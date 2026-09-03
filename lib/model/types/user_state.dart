import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_state.g.dart';

@Collection()
@JsonSerializable()
class UserState {
  // Enforce single-instance record in local DB
  Id id = 1;

  int optionalPrayerCounter;

  UserState({this.optionalPrayerCounter = 0});

  factory UserState.fromJson(Map<String, dynamic> json) =>
      _$UserStateFromJson(json);

  Map<String, dynamic> toJson() => _$UserStateToJson(this);
}
