import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../utils/enums.dart';

class Day15 extends BaseDay {
  const Day15({super.key}) : super(Days.day15, 'day15.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var indexOfFirstEmptyLine = lines.indexWhere((line) => line.isEmpty);
    var mapLines = lines.sublist(0, indexOfFirstEmptyLine);
    var rawCommands = lines.sublist(indexOfFirstEmptyLine + 1).join();

    var map = Map(mapLines, rawCommands);
    map.drawMap();
    map.runCommands();

    var sum = map.positions.map((e) => e.isBox ? 100 * e.coordinate.y + e.coordinate.x : 0).sum;
    print("Solution: $sum");

    return "$sum";
  }

  @override
  String? resolveTask2(List<String> lines) {
    var indexOfFirstEmptyLine = lines.indexWhere((line) => line.isEmpty);
    var mapLines = lines.sublist(0, indexOfFirstEmptyLine);
    mapLines = mapLines
        .map((e) => e.characters.map((c) {
              if (c == 'O') {
                return "[]";
              } else if (c == '@') {
                return "@.";
              } else {
                return "$c$c";
              }
            }).join())
        .toList();
    var rawCommands = lines.sublist(indexOfFirstEmptyLine + 1).join();

    var map = MapComplex(mapLines, rawCommands);
    map.runCommands();

    print("Solution: ${map.sum}");
    return "${map.sum}";
  }
}

class Map {
  final List<Position> positions = [];
  final List<Command> commands = [];

  Map(List<String> rawLines, String rawCommands) {
    for (var y = 0; y < rawLines.length; y++) {
      for (var x = 0; x < rawLines[y].length; x++) {
        positions.add(Position(rawLines[y][x], Coordinate(x, y)));
      }
    }
    for (var rawCommand in rawCommands.characters) {
      switch (rawCommand) {
        case "^":
          commands.add(Command(Direction.up));
          break;
        case "v":
          commands.add(Command(Direction.down));
          break;
        case "<":
          commands.add(Command(Direction.left));
          break;
        case ">":
          commands.add(Command(Direction.right));
          break;
      }
    }
  }

  void runCommands() {
    for (var command in commands) {
      var currentPosition = positions.firstWhere((e) => e.isCurrentPosition);
      var movablePositions = findPositionsTillNextEmptyPosition(currentPosition, command.direction);
      if (movablePositions != null) {
        for (var movablePosition in movablePositions.reversed) {
          if (movablePosition.isEmpty()) {
            continue;
          }
          movePosition(movablePosition, command.direction);
        }
      }
    }
  }

  List<Position>? findPositionsTillNextEmptyPosition(Position currentPosition, Direction direction) {
    var movingPositions = <Position>[currentPosition];
    var nextX = currentPosition.coordinate.x;
    var nextY = currentPosition.coordinate.y;
    while (true) {
      switch (direction) {
        case Direction.up:
          nextY--;
          break;
        case Direction.down:
          nextY++;
          break;
        case Direction.left:
          nextX--;
          break;
        case Direction.right:
          nextX++;
          break;
      }
      var nextPosition = positions.firstWhere((e) => e.coordinate.x == nextX && e.coordinate.y == nextY);
      if (nextPosition.isWall) {
        return null;
      } else {
        if (nextPosition.isBox) {}
        movingPositions.add(nextPosition);
      }
      if (nextPosition.isEmpty()) {
        return movingPositions;
      }
    }
  }

  void movePosition(Position position, Direction direction) {
    Coordinate? nextCoordinate;
    switch (direction) {
      case Direction.up:
        nextCoordinate = const Coordinate(0, -1);
        break;
      case Direction.down:
        nextCoordinate = const Coordinate(0, 1);
        break;
      case Direction.left:
        nextCoordinate = const Coordinate(-1, 0);
        break;
      case Direction.right:
        nextCoordinate = const Coordinate(1, 0);
        break;
    }
    var nextPosition = positions.firstWhere((e) => e.coordinate == position.coordinate + nextCoordinate!);
    nextPosition.copyPosition(position);
    position.emptyPosition();
  }

  void drawMap() {
    int y = 0;
    while (true) {
      var yPositions = positions.where((e) => e.coordinate.y == y).toList();
      if (yPositions.isEmpty) {
        break;
      }
      print(yPositions.map((e) {
        if (e.isWall) {
          return "#";
        } else if (e.isCurrentPosition) {
          return "@";
        } else if (e.isLeftBox) {
          return "[";
        } else if (e.isRightBox) {
          return "]";
        } else if (e.isBox) {
          return "O";
        } else {
          return ".";
        }
      }).join());
      y++;
    }
  }
}

