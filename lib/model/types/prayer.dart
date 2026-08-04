import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer.freezed.dart';
part 'prayer.g.dart';

@freezed
abstract class Prayer with _$Prayer {
  const factory Prayer({
    @Default('') String name,
    DateTime? time,
    @Default(false) bool isDone,
  }) = _Prayer;

  factory Prayer.fromJson(Map<String, dynamic> json) => _$PrayerFromJson(json);
}
