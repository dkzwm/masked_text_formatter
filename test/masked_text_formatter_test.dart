import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masked_text_formatter/masked_text_formatter.dart';

void main() {
  group("Mask Text Formatter Tests", () {
    group("Mask Text Formatter Type Tests", () {
      test('Simple - Type', () {
        _testType("13012345678", "130 1234 5678",
            MaskedTextFormatter.simple("344", placeholder: " "));
      });

      test('Complex - Type', () {
        _testType(
            "2333",
            "😊😊😊2333😊😊😊",
            MaskedTextFormatter.complex("😊😊😊####😊😊😊",
                mark: "#", deleteEndPlaceholder: false));
      });

      test('Mask - Type', () {
        _testType("13012345678", "0086 130 1234 5678",
            MaskedTextFormatter.mask("\\0\\086 000 0000 0000"));
      });

      test('Custom - Type', () {
        _testType(
            "51001020201001000X",
            "510 010 2020 1001 000X",
            MaskedTextFormatter.custom("000 000 0000 0000 000X", filterRules: {
              "X": RegExpMatcher.from(r'[0-9Xx]'),
              "0": RegExpMatcher.from(r'[0-9]')
            }));
      });
    });
    group("Mask Text Formatter Insert Start Tests", () {
      test('Simple - Insert Start', () {
        _testInsertStart("130", "12345678", "130 1234 5678",
            MaskedTextFormatter.simple("344", placeholder: " "));
      });

      test('Complex - Insert Start', () {
        _testInsertStart(
            "23",
            "33",
            "😊😊😊2333😊😊😊",
            MaskedTextFormatter.complex("😊😊😊####😊😊😊",
                mark: "#", deleteEndPlaceholder: false));
      });

      test('Mask - Insert Start', () {
        _testInsertStart("130", "12345678", "0086 130 1234 5678",
            MaskedTextFormatter.mask("\\0\\086 000 0000 0000"));
      });

      test('Custom - Insert Start', () {
        _testInsertStart(
            "510",
            "010202010010000",
            "510 010 2020 1001 0000",
            MaskedTextFormatter.custom("000 000 0000 0000 000X", filterRules: {
              "X": RegExpMatcher.from(r'[0-9Xx]'),
              "0": RegExpMatcher.from(r'[0-9]')
            }));
      });
    });
    group("Mask Text Formatter Insert Center Tests", () {
      test('Simple - Insert Center', () {
        _testInsertCenter("1234", "1305678", 3, "130 1234 5678",
            MaskedTextFormatter.simple("344", placeholder: " "));
      });

      test('Complex - Insert Center', () {
        _testInsertCenter(
            "23",
            "33",
            4,
            "😊😊😊2333😊😊😊",
            MaskedTextFormatter.complex("😊😊😊####😊😊😊",
                mark: "#", deleteEndPlaceholder: false));
      });

      test('Mask - Insert Center', () {
        _testInsertCenter("1234", "1305678", 8, "0086 130 1234 5678",
            MaskedTextFormatter.mask("\\0\\086 000 0000 0000"));
      });

      test('Custom - Insert Center', () {
        _testInsertCenter(
            "2020",
            "51001010010000",
            7,
            "510 010 2020 1001 0000",
            MaskedTextFormatter.custom("000 000 0000 0000 000X", filterRules: {
              "X": RegExpMatcher.from(r'[0-9Xx]'),
              "0": RegExpMatcher.from(r'[0-9]')
            }));
      });
    });
    group("Mask Text Formatter Append Tests", () {
      test('Simple - Append', () {
        _testAppend("5A6A7A8", "1301234", "130 1234 5678",
            MaskedTextFormatter.simple("344", placeholder: " "));
      });

      test('Complex - Append', () {
        _testAppend(
            "3B3B",
            "23",
            "😊😊😊2333😊😊😊",
            MaskedTextFormatter.complex("😊😊😊####😊😊😊",
                mark: "#", deleteEndPlaceholder: false));
      });

      test('Mask - Append', () {
        _testAppend("5C6C7C8", "1301234", "0086 130 1234 5678",
            MaskedTextFormatter.mask("\\0\\086 000 0000 0000"));
      });

      test('Custom - Append', () {
        _testAppend(
            "D0D0D0DX",
            "51001020201001",
            "510 010 2020 1001 000X",
            MaskedTextFormatter.custom("000 000 0000 0000 000X", filterRules: {
              "X": RegExpMatcher.from(r'[0-9Xx]'),
              "0": RegExpMatcher.from(r'[0-9]')
            }));
      });
    });
    group("Mask Text Formatter Replace Tests", () {
      test('Simple - Replace', () {
        _testReplace("1234", "1A2A3A4", "13012345678", "130 1234 5678",
            MaskedTextFormatter.simple("344", placeholder: " "));
      });

      test('Complex - Replace', () {
        _testReplace(
            "😊😊23",
            "2B3B",
            "2333",
            "😊😊😊2333😊😊😊",
            MaskedTextFormatter.complex("😊😊😊####😊😊😊",
                mark: "#", deleteEndPlaceholder: false));
      });

      test('Mask - Replace', () {
        _testReplace(" 5678", "5C6C7C8", "13012345678", "0086 130 1234 5678",
            MaskedTextFormatter.mask("\\0\\086 000 0000 0000"));
      });

      test('Custom - Replace', () {
        _testReplace(
            " 000X",
            "D2D0D0DX",
            "51001020201001000X",
            "510 010 2020 1001 200X",
            MaskedTextFormatter.custom("000 000 0000 0000 000X", filterRules: {
              "X": RegExpMatcher.from(r'[0-9Xx]'),
              "0": RegExpMatcher.from(r'[0-9]')
            }));
      });
    });
    group("Mask Text Formatter Remove Tests", () {
      test('Simple - Remove', () {
        _testRemove("5678", "13012345678", "130 1234",
            MaskedTextFormatter.simple("344", placeholder: " "));
      });

      test('Complex - Remove', () {
        _testRemove(
            "33",
            "2333",
            "😊😊😊23",
            MaskedTextFormatter.complex("😊😊😊####😊😊😊",
                mark: "#", deleteEndPlaceholder: false));
      });

      test('Mask - Remove', () {
        _testRemove("5678", "13012345678", "0086 130 1234",
            MaskedTextFormatter.mask("\\0\\086 000 0000 0000"));
      });

      test('Custom - Remove', () {
        _testRemove(
            "2020",
            "51001020201001000X",
            "510 010 1001 000",
            MaskedTextFormatter.custom("000 000 0000 0000 000X", filterRules: {
              "X": RegExpMatcher.from(r'[0-9Xx]'),
              "0": RegExpMatcher.from(r'[0-9]')
            }));
      });
    });
  });
}

