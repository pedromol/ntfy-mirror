import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ntfy_mirror/auth/auth.dart';

void main() {
  group('AuthConfig.headers', () {
    test('none produces no headers', () {
      expect(const AuthConfig().headers, isEmpty);
      expect(AuthConfig.fromJson(null).headers, isEmpty);
    });

    test('bearer adds Authorization header', () {
      const c = AuthConfig(type: AuthType.bearer, token: 'secret-token');
      expect(c.headers, {'Authorization': 'Bearer secret-token'});
    });

    test('api key uses custom header name', () {
      const c = AuthConfig(
        type: AuthType.apiKey,
        headerName: 'X-API-Key',
        apiKey: 'my-key',
      );
      expect(c.headers, {'X-API-Key': 'my-key'});
    });

    test('api key trims header name', () {
      const c = AuthConfig(
        type: AuthType.apiKey,
        headerName: '  X-Auth  ',
        apiKey: 'k',
      );
      expect(c.headers.containsKey('X-Auth'), isTrue);
    });

    test('basic encodes base64(user:pass)', () {
      const c = AuthConfig(
        type: AuthType.basic,
        username: 'admin',
        password: 's3cret',
      );
      final expected =
          'Basic ${base64Encode(utf8.encode('admin:s3cret'))}';
      expect(c.headers['Authorization'], expected);
      expect(c.headers.length, 1);
    });
  });

  group('AuthConfig serialization', () {
    test('roundtrip preserves config', () {
      const c = AuthConfig(
        type: AuthType.apiKey,
        headerName: 'X-Key',
        apiKey: 'v',
      );
      expect(AuthConfig.fromJson(c.toJson()).toJson(), c.toJson());
    });

    test('missing storage is treated as none (backward compatible)', () {
      final c = AuthConfig.fromJson(null);
      expect(c.type, AuthType.none);
      expect(c.isEnabled, isFalse);
      expect(c.isValid, isTrue);
    });

    test('unknown type falls back to none', () {
      final c = AuthConfig.fromJson(const {'type': 'Nope', 'token': 't'});
      expect(c.type, AuthType.none);
    });

    test('storage keys are stable', () {
      expect(AuthType.none.storageKey, 'None');
      expect(AuthType.bearer.storageKey, 'Bearer');
      expect(AuthType.apiKey.storageKey, 'API key');
      expect(AuthType.basic.storageKey, 'Basic');
      expect(AuthType.fromStorageKey('Bearer'), AuthType.bearer);
      expect(AuthType.fromStorageKey('API key'), AuthType.apiKey);
    });
  });

  group('AuthConfig validation', () {
    test('none is always valid', () {
      expect(const AuthConfig().isValid, isTrue);
      expect(const AuthConfig().validationError, isNull);
    });

    test('bearer requires a token', () {
      const empty = AuthConfig(type: AuthType.bearer);
      const filled = AuthConfig(type: AuthType.bearer, token: 't');
      expect(empty.isValid, isFalse);
      expect(empty.validationError, isNotNull);
      expect(filled.isValid, isTrue);
    });

    test('api key requires header name and value', () {
      expect(
        const AuthConfig(type: AuthType.apiKey, headerName: '', apiKey: 'a')
            .isValid,
        isFalse,
      );
      expect(
        const AuthConfig(type: AuthType.apiKey, headerName: 'X').isValid,
        isFalse,
      );
      expect(
        const AuthConfig(
          type: AuthType.apiKey,
          headerName: 'X',
          apiKey: 'a',
        ).isValid,
        isTrue,
      );
    });

    test('basic requires username and password', () {
      expect(
        const AuthConfig(type: AuthType.basic, username: 'u').isValid,
        isFalse,
      );
      expect(
        const AuthConfig(type: AuthType.basic, password: 'p').isValid,
        isFalse,
      );
      expect(
        const AuthConfig(
          type: AuthType.basic,
          username: 'u',
          password: 'p',
        ).isValid,
        isTrue,
      );
    });
  });
}