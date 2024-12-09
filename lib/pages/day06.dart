import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day06 extends BaseDay {
  const Day06({super.key}) : super(Days.day06, 'day06.txt');

  @override
  String? resolveTask1(List<String> lines) {
    int borderX = lines.length;
    int borderY = lines.first.length;

    List<Position> positions = getPositions(lines);
    goToRoute(positions, borderX, borderY);

    var positionsVisited = positions.where((element) => element.hasVisited).length;
    return "$positionsVisited";
  }

  @override
  String? resolveTask2(List<String> lines) {
    int borderX = lines.length;
    int borderY = lines.first.length;

    List<Position> positions = getPositions(lines);
    List<Position> positionsWithoutObstacles =
        positions.where((element) => !element.hasObstacle && !element.isCurrentPosition).toList();
    var loopedRoutes = 0;
    var initialPositionCoordinates = positions.firstWhere((element) => element.isCurrentPosition).coordinate;
    for (var position in positionsWithoutObstacles) {
      position.hasObstacle = true;
      if (isLoopedRoute(positions, borderX, borderY)) {
        print("Looped route found at ${position.coordinate}");
        loopedRoutes++;
      }
      position.hasObstacle = false;

      var currentPosition = positions.firstWhere((element) => element.isCurrentPosition);
      currentPosition.isCurrentPosition = false;
      positions.firstWhere((element) => element.coordinate == initialPositionCoordinates).isCurrentPosition = true;
    }
    return "$loopedRoutes";
  }

  void goToRoute(List<Position> positions, int borderX, int borderY) {
    var direction = Direction.north;
    while (true) {
      Position currentPosition = positions.firstWhere((element) => element.isCurrentPosition);
      currentPosition.hasVisited = true;
      var nextCoordinate = currentPosition.nextCoordinate(direction);
      if (nextCoordinate.x < 0 || nextCoordinate.x >= borderX || nextCoordinate.y < 0 || nextCoordinate.y >= borderY) {
        break;
      }
      var nextPosition = positions.firstWhere(
          (element) => element.coordinate.x == nextCoordinate.x && element.coordinate.y == nextCoordinate.y);
      if (nextPosition.hasObstacle) {
        direction = turnRight(direction);
      } else {
        currentPosition.isCurrentPosition = false;
        nextPosition.isCurrentPosition = true;
      }
    }
  }

  bool isLoopedRoute(List<Position> positions, int borderX, int borderY) {
    Map<String, List<Direction>> visitedCoordinates = {};
    var direction = Direction.north;
    while (true) {
      Position currentPosition = positions.firstWhere((element) => element.isCurrentPosition);
      currentPosition.hasVisited = true;
      var nextCoordinate = currentPosition.nextCoordinate(direction);
      if (nextCoordinate.x < 0 || nextCoordinate.x >= borderX || nextCoordinate.y < 0 || nextCoordinate.y >= borderY) {
        return false;
      }
      var nextPosition = positions.firstWhere(
          (element) => element.coordinate.x == nextCoordinate.x && element.coordinate.y == nextCoordinate.y);
      if (nextPosition.hasObstacle) {
        direction = turnRight(direction);
      } else {
        var currentCoordinate = Coordinate(currentPosition.coordinate.x, currentPosition.coordinate.y).toString();
        if (visitedCoordinates.containsKey(currentCoordinate)) {
          if (visitedCoordinates[currentCoordinate]!.contains(direction)) {
            return true;
          } else {
            visitedCoordinates[currentCoordinate]!.add(direction);
          }
        } else {
          visitedCoordinates[currentCoordinate] = [direction];
        }
        currentPosition.isCurrentPosition = false;
        nextPosition.isCurrentPosition = true;
      }
    }
  }

  List<Position> getPositions(List<String> lines) {
    List<Position> positions = [];
    lines.forEachIndexed((y, line) {
      line.split('').forEachIndexed((x, value) {
        bool isCurrentPosition = value == '^';
        bool hasObstacle = value == '#';
        positions.add(Position(Coordinate(x, y), isCurrentPosition, hasObstacle));
      });
    });
    return positions;
  }

  Direction turnRight(Direction direction) {
    switch (direction) {
      case Direction.north:
        return Direction.east;
      case Direction.east:
        return Direction.south;
      case Direction.south:
        return Direction.west;
      case Direction.west:
        return Direction.north;
    }
  }
}

class Position {
  Coordinate coordinate;
  bool hasObstacle;
  bool isCurrentPosition;
  bool hasVisited = false;

  Position(this.coordinate, this.isCurrentPosition, this.hasObstacle);

  Coordinate nextCoordinate(Direction direction) {
    switch (direction) {
      case Direction.north:
        return Coordinate(coordinate.x, coordinate.y - 1);
      case Direction.east:
        return Coordinate(coordinate.x + 1, coordinate.y);
      case Direction.south:
        return Coordinate(coordinate.x, coordinate.y + 1);
      case Direction.west:
        return Coordinate(coordinate.x - 1, coordinate.y);
    }
  }
}

enum Direction { north, east, south, west }

class Coordinate {
  int x, y;

  Coordinate(this.x, this.y);

  @override
  toString() {
    return "($x, $y)";
  }
}
