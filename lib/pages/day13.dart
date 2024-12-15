import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day13 extends BaseDay {
  const Day13({super.key}) : super(Days.day13, 'day13.txt');

  @override
  String? resolveTask1(List<String> lines) {
    List<ClawMachine> clawMachines = [];

    List<String> rawClawMachineLines = [];
    for (var line in lines) {
      if (line.isEmpty) {
        continue;
      } else {
        rawClawMachineLines.add(line);
      }
      if (rawClawMachineLines.length == 3) {
        clawMachines.add(ClawMachine(rawClawMachineLines));
        rawClawMachineLines = [];
      }
    }
    int solution = clawMachines.map((clawMachine) => clawMachine.solve1()).sum;
    print("Solution: $solution");
    return "$solution";
  }

  @override
  String? resolveTask2(List<String> lines) {
    List<ClawMachine> clawMachines = [];

    List<String> rawClawMachineLines = [];
    for (var line in lines) {
      if (line.isEmpty) {
        continue;
      } else {
        rawClawMachineLines.add(line);
      }
      if (rawClawMachineLines.length == 3) {
        clawMachines.add(ClawMachine(rawClawMachineLines, addToTarget: 10000000000000));
        rawClawMachineLines = [];
      }
    }
    int solution = clawMachines.map((clawMachine) => clawMachine.solve2()).sum;
    print("Solution: $solution");
    return "$solution";
  }
}

class ClawMachine {
  late Coordinate target;
  late Button buttonA;
  late Button buttonB;

  ClawMachine(List<String> lines, {int addToTarget = 0}) {
    assert(lines.length == 3);
    for (var line in lines) {
      var parts = line.split(":").map((e) => e.trim()).toList();
      var key = parts[0];
      var content = parts[1];
      if (key == "Prize") {
        var prizeParts = parts[1].split(",").map((e) => e.trim()).toList();
        var x = 0, y = 0;
        for (var prizePart in prizeParts) {
          var prize = prizePart.split("=");
          if (prize[0] == "X") {
            x = int.parse(prize[1]) + addToTarget;
          } else if (prize[0] == "Y") {
            y = int.parse(prize[1]) + addToTarget;
          }
        }
        target = Coordinate(x, y);
      } else if (key == "Button A") {
        buttonA = Button(content, 3);
      } else if (key == "Button B") {
        buttonB = Button(content, 1);
      }
    }
  }

  int solve1({bool isComplex = false}) {
    var solutionsA = solveDiophantine(buttonA.x, buttonB.x, target.x, max: isComplex ? 100000 : 0);
    var solutionsB = solveDiophantine(buttonA.y, buttonB.y, target.y, max: isComplex ? 100000 : 0);
    var commonSolutions =
        solutionsA.where((solution) => solutionsB.any((element) => element.x == solution.x && element.y == solution.y));
    if (commonSolutions.isEmpty) {
      return 0;
    } else {
      int cheapest = -1;
      for (var solution in commonSolutions) {
        var cost = solution.x * buttonA.value + solution.y * buttonB.value;
        if (cheapest == -1 || cost < cheapest) {
          cheapest = cost;
        }
      }
      return cheapest;
    }
  }

  int solve2() {
    var b = ((buttonA.y * target.x) - (buttonA.x * target.y)) / ((buttonA.y * buttonB.x) - (buttonA.x * buttonB.y));
    if(b.remainder(1) == 0) {
      var a = (target.x - buttonB.x * b) / buttonA.x;
      return a.toInt() * buttonA.value + b.toInt() * buttonB.value;
    }
    return 0;
  }

  @override
  String toString() {
    return "Target: $target - Push A: $buttonA - Push B: $buttonB";
  }
}

class Button {
  int value;
  late int x, y;

  Button(String rawPush, this.value) {
    rawPush.split(",").map((e) => e.trim()).toList().forEach((element) {
      if (element.startsWith("X")) {
        x = int.parse(element.split("+")[1]);
      } else if (element.startsWith("Y")) {
        y = int.parse(element.split("+")[1]);
      }
    });
  }

  @override
  String toString() {
    return "[$x,$y]";
  }
}

class Coordinate {
  int x;
  int y;

  Coordinate(this.x, this.y);

  Coordinate operator +(Coordinate other) {
    return Coordinate(x + other.x, y + other.y);
  }

  Coordinate operator -(Coordinate other) {
    return Coordinate(x - other.x, y - other.y);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coordinate && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() {
    return "[X: $x,Y: $y]";
  }
}

class Pair {
  int x;
  int y;

  Pair(this.x, this.y);

  @override
  String toString() {
    return "[$x,$y]";
  }
}

List<Pair> solveDiophantine(int a, int b, int c, {int max = 0}) {
  var list = <Pair>[];
  int g = gcd(a, b);
  if (c % g != 0) {
    return list;
  }

  List<int> solution = extendedEuclid(a, b);
  int x0 = solution[0] * (c ~/ g);
  int y0 = solution[1] * (c ~/ g);
  if (x0 > 0 && y0 > 0) {
    list.add(Pair(x0, y0));
    c = c ~/ g;
    a = a ~/ g;
    b = b ~/ g;
  }

  int range = c;
  for (int k = -range; k <= range; k++) {
    int x = x0 + k * (b ~/ g);
    int y = y0 - k * (a ~/ g);
    if (x >= 0 && y >= 0) {
      var pair = Pair(x, y);
      if (!list.any((element) => element.x == pair.x && element.y == pair.y)) {
        list.add(pair);
      }
    }
  }
  return list;
}

int gcd(int a, int b) {
  while (b != 0) {
    int temp = b;
    b = a % b;
    a = temp;
  }
  return a.abs();
}

List<int> extendedEuclid(int a, int b) {
  if (b == 0) {
    return [1, 0];
  }
  List<int> result = extendedEuclid(b, a % b);
  int x = result[1];
  int y = result[0] - (a ~/ b) * result[1];
  return [x, y];
}