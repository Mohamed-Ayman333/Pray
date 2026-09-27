part of '../home_page.dart';

class DaysList extends StatelessWidget {
  final Day? dayData;
  final PrayerThemeColors themeColors;
  final Function(DateTime, String) onToggle;

  const DaysList({
    super.key,
    required this.dayData,
    required this.themeColors,
    required this.onToggle,
  });

  /// Hard-coded sunnah rak'ah counts per prayer: (before, after).
  /// Sunrise and Dhuha carry no sunnah. Values to be verified later.
  static const Map<String, (int, int)> _sunnahCounts = {
    'Fajr': (2, 2),
    'Sunrise': (0, 0),
    'Dhuha': (0, 0),
    'Dhuhr': (2, 2),
    'Asr': (2, 2),
    'Maghrib': (2, 2),
    'Isha': (2, 2),
  };

  static const _headerStyle = TextStyle(
    fontSize: 11,
    letterSpacing: 0.5,
    fontWeight: FontWeight.bold,
    color: Color(0xFF94A3B8),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showSunnah = context.watch<SettingsController>().showSunnahPrayers;

    if (dayData == null) {
      return Center(child: Text(l10n.loadingTodaysPrayers));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat('hh:mm a', locale);

    final containerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F2);
    final dividerColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFEDF1EE);
    final primaryTextColor = isDark ? Colors.white : Colors.grey[800];
    final timeTextColor = isDark ? Colors.white : Colors.black;
    final trackColor = isDark ? Colors.grey[600] : Colors.grey[300];
    final mutedColor = isDark ? Colors.grey[500] : Colors.grey[400];

    // Derive Dhuha from sunrise (20 min after).
    final Prayer sunriseData = dayData!.prayers.firstWhere(
      (p) => p.name.trim().toLowerCase() == 'sunrise',
      orElse: () => Prayer(name: 'Sunrise'),
    );
    final dhuhaTime = sunriseData.time?.add(const Duration(minutes: 20));

    final items = <_RowData>[
      const _RowData('Fajr', Icons.wb_twilight),
      const _RowData('Sunrise', Icons.wb_sunny_outlined),
      if (showSunnah) const _RowData('Dhuha', Icons.brightness_5_outlined),
      const _RowData('Dhuhr', Icons.wb_sunny),
      const _RowData('Asr', Icons.wb_sunny_rounded),
      const _RowData('Maghrib', Icons.nightlight_round),
      const _RowData('Isha', Icons.dark_mode),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          showSunnah ? _SunnahHeader(l10n: l10n) : _SimpleHeader(l10n: l10n),
          ...items.map((item) {
            final prayerName = item.name;
            final isSunrise = prayerName == 'Sunrise';
            final isDhuha = prayerName == 'Dhuha';
            final isTracked = !isSunrise && !isDhuha;

            final Prayer prayerData = dayData!.prayers.firstWhere(
              (p) =>
                  p.name.trim().toLowerCase() ==
                  prayerName.trim().toLowerCase(),
              orElse: () => Prayer(name: prayerName),
            );

            final DateTime? displayTime = isDhuha ? dhuhaTime : prayerData.time;
            final isDone = isTracked && prayerData.isDone;

            final VoidCallback? onTap = isTracked
                ? () {
                    final rawDate = dayData!.date ?? DateTime.now();
                    final localDate = rawDate.toLocal();
                    final utcDate = DateTime.utc(
                      localDate.year,
                      localDate.month,
                      localDate.day,
                    );
                    onToggle(utcDate, prayerName);
                  }
                : null;

            if (showSunnah) {
              final counts = _sunnahCounts[prayerName] ?? (0, 0);
              return _SunnahRow(
                l10n: l10n,
                icon: item.icon,
                prayerName: prayerName,
                displayTime: displayTime,
                timeFormat: timeFormat,
                isTracked: isTracked,
                isDone: isDone,
                onTap: onTap,
                dividerColor: dividerColor,
                primaryTextColor: primaryTextColor,
                timeTextColor: timeTextColor,
                mutedColor: mutedColor,
                trackColor: trackColor,
                sunnahBefore: counts.$1,
                sunnahAfter: counts.$2,
              );
            }

            return _SimpleRow(
              l10n: l10n,
              icon: item.icon,
              prayerName: prayerName,
              displayTime: displayTime,
              timeFormat: timeFormat,
              isTracked: isTracked,
              isDone: isDone,
              onTap: onTap,
              dividerColor: dividerColor,
              primaryTextColor: primaryTextColor,
              timeTextColor: timeTextColor,
              mutedColor: mutedColor,
              trackColor: trackColor,
            );
          }),
        ],
      ),
    );
  }
}

