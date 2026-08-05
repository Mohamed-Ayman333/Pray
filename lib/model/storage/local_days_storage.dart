import 'package:isar/isar.dart';
import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class LocalDaysStorage implements IDaysStorage {
  final Isar isar;

  LocalDaysStorage(this.isar);

  @override
  Future<void> save(Day day) async {
    await isar.writeTxn(() async {
      await isar.days.put(day);
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

  @override
  Future<void> saveAll(List<Day> days) async {
    await isar.writeTxn(() async {
      await isar.days.putAll(days);
    });
  }
}