class MapComplex {
  List<Wall> walls;
  List<Box> boxes;
  late Coordinate currentPosition;
  List<Command> commands;

  MapComplex(List<String> rawLines, String rawCommands)
      : walls = [],
        boxes = [],
        commands = [] {
    for (var y = 0; y < rawLines.length; y++) {
      for (var x = 0; x < rawLines[y].length; x++) {
        String raw = rawLines[y][x];
        if (raw == "#") {
          walls.add(Wall(x, y));
        } else if (raw == "[") {
          boxes.add(Box(Coordinate(x, y), Coordinate(x + 1, y)));
        } else if (raw == "@") {
          currentPosition = Coordinate(x, y);
        }
      }
    }
    for (var rawCommand in rawCommands.characters) {
      switch (rawCommand) {
        case "^":
          commands.add(Command(Direction.up));
          break;
        case "v":
          commands.add(Command(Direction.down));
          break;
        case "<":
          commands.add(Command(Direction.left));
          break;
        case ">":
          commands.add(Command(Direction.right));
          break;
      }
    }
  }

  void runCommands() {
    for (var command in commands) {
      var nextCoordinate = currentPosition + nextCoordinateDirection(command.direction);
      if (getWall(nextCoordinate) != null) {
        continue;
      } else {
        var currentBox = getBox(nextCoordinate);
        if (currentBox != null) {
          var moveableBoxes = <Box>[currentBox];
          findAllMoveableBoxes(currentBox, command.direction, moveableBoxes);
          moveableBoxes = moveableBoxes.toSet().toList();
          if (moveableBoxes.any((box) {
            var nextBoxLeftCoordinate = box.leftCoordinate + nextCoordinateDirection(command.direction);
            var nextBoxRightCoordinate = box.rightCoordinate + nextCoordinateDirection(command.direction);
            return getWall(nextBoxLeftCoordinate) != null || getWall(nextBoxRightCoordinate) != null;
          })) {
            continue;
          } else {
            for (var box in moveableBoxes) {
              box.leftCoordinate += nextCoordinateDirection(command.direction);
              box.rightCoordinate += nextCoordinateDirection(command.direction);
            }
            currentPosition = nextCoordinate;
          }
        } else {
          currentPosition = nextCoordinate;
        }
      }
    }
  }

  void findAllMoveableBoxes(Box currentBox, Direction direction, List<Box> boxes) {
    Coordinate nextLeftBoxCoordinate = currentBox.leftCoordinate + nextCoordinateDirection(direction);
    var nextLeftBox = getBox(nextLeftBoxCoordinate);

    Coordinate nextRightBoxCoordinate = currentBox.rightCoordinate + nextCoordinateDirection(direction);
    var nextRightBox = getBox(nextRightBoxCoordinate);

    [nextLeftBox, nextRightBox].whereNotNull().where((box) => box != currentBox).toSet().forEach((box) {
      boxes.add(box);
      findAllMoveableBoxes(box, direction, boxes);
    });
  }

  Coordinate nextCoordinateDirection(Direction direction) {
    switch (direction) {
      case Direction.up:
        return const Coordinate(0, -1);
      case Direction.down:
        return const Coordinate(0, 1);
      case Direction.left:
        return const Coordinate(-1, 0);
      case Direction.right:
        return const Coordinate(1, 0);
    }
  }

  Box? getBox(Coordinate coordinate) {
    return boxes.firstWhereOrNull((e) => e.leftCoordinate == coordinate || e.rightCoordinate == coordinate);
  }

  Wall? getWall(Coordinate coordinate) {
    return walls.firstWhereOrNull((e) => e.x == coordinate.x && e.y == coordinate.y);
  }

  int get sum {
    return boxes.map((box) => 100 * box.leftCoordinate.y + box.leftCoordinate.x).sum;
  }

