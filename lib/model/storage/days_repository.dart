import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class DaysRepository implements IDaysStorage {
  final IDaysStorage _localStorage;
  final IDaysStorage _cachingCalculatedStorage;

  DaysRepository({
    required IDaysStorage localStorage,
    required IDaysStorage cachingCalculatedStorage,
  }) : _localStorage = localStorage,
       _cachingCalculatedStorage = cachingCalculatedStorage;

  /// Returns true if [date] is today or any day in the past.
  bool _isPastOrToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    // If targetDate <= today, it's today or earlier
    return targetDate.isBefore(today) || targetDate.isAtSameMomentAs(today);
  }

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
    // 1. If it's today or a past day, prioritize local storage
    if (_isPastOrToday(date)) {
      final localDay = await _localStorage.load(date);
      if (localDay != null) {
        return localDay;
      }
    }

    // 2. Otherwise (future day, or local was missing), pull Calculated
    final calculatedDay = await _cachingCalculatedStorage.load(date);
    if (calculatedDay != null) {
      return calculatedDay;
    }

    // 3. Final fallback to local storage
    return await _localStorage.load(date);
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Normalize range inputs to midnight boundaries
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    // If the entire requested range is in the past or today
    if (end.isBefore(today) || end.isAtSameMomentAs(today)) {
      return await _localStorage.getInRange(start, end);
    }

    // If the entire requested range is in the future (starts tomorrow or later)
    final tomorrow = today.add(const Duration(days: 1));
    if (start.isAfter(today)) {
      return await _fetchFutureRange(start, end);
    }

    // --- RANGE STRADDLES TODAY/PAST AND FUTURE ---
    // Part 1: Past + Today (from Local)
    final localPartFuture = _localStorage.getInRange(start, today);

    // Part 2: Future Days (from Calculated, cached locally)
    final remotePartFuture = _fetchFutureRange(tomorrow, end);

    // Wait for both requests in parallel
    final results = await Future.wait([localPartFuture, remotePartFuture]);
    final localDays = results[0];
    final futureDays = results[1];

    // Combine and return results
    return [...localDays, ...futureDays];
  }

  /// Helper to safely load future dates from Calculated storage with local fallback
  Future<List<Day>> _fetchFutureRange(DateTime start, DateTime end) async {
    final calculatedDays = await _cachingCalculatedStorage.getInRange(
      start,
      end,
    );
    if (calculatedDays.isNotEmpty) {
      return calculatedDays;
    }
    return await _localStorage.getInRange(start, end);
  }
}
