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

  @override
  Future<Day?> load(DateTime date) async {
    final day = await _calculatedStorage.load(date);

    if (day != null) {
      await _localStorage.save(day);
    }

    return day;
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    final days = await _calculatedStorage.getInRange(startDate, endDate);

    if (days.isNotEmpty) {
      await _localStorage.saveAll(days);
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
