import 'package:isar/isar.dart';
import 'package:pray/model/storage/i_settings_storage.dart';
import 'package:pray/model/types/settings.dart';

class SettingsStorage implements ISettingsStorage {
  final Isar isar;

  SettingsStorage(this.isar);

  @override
  Future<void> save(Settings settings) async {
    settings.id = 1;
    await isar.writeTxn(() async {
      await isar.settings.put(settings);
    });
  }

  @override
  Future<Settings?> load() async {
    final settings = await isar.settings.get(1);
    return settings ?? Settings();
  }
}
