import 'package:pray/model/storage/i_settings_storage.dart';
import 'package:pray/model/types/settings.dart';

class SettingsStorage implements ISettingsStorage {
  @override
  Future<void> save(Settings settings) async {
    // TODO: Write settings to shared_preferences or local file
  }

  @override
  Future<Settings?> load() async {
    // TODO: Read settings from shared_preferences or local file
    return null;
  }
}
