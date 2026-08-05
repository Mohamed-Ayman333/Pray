import 'package:pray/model/storage/i_settings_storage.dart';
import 'package:pray/model/types/settings.dart';

class SettingsRepository {
  final ISettingsStorage _settingsStorage;

  SettingsRepository({required ISettingsStorage settingsStorage})
    : _settingsStorage = settingsStorage;

  Future<void> save(Settings settings) async {
    await _settingsStorage.save(settings);
  }

  Future<Settings?> load() async {
    //TODO:save befor returning
    return await _settingsStorage.load();
  }
}
