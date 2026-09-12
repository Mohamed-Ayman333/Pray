import 'package:flutter/material.dart';

@immutable
class PrayerThemeColors extends ThemeExtension<PrayerThemeColors> {
  final Color? nextPrayerBackground;
  final Color? nextPrayerBorder;
  final Color? prayerDone;
  final Color? prayerPending;
  final Color? progressBarFill;
  final Color? progressBarTrack;
  final Color? calendarActiveHighlight;
  final Color? successContainer;
  final Color? warningContainer;
  final Color? errorContainer;
  final Color? infoContainer;

  const PrayerThemeColors({
    required this.nextPrayerBackground,
    required this.nextPrayerBorder,
    required this.prayerDone,
    required this.prayerPending,
    required this.progressBarFill,
    required this.progressBarTrack,
    required this.calendarActiveHighlight,
    required this.successContainer,
    required this.warningContainer,
    required this.errorContainer,
    required this.infoContainer,
  });

  @override
  PrayerThemeColors copyWith({
    Color? nextPrayerBackground,
    Color? nextPrayerBorder,
    Color? prayerDone,
    Color? prayerPending,
    Color? progressBarFill,
    Color? progressBarTrack,
    Color? calendarActiveHighlight,
    Color? successContainer,
    Color? warningContainer,
    Color? errorContainer,
    Color? infoContainer,
  }) {
    return PrayerThemeColors(
      nextPrayerBackground: nextPrayerBackground ?? this.nextPrayerBackground,
      nextPrayerBorder: nextPrayerBorder ?? this.nextPrayerBorder,
      prayerDone: prayerDone ?? this.prayerDone,
      prayerPending: prayerPending ?? this.prayerPending,
      progressBarFill: progressBarFill ?? this.progressBarFill,
      progressBarTrack: progressBarTrack ?? this.progressBarTrack,
      calendarActiveHighlight:
          calendarActiveHighlight ?? this.calendarActiveHighlight,
      successContainer: successContainer ?? this.successContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      errorContainer: errorContainer ?? this.errorContainer,
      infoContainer: infoContainer ?? this.infoContainer,
    );
  }

  @override
  PrayerThemeColors lerp(ThemeExtension<PrayerThemeColors>? other, double t) {
    if (other is! PrayerThemeColors) return this;
    return PrayerThemeColors(
      nextPrayerBackground: Color.lerp(
        nextPrayerBackground,
        other.nextPrayerBackground,
        t,
      ),
      nextPrayerBorder: Color.lerp(nextPrayerBorder, other.nextPrayerBorder, t),
      prayerDone: Color.lerp(prayerDone, other.prayerDone, t),
      prayerPending: Color.lerp(prayerPending, other.prayerPending, t),
      progressBarFill: Color.lerp(progressBarFill, other.progressBarFill, t),
      progressBarTrack: Color.lerp(progressBarTrack, other.progressBarTrack, t),
      calendarActiveHighlight: Color.lerp(
        calendarActiveHighlight,
        other.calendarActiveHighlight,
        t,
      ),
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t),
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t),
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t),
    );
  }
}
