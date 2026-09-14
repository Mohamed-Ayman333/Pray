import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controller/days_controller.dart';
import '../../controller/settings_controller.dart';
import '../../controller/user_state_controller.dart';
import '../../model/types/day.dart';
import '../../model/types/prayer.dart';
import '../theme/app_colors.dart';

part 'widgets/header_card.dart';
part 'widgets/view_switcher.dart';
part 'widgets/days_list.dart';
part 'widgets/days_table.dart';
part 'widgets/optional_prayer_counter.dart';
part 'widgets/theme_toggle_button.dart'; // Added part file

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Local state to track selected view (Day or 30-Day)
  bool _isDayViewSelected = true;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Start periodic timer to refresh countdown in Header
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {}); // Rebuild header to update countdown text
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in controllers
    final daysController = context.watch<DaysController>();
    final settingsController = context.watch<SettingsController>();

    // Safety fallback if database isn't init yet
    if (!settingsController.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final today = DateTime.now();
    final dayData = daysController.getDay(today);

    // Get Next Prayer info safely
    final nextPrayer = daysController.nextPrayer;
    final timeUntilNext = daysController.timeUntilNextPrayer;

    // Utilize colors from ThemeExtension
    final themeColors = Theme.of(context).extension<PrayerThemeColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // 1. App Bar with Logo, Title, and Dark Mode Toggle
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 12),
            Text(
              'Pray',
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
              onToggleTheme: () => settingsController.toggleTheme(),
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
              // 2. Main Next Prayer Header Card
              HeaderCard(
                nextPrayer: nextPrayer,
                timeUntilNext: timeUntilNext,
                themeColors: themeColors,
              ),
              const SizedBox(height: 24),

              // 3. View Switcher Toggle Button Group
              ViewSwitcher(
                isDayViewSelected: _isDayViewSelected,
                onViewChanged: (isDayView) {
                  setState(() => _isDayViewSelected = isDayView);
                  // Load 30 days if user switches to table view
                  if (!isDayView) daysController.loadNext30Days();
                },
              ),
              const SizedBox(height: 24),

              // 4. Content Area: Toggle between List and Table
              _isDayViewSelected
                  ? DaysList(
                      dayData: dayData,
                      themeColors: themeColors,
                      onToggle: daysController.togglePrayer,
                    )
                  : DaysTable(daysController: daysController),

              const SizedBox(height: 24),

              // 5. Optional Prayer Counter Segment
              const OptionalPrayerCounter(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      // 6. Material 3 Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (index) {
            // Handle navigation tab changes
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.mosque_outlined),
              selectedIcon: Icon(Icons.mosque),
              label: 'Prayers',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
