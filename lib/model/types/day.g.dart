// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DayImpl _$$DayImplFromJson(Map<String, dynamic> json) => _$DayImpl(
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  prayers:
      (json['prayers'] as List<dynamic>?)
          ?.map((e) => Prayer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$DayImplToJson(_$DayImpl instance) => <String, dynamic>{
  'date': instance.date?.toIso8601String(),
  'prayers': instance.prayers,
};
