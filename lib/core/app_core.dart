import 'package:isar/isar.dart';

import 'package:pray/controller/settings_controller.dart';
import 'package:pray/model/storage/settings_storage.dart';
import 'package:pray/model/storage/settings_repository.dart';
import 'package:pray/model/storage/local_days_storage.dart';
import 'package:pray/model/storage/calculated_days_storage.dart';
import 'package:pray/model/storage/caching_calculated_days_storage.dart';
import 'package:pray/model/storage/days_repository.dart';

/// Bundles the settings + days data layer built from a single Isar instance.
///
/// This is the one place that wires SettingsController -> CalculatedDaysStorage
/// -> CachingCalculatedDaysStorage -> DaysRepository. Both the running app
/// (main.dart) and the background notification-tap isolate
/// (notification_service.dart) call [buildAppCore] instead of each
/// reconstructing this graph by hand, which previously let the two copies
/// drift out of sync.
class AppCore {
  final SettingsController settingsController;
  final DaysRepository daysRepository;

  AppCore({required this.settingsController, required this.daysRepository});
}

Future<AppCore> buildAppCore(Isar isar) async {
  final settingsController = SettingsController(
    settingsRepository: SettingsRepository(
      settingsStorage: SettingsStorage(isar),
    ),
  );
  await settingsController.init();

  final localDaysStorage = LocalDaysStorage(isar);
  final cachingDaysStorage = CachingCalculatedDaysStorage(
    calculatedStorage: CalculatedDaysStorage(
      settingsController: settingsController,
    ),
    localStorage: localDaysStorage,
  );

  final daysRepository = DaysRepository(
    localStorage: localDaysStorage,
    cachingCalculatedStorage: cachingDaysStorage,
  );

  return AppCore(
    settingsController: settingsController,
    daysRepository: daysRepository,
  );
}
