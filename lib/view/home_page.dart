import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int gridWidth = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[300],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        widthFactor: 1,
        child:Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: ()=>{},
                  child: Text('Today'),
                ),
                TextButton(
                  onPressed: ()=>{},
                  child: Text('30 Days')
                ),
              ],
            ),
            SizedBox(
              height: 120,
              child: Row(
                spacing: 30,
                children: [
                  Column(
                    children: [
                      Text('Alfajr'),
                      Text('Alshroq'),
                      Text('Alzohr'),
                      Text('Alasr'),
                      Text('Almagreb'),
                      Text('Alesha'),
                    ],
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 6,
                      scrollDirection: Axis.horizontal,
                      mainAxisSpacing: 10,
                      children: [
                        Text('hi0'),
                        Text('hi1'),
                        Text('hi2'),
                        Text('hi3'),
                        Text('hi4'),
                        Text('hi5'),
                      ],
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
