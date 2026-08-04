import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pray/model/types/prayer.dart';

part 'day.freezed.dart';
part 'day.g.dart';

@freezed
abstract class Day with _$Day {
  const Day._();

  const factory Day({DateTime? date, @Default([]) List<Prayer> prayers}) = _Day;

  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);

  List<Prayer> get completedPrayers => prayers.where((p) => p.isDone).toList();
  List<Prayer> get pendingPrayers => prayers.where((p) => !p.isDone).toList();
}
