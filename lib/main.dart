import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:pray/model/storage/app_database.dart';
import 'package:pray/core/app_core.dart';
import 'package:pray/model/storage/i_user_state_storage.dart';
import 'package:pray/model/storage/user_state_storage.dart';
import 'package:pray/model/storage/user_state_repository.dart';
import 'package:pray/controller/settings_controller.dart';
import 'package:pray/controller/user_state_controller.dart';
import 'package:pray/controller/days_controller.dart';
import 'package:pray/service/notification_service.dart';
import 'package:pray/view/theme/app_theme.dart';
import 'package:pray/view/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await AppDatabase.init();

  final appCore = await buildAppCore(isar);
  final settingsController = appCore.settingsController;
  final daysRepository = appCore.daysRepository;

  final IUserStateStorage userStateStorage = UserStateStorage(isar);
  final userStateRepository = UserStateRepository(
    userStateStorage: userStateStorage,
  );
  final userStateController = UserStateController(
    userStateRepository: userStateRepository,
  );

  final daysController = DaysController(
    daysRepository: daysRepository,
    settingsController: settingsController,
  );

  await userStateController.init();

  await NotificationService.instance.init(
    onNotificationResponse: (NotificationResponse response) async {
      debugPrint(
        '[notif-fg] fired: actionId=${response.actionId} payload=${response.payload}',
      );
      if (response.actionId == 'mark_done_action' && response.payload != null) {
        final parts = response.payload!.split('|');
        if (parts.length == 2) {
          final parsedDate = DateTime.parse(parts[0]);
          final date = DateTime.utc(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
          );
          final prayerName = parts[1];
          await daysController.togglePrayer(date, prayerName);
          debugPrint(
            '[notif-fg] togglePrayer succeeded for $prayerName on $date',
          );
        }
      }
    },
  );

  _refreshLocationInBackground(settingsController);

  final now = DateTime.now();
  await Future.wait([
    daysController.loadMonth(now),
    daysController.loadNext30Days(),
  ]);

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
