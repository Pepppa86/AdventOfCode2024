import 'package:advent_of_code2024/pages/base/base_day.dart';

import '../utils/enums.dart';

class Day11 extends BaseDay {
  const Day11({super.key}) : super(Days.day11, 'day11.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var initStones = lines.join("").split(" ").toList();

    var blinkCount = 25;
    int result = 0;
    for (var stone in initStones) {
      result += _blink(int.parse(stone), blinkCount, {});
    }
    return "$result";
  }

  @override
  String? resolveTask2(List<String> lines) {
    var initStones = lines.join("").split(" ").toList();

    var blinkCount = 75;
    int result = 0;
    for (var stone in initStones) {
      result += _blink(int.parse(stone), blinkCount, {});
    }
    return "$result";
  }

  int _blink(int stone, int times, Map<int, Map<int, int>> dictionary) {
    if (times == 0) {
      return 1;
    }
    var d1 = dictionary[stone];
    if (d1 != null) {
      var e = d1[times];
      if (e != null) {
        return e;
      }
    }

    String t = stone.toString();
    int e;
    if (stone == 0) {
      e = _blink(1, times - 1, dictionary);
    } else if (t.length % 2 == 0) {
      int half = t.length ~/ 2;
      int leftStone = int.parse(t.substring(0, half));
      int rightStone = int.parse(t.substring(half));
      e = _blink(leftStone, times - 1, dictionary) + _blink(rightStone, times - 1, dictionary);
    } else {
      e = _blink(stone * 2024, times - 1, dictionary);
    }
    if (d1 == null) {
      d1 = {};
      dictionary[stone] = d1;
    }
    d1[times] = e;
    return e;
  }

  void countStonesNew(int blinkCount, Map<String, int> map) {
    print("BlinkCount: $blinkCount");
    if (blinkCount == 0) {
      return;
    }
    var entries = map.entries.where((element) => element.value > 0).toList();
    for (var entry in entries) {
      for (int i = 0; i < entry.value; i++) {
        _createStones(entry.key, map);
      }
    }
    countStonesNew(--blinkCount, map);
  }

  void _createStones(String number, Map<String, int> map) {
    map[number] = map.containsKey(number) ? map[number]! - 1 : 0;
    if (number == "0") {
      map["1"] = map.containsKey("1") ? map["1"]! + 1 : 1;
    } else if (number.length % 2 == 0) {
      int half = number.length ~/ 2;
      var first = number.substring(0, half);
      map[first] = map.containsKey(first) ? map[first]! + 1 : 1;
      var second = number.substring(half);
      map[second] = map.containsKey(second) ? map[second]! + 1 : 1;
    } else {
      var value = (int.parse(number) * 2024).toString();
      map[value] = map.containsKey(value) ? map[value]! + 1 : 1;
    }
  }

  void countStones(List<int> initStones, int blinkCount, Map<int, int> map) {
    for (var number in initStones) {
      _blinkOnStone(blinkCount, number, map);
    }
  }

  void _blinkOnStone(int blinkCount, int number, Map<int, int> map) {
    if (blinkCount == 0) {
      return;
    } else {
      map[number] = map.containsKey(number) ? map[number]! - 1 : 0;
      //_createStones(number, map);
      /*for (var number in stones) {
        map[number] = map.containsKey(number) ? map[number]! + 1 : 1;
        _blinkOnStone(blinkCount - 1, number, map);
      }*/
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
