import 'package:pray/model/types/language.dart';

class Settings {
  final bool darkMode;
  final bool notifications;
  final bool stickyNotifications;
  final bool azan;
  final int reminderOffsetInMinutes;
  final int autoIncrementOptionalPrayerCounterBy;
  final Language language;

  Settings({
    required this.darkMode,
    required this.notifications,
    required this.stickyNotifications,
    required this.azan,
    required this.reminderOffsetInMinutes,
    required this.autoIncrementOptionalPrayerCounterBy,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'notifications': notifications,
      'stickyNotifications': stickyNotifications,
      'azan': azan,
      'reminderOffsetInMinutes': reminderOffsetInMinutes,
      'autoIncrementOptionalPrayerCounterBy':
          autoIncrementOptionalPrayerCounterBy,
      'language': language.name,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      darkMode: json['darkMode'] as bool,
      notifications: json['notifications'] as bool,
      stickyNotifications: json['stickyNotifications'] as bool,
      azan: json['azan'] as bool,
      reminderOffsetInMinutes: json['reminderOffsetInMinutes'] as int,
      autoIncrementOptionalPrayerCounterBy:
          json['autoIncrementOptionalPrayerCounterBy'] as int,
      language: Language.values.byName(json['language'] as String),
    );
  }

  Settings copyWith({
    bool? darkMode,
    bool? notifications,
    bool? stickyNotifications,
    bool? azan,
    int? reminderOffsetInMinutes,
    int? autoIncrementOptionalPrayerCounterBy,
    Language? language,
  }) {
    return Settings(
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      stickyNotifications: stickyNotifications ?? this.stickyNotifications,
      azan: azan ?? this.azan,
      reminderOffsetInMinutes:
          reminderOffsetInMinutes ?? this.reminderOffsetInMinutes,
      autoIncrementOptionalPrayerCounterBy:
          autoIncrementOptionalPrayerCounterBy ??
          this.autoIncrementOptionalPrayerCounterBy,
      language: language ?? this.language,
    );
  }
}
