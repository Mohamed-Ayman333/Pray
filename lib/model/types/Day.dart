import 'package:pray/model/types/Prayer.dart';

class Day {
  //will think if it should stay a string or become a date type
  String _date;
  List<Prayer> _prayers;

  Day(this._date, this._prayers);

  List<Prayer> get prayers => _prayers;
  String get date => _date;

}