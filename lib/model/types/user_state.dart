import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_state.g.dart';

@Collection()
@JsonSerializable()
class UserState {
  // Enforce single-instance record in local DB
  Id id = 1;

  int optionalPrayerCounter;

  /// Whether the user has already been shown the battery-optimization
  /// exemption prompt. Persisted so we only ever nag once per install.
  bool hasPromptedBatteryExemption;

  UserState({
    this.optionalPrayerCounter = 0,
    this.hasPromptedBatteryExemption = false,
  });

  factory UserState.fromJson(Map<String, dynamic> json) =>
      _$UserStateFromJson(json);

  Map<String, dynamic> toJson() => _$UserStateToJson(this);
}
