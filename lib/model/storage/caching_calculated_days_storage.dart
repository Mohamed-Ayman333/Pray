import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class CachingCalculatedDaysStorage implements IDaysStorage {
  final IDaysStorage _calculatedStorage;
  final IDaysStorage _localStorage;

  CachingCalculatedDaysStorage({
    required IDaysStorage calculatedStorage,
    required IDaysStorage localStorage,
  }) : _calculatedStorage = calculatedStorage,
       _localStorage = localStorage;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate.isAtSameMomentAs(today);
  }

  @override
  Future<Day?> load(DateTime date) async {
    final day = await _calculatedStorage.load(date);

    // Only cache to local storage if it's Today
    if (day != null && _isToday(date)) {
      await _localStorage.save(day);
    }

    return day;
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    final days = await _calculatedStorage.getInRange(startDate, endDate);

    // Save only Today if present in the range
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    for (final day in days) {
      if (day.date != null) {
        final dayNormalized = DateTime(
          day.date!.year,
          day.date!.month,
          day.date!.day,
        );
        if (dayNormalized.isAtSameMomentAs(todayNormalized)) {
          await _localStorage.save(day);
          break;
        }
      }
    }

    return days;
  }

  @override
  Future<void> save(Day day) async {
    await _localStorage.save(day);
  }

  @override
  Future<void> saveAll(List<Day> days) async {
    await _localStorage.saveAll(days);
  }
}
