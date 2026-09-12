import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// Import domain models / schemas for Isar initialization
import 'package:pray/model/types/settings.dart';
import 'package:pray/model/types/user_state.dart';
import 'package:pray/model/types/day.dart';

// Import storage interfaces & concrete implementations
import 'package:pray/model/storage/i_settings_storage.dart';
import 'package:pray/model/storage/i_user_state_storage.dart';
import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/storage/settings_storage.dart';
import 'package:pray/model/storage/user_state_storage.dart';
import 'package:pray/model/storage/local_days_storage.dart';
import 'package:pray/model/storage/caching_calculated_days_storage.dart';
import 'package:pray/model/storage/calculated_days_storage.dart';

// Import repositories
import 'package:pray/model/storage/settings_repository.dart';
import 'package:pray/model/storage/user_state_repository.dart';
import 'package:pray/model/storage/days_repository.dart';

// Import controllers
import 'package:pray/controller/settings_controller.dart';
import 'package:pray/controller/user_state_controller.dart';
import 'package:pray/controller/days_controller.dart';

// Import Theme setup
import 'package:pray/view/theme/app_theme.dart';

// Import Home Page
import 'package:pray/view/ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // STEP 0: Open Isar Database
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    SettingsSchema,
    UserStateSchema,
    DaySchema,
  ], directory: dir.path);

  // STEP 1: Initialize raw Isar storage engines
  final ISettingsStorage settingsStorage = SettingsStorage(isar);
  final IUserStateStorage userStateStorage = UserStateStorage(isar);
  final IDaysStorage localDaysStorage = LocalDaysStorage(isar);

  // STEP 2: Build Settings & UserState layer
  final settingsRepository = SettingsRepository(
    settingsStorage: settingsStorage,
  );
  final userStateRepository = UserStateRepository(
    userStateStorage: userStateStorage,
  );

  final settingsController = SettingsController(
    settingsRepository: settingsRepository,
  );
  final userStateController = UserStateController(
    userStateRepository: userStateRepository,
  );

  // STEP 3: Build calculation storages with live SettingsController reference
  final IDaysStorage calcDaysStorage = CalculatedDaysStorage(
    settingsController: settingsController,
  );
  final IDaysStorage cachingDaysStorage = CachingCalculatedDaysStorage(
    calculatedStorage: calcDaysStorage,
    localStorage: localDaysStorage,
  );

  // STEP 4: Build Days repository and controller
  final daysRepository = DaysRepository(
    localStorage: localDaysStorage,
    cachingCalculatedStorage: cachingDaysStorage,
  );
  final daysController = DaysController(daysRepository: daysRepository);

  // STEP 5: Initialize persisted states & cache today's prayers
  await Future.wait([
    settingsController.init(),
    userStateController.init(),
    daysController.loadDay(DateTime.now()),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsController),
        ChangeNotifierProvider.value(value: userStateController),
        ChangeNotifierProvider.value(value: daysController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final isDarkMode = settingsController.currentSettings.darkMode;

    return MaterialApp(
      title: 'Prayer Times',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomePage(),
    );
  }
}
