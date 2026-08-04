import 'package:pray/model/storage/i_days_storage.dart';
import 'package:pray/model/types/day.dart';

class OnlineDaysStorage implements IDaysStorage {
  @override
  Future<void> save(Day day) async {
    // TODO: Send 'day' to backend REST/GraphQL API
  }

  @override
  Future<Day?> load(DateTime date) async {
    // TODO: Fetch single day from backend API
    return null;
  }

  @override
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate) async {
    // TODO: Fetch date range from backend API
    return [];
  }
}
