import 'package:adhan/adhan.dart' hide Prayer;
import 'package:pray/controller/settings_controller.dart';
import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/prayer.dart';

class CalculatedDaysStorage implements IDaysStorage {
  final SettingsController _settingsController;

  CalculatedDaysStorage({required SettingsController settingsController})
    : _settingsController = settingsController;

  /// Computes the astronomical prayer times for [date] dynamically reading
  /// live settings (coordinates, calculation method, madhab) from SettingsController.
  Day _calculateDay(DateTime date) {
    final settings = _settingsController.currentSettings;

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final coordinates = Coordinates(settings.latitude, settings.longitude);
    final dateComponents = DateComponents.from(normalizedDate);

    final params = settings.calculationMethod.getParameters()
      ..madhab = settings.madhab;

    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    final List<Prayer> prayers = [
      Prayer(name: 'Fajr', time: prayerTimes.fajr, isDone: false),
      Prayer(name: 'Sunrise', time: prayerTimes.sunrise, isDone: false),
      Prayer(name: 'Dhuhr', time: prayerTimes.dhuhr, isDone: false),
      Prayer(name: 'Asr', time: prayerTimes.asr, isDone: false),
      Prayer(name: 'Maghrib', time: prayerTimes.maghrib, isDone: false),
      Prayer(name: 'Isha', time: prayerTimes.isha, isDone: false),
    ];

    return Day(date: normalizedDate, prayers: prayers);
  }

  @override
  Future<Day?> load(DateTime date) async {
    return _calculateDay(date);
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    final List<Day> days = [];

    var current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      days.add(_calculateDay(current));
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  @override
  Future<void> save(Day day) async {
    // Read-only generator; save operations are handled by DaysLocalStorage
  }

  @override
  Future<void> saveAll(List<Day> days) async {
    // Read-only generator; save operations are handled by DaysLocalStorage
  }
}
