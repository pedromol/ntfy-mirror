import 'dart:convert';

/// The supported HTTP authentication types.
enum AuthType {
  none,
  bearer,
  apiKey,
  basic;

  /// Human readable label used in the UI.
  String get label => switch (this) {
        AuthType.none => 'None',
        AuthType.bearer => 'Bearer',
        AuthType.apiKey => 'API key',
        AuthType.basic => 'Basic',
      };

  /// Value persisted to secure storage. Kept as stable strings so stored
  /// configs survive renames of the enum values.
  String get storageKey => switch (this) {
        AuthType.none => 'None',
        AuthType.bearer => 'Bearer',
        AuthType.apiKey => 'API key',
        AuthType.basic => 'Basic',
      };

  static AuthType fromStorageKey(String? key) => switch (key) {
        'Bearer' => AuthType.bearer,
        'API key' => AuthType.apiKey,
        'Basic' => AuthType.basic,
        _ => AuthType.none,
      };
}

/// Why the configured auth is incomplete. The UI maps each code to a
/// localized message, so no user-facing English text lives here.
enum AuthValidationError { missingToken, missingHeaderName, missingApiKey, missingUsername, missingPassword }

/// Holds the user-configured HTTP authentication settings.
///
/// Only the fields relevant to [type] are used; the others remain empty.
/// Values are persisted (encrypted) so they are never logged or exposed in
/// plain text by the forwarding code.
class AuthConfig {
  final AuthType type;
  final String token;
  final String headerName;
  final String apiKey;
  final String username;
  final String password;

  const AuthConfig({
    this.type = AuthType.none,
    this.token = '',
    this.headerName = 'X-API-Key',
    this.apiKey = '',
    this.username = '',
    this.password = '',
  });

  static const AuthConfig none = AuthConfig();

  bool get isEnabled => type != AuthType.none;

  bool get isValid => switch (type) {
        AuthType.none => true,
        AuthType.bearer => token.trim().isNotEmpty,
        AuthType.apiKey => headerName.trim().isNotEmpty && apiKey.trim().isNotEmpty,
        AuthType.basic => username.trim().isNotEmpty && password.isNotEmpty,
      };

  /// Describes what is missing, when invalid. Localized by the UI.
  AuthValidationError? get validationError => switch (type) {
        AuthType.none => null,
        AuthType.bearer =>
          token.trim().isEmpty ? AuthValidationError.missingToken : null,
        AuthType.apiKey =>
          headerName.trim().isEmpty
              ? AuthValidationError.missingHeaderName
              : (apiKey.trim().isEmpty
                  ? AuthValidationError.missingApiKey
                  : null),
        AuthType.basic =>
          username.trim().isEmpty
              ? AuthValidationError.missingUsername
              : (password.isEmpty
                  ? AuthValidationError.missingPassword
                  : null),
      };

  /// HTTP headers to attach to the outgoing request.
  ///
  /// Returns an empty map for [AuthType.none] so behavior is unchanged when no
  /// authentication is configured.
  Map<String, String> get headers => switch (type) {
        AuthType.none => const {},
        AuthType.bearer => {'Authorization': 'Bearer ${token.trim()}'},
        AuthType.apiKey => {headerName.trim(): apiKey},
        AuthType.basic => {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          },
      };

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.storageKey,
        'token': token,
        'headerName': headerName,
        'apiKey': apiKey,
        'username': username,
        'password': password,
      };

  static AuthConfig fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return AuthConfig.none;
    return AuthConfig(
      type: AuthType.fromStorageKey((json['type'] as String?) ?? ''),
      token: (json['token'] as String?) ?? '',
      headerName: (json['headerName'] as String?) ?? 'X-API-Key',
      apiKey: (json['apiKey'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      password: (json['password'] as String?) ?? '',
    );
  }
}