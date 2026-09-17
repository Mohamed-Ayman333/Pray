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

  DateTime _toNormalizedUtc(DateTime date) {
    final local = date.toLocal();
    return DateTime.utc(local.year, local.month, local.day);
  }

  bool _isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final targetDate = _toNormalizedUtc(date);
    return targetDate.isBefore(today);
  }

  /// Central logic for toggling prayer completion state and persisting locally
  Future<void> togglePrayer(DateTime date, String prayerName) async {
    final normalizedDate = _toNormalizedUtc(date);

    // Load existing day or fall back to calculation
    var day = await load(normalizedDate);

    if (day != null) {
      day.date = normalizedDate;
      final prayerIndex = day.prayers.indexWhere(
        (p) => p.name.trim().toLowerCase() == prayerName.trim().toLowerCase(),
      );

      if (prayerIndex != -1) {
        day.prayers[prayerIndex].isDone = !day.prayers[prayerIndex].isDone;
        await save(day);
      }
    }
  }

  @override
  Future<void> save(Day day) async {
    if (day.date != null) {
      day.date = _toNormalizedUtc(day.date!);
    }
    await _localStorage.save(day);
  }

  @override
  Future<void> saveAll(List<Day> days) async {
    for (final d in days) {
      if (d.date != null) {
        d.date = _toNormalizedUtc(d.date!);
      }
    }
    await _localStorage.saveAll(days);
  }

  @override
  Future<Day?> load(DateTime date) async {
    final normalizedDate = _toNormalizedUtc(date);

    // 1. Past: Local ONLY
    if (_isPast(normalizedDate)) {
      return await _localStorage.load(normalizedDate);
    }

    // 2. Today & Future: Dynamic Calculation + Preserve User Progress
    final localDay = await _localStorage.load(normalizedDate);
    final calculatedDay = await _cachingCalculatedStorage.load(normalizedDate);

    if (calculatedDay == null) return localDay;

    calculatedDay.date = normalizedDate;

    if (localDay != null) {
      calculatedDay.id = localDay.id;
      for (final calcPrayer in calculatedDay.prayers) {
        final existingIndex = localDay.prayers.indexWhere(
          (p) =>
              p.name.trim().toLowerCase() ==
              calcPrayer.name.trim().toLowerCase(),
        );
        if (existingIndex != -1) {
          calcPrayer.isDone = localDay.prayers[existingIndex].isDone;
        }
      }
    }

    return calculatedDay;
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final start = _toNormalizedUtc(startDate);
    final end = _toNormalizedUtc(endDate);

    if (end.isBefore(today)) {
      return await _localStorage.getInRange(start, end);
    }

    if (start.isAtSameMomentAs(today) && end.isAtSameMomentAs(today)) {
      return await _fetchTodayRange(today);
    }

    if (start.isAfter(today)) {
      final List<Day> futureDays = [];
      var current = start;
      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        final loaded = await load(current);
        if (loaded != null) futureDays.add(loaded);
        current = current.add(const Duration(days: 1));
      }
      return futureDays;
    }

    final List<Future<List<Day>>> requests = [];

    if (start.isBefore(today)) {
      final pastEnd = end.isBefore(today) ? end : yesterday;
      requests.add(_localStorage.getInRange(start, pastEnd));
    }

    if (!start.isAfter(today) && !end.isBefore(today)) {
      requests.add(_fetchTodayRange(today));
    }

    if (end.isAfter(today)) {
      final futureStart = start.isAfter(today) ? start : tomorrow;
      requests.add(_fetchFutureRange(futureStart, end));
    }

    final results = await Future.wait(requests);
    return results.expand((list) => list).toList();
  }

  Future<List<Day>> _fetchTodayRange(DateTime today) async {
    final day = await load(today);
    return day != null ? [day] : [];
  }

  Future<List<Day>> _fetchFutureRange(DateTime start, DateTime end) async {
    final List<Day> futureDays = [];
    var current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final loaded = await load(current);
      if (loaded != null) futureDays.add(loaded);
      current = current.add(const Duration(days: 1));
    }
    return futureDays;
  }
}
