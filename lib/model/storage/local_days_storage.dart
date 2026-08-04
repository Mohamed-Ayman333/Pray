import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class LocalDaysStorage implements IDaysStorage {
  @override
  Future<void> save(Day day) async {
    // TODO: Save 'day' to local DB (Isar / Hive / sqflite)
  }

  @override
  Future<Day?> load(DateTime date) async {
    // TODO: Query local DB by date
    return null;
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    // TODO: Query local DB for date range
    return [];
  }
}
