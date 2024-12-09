import 'package:advent_of_code2024/pages/base/base_day.dart';

import '../utils/enums.dart';

class Day09 extends BaseDay {
  const Day09({super.key}) : super(Days.day09, 'day09.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var result = lines.join().split('').map((e) => int.parse(e.trim())).toList();
    List<dynamic> list = [];
    int id = 0;
    for (var i = 0; i < result.length; i++) {
      var current = result[i];
      for (int j = 0; j < current; j++) {
        if (i % 2 == 0) {
          list.add(id);
        } else {
          list.add('.');
        }
      }
      if (i % 2 == 0) {
        id++;
      }
    }

    List<dynamic> resultList = [];
    int step = 0;
    for (var i = 0; i < list.length; i++) {
      var current = list[i];
      if (i > (list.length - 1) - step) {
        resultList.add('.');
      } else if (current == '.') {
        while (true) {
          int currentStep = (list.length - 1) - step;
          if (list[currentStep] == '.') {
            step++;
            continue;
          } else {
            break;
          }
        }
        resultList.add(list[(list.length - 1) - step]);
        step++;
      } else {
        resultList.add(current);
      }
    }

    int sum = 0;
    for (int i = 0; i < resultList.length; i++) {
      var currentRaw = resultList[i];
      if (currentRaw == '.') {
        continue;
      }
      int current = int.parse(currentRaw.toString());
      sum += (current * i);
    }
    return "$sum";
  }

  @override
  String? resolveTask2(List<String> lines) {
    var result = lines.join().split('').map((e) => int.parse(e.trim())).toList();
    List<Slot> slots = [];
    int id = 0;
    for (var i = 0; i < result.length; i++) {
      var current = result[i];
      Slot slot = Slot();
      for (int j = 0; j < current; j++) {
        if (i % 2 == 0) {
          slot.addItem(id);
        } else {
          slot.addItem(null);
        }
      }
      slots.add(slot);
      if (i % 2 == 0) {
        id++;
      }
    }

    for (int i = slots.length - 1; i >= 0; i--) {
      var currentSlot = slots[i];
      if (currentSlot.isEmpty()) {
        continue;
      }
      for (var slot in slots) {
        if (slot == currentSlot) {
          break;
        }
        if (slot.addIfFree(currentSlot)) {
          currentSlot.freeUp();
          break;
        }
      }
    }

    List<int?> items = [];
    slots.map((slot) => slot.slots.map((e) => e)).toList().forEach((element) {
      items.addAll(element);
    });

    int sum = 0;
    for (int i = 0; i < items.length; i++) {
      var currentRaw = items[i];
      if (currentRaw == null) {
        continue;
      }
      int current = int.parse(currentRaw.toString());
      sum += (current * i);
    }

    return "$sum";
  }
}

class Slot {
  List<int?> slots = List.empty(growable: true);

  Slot();

  int freeSlots() {
    return slots.where((element) => element == null).length;
  }

  int? getItem(int index) {
    return slots[index];
  }

  void addItem(int? value) {
    slots.add(value);
  }

  void removeItem(int id) {
    if (slots.contains(id)) {
      slots[slots.lastIndexOf(id)] = null;
    }
  }

  bool addIfFree(Slot slot) {
    int requiredFreeSpace = slot.slots.where((element) => element != null).length;
    if (slots.where((element) => element == null).length >= requiredFreeSpace) {
      for (int i = 0; i < slot.slots.length; i++) {
        if (slot.slots[i] != null) {
          slots[slots.indexOf(null)] = slot.slots[i];
        }
      }
      return true;
    }
    return false;
  }

  void freeUp() {
    slots = slots.map((e) => null).toList();
  }

  bool isEmpty() {
    return slots.every((element) => element == null);
  }
}
