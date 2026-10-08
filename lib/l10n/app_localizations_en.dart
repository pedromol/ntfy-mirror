// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ntfy Mirror';

  @override
  String get splashSubtitle => 'Seamless Message Forwarding';

  @override
  String get initializing => 'Initializing...';

  @override
  String get serviceActive => 'Service Active';

  @override
  String get serviceInactive => 'Service Inactive';

  @override
  String get serviceActiveDesc => 'Messages are being monitored and forwarded';

  @override
  String get serviceInactiveDesc => 'Configure settings and start the service';

  @override
  String get destinationSettings => 'Destination Settings';

  @override
  String get endpointUrl => 'Endpoint URL';

  @override
  String get endpointHint => 'https://your-api.example.com/webhook';

  @override
  String get endpointHelper => 'HTTP endpoint to receive message data';

  @override
  String get saveConfiguration => 'Save Configuration';

  @override
  String get configurationSaved => 'Configuration Saved';

  @override
  String get editPayloadTemplate => 'Edit Payload Template';

  @override
  String get selectAppsToMonitor => 'Select Apps to Monitor';

  @override
  String get testConnectivityAuth => 'Test connectivity + authentication';

  @override
  String get testing => 'Testing…';

  @override
  String get waitingForEcho =>
      'Sending test notification — waiting for it to come back...';

  @override
  String get setEndpointFirst => 'Set Endpoint first';

  @override
  String get invalidUrl =>
      'Invalid URL. Use https://your-api.example.com/webhook';

  @override
  String get onlyHttpsAllowed =>
      'Only HTTPS is allowed (HTTP only for localhost).';

  @override
  String get httpAuth => 'HTTP Authentication';

  @override
  String get serviceControl => 'Service Control';

  @override
  String get checkingServiceStatus => 'Checking service status...';

  @override
  String get startMonitoringService => 'Start Monitoring Service';

  @override
  String get stopService => 'Stop Service';

  @override
  String get smsObserver => 'SMS Observer';

  @override
  String get smsObserverDesc =>
      'Monitor SMS messages in addition to notifications';

  @override
  String get permissions => 'Permissions';

  @override
  String get notificationAccess => 'Notification Access';

  @override
  String get notificationAccessDesc => 'Required to capture notifications';

  @override
  String get postNotifications => 'Post Notifications';

  @override
  String get postNotificationsDesc => 'Allow app to show status notifications';

  @override
  String get readSms => 'Read SMS';

  @override
  String get readSmsDesc => 'Optional: Monitor SMS messages';

  @override
  String get batteryOptimization => 'Battery Optimization';

  @override
  String get batteryOptimizationDesc =>
      'Prevent Android from stopping the service';

  @override
  String get unrestrictedData => 'Unrestricted Data';

  @override
  String get unrestrictedDataDesc => 'Allow background network access';

  @override
  String get refreshPermissions => 'Refresh Permissions';

  @override
  String get granted => 'Granted';

  @override
  String get optional => 'Optional';

  @override
  String get required => 'Required';

  @override
  String get settings => 'Settings';

  @override
  String get grant => 'Grant';

  @override
  String get about => 'About';

  @override
  String get openSourceProject => 'Open Source Project';

  @override
  String get starOnGithub => 'Star on GitHub';

  @override
  String get reportIssues => 'Report Issues';

  @override
  String get queue => 'Queue';

  @override
  String get logs => 'Logs';

  @override
  String get sendingTestWaiting =>
      'Sending test notification — waiting for it to come back...';

  @override
  String get httpAuthentication => 'HTTP Authentication';

  @override
  String get monitorSmsInAddition =>
      'Monitor SMS messages in addition to notifications';

  @override
  String get requiredToCaptureNotifications =>
      'Required to capture notifications';

  @override
  String get allowShowStatusNotifications =>
      'Allow app to show status notifications';

  @override
  String get optionalMonitorSms => 'Optional: Monitor SMS messages';

  @override
  String get preventAndroidStopping =>
      'Prevent Android from stopping the service';

  @override
  String get allowBackgroundNetwork => 'Allow background network access';

  @override
  String get configureStartService =>
      'Configure settings and start the service';

  @override
  String get messagesMonitored => 'Messages are being monitored and forwarded';

  @override
  String get validationSuccess =>
      'Validation OK — the test message was sent to the endpoint and received back.';

  @override
  String get validationSendFailed =>
      'Test message could not be sent to the endpoint.';

  @override
  String get validationTimeout =>
      'Test message sent, but it did not come back in time. Check Notification Access, the service, and selected apps.';

  @override
  String get validationNotConfirmed => 'Test message sent, but not confirmed.';

  @override
  String get validationAuthFailed =>
      'Authentication failed (HTTP 401/403) — check credentials in settings.';

  @override
  String get validationEndpointUnreachable =>
      'Endpoint rejected or unreachable — check the URL and network.';

  @override
  String get validationListenerNoAccess =>
      'Notification access is not granted — grant it so notifications can be captured.';

  @override
  String get validationListenerNotRunning =>
      'Notification access is granted but the listener is not running. Allow autostart and unrestricted battery (MIUI/HyperOS), then toggle Notification access off and on.';

  @override
  String get validationNotificationsDisabled =>
      'Notification permission is not granted — enable notifications for Ntfy Mirror.';

  @override
  String get validationTestNotificationFailed =>
      'Could not start the local test notification.';

  @override
  String validationTestNotificationFailedDetail(String detail) {
    return 'Could not start the local test notification ($detail).';
  }

  @override
  String get validationTestNotificationUnsupported =>
      'This build does not support local test notifications.';

  @override
  String get authMissingToken => 'Enter the access token.';

  @override
  String get authMissingHeaderName => 'Enter the header name.';

  @override
  String get authMissingApiKey => 'Enter the API key value.';

  @override
  String get authMissingUsername => 'Enter the username.';

  @override
  String get authMissingPassword => 'Enter the password.';

  @override
  String get useNtfyStyle => 'Use ntfy-style delivery';

  @override
  String get ntfyStyleEnabled => 'ntfy-style enabled';

  @override
  String get templateCannotBeEmpty =>
      'Template cannot be empty when ntfy-style is disabled';
}
