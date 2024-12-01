import 'package:advent_of_code2024/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/enums.dart';

abstract class BaseDay extends StatelessWidget {
  final Days day;
  final String assetFileName;

  const BaseDay(this.day, this.assetFileName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(day.title),
      ),
      body: SafeArea(
        child: FutureBuilder<List<String>>(
            future: readFileLineByLine(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('An error occurred while reading the file'));
              }
              var list = snapshot.data!;
              var result1 = resolveTask1(list);
              var result2 = resolveTask2(list);
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    Text("Number of lines: ${list.length}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    resultWidget("Solution of task 1 is", result1),
                    resultWidget("Solution of task 2 is", result2),
                  ],
                ),
              );
            }),
      ),
    );
  }

  String? resolveTask1(List<String> lines);

  String? resolveTask2(List<String> lines);

  Future<List<String>> readFileLineByLine() async {
    try {
      final fileContent = await rootBundle.loadString('assets/$assetFileName');
      return fileContent.split('\n').map((line) => line.trim()).toList();
    } catch (e) {
      return List.empty();
    }
  }

  Widget resultWidget(String label, String? result) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
        const SizedBox(width: 5),
        Text(result ?? "N/A",
            style: TextStyle(
                color: result == null ? Colors.red : Colors.green,
                fontSize: 18,
                fontWeight: result == null ? FontWeight.w500 : FontWeight.bold)),
      ],
    );
  }
}
