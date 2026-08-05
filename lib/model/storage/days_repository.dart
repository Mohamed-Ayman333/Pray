import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class DaysRepository implements IDaysStorage {
  final IDaysStorage _localStorage;
  final IDaysStorage _cachingOnlineStorage;

  DaysRepository({
    required IDaysStorage localStorage,
    required IDaysStorage cachingOnlineStorage,
  }) : _localStorage = localStorage,
       _cachingOnlineStorage = cachingOnlineStorage;

  @override
  Future<void> save(Day day) async {
    await _localStorage.save(day);
  }

  @override
  Future<void> saveAll(List<Day> days) async {
    await _localStorage.saveAll(days);
  }

  @override
  Future<Day?> load(DateTime date) async {
    //TODO: make it that if the day has pased get it from the local storag directly
    try {
      final remoteDay = await _cachingOnlineStorage.load(date);
      if (remoteDay != null) {
        return remoteDay;
      }
    } catch (e) {
      // Network failure, timeout, or no connection -> proceed to fallback
    }

    return await _localStorage.load(date);
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    //TODO: make it that if the day has pased get it from the local storag directly
    try {
      final remoteDays = await _cachingOnlineStorage.getInRange(
        startDate,
        endDate,
      );
      if (remoteDays.isNotEmpty) {
        return remoteDays;
      }
    } catch (e) {
      // Network failure -> proceed to fallback
    }

    return await _localStorage.getInRange(startDate, endDate);
  }
}
