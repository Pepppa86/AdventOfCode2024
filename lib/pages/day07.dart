import 'dart:math';

import 'package:advent_of_code2024/pages/base/base_day.dart';

import '../utils/enums.dart';

class Day07 extends BaseDay {
  final List<String> operations = ['+', '*'];
  final List<String> altOperations = ['+', '*', '||'];

  Day07({super.key}) : super(Days.day07, 'day07.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var equations = lines.map((e) => Equation(e)).toList();
    var solvableEquations = equations
        .where((element) => element.isSolvable(getCombinations(operations, element.right!.length - 1)) == true)
        .toList();
    int? sum = solvableEquations.map((e) => e.left).toList().reduce((value, element) => value! + element!);
    return "$sum";
  }

  @override
  String? resolveTask2(List<String> lines) {
    var equations = lines.map((e) => Equation(e)).toList();

    var solvableEquations = equations
        .where((element) => element.isSolvable(getCombinations(operations, element.right!.length - 1)) == true)
        .toList();
    int sum1 = solvableEquations.map((e) => e.left).toList().reduce((value, element) => value! + element!) ?? 0;

    var notSolvableEquations = equations.where((element) => !solvableEquations.contains(element)).toList();

    var altSolvableEquations = notSolvableEquations
        .where((element) => element.isSolvable(getCombinations(altOperations, element.right!.length - 1)) == true)
        .toList();
    int sum2 = altSolvableEquations.map((e) => e.left).toList().reduce((value, element) => value! + element!) ?? 0;

    print("Sum: ${sum1 + sum2}");
    return "${sum1 + sum2}";
  }

  List<List<String>> getCombinations(List<String> elements, int length) {
    List<List<String>> combinations = [];
    var totalCombinations = pow(elements.length, length);
    for (int i = 0; i < totalCombinations; i++) {
      List<String> currentCombination = [];
      int temp = i;
      for (int j = 0; j < length; j++) {
        currentCombination.add(elements[temp % elements.length]);
        temp ~/= elements.length;
      }
      combinations.add(currentCombination);
    }
    return combinations;
  }
}

class Equation {
  late int? left;
  late List<int>? right;

  Equation(String raw) {
    var sides = raw.split(":");
    if (sides.length != 2) {
      left = null;
      right = null;
    } else {
      left = int.parse(sides[0]);
      right = sides[1].trim().split(' ').map((e) => int.parse(e.trim())).toList();
    }
  }

  bool? isSolvable(List<List<String>> combinations) {
    var list = right;

    if (left == null || list == null) return null;
    for (var i = 0; i < combinations.length; i++) {
      var currentCombination = combinations[i];
      var solution = list.first;
      for (var j = 1; j < list.length; j++) {
        var next = list[j];
        if (currentCombination[j - 1] == '+') {
          solution += next;
        } else if (currentCombination[j - 1] == '*') {
          solution *= next;
        } else if (currentCombination[j - 1] == '||') {
          solution = int.parse("$solution$next");
        }
        if (solution > left!) {
          break;
        }
      }
      if (solution == left) {
        return true;
      }
    }
    return false;
  }

  @override
  toString() {
    return "$left: ${right?.join(' ')}";
  }
}
