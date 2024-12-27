import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day16 extends BaseDay {
  const Day16({super.key}) : super(Days.day16, 'day16.txt');

  @override
  String? resolveTask1(List<String> lines) {
    /*var maze = Maze(lines);

    int solution = maze.runTheMaze();
    return "$solution";*/
    return null;
  }

  @override
  String? resolveTask2(List<String> lines) {
    var maze = Maze(lines);

    int solution = maze.runTheMazeForBestSeats();
    return "$solution";
  }
}

class Maze {
  final List<Position> positions = [];
  int? currentBestValue;

  Maze(List<String> rawLines) {
    for (var y = 0; y < rawLines.length; y++) {
      for (var x = 0; x < rawLines[y].length; x++) {
        positions.add(Position(rawLines[y][x], Coordinate(x, y)));
      }
    }
    var positionsToGo = positions.where((e) => e.isPlaceToGo).toList();
    for (var position in positionsToGo) {
      position.setNeighbours(positionsToGo
          .where((p) =>
              (p.coordinate.y == position.coordinate.y && (p.coordinate.x - position.coordinate.x).abs() == 1) ||
              (p.coordinate.x == position.coordinate.x && (p.coordinate.y - position.coordinate.y).abs() == 1))
          .toList());
    }
  }

  List<Position> getCrossRoads() {
    return positions.where((e) => e.isCrossRoad).toList();
  }

  List<Position> getFullCrossRoads() {
    return positions.where((e) => e.isFullCrossRoad).toList();
  }

  List<Position> getPlacesToGo() {
    return positions.where((e) => e.isPlaceToGo).toList();
  }

  List<Position> getWalls() {
    return positions.where((e) => e.isWall).toList();
  }

  int runTheMaze() {
    var direction = Direction.east;
    var currentPosition = positions.firstWhere((e) => e.isCurrentPosition);

    var path = Path.init(1, currentPosition, direction);
    List<Path> paths = [path];

    goToNextPosition(paths, path.id);

    var endPaths = paths.where((e) => e.containsEndPosition()).toList();
    print("End paths found: ${endPaths.length}");
    endPaths.sort((a, b) => a.value.compareTo(b.value));
    endPaths.first.drawPath(this);
    print("Best value: ${endPaths.first.value}, path length: ${endPaths.first.positions.length}");
    return endPaths.first.value;
  }

  int runTheMazeForBestSeats() {
    var direction = Direction.east;
    var currentPosition = positions.firstWhere((e) => e.isCurrentPosition);

    var path = Path.init(1, currentPosition, direction);
    List<Path> paths = [path];

    goToNextPosition(paths, path.id, isStrict: false);

    var endPaths = paths.where((e) => e.containsEndPosition()).toList();
    print("End paths found: ${endPaths.length}");
    endPaths.sort((a, b) => a.value.compareTo(b.value));
    var bastValue = endPaths.first.value;
    endPaths.first.drawPath(this, withDirection: false);
    var bestPositions = <Position>[];
    endPaths.where((e) => e.value == bastValue).forEach((path) {
      for (var position in path.positions) {
        if (!bestPositions.contains(position.position)) {
          bestPositions.add(position.position);
        }
      }
    });
    print("We have ${bestPositions.length} best seats on the optimal path");

    //endPaths.first.drawPath(this);
    return bestPositions.length;
  }

  void goToNextPosition(List<Path> paths, int id, {bool isStrict = true}) {
    var currentPath = paths.firstWhere((e) => e.id == id);
    var pathPosition = currentPath.lastPosition;
    var direction = pathPosition.direction;
    var position = pathPosition.position;
    if (position.isEndPosition) {
      if (currentBestValue == null || currentPath.value < currentBestValue!) {
        currentBestValue = currentPath.value;
      }
      return;
    }

    var nextPositions = position
        .nextPositions(direction)
        .where((e) =>
            currentPath.containsPosition(e) == false && e.isBetterThenBestPathValue(currentPath, isStrict: isStrict))
        .toList();
    if (nextPositions.isEmpty) {
      return;
    }

    if (isStrict) {
      if (currentBestValue != null && currentPath.value >= currentBestValue!) {
        return;
      }
    } else {
      if (currentBestValue != null && currentPath.value > currentBestValue!) {
        return;
      }
    }

    for (var nextPosition in nextPositions) {
      var nextPositionDirection = pathPosition.position.coordinate.x == nextPosition.coordinate.x
          ? (pathPosition.position.coordinate.y > nextPosition.coordinate.y ? Direction.north : Direction.south)
          : (pathPosition.position.coordinate.x > nextPosition.coordinate.x ? Direction.west : Direction.east);

      var newPath = Path.copy(paths.last.id + 1, currentPath);
      newPath.addPosition(nextPosition, nextPositionDirection);
      paths.add(newPath);
      paths.remove(currentPath);
      goToNextPosition(paths, newPath.id, isStrict: isStrict);
    }
  }
}

