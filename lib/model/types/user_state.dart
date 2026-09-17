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

  /// The last UTC-midnight date on which the optional prayer counter was
  /// auto-incremented. `null` until the first launch after this feature
  /// shipped; on that first launch it's set to "today" without incrementing
  /// (so existing users don't see a surprise jump).
  DateTime? lastAutoIncrementDate;

  UserState({
    this.optionalPrayerCounter = 0,
    this.hasPromptedBatteryExemption = false,
    this.lastAutoIncrementDate,
  });

  factory UserState.fromJson(Map<String, dynamic> json) =>
      _$UserStateFromJson(json);

  Map<String, dynamic> toJson() => _$UserStateToJson(this);
}
