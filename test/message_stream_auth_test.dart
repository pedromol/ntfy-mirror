import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ntfy_mirror/message_stream.dart';

class _MemoryStore implements RetryQueueStore {
  List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  @override
  Future<List<Map<String, dynamic>>> get() async =>
      List<Map<String, dynamic>>.from(_items);
  @override
  Future<void> set(List<Map<String, dynamic>> items) async {
    _items = List<Map<String, dynamic>>.from(items);
  }
}

class _FakeClient extends http.BaseClient {
  final List<http.Request> sent = <http.Request>[];
  int statusCode;
  _FakeClient(this.statusCode);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sent.add(request as http.Request);
    final bodyBytes = utf8.encode(await request.finalize().bytesToString());
    return http.StreamedResponse(Stream.value(bodyBytes), statusCode,
        request: request);
  }
}

const MethodChannel _prefsChannel = MethodChannel('msg_mirror_prefs');

Future<void> _mockAuth(Map<String, dynamic>? cfg) async {
  _prefsChannel.setMockMethodCallHandler((call) async {
    if (call.method == 'getAuth') {
      return cfg == null ? '' : jsonEncode(cfg);
    }
    return null;
  });
}

Future<http.Request> _recordRequest(int statusCode) async {
  final store = _MemoryStore();
  final client = _FakeClient(statusCode);
  final s = MessageStream(
    reception: '',
    endpoint: 'https://example.invalid',
    httpClient: client,
    queueStore: store,
  );
  await s.debugProcessSms({'from': 'A', 'body': 'B', 'date': 1});
  s.dispose();
  return client.sent.single;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _prefsChannel.setMockMethodCallHandler(null);
  });

  test('none → only Content-Type header', () async {
    await _mockAuth(null);
    final req = await _recordRequest(200);
    expect(req.headers.containsKey('Authorization'), isFalse);
    expect(req.headers['Content-Type'], startsWith('application/json'));
  });

  test('bearer → Authorization: Bearer token', () async {
    await _mockAuth({'type': 'Bearer', 'token': 'secret'});
    final req = await _recordRequest(200);
    expect(req.headers['Authorization'], 'Bearer secret');
    expect(req.headers['Content-Type'], startsWith('application/json'));
  });

  test('api key → custom header name', () async {
    await _mockAuth({
      'type': 'API key',
      'headerName': '  X-API-Key ',
      'apiKey': 'k123',
    });
    final req = await _recordRequest(200);
    expect(req.headers['X-API-Key'], 'k123');
  });

  test('basic → Authorization: Basic base64', () async {
    await _mockAuth({
      'type': 'Basic',
      'username': 'user',
      'password': 'pass',
    });
    final req = await _recordRequest(200);
    expect(
      req.headers['Authorization'],
      'Basic ${base64Encode(utf8.encode('user:pass'))}',
    );
  });

  test('401 → authFailure, item not enqueued', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _mockAuth({'type': 'Bearer', 'token': 'bad'});
    final store = _MemoryStore();
    final client = _FakeClient(401);
    final s = MessageStream(
      reception: '',
      endpoint: 'https://example.invalid',
      httpClient: client,
      queueStore: store,
    );
    await s.debugProcessSms({'from': 'A', 'body': 'B', 'date': 1});
    expect(s.debugGetQueue(), isEmpty);
    s.dispose();
  });

  test('403 → authFailure, item not enqueued', () async {
    await _mockAuth({'type': 'Bearer', 'token': 'bad'});
    final store = _MemoryStore();
    final client = _FakeClient(403);
    final s = MessageStream(
      reception: '',
      endpoint: 'https://example.invalid',
      httpClient: client,
      queueStore: store,
    );
    await s.debugProcessSms({'from': 'A', 'body': 'B', 'date': 1});
    expect(s.debugGetQueue(), isEmpty);
    s.dispose();
  });

  test('retry flush drops items that keep failing with 401', () async {
    await _mockAuth({'type': 'Basic', 'username': 'u', 'password': 'wrong'});
    final store = _MemoryStore();
    final client = _FakeClient(401);
    final s = MessageStream(
      reception: '',
      endpoint: 'https://example.invalid',
      httpClient: client,
      queueStore: store,
    );
    s.debugEnqueueRetry({'message_body': 'b', 'message_from': 'f', 'message_date': 'd', 'app': 'sms', 'type': 'sms'});
    await s.debugFlushRetryQueue(force: true);
    expect(s.debugGetQueue(), isEmpty);
    s.dispose();
  });
}