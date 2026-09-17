import 'app_localizations.dart';

extension AppLocalizationsX on AppLocalizations {
  /// Maps the internal English prayer name (used across the DB and the
  /// adhan package) to its localized display name.
  String prayerDisplayName(String internalName) {
    switch (internalName.trim().toLowerCase()) {
      case 'fajr':
        return prayerFajr;
      case 'sunrise':
        return prayerSunrise;
      case 'dhuhr':
        return prayerDhuhr;
      case 'asr':
        return prayerAsr;
      case 'maghrib':
        return prayerMaghrib;
      case 'isha':
        return prayerIsha;
      default:
        return internalName;
    }
  }
}