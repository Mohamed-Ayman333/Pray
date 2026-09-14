part of '../home_page.dart';

class DaysTable extends StatelessWidget {
  final DaysController daysController;

  const DaysTable({super.key, required this.daysController});

  @override
  Widget build(BuildContext context) {
    final loadedDays = daysController.loadedDays;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final today = DateTime.now();
    final todayTruncated = DateTime(today.year, today.month, today.day);

    // Filter starting from Today up to next 30 days
    final displayDates = List.generate(31, (index) {
      return todayTruncated.add(Duration(days: index));
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

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              0: const FixedColumnWidth(100), // Fixed Prayer Name Column
              for (int i = 1; i <= displayDates.length; i++)
                i: const FixedColumnWidth(80), // Fixed width per day column
            },
            children: [
              // Row 1: Header (PRAYER, 14 MAR, 15 MAR ... next 30 days)
              TableRow(
                decoration: BoxDecoration(color: headerBg),
                children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('PRAYER', style: _headerStyle),
                    ),
                  ),
                  ...displayDates.map(
                    (date) => TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          dateFormat.format(date).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC89B3C), // Gold accent
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Data Rows
              ...prayerRows.map((prayerName) {
                return TableRow(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: dividerColor)),
                  ),
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          prayerName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textStyleColor,
                          ),
                        ),
                      ),
                    ),
                    ...displayDates.map((date) {
                      final Day? dayData = loadedDays[date];
                      if (dayData == null) {
                        return TableCell(
                          child: Text(
                            '--',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textStyleColor),
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

                      return TableCell(
                        child: Text(
                          prayerTime != null
                              ? timeFormat.format(prayerTime)
                              : '--',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
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
