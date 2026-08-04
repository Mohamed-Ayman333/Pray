// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrayerImpl _$$PrayerImplFromJson(Map<String, dynamic> json) => _$PrayerImpl(
  name: json['name'] as String? ?? '',
  time: json['time'] == null ? null : DateTime.parse(json['time'] as String),
  isDone: json['isDone'] as bool? ?? false,
);

Map<String, dynamic> _$$PrayerImplToJson(_$PrayerImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'time': instance.time?.toIso8601String(),
      'isDone': instance.isDone,
    };
