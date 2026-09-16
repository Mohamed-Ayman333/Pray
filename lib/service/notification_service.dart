import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Day;
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
      final date = DateTime.parse(parts[0]);
      final prayerName = parts[1];

      try {
        final isar = await AppDatabase.init();
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
    } else {
      debugPrint(
        '[notif-bg] payload did not split into 2 parts: ${response.payload}',
      );
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

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

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
    // Whether the notification should keep repeating its sound/vibration
    // until the user dismisses or acts on it, instead of firing once.
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
          // FLAG_INSISTENT (4): Android keeps replaying this notification's
          // sound/vibration on this SAME notification until the user
          // dismisses it or taps an action, instead of only alerting once.
          additionalFlags: repeatSound ? Int32List.fromList(<int>[4]) : null,
          actions: const [
            AndroidNotificationAction(
              'mark_done_action',
              'Mark as Done',
              showsUserInterface: false,
            ),
          ],
        ),
        // Note: iOS has no equivalent to FLAG_INSISTENT — Apple only
        // allows a notification's sound to play once, so repeatSound
        // only has an effect on Android.
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'PRAYER_CATEGORY',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
