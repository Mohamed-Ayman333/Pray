import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class CachingOnlineDaysStorage implements IDaysStorage {
  final IDaysStorage _onlineStorage;
  final IDaysStorage _localStorage;

  CachingOnlineDaysStorage({
    required IDaysStorage onlineStorage,
    required IDaysStorage localStorage,
  }) : _onlineStorage = onlineStorage,
       _localStorage = localStorage;

  @override
  Future<Day?> load(DateTime date) async {
    final day = await _onlineStorage.load(date);

    if (day != null) {
      await _localStorage.save(day);
    }

    return day;
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    final days = await _onlineStorage.getInRange(startDate, endDate);

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
