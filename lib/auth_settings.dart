import 'package:flutter/material.dart';
import 'package:ntfy_mirror/auth/auth.dart';
import 'package:ntfy_mirror/l10n/app_localizations.dart';
import 'package:ntfy_mirror/prefs.dart';

/// Section that lets the user configure HTTP authentication for the endpoint.
///
/// Supports: None, Bearer token, API key (custom header) and Basic auth.
/// Credentials are persisted through [Prefs.setAuth], which stores them
/// encrypted on Android. Nothing here logs or exposes the secret values.
class AuthSettingsSection extends StatefulWidget {
  const AuthSettingsSection({super.key});

  @override
  State<AuthSettingsSection> createState() => _AuthSettingsSectionState();
}

class _AuthSettingsSectionState extends State<AuthSettingsSection> {
  static const Map<AuthType, IconData> _typeIcons = <AuthType, IconData>{
    AuthType.none: Icons.lock_open_rounded,
    AuthType.bearer: Icons.key_rounded,
    AuthType.apiKey: Icons.vpn_key_rounded,
    AuthType.basic: Icons.person_rounded,
  };

  late final TextEditingController _tokenCtrl;
  late final TextEditingController _headerCtrl;
  late final TextEditingController _apiKeyCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _passCtrl;

  AuthType _type = AuthType.none;
  bool _obscureToken = true;
  bool _obscureApiKey = true;
  bool _obscurePass = true;
  bool _loaded = false;
  bool _saveAttempted = false;
  AuthConfig? _savedConfig;

  AuthConfig get _draft => AuthConfig(
        type: _type,
        token: _tokenCtrl.text,
        headerName: _headerCtrl.text.trim().isEmpty
            ? 'X-API-Key'
            : _headerCtrl.text.trim(),
        apiKey: _apiKeyCtrl.text,
        username: _userCtrl.text,
        password: _passCtrl.text,
      );

  @override
  void initState() {
    super.initState();
    _tokenCtrl = TextEditingController();
    _headerCtrl = TextEditingController(text: 'X-API-Key');
    _apiKeyCtrl = TextEditingController();
    _userCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _headerCtrl.dispose();
    _apiKeyCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cfg = AuthConfig.fromJson(await Prefs.getAuth());
    if (!mounted) return;
    setState(() {
      _type = cfg.type;
      _tokenCtrl.text = cfg.token;
      _headerCtrl.text = cfg.headerName;
      _apiKeyCtrl.text = cfg.apiKey;
      _userCtrl.text = cfg.username;
      _passCtrl.text = cfg.password;
      _savedConfig = cfg;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saveAttempted = true);
    final cfg = _draft;
    if (!cfg.isValid) return;
    await Prefs.setAuth(cfg.toJson());
    if (!mounted) return;
    setState(() => _savedConfig = cfg);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(cfg.isEnabled
                  ? '${cfg.type.label} authentication saved'
                  : 'Authentication disabled'),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onTypeSelected(AuthType type) {
    setState(() {
      _type = type;
      _saveAttempted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cfg = _draft;
    final l10n = AppLocalizations.of(context)!;
    final validationError = switch (cfg.validationError) {
      null => null,
      AuthValidationError.missingToken => l10n.authMissingToken,
      AuthValidationError.missingHeaderName => l10n.authMissingHeaderName,
      AuthValidationError.missingApiKey => l10n.authMissingApiKey,
      AuthValidationError.missingUsername => l10n.authMissingUsername,
      AuthValidationError.missingPassword => l10n.authMissingPassword,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HTTP Authentication',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'How the app should authenticate requests to the endpoint.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _AuthStatusChip(saved: _savedConfig),
          ],
        ),
        const SizedBox(height: 16),
        if (!_loaded)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AuthType>(
              segments: <ButtonSegment<AuthType>>[
                for (final type in AuthType.values)
                  ButtonSegment<AuthType>(
                    value: type,
                    label: Text(type.label),
                    icon: Icon(_typeIcons[type], size: 18),
                  ),
              ],
              selected: <AuthType>{_type},
              onSelectionChanged: (selection) =>
                  _onTypeSelected(selection.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  theme.textTheme.labelMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildFieldsFor(_type),
          ),
          if (_saveAttempted && validationError != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 20, color: colorScheme.onErrorContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      validationError,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: validationError == null ? _save : null,
            icon: Icon(
              validationError == null
                  ? Icons.shield_outlined
                  : Icons.error_outline_rounded,
            ),
            label: const Text('Save authentication'),
          ),
        ],
      ],
    );
  }

  Widget _buildFieldsFor(AuthType type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case AuthType.none:
        return Container(
          key: const ValueKey<AuthType>(AuthType.none),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_open_rounded,
                  color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Requests will be sent without authentication headers.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        );
      case AuthType.bearer:
        return Column(
          key: const ValueKey<AuthType>(AuthType.bearer),
          children: [
            TextField(
              controller: _tokenCtrl,
              obscureText: _obscureToken,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() => _saveAttempted = false),
              decoration: InputDecoration(
                labelText: 'Token',
                hintText: 'eyJhbGciOiJIUzI1NiIs...',
                prefixIcon: const Icon(Icons.key_rounded),
                helperText: 'The app will send: Authorization: Bearer <token>',
                suffixIcon: _VisibilityToggle(
                  obscure: _obscureToken,
                  onToggle: () =>
                      setState(() => _obscureToken = !_obscureToken),
                ),
              ),
            ),
          ],
        );
      case AuthType.apiKey:
        return Column(
          key: const ValueKey<AuthType>(AuthType.apiKey),
          children: [
            TextField(
              controller: _headerCtrl,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() => _saveAttempted = false),
              decoration: const InputDecoration(
                labelText: 'Header name',
                hintText: 'X-API-Key',
                prefixIcon: Icon(Icons.label_rounded),
                helperText: 'E.g.: X-API-Key, Authorization...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyCtrl,
              obscureText: _obscureApiKey,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() => _saveAttempted = false),
              decoration: InputDecoration(
                labelText: 'API key value',
                hintText: 'your_api_key',
                prefixIcon: const Icon(Icons.vpn_key_rounded),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscureApiKey,
                  onToggle: () =>
                      setState(() => _obscureApiKey = !_obscureApiKey),
                ),
              ),
            ),
          ],
        );
      case AuthType.basic:
        return Column(
          key: const ValueKey<AuthType>(AuthType.basic),
          children: [
            TextField(
              controller: _userCtrl,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() => _saveAttempted = false),
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'your_username',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() => _saveAttempted = false),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'your_password',
                prefixIcon: const Icon(Icons.lock_rounded),
                helperText: 'The app will send: Authorization: Basic <base64>',
                suffixIcon: _VisibilityToggle(
                  obscure: _obscurePass,
                  onToggle: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onToggle;

  const _VisibilityToggle({required this.obscure, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
      ),
      onPressed: onToggle,
      tooltip: obscure ? 'Show' : 'Hide',
    );
  }
}

class _AuthStatusChip extends StatelessWidget {
  final AuthConfig? saved;

  const _AuthStatusChip({required this.saved});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cfg = saved;
    final active = cfg?.isEnabled ?? false;
    final color = active ? Colors.green : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.verified_user_rounded : Icons.lock_open_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            active ? 'Active: ${cfg!.type.label}' : 'Inactive',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}