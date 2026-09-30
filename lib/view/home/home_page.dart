import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controller/days_controller.dart';
import '../../controller/settings_controller.dart';
import '../../controller/user_state_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../model/types/day.dart';
import '../../model/types/prayer.dart';
import '../theme/app_colors.dart';
import 'widgets/theme_toggle_button.dart';
import '../../l10n/app_localizations_extension.dart';

part 'widgets/header_card.dart';
part 'widgets/view_switcher.dart';
part 'widgets/days_list.dart';
part 'widgets/days_table.dart';
part 'widgets/optional_prayer_counter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _isDayViewSelected = true;
  Timer? _countdownTimer;
  bool _locationPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check on resume so the banner disappears if the user grants
    // permission from the system settings while the app is backgrounded.
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    final denied = status.isDenied || status.isPermanentlyDenied;
    if (mounted && denied != _locationPermissionDenied) {
      setState(() => _locationPermissionDenied = denied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysController = context.watch<DaysController>();
    final settingsController = context.watch<SettingsController>();
    final l10n = AppLocalizations.of(context);

    if (!settingsController.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final today = DateTime.now();
    final todayNormalized = DateTime.utc(today.year, today.month, today.day);
    final dayData = daysController.getDay(todayNormalized);

    final nextPrayer = daysController.nextPrayer;
    final timeUntilNext = daysController.timeUntilNextPrayer;

    final themeColors = Theme.of(context).extension<PrayerThemeColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo.jpg', height: 32),
            const SizedBox(width: 12),
            Text(
              l10n.appTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ThemeToggleButton(
              isDarkMode: settingsController.isDarkMode,
              onToggleTheme: () => settingsController.setDarkMode(
                !settingsController.isDarkMode,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              if (_locationPermissionDenied) ...[
                _LocationPermissionBanner(
                  message: l10n.locationPermissionFallbackBanner,
                  themeColors: themeColors,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 16),
              ],
              HeaderCard(
                nextPrayer: nextPrayer,
                timeUntilNext: timeUntilNext,
                themeColors: themeColors,
              ),
              const SizedBox(height: 24),
              ViewSwitcher(
                isDayViewSelected: _isDayViewSelected,
                onViewChanged: (isDayView) {
                  setState(() => _isDayViewSelected = isDayView);
                  if (!isDayView) daysController.loadNext30Days();
                },
              ),
              const SizedBox(height: 24),
              _isDayViewSelected
                  ? DaysList(
                      dayData: dayData,
                      themeColors: themeColors,
                      onToggle: daysController.togglePrayer,
                    )
                  : DaysTable(daysController: daysController),
              const SizedBox(height: 24),
              const OptionalPrayerCounter(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationPermissionBanner extends StatelessWidget {
  final String message;
  final PrayerThemeColors themeColors;
  final ColorScheme colorScheme;

  const _LocationPermissionBanner({
    required this.message,
    required this.themeColors,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: themeColors.warningContainer ?? colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_off_rounded,
            color: colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
