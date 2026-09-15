part of '../home_page.dart';

class DaysTable extends StatelessWidget {
  final DaysController daysController;

  const DaysTable({super.key, required this.daysController});

  @override
  Widget build(BuildContext context) {
    final loadedDays = daysController.loadedDays;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final today = DateTime.now();
    // Normalize to UTC midnight to match DaysController key format
    final todayTruncated = DateTime.utc(today.year, today.month, today.day);

    final displayDates = List.generate(31, (index) {
      return DateTime.utc(
        todayTruncated.year,
        todayTruncated.month,
        todayTruncated.day + index,
      );
    });

    if (loadedDays.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM');
    final timeFormat = DateFormat('hh:mm');
    final prayerRows = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    final containerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final headerBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F2);
    final dividerColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFEDF1EE);
    final textStyleColor = isDark ? Colors.grey[300] : Colors.grey[700];

    const double rowHeight = 48.0;

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Row(
          children: [
            // Fixed Left Column (Prayer Names)
            Container(
              width: 100,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: dividerColor)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: rowHeight,
                    color: headerBg,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text('PRAYER', style: _headerStyle),
                  ),
                  ...prayerRows.map((prayerName) {
                    return Container(
                      height: rowHeight,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: dividerColor)),
                      ),
                      child: Text(
                        prayerName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textStyleColor,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Scrollable Right Grid (Dates & Times)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dates Header Row
                    Container(
                      height: rowHeight,
                      color: headerBg,
                      child: Row(
                        children: displayDates.map((date) {
                          return SizedBox(
                            width: 80,
                            child: Center(
                              child: Text(
                                dateFormat.format(date).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC89B3C),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Prayer Times Rows
                    ...prayerRows.map((prayerName) {
                      return Container(
                        height: rowHeight,
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: dividerColor)),
                        ),
                        child: Row(
                          children: displayDates.map((date) {
                            final Day? dayData = loadedDays[date];
                            if (dayData == null) {
                              return SizedBox(
                                width: 80,
                                child: Center(
                                  child: Text(
                                    '--',
                                    style: TextStyle(color: textStyleColor),
                                  ),
                                ),
                              );
                            }

                            final Prayer? matchingPrayer = dayData.prayers
                                .cast<Prayer?>()
                                .firstWhere(
                                  (p) =>
                                      p?.name.toLowerCase() ==
                                      prayerName.toLowerCase(),
                                  orElse: () => null,
                                );

                            final DateTime? prayerTime = matchingPrayer?.time;

                            return SizedBox(
                              width: 80,
                              child: Center(
                                child: Text(
                                  prayerTime != null
                                      ? timeFormat.format(prayerTime)
                                      : '--',
                                  style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
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
