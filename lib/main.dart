import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:advent_of_code2024/utils/enums.dart';
import 'package:advent_of_code2024/utils/extensions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var listItems = Days.values.where((e) => e.page is BaseDay).toList().reversed.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advent of Code 2024'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            var day = listItems.elementAt(index);
            return ListTile(
              title: Text(day.title),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => day.page),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
