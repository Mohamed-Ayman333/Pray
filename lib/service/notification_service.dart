import 'dart:typed_data';

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

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({
    void Function(NotificationResponse)? onNotificationResponse,
  }) async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

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

    // Explicitly create high-importance notification channel for Android
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      const channel = AndroidNotificationChannel(
        'prayer_channel',
        'Prayer Reminders',
        description: 'Notifications for upcoming prayer times',
        importance: Importance.max,
      );
      await androidImplementation.createNotificationChannel(channel);
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> schedulePrayerNotifications(
    List<Day> days,
    Settings settings,
  ) async {
    await _plugin.cancelAll();

    if (!settings.notifications) return;

    int notificationId = 0;
    final now = DateTime.now();
    final repeatSound = settings.reminderOffsetInMinutes > 0;

    for (final day in days) {
      for (final prayer in day.prayers) {
        if (prayer.isDone) continue;

        final time = prayer.time;
        if (time == null || !time.isAfter(now)) continue;

        await _scheduleSingleNotification(
          id: notificationId++,
          title: 'Time for ${prayer.name}',
          body: 'It is time for ${prayer.name} prayer.',
          scheduledTime: time,
          settings: settings,
          payload: '${day.date?.toIso8601String()}|${prayer.name}',
          repeatSound: repeatSound,
        );
      }
    }
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

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Reminders',
            channelDescription: 'Notifications for upcoming prayer times',
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
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (_) {
      // Fallback to inexact scheduling if exact alarm permission is denied
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Reminders',
            channelDescription: 'Notifications for upcoming prayer times',
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
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
