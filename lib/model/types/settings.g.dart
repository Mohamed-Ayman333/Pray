// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsImpl _$$SettingsImplFromJson(Map<String, dynamic> json) =>
    _$SettingsImpl(
      darkMode: json['darkMode'] as bool? ?? true,
      notifications: json['notifications'] as bool? ?? false,
      stickyNotifications: json['stickyNotifications'] as bool? ?? false,
      azan: json['azan'] as bool? ?? false,
      reminderOffsetInMinutes:
          (json['reminderOffsetInMinutes'] as num?)?.toInt() ?? 0,
      autoIncrementOptionalPrayerCounterBy:
          (json['autoIncrementOptionalPrayerCounterBy'] as num?)?.toInt() ?? 0,
      language:
          $enumDecodeNullable(_$LanguageEnumMap, json['language']) ??
          Language.en,
    );

Map<String, dynamic> _$$SettingsImplToJson(_$SettingsImpl instance) =>
    <String, dynamic>{
      'darkMode': instance.darkMode,
      'notifications': instance.notifications,
      'stickyNotifications': instance.stickyNotifications,
      'azan': instance.azan,
      'reminderOffsetInMinutes': instance.reminderOffsetInMinutes,
      'autoIncrementOptionalPrayerCounterBy':
          instance.autoIncrementOptionalPrayerCounterBy,
      'language': _$LanguageEnumMap[instance.language]!,
    };

const _$LanguageEnumMap = {Language.ar: 'ar', Language.en: 'en'};
