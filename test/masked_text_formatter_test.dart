import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masked_text_formatter/masked_text_formatter.dart';

void main() {
  group("Mask Text Formatter Tests", () {
    test('Simple', () {
      _testFormat("13012345678", "130 1234 5678",
          MaskedTextFormatter.simple(formatStyle: "344", placeholder: " "));
    });

    test('Complex', () {
      _testFormat(
          "13012345678",
          "+86 130 1234 5678",
          MaskedTextFormatter.complex(
              formatStyle: "+86 ### #### ####", mark: "#"));
    });

    test('Mask', () {
      _testFormat("13012345678", "130 1234 5678",
          MaskedTextFormatter.mask(formatStyle: "000 0000 0000"));
    });

    test('Custom', () {
      _testFormat(
          "51001020201001000X",
          "510 010 2020 1001 000X",
          MaskedTextFormatter.custom(
              formatStyle: "000 000 0000 0000 000X",
              emptyPlaceholder: null,
              filterRules: {"X": RegExp(r'[0-9Xx]'), "0": RegExp(r'[0-9]')},
              escapeMark: "\\"));
    });
  });
}

void _testFormat(input, expectResult, formatter) {
  TextEditingValue currentTextEditingValue = TextEditingValue();
  for (var i = 0; i < input.length; i++) {
    final text = currentTextEditingValue.text + input[i];
    currentTextEditingValue = formatter.formatEditUpdate(
        currentTextEditingValue,
        TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length)));
    debugPrint(currentTextEditingValue.text);
    expect(expectResult.startsWith(currentTextEditingValue.text), true);
    expect(formatter.getRealText(), input.substring(0, i + 1));
  }
}
