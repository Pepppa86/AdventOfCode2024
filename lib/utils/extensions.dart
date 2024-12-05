import 'package:advent_of_code2024/pages/day04.dart';
import 'package:flutter/material.dart';

import '../pages/day01.dart';
import '../pages/day02.dart';
import '../pages/day03.dart';
import 'enums.dart';

extension DaysExtension on Days {
  String get title {
    switch (this) {
      case Days.day01:
        return 'Day 01';
      case Days.day02:
        return 'Day 02';
      case Days.day03:
        return 'Day 03';
      case Days.day04:
        return 'Day 04';
      case Days.day05:
        return 'Day 05';
      case Days.day06:
        return 'Day 06';
      case Days.day07:
        return 'Day 07';
      case Days.day08:
        return 'Day 08';
      case Days.day09:
        return 'Day 09';
      case Days.day10:
        return 'Day 10';
      case Days.day11:
        return 'Day 11';
      case Days.day12:
        return 'Day 12';
      case Days.day13:
        return 'Day 13';
      case Days.day14:
        return 'Day 14';
      case Days.day15:
        return 'Day 15';
      case Days.day16:
        return 'Day 16';
      case Days.day17:
        return 'Day 17';
      case Days.day18:
        return 'Day 18';
      case Days.day19:
        return 'Day 19';
      case Days.day20:
        return 'Day 20';
      case Days.day21:
        return 'Day 21';
      case Days.day22:
        return 'Day 22';
      case Days.day23:
        return 'Day 23';
      case Days.day24:
        return 'Day 24';
    }
  }

  Widget get page {
    switch (this) {
      case Days.day01:
        return const Day01();
      case Days.day02:
        return const Day02();
      case Days.day03:
        return const Day03();
      case Days.day04:
        return const Day04();
      default:
        return Container();
    }
  }
}