import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'calendar/calendar_page.dart';
import 'home/home_page.dart';
import 'settings/settings_page.dart';
import 'widgets/battery_exemption_prompt.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final GlobalKey<PrayerCalendarPageState> _calendarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final List<Widget> pages = [
      const HomePage(),
      PrayerCalendarPage(key: _calendarKey),
      const SettingsPage(),
    ];

    return BatteryExemptionPrompt(
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: pages),
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
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (_selectedIndex != index) {
                _calendarKey.currentState?.resetView();
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.mosque_outlined),
                selectedIcon: const Icon(Icons.mosque),
                label: l10n.navPrayers,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: l10n.navCalendar,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n.settingsTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
