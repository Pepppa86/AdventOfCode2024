import 'package:advent_of_code2024/pages/base/base_day.dart';

import '../utils/enums.dart';

class Day10 extends BaseDay {
  const Day10({super.key}) : super(Days.day10, 'day10.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var map = Map(lines.map((e) => e.split('')).toList());
    return "${map.countUpwards()}";
  }

  @override
  String? resolveTask2(List<String> lines) {
    var map = Map(lines.map((e) => e.split('')).toList());
    return "${map.countUpwards(allPossible: true)}";
  }
}

class Map {
  List<Position> positions;

  Map(List<List<String>> rawNumbers) : positions = [] {
    for (var i = 0; i < rawNumbers.length; i++) {
      for (var j = 0; j < rawNumbers[i].length; j++) {
        var raw = rawNumbers[i][j];
        var number = raw == "." ? -1 : int.parse(raw);
        var coordinate = Coordinate(j, i);
        positions.add(Position(number, coordinate));
      }
    }

    for (var position in positions) {
      for (var neighbor in positions) {
        if (position.coordinate.x == neighbor.coordinate.x && position.coordinate.y == neighbor.coordinate.y) {
          continue;
        }
        if ((position.coordinate.x == neighbor.coordinate.x &&
                (position.coordinate.y - neighbor.coordinate.y).abs() == 1) ||
            (position.coordinate.y == neighbor.coordinate.y &&
                (position.coordinate.x - neighbor.coordinate.x).abs() == 1)) {
          position.addNeighbor(neighbor);
        }
      }
    }
  }

  int countUpwards({bool allPossible = false}) {
    var zeroPoints = positions.where((element) => element.number == 0).toList();
    var positionMap = <Position, List<Position>>{};
    for (var zeroPoint in zeroPoints) {
      var topPositions = <Position>[];
      countUpwardsFrom(zeroPoint, topPositions);
      positionMap[zeroPoint] = topPositions;
    }
    int counter = 0;
    positionMap.forEach((key, value) {
      if (allPossible) {
        counter += value.map((e) => e.coordinate).length;
      } else {
        counter += value.map((e) => e.coordinate).toSet().length;
      }
    });
    return counter;
  }

  void countUpwardsFrom(Position position, List<Position> topPositions) {
    var nextPoints = position.upwards();
    for (var nextPoint in nextPoints) {
      if (nextPoint.isTop()) {
        topPositions.add(nextPoint);
      } else {
        countUpwardsFrom(nextPoint, topPositions);
      }
    }
  }
}

class Position {
  int number;
  Coordinate coordinate;
  List<Position> neighbors = [];

  Position(this.number, this.coordinate);

  void addNeighbor(Position neighbor) {
    neighbors.add(neighbor);
  }

  List<Position> upwards() {
    return neighbors.where((element) => element.number == number + 1).toList();
  }

  bool isTop() => number == 9;
}

class Coordinate {
  int x, y;

  Coordinate(this.x, this.y);

  @override
  toString() {
    return "($x, $y)";
  }
}
