import 'package:pray/model/types/settings.dart';

abstract class ISettingsStorage {
  Future<void> save(Settings settings);
  Future<Settings?> load();
}
