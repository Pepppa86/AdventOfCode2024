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
    var initStones = lines.join("").split(" ").map((e) => int.parse(e)).toList();

    var date = DateTime.now();
    var counter = countStones(initStones, 50);
    print("Counter: $counter - ${DateTime.now().difference(date)}");

    /*var blinkCount = 1;
    var loopCount = 25;
    var previuousCounter = 0;
    while(loopCount >= 0) {
      var counter = countStones(initStones, blinkCount);
      print("Blink: $blinkCount, Counter: $counter \t diff: ${counter - previuousCounter}");
      previuousCounter = counter;
      blinkCount++;
      loopCount--;
    }*/
    return null;
    //return counter.toString();
  }

  int countStones(List<int> initStones, int blinkCount) {
    int counter = 0;
    for (var number in initStones) {
      _blinkOnStone(blinkCount, number, () {
        counter++;
      });
    }

    return counter;
  }

  void _blinkOnStone(int blinkCount, int number, Function() callback) {
    if (blinkCount == 0) {
      callback();
    } else {
      for (var number in _createStones(number)) {
        _blinkOnStone(blinkCount - 1, number, callback);
      }
    }
  }

  List<int> _createStones(int number) {
    if (number == 0) {
      return [1];
    } else if (number.toString().length % 2 == 0) {
      int half = number.toString().length ~/ 2;
      return [
        int.parse(number.toString().substring(0, half)),
        int.parse(number.toString().substring(half))
      ];
    } else {
      return [number * 2024];
    }
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
