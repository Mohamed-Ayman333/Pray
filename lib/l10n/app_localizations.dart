import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pray'**
  String get appTitle;

  /// No description provided for @comingNext.
  ///
  /// In en, this message translates to:
  /// **'COMING NEXT'**
  String get comingNext;

  /// No description provided for @countdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdown;

  /// No description provided for @dayView.
  ///
  /// In en, this message translates to:
  /// **'Day View'**
  String get dayView;

  /// No description provided for @thirtyDayView.
  ///
  /// In en, this message translates to:
  /// **'30-Day View'**
  String get thirtyDayView;

  /// No description provided for @loadingTodaysPrayers.
  ///
  /// In en, this message translates to:
  /// **'Loading Today\'s Prayers'**
  String get loadingTodaysPrayers;

  /// No description provided for @columnPrayer.
  ///
  /// In en, this message translates to:
  /// **'PRAYER'**
  String get columnPrayer;

  /// No description provided for @columnTime.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get columnTime;

  /// No description provided for @columnStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get columnStatus;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayLabel;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @prayerHistory.
  ///
  /// In en, this message translates to:
  /// **'Prayer History'**
  String get prayerHistory;

  /// No description provided for @missedPrayersQada.
  ///
  /// In en, this message translates to:
  /// **'Missed Prayers (Qada)'**
  String get missedPrayersQada;

  /// No description provided for @missedPrayers.
  ///
  /// In en, this message translates to:
  /// **'Missed Prayers'**
  String get missedPrayers;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark Done'**
  String get markDone;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @preferencesAndCalculation.
  ///
  /// In en, this message translates to:
  /// **'Preferences & Prayer Calculation'**
  String get preferencesAndCalculation;

  /// No description provided for @calculationAndJurisprudence.
  ///
  /// In en, this message translates to:
  /// **'Calculation & Jurisprudence'**
  String get calculationAndJurisprudence;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// No description provided for @jurisprudenceSchool.
  ///
  /// In en, this message translates to:
  /// **'Jurisprudence School'**
  String get jurisprudenceSchool;

  /// No description provided for @standardMadhab.
  ///
  /// In en, this message translates to:
  /// **'Standard (Shafi, Hanbali, Maliki)'**
  String get standardMadhab;

  /// No description provided for @hanafiMadhab.
  ///
  /// In en, this message translates to:
  /// **'Hanafi (Shadow 2x)'**
  String get hanafiMadhab;

  /// No description provided for @notificationsAndAlerts.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Alerts'**
  String get notificationsAndAlerts;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable prayer alerts & reminders'**
  String get notificationsSubtitle;

  /// No description provided for @stickyNotifications.
  ///
  /// In en, this message translates to:
  /// **'Sticky Notifications'**
  String get stickyNotifications;

  /// No description provided for @stickyNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the notification until the prayer is made done'**
  String get stickyNotificationsSubtitle;

  /// No description provided for @repeatNotificationSound.
  ///
  /// In en, this message translates to:
  /// **'Repeat Notification Sound'**
  String get repeatNotificationSound;

  /// No description provided for @repeatNotificationSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Loop the alert sound until you dismiss it'**
  String get repeatNotificationSoundSubtitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @valuesAndAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Values & Adjustments'**
  String get valuesAndAdjustments;

  /// No description provided for @optionalPrayerCounterAutoIncrement.
  ///
  /// In en, this message translates to:
  /// **'Optional Prayer Counter Daily Auto-Increment'**
  String get optionalPrayerCounterAutoIncrement;

  /// No description provided for @appearanceAndTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Theme'**
  String get appearanceAndTheme;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'THEME MODE'**
  String get themeMode;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @calculationMethodMuslimWorldLeague.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get calculationMethodMuslimWorldLeague;

  /// No description provided for @calculationMethodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority'**
  String get calculationMethodEgyptian;

  /// No description provided for @calculationMethodKarachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get calculationMethodKarachi;

  /// No description provided for @calculationMethodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm Al-Qura University, Makkah'**
  String get calculationMethodUmmAlQura;

  /// No description provided for @calculationMethodDubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get calculationMethodDubai;

  /// No description provided for @calculationMethodMoonsightingCommittee.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee'**
  String get calculationMethodMoonsightingCommittee;

  /// No description provided for @calculationMethodNorthAmerica.
  ///
  /// In en, this message translates to:
  /// **'ISNA (North America)'**
  String get calculationMethodNorthAmerica;

  /// No description provided for @calculationMethodKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get calculationMethodKuwait;

  /// No description provided for @calculationMethodQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get calculationMethodQatar;

  /// No description provided for @calculationMethodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get calculationMethodSingapore;

  /// No description provided for @calculationMethodTehran.
  ///
  /// In en, this message translates to:
  /// **'Institute of Geophysics, Tehran'**
  String get calculationMethodTehran;

  /// No description provided for @calculationMethodTurkey.
  ///
  /// In en, this message translates to:
  /// **'Diyanet İşleri Başkanlığı, Turkey'**
  String get calculationMethodTurkey;

  /// No description provided for @calculationMethodOther.
  ///
  /// In en, this message translates to:
  /// **'Other / Custom'**
  String get calculationMethodOther;

  /// No description provided for @batteryPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep reminders on time'**
  String get batteryPromptTitle;

  /// No description provided for @batteryPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'Android sometimes delays or silences notifications when the app is in the background. To make sure you receive prayer reminders on time, allow this app to ignore battery optimizations.'**
  String get batteryPromptMessage;

  /// No description provided for @batteryPromptLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get batteryPromptLater;

  /// No description provided for @batteryPromptAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get batteryPromptAllow;

  /// No description provided for @sunnahDisplaySection.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Prayers'**
  String get sunnahDisplaySection;

  /// No description provided for @showSunnahPrayers.
  ///
  /// In en, this message translates to:
  /// **'Show Sunnah Prayers'**
  String get showSunnahPrayers;

  /// No description provided for @showSunnahPrayersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display sunnah prayers in the daily view'**
  String get showSunnahPrayersSubtitle;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications for upcoming prayer times'**
  String get notifChannelDescription;

  /// No description provided for @notifMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get notifMarkDone;

  /// No description provided for @notifTimeFor.
  ///
  /// In en, this message translates to:
  /// **'Time for {prayer}'**
  String notifTimeFor(String prayer);

  /// No description provided for @notifItIsTimeFor.
  ///
  /// In en, this message translates to:
  /// **'It is time for {prayer} prayer.'**
  String notifItIsTimeFor(String prayer);

  /// No description provided for @resetCounter.
  ///
  /// In en, this message translates to:
  /// **'Reset counter'**
  String get resetCounter;

  /// No description provided for @resetCounterDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset counter?'**
  String get resetCounterDialogTitle;

  /// No description provided for @resetCounterDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This will set the optional prayer counter back to 0.'**
  String get resetCounterDialogMessage;

  /// No description provided for @resetCounterDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetCounterDialogConfirm;

  /// No description provided for @resetCounterDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get resetCounterDialogCancel;

  /// No description provided for @navPrayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get navPrayers;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
