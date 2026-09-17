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
import 'package:pray/l10n/app_localizations.dart';
import 'package:pray/l10n/app_localizations_extension.dart';
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

/// Resolves the correct generated [AppLocalizations] instance for a locale
/// name ('en' or 'ar'). Used outside of a widget tree (e.g. from the
/// notification service) where `AppLocalizations.of(context)` isn't
/// available.
AppLocalizations _resolveL10n(String localeName) {
  try {
    return lookupAppLocalizations(Locale(localeName));
  } catch (_) {
    return lookupAppLocalizations(const Locale('en'));
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  static const String _channelId = 'prayer_channel_v2';

  static const String _androidSound = 'adhan';
  static const String _iosSound = 'adhan.caf';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init({
    required Function(NotificationResponse) onNotificationResponse,
    String localeName = 'en',
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

    // ---- Localizations ----
    final l10n = _resolveL10n(localeName);

    // ---- Init settings ----
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    final iosCategories = [
      DarwinNotificationCategory(
        'PRAYER_CATEGORY',
        actions: [
          // No `foreground` option → the action is handled silently in the
          // background without bringing the app to the foreground.
          DarwinNotificationAction.plain(
            'mark_done_action',
            l10n.notifMarkDone,
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
      final channel = AndroidNotificationChannel(
        _channelId,
        l10n.notifChannelName,
        description: l10n.notifChannelDescription,
        importance: Importance.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound(_androidSound),
        enableVibration: true,
      );
      await androidImplementation.createNotificationChannel(channel);
      debugPrint('[notif] channel created: $_channelId (sound=$_androidSound)');

      final bool? notifGranted = await androidImplementation
          .requestNotificationsPermission();
      debugPrint('[notif] notifications permission granted: $notifGranted');

      final bool? exactGranted = await androidImplementation
          .requestExactAlarmsPermission();
      debugPrint('[notif] exact alarm permission granted: $exactGranted');
    }

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

    final l10n = _resolveL10n(settings.language.name);

    int notificationId = 0;
    final now = DateTime.now();
    final repeatSound = settings.repeatNotifications;
    int scheduled = 0;

    for (final day in days) {
      for (final prayer in day.prayers) {
        if (prayer.isDone) continue;

        final time = prayer.time;
        if (time == null || !time.isAfter(now)) continue;

        try {
          final displayName = l10n.prayerDisplayName(prayer.name);
          await _scheduleSingleNotification(
            id: notificationId++,
            title: l10n.notifTimeFor(displayName),
            body: l10n.notifItIsTimeFor(displayName),
            scheduledTime: time,
            settings: settings,
            payload: '${day.date?.toIso8601String()}|${prayer.name}',
            repeatSound: repeatSound,
            l10n: l10n,
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
    required AppLocalizations l10n,
    bool repeatSound = false,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.notifChannelName,
        channelDescription: l10n.notifChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound(_androidSound),
        ongoing: settings.stickyNotifications,
        autoCancel: !settings.stickyNotifications,
        additionalFlags: repeatSound ? Int32List.fromList(<int>[4]) : null,
        actions: [
          AndroidNotificationAction(
            'mark_done_action',
            l10n.notifMarkDone,
            // 👇 false = handle silently in the background, don't launch
            //    the app. The action is delivered to
            //    `notificationTapBackground` instead of the foreground
            //    `onNotificationResponse` callback.
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: 'PRAYER_CATEGORY',
        sound: _iosSound,
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
