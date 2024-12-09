import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day08 extends BaseDay {
  const Day08({super.key}) : super(Days.day08, 'day08.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var z = getPositions(lines);
    var positions = z.$1;
    var antennas = positions.whereType<Antenna>().toList();
    List<String> ids = antennas.map((e) => e.id).toList().toSet().toList();
    for (var id in ids) {
      var sameAntennas = antennas.where((element) => element.id == id).toList();
      var pairs = getPairs(sameAntennas);
      for (var pair in pairs) {
        var distance = pair.distance();
        int x1, x2, y1, y2;
        if (pair.antenna1.coordinate.x <= pair.antenna2.coordinate.x) {
          x1 = pair.antenna2.coordinate.x + distance.width;
          x2 = pair.antenna1.coordinate.x - distance.width;
        } else {
          x1 = pair.antenna2.coordinate.x - distance.width;
          x2 = pair.antenna1.coordinate.x + distance.width;
        }
        if (pair.antenna1.coordinate.y <= pair.antenna2.coordinate.y) {
          y1 = pair.antenna2.coordinate.y + distance.height;
          y2 = pair.antenna1.coordinate.y - distance.height;
        } else {
          y1 = pair.antenna1.coordinate.y + distance.height;
          y2 = pair.antenna2.coordinate.y - distance.height;
        }
        var coordinate1 = Coordinate(x1, y1);
        var coordinate2 = Coordinate(x2, y2);
        positions
            .where((element) => element.coordinate == coordinate1 || element.coordinate == coordinate2)
            .forEach((element) {
          element.setAntinode(true);
        });
      }
    }

    return positions.where((element) => element.isAntinode).length.toString();
  }

  @override
  String? resolveTask2(List<String> lines) {
    var z = getPositions(lines);
    var positions = z.$1;
    var borderX = z.$2;
    var borderY = z.$3;
    var antennas = positions.whereType<Antenna>().toList();
    List<String> ids = antennas.map((e) => e.id).toList().toSet().toList();
    for (var id in ids) {
      var sameAntennas = antennas.where((element) => element.id == id).toList();
      var pairs = getPairs(sameAntennas);
      for (var pair in pairs) {
        var distance = pair.distance();
        int? x1, x2, y1, y2;
        while (true) {
          if (pair.antenna1.coordinate.x <= pair.antenna2.coordinate.x) {
            x1 = x1 == null ? pair.antenna2.coordinate.x + distance.width : x1 + distance.width;
            x2 = x2 == null ? pair.antenna1.coordinate.x - distance.width : x2 - distance.width;
          } else {
            x1 = x1 == null ? pair.antenna2.coordinate.x - distance.width : x1 - distance.width;
            x2 = x2 == null ? pair.antenna1.coordinate.x + distance.width : x2 + distance.width;
          }
          if (pair.antenna1.coordinate.y <= pair.antenna2.coordinate.y) {
            y1 = y1 == null ? pair.antenna2.coordinate.y + distance.height : y1 + distance.height;
            y2 = y2 == null ? pair.antenna1.coordinate.y - distance.height : y2 - distance.height;
          } else {
            y1 = y1 == null ? pair.antenna1.coordinate.y + distance.height : y1 + distance.height;
            y2 = y2 == null ? pair.antenna2.coordinate.y - distance.height : y2 - distance.height;
          }
          var coordinate1 = Coordinate(x1, y1);
          var coordinate2 = Coordinate(x2, y2);
          var positionsToSet = positions
              .where((element) => element.coordinate == coordinate1 || element.coordinate == coordinate2)
              .toList();
          for (var element in positionsToSet) {
            element.setAntinode(true);
          }
          if (!coordinate1.isValid(borderX, borderY) && !coordinate2.isValid(borderX, borderY)) {
            break;
          }
        }
      }
    }

    var antennasWithSameIdLength = 0;
    var antennasWithSameIds = [];
    antennas.map((e) => e.id).toSet().forEach((id) {
      var antennasWithSameId = antennas.where((element) => element.id == id).length;
      if (antennasWithSameId > 1) {
        antennasWithSameIds.add(antennasWithSameId);
        antennasWithSameIdLength += antennasWithSameId;
      }
    });

    var antinodes = positions
        .where((element) => element.isAntinode && !(element is Antenna && !antennasWithSameIds.contains(element.id)))
        .length;

    print("Sum: ${antinodes + antennasWithSameIdLength}");
    return (antinodes + antennasWithSameIdLength).toString();
  }

  (List<Position>, int, int) getPositions(List<String> lines) {
    var antennas = <Position>[];
    int borderX = lines.length;
    int borderY = lines.first.length;
    lines.forEachIndexed((y, line) {
      line.trim().split('').forEachIndexed((x, e) {
        var element = e.trim();
        if (element == '.') {
          antennas.add(Position(x, y));
        } else {
          antennas.add(Antenna(element, x, y));
        }
      });
    });
    return (antennas, borderX, borderY);
  }

  List<Pair> getPairs(List<Antenna> positions) {
    var pairs = <Pair>[];
    for (var i = 0; i < positions.length; i++) {
      for (var j = i + 1; j < positions.length; j++) {
        pairs.add(Pair(positions[i], positions[j]));
      }
    }
    return pairs;
  }
}

class Position {
  final Coordinate coordinate;
  bool isAntinode = false;

  Position(int x, int y) : coordinate = Coordinate(x, y);

  void setAntinode(bool isAntinode) {
    this.isAntinode = isAntinode;
  }

  Distance distanceTo(Position other) {
    return Distance((coordinate.x - other.coordinate.x).abs(), (coordinate.y - other.coordinate.y).abs());
  }
}

class Antenna extends Position {
  final String id;

  Antenna(this.id, int x, int y) : super(x, y);

  bool isSame(Antenna other) {
    return id == other.id;
  }
}

class Coordinate {
  final int x;
  final int y;

  const Coordinate(this.x, this.y);

  bool isValid(int borderX, int borderY) {
    return x >= 0 && y >= 0 && x < borderX && y < borderY;
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
    return 'Coordinate(x: $x, y: $y)';
  }
}

class Distance {
  final int width;
  final int height;

  const Distance(this.width, this.height);

  @override
  toString() {
    return "($width, $height)";
  }
}

class Pair {
  final Antenna antenna1;
  final Antenna antenna2;

  Pair(this.antenna1, this.antenna2);

  Distance distance() {
    return antenna1.distanceTo(antenna2);
  }

  @override
  toString() {
    return "${antenna1.coordinate} - ${antenna2.coordinate}";
  }
}
