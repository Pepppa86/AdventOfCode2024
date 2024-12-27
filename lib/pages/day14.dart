import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day14 extends BaseDay {
  const Day14({super.key}) : super(Days.day14, 'day14.txt');

  @override
  String? resolveTask1(List<String> lines) {
    /*var field = Field(101, 103);
    for (var line in lines) {
      var rawRobot = line.split(" ");
      if (rawRobot.length != 2) {
        return null;
      }

      var rawPosition = rawRobot[0].split("=")[1].split(",");
      var rawVelocity = rawRobot[1].split("=")[1].split(",");
      if (rawPosition.length != 2 || rawVelocity.length != 2) {
        return null;
      }

      var position = Coordinate(int.parse(rawPosition[0]), int.parse(rawPosition[1]));
      var velocity = Coordinate(int.parse(rawVelocity[0]), int.parse(rawVelocity[1]));

      field.addRobot(Robot(position, velocity));
    }

    print("Robots count: ${field.robots.length}");

    for (int i = 0; i < 100; i++) {
      field.moveRobots();
    }

    for (int i = 0; i < field.height; i++) {
      var stringBuffer = StringBuffer();
      for (int j = 0; j < field.width; j++) {
        var robotsCount = field.robots.where((robot) => robot.position.x == j && robot.position.y == i).length;
        stringBuffer.write(robotsCount == 0 ? "." : "$robotsCount");
      }
      print(stringBuffer);
    }

    var robotsOfFirstQuadrant =
        field.robots.where((robot) => robot.position.x < field.width ~/ 2 && robot.position.y < field.height ~/ 2);
    var robotsOfSecondQuadrant =
        field.robots.where((robot) => robot.position.x > field.width ~/ 2 && robot.position.y < field.height ~/ 2);
    var robotsOfThirdQuadrant =
        field.robots.where((robot) => robot.position.x < field.width ~/ 2 && robot.position.y > field.height ~/ 2);
    var robotsOfFourthQuadrant =
        field.robots.where((robot) => robot.position.x > field.width ~/ 2 && robot.position.y > field.height ~/ 2);

    print("Robots of first quadrant: ${robotsOfFirstQuadrant.length}");
    print("Robots of second quadrant: ${robotsOfSecondQuadrant.length}");
    print("Robots of third quadrant: ${robotsOfThirdQuadrant.length}");
    print("Robots of fourth quadrant: ${robotsOfFourthQuadrant.length}");

    var solution = robotsOfFirstQuadrant.length *
        robotsOfSecondQuadrant.length *
        robotsOfThirdQuadrant.length *
        robotsOfFourthQuadrant.length;
    print("Solution: $solution");
    return "$solution";*/
    return null;
  }

  @override
  String? resolveTask2(List<String> lines) {
    var field = Field(101, 103);
    for (var line in lines) {
      var rawRobot = line.split(" ");
      if (rawRobot.length != 2) {
        return null;
      }

      var rawPosition = rawRobot[0].split("=")[1].split(",");
      var rawVelocity = rawRobot[1].split("=")[1].split(",");
      if (rawPosition.length != 2 || rawVelocity.length != 2) {
        return null;
      }

      var position = Coordinate(int.parse(rawPosition[0]), int.parse(rawPosition[1]));
      var velocity = Coordinate(int.parse(rawVelocity[0]), int.parse(rawVelocity[1]));

      field.addRobot(Robot(position, velocity));
    }

    var counter = 0;
    do {
      field.moveRobots();
      counter++;
      if(field.containsConcentratedItems(30)) {
        break;
      }

      if (counter % 10000 == 0) {
        print("Counter: $counter");
      }
    } while (true);

    for (int i = 0; i < field.height; i++) {
      var stringBuffer = StringBuffer();
      for (int j = 0; j < field.width; j++) {
        var robotsCount = field.robots
            .where((robot) => robot.position.x == j && robot.position.y == i)
            .length;
        stringBuffer.write(robotsCount == 0 ? "." : "$robotsCount");
      }
      print(stringBuffer);
    }

    return "$counter";
  }
}

class Field {
  final int width;
  final int height;
  List<Robot> robots = [];

  Field(this.width, this.height);

  void addRobot(Robot robot) {
    robots.add(robot);
  }

  bool containsConcentratedItems(int threshold) {
    for (var robot in robots) {
      var items = <Robot>[];
      robot.getNeighbors(robots, items);
      if(items.length >= threshold) {
        return true;
      }
    }
    return false;
  }

  void moveRobots() {
    for (var robot in robots) {
      var currentPositionX = robot.position.x;
      var currentPositionY = robot.position.y;

      var nextPositionX = currentPositionX + robot.velocity.x;
      var nextPositionY = currentPositionY + robot.velocity.y;

      if (nextPositionX < 0) {
        nextPositionX = width - (nextPositionX).abs();
      }
      if (nextPositionX >= width) {
        nextPositionX = nextPositionX - width;
      }
      if (nextPositionY < 0) {
        nextPositionY = height - (nextPositionY).abs();
      }
      if (nextPositionY >= height) {
        nextPositionY = nextPositionY - height;
      }

      robot.position.x = nextPositionX;
      robot.position.y = nextPositionY;
    }
  }
}

class Robot {
  Coordinate position;
  Coordinate velocity;

  Robot(this.position, this.velocity);

  void getNeighbors(List<Robot> robots, List<Robot> items) {
    items.add(this);
    for (var robot in robots) {
      if(items.contains(robot)) {
        continue;
      }
      if ((robot.position.x == position.x || (robot.position.x - position.x).abs() == 1) &&
          (robot.position.y == position.y || (robot.position.y - position.y).abs() == 1)) {
        robot.getNeighbors(robots, items);
      }
    }
  }
}

class Coordinate {
  int x;
  int y;

  Coordinate(this.x, this.y);
}
