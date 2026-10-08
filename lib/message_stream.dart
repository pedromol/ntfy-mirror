
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ntfy_mirror/auth/auth.dart';
import 'package:ntfy_mirror/logger.dart';
import 'package:ntfy_mirror/permissions.dart';
import 'package:ntfy_mirror/prefs.dart';
import 'package:ntfy_mirror/template_renderer.dart';

/// A payload to be sent to the API, including the body and optional headers.
class MirroredPayload {
  final String body;
  final Map<String, String> headers;
  final bool isJson;

  MirroredPayload({
    required this.body,
    required this.headers,
    this.isJson = false,
  });

  Map<String, dynamic> toMap() => {
    'body': body,
    'headers': headers,
    'isJson': isJson,
  };

  factory MirroredPayload.fromMap(Map<String, dynamic> map) => MirroredPayload(
    body: map['body'] as String,
    headers: Map<String, String>.from(map['headers'] as Map),
    isJson: map['isJson'] as bool,
  );
}

enum SendResult {

  success,
  failure,
  authFailure,
}

/// Why a round-trip validation run failed.
///
/// Codes, not strings: the UI maps each value to a localized message via
/// `AppLocalizations`, so no user-facing English text lives here.
enum ValidationFailure {
  authFailure,
  endpointUnreachable,
  listenerNoAccess,
  listenerNotRunning,
  notificationsDisabled,
  testNotificationUnsupported,
  testNotificationFailed,
}

/// Result of a round-trip validation run.
///
/// A test message is POSTed to the endpoint (`httpOk`) and a local test
/// notification is posted; when that notification comes back through the
/// listener the run is confirmed (`received`).
class ValidationReport {
  final String token;
  final bool httpOk;
  final bool received;
  final bool timedOut;
  final ValidationFailure? failure;

  /// Technical detail (e.g. the native platform error) shown alongside the
  /// localized message for [ValidationFailure.testNotificationFailed].
  final String? errorDetail;

  const ValidationReport({
    required this.token,
    required this.httpOk,
    required this.received,
    required this.timedOut,
    this.failure,
    this.errorDetail,
  });

  bool get success => httpOk && received;
}

abstract class RetryQueueStore {
  Future<List<Map<String, dynamic>>> get();
  Future<void> set(List<Map<String, dynamic>> items);
}

class PrefsRetryQueueStore implements RetryQueueStore {
  @override
  Future<List<Map<String, dynamic>>> get() => Prefs.getRetryQueue();

  @override
  Future<void> set(List<Map<String, dynamic>> items) => Prefs.setRetryQueue(items);
}

class MessageStream {
  static const MethodChannel _channel = MethodChannel('msg_mirror');
  static const MethodChannel _testChannel = MethodChannel('msg_mirror_test');
  static const MethodChannel _resultChannel = MethodChannel('msg_mirror_result');

  // Round-trip validation state. Static so the native echo (delivered on
  // `msg_mirror_result`) can resolve the pending run in any isolate.
  static String? _pendingToken;
  static Completer<void>? _echoCompleter;

  /// Test seam: replaces the native listener-readiness probe with a fake so
  /// the "listener not running" paths can be exercised off-device.
  @visibleForTesting
  static Future<ValidationFailure?> Function(Duration wait)? debugListenerGate;

  /// Completes the pending validation when the native side reports that the
  /// test message came back.
  static void resolveValidationEcho(String token) {
    final completer = _echoCompleter;
    if (_pendingToken != null &&
        token.isNotEmpty &&
        token == _pendingToken &&
        completer != null &&
        !completer.isCompleted) {
      completer.complete(null);
    }
  }

  /// Wires the `msg_mirror_result` channel used to receive the validation echo.
  static void wireValidationResultChannel() {
    _resultChannel.setMethodCallHandler((call) async {
      if (call.method == 'onValidationEcho') {
        resolveValidationEcho((call.arguments as String?) ?? '');
      }
    });
  }

