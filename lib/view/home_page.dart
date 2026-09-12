import 'package:flutter/material.dart';

import 'app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Text> times = [
    Text('date'),
    Text('hi0'),
    Text('hi1'),
    Text('hi2'),
    Text('hi3'),
    Text('hi4'),
    Text('hi5'),
    Text('hi5'),
    Text('hi5'),
    Text('hi5'),
    Text('hi5'),
    Text('hi5'),
    Text('hi5'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[300],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        widthFactor: 1,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor: WidgetStateColor.fromMap(
                        primaryButtonStyle,
                      ),
                    ),
                    child: Text('Today'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor: WidgetStateColor.fromMap(
                        primaryButtonStyle,
                      ),
                    ),
                    child: Text('30 Days'),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 230,
              child: Row(
                spacing: 10,
                children: [
                  Container(
                    color: Colors.teal[400],
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      spacing: 10,
                      children: [
                        Text('Prayer'),
                        Text('Alfajr'),
                        Text('Alshroq'),
                        Text('Alzohr'),
                        Text('Alasr'),
                        Text('Almagreb'),
                        Text('Alesha'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      margin: EdgeInsets.all(0),
                      child: GridView.count(
                        crossAxisCount: 7,
                        scrollDirection: Axis.horizontal,
                        mainAxisSpacing: 10,
                        children: times,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
