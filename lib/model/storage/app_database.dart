import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/settings.dart';
import 'package:pray/model/types/user_state.dart';

class AppDatabase {
  static Future<Isar> init() async {
    final dir = await getApplicationDocumentsDirectory();

    return await Isar.open([
      DaySchema,
      SettingsSchema,
      UserStateSchema,
    ], directory: dir.path);
  }
}
