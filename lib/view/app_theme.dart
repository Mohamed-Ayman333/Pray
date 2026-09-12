import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // ==========================================
  // LIGHT COLOR SCHEME
  // ==========================================
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1B5E20),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE8F5E9),
    onPrimaryContainer: Color(0xFF002107),
    secondary: Color(0xFFC89B3C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFF8E1),
    onSecondaryContainer: Color(0xFF3E2723),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF191C1B),
    surfaceContainerHigh: Color(0xFFF1F5F2),
    onSurfaceVariant: Color(0xFF4A5568),
    outline: Color(0xFFE2E8F0),
    outlineVariant: Color(0xFFE2E8F0),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFEBEE),
    onErrorContainer: Color(0xFFD32F2F),
  );

  // ==========================================
  // DARK COLOR SCHEME
  // ==========================================
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF81C784),
    onPrimary: Color(0xFF0A330C),
    primaryContainer: Color(0xFF1A3826),
    onPrimaryContainer: Color(0xFFC8E6C9),
    secondary: Color(0xFFFFD54F),
    onSecondary: Color(0xFF3E2723),
    secondaryContainer: Color(0xFF3D3012),
    onSecondaryContainer: Color(0xFFFFE082),
    surface: Color(0xFF1A1E1C),
    onSurface: Color(0xFFE8ECE9),
    surfaceContainerHigh: Color(0xFF242A27),
    onSurfaceVariant: Color(0xFF9EABA2),
    outline: Color(0xFF2E3833),
    outlineVariant: Color(0xFF2E3833),
    error: Color(0xFFEF5350),
    onError: Color(0xFF3B1314),
    errorContainer: Color(0xFF3B1314),
    onErrorContainer: Color(0xFFFFCDD2),
  );

  // ==========================================
  // LIGHT THEME BUILDER
  // ==========================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      disabledColor: const Color(0xFF9E9E9E),
      extensions: const [
        PrayerThemeColors(
          nextPrayerBackground: Color(0xFFE8F5E9),
          nextPrayerBorder: Color(0xFF1B5E20),
          prayerDone: Color(0xFF388E3C),
          prayerPending: Color(0xFF718096),
          progressBarFill: Color(0xFF2E7D32),
          progressBarTrack: Color(0xFFE0E7E3),
          calendarActiveHighlight: Color(0xFFC89B3C),
          successContainer: Color(0xFFE8F5E9),
          warningContainer: Color(0xFFFFF3E0),
          errorContainer: Color(0xFFFFEBEE),
          infoContainer: Color(0xFFE1F5FE),
        ),
      ],
    );
  }

  // ==========================================
  // DARK THEME BUILDER
  // ==========================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF121413),
      disabledColor: const Color(0xFF616B65),
      extensions: const [
        PrayerThemeColors(
          nextPrayerBackground: Color(0xFF1A3826),
          nextPrayerBorder: Color(0xFF81C784),
          prayerDone: Color(0xFF66BB6A),
          prayerPending: Color(0xFFA0AEC0),
          progressBarFill: Color(0xFF81C784),
          progressBarTrack: Color(0xFF27382E),
          calendarActiveHighlight: Color(0xFFFFD54F),
          successContainer: Color(0xFF1B3822),
          warningContainer: Color(0xFF3E2705),
          errorContainer: Color(0xFF3B1314),
          infoContainer: Color(0xFF0C2D3E),
        ),
      ],
    );
  }
}
