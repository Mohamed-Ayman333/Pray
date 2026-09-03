import 'package:adhan/adhan.dart' hide Prayer;
import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/prayer.dart';

class CalculatedDaysStorage implements IDaysStorage {
  final double latitude;
  final double longitude;
  final CalculationMethod calculationMethod;
  final Madhab madhab;

  CalculatedDaysStorage({
    required this.latitude,
    required this.longitude,
    this.calculationMethod = CalculationMethod.egyptian,
    this.madhab = Madhab.shafi,
  });

  /// Computes the astronomical prayer times for [date] and maps them directly
  /// into your `Day` domain model containing `Prayer` instances.
  Day _calculateDay(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final coordinates = Coordinates(latitude, longitude);
    final dateComponents = DateComponents.from(normalizedDate);

    final params = calculationMethod.getParameters()..madhab = madhab;
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
    // Read-only generator; save operations are handled by LocalDaysStorage
  }

  @override
  Future<void> saveAll(List<Day> days) async {
    // Read-only generator; save operations are handled by LocalDaysStorage
  }
}
