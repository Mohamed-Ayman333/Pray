import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class DaysRepository implements IDaysStorage {
  final IDaysStorage _localStorage;
  final IDaysStorage _onlineStorage;

  DaysRepository({
    required IDaysStorage localStorage,
    required IDaysStorage onlineStorage,
  }) : _localStorage = localStorage,
       _onlineStorage = onlineStorage;

  @override
  Future<void> save(Day day) async {
    // User modifications are stored locally only
    await _localStorage.save(day);
  }

  @override
  Future<Day?> load(DateTime date) async {
    try {
      // 1. Fetch fresh data from external API
      final remoteDay = await _onlineStorage.load(date);
      if (remoteDay != null) {
        // 2. Cache in local DB for offline access & rate-limit reduction
        await _localStorage.save(remoteDay);
        return remoteDay;
      }
    } catch (e) {
      // API call failed / No Internet -> Fallback to local cache
    }

    // 3. Return local version
    return await _localStorage.load(date);
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    try {
      // 1. Fetch batch range from external API
      final remoteDays = await _onlineStorage.getInRange(startDate, endDate);
      if (remoteDays.isNotEmpty) {
        // 2. Cache all fetched days locally
        for (final day in remoteDays) {
          await _localStorage.save(day);
        }
        return remoteDays;
      }
    } catch (e) {
      // API call failed / No Internet -> Fallback to local cache
    }

    // 3. Return cached range from local DB
    return await _localStorage.getInRange(startDate, endDate);
  }
}
