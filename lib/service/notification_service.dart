import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/settings.dart';

// Top-level background action handler required for notification buttons
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  if (response.actionId == 'mark_done_action') {
    // Background handling logic (e.g., updating Isar storage directly)
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

    // 1. Configure iOS interactive categories with "Mark as Done" action
    final iosCategories = [
      DarwinNotificationCategory(
        'PRAYER_CATEGORY',
        actions: [
          DarwinNotificationAction.plain(
            'mark_done_action',
            'Mark as Done',
            options: {DarwinNotificationActionOption.foreground},
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

  /// Schedules prayer notifications taking settings (e.g. sticky notifications) into account
  Future<void> schedulePrayerNotifications(
    List<Day> days,
    Settings settings,
  ) async {
    await _plugin.cancelAll();

    if (!settings.notifications) return;

    int notificationId = 0;
    final now = DateTime.now();

    for (final day in days) {
      for (final prayer in day.prayers) {
        final time = prayer.time;

        if (time != null && time.isAfter(now)) {
          // Adjust time if a reminder offset is set
          final scheduledTime = time.add(
            Duration(minutes: settings.reminderOffsetInMinutes),
          );
          final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

          await _plugin.zonedSchedule(
            notificationId++,
            'Time for ${prayer.name}',
            'It is time for ${prayer.name} prayer.',
            tzTime,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'prayer_channel',
                'Prayer Reminders',
                channelDescription: 'Notifications for upcoming prayer times',
                importance: Importance.max,
                priority: Priority.high,
                ongoing:
                    settings.stickyNotifications, // Sticky notification setting
                autoCancel: !settings.stickyNotifications,
                actions: const [
                  AndroidNotificationAction(
                    'mark_done_action',
                    'Mark as Done',
                    showsUserInterface: true,
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
            payload: '${day.date?.toIso8601String()}|${prayer.name}',
          );
        }
      }
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
