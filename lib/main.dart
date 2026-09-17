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

  final now = DateTime.now();
  await Future.wait([
    daysController.loadMonth(now),
    daysController.loadNext30Days(),
  ]);

  unawaited(_refreshLocationInBackground(settingsController));

  // 👇 Render the UI immediately. Notification scheduling used to be awaited
  //    here and it blocked startup for 30–90 seconds when hundreds of
  //    alarms had to be scheduled. Now we do it after the first frame.
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

  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint('[startup] kicking off notification sync (post-frame)');
    // Fire-and-forget. Errors are logged inside syncNotifications.
    daysController.syncNotifications();
  });
}

Future<void> _refreshLocationInBackground(SettingsController settings) async {
  try {
    debugPrint('[location] starting refresh');

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[location] service enabled: $serviceEnabled');
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    debugPrint('[location] initial permission: $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('[location] after request: $permission');
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('[location] permission not granted, keeping stored coords');
      return;
    }

    // Cached fix first — instant, no timeout risk.
    Position? position;
    try {
      position = await Geolocator.getLastKnownPosition();
      debugPrint(
        '[location] last known: '
        '${position?.latitude}, ${position?.longitude}',
      );
    } catch (e) {
      debugPrint('[location] getLastKnownPosition failed: $e');
    }

    // Fall back to a live fix only if nothing is cached.
    if (position == null) {
      debugPrint('[location] no cached position, requesting live fix');
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
        debugPrint(
          '[location] live fix: ${position.latitude}, ${position.longitude}',
        );
      } on TimeoutException {
        debugPrint('[location] live fix timed out — no location available');
        return;
      }
    }

    final current = settings.currentSettings;
    const threshold = 0.001; // ~100 m
    final moved =
        (current.latitude - position.latitude).abs() > threshold ||
        (current.longitude - position.longitude).abs() > threshold;

    if (!moved) {
      debugPrint('[location] coordinates unchanged, skipping write');
      return;
    }

    debugPrint(
      '[location] updating → ${position.latitude}, ${position.longitude}',
    );
    await settings.updateLocation(position.latitude, position.longitude);

    debugPrint(
      '[location] done → '
      '${settings.currentSettings.latitude}, '
      '${settings.currentSettings.longitude}',
    );
  } catch (e, st) {
    debugPrint('[location] refresh failed: $e\n$st');
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

    _runAutoIncrement();
    _scheduleMidnightCheck();
    _reloadToday();
    _refreshLocationOnResume();
  }

  void _scheduleMidnightCheck() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
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

  Future<void> _reloadToday() async {
    if (!mounted) return;
    final daysController = context.read<DaysController>();
    await daysController.loadDay(DateTime.now());
  }

  Future<void> _refreshLocationOnResume() async {
    if (!mounted) return;
    final settings = context.read<SettingsController>();
    await _refreshLocationInBackground(settings);
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
