import 'package:pray/model/types/day.dart';

abstract class IDaysStorage {
  Future<void> save(Day day);
  Future<void> saveAll(List<Day> days); // <-- Added batch save method
  Future<Day?> load(DateTime date);
  Future<List<Day>> getInRange(DateTime startDate, DateTime endDate);
}
