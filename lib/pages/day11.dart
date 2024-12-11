import 'package:advent_of_code2024/pages/base/base_day.dart';

import '../utils/enums.dart';

class Day11 extends BaseDay {
  const Day11({super.key}) : super(Days.day11, 'day11.txt');

  @override
  String? resolveTask1(List<String> lines) {
    /*var initStones = lines.join("").split(" ").map((e) => Stone(e)).toList();
    var copyStones = <Stone>[];
    copyStones.addAll(initStones);
    for(int i = 0; i < 25; i++) {
      var newStones = <Stone>[];
      for(var stone in copyStones) {
        newStones.addAll(stone.blink());
      }
      copyStones = newStones;
    }
    return "${copyStones.length}";*/
    return null;
  }

  @override
  String? resolveTask2(List<String> lines) {
    var initStones = lines.join("").split(" ").map((e) => Stone(int.parse(e))).toList();

    var startDate = DateTime.now();
    int counter = 0;
    var blinkCount = 50;
    for (var stone in initStones) {
      stone.blinkOnStone(blinkCount, () {
        counter++;
        /*if (counter % 100000000 == 0) {
          print("${DateTime.now()} - Counter: $counter");
        }*/
      });
    }

    /*var count = 0;
    for(var stone in initStones) {
      count += stone.getStoneCount();
    }
    print("Count: $count");
    return "$count";*/

    print("Counter: $counter - Duration: ${DateTime.now().difference(startDate)}");
    return counter.toString();
  }
}

class Stone {
  int number;
  List<Stone> descendantStones = <Stone>[];

  Stone(this.number);

  List<Stone> _createStones() {
    if (number == 0) {
      return [Stone(1)];
    } else if (digitsAreEven()) {
      int half = number.toString().length ~/ 2;
      return [
        Stone(int.parse(number.toString().substring(0, half))),
        Stone(int.parse(number.toString().substring(half)))
      ];
    } else {
      return [Stone(number * 2024)];
    }
  }

  bool digitsAreEven() {
    return number.toString().length % 2 == 0;
  }

  void blinkOnStone(int blinkCount, Function() callback) {
    if (blinkCount == 0) {
      callback();
    } else {
      for (var stone in _createStones()) {
        stone.blinkOnStone(blinkCount - 1, callback);
      }
    }
  }
}
