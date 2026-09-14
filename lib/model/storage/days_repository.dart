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

  bool _isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate.isBefore(today);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate.isAtSameMomentAs(today);
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
    // 1. Past: Local ONLY
    if (_isPast(date)) {
      return await _localStorage.load(date);
    }

    // 2. Today: Dynamic Calculation + Preserve User Progress
    if (_isToday(date)) {
      final localDay = await _localStorage.load(date);
      final calculatedDay = await _cachingCalculatedStorage.load(date);

      if (localDay == null) return calculatedDay;
      if (calculatedDay == null) return localDay;

      // Preserve completion state (`isDone`) while taking new calculated prayer times
      for (final calcPrayer in calculatedDay.prayers) {
        final existing = localDay.prayers.firstWhere(
          (p) => p.name.toLowerCase() == calcPrayer.name.toLowerCase(),
          orElse: () => calcPrayer,
        );
        calcPrayer.isDone = existing.isDone;
      }

      return calculatedDay;
    }

    // 3. Future: Pure Calculation (No local persistence)
    return await _cachingCalculatedStorage.load(date);
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    // Scenario A: Entirely Past -> Local ONLY
    if (end.isBefore(today)) {
      return await _localStorage.getInRange(start, end);
    }

    // Scenario B: Entirely Today
    if (start.isAtSameMomentAs(today) && end.isAtSameMomentAs(today)) {
      return await _fetchTodayRange(today);
    }

    // Scenario C: Entirely Future -> Direct Calculation
    if (start.isAfter(today)) {
      return await _cachingCalculatedStorage.getInRange(start, end);
    }

    // Scenario D: Multi-day range spanning across Past / Today / Future
    final List<Future<List<Day>>> requests = [];

    // Part 1: Past portion -> Local ONLY
    if (start.isBefore(today)) {
      final pastEnd = end.isBefore(today) ? end : yesterday;
      requests.add(_localStorage.getInRange(start, pastEnd));
    }

    // Part 2: Today portion -> Local FIRST -> Calculated fallback
    if (!start.isAfter(today) && !end.isBefore(today)) {
      requests.add(_fetchTodayRange(today));
    }

    // Part 3: Future portion -> Calculated ONLY
    if (end.isAfter(today)) {
      final futureStart = start.isAfter(today) ? start : tomorrow;
      requests.add(_cachingCalculatedStorage.getInRange(futureStart, end));
    }

    final results = await Future.wait(requests);
    return results.expand((list) => list).toList();
  }

  Future<List<Day>> _fetchTodayRange(DateTime today) async {
    final day = await load(today);
    return day != null ? [day] : [];
  }
}
