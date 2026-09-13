import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pray/model/types/prayer.dart';

part 'day.g.dart';

@Collection()
@JsonSerializable()
class Day {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  DateTime? date;

  List<Prayer> prayers;

  Day({this.date, this.prayers = const []});

  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);
  Map<String, dynamic> toJson() => _$DayToJson(this);

  @ignore
  List<Prayer> get completedPrayers => prayers.where((p) => p.isDone).toList();

  @ignore
  List<Prayer> get pendingPrayers => prayers.where((p) => !p.isDone).toList();
}
