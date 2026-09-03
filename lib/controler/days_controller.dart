import 'package:flutter/foundation.dart';
import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class DaysController extends ChangeNotifier {
  final IDaysStorage _daysRepository;
  final Map<DateTime, Day> _loadedDays = {};

  DaysController({required IDaysStorage daysRepository})
    : _daysRepository = daysRepository;

  /// Public read-only access to loaded days
  Map<DateTime, Day> get loadedDays => Map.unmodifiable(_loadedDays);

  /// Utility to ensure Map keys are strictly midnight dates
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Loads a single day from the repository and updates in-memory cache
  Future<void> loadDay(DateTime date) async {
    final normalized = _normalizeDate(date);
    final day = await _daysRepository.load(normalized);
    if (day != null) {
      _loadedDays[normalized] = day;
      notifyListeners();
    }
  }

  /// Loads a date range from repository and populates in-memory cache
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

  /// Retrieves a Day synchronously from the in-memory cache
  Day? getDay(DateTime date) {
    return _loadedDays[_normalizeDate(date)];
  }

  /// Toggles `isDone` status for a specific prayer and persists to storage
  Future<void> togglePrayer(DateTime date, String prayerName) async {
    final normalized = _normalizeDate(date);
    final day = _loadedDays[normalized];

    if (day == null) return;

    // Find target prayer in list
    final prayerIndex = day.prayers.indexWhere(
      (p) => p.name.toLowerCase() == prayerName.toLowerCase(),
    );

    if (prayerIndex != -1) {
      // Toggle in-memory state
      day.prayers[prayerIndex].isDone = !day.prayers[prayerIndex].isDone;

      // Persist updated Day model back through repository
      await _daysRepository.save(day);

      notifyListeners();
    }
  }
}