  void drawMap() {
    var maxX = walls.map((e) => e.x).max;
    var maxY = walls.map((e) => e.y).max;
    for (var y = 0; y <= maxY; y++) {
      var stringBuffer = StringBuffer();
      for (var x = 0; x <= maxX; x++) {
        var coordinate = Coordinate(x, y);
        var wall = getWall(coordinate);
        if (wall != null) {
          stringBuffer.write("#");
        } else {
          var box = getBox(coordinate);
          if (box != null) {
            if (box.leftCoordinate == coordinate) {
              stringBuffer.write("[");
            } else if (box.rightCoordinate == coordinate) {
              stringBuffer.write("]");
            }
            //stringBuffer.write("O");
          } else if (currentPosition == coordinate) {
            stringBuffer.write("@");
          } else {
            stringBuffer.write(".");
          }
        }
      }
      print(stringBuffer.toString());
    }
  }
}

class Position {
  final Coordinate coordinate;
  late bool isCurrentPosition = false;
  late bool isWall = false;
  late bool isBox = false;
  late bool isLeftBox = false;
  late bool isRightBox = false;

  Position(String raw, this.coordinate) {
    if (raw == "#") {
      isWall = true;
    } else if (raw == "@") {
      isCurrentPosition = true;
    } else if (raw == "O") {
      isBox = true;
    }
  }

  void copyPosition(Position position) {
    isCurrentPosition = position.isCurrentPosition;
    isBox = position.isBox;
    isLeftBox = position.isLeftBox;
    isRightBox = position.isRightBox;
  }

  void emptyPosition() {
    isCurrentPosition = false;
    isBox = false;
    isLeftBox = false;
    isRightBox = false;
  }

  bool isEmpty() {
    return !isWall && !isCurrentPosition && !isBox;
  }

  bool isNextPositionFree(List<Position> positions, Direction direction) {
    return _nextPositions(positions, direction).isEmpty();
  }

  bool isNextPositionWall(List<Position> positions, Direction direction) {
    return _nextPositions(positions, direction).isWall;
  }

  Position _nextPositions(List<Position> positions, Direction direction) {
    switch (direction) {
      case Direction.up:
        return positions.firstWhere((e) => e.coordinate == coordinate + const Coordinate(0, -1));
      case Direction.down:
        return positions.firstWhere((e) => e.coordinate == coordinate + const Coordinate(0, 1));
      case Direction.left:
        return positions.firstWhere((e) => e.coordinate == coordinate + const Coordinate(-1, 0));
      case Direction.right:
        return positions.firstWhere((e) => e.coordinate == coordinate + const Coordinate(1, 0));
    }
  }
}

class Wall extends Coordinate {
  Wall(super.x, super.y);
}

class Box {
  Coordinate leftCoordinate;
  Coordinate rightCoordinate;

  Box(this.leftCoordinate, this.rightCoordinate);

  bool isOnCoordinate(Coordinate coordinate) {
    return coordinate == leftCoordinate || coordinate == rightCoordinate;
  }

  bool isNextCoordinateFree(List<Position> positions, Direction direction) {
    return _nextPositions(positions, direction).every((element) => element.isEmpty());
  }

  bool isNextCoordinateWall(List<Position> positions, Direction direction) {
    return _nextPositions(positions, direction).any((element) => element.isWall);
  }

  List<Position> _nextPositions(List<Position> positions, Direction direction) {
    switch (direction) {
      case Direction.up:
        return positions
            .where((e) =>
                e.coordinate == leftCoordinate + const Coordinate(0, -1) ||
                e.coordinate == rightCoordinate + const Coordinate(0, -1))
            .toList();
      case Direction.down:
        return positions
            .where((e) =>
                e.coordinate == leftCoordinate + const Coordinate(0, 1) ||
                e.coordinate == rightCoordinate + const Coordinate(0, 1))
            .toList();
      case Direction.left:
        return positions.where((e) => e.coordinate == leftCoordinate + const Coordinate(-1, 0)).toList();
      case Direction.right:
        return positions.where((e) => e.coordinate == rightCoordinate + const Coordinate(1, 0)).toList();
    }
  }

  Position leftPosition(List<Position> positions) {
    return positions.firstWhere((e) => e.coordinate == leftCoordinate);
  }

  Position rightPosition(List<Position> positions) {
    return positions.firstWhere((e) => e.coordinate == rightCoordinate);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Box && other.leftCoordinate == leftCoordinate && other.rightCoordinate == rightCoordinate;
  }

  @override
  int get hashCode => leftCoordinate.hashCode ^ rightCoordinate.hashCode;
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

class Command {
  final Direction direction;

  Command(this.direction);
}

enum Direction { up, down, left, right }
