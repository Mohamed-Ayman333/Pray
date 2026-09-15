import 'package:flutter/foundation.dart';
import 'package:pray/controller/settings_controller.dart';
import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/prayer.dart';

class DaysController extends ChangeNotifier {
  final IDaysStorage _daysRepository;
  final SettingsController _settingsController;
  final Map<DateTime, Day> _loadedDays = {};

  DaysController({
    required IDaysStorage daysRepository,
    required SettingsController settingsController,
  }) : _daysRepository = daysRepository,
       _settingsController = settingsController {
    _settingsController.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settingsController.removeListener(_onSettingsChanged);
    super.dispose();
  }

  Future<void> _onSettingsChanged() async {
    await clearAndReload();
  }

  Future<void> clearAndReload() async {
    _loadedDays.clear();
    final now = DateTime.now();
    await Future.wait([loadMonth(now), loadNext30Days()]);
  }

  Map<DateTime, Day> get loadedDays => Map.unmodifiable(_loadedDays);

  /// Converts any DateTime to UTC Midnight (00:00:00.000Z) to match Isar storage format
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  Future<void> loadDay(DateTime date) async {
    final normalized = _normalizeDate(date);
    final day = await _daysRepository.load(normalized);
    if (day != null) {
      _loadedDays[normalized] = day;
    } else {
      _loadedDays.remove(normalized);
    }
    notifyListeners();
  }

  Future<void> loadDaysInRange(DateTime startDate, DateTime endDate) async {
    final startNormalized = _normalizeDate(startDate);
    final endNormalized = DateTime.utc(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    final days = await _daysRepository.getInRange(
      startNormalized,
      endNormalized,
    );
    for (final day in days) {
      if (day.date != null) {
        final normalized = _normalizeDate(day.date!);
        _loadedDays[normalized] = day;
      }
    }
    notifyListeners();
  }

  /// Loads historical days for a given calendar month (capped at today)
  Future<void> loadMonth(DateTime monthDate) async {
    final now = DateTime.now();
    final today = _normalizeDate(now);

    final startDate = DateTime.utc(monthDate.year, monthDate.month, 1);

    // Get last day of the target month
    final lastDayOfMonth = DateTime.utc(
      monthDate.year,
      monthDate.month + 1,
      0,
    ).day;
    var endDate = DateTime.utc(
      monthDate.year,
      monthDate.month,
      lastDayOfMonth,
      23,
      59,
      59,
      999,
    );

    if (startDate.isAfter(today)) return;

    if (endDate.isAfter(today)) {
      endDate = DateTime.utc(
        today.year,
        today.month,
        today.day,
        23,
        59,
        59,
        999,
      );
    }

    await loadDaysInRange(startDate, endDate);
  }

  Day? getDay(DateTime date) {
    return _loadedDays[_normalizeDate(date)];
  }

  Future<Day?> getOrLoadDay(DateTime date) async {
    final normalized = _normalizeDate(date);

    if (_loadedDays.containsKey(normalized)) {
      return _loadedDays[normalized];
    }

    await loadDay(normalized);
    return _loadedDays[normalized];
  }

  int getMissedPrayersCount(DateTime date) {
    final normalized = _normalizeDate(date);
    final day = getDay(normalized);

    if (day == null) {
      return 0;
    }

    return day.pendingPrayers.length;
  }

  bool isDayFullyCompleted(DateTime date) {
    return getMissedPrayersCount(date) == 0;
  }

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

    final tomorrow = getDay(now.add(const Duration(days: 1)));
    if (tomorrow == null) return null;

    try {
      return tomorrow.prayers.firstWhere((p) => p.name.toLowerCase() == 'fajr');
    } catch (_) {
      return null;
    }
  }

  Duration get timeUntilNextPrayer {
    final next = nextPrayer;
    if (next == null || next.time == null) return Duration.zero;
    return next.time!.difference(DateTime.now());
  }

  Future<void> loadNext30Days() async {
    final today = DateTime.now();
    final startDate = _normalizeDate(today);
    final endDate = startDate.add(const Duration(days: 30));
    await loadDaysInRange(startDate, endDate);
  }
}
