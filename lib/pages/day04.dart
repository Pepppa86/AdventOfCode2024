import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:flutter/material.dart';

import '../utils/enums.dart';

class Day04 extends BaseDay {
  const Day04({super.key}) : super(Days.day04, 'day04.txt');

  @override
  String? resolveTask1(List<String> lines) {
    String word = "XMAS";
    lines.map((e) => e.split('')).toList();
    var counter = findWordOccurrencesInMatrix(lines.map((e) => e.split('')).toList(), word);
    return "$counter";
  }

  @override
  String? resolveTask2(List<String> lines) {
    String word = "MAS";
    lines.map((e) => e.split('')).toList();
    var counter = findWordOccurrencesInMatrixDiagonal(lines.map((e) => e.split('')).toList(), word);
    return "$counter";
  }

  int findWordOccurrencesInMatrix(List<List<String>> matrix, String word) {
    int rows = matrix.length;
    int cols = matrix[0].length;
    int wordLength = word.length;
    int count = 0;

    // Helper function to check in a specific direction
    bool checkDirection(int x, int y, int dx, int dy) {
      for (int i = 0; i < wordLength; i++) {
        int newX = x + i * dx;
        int newY = y + i * dy;

        if (newX < 0 || newX >= rows || newY < 0 || newY >= cols || matrix[newX][newY] != word[i]) {
          return false;
        }
      }
      return true;
    }

    // Directions to check: right, down, diagonal (right-down), diagonal (left-down)
    List<List<int>> directions = [
      [0, 1], // Right
      [1, 0], // Down
      [1, 1], // Diagonal (right-down)
      [1, -1], // Diagonal (left-down)
      [0, -1], // Left
      [-1, 0], // Up
      [-1, -1], // Diagonal (left-up)
      [-1, 1], // Diagonal (right-up)
    ];

    // Traverse the matrix
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        for (var dir in directions) {
          int dx = dir[0];
          int dy = dir[1];
          if (checkDirection(row, col, dx, dy)) {
            count++;
          }
        }
      }
    }

    return count;
  }

  int findWordOccurrencesInMatrixDiagonal(List<List<String>> matrix, String word) {
    var middleCharacter = findMiddleCharacter(word);
    print("Middle character: $middleCharacter");
    int rows = matrix.length;
    int cols = matrix[0].length;
    int wordLength = word.length;
    int count = 0;

    (bool, Pair?) checkDirection(int x, int y, int dx, int dy) {
      for (int i = 0; i < wordLength; i++) {
        int newX = x + i * dx;
        int newY = y + i * dy;

        if (newX < 0 || newX >= rows || newY < 0 || newY >= cols || matrix[newX][newY] != word[i]) {
          return (false, null);
        }
      }
      // Get the middle character coordinates
      Pair? pair;
      for (int i = 0; i < wordLength; i++) {
        int newX = x + i * dx;
        int newY = y + i * dy;

        if (matrix[newX][newY] == middleCharacter) {
          pair = Pair(newX, newY);
        }
      }
      return (true, pair);
    }

    List<List<int>> directions = [
      [1, 1], // Diagonal (right-down)
      [1, -1], // Diagonal (left-down)
      [-1, -1], // Diagonal (left-up)
      [-1, 1], // Diagonal (right-up)
    ];

    // Traverse the matrix
    List<Pair> targetPairs = [];
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        for (var dir in directions) {
          int dx = dir[0];
          int dy = dir[1];
          var result = checkDirection(row, col, dx, dy);
          if (result.$1) {
            targetPairs.add(result.$2!);
          }
        }
      }
    }

    return findDuplicates(targetPairs).length;
  }

  String findMiddleCharacter(String word) {
    int length = word.length;

    if (length % 2 == 0) {
      // For even length, return the two middle characters
      return word.substring(length ~/ 2 - 1, length ~/ 2 + 1);
    } else {
      // For odd length, return the middle character
      return word[length ~/ 2];
    }
  }

  List<String> findDuplicates(List<Pair> pairs) {
    Map<String, int> occurrences = {};

    // Count occurrences of each string
    for (var pair in pairs) {
      occurrences[pair.toString()] = (occurrences[pair.toString()] ?? 0) + 1;
    }

    // Filter strings that occur more than once
    return occurrences.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toList();
  }
}

class Pair {
  final int x;
  final int y;

  Pair(this.x, this.y);

  @override
  String toString() {
    return "($x, $y)";
  }
}