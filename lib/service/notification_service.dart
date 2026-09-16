import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Day;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pray/model/storage/app_database.dart';
import 'package:pray/model/storage/local_days_storage.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/settings.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  // Required when executing background tasks in Flutter
  WidgetsFlutterBinding.ensureInitialized();

  if (response.actionId == 'mark_done_action' && response.payload != null) {
    final parts = response.payload!.split('|');
    if (parts.length == 2) {
      final date = DateTime.parse(parts[0]);
      final prayerName = parts[1];

      try {
        // Initialize local storage inside the background isolate
        final isar = await AppDatabase.init();
        final daysStorage = LocalDaysStorage(isar);

        final normalizedDate = DateTime.utc(date.year, date.month, date.day);
        final day = await daysStorage.load(normalizedDate);

        if (day != null) {
          final prayerIndex = day.prayers.indexWhere(
            (p) => p.name.toLowerCase() == prayerName.toLowerCase(),
          );

          if (prayerIndex != -1) {
            day.prayers[prayerIndex].isDone = true;
            await daysStorage.save(day);
          }
        }
      } catch (e) {
        debugPrint('Error updating prayer in background: $e');
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
    final intervalMinutes = settings.reminderOffsetInMinutes;

    for (final day in days) {
      for (final prayer in day.prayers) {
        if (prayer.isDone) continue;

        final time = prayer.time;
        if (time == null) continue;

        final baseTime = time;

        if (baseTime.isAfter(now)) {
          await _scheduleSingleNotification(
            id: notificationId++,
            title: 'Time for ${prayer.name}',
            body: 'It is time for ${prayer.name} prayer.',
            scheduledTime: baseTime,
            settings: settings,
            payload: '${day.date?.toIso8601String()}|${prayer.name}',
          );
        }

        if (intervalMinutes > 0) {
          for (int repeat = 1; repeat <= 3; repeat++) {
            final repeatTime = baseTime.add(
              Duration(minutes: repeat * intervalMinutes),
            );

            if (repeatTime.isAfter(now)) {
              await _scheduleSingleNotification(
                id: notificationId++,
                title: 'Reminder: ${prayer.name}',
                body: 'It is time for ${prayer.name} prayer.',
                scheduledTime: repeatTime,
                settings: settings,
                payload: '${day.date?.toIso8601String()}|${prayer.name}',
              );
            }
          }
        }
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
          actions: const [
            AndroidNotificationAction(
              'mark_done_action',
              'Mark as Done',
              showsUserInterface: false,
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
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
