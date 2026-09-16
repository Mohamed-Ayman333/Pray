import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Import Database helper
import 'package:pray/model/storage/app_database.dart';

// Import shared settings+days bootstrap
import 'package:pray/core/app_core.dart';

// Import storage interfaces & concrete implementations (user state only —
// settings and days storage are wired inside buildAppCore)
import 'package:pray/model/storage/i_user_state_storage.dart';
import 'package:pray/model/storage/user_state_storage.dart';

// Import repositories
import 'package:pray/model/storage/user_state_repository.dart';

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

  // STEP 1: Build settings + days data layer (shared with the background
  // notification-tap isolate in notification_service.dart)
  final appCore = await buildAppCore(isar);
  final settingsController = appCore.settingsController;
  final daysRepository = appCore.daysRepository;

  // STEP 2: Build UserState layer (unrelated to notifications, wired here directly)
  final IUserStateStorage userStateStorage = UserStateStorage(isar);
  final userStateRepository = UserStateRepository(
    userStateStorage: userStateStorage,
  );
  final userStateController = UserStateController(
    userStateRepository: userStateRepository,
  );

  // STEP 3: Build Days controller
  final daysController = DaysController(
    daysRepository: daysRepository,
    settingsController: settingsController,
  );

  // STEP 4: Initialize remaining persisted state
  // (settingsController is already initialized inside buildAppCore)
  await userStateController.init();

  // STEP 5: Initialize Notification Service and wire Mark as Done payload action
  await NotificationService.instance.init(
    onNotificationResponse: (NotificationResponse response) async {
      debugPrint(
        '[notif-fg] fired: actionId=${response.actionId} payload=${response.payload}',
      );
      if (response.actionId == 'mark_done_action' && response.payload != null) {
        final parts = response.payload!.split('|');
        if (parts.length == 2) {
          final date = DateTime.parse(parts[0]);
          final prayerName = parts[1];
          await daysController.togglePrayer(date, prayerName);
          debugPrint(
            '[notif-fg] togglePrayer succeeded for $prayerName on $date',
          );
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