  String reception;
  String endpoint = '';
  String? payloadTemplate; // User-defined JSON template
  final Set<String> _recentKeys = <String>{};
  final List<String> _recentOrder = <String>[];
  static const int _recentCap = 300;
  // Minimal retry queue with exponential backoff
  final List<Map<String, dynamic>> _retryQueue = <Map<String, dynamic>>[];
  int _backoffMs = 2000;
  static const int _maxBackoffMs = 60000;
  Timer? _retryTimer;
  static const int _retryCap = 50;
  final http.Client _http;
  final RetryQueueStore _queueStore;

  MessageStream({required this.reception, String? endpoint, http.Client? httpClient, RetryQueueStore? queueStore})
      : _http = httpClient ?? http.Client(),
        _queueStore = queueStore ?? PrefsRetryQueueStore() {
    if (endpoint != null && endpoint.isNotEmpty) {
      this.endpoint = endpoint;
    }
  }

  Future<void> start() async {
    _channel.setMethodCallHandler(_onNative);
    Logger.d('Dart handler registered (reception=${reception.isEmpty ? 'EMPTY' : 'SET'})');
    _restoreQueue();
    await _loadTemplate();
  }

  Future<void> _loadTemplate() async {
    try {
      final tpl = await Prefs.getPayloadTemplate();
      if (tpl.trim().isNotEmpty) payloadTemplate = tpl;
    } catch (_) {}
  }

  Future<dynamic> _onNative(MethodCall call) async {
    try {
      await Logger.d('Native call received: ${call.method} (args=${call.arguments})');
      // The round-trip validation echo must be recognized BEFORE the regular
      // filters run, otherwise the test event would be dropped (self app,
      // non-allowed package, dedup) and never reported as received.
      if (call.method == 'onNotification' || call.method == 'onSms') {
        final echo = call.arguments;
        if (echo is Map) _checkValidationEcho(echo.values.map((e) => '$e').join(' '));
      }
      switch (call.method) {
        case 'onNotification':
          final args = call.arguments;
          if (args is! Map) {
            await Logger.e('onNotification args is not a Map: $args');
            break;
          }
          final payload = await _buildNotifPayload(args as Map<dynamic, dynamic>);
          if (payload != null) {
            await Logger.d('Sending notification payload: ${payload.headers['Title'] ?? 'unknown'}');
            final result = await _sendToApi(payload);
            if (result == SendResult.failure) {
              _enqueueRetry(payload);
            } else if (result == SendResult.authFailure) {
              await Logger.e('Notification not queued — authentication failed. Check credentials in settings.');
            }
          } else {
            await Logger.d('Notification payload skipped (group summary or empty)');
          }
          break;
        case 'onSms':
          final args = call.arguments;
          if (args is! Map) {
            await Logger.e('onSms args is not a Map: $args');
            break;
          }
          final payload = _buildSmsPayload(args as Map<dynamic, dynamic>);
          if (payload != null) {
            await Logger.d('Sending SMS payload from ${payload.headers['Title'] ?? 'unknown'}');
            final result = await _sendToApi(payload);
            if (result == SendResult.failure) {
              _enqueueRetry(payload);
            } else if (result == SendResult.authFailure) {
              await Logger.e('SMS not queued — authentication failed. Check credentials in settings.');
            }
          } else {
            await Logger.d('SMS payload skipped (empty body)');
          }
          break;
        case 'forceRetry':
          await Logger.d('Force retry requested');
          await _flushRetryQueue(force: true);
          break;
      }
    } catch (err) {
      await Logger.e('Handler error: $err');
    }
    return null;
  }

