import 'package:pray/model/types/prayer.dart';

class Day {

  final DateTime date;
  final List<Prayer> prayers;

  Day({ required this.date, required this.prayers});

  factory Day.fromJson(Map<String, dynamic> json){
  return Day(date: DateTime.parse(json['date'] as String),
    prayers: (json['prayers'] as List<dynamic>?)
        ?.map((prayerJson) => Prayer.fromJson(prayerJson as Map<String, dynamic>))
        .toList()??[],);
  }

  Map<String, dynamic> toJson(){
    return {
      'date': date.toIso8601String(),
      'prayers': prayers.map((prayer) => prayer.toJson()).toList(),
    };
  }



}