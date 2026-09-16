import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Import Database helper
import 'package:pray/model/storage/app_database.dart';

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

// Import notification service
import 'package:pray/service/notification_service.dart';

// Import Theme setup
import 'package:pray/view/theme/app_theme.dart';

// Import Main Shell Wrapper
import 'package:pray/view/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // STEP 0: Open Isar Database via AppDatabase helper
  final isar = await AppDatabase.init();

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

  // STEP 3: Build calculation storages with dynamic SettingsController reference
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

  final daysController = DaysController(
    daysRepository: daysRepository,
    settingsController: settingsController,
  );

  // STEP 5: Initialize persisted states
  await Future.wait([settingsController.init(), userStateController.init()]);

  // STEP 6: Initialize Notification Service and wire Mark as Done payload action
  await NotificationService.instance.init(
    onNotificationResponse: (NotificationResponse response) async {
      if (response.actionId == 'mark_done_action' && response.payload != null) {
        final parts = response.payload!.split('|');
        if (parts.length == 2) {
          final date = DateTime.parse(parts[0]);
          final prayerName = parts[1];
          await daysController.togglePrayer(date, prayerName);
        }
      }
    },
  );

  // Attempt background location update
  _refreshLocationInBackground(settingsController);

  // Pre-load current month history and upcoming 30 days into memory cache
  final now = DateTime.now();
  await Future.wait([
    daysController.loadMonth(now),
    daysController.loadNext30Days(),
  ]);

  // loadNext30Days() no longer schedules notifications itself (that
  // previously caused double-scheduling when clearAndReload() also called
  // it), so schedule the initial batch explicitly here on startup.
  await daysController.syncNotifications();

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

Future<void> _refreshLocationInBackground(SettingsController settings) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );

    await settings.updateLocation(position.latitude, position.longitude);
  } catch (_) {
    // Fail silently to keep app responsive and offline-ready
  }
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
      home: const MainShell(),
    );
  }
}
