import 'package:isar/isar.dart';
import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class LocalDaysStorage implements IDaysStorage {
  final Isar isar;

  LocalDaysStorage(this.isar);

  Day? _optimizeDay(Day originalDay) {
    if (originalDay.date == null) return originalDay;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayDate = DateTime(
      originalDay.date!.year,
      originalDay.date!.month,
      originalDay.date!.day,
    );

    if (dayDate.isBefore(today)) {
      final pending = originalDay.pendingPrayers;

      if (pending.isEmpty) {
        return Day(date: originalDay.date, prayers: const [])
          ..id = originalDay.id;
      }

      return Day(date: originalDay.date, prayers: List.from(pending))
        ..id = originalDay.id;
    }

    return originalDay;
  }

  @override
  Future<void> save(Day day) async {
    final optimized = _optimizeDay(day);

    await isar.writeTxn(() async {
      if (optimized == null) {
        if (day.date != null) {
          await isar.days.filter().dateEqualTo(day.date!).deleteAll();
        }
      } else {
        await isar.days.put(optimized);
      }
    });
  }

  @override
  Future<void> saveAll(List<Day> days) async {
    final List<Day> daysToSave = [];
    final List<DateTime> datesToDelete = [];

    for (final day in days) {
      final optimized = _optimizeDay(day);
      if (optimized != null) {
        daysToSave.add(optimized);
      } else if (day.date != null) {
        datesToDelete.add(day.date!);
      }
    }

    await isar.writeTxn(() async {
      if (datesToDelete.isNotEmpty) {
        await isar.days
            .filter()
            .anyOf(datesToDelete, (q, DateTime d) => q.dateEqualTo(d))
            .deleteAll();
      }

      if (daysToSave.isNotEmpty) {
        await isar.days.putAll(daysToSave);
      }
    });
  }

  @override
  Future<Day?> load(DateTime date) async {
    return await isar.days.filter().dateEqualTo(date).findFirst();
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    return await isar.days.filter().dateBetween(startDate, endDate).findAll();
  }
}
