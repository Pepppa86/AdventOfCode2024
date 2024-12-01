import 'package:advent_of_code2024/pages/base/base_day.dart';

import '../utils/enums.dart';
import 'package:collection/collection.dart';

class Day01 extends BaseDay {
  const Day01({super.key}) : super(Days.day01, 'day01.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var list1 = <int>[];
    var list2 = <int>[];
    for (var element in lines) {
      var elementsOfLine = element.split(' ').where((element) => element.isNotEmpty);
      if(elementsOfLine.length == 2) {
        list1.add(int.parse(elementsOfLine.first));
        list2.add(int.parse(elementsOfLine.last));
      }
    }
    if(list1.isEmpty || list2.isEmpty) {
      return "Something went wrong!";
    }
    list1.sort();
    list2.sort();
    var counter = 0;
    list1.forEachIndexed((index, element) {
      counter += (element - list2[index]).abs();
    });
    return "$counter";
  }

  @override
  String? resolveTask2(List<String> lines) {
    var list1 = <int>[];
    var list2 = <int>[];
    for (var element in lines) {
      var elementsOfLine = element.split(' ').where((element) => element.isNotEmpty);
      if(elementsOfLine.length == 2) {
        list1.add(int.parse(elementsOfLine.first));
        list2.add(int.parse(elementsOfLine.last));
      }
    }
    if(list1.isEmpty || list2.isEmpty) {
      return "Something went wrong!";
    }
    var counter = 0;
    for (var element in list1) {
      counter += (element * (list2.where((element2) => element2 == element).length));
    }
    return "$counter";
  }
}
