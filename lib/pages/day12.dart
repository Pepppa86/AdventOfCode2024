import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day12 extends BaseDay {
  const Day12({super.key}) : super(Days.day12, 'day12.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var farm = Farm(lines.map((e) => e.split("")).toList());

    var sum = farm.regions.map((e) => e.simpleValue()).reduce((value, element) => value + element);

    return "$sum";
  }

  @override
  String? resolveTask2(List<String> lines) {
    var farm = Farm(lines.map((e) => e.split("")).toList());

    var sum = farm.regions.map((e) => e.complexValue()).reduce((value, element) => value + element);

    return "$sum";
  }
}

class Farm {
  List<List<String>> rawInput;
  List<Position> positions = [];
  List<Region> regions = [];

  Farm(this.rawInput) {
    getPositions();
    organizeNeighbours();
    organizeRegions();
  }

  void getPositions() {
    for (int y = 0; y < rawInput.length; y++) {
      for (int x = 0; x < rawInput[y].length; x++) {
        positions.add(Position(rawInput[y][x], x, y));
      }
    }
  }

  void organizeNeighbours() {
    for (var position in positions) {
      for (var neighbour in positions) {
        if (position != neighbour) {
          if ((position.x == neighbour.x && (position.y - neighbour.y).abs() == 1) ||
              (position.y == neighbour.y && (position.x - neighbour.x).abs() == 1)) {
            position.addNeighbour(neighbour);
          }
        }
      }
    }
    for (var position in positions) {
      position.organizeFences();
    }
  }

  void organizeRegions() {
    while (true) {
      var position = positions
          .firstWhereOrNull((element) => regions.isEmpty || regions.none((region) => region.hasPosition(element)));
      if (position == null) {
        break;
      }
      regions.add(getRegion(position));
    }
  }

  Region getRegion(Position position) {
    var positions = <Position>[position];
    addPosition(position, positions);
    return Region(position.character, positions);
  }

  void addPosition(Position position, List<Position> positions) {
    for (var neighbour in position.neighbours) {
      if (neighbour.character == position.character && !positions.contains(neighbour)) {
        positions.add(neighbour);
        addPosition(neighbour, positions);
        continue;
      }
    }
  }
}

class Region {
  String character;
  List<Position> positions = [];

  Region(this.character, this.positions);

  bool hasPosition(Position position) {
    return positions.contains(position);
  }

  int get size => positions.length;

  int simpleValue() {
    int fenceCount = positions.map((e) => e.fencesCount()).reduce((value, element) => value + element);
    return fenceCount * size;
  }

  int complexValue() {
    int peakCount = positions.map((e) => e.outerPeakCount() + e.innerPeakCount()).reduce((value, element) => value + element);
    return peakCount * size;
  }
}

class Position {
  String character;
  int x;
  int y;
  List<Position> neighbours = [];
  List<Fence> fences = [];

  Position(this.character, this.x, this.y);

  void organizeFences() {
    if (!hasUpperRegionNeighbour()) {
      fences.add(Fence(Orientation.north));
    }
    if (!hasLeftRegionNeighbour()) {
      fences.add(Fence(Orientation.west));
    }
    if (!hasRightRegionNeighbour()) {
      fences.add(Fence(Orientation.east));
    }
    if (!hasLowerRegionNeighbour()) {
      fences.add(Fence(Orientation.south));
    }
  }

  void addNeighbour(Position neighbour) {
    neighbours.add(neighbour);
  }

  Position? upperNeighbour() {
    return neighbours.firstWhereOrNull((element) => element.y == y - 1);
  }

  Position? leftNeighbour() {
    return neighbours.firstWhereOrNull((element) => element.x == x - 1);
  }

  Position? rightNeighbour() {
    return neighbours.firstWhereOrNull((element) => element.x == x + 1);
  }

  Position? lowerNeighbour() {
    return neighbours.firstWhereOrNull((element) => element.y == y + 1);
  }

  bool hasUpperRegionNeighbour() {
    return upperNeighbour() != null && upperNeighbour()?.character == character;
  }

  bool hasLeftRegionNeighbour() {
    return leftNeighbour() != null && leftNeighbour()?.character == character;
  }

  bool hasRightRegionNeighbour() {
    return rightNeighbour() != null && rightNeighbour()?.character == character;
  }

  bool hasLowerRegionNeighbour() {
    return lowerNeighbour() != null && lowerNeighbour()?.character == character;
  }

  int outerPeakCount() {
    int peakCount = 0;
    if (hasUpperRegionNeighbour() == false && hasLeftRegionNeighbour() == false) {
      peakCount++;
    }
    if (hasUpperRegionNeighbour() == false && hasRightRegionNeighbour() == false) {
      peakCount++;
    }
    if (hasLowerRegionNeighbour() == false && hasLeftRegionNeighbour() == false) {
      peakCount++;
    }
    if (hasLowerRegionNeighbour() == false && hasRightRegionNeighbour() == false) {
      peakCount++;
    }
    return peakCount;
  }

  int innerPeakCount() {
    int innerPeak = 0;
    if (hasLeftRegionNeighbour() &&
        leftNeighbour()!.fences.any((fence) => fence.orientation == Orientation.south) &&
        hasLowerRegionNeighbour() &&
        lowerNeighbour()!.fences.any((fence) => fence.orientation == Orientation.west)) {
      innerPeak++;
    }
    if (hasRightRegionNeighbour() &&
        rightNeighbour()!.fences.any((fence) => fence.orientation == Orientation.south) &&
        hasLowerRegionNeighbour() &&
        lowerNeighbour()!.fences.any((fence) => fence.orientation == Orientation.east)) {
      innerPeak++;
    }
    if (hasLeftRegionNeighbour() &&
        leftNeighbour()!.fences.any((fence) => fence.orientation == Orientation.north) &&
        hasUpperRegionNeighbour() &&
        upperNeighbour()!.fences.any((fence) => fence.orientation == Orientation.west)) {
      innerPeak++;
    }
    if (hasRightRegionNeighbour() &&
        rightNeighbour()!.fences.any((fence) => fence.orientation == Orientation.north) &&
        hasUpperRegionNeighbour() &&
        upperNeighbour()!.fences.any((fence) => fence.orientation == Orientation.east)) {
      innerPeak++;
    }
    return innerPeak;
  }

  Orientation getOrientationByNeighbour(String character) {
    if (upperNeighbour()?.character == character) {
      return Orientation.north;
    } else if (leftNeighbour()?.character == character) {
      return Orientation.west;
    } else if (rightNeighbour()?.character == character) {
      return Orientation.east;
    } else if (lowerNeighbour()?.character == character) {
      return Orientation.south;
    } else {
      throw Exception("No neighbour found with character: $character");
    }
  }

  int fencesCount() {
    return fences.length;
  }

  @override
  String toString() {
    return "Position($character): $x, $y";
  }
}

class Fence {
  Orientation orientation;

  Fence(this.orientation);
}

enum Direction { up, down, left, right }

enum Orientation { north, south, west, east }

extension OrientationExtension on Orientation {
  Direction get direction {
    switch (this) {
      case Orientation.north:
        return Direction.right;
      case Orientation.south:
        return Direction.left;
      case Orientation.west:
        return Direction.up;
      case Orientation.east:
        return Direction.down;
    }
  }
}
