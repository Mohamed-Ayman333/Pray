import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pray/model/types/language.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
abstract class Settings with _$Settings {
  const factory Settings({
    @Default(true) bool darkMode,
    @Default(false) bool notifications,
    @Default(false) bool stickyNotifications,
    @Default(false) bool azan,
    @Default(0) int reminderOffsetInMinutes,
    @Default(0) int autoIncrementOptionalPrayerCounterBy,
    @Default(Language.en) Language language,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}
