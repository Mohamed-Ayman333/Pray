part of '../home_page.dart';

class HeaderCard extends StatelessWidget {
  final Prayer? nextPrayer;
  final Duration timeUntilNext;
  final PrayerThemeColors themeColors;

  const HeaderCard({
    super.key,
    required this.nextPrayer,
    required this.timeUntilNext,
    required this.themeColors,
  });

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    if (nextPrayer == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('hh:mm a');
    final formattedTime = nextPrayer!.time != null
        ? timeFormat.format(nextPrayer!.time!)
        : '--:--';

    final primaryTextColor = isDark
        ? Colors.white
        : themeColors.nextPrayerBorder;
    final secondaryTextColor = isDark
        ? const Color(0xFFA0AEC0)
        : const Color(0xFF4A5568);
    final timeTextColor = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF191C1B);
    final cardBgColor = isDark
        ? const Color(0xFF1E293B)
        : themeColors.nextPrayerBackground;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 12, color: primaryTextColor),
              const SizedBox(width: 8),
              Text(
                'COMING NEXT',
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextPrayer!.name,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: timeTextColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Countdown',
                    style: TextStyle(fontSize: 14, color: secondaryTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _printDuration(timeUntilNext),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
