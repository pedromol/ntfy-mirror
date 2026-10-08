import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ntfy Mirror'**
  String get appTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seamless Message Forwarding'**
  String get splashSubtitle;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @serviceActive.
  ///
  /// In en, this message translates to:
  /// **'Service Active'**
  String get serviceActive;

  /// No description provided for @serviceInactive.
  ///
  /// In en, this message translates to:
  /// **'Service Inactive'**
  String get serviceInactive;

  /// No description provided for @serviceActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Messages are being monitored and forwarded'**
  String get serviceActiveDesc;

  /// No description provided for @serviceInactiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure settings and start the service'**
  String get serviceInactiveDesc;

  /// No description provided for @destinationSettings.
  ///
  /// In en, this message translates to:
  /// **'Destination Settings'**
  String get destinationSettings;

  /// No description provided for @endpointUrl.
  ///
  /// In en, this message translates to:
  /// **'Endpoint URL'**
  String get endpointUrl;

  /// No description provided for @endpointHint.
  ///
  /// In en, this message translates to:
  /// **'https://your-api.example.com/webhook'**
  String get endpointHint;

  /// No description provided for @endpointHelper.
  ///
  /// In en, this message translates to:
  /// **'HTTP endpoint to receive message data'**
  String get endpointHelper;

  /// No description provided for @saveConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get saveConfiguration;

  /// No description provided for @configurationSaved.
  ///
  /// In en, this message translates to:
  /// **'Configuration Saved'**
  String get configurationSaved;

  /// No description provided for @editPayloadTemplate.
  ///
  /// In en, this message translates to:
  /// **'Edit Payload Template'**
  String get editPayloadTemplate;

  /// No description provided for @selectAppsToMonitor.
  ///
  /// In en, this message translates to:
  /// **'Select Apps to Monitor'**
  String get selectAppsToMonitor;

  /// No description provided for @testConnectivityAuth.
  ///
  /// In en, this message translates to:
  /// **'Test connectivity + authentication'**
  String get testConnectivityAuth;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get testing;

  /// No description provided for @waitingForEcho.
  ///
  /// In en, this message translates to:
  /// **'Sending test notification — waiting for it to come back...'**
  String get waitingForEcho;

  /// No description provided for @setEndpointFirst.
  ///
  /// In en, this message translates to:
  /// **'Set Endpoint first'**
  String get setEndpointFirst;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL. Use https://your-api.example.com/webhook'**
  String get invalidUrl;

  /// No description provided for @onlyHttpsAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only HTTPS is allowed (HTTP only for localhost).'**
  String get onlyHttpsAllowed;

  /// No description provided for @httpAuth.
  ///
  /// In en, this message translates to:
  /// **'HTTP Authentication'**
  String get httpAuth;

  /// No description provided for @serviceControl.
  ///
  /// In en, this message translates to:
  /// **'Service Control'**
  String get serviceControl;

  /// No description provided for @checkingServiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking service status...'**
  String get checkingServiceStatus;

  /// No description provided for @startMonitoringService.
  ///
  /// In en, this message translates to:
  /// **'Start Monitoring Service'**
  String get startMonitoringService;

  /// No description provided for @stopService.
  ///
  /// In en, this message translates to:
  /// **'Stop Service'**
  String get stopService;

  /// No description provided for @smsObserver.
  ///
  /// In en, this message translates to:
  /// **'SMS Observer'**
  String get smsObserver;

  /// No description provided for @smsObserverDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor SMS messages in addition to notifications'**
  String get smsObserverDesc;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @notificationAccess.
  ///
  /// In en, this message translates to:
  /// **'Notification Access'**
  String get notificationAccess;

  /// No description provided for @notificationAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Required to capture notifications'**
  String get notificationAccessDesc;

  /// No description provided for @postNotifications.
  ///
  /// In en, this message translates to:
  /// **'Post Notifications'**
  String get postNotifications;

  /// No description provided for @postNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow app to show status notifications'**
  String get postNotificationsDesc;

  /// No description provided for @readSms.
  ///
  /// In en, this message translates to:
  /// **'Read SMS'**
  String get readSms;

  /// No description provided for @readSmsDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional: Monitor SMS messages'**
  String get readSmsDesc;

  /// No description provided for @batteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Battery Optimization'**
  String get batteryOptimization;

  /// No description provided for @batteryOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Prevent Android from stopping the service'**
  String get batteryOptimizationDesc;

  /// No description provided for @unrestrictedData.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted Data'**
  String get unrestrictedData;

  /// No description provided for @unrestrictedDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow background network access'**
  String get unrestrictedDataDesc;

  /// No description provided for @refreshPermissions.
  ///
  /// In en, this message translates to:
  /// **'Refresh Permissions'**
  String get refreshPermissions;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @grant.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get grant;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @openSourceProject.
  ///
  /// In en, this message translates to:
  /// **'Open Source Project'**
  String get openSourceProject;

  /// No description provided for @starOnGithub.
  ///
  /// In en, this message translates to:
  /// **'Star on GitHub'**
  String get starOnGithub;

  /// No description provided for @reportIssues.
  ///
  /// In en, this message translates to:
  /// **'Report Issues'**
  String get reportIssues;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @sendingTestWaiting.
  ///
  /// In en, this message translates to:
  /// **'Sending test notification — waiting for it to come back...'**
  String get sendingTestWaiting;

  /// No description provided for @httpAuthentication.
  ///
  /// In en, this message translates to:
  /// **'HTTP Authentication'**
  String get httpAuthentication;

  /// No description provided for @monitorSmsInAddition.
  ///
  /// In en, this message translates to:
  /// **'Monitor SMS messages in addition to notifications'**
  String get monitorSmsInAddition;

  /// No description provided for @requiredToCaptureNotifications.
  ///
  /// In en, this message translates to:
  /// **'Required to capture notifications'**
  String get requiredToCaptureNotifications;

  /// No description provided for @allowShowStatusNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow app to show status notifications'**
  String get allowShowStatusNotifications;

  /// No description provided for @optionalMonitorSms.
  ///
  /// In en, this message translates to:
  /// **'Optional: Monitor SMS messages'**
  String get optionalMonitorSms;

  /// No description provided for @preventAndroidStopping.
  ///
  /// In en, this message translates to:
  /// **'Prevent Android from stopping the service'**
  String get preventAndroidStopping;

  /// No description provided for @allowBackgroundNetwork.
  ///
  /// In en, this message translates to:
  /// **'Allow background network access'**
  String get allowBackgroundNetwork;

  /// No description provided for @configureStartService.
  ///
  /// In en, this message translates to:
  /// **'Configure settings and start the service'**
  String get configureStartService;

  /// No description provided for @messagesMonitored.
  ///
  /// In en, this message translates to:
  /// **'Messages are being monitored and forwarded'**
  String get messagesMonitored;

  /// No description provided for @validationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Validation OK — the test message was sent to the endpoint and received back.'**
  String get validationSuccess;

  /// No description provided for @validationSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Test message could not be sent to the endpoint.'**
  String get validationSendFailed;

  /// No description provided for @validationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Test message sent, but it did not come back in time. Check Notification Access, the service, and selected apps.'**
  String get validationTimeout;

  /// No description provided for @validationNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Test message sent, but not confirmed.'**
  String get validationNotConfirmed;

  /// No description provided for @validationAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed (HTTP 401/403) — check credentials in settings.'**
  String get validationAuthFailed;

  /// No description provided for @validationEndpointUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Endpoint rejected or unreachable — check the URL and network.'**
  String get validationEndpointUnreachable;

  /// No description provided for @validationListenerNoAccess.
  ///
  /// In en, this message translates to:
  /// **'Notification access is not granted — grant it so notifications can be captured.'**
  String get validationListenerNoAccess;

  /// No description provided for @validationListenerNotRunning.
  ///
  /// In en, this message translates to:
  /// **'Notification access is granted but the listener is not running. Allow autostart and unrestricted battery (MIUI/HyperOS), then toggle Notification access off and on.'**
  String get validationListenerNotRunning;

  /// No description provided for @validationNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is not granted — enable notifications for Ntfy Mirror.'**
  String get validationNotificationsDisabled;

  /// No description provided for @validationTestNotificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the local test notification.'**
  String get validationTestNotificationFailed;

  /// No description provided for @validationTestNotificationFailedDetail.
  ///
  /// In en, this message translates to:
  /// **'Could not start the local test notification ({detail}).'**
  String validationTestNotificationFailedDetail(String detail);

  /// No description provided for @validationTestNotificationUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This build does not support local test notifications.'**
  String get validationTestNotificationUnsupported;

  /// No description provided for @authMissingToken.
  ///
  /// In en, this message translates to:
  /// **'Enter the access token.'**
  String get authMissingToken;

  /// No description provided for @authMissingHeaderName.
  ///
  /// In en, this message translates to:
  /// **'Enter the header name.'**
  String get authMissingHeaderName;

  /// No description provided for @authMissingApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter the API key value.'**
  String get authMissingApiKey;

  /// No description provided for @authMissingUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter the username.'**
  String get authMissingUsername;

  /// No description provided for @authMissingPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the password.'**
  String get authMissingPassword;

  /// No description provided for @useNtfyStyle.
  ///
  /// In en, this message translates to:
  /// **'Use ntfy-style delivery'**
  String get useNtfyStyle;

  /// No description provided for @ntfyStyleEnabled.
  ///
  /// In en, this message translates to:
  /// **'ntfy-style enabled'**
  String get ntfyStyleEnabled;

  /// No description provided for @templateCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Template cannot be empty when ntfy-style is disabled'**
  String get templateCannotBeEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
