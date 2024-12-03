import 'package:collection/collection.dart';

import '../utils/enums.dart';
import 'base/base_day.dart';

class Day03 extends BaseDay {
  const Day03({super.key}) : super(Days.day03, 'day03.txt');

  @override
  String? resolveTask1(List<String> lines) {
    int counter = 0;

    RegExp regex = RegExp(r'mul\(\d{1,3},\d{1,3}\)');

    // Find all matches
    Iterable<RegExpMatch> matches = regex.allMatches(lines.join(""));

    // Process and print matches
    for (RegExpMatch match in matches) {
      var current = match.group(0);

      if(current != null) {
        counter += getMulValue(current);
      }
    }
    return "$counter";
  }

  @override
  String? resolveTask2(List<String> lines) {
    int counter = 0;
    RegExp regex = RegExp(r'mul\(\d{1,3},\d{1,3}\)');
    var raw = lines.join("");
    Iterable<RegExpMatch> matches = regex.allMatches(raw);

    Map<String, int> map = <String, int>{};
    matches.map((e) => e.group(0)).forEach((element) {
      if(element != null) {
        map[element] = raw.indexOf(element);
      }
    });

    String doString = "do()";
    String dontString = "don't()";

    var doIndeces = <int>[];
    var dontIndeces = <int>[];

    int startIndex = 0;
    while ((startIndex = raw.indexOf(doString, startIndex)) != -1) {
      doIndeces.add(startIndex);
      startIndex += doString.length; // Move past the current match
    }

    startIndex = 0;
    while ((startIndex = raw.indexOf(dontString, startIndex)) != -1) {
      dontIndeces.add(startIndex);
      startIndex += dontString.length; // Move past the current match
    }

    var joinIndeces = dontIndeces + doIndeces;
    joinIndeces.sort();

    var firstIndex = joinIndeces.first;
    map.entries.where((element) => element.value < firstIndex).forEach((entry) {
      counter += getMulValue(entry.key);
    });

    for (var index in joinIndeces) {
      bool isDo = doIndeces.contains(index);
      var nextIndex = joinIndeces.firstWhereOrNull((element) => element > index);
      for (var element in map.entries) {
        if(isDo && element.value > index && (nextIndex == null || element.value < nextIndex)) {
          counter += getMulValue(element.key);
        }
      }
    }
    return "$counter";
  }

  int getMulValue(String raw) {
    var str = raw.substring(raw.indexOf("(") + 1, raw.lastIndexOf(")"));
    return str.split(",").map((e) => int.parse(e)).reduce((value, element) => value * element);
  }
}