import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pray/model/types/language.dart';

part 'settings.g.dart';

@Collection()
@JsonSerializable()
class Settings {
  // Enforce single-instance record in local DB
  Id id = 1;

  bool darkMode;
  bool notifications;
  bool stickyNotifications;
  bool azan;
  int reminderOffsetInMinutes;
  int autoIncrementOptionalPrayerCounterBy;

  @enumerated
  Language language;

  Settings({
    this.darkMode = true,
    this.notifications = false,
    this.stickyNotifications = false,
    this.azan = false,
    this.reminderOffsetInMinutes = 0,
    this.autoIncrementOptionalPrayerCounterBy = 0,
    this.language = Language.en,
  });

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
