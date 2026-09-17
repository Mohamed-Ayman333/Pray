import 'package:flutter/foundation.dart';
import 'package:pray/model/storage/user_state_repository.dart';
import 'package:pray/model/types/user_state.dart';

class UserStateController extends ChangeNotifier {
  final UserStateRepository _userStateRepository;
  late UserState _currentUserState;
  bool _isInitialized = false;

  UserStateController({required UserStateRepository userStateRepository})
    : _userStateRepository = userStateRepository {
    _currentUserState = UserState();
  }

  bool get isInitialized => _isInitialized;
  UserState get currentUserState => _currentUserState;

  /// Loads persisted user state from local storage on startup
  Future<void> init() async {
    final loadedState = await _userStateRepository.load();
    if (loadedState != null) {
      _currentUserState = loadedState;
    } else {
      await _userStateRepository.save(_currentUserState);
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Internal helper to update state, persist to Isar, and notify listeners
  Future<void> _updateAndSave(void Function(UserState s) update) async {
    update(_currentUserState);
    await _userStateRepository.save(_currentUserState);
    notifyListeners();
  }

  // --- MUTATION METHODS ---

  Future<void> incrementOptionalPrayer([int step = 1]) async {
    await _updateAndSave((s) {
      s.optionalPrayerCounter += step;
    });
  }

  Future<void> decrementOptionalPrayer([int step = 1]) async {
    await _updateAndSave((s) {
      if (s.optionalPrayerCounter - step >= 0) {
        s.optionalPrayerCounter -= step;
      } else {
        s.optionalPrayerCounter = 0;
      }
    });
  }

  Future<void> setOptionalPrayerCounter(int value) async {
    await _updateAndSave((s) {
      s.optionalPrayerCounter = value < 0 ? 0 : value;
    });
  }

  /// Records that the user has already been shown the battery-optimization
  /// exemption prompt, so it is only ever displayed once per install.
  ///
  /// No-op if already true, to avoid a redundant Isar write.
  Future<void> markBatteryExemptionPrompted() async {
    if (_currentUserState.hasPromptedBatteryExemption) return;
    await _updateAndSave((s) {
      s.hasPromptedBatteryExemption = true;
    });
  }

  /// Applies the daily optional-prayer auto-increment configured in
  /// [Settings.autoIncrementOptionalPrayerCounterBy].
  ///
  /// Intended to run once per app launch (from `main()`), *after* both
  /// controllers are initialized. Behavior:
  ///
  /// * **incrementBy <= 0** → feature is off. The internal "last applied"
  ///   marker is still advanced to today so that turning the feature on
  ///   later doesn't retroactively add for the disabled period.
  /// * **First-ever launch** (`lastAutoIncrementDate == null`) → record
  ///   today without incrementing, to avoid a surprise jump.
  /// * **Same day** → no-op (guarantees at most one increment per day).
  /// * **Clock moved backwards** → reset the marker to today, no increment.
  /// * **N days elapsed** → counter += incrementBy * N, marker = today.
  Future<void> applyDailyAutoIncrement(int incrementBy) async {
    if (!_isInitialized) return;

    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final last = _currentUserState.lastAutoIncrementDate;

    // Feature disabled — keep the marker fresh so re-enabling doesn't
    // cause a catch-up burst for the disabled days.
    if (incrementBy <= 0) {
      if (last == null || !_isSameUtcDay(last, today)) {
        await _updateAndSave((s) => s.lastAutoIncrementDate = today);
      }
      return;
    }

    // First time we've ever run this logic on this install.
    if (last == null) {
      await _updateAndSave((s) => s.lastAutoIncrementDate = today);
      debugPrint('[user-state] auto-increment baseline set to $today');
      return;
    }

    final lastNormalized = DateTime.utc(last.year, last.month, last.day);

    if (lastNormalized.isAtSameMomentAs(today)) return;

    if (lastNormalized.isAfter(today)) {
      // Clock moved backwards; reset quietly.
      await _updateAndSave((s) => s.lastAutoIncrementDate = today);
      debugPrint('[user-state] clock moved backwards, resetting marker');
      return;
    }

    final daysElapsed = today.difference(lastNormalized).inDays;
    if (daysElapsed <= 0) return;

    final delta = incrementBy * daysElapsed;
    await _updateAndSave((s) {
      s.optionalPrayerCounter += delta;
      s.lastAutoIncrementDate = today;
    });

    debugPrint(
      '[user-state] auto-incremented optional prayer counter by '
      '$delta ($daysElapsed day(s) × $incrementBy)',
    );
  }

  bool _isSameUtcDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
