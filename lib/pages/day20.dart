import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day20 extends BaseDay {
  const Day20({super.key}) : super(Days.day20, 'day20.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var maze = Maze(lines);
    var cheats = maze.runTask1();
    return cheats.toString();
  }

  @override
  String? resolveTask2(List<String> lines) {
    var maze = Maze(lines);
    var cheats = maze.runTask2();
    return cheats.toString();
  }
}

class Maze {
  final List<Position> positions = [];

  Maze(List<String> lines) {
    int y = 0;
    for (var line in lines) {
      for (int x = 0; x < line.length; x++) {
        positions.add(Position(Coordinate(x, y), line[x],
            isBorder: x == 0 || x == line.length - 1 || y == 0 || y == lines.length - 1));
      }
      y++;
    }
    for (var position in positions) {
      position.setNeighbours(positions);
    }
  }

  int runTask1() {
    var startPosition = positions.firstWhere((e) => e.isStartingPosition);

    var path = Path.init(startPosition);
    List<Path> paths = [];

    goToNextPosition(paths, path);
    var originalPath = paths.first;
    var picosecondsToSave = 100;

    List<Position> checkedWalls = [];
    Map<int, int> cheatedPathsMap = {};
    for (var position in originalPath.positions) {
      var wallNeighbors = position
          .getWallNeighbours()
          .where((e) =>
              checkedWalls.contains(e) == false &&
              e.neighbours.any((neighbor) => originalPath.positions.contains(neighbor)))
          .toList();
      for (var wallNeighbor in wallNeighbors) {
        var copyPositions = List.from(originalPath.positions).sublist(0, originalPath.positions.indexOf(position));
        copyPositions.add(wallNeighbor);
        wallNeighbor.neighbours.where((e) => originalPath.positions.contains(e) && e != position).forEach((e) {
          var newPositions = List.from(copyPositions);
          newPositions.addAll(originalPath.positions.sublist(originalPath.positions.indexOf(e) - 1));
          if (originalPath.positions.length - newPositions.length >= picosecondsToSave) {
            int savedPicoseconds = originalPath.length - newPositions.length;
            if (cheatedPathsMap.containsKey(savedPicoseconds)) {
              cheatedPathsMap[savedPicoseconds] = cheatedPathsMap[savedPicoseconds]! + 1;
            } else {
              cheatedPathsMap[savedPicoseconds] = 1;
            }
          }
        });
        checkedWalls.add(wallNeighbor);
      }
    }
    return cheatedPathsMap.values.sum;
  }

  int runTask2() {
    var startPosition = positions.firstWhere((e) => e.isStartingPosition);

    var path = Path.init(startPosition);
    List<Path> paths = [];

    goToNextPosition(paths, path);
    var originalPath = paths.first;
    var picosecondsToSave = 100;
    var numberOfCheats = 20;

    var counterMap = <int, int>{};
    int counter = 0;
    for (var position in originalPath.positions) {
      var optionalPositions = originalPath.positions.where((e) =>
          ((originalPath.positions.indexOf(e) - originalPath.positions.indexOf(position)) >= picosecondsToSave) &&
          (((e.coordinate.x - position.coordinate.x).abs() + (e.coordinate.y - position.coordinate.y).abs()) <=
              numberOfCheats));
      for (var optionalPosition in optionalPositions) {
        var indexOfPosition = originalPath.positions.indexOf(position);
        var indexOfOptionalPosition = originalPath.positions.indexOf(optionalPosition);
        var distance = (optionalPosition.coordinate.x - position.coordinate.x).abs() +
            (optionalPosition.coordinate.y - position.coordinate.y).abs();

        var diff = (indexOfOptionalPosition - indexOfPosition) - distance;

        if (diff >= picosecondsToSave) {
          counter++;
          if (counterMap.containsKey(diff)) {
            counterMap[diff] = counterMap[diff]! + 1;
          } else {
            counterMap[diff] = 1;
          }
        }
      }
    }
    return counter;
  }

  void goToNextPosition(List<Path> paths, Path currentPath) {
    var position = currentPath.lastPosition;
    if (position.isEndingPosition) {
      paths.add(currentPath);
      return;
    }

    var nextPositions =
        position.getAvailableNeighbours().where((e) => currentPath.containsPosition(e) == false).toList();
    if (nextPositions.isEmpty) {
      return;
    }
    if (nextPositions.length == 1) {
      currentPath.addPosition(nextPositions.first);
      goToNextPosition(paths, currentPath);
    } else {
      for (var nextPosition in nextPositions) {
        var newPath = Path.copy(currentPath);
        newPath.addPosition(nextPosition);
        goToNextPosition(paths, newPath);
      }
    }
  }

  void drawMaze() {
    var maxX = positions.map((e) => e.coordinate.x).reduce((value, element) => value > element ? value : element);
    var maxY = positions.map((e) => e.coordinate.y).reduce((value, element) => value > element ? value : element);
    for (int y = 0; y <= maxY; y++) {
      String line = "";
      for (int x = 0; x <= maxX; x++) {
        var position = positions.firstWhere((e) => e.coordinate.x == x && e.coordinate.y == y);
        if (position.isWall) {
          line += "#";
        } else if (position.isStartingPosition) {
          line += "S";
        } else if (position.isEndingPosition) {
          line += "E";
        } else {
          line += ".";
        }
      }
      print(line);
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
    positions.add(position);
  }

  bool containsPosition(Position position) {
    return positions.any((e) => e == position);
  }

  int get length => positions.length;

  void drawPath(Maze maze) {
    int y = 0;
    while (true) {
      var yPositions = maze.positions.where((e) => e.coordinate.y == y).toList();
      if (yPositions.isEmpty) {
        break;
      }
      print(yPositions.map((e) {
        if (e.isWall) {
          return "#";
        } else if (e.isStartingPosition) {
          return "S";
        } else if (e.isEndingPosition) {
          return "E";
        } else if (containsPosition(e)) {
          return " ";
        } else {
          return ".";
        }
      }).join());
      y++;
    }
  }
}

class Position {
  final Coordinate coordinate;
  List<Position> neighbours = [];
  int? bestPathIndex;
  bool isWall = false;
  bool isStartingPosition = false;
  bool isEndingPosition = false;
  bool isBorder = false;

  Position(this.coordinate, String character, {required this.isBorder}) {
    switch (character) {
      case '#':
        isWall = true;
        break;
      case 'S':
        isStartingPosition = true;
        break;
      case 'E':
        isEndingPosition = true;
        break;
    }
  }

  bool setBestPathIndex(int index) {
    if (bestPathIndex == null || index <= bestPathIndex!) {
      bestPathIndex = index;
      return true;
    }
    return false;
  }

  void setNeighbours(List<Position> allPositions) {
    neighbours = allPositions
        .where((p) =>
            (p.coordinate.y == coordinate.y && (p.coordinate.x - coordinate.x).abs() == 1) ||
            (p.coordinate.x == coordinate.x && (p.coordinate.y - coordinate.y).abs() == 1))
        .toList();
  }

  List<Position> getAvailableNeighbours() {
    return neighbours.where((e) => e.isWall == false).toList();
  }

  List<Position> getWallNeighbours() {
    return neighbours
        .where((e) =>
            e.isWall &&
            e.isBorder == false &&
            e.neighbours.any((neighbor) => neighbor != this && neighbor.getAvailableNeighbours().isNotEmpty))
        .toList();
  }

  void resetBestPathIndex() {
    bestPathIndex = null;
  }

  @override
  toString() {
    return coordinate.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.coordinate == coordinate;
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
