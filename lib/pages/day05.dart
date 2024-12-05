import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day05 extends BaseDay {
  const Day05({super.key}) : super(Days.day05, 'day05.txt');

  @override
  String? resolveTask1(List<String> lines) {
    List<Page> pageList = getPages(lines);
    List<Sequence> sequenceList = getSequences(lines, pageList);

    var correctSequences = sequenceList.where((element) => element.isCorrect());
    var pagesInMiddle = correctSequences.map((e) => e.pages[e.pages.length ~/ 2]).toList();
    var sum = pagesInMiddle.fold(0, (previousValue, element) => previousValue + element.number);

    return "$sum";
  }

  @override
  String? resolveTask2(List<String> lines) {
    List<Page> pageList = getPages(lines);
    List<Sequence> sequenceList = getSequences(lines, pageList);

    var incorrectSequences = sequenceList.where((element) => !element.isCorrect()).toList();
    for (var sequence in incorrectSequences) {
      sequence.reorderTillCorrect();
    }
    var pagesInMiddle = incorrectSequences.map((e) => e.pages[e.pages.length ~/ 2]).toList();
    var sum = pagesInMiddle.fold(0, (previousValue, element) => previousValue + element.number);

    return "$sum";
  }

  List<Page> getPages(List<String> lines) {
    List<Page> pageList = [];
    for (var line in lines) {
      if (line.contains('|')) {
        var pages = line.split('|');
        if (pages.length == 2) {
          var page1Number = int.parse(pages[0].trim());
          var page2Number = int.parse(pages[1].trim());
          var page1 = pageList.firstWhereOrNull((element) => element.number == page1Number);
          if (page1 == null) {
            page1 = Page(page1Number);
            pageList.add(page1);
          }
          var page2 = pageList.firstWhereOrNull((element) => element.number == page2Number);
          if (page2 == null) {
            page2 = Page(page2Number);
            pageList.add(page2);
          }
          page1.addPageAfter(page2);
          page2.addPageBefore(page1);
        }
      }
    }
    return pageList;
  }

  List<Sequence> getSequences(List<String> lines, List<Page> pageList) {
    List<Sequence> sequenceList = [];
    for (var line in lines) {
      if (line.contains(",")) {
        var pages = line.split(',').map((e) => int.parse(e.trim())).toList();
        sequenceList.add(Sequence(pages.map((e) => pageList.firstWhere((element) => element.number == e)).toList()));
      }
    }
    return sequenceList;
  }
}

class Page {
  int number;
  List<Page> pagesAfter = [];
  List<Page> pagesBefore = [];

  Page(this.number);

  void addPageAfter(Page page) {
    pagesAfter.add(page);
  }

  void addPageBefore(Page page) {
    pagesBefore.add(page);
  }

  bool isIncorrect(Page page) {
    if(pagesBefore.contains(page)) {
      return true;
    }else if(page.pagesAfter.contains(this)) {
      return true;
    }
    return false;
  }

  bool isBefore(Page page) {
    return pagesBefore.contains(page);
  }

  bool isAfter(Page page) {
    return pagesAfter.contains(page);
  }
}

class Sequence {
  List<Page> pages;

  Sequence(this.pages);

  bool isCorrect() {
    for (int i = 0; i < pages.length - 1; i++) {
      var page1 = pages[i];
      var page2 = pages[i + 1];
      if (page1.isIncorrect(page2)) {
        return false;
      }
    }
    return true;
  }

  void reorderTillCorrect() {
    for (int i = 0; i < pages.length - 1; i++) {
      var page1 = pages[i];
      var page2 = pages[i + 1];
      if (page1.isIncorrect(page2)) {
        swapElements(pages, i, i + 1);
      }
    }
    if (!isCorrect()) {
      reorderTillCorrect();
    }
  }

  void swapElements(List list, int index1, int index2) {
    if (index1 < 0 || index2 < 0 || index1 >= list.length || index2 >= list.length) {
      throw ArgumentError("Indices are out of bounds.");
    }

    var temp = list[index1];
    list[index1] = list[index2];
    list[index2] = temp;
  }
}
