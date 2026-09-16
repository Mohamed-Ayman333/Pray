import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Day;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/settings.dart';
import 'package:pray/model/types/user_state.dart';

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

  /// Schedules prayer notifications and repeating intervals based on settings and user state
  Future<void> schedulePrayerNotifications(
    List<Day> days,
    Settings settings,
    UserState userState,
  ) async {
    await _plugin.cancelAll();

    if (!settings.notifications) return;

    int notificationId = 0;
    final now = DateTime.now();

    // Pull repeat count/interval from user state (defaults to 1 trigger if 0)
    final repeatIntervalMinutes = 15; // Set your default interval step
    final totalRepeats = userState.optionalPrayerCounter > 0
        ? userState.optionalPrayerCounter
        : 1;

    for (final day in days) {
      for (final prayer in day.prayers) {
        if (prayer.isDone) continue; // Skip completed prayers

        final time = prayer.time;
        if (time == null) continue;

        // Base scheduled time with user reminder offset
        final baseTime = time.add(
          Duration(minutes: settings.reminderOffsetInMinutes),
        );

        for (int repeat = 0; repeat < totalRepeats; repeat++) {
          final scheduledTime = baseTime.add(
            Duration(minutes: repeat * repeatIntervalMinutes),
          );

          if (scheduledTime.isAfter(now)) {
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
              payload: '${day.date?.toIso8601String()}|${prayer.name}',
            );
          }
        }
      }
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
