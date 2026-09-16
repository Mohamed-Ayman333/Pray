import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Day;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/settings.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  if (response.actionId == 'mark_done_action') {
    // Handle background taps if app is killed
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

  /// Schedules prayer notifications. Repeating interval step is determined by `reminderOffsetInMinutes`.
  /// If `reminderOffsetInMinutes` is 0, no repeat notifications are scheduled (only the base notification).
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
        if (prayer.isDone) continue; // Skip completed prayers

        final time = prayer.time;
        if (time == null) continue;

        // Base prayer time
        final baseTime = time;

        // Always schedule initial notification
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

        // Schedule repeats at the interval configured in settings if interval > 0
        if (intervalMinutes > 0) {
          // Schedules 3 repeat intervals after prayer time
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
      payload: payload,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
