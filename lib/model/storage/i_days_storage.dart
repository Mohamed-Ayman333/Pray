import 'package:pray/model/types/day.dart';

abstract class IDaysStorage {
  Future<void> save(Day day);
  Future<Day?> load(DateTime date);
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate);
}
