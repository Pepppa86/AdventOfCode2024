import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day19 extends BaseDay {
  const Day19({super.key}) : super(Days.day19, 'day19.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var indexOfEmptyLine = lines.indexWhere((line) => line.isEmpty);
    var rawPatterns = lines.sublist(0, indexOfEmptyLine);
    var patterns = rawPatterns.join("").trim().split(",").map((e) => Pattern(e.trim())).toList();

    var rawDesigns = lines.sublist(indexOfEmptyLine + 1);
    var designs = rawDesigns.map((e) => Design(e.trim(), patterns)).toList();

    var solvable = designs.where((design) => design.isSolvable).toList();
    return "${solvable.length}";
  }

  @override
  String? resolveTask2(List<String> lines) {
    var indexOfEmptyLine = lines.indexWhere((line) => line.isEmpty);
    var rawPatterns = lines.sublist(0, indexOfEmptyLine);
    var patterns = rawPatterns.join("").trim().split(",").map((e) => e.trim()).toList();

    var rawDesigns = lines.sublist(indexOfEmptyLine + 1);

    var list = rawDesigns.map((e) => e.trim()).map((design) => countPossibilities(design, patterns, {})).toList();
    return "${list.sum}";
  }

  int countPossibilities(String currentDesign, List<String> towels, Map<String, int> memo) {
    if (memo.containsKey(currentDesign)) {
      return memo[currentDesign]!;
    }

    var count = 0;
    for (var towel in towels) {
      if (currentDesign.startsWith(towel)) {
        var remaining = currentDesign.substring(towel.length);
        if (remaining.isEmpty) {
          count++;
        } else {
          count += countPossibilities(remaining, towels, memo);
        }
      }
    }

    memo[currentDesign] = count;
    return count;
  }
}

class Pattern {
  String pattern;

  Pattern(this.pattern);
}

class Design {
  String design;
  List<Pattern> patterns;
  bool isSolved = false;
  List<String> alreadyTested = [];

  Design(this.design, this.patterns);

  bool get isSolvable {
    var availablePatterns =
        patterns.where((pattern) => design.contains(pattern.pattern)).map((e) => e.pattern).toList();
    if (patterns.any((pattern) => design.endsWith(pattern.pattern))) {
      _solve(design, availablePatterns);
    }
    return isSolved;
  }

  void _solve(String d, List<String> patterns) {
    if (isSolved) {
      return;
    }
    var suitablePatterns =
        patterns.where((pattern) => d.startsWith(pattern)).toList().sorted((a, b) => b.length.compareTo(a.length));
    for (var suitablePattern in suitablePatterns) {
      var newDesign = d.substring(suitablePattern.length);
      if (newDesign.isEmpty) {
        isSolved = true;
      } else {
        if (alreadyTested.contains(newDesign) == false && patterns.any((pattern) => newDesign.endsWith(pattern))) {
          _solve(newDesign, patterns);
        }
      }
      if (alreadyTested.contains(newDesign) == false) {
        alreadyTested.add(newDesign);
      }
    }
  }
}