class Path {
  final int id;
  List<PathPosition> positions = [];
  int value = 0;

  Path.init(this.id, Position position, Direction direction) {
    positions.add(PathPosition(position, direction));
  }

  Path.copy(this.id, Path path) {
    positions = List.from(path.positions);
    value = path.value;
  }

  PathPosition get lastPosition => positions.last;

  void addPosition(Position position, Direction direction) {
    value++;
    if (positions.last.direction != direction) {
      value += 1000;
    }
    positions.add(PathPosition(position, direction));
  }

  bool containsEndPosition() {
    return positions.any((e) => e.position.isEndPosition);
  }

  bool containsPosition(Position position) {
    return positions.any((e) => e.position == position);
  }

  int get positionsToNorth {
    return positions.where((e) => e.direction == Direction.north).length;
  }

  int get positionsToEast {
    return positions.where((e) => e.direction == Direction.east).length;
  }

  int get positionsToSouth {
    return positions.where((e) => e.direction == Direction.south).length;
  }

  int get positionsToWest {
    return positions.where((e) => e.direction == Direction.west).length;
  }

  void drawPath(Maze maze, {bool withDirection = true}) {
    int y = 0;
    while (true) {
      var yPositions = maze.positions.where((e) => e.coordinate.y == y).toList();
      if (yPositions.isEmpty) {
        break;
      }
      print(yPositions.map((e) {
        if (e.isWall) {
          return "#";
        } else if (positions.any((pos) => pos.position == e)) {
          var position = positions.firstWhere((pos) => pos.position == e);
          if (withDirection) {
            if (position.direction == Direction.north) {
              return "^";
            } else if (position.direction == Direction.east) {
              return ">";
            } else if (position.direction == Direction.south) {
              return "v";
            } else if (position.direction == Direction.west) {
              return "<";
            }
          } else {
            return "O";
          }
        } else {
          return ".";
        }
      }).join());
      y++;
    }
  }
}

class PathPosition {
  final Position position;
  Direction direction;

  PathPosition(this.position, this.direction);
}

class Position {
  final Coordinate coordinate;
  bool startPosition = false;
  bool isEndPosition = false;
  bool isCurrentPosition = false;
  bool isWall = false;
  bool isPlaceToGo = false;
  List<Position> neighbours = [];
  int? bestPathValue;

  Position(String raw, this.coordinate) {
    if (raw == "#") {
      isWall = true;
    } else {
      isPlaceToGo = true;
      if (raw == "S") {
        startPosition = true;
        isCurrentPosition = true;
      } else if (raw == "E") {
        isEndPosition = true;
      }
    }
  }

  bool get isCrossRoad => neighbours.length > 2;

  bool get isFullCrossRoad => neighbours.length == 4;

  void setNeighbours(List<Position> neighbours) {
    this.neighbours = neighbours;
  }

  Position? upperNeighbour() {
    return neighbours.firstWhereOrNull((e) => e.coordinate.y == coordinate.y - 1);
  }

  Position? lowerNeighbour() {
    return neighbours.firstWhereOrNull((e) => e.coordinate.y == coordinate.y + 1);
  }

  Position? leftNeighbour() {
    return neighbours.firstWhereOrNull((e) => e.coordinate.x == coordinate.x - 1);
  }

  Position? rightNeighbour() {
    return neighbours.firstWhereOrNull((e) => e.coordinate.x == coordinate.x + 1);
  }

  Position? nextPosition(Direction pathDirection) {
    switch (pathDirection) {
      case Direction.north:
        return upperNeighbour();
      case Direction.east:
        return rightNeighbour();
      case Direction.south:
        return lowerNeighbour();
      case Direction.west:
        return leftNeighbour();
    }
  }

  List<Position> nextPositions(Direction pathDirection) {
    return Direction.values
        .where((e) => e != pathDirection.opposite)
        .map((e) => nextPosition(e))
        .whereNotNull()
        .toList();
  }

  bool isBetterThenBestPathValue(Path path, {bool isStrict = true}) {
    if (bestPathValue == null) {
      bestPathValue = path.value;
      return true;
    } else {
      if (isStrict) {
        if (bestPathValue == null || path.value < bestPathValue!) {
          bestPathValue = path.value;
          return true;
        }
        return false;
      } else {
        if (bestPathValue == null || path.value <= bestPathValue! || (path.value - bestPathValue!).abs() <= 1001) {
          bestPathValue = path.value;
          return true;
        }
      }
    }
    return false;
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
