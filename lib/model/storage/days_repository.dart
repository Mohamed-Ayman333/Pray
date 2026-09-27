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
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    // 1. Past: local first, then backfill from the calculation cache.
    if (_isPast(normalizedDate)) {
      final localDay = await _localStorage.load(normalizedDate);
      if (localDay != null) return localDay;

      // Day was computed but never committed. Persist it now so it has a
      // real all-pending record instead of appearing as "fully completed".
      final cachedDay = await _cachingCalculatedStorage.load(normalizedDate);
      if (cachedDay != null) {
        cachedDay.date = normalizedDate;
        await _localStorage.save(cachedDay);
      }
      return cachedDay;
    }

    // 2. Today & Future: dynamic calculation + preserve user progress.
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
    } else if (normalizedDate.isAtSameMomentAs(today)) {
      // First computation of today: commit immediately so that when the
      // day rolls over it has a proper local record (all prayers pending),
      // rather than looking falsely completed.
      await _localStorage.save(calculatedDay);
    }

    return calculatedDay;
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final start = _toNormalizedUtc(startDate);
    final end = _toNormalizedUtc(endDate);

    if (end.isBefore(today)) {
      return _loadDayByDay(start, end);
    }

    if (start.isAtSameMomentAs(today) && end.isAtSameMomentAs(today)) {
      return _loadDayByDay(today, today);
    }

    if (start.isAfter(today)) {
      return _loadDayByDay(start, end);
    }

    final List<Future<List<Day>>> requests = [];

    if (start.isBefore(today)) {
      final pastEnd = end.isBefore(today)
          ? end
          : today.subtract(const Duration(days: 1));
      requests.add(_loadDayByDay(start, pastEnd));
    }

    if (!start.isAfter(today) && !end.isBefore(today)) {
      requests.add(_loadDayByDay(today, today));
    }

    if (end.isAfter(today)) {
      final futureStart = start.isAfter(today) ? start : tomorrow;
      requests.add(_loadDayByDay(futureStart, end));
    }

    final results = await Future.wait(requests);
    return results.expand((list) => list).toList();
  }

  Future<List<Day>> _loadDayByDay(DateTime start, DateTime end) async {
    final List<Day> days = [];
    var current = start;
    while (!current.isAfter(end)) {
      final day = await load(current);
      if (day != null) days.add(day);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }
}
