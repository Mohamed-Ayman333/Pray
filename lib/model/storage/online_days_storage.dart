import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class OnlineDaysStorage implements IDaysStorage {
  @override
  Future<void> save(Day day) async {
    //does nothing for now
  }

  @override
  Future<void> saveAll(List<Day> days) async {
    //does nothing for now
  }

  @override
  Future<Day?> load(DateTime date) async {
    // TODO: Make HTTP GET request to external API for a single date
    // Parse JSON -> convert to Day model -> return
    return null;
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    // TODO: Make HTTP GET request to external API using startDate & endDate query params
    // Parse list JSON -> convert to List<Day> -> return
    return [];
  }
}
