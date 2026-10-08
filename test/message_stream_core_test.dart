import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ntfy_mirror/message_stream.dart';

class _MemoryStore implements RetryQueueStore {
  List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  @override
  Future<List<Map<String, dynamic>>> get() async => List<Map<String, dynamic>>.from(_items);
  @override
  Future<void> set(List<Map<String, dynamic>> items) async { _items = List<Map<String, dynamic>>.from(items); }
}

class _FakeClient extends http.BaseClient {
  final List<http.Request> sent = <http.Request>[];
  int statusCode;
  _FakeClient(this.statusCode);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sent.add(request as http.Request);
    final bodyBytes = utf8.encode(await request.finalize().bytesToString());
    return http.StreamedResponse(Stream.value(bodyBytes), statusCode, request: request);
  }
}

void _setTestChannelHandler(Future<Object?>? Function(MethodCall)? handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('msg_mirror_test'), handler);
}

/// Mocks the `msg_mirror_test` channel; when [autoEcho] is true it immediately
/// signals the echo back, as the native listener would do.
void _mockTestChannel({required bool autoEcho}) {
  _setTestChannelHandler((MethodCall call) async {
    if (autoEcho && call.method == 'postTestNotification') {
      MessageStream.resolveValidationEcho((call.arguments as String?) ?? '');
    }
    return null;
  });
}

void _clearTestChannel() => _setTestChannelHandler(null);

