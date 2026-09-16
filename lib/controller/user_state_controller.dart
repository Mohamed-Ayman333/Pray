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
}
