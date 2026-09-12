// lib/main.dart
import 'package:flutter/material.dart';
import 'view/app_theme.dart';
import 'view/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times',
      debugShowCheckedModeBanner: false,

      // Pass the generated light and dark themes here
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically adapts to device theme mode

      home: const HomePage(),
    );
  }
}
