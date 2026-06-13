import 'package:flutter/material.dart';

import 'view/HomePage.dart';

void main() {
  runApp(const PrayApp());
}
//Root widget
class PrayApp extends StatelessWidget {
  //the constructor
  //passes a key to the parent
  const PrayApp({super.key});
  //the function that builds the widget on the screen
  @override
  Widget build(BuildContext context) {
    //the actual root widget that will be displayed
    return MaterialApp(
      title: 'Pray',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const HomePage(title: 'Prayer Times'),
    );
  }
}

