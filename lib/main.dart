import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:pray/l10n/app_localizations.dart';
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

  // Apply the daily optional-prayer auto-increment once at startup.
  // (Fires again at midnight and on app resume via _MyAppState.)
  await userStateController.applyDailyAutoIncrement(
    settingsController.currentSettings.autoIncrementOptionalPrayerCounterBy,
  );

  Future<void> handleNotificationResponse(NotificationResponse response) async {
    debugPrint(
      '[notif-handler] fired: actionId=${response.actionId} payload=${response.payload}',
    );

    if (response.payload != null) {
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
          '[notif-handler] togglePrayer succeeded for $prayerName on $date',
        );
      }
    }
  }

  await NotificationService.instance.init(
    onNotificationResponse: handleNotificationResponse,
    localeName: settingsController.currentSettings.language.name,
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnightCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    // 1. Catch up on any missed days and re-arm the midnight timer
    //    (iOS suspends timers while backgrounded).
    _runAutoIncrement();
    _scheduleMidnightCheck();

    // 2. Reload today's data so a "Mark as Done" tap from a notification
    //    action (handled in a background isolate) is reflected in the UI.
    _reloadToday();
  }

  /// Schedules a one-shot timer for the next local midnight, then reschedules
  /// itself in the callback so it keeps firing day after day.
  void _scheduleMidnightCheck() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    // `DateTime(now.year, now.month, now.day + 1)` correctly handles month
    // rollover and DST (the local-timezone constructor normalizes it).
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final delay = nextMidnight.difference(now);

    debugPrint('[lifecycle] next auto-increment check in $delay');

    _midnightTimer = Timer(delay, () {
      _runAutoIncrement();
      _scheduleMidnightCheck();
    });
  }

  Future<void> _runAutoIncrement() async {
    if (!mounted) return;
    final settings = context.read<SettingsController>();
    final userState = context.read<UserStateController>();
    await userState.applyDailyAutoIncrement(
      settings.currentSettings.autoIncrementOptionalPrayerCounterBy,
    );
  }

  /// Reloads today's [Day] from storage, pulling in any changes written by
  /// the background notification-action isolate. Cheap when nothing changed
  /// (Isar read + in-memory map assignment).
  Future<void> _reloadToday() async {
    if (!mounted) return;
    final daysController = context.read<DaysController>();
    await daysController.loadDay(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final isDarkMode = settingsController.currentSettings.darkMode;
    final locale = Locale(settingsController.currentSettings.language.name);

    return MaterialApp(
      title: 'Prayer Times',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainShell(),
    );
  }
}
