import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Day;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:isar/isar.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'package:pray/core/app_core.dart';
import 'package:pray/l10n/app_localizations.dart';
import 'package:pray/l10n/app_localizations_extension.dart';
import 'package:pray/model/storage/app_database.dart';
import 'package:pray/model/types/day.dart';
import 'package:pray/model/types/prayer.dart';
import 'package:pray/model/types/settings.dart';

const String _channelId = 'prayer_channel_v2';
const String _androidSound = 'adhan';
const String _workerTaskName = 'stickyNotificationCheck';

/// Deterministic notification ID derived from the payload.
///
/// Both the scheduled notification AND the sticky repost compute the same
/// ID for the same prayer+date, so if both ever fire simultaneously the
/// system REPLACES the older one instead of showing two copies.
///
/// Uses FNV-1a (32-bit) because `String.hashCode` is not guaranteed to be
/// stable across Dart runtimes/isolates, which we rely on since the worker
/// runs in a separate isolate from the foreground app.
int notificationIdForPayload(String payload) {
  var hash = 0x811C9DC5;
  for (var i = 0; i < payload.length; i++) {
    hash ^= payload.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  // Mask to 31 bits so the ID is always positive — Android rejects negative
  // notification IDs.
  return hash & 0x7FFFFFFF;
}

/// WorkManager background dispatcher. Must be a top-level function and
/// annotated with @pragma('vm:entry-point') so it survives AOT compilation.
@pragma('vm:entry-point')
void stickyNotificationWorkerDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('[sticky-worker] task=$task fired');
    try {
      await _runWorker();
    } catch (e, st) {
      debugPrint('[sticky-worker] error: $e\n$st');
    }
    // Always return true — returning false triggers WorkManager retries.
    return true;
  });
}

Future<void> _runWorker() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  try {
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
  } catch (e) {
    debugPrint('[sticky-worker] timezone setup failed: $e');
  }

  final isar = Isar.getInstance() ?? await AppDatabase.init();
  final core = await buildAppCore(isar);
  final settings = core.settingsController.currentSettings;

  final now = DateTime.now();
  final todayUtc = DateTime.utc(now.year, now.month, now.day);
  final today = await core.daysRepository.load(todayUtc);

  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
  await plugin.initialize(const InitializationSettings(android: androidInit));

  final androidImpl = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (androidImpl != null) {
    const channel = AndroidNotificationChannel(
      _channelId,
      'Prayer Reminders',
      description: 'Notifications for upcoming prayer times',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_androidSound),
      enableVibration: true,
    );
    await androidImpl.createNotificationChannel(channel);
  }

  await ensureStickyVisible(
    plugin: plugin,
    loadedDays: today != null ? [today] : const [],
    settings: settings,
  );
}

/// Ensures the *currently pending prayer* has a visible notification.
///
/// "Currently pending" = the latest prayer today whose time has already
/// passed and that hasn't been marked done. If it's already on screen
/// (by ID), we do nothing. Otherwise we repost it with the same
/// deterministic ID used when it was originally scheduled.
Future<void> ensureStickyVisible({
  required FlutterLocalNotificationsPlugin plugin,
  required List<Day> loadedDays,
  required Settings settings,
}) async {
  if (!settings.notifications || !settings.stickyNotifications) {
    debugPrint('[sticky] feature disabled — skipping');
    return;
  }

  final now = DateTime.now();

  Day? today;
  for (final d in loadedDays) {
    final dd = d.date;
    if (dd == null) continue;
    if (dd.year == now.year && dd.month == now.month && dd.day == now.day) {
      today = d;
      break;
    }
  }
  if (today == null) {
    debugPrint('[sticky] no today data, nothing to do');
    return;
  }

  // Find the LATEST prayer today that has passed and isn't done.
  Prayer? candidate;
  for (final prayer in today.prayers) {
    if (prayer.name.toLowerCase() == 'sunrise') continue;
    if (prayer.isDone) continue;
    final t = prayer.time;
    if (t == null || t.isAfter(now)) continue;
    candidate = prayer;
  }
  if (candidate == null) {
    debugPrint('[sticky] no pending prayer — nothing to do');
    return;
  }

  final payload = '${today.date?.toIso8601String()}|${candidate.name}';
  final id = notificationIdForPayload(payload);

  // Check whether a notification with this exact ID is already showing.
  final androidImpl = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  final active = await androidImpl?.getActiveNotifications() ?? const [];
  final alreadyShowing = active.any((n) => n.id == id);

  if (alreadyShowing) {
    debugPrint(
      '[sticky] ${candidate.name} (id=$id) already active — skipping repost',
    );
    return;
  }

  AppLocalizations l10n;
  try {
    l10n = lookupAppLocalizations(Locale(settings.language.name));
  } catch (_) {
    l10n = lookupAppLocalizations(const Locale('en'));
  }

  final displayName = l10n.prayerDisplayName(candidate.name);
  debugPrint('[sticky] reposting ${candidate.name} (id=$id)');

  await plugin.show(
    id,
    l10n.notifTimeFor(displayName),
    l10n.notifItIsTimeFor(displayName),
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.notifChannelName,
        channelDescription: l10n.notifChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound(_androidSound),
        ongoing: true,
        autoCancel: false,
        additionalFlags: settings.repeatNotifications
            ? Int32List.fromList(<int>[4])
            : null,
        actions: [
          AndroidNotificationAction(
            'mark_done_action',
            l10n.notifMarkDone,
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
    ),
    payload: payload,
  );
}

/// Registers the periodic WorkManager task. Safe to call on every app launch
/// thanks to [ExistingWorkPolicy.keep].
Future<void> registerStickyNotificationWorker() async {
  try {
    await Workmanager().registerPeriodicTask(
      _workerTaskName,
      _workerTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
    debugPrint('[sticky] worker registered');
  } catch (e) {
    debugPrint('[sticky] failed to register worker: $e');
  }
}
