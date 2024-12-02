import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day02 extends BaseDay {
  const Day02({super.key}) : super(Days.day02, 'day02.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var list = <List<int>>[];
    for (var element in lines) {
      var elementsOfLine = element.split(' ').where((element) => element.isNotEmpty);
      list.add(elementsOfLine.map((element) => int.parse(element)).toList());
    }

    var counter = list.where((element) => isRight(element)).length;

    return "$counter";
  }

  @override
  String? resolveTask2(List<String> lines) {
    var list = <List<int>>[];
    for (var element in lines) {
      var elementsOfLine = element.split(' ').where((element) => element.isNotEmpty);
      list.add(elementsOfLine.map((element) => int.parse(element)).toList());
    }
    var counter = 0;
    for(var element in list) {
      if(isRight(element)){
        counter++;
        continue;
      }else{
        for(int i = 0; i < element.length; i++){
          var copyList = List<int>.from(element);
          copyList.removeAt(i);
          if(isRight(copyList)){
            counter++;
            break;
          }
        }
      }
    }

    return "$counter";
  }

  bool isRight(List<int> element) {
    var incSorted = element.sorted((a, b) => a.compareTo(b)).map((e) => "$e").join(",");
    var decSorted = element.sorted((a, b) => b.compareTo(a)).map((e) => "$e").join(",");
    var copy = element.map((e) => "$e").join(",");
    if (copy != incSorted && copy != decSorted) {
      return false;
    }
    var index = 0;
    var errors = 0;
    for (var current in element) {
      if (index == 0) {
        index++;
        continue;
      } else {
        var previous = element[index - 1];
        var diff = (previous - current).abs();
        if (diff < 1 || diff > 3) {
          if(errors > 0) {
            break;
          }
          errors++;
          continue;
        }
        index++;
        if (index == element.length) {
          return true;
        }
      }
    }
    return false;
  }
}
