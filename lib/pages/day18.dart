import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day18 extends BaseDay {
  const Day18({super.key}) : super(Days.day18, 'day18.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var maze = Maze(70, 70, lines, count: 1024);
    var stepsToCompleteTheMaze = maze.runTask1(0, 0);

    return stepsToCompleteTheMaze.toString();
  }

  @override
  String? resolveTask2(List<String> lines) {
    var maze = Maze(70, 70, lines, count: 1024);
    var lastPositionLeadToStuck = maze.runTask2(0, 0);
    return lastPositionLeadToStuck.toString();
  }
}

class Maze {
  int width;
  int height;
  final List<Position> droppedPositions = [];
  late List<String> waitingRawPositions;
  int? bestPathValue;

  Maze(this.width, this.height, List<String> lines, {int? count}) {
    var droppedLines = List.from(lines);
    if (count != null) {
      droppedLines = droppedLines.sublist(0, count);
    }
    for (var y = 0; y <= height; y++) {
      for (var x = 0; x <= width; x++) {
        bool isCorrupted = droppedLines.contains("$x,$y");
        droppedPositions.add(Position(x, y, isCorrupted));
      }
    }
    waitingRawPositions = lines.sublist(1024);

    for (var position in droppedPositions) {
      position.setNeighbours(droppedPositions);
    }
  }

  List<Position> getPlacesToGo() {
    return droppedPositions.where((e) => e.isCorrupted == false).toList();
  }

  int runTask1(int x, int y) {
    var startPosition = droppedPositions.firstWhere((e) => e.coordinate.x == x && e.coordinate.y == y);

    var path = Path.init(startPosition);
    List<Path> paths = [path];

    goToNextPosition(paths, path);

    var endPaths = paths.where((e) => e.positions.last.coordinate == const Coordinate(70, 70)).toList();
    endPaths.sort((a, b) => a.positions.length.compareTo(b.positions.length));

    return endPaths.first.positions.length - 1;
  }

  String runTask2(int x, int y) {
    var index = 0;
    var startPosition = droppedPositions.firstWhere((e) => e.coordinate.x == x && e.coordinate.y == y);
    String? lastStuckPosition;
    String? preLastStuckPosition;
    while (true) {
      var path = Path.init(startPosition);
      List<Path> paths = [path];

      preLastStuckPosition = lastStuckPosition;
      bestPathValue = null;
      for (var e in droppedPositions) {
        e.resetBestPathIndex();
      }
      goToNextPosition(paths, path);

      while (true) {
        var coordinates = waitingRawPositions[index].split(',').map((e) => e.trim()).map(int.parse).toList();
        var nextCorruptedPosition = droppedPositions
            .firstWhere((e) => e.coordinate.x == coordinates.first && e.coordinate.y == coordinates.last);
        nextCorruptedPosition.isCorrupted = true;

        paths = paths.where((e) => e.positions.none((p) => p.coordinate == nextCorruptedPosition.coordinate)).toList();
        if (paths.isNotEmpty) {
          index++;
          continue;
        } else {
          lastStuckPosition = nextCorruptedPosition.coordinate.toString();
          break;
        }
      }
      if (lastStuckPosition == preLastStuckPosition) {
        break;
      }
    }
    return lastStuckPosition;
  }

  void addWaitingPositions(int index) {
    var nextWaitingPosition = waitingRawPositions[index];
    var coordinates = nextWaitingPosition.split(',').map((e) => e.trim()).map(int.parse).toList();
    var nextPosition = Position(coordinates.first, coordinates.last, true);
    droppedPositions.add(nextPosition);
  }

  void goToNextPosition(List<Path> paths, Path currentPath) {
    if (bestPathValue != null && currentPath.positions.length > bestPathValue!) {
      paths.remove(currentPath);
      return;
    }
    var position = currentPath.lastPosition;
    if (position.coordinate.x == 70 && position.coordinate.y == 70) {
      if (bestPathValue == null || currentPath.positions.length < bestPathValue!) {
        bestPathValue = currentPath.positions.length;
      }
      return;
    }

    var nextPositions = position
        .getAvailableNeighbours()
        .where((e) =>
            currentPath.containsPosition(e) == false &&
            (e.bestPathIndex == null || e.bestPathIndex! > currentPath.positions.length))
        .toList();
    if (nextPositions.isEmpty) {
      paths.remove(currentPath);
      return;
    }
    if (nextPositions.length == 1) {
      currentPath.addPosition(nextPositions.first);
      goToNextPosition(paths, currentPath);
    } else {
      for (var nextPosition in nextPositions) {
        var newPath = Path.copy(currentPath);
        newPath.addPosition(nextPosition);
        paths.remove(currentPath);
        paths.add(newPath);
        goToNextPosition(paths, newPath);
      }
    }
  }
}

class Path {
  List<Position> positions = [];

  Path.init(Position position) {
    positions.add(position);
  }

  Path.copy(Path path) {
    positions = List.from(path.positions);
  }

  Position get lastPosition => positions.last;

  void addPosition(Position position) {
    if (position.setBestPathIndex(positions.length)) {
      positions.add(position);
    }
  }

  bool containsPosition(Position position) {
    return positions.any((e) => e.coordinate == position.coordinate);
  }
}

class Position {
  final Coordinate coordinate;
  bool isCorrupted = false;
  List<Position> _neighbours = [];
  int? bestPathIndex;

  Position(int x, int y, this.isCorrupted) : coordinate = Coordinate(x, y);

  bool setBestPathIndex(int index) {
    if (bestPathIndex == null || index <= bestPathIndex!) {
      bestPathIndex = index;
      return true;
    }
    return false;
  }

  void setNeighbours(List<Position> allPositions) {
    _neighbours = allPositions
        .where((p) =>
            (p.coordinate.y == coordinate.y && (p.coordinate.x - coordinate.x).abs() == 1) ||
            (p.coordinate.x == coordinate.x && (p.coordinate.y - coordinate.y).abs() == 1))
        .toList();
  }

  List<Position> getAvailableNeighbours() {
    return _neighbours.where((e) => e.isCorrupted == false).toList();
  }

  void resetBestPathIndex() {
    bestPathIndex = null;
  }

  @override
  toString() {
    return coordinate.toString();
  }
}

class Coordinate {
  final int x;
  final int y;

  const Coordinate(this.x, this.y);

  Coordinate operator +(Coordinate other) {
    return Coordinate(x + other.x, y + other.y);
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
    return "($x, $y)";
  }
}

enum Direction { north, east, south, west }

extension DirectionExtension on Direction {
  Direction get opposite {
    switch (this) {
      case Direction.north:
        return Direction.south;
      case Direction.east:
        return Direction.west;
      case Direction.south:
        return Direction.north;
      case Direction.west:
        return Direction.east;
    }
  }
}
