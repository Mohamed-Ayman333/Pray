import 'package:isar/isar.dart';
import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class LocalDaysStorage implements IDaysStorage {
  final Isar isar;

  LocalDaysStorage(this.isar);

  Day? _optimizeDay(Day day) {
    if (day.date == null) return day;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayDate = DateTime(day.date!.year, day.date!.month, day.date!.day);

    if (dayDate.isBefore(today)) {
      day.prayers = day.completedPrayers;
    }

    if (dayDate.isBefore(today) && day.prayers.isEmpty) {
      return null;
    }

    return day;
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
        for (final date in datesToDelete) {
          await isar.days.filter().dateEqualTo(date).deleteAll();
        }
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