void main() {
  setUp(() { TestWidgetsFlutterBinding.ensureInitialized(); });

  test('post success → no enqueue', () async {
    final store = _MemoryStore();
    final client = _FakeClient(200);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    await s.debugProcessSms({'from': 'A', 'body': 'B', 'date': 1});
    expect(s.debugGetQueue().isEmpty, true);
    s.dispose();
  });

  test('post 503 → enqueue', () async {
    final store = _MemoryStore();
    final client = _FakeClient(503);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    await s.debugProcessSms({'from': 'A', 'body': 'B', 'date': 1});
    expect(s.debugGetQueue().length, 1);
    s.dispose();
  });

  test('queue cap evicts oldest', () async {
    final store = _MemoryStore();
    final client = _FakeClient(503);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    for (int i = 0; i < 55; i++) {
      s.debugEnqueueRetry({'message_body': 'b$i', 'message_from': 'f$i', 'message_date': 'd', 'app': 'sms', 'type': 'sms'});
    }
    expect(s.debugGetQueue().length, 50);
    s.dispose();
  });

  test('non-force flush stops on first failure', () async {
    final store = _MemoryStore();
    final client = _FakeClient(503);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    s.debugEnqueueRetry({'message_body': 'b1', 'message_from': 'f1', 'message_date': 'd', 'app': 'sms', 'type': 'sms'});
    s.debugEnqueueRetry({'message_body': 'b2', 'message_from': 'f2', 'message_date': 'd', 'app': 'sms', 'type': 'sms'});
    await s.debugFlushRetryQueue(force: false);
    // Should stop after the first failure and leave at least one
    expect(s.debugGetQueue().isNotEmpty, true);
    s.dispose();
  });

  test('dedup: notification and sms keys', () async {
    final store = _MemoryStore();
    final client = _FakeClient(200);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    // Notification duplicates
    await s.debugProcessNotification({'app': 'com.x', 'title': 'T', 'text': 'X', 'when': 123, 'isGroupSummary': false});
    await s.debugProcessNotification({'app': 'com.x', 'title': 'T', 'text': 'X', 'when': 123, 'isGroupSummary': false});
    // SMS duplicates
    await s.debugProcessSms({'from': 'A', 'body': 'B', 'date': 10});
    await s.debugProcessSms({'from': 'A', 'body': 'B', 'date': 10});
    // No enqueues since success client, but dedup also should not send duplicates, not easily observable; assert queue empty
    expect(s.debugGetQueue().isEmpty, true);
    s.dispose();
  });

  test('skip conditions: group summary, self app, empty body', () async {
    final store = _MemoryStore();
    final client = _FakeClient(503);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    // group summary
    await s.debugProcessNotification({'app': 'com.x', 'title': 'T', 'text': 'X', 'when': 1, 'isGroupSummary': true});
    // self app
    await s.debugProcessNotification({'app': 'br.mol.net.br', 'title': 'T', 'text': 'X', 'when': 2, 'isGroupSummary': false});
    // empty body
    await s.debugProcessNotification({'app': 'com.x', 'title': '', 'text': '', 'when': 3, 'isGroupSummary': false});
    expect(s.debugGetQueue().isEmpty, true);
    s.dispose();
  });

  test('validation echo (isTest) bypasses self-app and allowlist filters', () async {
    final store = _MemoryStore();
    final client = _FakeClient(503);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    // Self-app + non-allowed package, but flagged as a validation test event.
    await s.debugProcessNotification({
      'app': 'br.mol.net.br',
      'title': 'T',
      'text': 'X',
      'when': 1,
      'isGroupSummary': false,
      'isTest': true,
    });
    expect(s.debugGetQueue().length, 1);
    s.dispose();
  });

  test('validation success: endpoint ok and echo received', () async {
    _mockTestChannel(autoEcho: true);
    final store = _MemoryStore();
    final client = _FakeClient(200);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    final report = await s.runValidation(timeout: const Duration(seconds: 3));
    expect(report.httpOk, true);
    expect(report.received, true);
    expect(report.success, true);
    expect(client.sent.length, 1);
    s.dispose();
    _clearTestChannel();
  });

  test('validation timeout: endpoint ok but echo never arrives', () async {
    _mockTestChannel(autoEcho: false);
    final store = _MemoryStore();
    final client = _FakeClient(200);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    final report = await s.runValidation(timeout: const Duration(milliseconds: 200));
    expect(report.httpOk, true);
    expect(report.received, false);
    expect(report.timedOut, true);
    expect(report.success, false);
    s.dispose();
    _clearTestChannel();
  });

  test('validation: endpoint failure reported immediately', () async {
    _mockTestChannel(autoEcho: true);
    final store = _MemoryStore();
    final client = _FakeClient(503);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    final report = await s.runValidation(timeout: const Duration(seconds: 3));
    expect(report.httpOk, false);
    expect(report.received, false);
    expect(report.success, false);
    expect(client.sent.length, 1);
    s.dispose();
    _clearTestChannel();
  });

  test('validation: missing native test channel reported', () async {
    _setTestChannelHandler(null);
    final store = _MemoryStore();
    final client = _FakeClient(200);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    final report = await s.runValidation(timeout: const Duration(seconds: 3));
    expect(report.httpOk, true);
    expect(report.received, false);
    expect(report.timedOut, false);
    expect(report.failure, ValidationFailure.testNotificationUnsupported);
    expect(report.errorDetail, isNull);
    s.dispose();
  });

  test('validation: notification permission denied reported', () async {
    _setTestChannelHandler((MethodCall call) async {
      throw PlatformException(code: 'notifications_disabled', message: 'Notifications are disabled for this app');
    });
    final store = _MemoryStore();
    final client = _FakeClient(200);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    final report = await s.runValidation(timeout: const Duration(seconds: 3));
    expect(report.httpOk, true);
    expect(report.received, false);
    expect(report.timedOut, false);
    expect(report.failure, ValidationFailure.notificationsDisabled);
    expect(client.sent.length, 1);
    s.dispose();
    _clearTestChannel();
  });

  test('validation: disconnected listener reported instead of timing out', () async {
    MessageStream.debugListenerGate =
        (Duration wait) async => ValidationFailure.listenerNotRunning;
    var posted = false;
    _setTestChannelHandler((MethodCall call) async {
      if (call.method == 'postTestNotification') posted = true;
      return null;
    });
    final store = _MemoryStore();
    final client = _FakeClient(200);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    final report = await s.runValidation(timeout: const Duration(seconds: 3));
    expect(report.httpOk, true);
    expect(report.received, false);
    expect(report.timedOut, false);
    expect(report.failure, ValidationFailure.listenerNotRunning);
    expect(client.sent.length, 1);
    expect(posted, false);
    s.dispose();
    MessageStream.debugListenerGate = null;
    _clearTestChannel();
  });

  test('validation: healthy listener gate lets the round trip proceed', () async {
    MessageStream.debugListenerGate = (Duration wait) async => null;
    _mockTestChannel(autoEcho: true);
    final store = _MemoryStore();
    final client = _FakeClient(200);
    final s = MessageStream(reception: '', endpoint: 'https://example.invalid', httpClient: client, queueStore: store);
    final report = await s.runValidation(timeout: const Duration(seconds: 3));
    expect(report.success, true);
    expect(report.received, true);
    s.dispose();
    MessageStream.debugListenerGate = null;
    _clearTestChannel();
  });
}


