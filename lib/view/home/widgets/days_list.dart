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

  @override
  Widget build(BuildContext context) {
    if (dayData == null) {
      return const Center(child: Text("Loading Today's Prayers"));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('hh:mm a');

    final containerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F2);
    final dividerColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFEDF1EE);
    final primaryTextColor = isDark ? Colors.white : Colors.grey[800];
    final timeTextColor = isDark ? Colors.white : Colors.black;

    final items = [
      {'name': 'Fajr', 'icon': Icons.wb_twilight, 'type': 'adhan'},
      {'name': 'Sunrise', 'icon': Icons.wb_sunny_outlined, 'type': 'event'},
      {'name': 'Dhuhr', 'icon': Icons.wb_sunny, 'type': 'adhan'},
      {'name': 'Asr', 'icon': Icons.wb_sunny_rounded, 'type': 'adhan'},
      {'name': 'Maghrib', 'icon': Icons.nightlight_round, 'type': 'adhan'},
      {'name': 'Isha', 'icon': Icons.dark_mode, 'type': 'adhan'},
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
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('PRAYER', style: _headerStyle)),
                Text('TIME', style: _headerStyle),
                SizedBox(width: 24),
                Text('STATUS', style: _headerStyle),
                SizedBox(width: 8),
              ],
            ),
          ),
          ...items.map((item) {
            final prayerName = item['name'] as String;

            final Prayer prayerData = dayData!.prayers.firstWhere(
              (p) =>
                  p.name.trim().toLowerCase() ==
                  prayerName.trim().toLowerCase(),
              orElse: () => Prayer(name: prayerName),
            );

            final isSunrise = prayerName == 'Sunrise';
            final isDone = !isSunrise && prayerData.isDone;

            return GestureDetector(
              onTap: isSunrise
                  ? null
                  : () {
                      final rawDate = dayData!.date ?? DateTime.now();
                      final localDate = rawDate.toLocal();
                      final utcDate = DateTime.utc(
                        localDate.year,
                        localDate.month,
                        localDate.day,
                      );
                      onToggle(utcDate, prayerName);
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: dividerColor)),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        prayerName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    Text(
                      prayerData.time != null
                          ? timeFormat.format(prayerData.time!)
                          : '--:--',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDone ? Colors.green : timeTextColor,
                      ),
                    ),
                    const SizedBox(width: 24),
                    if (!isSunrise)
                      Icon(
                        isDone
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isDone
                            ? Colors.green
                            : (isDark ? Colors.grey[600] : Colors.grey[300]),
                      ),
                    if (isSunrise) const SizedBox(width: 24),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 11,
    letterSpacing: 0.5,
    fontWeight: FontWeight.bold,
    color: Color(0xFF94A3B8),
  );
}
