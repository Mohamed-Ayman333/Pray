import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/days_controller.dart';
import '../../controller/settings_controller.dart';
import '../theme/app_colors.dart';
import '../home/widgets/theme_toggle_button.dart';

class PrayerCalendarPage extends StatefulWidget {
  const PrayerCalendarPage({super.key});

  @override
  State<PrayerCalendarPage> createState() => PrayerCalendarPageState();
}

class PrayerCalendarPageState extends State<PrayerCalendarPage> {
  late DateTime _selectedMonth;
  DateTime? _selectedDayForQada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime.utc(now.year, now.month, 1);
  }

  /// Explicit reset method called when switching tabs or resetting view.
  void resetView() {
    if (_selectedDayForQada != null) {
      setState(() {
        _selectedDayForQada = null;
      });
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await context.read<DaysController>().loadMonth(_selectedMonth);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _selectedMonth = DateTime.utc(newMonth.year, newMonth.month, 1);
      _selectedDayForQada = null;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final daysController = context.watch<DaysController>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeColors = theme.extension<PrayerThemeColors>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
            _buildPageHeader(context, colorScheme, themeColors),
            const SizedBox(height: 20),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_selectedDayForQada != null)
              _buildMissedPrayersDetail(
                context,
                _selectedDayForQada!,
                daysController,
                colorScheme,
                themeColors,
              )
            else
              _buildCalendarGrid(
                context,
                daysController,
                colorScheme,
                themeColors,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(
    BuildContext context,
    ColorScheme colorScheme,
    PrayerThemeColors themeColors,
  ) {
    final titleText = _selectedDayForQada != null
        ? 'Missed Prayers (Qada)'
        : 'Prayer History';

    final subtitleText = _selectedDayForQada != null
        ? DateFormat('EEEE, d MMM yyyy').format(_selectedDayForQada!)
        : null;

    return Row(
      children: [
        if (_selectedDayForQada != null) ...[
          InkWell(
            onTap: () => setState(() => _selectedDayForQada = null),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (subtitleText != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_selectedDayForQada == null)
          _buildMonthDropdown(context, colorScheme),
      ],
    );
  }

  Widget _buildMonthDropdown(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: PopupMenuButton<DateTime>(
        initialValue: _selectedMonth,
        onSelected: _onMonthChanged,
        offset: const Offset(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        itemBuilder: (context) {
          final now = DateTime.now();
          return List.generate(12, (index) {
            final date = DateTime.utc(now.year, now.month - index, 1);
            return PopupMenuItem<DateTime>(
              value: date,
              child: Text(DateFormat('MMMM yyyy').format(date)),
            );
          });
        },
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    DaysController daysController,
    ColorScheme colorScheme,
    PrayerThemeColors themeColors,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;

    final firstWeekday = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    ).weekday;

    const weekDays = ['S', 'S', 'M', 'T', 'W', 'T', 'F'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday % 7);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayNum = dayOffset + 1;
              final cellDate = DateTime.utc(
                _selectedMonth.year,
                _selectedMonth.month,
                dayNum,
              );

              final isToday = cellDate.isAtSameMomentAs(today);
              final isFuture = cellDate.isAfter(today);

              final missedCount = isFuture
                  ? 0
                  : daysController.getMissedPrayersCount(cellDate);

              final isCompleted = !isFuture && missedCount == 0;

              return InkWell(
                onTap: () {
                  if (missedCount > 0) {
                    setState(() => _selectedDayForQada = cellDate);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? colorScheme.secondaryContainer.withValues(alpha: 0.4)
                        : (missedCount > 0
                              ? (themeColors.errorContainer ??
                                    colorScheme.errorContainer)
                              : colorScheme.surfaceContainerHigh.withValues(
                                  alpha: 0.5,
                                )),
                    borderRadius: BorderRadius.circular(12),
                    border: isToday
                        ? Border.all(color: colorScheme.secondary, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isFuture
                              ? theme.disabledColor
                              : (missedCount > 0
                                    ? colorScheme.error
                                    : colorScheme.onSurface),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondary,
                            ),
                          ),
                        )
                      else if (missedCount > 0)
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: colorScheme.error,
                          child: Text(
                            '$missedCount',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onError,
                            ),
                          ),
                        )
                      else if (isCompleted)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: themeColors.prayerDone ?? Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMissedPrayersDetail(
    BuildContext context,
    DateTime date,
    DaysController daysController,
    ColorScheme colorScheme,
    PrayerThemeColors themeColors,
  ) {
    final dayData = daysController.getDay(date);
    final pendingPrayers = dayData?.pendingPrayers ?? [];

    if (pendingPrayers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedDayForQada = null);
      });
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Missed Prayers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: themeColors.errorContainer ?? colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${pendingPrayers.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pendingPrayers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final prayer = pendingPrayers[index];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    prayer.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await daysController.togglePrayer(date, prayer.name);
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Mark Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          themeColors.prayerDone ?? colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