class _RowData {
  final String name;
  final IconData icon;
  const _RowData(this.name, this.icon);
}

class _SimpleHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _SimpleHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(l10n.columnPrayer, style: DaysList._headerStyle),
          ),
          Text(l10n.columnTime, style: DaysList._headerStyle),
          const SizedBox(width: 24),
          Text(l10n.columnStatus, style: DaysList._headerStyle),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _SunnahHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _SunnahHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              l10n.sunnahBeforeHeader,
              style: DaysList._headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              l10n.columnPrayer,
              style: DaysList._headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              l10n.sunnahAfterHeader,
              style: DaysList._headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(flex: 3, child: SizedBox()),
        ],
      ),
    );
  }
}

class _SimpleRow extends StatelessWidget {
  final AppLocalizations l10n;
  final IconData icon;
  final String prayerName;
  final DateTime? displayTime;
  final DateFormat timeFormat;
  final bool isTracked;
  final bool isDone;
  final VoidCallback? onTap;
  final Color dividerColor;
  final Color? primaryTextColor;
  final Color timeTextColor;
  final Color? mutedColor;
  final Color? trackColor;

  const _SimpleRow({
    required this.l10n,
    required this.icon,
    required this.prayerName,
    required this.displayTime,
    required this.timeFormat,
    required this.isTracked,
    required this.isDone,
    required this.onTap,
    required this.dividerColor,
    required this.primaryTextColor,
    required this.timeTextColor,
    required this.mutedColor,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor)),
        ),
        child: Row(
          children: [
            Icon(icon, color: mutedColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.prayerDisplayName(prayerName),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ),
            Text(
              displayTime != null ? timeFormat.format(displayTime!) : '--:--',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDone ? Colors.green : timeTextColor,
              ),
            ),
            const SizedBox(width: 24),
            if (isTracked)
              Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? Colors.green : trackColor,
              ),
            if (!isTracked) const SizedBox(width: 24),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _SunnahRow extends StatelessWidget {
  final AppLocalizations l10n;
  final IconData icon;
  final String prayerName;
  final DateTime? displayTime;
  final DateFormat timeFormat;
  final bool isTracked;
  final bool isDone;
  final VoidCallback? onTap;
  final Color dividerColor;
  final Color? primaryTextColor;
  final Color timeTextColor;
  final Color? mutedColor;
  final Color? trackColor;
  final int sunnahBefore;
  final int sunnahAfter;

  const _SunnahRow({
    required this.l10n,
    required this.icon,
    required this.prayerName,
    required this.displayTime,
    required this.timeFormat,
    required this.isTracked,
    required this.isDone,
    required this.onTap,
    required this.dividerColor,
    required this.primaryTextColor,
    required this.timeTextColor,
    required this.mutedColor,
    required this.trackColor,
    required this.sunnahBefore,
    required this.sunnahAfter,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final numberStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w900,
      color: colorScheme.primary,
      fontStyle: FontStyle.italic,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor)),
        ),
        child: Row(
          children: [
            // Sunnah before
            Expanded(
              flex: 3,
              child: Center(
                child: sunnahBefore > 0
                    ? Text('$sunnahBefore', style: numberStyle)
                    : const SizedBox.shrink(),
              ),
            ),
            // Prayer name + time (stacked)
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 16, color: mutedColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.prayerDisplayName(prayerName),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: primaryTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayTime != null
                        ? timeFormat.format(displayTime!)
                        : '--:--',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: timeTextColor,
                    ),
                  ),
                ],
              ),
            ),
            // Sunnah after
            Expanded(
              flex: 3,
              child: Center(
                child: sunnahAfter > 0
                    ? Text('$sunnahAfter', style: numberStyle)
                    : const SizedBox.shrink(),
              ),
            ),
            // Status
            Expanded(
              flex: 3,
              child: Center(
                child: isTracked
                    ? Icon(
                        isDone
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isDone ? Colors.green : trackColor,
                        size: 26,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
