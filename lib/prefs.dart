import 'dart:convert';

import 'package:flutter/services.dart';

/// Thin wrapper around the `msg_mirror_prefs` platform channel.
class Prefs {
  static const MethodChannel _channel = MethodChannel('msg_mirror_prefs');

  static Future<String> getReception() async {
    try {
      final res = await _channel.invokeMethod('getReception');
      return (res ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  static Future<void> setReception(String value) async {
    try {
      await _channel.invokeMethod('setReception', value);
    } catch (_) {}
  }

  static Future<String> getEndpoint() async {
    try {
      final res = await _channel.invokeMethod('getEndpoint');
      return (res ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  static Future<void> setEndpoint(String value) async {
    try {
      await _channel.invokeMethod('setEndpoint', value);
    } catch (_) {}
  }

  static Future<bool> getSmsEnabled() async {
    try {
      final res = await _channel.invokeMethod('getSmsEnabled');
      return res == true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> setSmsEnabled(bool value) async {
    try {
      await _channel.invokeMethod('setSmsEnabled', value);
    } catch (_) {}
  }

  static Future<Set<String>> getAllowedPackages() async {
    try {
      final res = await _channel.invokeMethod('getAllowedPackages');
      final list = (res as List<dynamic>?) ?? const <dynamic>[];
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> setAllowedPackages(Set<String> packages) async {
    try {
      await _channel.invokeMethod('setAllowedPackages', packages.toList());
    } catch (_) {}
  }

  /// Returns the auth config as a decoded map, or an empty map when no auth
  /// has been configured (backward compatible with existing installs).
  static Future<Map<String, dynamic>> getAuth() async {
    try {
      final res = await _channel.invokeMethod('getAuth');
      final json = (res ?? '').toString().trim();
      if (json.isEmpty || json == 'null') return <String, dynamic>{};
      return (jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static Future<void> setAuth(Map<String, dynamic> auth) async {
    try {
      await _channel.invokeMethod('setAuth', jsonEncode(auth));
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getRetryQueue() async {
    try {
      final res = await _channel.invokeMethod('getRetryQueue');
      final json = (res ?? '[]').toString();
      final list = (jsonDecode(json) as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return list;
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  static Future<void> setRetryQueue(List<Map<String, dynamic>> items) async {
    try {
      await _channel.invokeMethod('setRetryQueue', jsonEncode(items));
    } catch (_) {}
  }

  static Future<String> getPayloadTemplate() async {
    try {
      final res = await _channel.invokeMethod('getPayloadTemplate');
      return (res ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  static Future<void> setPayloadTemplate(String value) async {
    try {
      await _channel.invokeMethod('setPayloadTemplate', value);
    } catch (_) {}
  }

  static Future<String> getThemeMode() async {
    try {
      final res = await _channel.invokeMethod('getThemeMode');
      return (res ?? 'system').toString();
    } catch (_) {
      return 'system';
    }
  }

  static Future<void> setThemeMode(String value) async {
    try {
      await _channel.invokeMethod('setThemeMode', value);
    } catch (_) {}
  }
}