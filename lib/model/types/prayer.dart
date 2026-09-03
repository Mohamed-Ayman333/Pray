import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prayer.g.dart';

@embedded
@JsonSerializable()
class Prayer {
  String name;
  DateTime? time;
  bool isDone;

  Prayer({this.name = '', this.time, this.isDone = false});

  factory Prayer.fromJson(Map<String, dynamic> json) => _$PrayerFromJson(json);
  Map<String, dynamic> toJson() => _$PrayerToJson(this);
}
