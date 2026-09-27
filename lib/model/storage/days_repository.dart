import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/controller/settings_controller.dart';

class DaysRepository implements IDaysStorage {
  final IDaysStorage _localStorage;
  final IDaysStorage _cachingCalculatedStorage;
  final SettingsController _settingsController;

  DaysRepository({
    required IDaysStorage localStorage,
    required IDaysStorage cachingCalculatedStorage,
    required SettingsController settingsController,
  }) : _localStorage = localStorage,
       _cachingCalculatedStorage = cachingCalculatedStorage,
       _settingsController = settingsController;

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

    // Don't-track mode: never persist pending info for past days. Store
    // an empty tombstone so the day reads back as a completed record
    // without carrying any per-prayer state.
    if (!_settingsController.trackPrayers &&
        day.date != null &&
        _isPast(day.date!)) {
      final tombstone = Day(date: day.date, prayers: const [])..id = day.id;
      await _localStorage.save(tombstone);
      return;
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

    if (!_settingsController.trackPrayers) {
      final rewritten = days.map((d) {
        if (d.date != null && _isPast(d.date!)) {
          return Day(date: d.date, prayers: const [])..id = d.id;
        }
        return d;
      }).toList();
      await _localStorage.saveAll(rewritten);
      return;
    }

    await _localStorage.saveAll(days);
  }

  @override
  Future<Day?> load(DateTime date) async {
    final normalizedDate = _toNormalizedUtc(date);
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    // 1. Past: local only. No record means "unknown", not "missed everything".
    if (_isPast(normalizedDate)) {
      final localDay = await _localStorage.load(normalizedDate);

      // Tracking disabled: every past day becomes a tombstone — a stored
      // record with an empty prayer list. Catches rows written before the
      // toggle was switched off; new writes are already tombstones via save().
      if (!_settingsController.trackPrayers) {
        if (localDay != null && localDay.prayers.isEmpty) {
          return localDay;
        }
        final tombstone = Day(date: normalizedDate, prayers: const []);
        if (localDay != null) tombstone.id = localDay.id;
        await _localStorage.save(tombstone);
        return tombstone;
      }

      return localDay;
    }

    // 2. Today & Future: unchanged.
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
      await _localStorage.save(calculatedDay);
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

    // Pure past.
    if (end.isBefore(today)) {
      return await _pastRange(start, end);
    }

    // Today only.
    if (start.isAtSameMomentAs(today) && end.isAtSameMomentAs(today)) {
      return await _fetchTodayRange(today);
    }

    // Pure future.
    if (start.isAfter(today)) {
      return await _fetchFutureRange(start, end);
    }

    // Mixed: fan out into past / today / future slices.
    final List<Future<List<Day>>> requests = [];

    if (start.isBefore(today)) {
      final pastEnd = end.isBefore(today) ? end : yesterday;
      requests.add(_pastRange(start, pastEnd));
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

  /// Loads past days, honoring don't-track mode. When tracking is off,
  /// every day in the range is returned as an empty tombstone, and any
  /// stored row that still carries pending prayers is overwritten so the
  /// state survives across sessions.
  Future<List<Day>> _pastRange(DateTime start, DateTime end) async {
    final stored = await _localStorage.getInRange(start, end);

    if (_settingsController.trackPrayers) return stored;

    // Index stored rows by date so we can preserve their ids on overwrite.
    final byDate = <DateTime, Day>{
      for (final d in stored)
        if (d.date != null) _toNormalizedUtc(d.date!): d,
    };

    final fabricated = <Day>[];
    final toPersist = <Day>[];
    var current = start;

    while (!current.isAfter(end)) {
      final existing = byDate[current];
      final tombstone = Day(date: current, prayers: const []);
      if (existing != null) tombstone.id = existing.id;
      fabricated.add(tombstone);

      // Only write rows that don't yet exist or that still hold pending
      // prayers. Already-empty rows are left alone.
      if (existing == null || existing.prayers.isNotEmpty) {
        toPersist.add(tombstone);
      }

      current = current.add(const Duration(days: 1));
    }

    if (toPersist.isNotEmpty) {
      await _localStorage.saveAll(toPersist);
    }

    return fabricated;
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
