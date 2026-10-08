import 'package:flutter/material.dart';
import 'package:ntfy_mirror/l10n/app_localizations.dart';
import 'package:ntfy_mirror/message_stream.dart';
import 'package:ntfy_mirror/platform_controls.dart';
import 'package:ntfy_mirror/prefs.dart';
import 'package:ntfy_mirror/permissions.dart';
import 'package:ntfy_mirror/logger.dart';
import 'package:ntfy_mirror/app_selector.dart';
import 'package:ntfy_mirror/payload_template_screen.dart';
import 'dart:async';
import 'package:ntfy_mirror/logs_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ntfy_mirror/auth_settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await Prefs.getThemeMode();
    setState(() {
      switch (mode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ntfy Mirror',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: _themeMode,
      theme: _createTheme(Brightness.light),
      darkTheme: _createTheme(Brightness.dark),
      home: const SplashScreen(),
    );
  }

  ThemeData _createTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6B73FF),
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      typography: Typography.material2021(),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _githubFadeAnimation;
  late Animation<Offset> _githubSlideAnimation;
  late Animation<double> _versionFadeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  String version = '';

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Staggered animations for smooth sequential appearance
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _logoSlideAnimation = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _subtitleSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _githubFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    _githubSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _versionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _loadVersionAndNavigate();
  }

  Future<void> _loadVersionAndNavigate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        version = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      setState(() {
        version = 'v1.0.2+3';
      });
    }

    // Start animations
    _mainController.forward();
    _rotationController.repeat();

    await Future.delayed(const Duration(milliseconds: 800));
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ConfigScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _rotationController,
          _progressController
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Background gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.1),
                      colorScheme.surface,
                    ],
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    SlideTransition(
                      position: _logoSlideAnimation,
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Rotating outer ring
                            RotationTransition(
                              turns: _rotationAnimation,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            // Main logo container
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primary.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.sync_alt_rounded,
                                size: 48,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Animated Title
                    SlideTransition(
                      position: _titleSlideAnimation,
                      child: FadeTransition(
                        opacity: _titleFadeAnimation,
                        child: Text(
                          AppLocalizations.of(context)!.appTitle,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Animated Subtitle
                    SlideTransition(
                      position: _subtitleSlideAnimation,
                      child: FadeTransition(
                        opacity: _subtitleFadeAnimation,
                        child: Text(
                          AppLocalizations.of(context)!.splashSubtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 64),

                    // Animated GitHub Link
                    SlideTransition(
                      position: _githubSlideAnimation,
                      child: FadeTransition(
                        opacity: _githubFadeAnimation,
                        child: GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse('https://github.com/pedromol/ntfy-mirror');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.code_rounded,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'pedromol/ntfy-mirror',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Animated Version
                    FadeTransition(
                      opacity: _versionFadeAnimation,
                      child: version.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                version,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              // Progress indicator at bottom
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _progressAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: size.width * 0.6,
                        height: 3,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: (size.width * 0.6) * _progressAnimation.value,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary,
                                      colorScheme.primary.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.initializing,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController endpointCtrl = TextEditingController();
  bool smsEnabled = true;
  bool hasNotifAccess = false;
  bool hasPostNotif = false;
  bool hasReadSms = false;
  bool ignoringBattery = false;
  bool serviceRunning = false;
  bool checkingService = true;
  MessageStream? stream;
  String _lastSavedEndpoint = '';
  bool _validating = false;
  ValidationReport? _validation;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    MessageStream.wireValidationResultChannel();
  }

  @override
  void reassemble() {
    super.reassemble();
    _recheckService();
  }

  Future<void> _loadPrefs() async {
    smsEnabled = await Prefs.getSmsEnabled();
    serviceRunning = await PlatformControls.isServiceRunning();
    await _refreshPerms();
    if (!mounted) return;
    setState(() {
      checkingService = false;
    });
    final ep = await Prefs.getEndpoint();
    if (!mounted) return;
    setState(() {
      endpointCtrl.text = ep;
      _lastSavedEndpoint = ep;
    });
  }

  Future<void> _recheckService() async {
    setState(() { checkingService = true; });
    final running = await PlatformControls.isServiceRunning();
    if (!mounted) return;
    setState(() {
      serviceRunning = running;
      checkingService = false;
    });
  }

  Future<void> _setSmsEnabled(bool v) async {
    setState(() { smsEnabled = v; });
    await Prefs.setSmsEnabled(v);
    await Logger.d('SMS enabled set to $v');
  }

  Future<void> _refreshPerms() async {
    hasNotifAccess = await PermissionService.hasNotificationAccess();
    hasPostNotif = await PermissionService.hasPostNotifications();
    hasReadSms = await PermissionService.hasReadSms();
    ignoringBattery = await PermissionService.isIgnoringBatteryOptimizations();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    endpointCtrl.dispose();
    super.dispose();
  }

  bool get _destinationDirty =>
      endpointCtrl.text.trim() != _lastSavedEndpoint.trim();

  void _saveDestination() async {
    final endpoint = endpointCtrl.text.trim();
    if (endpoint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.setEndpointFirst)));
      return;
    }
    final error = _validateEndpoint(endpoint);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Prefs.setEndpoint(endpoint);
    final s = MessageStream(reception: '', endpoint: endpoint);
    await s.start();
    Logger.d('Destination saved: endpoint=${_sanitizeEndpoint(endpoint)}');
    setState(() {
      stream = s;
      _lastSavedEndpoint = endpoint;
    });
  }

  static String? _validateEndpoint(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.host.isEmpty) {
      return 'Invalid URL. Use https://your-api.example.com/webhook';
    }
    if (uri.scheme == 'https') return null;
    if (uri.scheme == 'http' && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
      return null;
    }
    return 'Only HTTPS is allowed (HTTP only for localhost).';
  }

  static String _sanitizeEndpoint(String raw) {
    try {
      final u = Uri.parse(raw);
      if (u.userInfo.isEmpty) return raw;
      return u.replace(userInfo: '').toString();
    } catch (_) {
      return raw;
    }
  }

  Future<void> _runValidation() async {
    final endpoint = endpointCtrl.text.trim();
    if (endpoint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.setEndpointFirst)));
      return;
    }
    final error = _validateEndpoint(endpoint);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() {
      _validating = true;
      _validation = null;
    });
    final s = MessageStream(reception: '', endpoint: endpoint);
    await s.start();
    final report = await s.runValidation(timeout: const Duration(seconds: 90));
    s.dispose();
    if (!mounted) return;
    setState(() {
      _validating = false;
      _validation = report;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.sync_alt,
                color: colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Ntfy Mirror',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.queue,
            icon: Icon(Icons.cloud_upload_outlined, color: colorScheme.onSurfaceVariant),
            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const QueueScreen())); },
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.logs,
            icon: Icon(Icons.article_outlined, color: colorScheme.onSurfaceVariant),
            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const LogsScreen())); },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.primaryContainer.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    serviceRunning ? Icons.check_circle_rounded : Icons.pending_rounded,
                    size: 48,
                    color: serviceRunning ? Colors.green : colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    serviceRunning ? AppLocalizations.of(context)!.serviceActive : AppLocalizations.of(context)!.serviceInactive,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    serviceRunning
                        ? AppLocalizations.of(context)!.messagesMonitored
                        : AppLocalizations.of(context)!.configureStartService,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _ModernCard(
              title: AppLocalizations.of(context)!.destinationSettings,
              icon: Icons.settings_ethernet_rounded,
              child: Column(
                children: [
                  TextField(
                    controller: endpointCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.endpointUrl,
                      hintText: AppLocalizations.of(context)!.endpointHint,
                      prefixIcon: Icon(Icons.link_rounded),
                      helperText: AppLocalizations.of(context)!.endpointHelper,
                    ),
                    onChanged: (_) { setState(() {}); },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: (endpointCtrl.text.trim().isEmpty || !_destinationDirty)
                        ? null
                        : _saveDestination,
                    icon: Icon(_destinationDirty ? Icons.save_rounded : Icons.check_rounded),
                    label: Text(_destinationDirty ? AppLocalizations.of(context)!.saveConfiguration : AppLocalizations.of(context)!.configurationSaved),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const PayloadTemplateScreen())); },
                    icon: const Icon(Icons.data_object_rounded),
                    label: Text(AppLocalizations.of(context)!.editPayloadTemplate),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSelectorScreen())); },
                    icon: const Icon(Icons.apps_rounded),
                    label: Text(AppLocalizations.of(context)!.selectAppsToMonitor),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.tonalIcon(
                    onPressed: (endpointCtrl.text.trim().isEmpty || _validating)
                        ? null
                        : _runValidation,
                    icon: _validating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fact_check_outlined),
                    label: Text(_validating ? AppLocalizations.of(context)!.testing : AppLocalizations.of(context)!.testConnectivityAuth),
                  ),
                  if (_validating)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sync_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.sendingTestWaiting,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_validation != null && !_validating) ...[
                    const SizedBox(height: 12),
                    _ValidationResultCard(report: _validation!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            _ModernCard(
              title: AppLocalizations.of(context)!.httpAuthentication,
              icon: Icons.security_rounded,
              child: const AuthSettingsSection(),
            ),

            const SizedBox(height: 20),

            _ModernCard(
              title: AppLocalizations.of(context)!.serviceControl,
              icon: Icons.power_settings_new_rounded,
              child: Column(
                children: [
                  if (checkingService)
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.checkingServiceStatus,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!serviceRunning)
                    FilledButton.icon(
                      onPressed: (endpointCtrl.text.trim().isEmpty)
                          ? null
                          : () async {
                              setState(() { checkingService = true; });
                              await PlatformControls.startService();
                              await Future.delayed(const Duration(milliseconds: 600));
                              final running = await PlatformControls.isServiceRunning();
                              if (!mounted) return;
                              setState(() {
                                serviceRunning = running;
                                checkingService = false;
                              });
                            },
                      icon: const Icon(Icons.play_circle_filled_rounded),
                      label: Text(AppLocalizations.of(context)!.startMonitoringService),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () async {
                        setState(() { checkingService = true; });
                        await PlatformControls.stopService();
                        bool running = true;
                        for (int i = 0; i < 5; i++) {
                          await Future.delayed(const Duration(milliseconds: 300));
                          running = await PlatformControls.isServiceRunning();
                          if (!running) break;
                        }
                        if (!mounted) return;
                        setState(() {
                          serviceRunning = running;
                          checkingService = false;
                        });
                      },
                      icon: const Icon(Icons.stop_circle_rounded),
                      label: Text(AppLocalizations.of(context)!.stopService),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sms_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.smsObserver,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.monitorSmsInAddition,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: smsEnabled,
                          onChanged: _setSmsEnabled,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

              _ModernCard(
                title: 'Appearance',
                icon: Icons.palette_rounded,
                child: const _ThemeModeSelector(),
              ),

              const SizedBox(height: 20),

              _ModernCard(
                title: AppLocalizations.of(context)!.permissions,
                icon: Icons.security_rounded,
                child: Column(
                  children: [
                    _ModernPermissionRow(
                      ok: hasNotifAccess,
                      title: AppLocalizations.of(context)!.notificationAccess,
                      subtitle: AppLocalizations.of(context)!.requiredToCaptureNotifications,
                      icon: Icons.notifications_rounded,
                      action: () { PermissionService.openNotificationAccess(); },
                    ),
                    const SizedBox(height: 16),
                    _ModernPermissionRow(
                      ok: hasPostNotif,
                      title: AppLocalizations.of(context)!.postNotifications,
                      subtitle: AppLocalizations.of(context)!.allowShowStatusNotifications,
                      icon: Icons.notification_add_rounded,
                      action: () async {
                        await PermissionService.requestPostNotifications();
                        await _refreshPerms();
                      },
                    ),
                    const SizedBox(height: 16),
                    _ModernPermissionRow(
                      ok: hasReadSms,
                      title: AppLocalizations.of(context)!.readSms,
                      subtitle: AppLocalizations.of(context)!.optionalMonitorSms,
                      icon: Icons.sms_rounded,
                      isOptional: true,
                      action: () async {
                        await PermissionService.requestReadSms();
                        await _refreshPerms();
                      },
                    ),
                    const SizedBox(height: 16),
                    _ModernPermissionRow(
                      ok: ignoringBattery,
                      title: AppLocalizations.of(context)!.batteryOptimization,
                      subtitle: AppLocalizations.of(context)!.preventAndroidStopping,
                      icon: Icons.battery_saver_rounded,
                      action: () { PermissionService.openBatterySettings(); },
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<int>(
                      future: PermissionService.getDataSaverStatus(),
                      builder: (context, snapshot) {
                        final st = snapshot.data ?? 1;
                        final ok = st == 1 || st == 2;
                        return _ModernPermissionRow(
                          ok: ok,
                          title: AppLocalizations.of(context)!.unrestrictedData,
                          subtitle: AppLocalizations.of(context)!.allowBackgroundNetwork,
                          icon: Icons.data_usage_rounded,
                          action: () { PermissionService.openDataSaverSettings(); },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _refreshPerms,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(AppLocalizations.of(context)!.refreshPermissions),
                    ),
                  ],
                ),
              ),



            const SizedBox(height: 20),

            Container(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ModernCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ModernCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

/// Localized summary for a validation run. [ValidationReport] only carries
/// codes; the English text lives in the `.arb` files.
String _validationMessage(ValidationReport report, AppLocalizations l10n) {
  if (report.success) return l10n.validationSuccess;
  if (report.timedOut) return l10n.validationTimeout;
  final failure = report.failure;
  if (failure == null) {
    return report.httpOk ? l10n.validationNotConfirmed : l10n.validationSendFailed;
  }
  switch (failure) {
    case ValidationFailure.authFailure:
      return l10n.validationAuthFailed;
    case ValidationFailure.endpointUnreachable:
      return l10n.validationEndpointUnreachable;
    case ValidationFailure.listenerNoAccess:
      return l10n.validationListenerNoAccess;
    case ValidationFailure.listenerNotRunning:
      return l10n.validationListenerNotRunning;
    case ValidationFailure.notificationsDisabled:
      return l10n.validationNotificationsDisabled;
    case ValidationFailure.testNotificationUnsupported:
      return l10n.validationTestNotificationUnsupported;
    case ValidationFailure.testNotificationFailed:
      final detail = report.errorDetail;
      return detail == null
          ? l10n.validationTestNotificationFailed
          : l10n.validationTestNotificationFailedDetail(detail);
  }
}

class _ValidationResultCard extends StatelessWidget {
  final ValidationReport report;

  const _ValidationResultCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ok = report.success;
    final color = ok ? Colors.green : colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ok
            ? Colors.green.withValues(alpha: 0.12)
            : colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _validationMessage(report, AppLocalizations.of(context)!),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ok ? Colors.green.shade900 : colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernPermissionRow extends StatelessWidget {
  final bool ok;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isOptional;
  final VoidCallback action;

  const _ModernPermissionRow({
    required this.ok,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isOptional = false,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (ok) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_rounded;
      statusText = AppLocalizations.of(context)!.granted;
    } else if (isOptional) {
      statusColor = colorScheme.onSurfaceVariant;
      statusIcon = Icons.info_outline_rounded;
      statusText = AppLocalizations.of(context)!.optional;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_rounded;
      statusText = AppLocalizations.of(context)!.required;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ok
            ? Colors.green.withValues(alpha: 0.1)
            : (isOptional
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : Colors.orange.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ok
              ? Colors.green.withValues(alpha: 0.3)
              : (isOptional
                  ? colorScheme.outline.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: action,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  ok ? AppLocalizations.of(context)!.settings : AppLocalizations.of(context)!.grant,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatefulWidget {
  const _ThemeModeSelector({super.key});

  @override
  State<_ThemeModeSelector> createState() => _ThemeModeSelectorState();
}

class _ThemeModeSelectorState extends State<_ThemeModeSelector> {
  String _currentMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final mode = await Prefs.getThemeMode();
    setState(() {
      _currentMode = mode;
    });
  }

  Future<void> _setMode(String mode) async {
    setState(() {
      _currentMode = mode;
    });
    await Prefs.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        _ModeOption(
          label: 'System Default',
          value: 'system',
          isSelected: _currentMode == 'system',
          onSelect: _setMode,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 8),
        _ModeOption(
          label: 'Light Mode',
          value: 'light',
          isSelected: _currentMode == 'light',
          onSelect: _setMode,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 8),
        _ModeOption(
          label: 'Dark Mode',
          value: 'dark',
          isSelected: _currentMode == 'dark',
          onSelect: _setMode,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _ModeOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final Function(String) onSelect;
  final ColorScheme colorScheme;

  const _ModeOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onSelect,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GitHubInfoCard extends StatefulWidget {
  const _GitHubInfoCard({super.key});

  @override
  State<_GitHubInfoCard> createState() => _GitHubInfoCardState();
}

class _GitHubInfoCardState extends State<_GitHubInfoCard> {
  String version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        version = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      setState(() {
        version = 'v1.0.2+3';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _ModernCard(
      title: AppLocalizations.of(context)!.about,
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.3),
                  colorScheme.primaryContainer.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.sync_alt,
                        color: colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.appTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (version.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              version,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.code_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.openSourceProject,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse('https://github.com/pedromol/ntfy-mirror');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
}


                              },
                              child: Text(
                                'github.com/pedromol/ntfy-mirror',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse('https://github.com/pedromol/ntfy-mirror');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_outline_rounded,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.starOnGithub,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse('https://github.com/pedromol/ntfy-mirror/issues');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bug_report_outlined,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.reportIssues,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@pragma('vm:entry-point')
void backgroundMain() {
  WidgetsFlutterBinding.ensureInitialized();
  _bootstrapBackground();
}

Future<void> _bootstrapBackground() async {
  final reception = await Prefs.getReception();
  final endpoint = await Prefs.getEndpoint();
  await Logger.d('Background(main.dart) bootstrap: reception=${reception.isEmpty ? 'EMPTY' : 'SET'}, endpoint=${endpoint.isEmpty ? 'DEFAULT' : 'SET'}');
  final stream = MessageStream(
    reception: reception,
    endpoint: endpoint.isEmpty ? null : endpoint,
  );
  await stream.start();
  await Logger.d('Background(main.dart) stream started');
}