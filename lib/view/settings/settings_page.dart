import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/settings_controller.dart';
import '../../model/types/language.dart';
import '../home/widgets/theme_toggle_button.dart';

part 'widgets/settings_section_card.dart';
part 'widgets/settings_segmented_control.dart';
part 'widgets/settings_stepper.dart';
part 'widgets/settings_switch_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// Helper method to format enum values into user-friendly titles
  String _formatMethodName(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.muslim_world_league:
        return 'Muslim World League';
      case CalculationMethod.egyptian:
        return 'Egyptian General Authority';
      case CalculationMethod.karachi:
        return 'University of Islamic Sciences, Karachi';
      case CalculationMethod.umm_al_qura:
        return 'Umm Al-Qura University, Makkah';
      case CalculationMethod.dubai:
        return 'Dubai';
      case CalculationMethod.moon_sighting_committee:
        return 'Moonsighting Committee';
      case CalculationMethod.north_america:
        return 'ISNA (North America)';
      case CalculationMethod.kuwait:
        return 'Kuwait';
      case CalculationMethod.qatar:
        return 'Qatar';
      case CalculationMethod.singapore:
        return 'Singapore';
      case CalculationMethod.tehran:
        return 'Institute of Geophysics, Tehran';
      case CalculationMethod.turkey:
        return 'Diyanet İşleri Başkanlığı, Turkey';
      case CalculationMethod.other:
        return 'Other / Custom';
    }
  }

  void _showCalculationMethodPicker(
    BuildContext context,
    SettingsController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalContext) {
        final colorScheme = Theme.of(modalContext).colorScheme;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                // Handle bar indicator
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calculation Method',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(modalContext).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: CalculationMethod.values.length,
                    itemBuilder: (context, index) {
                      final method = CalculationMethod.values[index];
                      final isSelected = controller.calculationMethod == method;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 4,
                        ),
                        title: Text(
                          _formatMethodName(method),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          method.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          controller.updateCalculationMethod(method);
                          Navigator.of(modalContext).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    if (!settingsController.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              onToggleTheme: () => settingsController.setDarkMode(
                !settingsController.isDarkMode,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Preferences & Prayer Calculation',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 1: Calculation & Jurisprudence
            SettingsSectionCard(
              title: 'Calculation & Jurisprudence',
              icon: Icons.menu_book_rounded,
              children: [
                InkWell(
                  onTap: () =>
                      _showCalculationMethodPicker(context, settingsController),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CALCULATION METHOD',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMethodName(
                                  settingsController.calculationMethod,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Jurisprudence School',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SettingsSegmentedControl<Madhab>(
                      selectedValue: settingsController.madhab,
                      items: const [
                        SegmentItem(
                          value: Madhab.shafi,
                          label: 'Standard (Shafi, Hanbali, Maliki)',
                          icon: Icons.check,
                        ),
                        SegmentItem(
                          value: Madhab.hanafi,
                          label: 'Hanafi (Shadow 2x)',
                        ),
                      ],
                      onChanged: (madhab) =>
                          settingsController.updateMadhab(madhab),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section 2: Notifications
            SettingsSectionCard(
              title: 'Notifications & Alerts',
              icon: Icons.notifications_active_rounded,
              children: [
                SettingsSwitchTile(
                  title: 'Notifications',
                  subtitle: 'Enable prayer alerts & reminders',
                  value: settingsController.notifications,
                  onChanged: (val) =>
                      settingsController.toggleNotifications(val),
                ),
                const SizedBox(height: 8),
                SettingsSwitchTile(
                  title: 'Sticky Notifications',
                  subtitle: 'Persistent countdown widget in notification bar',
                  value: settingsController.stickyNotifications,
                  onChanged: (val) =>
                      settingsController.toggleStickyNotifications(val),
                ),
                const SizedBox(height: 8),
                SettingsSwitchTile(
                  title: 'Repeat Notification Sound',
                  subtitle: 'Loop the alert sound until you dismiss it',
                  value: settingsController.repeatNotifications,
                  onChanged: (val) =>
                      settingsController.toggleRepeatNotifications(val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section 3: Language
            SettingsSectionCard(
              title: 'Language',
              icon: Icons.translate_rounded,
              children: [
                SettingsSegmentedControl<Language>(
                  selectedValue: settingsController.language,
                  items: const [
                    SegmentItem(
                      value: Language.en,
                      label: 'English',
                      icon: Icons.check,
                    ),
                    SegmentItem(value: Language.ar, label: 'Arabic'),
                  ],
                  onChanged: (lang) => settingsController.updateLanguage(lang),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section 4: Values & Adjustments
            SettingsSectionCard(
              title: 'Values & Adjustments',
              icon: Icons.tune_rounded,
              children: [
                SettingsStepper(
                  title: 'Optional Prayer Counter Daily Auto-Increment',
                  subtitle: null,
                  valueText:
                      '+${settingsController.autoIncrementOptionalPrayerCounterBy}',
                  onIncrement: () =>
                      settingsController.incrementAutoIncrementValue(),
                  onDecrement: () =>
                      settingsController.decrementAutoIncrementValue(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section 5: Appearance & Theme
            SettingsSectionCard(
              title: 'Appearance & Theme',
              icon: Icons.palette_outlined,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'THEME MODE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SettingsSegmentedControl<bool>(
                      selectedValue: settingsController.isDarkMode,
                      items: const [
                        SegmentItem(
                          value: false,
                          label: 'Light',
                          icon: Icons.wb_sunny_outlined,
                        ),
                        SegmentItem(
                          value: true,
                          label: 'Dark',
                          icon: Icons.nightlight_round_outlined,
                        ),
                      ],
                      onChanged: (isDark) =>
                          settingsController.setDarkMode(isDark),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
