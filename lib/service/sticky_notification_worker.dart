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

/// Reserved notification ID for the "currently pending prayer" sticky.
///
/// Picked well outside the 0..59 range used by the scheduled prayer
/// notifications, so it can never collide with a future-scheduled reminder.
/// The app also cancels this ID whenever it re-syncs, so the state stays
/// consistent across app launches.
const int stickyRepostId = 999999;

const String _channelId = 'prayer_channel_v2';
const String _androidSound = 'adhan';
const String _workerTaskName = 'stickyNotificationCheck';

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
    // Always return true — returning false would trigger WorkManager retry
    // storms, and there's nothing productive about retrying a check that
    // already fails gracefully.
    return true;
  });
}

Future<void> _runWorker() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezones aren't strictly needed for the worker logic, but the
  // notification plugin touches tz internally, so set it up to be safe.
  tz.initializeTimeZones();
  try {
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
  } catch (e) {
    debugPrint('[sticky-worker] timezone setup failed: $e');
  }

  // Isar may already be open if the main app is running in the same process.
  final isar = Isar.getInstance() ?? await AppDatabase.init();
  final core = await buildAppCore(isar);
  final settings = core.settingsController.currentSettings;

  final now = DateTime.now();
  final todayUtc = DateTime.utc(now.year, now.month, now.day);
  final today = await core.daysRepository.load(todayUtc);

  // Prepare the notifications plugin for this isolate.
  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
  await plugin.initialize(const InitializationSettings(android: androidInit));

  // Ensure the channel exists in case the app was never fully launched.
  // createNotificationChannel is a no-op if the channel already exists.
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

/// Shared logic used by both the background worker and the foreground
/// notification sync flow.
///
/// Ensures that the *currently pending prayer* (the latest prayer today whose
/// time has passed and hasn't been marked done) has a visible sticky
/// notification. If no such prayer exists, cancels any lingering repost.
Future<void> ensureStickyVisible({
  required FlutterLocalNotificationsPlugin plugin,
  required List<Day> loadedDays,
  required Settings settings,
}) async {
  // Feature off → make sure nothing lingers.
  if (!settings.notifications || !settings.stickyNotifications) {
    await plugin.cancel(stickyRepostId);
    return;
  }

  final now = DateTime.now();

  // Find today's Day entry. `d.date` is UTC midnight of the local day.
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

  // Find the LATEST prayer that (a) has passed and (b) is not marked done.
  // Sunrise is skipped because it doesn't get a sticky reminder by design.
  Prayer? candidate;
  for (final prayer in today.prayers) {
    if (prayer.name.toLowerCase() == 'sunrise') continue;
    if (prayer.isDone) continue;
    final t = prayer.time;
    if (t == null || t.isAfter(now)) continue;
    candidate = prayer;
  }

  if (candidate == null) {
    debugPrint('[sticky] no pending prayer — cancelling repost');
    await plugin.cancel(stickyRepostId);
    return;
  }

  // Payload format must match the one used in NotificationService.
  final expectedPayload = '${today.date?.toIso8601String()}|${candidate.name}';

  // Is a notification already showing for this exact prayer?
  final androidImpl = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  final active = await androidImpl?.getActiveNotifications() ?? const [];
  final alreadyShowing = active.any((n) => n.payload == expectedPayload);

  if (alreadyShowing) {
    debugPrint('[sticky] ${candidate.name} still active — nothing to do');
    return;
  }

  // Resolve localizations from the user's chosen language.
  AppLocalizations l10n;
  try {
    l10n = lookupAppLocalizations(Locale(settings.language.name));
  } catch (_) {
    l10n = lookupAppLocalizations(const Locale('en'));
  }

  final displayName = l10n.prayerDisplayName(candidate.name);
  debugPrint('[sticky] reposting sticky for ${candidate.name}');

  await plugin.show(
    stickyRepostId,
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
    payload: expectedPayload,
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
