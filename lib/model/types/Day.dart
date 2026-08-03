import 'package:pray/model/types/Prayer.dart';

class Day {
  //will think if it should stay a string or become a date type
  final DateTime date;
  final List<Prayer> prayers;

  Day(this.date, this.prayers);



}