void _testType(
    String input, String expectResult, MaskedTextFormatter formatter) {
  TextEditingValue currentTextEditingValue = TextEditingValue();
  final iterator = input.runes.iterator;
  int index = 0;
  while (iterator.moveNext()) {
    index += iterator.currentSize;
    final text = currentTextEditingValue.text + iterator.currentAsString;
    currentTextEditingValue = formatter.formatEditUpdate(
        currentTextEditingValue,
        TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length)));
    debugPrint(currentTextEditingValue.text);
    expect(expectResult.startsWith(currentTextEditingValue.text), true);
    expect(formatter.getRealText(), input.substring(0, index));
  }
}

void _testInsertStart(String input, String original, String expectResult,
    MaskedTextFormatter formatter) {
  TextEditingValue currentTextEditingValue = TextEditingValue(
      text: formatter.formatMask(original),
      selection: TextSelection.collapsed(offset: 0));
  currentTextEditingValue = formatter.formatEditUpdate(
      currentTextEditingValue,
      TextEditingValue(
          text: input + currentTextEditingValue.text,
          selection: TextSelection.collapsed(offset: input.length)));
  debugPrint(currentTextEditingValue.text);
  expect(expectResult == currentTextEditingValue.text, true);
}

void _testInsertCenter(String input, String original, int offset,
    String expectResult, MaskedTextFormatter formatter) {
  TextEditingValue currentTextEditingValue = TextEditingValue(
      text: formatter.formatMask(original),
      selection: TextSelection.collapsed(offset: offset));
  currentTextEditingValue = formatter.formatEditUpdate(
      currentTextEditingValue,
      TextEditingValue(
          text: currentTextEditingValue.text.substring(0, offset) +
              input +
              currentTextEditingValue.text.substring(offset),
          selection: TextSelection.collapsed(offset: offset + input.length)));
  debugPrint(currentTextEditingValue.text);
  expect(expectResult == currentTextEditingValue.text, true);
}

void _testAppend(String input, String original, String expectResult,
    MaskedTextFormatter formatter) {
  final String masked = formatter.formatMask(original);
  TextEditingValue currentTextEditingValue = TextEditingValue(
      text: masked, selection: TextSelection.collapsed(offset: masked.length));
  currentTextEditingValue = formatter.formatEditUpdate(
      currentTextEditingValue,
      TextEditingValue(
          text: masked + input,
          selection:
              TextSelection.collapsed(offset: masked.length + input.length)));
  debugPrint(currentTextEditingValue.text);
  expect(expectResult == currentTextEditingValue.text, true);
}

void _testReplace(String replacement, String input, String original,
    String expectResult, MaskedTextFormatter formatter) {
  final String masked = formatter.formatMask(original);
  final int baseOffset = masked.indexOf(replacement);
  final int extentOffset = baseOffset + replacement.length;
  TextEditingValue currentTextEditingValue = TextEditingValue(
      text: masked,
      selection:
          TextSelection(baseOffset: baseOffset, extentOffset: extentOffset));
  currentTextEditingValue = formatter.formatEditUpdate(
      currentTextEditingValue,
      TextEditingValue(
          text: masked.substring(0, baseOffset) +
              input +
              masked.substring(extentOffset),
          selection:
              TextSelection.collapsed(offset: baseOffset + input.length)));
  debugPrint(currentTextEditingValue.text);
  expect(expectResult == currentTextEditingValue.text, true);
}

void _testRemove(String needRemove, String original, String expectResult,
    MaskedTextFormatter formatter) {
  final String masked = formatter.formatMask(original);
  final int baseOffset = masked.indexOf(needRemove);
  final int extentOffset = baseOffset + needRemove.length;
  TextEditingValue currentTextEditingValue = TextEditingValue(
      text: masked,
      selection:
          TextSelection(baseOffset: baseOffset, extentOffset: extentOffset));
  currentTextEditingValue = formatter.formatEditUpdate(
      currentTextEditingValue,
      TextEditingValue(
          text: masked.substring(0, baseOffset),
          selection: TextSelection.collapsed(offset: baseOffset)));
  debugPrint(currentTextEditingValue.text);
  expect(expectResult == currentTextEditingValue.text, true);
}
