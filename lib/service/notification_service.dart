import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Day;
import 'package:isar/isar.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:pray/core/app_core.dart';
import 'package:pray/model/storage/app_database.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/settings.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint(
    '[notif-bg] fired: actionId=${response.actionId} payload=${response.payload}',
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

      try {
        final isar = Isar.getInstance() ?? await AppDatabase.init();
        final core = await buildAppCore(isar);
        await core.daysRepository.togglePrayer(date, prayerName);

        debugPrint(
          '[notif-bg] togglePrayer succeeded for $prayerName on $date',
        );
      } catch (e, st) {
        debugPrint(
          '[notif-bg] Error handling background notification tap: $e\n$st',
        );
      }
    }
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  static const String _channelId = 'prayer_channel';
  static const String _channelName = 'Prayer Reminders';
  static const String _channelDescription =
      'Notifications for upcoming prayer times';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init({
    required Function(NotificationResponse) onNotificationResponse,
  }) async {
    if (_initialized) return;

    // ---- Timezone setup ----
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('[notif] timezone set to $timeZoneName');
    } catch (e) {
      debugPrint('[notif] failed to resolve timezone, falling back to UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    // ---- Init settings ----
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    final iosCategories = [
      DarwinNotificationCategory(
        'PRAYER_CATEGORY',
        actions: [
          DarwinNotificationAction.plain(
            'mark_done_action',
            'Mark as Done',
            options: const <DarwinNotificationActionOption>{},
          ),
        ],
      ),
    ];

    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: iosCategories,
    );

    await _plugin.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // ---- Cold-launch via notification tap ----
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null &&
        launchDetails.didNotificationLaunchApp &&
        launchDetails.notificationResponse != null) {
      debugPrint('[notif-init] Cold launched via notification tap');
      await onNotificationResponse(launchDetails.notificationResponse!);
    }

    // ---- Android-specific setup ----
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      await androidImplementation.createNotificationChannel(channel);
      debugPrint('[notif] channel created');

      // Notifications (Android 13+)
      final bool? notifGranted = await androidImplementation
          .requestNotificationsPermission();
      debugPrint('[notif] notifications permission granted: $notifGranted');

      // Exact alarms (Android 12+). This opens the system settings screen
      // if the user needs to grant it manually.
      final bool? exactGranted = await androidImplementation
          .requestExactAlarmsPermission();
      debugPrint('[notif] exact alarm permission granted: $exactGranted');
    }

    // ---- iOS permission ----
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> schedulePrayerNotifications(
    List<Day> days,
    Settings settings,
  ) async {
    debugPrint('[notif] scheduling for ${days.length} days');

    await _plugin.cancelAll();

    if (!settings.notifications) {
      debugPrint('[notif] notifications disabled in settings');
      return;
    }

    int notificationId = 0;
    final now = DateTime.now();
    final repeatSound = settings.reminderOffsetInMinutes > 0;
    int scheduled = 0;

    for (final day in days) {
      for (final prayer in day.prayers) {
        if (prayer.isDone) continue;

        final time = prayer.time;
        if (time == null || !time.isAfter(now)) continue;

        try {
          await _scheduleSingleNotification(
            id: notificationId++,
            title: 'Time for ${prayer.name}',
            body: 'It is time for ${prayer.name} prayer.',
            scheduledTime: time,
            settings: settings,
            payload: '${day.date?.toIso8601String()}|${prayer.name}',
            repeatSound: repeatSound,
          );
          scheduled++;
        } catch (e, st) {
          debugPrint(
            '[notif] FAILED to schedule ${prayer.name} at $time: $e\n$st',
          );
        }
      }
    }

    debugPrint('[notif] scheduled $scheduled notifications');
  }

  Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required Settings settings,
    required String payload,
    bool repeatSound = false,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ongoing: settings.stickyNotifications,
        autoCancel: !settings.stickyNotifications,
        additionalFlags: repeatSound ? Int32List.fromList(<int>[4]) : null,
        actions: const [
          AndroidNotificationAction(
            'mark_done_action',
            'Mark as Done',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: 'PRAYER_CATEGORY',
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('[notif] exact scheduled id=$id at $tzTime');
    } on PlatformException catch (e) {
      debugPrint('[notif] exact schedule failed ($e), falling back to inexact');
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('[notif] inexact scheduled id=$id at $tzTime');
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
