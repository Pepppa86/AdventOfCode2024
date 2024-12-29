import 'dart:math';

import 'package:advent_of_code2024/pages/base/base_day.dart';
import 'package:collection/collection.dart';

import '../utils/enums.dart';

class Day17 extends BaseDay {
  const Day17({super.key}) : super(Days.day17, 'day17.txt');

  @override
  String? resolveTask1(List<String> lines) {
    var program = Program(lines.where((line) => line.isNotEmpty).toList());
    var output = program.runProgram();
    return output;
  }

  @override
  String? resolveTask2(List<String> lines) {
    var program = Program(lines.where((line) => line.isNotEmpty).toList());
    var output = program.runProgram2();
    return output;
  }
}

class Program {
  List<Register> registers = [];
  List<int> operations = [];
  int instructionPointer = 0;

  Program(List<String> lines) {
    lines.where((element) => element.startsWith("Register")).forEach((element) {
      registers.add(Register(element.substring(element.indexOf(" ")).trim()));
    });

    var rawProgram = lines.firstWhereOrNull((element) => element.startsWith("Program"));
    if (rawProgram != null) {
      rawProgram = rawProgram.substring(rawProgram.indexOf(" ")).trim();
      operations.addAll(rawProgram.split(",").map((e) => int.parse(e)));
    }
  }

  String runProgram() {
    var output = <int>[];
    while (instructionPointer < operations.length) {
      var registerA = registers.firstWhere((element) => element.name == "A");
      var registerB = registers.firstWhere((element) => element.name == "B");
      var registerC = registers.firstWhere((element) => element.name == "C");
      var opcode = operations.elementAt(instructionPointer);
      var literalOperand = operations.elementAt(instructionPointer + 1);
      var operand = getOperandOnOperation(literalOperand, registers);

      switch (opcode) {
        case 0:
          adv(registerA, operand, registerA);
          break;
        case 1:
          bxl(registerB, literalOperand);
          break;
        case 2:
          bst(registerB, operand);
          break;
        case 3:
          var jump = jnz(registerA, operand);
          if (jump != -1) {
            instructionPointer = jump;
            continue;
          }
          break;
        case 4:
          bxc(registerB, registerC);
          break;
        case 5:
          output.add(out(operand));
          break;
        case 6:
          bdv(registerA, operand, registerB);
          break;
        case 7:
          cdv(registerA, operand, registerC);
          break;
        default:
          break;
      }
      instructionPointer += 2;
    }
    return output.join(",");
  }

  String runProgram2() {
    List<String> octalOutputs = [];
    findOutputs("", octalOutputs);
    var lowest = octalOutputs.toSet().sorted((a, b) => a.compareTo(b)).first;
    return int.parse(lowest, radix: 8).toString();
  }

  void findOutputs(String octal, List<String> octalOutputs) {
    int min = int.parse("${octal}0", radix: 8);
    int max = int.parse("${octal}7", radix: 8);

    for (var i = min; i < max; i++) {
      var copyValue = i;
      var output = "";
      while (true) {
        var currentOutValue = getCharacterValue(copyValue);
        output += "$currentOutValue";
        copyValue = copyValue ~/ 8;
        if (copyValue == 0) {
          break;
        }
      }
      var octalString = "$octal${i-min}";
      var target = operations.join("");
      if (target == output) {
        octalOutputs.add(octalString);
      } else if (target.endsWith(output)) {
        findOutputs(octalString, octalOutputs);
      }
    }
  }

  int getCharacterValue(int value) {
    return ((((value % 8) ^ 5) ^ (value ~/ pow(2, (value % 8) ^ 5))) ^ 6) % 8;
  }

  int getOperandOnOperation(int operand, List<Register> registers) {
    if (operand < 4 || operand > 6) {
      return operand;
    } else if (operand == 4) {
      return registers.firstWhereOrNull((element) => element.name == "A")?.value ?? 0;
    } else if (operand == 5) {
      return registers.firstWhereOrNull((element) => element.name == "B")?.value ?? 0;
    } else if (operand == 6) {
      return registers.firstWhereOrNull((element) => element.name == "C")?.value ?? 0;
    } else {
      return 0;
    }
  }

  //opcode 0
  void adv(Register register, int denominatorValue, Register targetRegister) {
    assert(register.name == "A");
    var numerator = register.value;
    var denominator = pow(2, denominatorValue);
    var result = numerator ~/ denominator;
    targetRegister.value = result;
  }

  //opcode 1
  void bxl(Register register, int value) {
    assert(register.name == "B");
    var result = register.value ^ value;
    register.value = result;
  }

  //opcode 2
  void bst(Register register, int value) {
    assert(register.name == "B");
    register.value = value % 8;
  }

  //opcode 3
  int jnz(Register register, int value) {
    assert(register.name == "A");
    if (register.value == 0) {
      return -1;
    } else {
      return value;
    }
  }

  //opcode 4
  void bxc(Register registerB, Register registerC) {
    assert(registerB.name == "B" && registerC.name == "C");
    var result = registerB.value ^ registerC.value;
    registerB.value = result;
  }

  //opcode 5
  int out(int value) {
    return value % 8;
  }

  //opcode 6
  void bdv(Register register, int value, Register targetRegister) {
    assert(register.name == "A" && targetRegister.name == "B");
    adv(register, value, targetRegister);
  }

  //opcode 7
  void cdv(Register register, int value, Register targetRegister) {
    assert(register.name == "A" && targetRegister.name == "C");
    adv(register, value, targetRegister);
  }
}

class Register {
  late String name;
  late int initValue;
  late int value;

  Register(String rawRegister) {
    var registerParts = rawRegister.split(":").map((e) => e.trim());
    if (registerParts.length != 2) {
      throw Exception("Invalid register format");
    } else {
      name = registerParts.elementAt(0);
      initValue = int.parse(registerParts.elementAt(1));
      value = initValue;
    }
  }
}
