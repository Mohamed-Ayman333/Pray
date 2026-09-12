import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pray/controller/days_controller.dart';
import 'package:pray/controller/settings_controller.dart';
import 'package:pray/controller/user_state_controller.dart';
import 'package:pray/view/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _is30DayView = false; // Local toggle for view switcher

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // 1. Theme and Color Scheme access
    final colorScheme = Theme.of(context).colorScheme;
    final prayerColors = Theme.of(context).extension<PrayerThemeColors>()!;

    // 2. Controllers Access
    final userStateController = context.watch<UserStateController>();
    final daysController = context.watch<DaysController>();
    final settingsController = context.read<SettingsController>();

    final currentDay = daysController.getDay(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        actions: [
          // Theme Toggle Button
          IconButton(
            icon: Icon(
              settingsController.currentSettings.darkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final isDark = settingsController.currentSettings.darkMode;
              settingsController.toggleDarkMode(!isDark);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to Settings Page
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // Navigate to Calendar Page
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // --- VIEW SWITCHER TOGGLE ---
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Day View')),
              ButtonSegment(value: true, label: Text('30-Day View')),
            ],
            selected: {_is30DayView},
            onSelectionChanged: (newSelection) {
              setState(() {
                _is30DayView = newSelection.first;
              });
            },
          ),

          const SizedBox(height: 16),

          // --- MAIN PRAYER TIMES LIST / TABLE ---
          Expanded(
            child: _is30DayView
                ? _build30DayTableView(context, prayerColors)
                : _buildDayView(context, currentDay, prayerColors),
          ),

          // --- OPTIONAL PRAYER COUNTER AT BOTTOM ---
          Card(
            margin: const EdgeInsets.all(16.0),
            color: colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Optional Counter',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => context
                            .read<UserStateController>()
                            .decrementOptionalPrayer(),
                      ),
                      Text(
                        '${userStateController.currentUserState.optionalPrayerCounter}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => context
                            .read<UserStateController>()
                            .incrementOptionalPrayer(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Day View Layout (List of Prayer Tiles)
  Widget _buildDayView(
    BuildContext context,
    dynamic day,
    PrayerThemeColors prayerColors,
  ) {
    if (day == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: day.prayers.length,
      itemBuilder: (context, index) {
        final prayer = day.prayers[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: Theme.of(context).colorScheme.surface,
          child: ListTile(
            title: Text(
              prayer.name,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              '${prayer.time.hour.toString().padLeft(2, '0')}:${prayer.time.minute.toString().padLeft(2, '0')}',
            ),
            trailing: Checkbox(
              value: prayer.isDone,
              activeColor: prayerColors.prayerDone,
              onChanged: (_) {
                context.read<DaysController>().togglePrayer(
                  day.date!,
                  prayer.name,
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Placeholder for 30-Day Horizontally Scrollable Table
  Widget _build30DayTableView(
    BuildContext context,
    PrayerThemeColors prayerColors,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          '30-Day Table View Container',
          style: TextStyle(color: prayerColors.calendarActiveHighlight),
        ),
      ),
    );
  }
}