  Future<MirroredPayload?> _buildNotifPayload(Map<dynamic, dynamic> m) async {
    final String app = (m['app'] ?? '').toString();
    final String title = (m['title'] ?? '').toString();
    final String text = (m['text'] ?? '').toString().trim();
    final bool isGroupSummary = (m['isGroupSummary'] ?? false) == true;
    final int whenMs = (m['when'] is int) ? (m['when'] as int) : 0;
    final String subText = (m['subText'] ?? '').toString();
    final String summaryText = (m['summaryText'] ?? '').toString();
    final String bigText = (m['bigText'] ?? '').toString();
    final String infoText = (m['infoText'] ?? '').toString();
    final String people = (m['people'] ?? '').toString();
    final String largeIcon = (m['largeIcon'] ?? '').toString();
    final String smallIcon = (m['smallIcon'] ?? '').toString();
    final String picture = (m['picture'] ?? '').toString();
    final String category = (m['category'] ?? '').toString();
    final String priority = (m['priority'] ?? '').toString();
    final String channelId = (m['channelId'] ?? '').toString();
    final String actions = (m['actions'] ?? '').toString();
    final String groupKey = (m['groupKey'] ?? '').toString();
    final String visibility = (m['visibility'] ?? '').toString();
    final String color = (m['color'] ?? '').toString();
    final String badgeIconType = (m['badgeIconType'] ?? '').toString();
    // Skip obvious ongoing/background work notifications
    final bool isTest = (m['isTest'] ?? false) == true;
    if (text.contains('doing work in the background')) {
      Logger.d('Skip background-work notification');
      return null;
    }
    // Only forward from allowed packages (persisted in prefs via native channel).
    // Validation test events bypass both the allowlist and the self-app skip so
    // the sent message is able to come back and prove the loop works.
    final allowed = await _getAllowedPackages();
    if (!isTest && allowed.isNotEmpty && !allowed.contains(app)) {
      Logger.d('Skip non-allowed app: $app');
      return null;
    }
    if (!isTest && app == 'br.mol.net.br') {
      Logger.d('Skip self notification');
      return null;
    }
    if (isGroupSummary) {
      Logger.d('Skip group summary');
      return null;
    }
    final String body = text.isNotEmpty ? text : title;
    if (body.isEmpty) {
      Logger.d('Skip notification with empty body');
      return null;
    }
    final key = _notifKey(app, whenMs);
    if (_isDuplicate(key)) {
      Logger.d('Skip duplicate notification key=$key');
      return null;
    }
    final dateStr = _formatDate(DateTime.fromMillisecondsSinceEpoch(whenMs == 0 ? DateTime.now().millisecondsSinceEpoch : whenMs));
    final extraValues = <String, String>{
      'title': title,
      'text': text,
      'when': whenMs.toString(),
      'isGroupSummary': isGroupSummary.toString(),
      'subText': subText,
      'summaryText': summaryText,
      'bigText': bigText,
      'infoText': infoText,
      'people': people,
      'largeIcon': largeIcon,
      'smallIcon': smallIcon,
      'picture': picture,
      'category': category,
      'priority': priority,
      'channelId': channelId,
      'actions': actions,
      'groupKey': groupKey,
      'visibility': visibility,
      'color': color,
      'badgeIconType': badgeIconType,
    };
    final base = _renderPayload(
      from: title,
      body: body,
      date: dateStr,
      app: app,
      type: 'notification',
      extraValues: extraValues,
    );
    return base;
  }
  Future<Set<String>> _getAllowedPackages() async {
    try {
      const MethodChannel ch = MethodChannel('msg_mirror_prefs');
      final list = await ch.invokeMethod('getAllowedPackages') as List<dynamic>;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  MirroredPayload? _buildSmsPayload(Map<dynamic, dynamic> m) {
    final String from = (m['from'] ?? '').toString();
    final String body = (m['body'] ?? '').toString();
    final int dateMs = (m['date'] is int) ? (m['date'] as int) : 0;
    if (body.isEmpty) return null;
    final key = _smsKey(from, dateMs);
    if (_isDuplicate(key)) {
      Logger.d('Skip duplicate SMS key=$key');
      return null;
    }
    final dateStr = _formatDate(DateTime.fromMillisecondsSinceEpoch(dateMs == 0 ? DateTime.now().millisecondsSinceEpoch : dateMs));
    return _renderPayload(
      from: from,
      body: body,
      date: dateStr,
      app: 'sms',
      type: 'sms',
    );
  }

  MirroredPayload _renderPayload({required String from, required String body, required String date, required String app, required String type, Map<String, String>? extraValues}) {
    final headers = <String, String>{
      'Title': from,
      'Priority': extraValues?['priority'] ?? 'default',
      'Tags': app,
    };

    if (extraValues != null) {
      final icon = extraValues['largeIcon'] ?? extraValues['smallIcon'];
      if (icon != null && icon.isNotEmpty) {
        headers['Icon'] = icon;
      }
    }

    final tpl = payloadTemplate;
    if (tpl == null || tpl.trim().isEmpty) {
      return MirroredPayload(
        body: body,
        headers: headers,
        isJson: false,
      );
    }

    final values = <String, String>{
      'body': body,
      'from': from,
      'date': date,
      'app': app,
      'type': type,
      'reception': reception,
    };
    if (extraValues != null && extraValues.isNotEmpty) {
      values.addAll(extraValues);
    }

    final rendered = TemplateRenderer.render(tpl, values, fallback: null);
    return MirroredPayload(
      body: rendered.toString(),
      headers: {'Content-Type': 'application/json'},
      isJson: true,
    );
  }

  

  Future<SendResult> _sendToApi(dynamic payload) async {
    final uri = Uri.parse(endpoint);
    final auth = AuthConfig.fromJson(await Prefs.getAuth());
    if (auth.isEnabled) {
      await Logger.d('Sending with auth: ${auth.type.storageKey}');
    }
    final headers = <String, String>{
      ...auth.headers,
    };

    String body;
    if (payload is MirroredPayload) {
      headers.addAll(payload.headers);
      body = payload.body;
      if (!payload.isJson) {
        headers['Content-Type'] = 'text/plain';
      } else {
        headers['Content-Type'] = 'application/json';
      }
    } else {
      // Fallback for potential legacy calls or unexpected types
      headers['Content-Type'] = 'text/plain';
      body = payload.toString();
    }

    try {
      final resp = await _http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 12));
      await Logger.d('POST done: status=${resp.statusCode}, len=${resp.body.length}');
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        await Logger.e('Authentication failed (HTTP ${resp.statusCode}) — check your credentials.');
        return SendResult.authFailure;
      }
      if (resp.statusCode >= 400) {
        await Logger.e('POST failed with status: ${resp.statusCode}');
        return SendResult.failure;
      }
      return SendResult.success;
    } catch (err) {
      await Logger.e('POST failed: $err');
      return SendResult.failure;
    }
  }

  void _enqueueRetry(dynamic payload) {
    if (payload is! MirroredPayload) return;
    final map = payload.toMap();
    if (_retryQueue.length >= _retryCap) {
      _retryQueue.removeAt(0);
    }
    _retryQueue.add(map);
    _persistQueue();
    _scheduleRetry();
  }


  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(milliseconds: _backoffMs), _flushRetryQueue);
    Logger.d('Retry scheduled in ${_backoffMs}ms (queue=${_retryQueue.length})');
    _backoffMs = (_backoffMs * 2).clamp(2000, _maxBackoffMs);
  }

  Future<void> _flushRetryQueue({bool force = false}) async {
    if (_retryQueue.isEmpty) {
      _backoffMs = 2000;
      return;
    }
    await Logger.d('Retry flush start: size=${_retryQueue.length} force=$force');
    final current = List<Map<String, dynamic>>.from(_retryQueue);
    _retryQueue.clear();
    for (final map in current) {
      final payload = MirroredPayload.fromMap(map);
      final result = await _sendToApi(payload);
      if (result == SendResult.failure) {
        _enqueueRetry(payload);
        if (!force) {
          // Stop early on first failure in normal mode to respect backoff pacing
          break;
        }
      } else if (result == SendResult.authFailure) {
        await Logger.e('Dropped queued item — authentication failed. Check credentials in settings.');
      }
    }
    await _persistQueue();
    await Logger.d('Retry flush done: remaining=${_retryQueue.length}');
    if (_retryQueue.isNotEmpty) {
      if (force) {
        // On force, schedule next attempt with minimal backoff
        _backoffMs = 2000;
      }
      _scheduleRetry();
    } else {
      _backoffMs = 2000;
    }
  }

  Future<void> _persistQueue() async {
    try {
      await _queueStore.set(_retryQueue);
    } catch (_) {}
  }

  Future<void> _restoreQueue() async {
    try {
      final items = await _queueStore.get();
      _retryQueue.clear();
      _retryQueue.addAll(items);
      if (_retryQueue.isNotEmpty) {
        _scheduleRetry();
      }
    } catch (_) {}
  }

  String _notifKey(String app, int whenMs) => '$app|$whenMs';
  String _smsKey(String from, int dateMs) => 'sms|$from|$dateMs';

  bool _isDuplicate(String key) {
    if (_recentKeys.contains(key)) return true;
    _recentKeys.add(key);
    _recentOrder.add(key);
    if (_recentOrder.length > _recentCap) {
      final old = _recentOrder.removeAt(0);
      _recentKeys.remove(old);
    }
    return false;
  }
  String _formatDate(DateTime dt) {
    String two(int v) => v < 10 ? '0$v' : '$v';
    final y = dt.year.toString().padLeft(4, '0');
    final mo = two(dt.month);
    final d = two(dt.day);
    final h = two(dt.hour);
    final mi = two(dt.minute);
    return '$y-$mo-$d $h:$mi';
  }

  // Test helpers
  List<Map<String, dynamic>> debugGetQueue() => List<Map<String, dynamic>>.from(_retryQueue);
  int debugGetBackoffMs() => _backoffMs;
  Future<void> debugFlushRetryQueue({bool force = false}) => _flushRetryQueue(force: force);
  void debugEnqueueRetry(Map<String, dynamic> payload) => _enqueueRetry(payload);
  void dispose() { _retryTimer?.cancel(); }

  void _checkValidationEcho(String candidate) {
    final token = _pendingToken;
    final completer = _echoCompleter;
    if (token == null ||
        token.isEmpty ||
        !candidate.contains(token) ||
        completer == null ||
        completer.isCompleted) {
      return;
    }
    completer.complete(null);
  }

  String _newToken() {
    final rnd = Random.secure();
    final bytes = List.generate(4, (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    return 'MMV-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}-$bytes';
  }

  /// Fails fast when the echo can never come back: notification access must be
  /// granted *and* the native listener must actually be bound — OEM skins
  /// (MIUI/HyperOS) keep access granted while silently dropping the bind.
  ///
  /// Returns `null` when the listener is ready, otherwise the failure code
  /// describing why the round trip cannot proceed.
  Future<ValidationFailure?> _ensureListenerReady(Duration wait) async {
    final gate = debugListenerGate;
    if (gate != null) return gate(wait);
    try {
      if (!await PermissionService.hasNotificationAccess()) {
        return ValidationFailure.listenerNoAccess;
      }
      if (await PermissionService.isListenerConnected()) return null;
      await PermissionService.rebindListener();
      final deadline = DateTime.now().add(wait);
      while (DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (await PermissionService.isListenerConnected()) return null;
      }
      return ValidationFailure.listenerNotRunning;
    } catch (_) {
      // Platform hooks unavailable (e.g. in tests) — let the round trip decide.
      return null;
    }
  }

  /// Posts the local test notification. Returns `null` on success or a
  /// failure code (plus optional technical detail) when the native side
  /// refuses to post it.
  Future<({ValidationFailure failure, String? detail})?> _postTestNotification(
      String token) async {
    try {
      await _testChannel.invokeMethod('postTestNotification', token);
      return null;
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'notifications_disabled':
          return (failure: ValidationFailure.notificationsDisabled, detail: null);
        case 'bad_token':
          return (failure: ValidationFailure.testNotificationFailed, detail: null);
        default:
          return (
            failure: ValidationFailure.testNotificationFailed,
            detail: e.message ?? e.code,
          );
      }
    } on MissingPluginException {
      return (failure: ValidationFailure.testNotificationUnsupported, detail: null);
    } catch (_) {
      return (failure: ValidationFailure.testNotificationFailed, detail: null);
    }
  }

  Future<void> _cancelTestNotification() async {
    try {
      await _testChannel.invokeMethod('cancelTestNotification');
    } catch (_) {}
  }

  /// Round-trip validation: POSTs a test message to the endpoint, then posts a
  /// local test notification and waits for it to come back through the listener.
  /// This tests connectivity and authentication (HTTP request to endpoint) plus
  /// the notification forwarding loop.
  ///
  /// The test event is exempt from the self-app / allowed-packages filters so the
  /// message can actually be received again (see `isTest` handling in
  /// [_buildNotifPayload] and the native listener).
  Future<ValidationReport> runValidation({
    Duration timeout = const Duration(seconds: 60),
    Duration listenerWait = const Duration(seconds: 4),
  }) async {
    final token = _newToken();
    _pendingToken = token;
    _echoCompleter = Completer<void>();
    await Logger.d('Validation: start token=$token');
    try {
      final payload = _renderPayload(
        from: 'Ntfy Mirror',
        body: 'Mirror validation test — $token',
        date: _formatDate(DateTime.now()),
        app: 'validation',
        type: 'validation',
      );
      final result = await _sendToApi(payload);
      if (result != SendResult.success) {
        final failure = result == SendResult.authFailure
            ? ValidationFailure.authFailure
            : ValidationFailure.endpointUnreachable;
        await Logger.e('Validation: ${failure.name}');
        return ValidationReport(token: token, httpOk: false, received: false, timedOut: false, failure: failure);
      }

      final listenerFailure = await _ensureListenerReady(listenerWait);
      if (listenerFailure != null) {
        await Logger.e('Validation: ${listenerFailure.name}');
        return ValidationReport(token: token, httpOk: true, received: false, timedOut: false, failure: listenerFailure);
      }

      final postError = await _postTestNotification(token);
      if (postError != null) {
        await Logger.e('Validation: ${postError.failure.name}${postError.detail != null ? ' — ${postError.detail}' : ''}');
        return ValidationReport(token: token, httpOk: true, received: false, timedOut: false, failure: postError.failure, errorDetail: postError.detail);
      }

      try {
        await _echoCompleter!.future.timeout(timeout);
        await Logger.d('Validation: message received back');
        return ValidationReport(token: token, httpOk: true, received: true, timedOut: false);
      } on TimeoutException {
        await Logger.e('Validation: test message sent but not received back within ${timeout.inSeconds}s');
        return ValidationReport(token: token, httpOk: true, received: false, timedOut: true);
      }
    } finally {
      await _cancelTestNotification();
      _pendingToken = null;
      _echoCompleter = null;
    }
  }

  Future<void> debugProcessSms(Map<String, dynamic> args) async {
    final payload = _buildSmsPayload(args);
    if (payload != null) {
      final result = await _sendToApi(payload);
      if (result == SendResult.failure) {
        _enqueueRetry(payload);
      }
    }
  }

  Future<void> debugProcessNotification(Map<String, dynamic> args) async {
    final payload = await _buildNotifPayload(args);
    if (payload != null) {
      final result = await _sendToApi(payload);
      if (result == SendResult.failure) {
        _enqueueRetry(payload);
      }
    }
  }
}
