// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pray';

  @override
  String get comingNext => 'COMING NEXT';

  @override
  String get countdown => 'Countdown';

  @override
  String get dayView => 'Day View';

  @override
  String get thirtyDayView => '30-Day View';

  @override
  String get loadingTodaysPrayers => 'Loading Today\'s Prayers';

  @override
  String get columnPrayer => 'PRAYER';

  @override
  String get columnTime => 'TIME';

  @override
  String get columnStatus => 'STATUS';

  @override
  String get todayLabel => 'TODAY';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerHistory => 'Prayer History';

  @override
  String get missedPrayersQada => 'Missed Prayers (Qada)';

  @override
  String get missedPrayers => 'Missed Prayers';

  @override
  String get markDone => 'Mark Done';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get preferencesAndCalculation => 'Preferences & Prayer Calculation';

  @override
  String get calculationAndJurisprudence => 'Calculation & Jurisprudence';

  @override
  String get calculationMethod => 'Calculation Method';

  @override
  String get jurisprudenceSchool => 'Jurisprudence School';

  @override
  String get standardMadhab => 'Standard (Shafi, Hanbali, Maliki)';

  @override
  String get hanafiMadhab => 'Hanafi (Shadow 2x)';

  @override
  String get notificationsAndAlerts => 'Notifications & Alerts';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get notificationsSubtitle => 'Enable prayer alerts & reminders';

  @override
  String get stickyNotifications => 'Sticky Notifications';

  @override
  String get stickyNotificationsSubtitle =>
      'Keep the notification until the prayer is made done';

  @override
  String get repeatNotificationSound => 'Repeat Notification Sound';

  @override
  String get repeatNotificationSoundSubtitle =>
      'Loop the alert sound until you dismiss it';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get valuesAndAdjustments => 'Values & Adjustments';

  @override
  String get optionalPrayerCounterAutoIncrement =>
      'Optional Prayer Counter Daily Auto-Increment';

  @override
  String get appearanceAndTheme => 'Appearance & Theme';

  @override
  String get themeMode => 'THEME MODE';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get calculationMethodMuslimWorldLeague => 'Muslim World League';

  @override
  String get calculationMethodEgyptian => 'Egyptian General Authority';

  @override
  String get calculationMethodKarachi =>
      'University of Islamic Sciences, Karachi';

  @override
  String get calculationMethodUmmAlQura => 'Umm Al-Qura University, Makkah';

  @override
  String get calculationMethodDubai => 'Dubai';

  @override
  String get calculationMethodMoonsightingCommittee => 'Moonsighting Committee';

  @override
  String get calculationMethodNorthAmerica => 'ISNA (North America)';

  @override
  String get calculationMethodKuwait => 'Kuwait';

  @override
  String get calculationMethodQatar => 'Qatar';

  @override
  String get calculationMethodSingapore => 'Singapore';

  @override
  String get calculationMethodTehran => 'Institute of Geophysics, Tehran';

  @override
  String get calculationMethodTurkey => 'Diyanet İşleri Başkanlığı, Turkey';

  @override
  String get calculationMethodOther => 'Other / Custom';

  @override
  String get batteryPromptTitle => 'Keep reminders on time';

  @override
  String get batteryPromptMessage =>
      'Android sometimes delays or silences notifications when the app is in the background. To make sure you receive prayer reminders on time, allow this app to ignore battery optimizations.';

  @override
  String get batteryPromptLater => 'Later';

  @override
  String get batteryPromptAllow => 'Allow';

  @override
  String get sunnahBeforeHeader => 'Sunnah Before';

  @override
  String get sunnahAfterHeader => 'Sunnah After';

  @override
  String get prayerDhuha => 'Dhuha';

  @override
  String get sunnahDisplaySection => 'Sunnah Prayers';

  @override
  String get showSunnahPrayers => 'Show Sunnah Prayers';

  @override
  String get showSunnahPrayersSubtitle =>
      'Display sunnah prayers in the daily view';

  @override
  String get notifChannelName => 'Prayer Reminders';

  @override
  String get notifChannelDescription =>
      'Notifications for upcoming prayer times';

  @override
  String get notifMarkDone => 'Mark as Done';

  @override
  String notifTimeFor(String prayer) {
    return 'Time for $prayer';
  }

  @override
  String notifItIsTimeFor(String prayer) {
    return 'It is time for $prayer prayer.';
  }

  @override
  String get resetCounter => 'Reset counter';

  @override
  String get resetCounterDialogTitle => 'Reset counter?';

  @override
  String get resetCounterDialogMessage =>
      'This will set the optional prayer counter back to 0.';

  @override
  String get resetCounterDialogConfirm => 'Reset';

  @override
  String get resetCounterDialogCancel => 'Cancel';

  @override
  String get navPrayers => 'Prayers';

  @override
  String get navCalendar => 'Calendar';
}
