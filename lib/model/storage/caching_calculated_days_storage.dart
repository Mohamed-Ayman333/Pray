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
    return await _calculatedStorage.load(date);
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    return await _calculatedStorage.getInRange(startDate, endDate);
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
