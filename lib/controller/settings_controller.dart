import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:pray/model/storage/settings_repository.dart';
import 'package:pray/model/types/language.dart';
import 'package:pray/model/types/settings.dart';

class SettingsController extends ChangeNotifier {
  final SettingsRepository _settingsRepository;
  late Settings _currentSettings;
  bool _isInitialized = false;

  SettingsController({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository {
    _currentSettings = Settings();
  }

  bool get isInitialized => _isInitialized;
  Settings get currentSettings => _currentSettings;

  /// Loads persisted settings from local storage on app initialization
  Future<void> init() async {
    final loadedSettings = await _settingsRepository.load();
    if (loadedSettings != null) {
      _currentSettings = loadedSettings;
    } else {
      await _settingsRepository.save(_currentSettings);
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Internal helper to update state, persist to Isar, and notify listeners
  Future<void> _updateAndSave(void Function(Settings s) update) async {
    update(_currentSettings);
    await _settingsRepository.save(_currentSettings);
    notifyListeners();
  }

  // --- MUTATION METHODS ---

  Future<void> updateLocation(double latitude, double longitude) async {
    await _updateAndSave((s) {
      s.latitude = latitude;
      s.longitude = longitude;
    });
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await _updateAndSave((s) => s.darkMode = enabled);
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _updateAndSave((s) => s.notifications = enabled);
  }

  Future<void> toggleStickyNotifications(bool enabled) async {
    await _updateAndSave((s) => s.stickyNotifications = enabled);
  }

  Future<void> toggleAzan(bool enabled) async {
    await _updateAndSave((s) => s.azan = enabled);
  }

  Future<void> updateReminderOffset(int minutes) async {
    await _updateAndSave((s) => s.reminderOffsetInMinutes = minutes);
  }

  Future<void> updateAutoIncrementOptionalPrayerCounterBy(int value) async {
    await _updateAndSave((s) => s.autoIncrementOptionalPrayerCounterBy = value);
  }

  Future<void> updateLanguage(Language language) async {
    await _updateAndSave((s) => s.language = language);
  }

  Future<void> updateCalculationMethod(CalculationMethod method) async {
    await _updateAndSave((s) => s.calculationMethod = method);
  }

  Future<void> updateMadhab(Madhab madhab) async {
    await _updateAndSave((s) => s.madhab = madhab);
  }
}
