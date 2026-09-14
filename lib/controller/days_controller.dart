import 'package:flutter/foundation.dart';
import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/prayer.dart';

class DaysController extends ChangeNotifier {
  final IDaysStorage _daysRepository;
  final Map<DateTime, Day> _loadedDays = {};

  DaysController({required IDaysStorage daysRepository})
    : _daysRepository = daysRepository;

  /// Public read-only access to loaded days[cite: 13]
  Map<DateTime, Day> get loadedDays => Map.unmodifiable(_loadedDays);

  /// Utility to ensure Map keys are strictly midnight dates[cite: 13]
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Loads a single day from the repository and updates in-memory cache[cite: 13]
  Future<void> loadDay(DateTime date) async {
    final normalized = _normalizeDate(date);
    final day = await _daysRepository.load(normalized);
    if (day != null) {
      _loadedDays[normalized] = day;
      notifyListeners();
    }
  }

  /// Loads a date range from repository and populates in-memory cache[cite: 13]
  Future<void> loadDaysInRange(DateTime startDate, DateTime endDate) async {
    final days = await _daysRepository.getInRange(startDate, endDate);
    for (final day in days) {
      if (day.date != null) {
        final normalized = _normalizeDate(day.date!);
        _loadedDays[normalized] = day;
      }
    }
    notifyListeners();
  }

  /// Retrieves a Day synchronously from the in-memory cache[cite: 13]
  Day? getDay(DateTime date) {
    return _loadedDays[_normalizeDate(date)];
  }

  /// Synchronously gets from cache, or asynchronously loads and caches on miss
  Future<Day?> getOrLoadDay(DateTime date) async {
    final normalized = _normalizeDate(date);

    if (_loadedDays.containsKey(normalized)) {
      return _loadedDays[normalized];
    }

    await loadDay(normalized);
    return _loadedDays[normalized];
  }

  /// Toggles `isDone` status for a specific prayer and persists to storage[cite: 13]
  Future<void> togglePrayer(DateTime date, String prayerName) async {
    final normalized = _normalizeDate(date);
    final day = _loadedDays[normalized];

    if (day == null) return;

    final prayerIndex = day.prayers.indexWhere(
      (p) => p.name.toLowerCase() == prayerName.toLowerCase(),
    );

    if (prayerIndex != -1) {
      day.prayers[prayerIndex].isDone = !day.prayers[prayerIndex].isDone;
      await _daysRepository.save(day);
      notifyListeners();
    }
  }

  /// Returns the next upcoming prayer for the current time[cite: 13]
  Prayer? get nextPrayer {
    final now = DateTime.now();
    final today = getDay(now);

    if (today != null) {
      for (final prayer in today.prayers) {
        final time = prayer.time;
        if (time != null && time.isAfter(now)) {
          return prayer;
        }
      }
    }

    // If all prayers today passed (or today wasn't loaded), check tomorrow's Fajr[cite: 13]
    final tomorrow = getDay(now.add(const Duration(days: 1)));
    if (tomorrow == null) return null;

    try {
      return tomorrow.prayers.firstWhere((p) => p.name.toLowerCase() == 'fajr');
    } catch (_) {
      return null;
    }
  }

  /// Calculates remaining time duration until next prayer[cite: 13]
  Duration get timeUntilNextPrayer {
    final next = nextPrayer;
    if (next == null || next.time == null) return Duration.zero;
    return next.time!.difference(DateTime.now());
  }

  /// Helper to load the next 30 days into memory for the table view[cite: 13]
  Future<void> loadNext30Days() async {
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day);
    final endDate = startDate.add(const Duration(days: 30));
    await loadDaysInRange(startDate, endDate);
  }
}
