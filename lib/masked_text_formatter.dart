import 'dart:math';

import 'package:flutter/services.dart';

/// author:dkzwm
/// Used dart to write a flutter version about [FormatEditText](https://github.com/dkzwm/FormatEditText)
class MaskedTextFormatter extends TextInputFormatter {
  _SpanText _spanText;

  MaskedTextFormatter.simple({
    String formatStyle,
    String placeholder,
  }) {
    if (_SpanText.isEmpty(formatStyle)) {
      throw ArgumentError.value(
          formatStyle, "formatStyle", "Must have character");
    }
    for (int i = 0; i < formatStyle.length; i++) {
      if (!_SpanText.isDigit(formatStyle.codeUnitAt(i))) {
        throw ArgumentError.value(formatStyle, "formatStyle", "Must be digit");
      }
    }
    if (placeholder != null && placeholder.length > 1) {
      throw ArgumentError.value(
          placeholder, "placeholder", "Must be null or length one character");
    }
    placeholder =
        placeholder ?? String.fromCharCode(_SpanText._sDefaultPlaceHolder);
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < formatStyle.length; i++) {
      int count = int.parse(formatStyle.substring(i, i + 1), radix: 10);
      while (count > 0) {
        buffer.write(String.fromCharCode(_SpanText._sDigitMask));
        count -= 1;
      }
      if (i != formatStyle.length - 1) {
        buffer.write(placeholder);
      }
    }
    _spanText = _SpanText._(
        formatStyle: buffer.toString(),
        indexes: null,
        emptyPlaceholder: _SpanText._sDefaultEmptyPlaceholder,
        emptyPlaceholderString: null,
        filters: null,
        escapeMark: _SpanText._sEscapeMark);
  }

  MaskedTextFormatter.complex({
    String formatStyle,
    String mark,
  }) {
    if (_SpanText.isEmpty(formatStyle)) {
      throw ArgumentError.value(
          formatStyle, "formatStyle", "Must have character");
    }
    if (mark != null && mark.length > 1) {
      throw ArgumentError.value(
          mark, "mark", "Must be null or length one character");
    }
    mark = mark ?? String.fromCharCode(_SpanText._sDefaultMark);
    if (!formatStyle.contains(mark)) {
      throw ArgumentError.value(
          formatStyle, "formatStyle", "Must have mark:'$mark' character");
    }
    final StringBuffer buffer = StringBuffer();
    List<int> indexes = [];
    for (int i = 0; i < formatStyle.length; i++) {
      String sub = formatStyle.substring(i, i + 1);
      int subCode = sub.codeUnitAt(0);
      if (sub == mark) {
        buffer.write(String.fromCharCode(_SpanText._sDigitMask));
      } else if (subCode == _SpanText._sDigitOrLetterMask ||
          subCode == _SpanText._sDigitMask ||
          subCode == _SpanText._sLetterMask ||
          subCode == _SpanText._sEscapeMark) {
        indexes.add(buffer.length);
        buffer.write(String.fromCharCode(_SpanText._sEscapeMark));
        buffer.write(sub);
      } else {
        buffer.write(sub);
      }
    }
    _spanText = _SpanText._(
        formatStyle: buffer.toString(),
        indexes: indexes,
        emptyPlaceholder: _SpanText._sDefaultEmptyPlaceholder,
        emptyPlaceholderString: null,
        filters: null,
        escapeMark: _SpanText._sEscapeMark);
  }

  MaskedTextFormatter.mask({
    String formatStyle,
    String emptyPlaceholder,
  }) {
    if (_SpanText.isEmpty(formatStyle)) {
      throw ArgumentError.value(
          formatStyle, "formatStyle", "Must have character");
    }
    if (emptyPlaceholder != null && emptyPlaceholder.length > 1) {
      throw ArgumentError.value(emptyPlaceholder, "emptyPlaceholder",
          "Must be null or length one character");
    }
    List<int> indexes = [];
    bool nextCharIsText = false;
    for (int i = 0; i < formatStyle.length; i++) {
      int subCode = formatStyle.substring(i, i + 1).codeUnitAt(0);
      if (!nextCharIsText && subCode == _SpanText._sEscapeMark) {
        nextCharIsText = true;
        indexes.add(i);
      }
    }
    _spanText = _SpanText._(
        formatStyle: formatStyle,
        indexes: indexes,
        emptyPlaceholder: emptyPlaceholder == null
            ? _SpanText._sDefaultEmptyPlaceholder
            : emptyPlaceholder.codeUnitAt(0),
        emptyPlaceholderString: emptyPlaceholder,
        filters: null,
        escapeMark: _SpanText._sEscapeMark);
  }

  MaskedTextFormatter.custom({
    String formatStyle,
    String emptyPlaceholder,
    Map<String, RegExp> filterRules,
    String escapeMark,
  }) {
    if (_SpanText.isEmpty(formatStyle)) {
      throw ArgumentError.value(
          formatStyle, "formatStyle", "Must have character");
    }
    if (emptyPlaceholder != null && emptyPlaceholder.length > 1) {
      throw ArgumentError.value(emptyPlaceholder, "emptyPlaceholder",
          "Must be null or length one character");
    }
    if (escapeMark != null && escapeMark.length > 1) {
      throw ArgumentError.value(
          escapeMark, "escapeMark", "Must be null or length one character");
    }
    int escapeMarkCode =
        escapeMark == null ? _SpanText._sEscapeMark : escapeMark.codeUnitAt(0);
    Map<int, RegExp> filter;
    if (filterRules != null) {
      filter = Map();
      for (final key in filterRules.keys) {
        if (key.length > 1) {
          throw ArgumentError.value(
              key, "The key of filterRules", "Must be length one character");
        }
        filter[key.codeUnitAt(0)] = filterRules[key];
      }
    }
    List<int> indexes = [];
    bool nextCharIsText = false;
    for (int i = 0; i < formatStyle.length; i++) {
      int subCode = formatStyle.substring(i, i + 1).codeUnitAt(0);
      if (!nextCharIsText && subCode == escapeMarkCode) {
        nextCharIsText = true;
        indexes.add(i);
      }
    }
    _spanText = _SpanText._(
        formatStyle: formatStyle,
        indexes: indexes,
        emptyPlaceholder: emptyPlaceholder == null
            ? _SpanText._sDefaultEmptyPlaceholder
            : emptyPlaceholder.codeUnitAt(0),
        emptyPlaceholderString: emptyPlaceholder,
        filters: filter,
        escapeMark: escapeMarkCode);
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (_spanText._maskedText == null ||
        (oldValue.text == _spanText._maskedText &&
            newValue.text != _spanText._lastNewText)) {
      return _spanText._format(oldValue, newValue);
    } else if (oldValue.text == _spanText._maskedText &&
        newValue.text == _spanText._lastNewText) {
      return oldValue;
    }
    return newValue;
  }

  String formatMask(String text) {
    final buffer = StringBuffer();
    _spanText._formatMask(buffer, text, 0, 0);
    return buffer.toString();
  }

  void clear() {
    _spanText._clear();
  }

  String getRealText() {
    return _spanText._getRealText();
  }
}

class _SpanText {
  static const int _sDefaultEmptyPlaceholder = -1;

  /// ' '
  static const int _sDefaultPlaceHolder = 32;

  /// '*'
  static const int _sDefaultMark = 42;

  /// '0'
  static const int _sDigitMask = 48;

  /// 'A'
  static const int _sLetterMask = 65;

  /// '*'
  static const int _sDigitOrLetterMask = 42;

  /// '?'
  static const int _sCharacterMask = 63;

  /// '\'
  static const int _sEscapeMark = 92;
  final List<_SingleSpan> _placeholderList = [];
  final List<_SingleSpan> _tempPlaceholderList = [];
  final String formatStyle;
  final int emptyPlaceholder;
  final String emptyPlaceholderString;
  final List<int> indexes;
  final Map<int, RegExp> filters;
  final int escapeMark;
  String _maskedText;
  String _lastNewText;

  _SpanText._({
    this.formatStyle,
    this.indexes,
    this.emptyPlaceholder,
    this.emptyPlaceholderString,
    this.filters,
    this.escapeMark,
  });

  _format(TextEditingValue oldValue, TextEditingValue newValue) {
    final String oldText = oldValue.text;
    final String newText = newValue.text;
    _lastNewText = newText;
    final TextSelection oldSelection = oldValue.selection;
    final TextSelection newSelection = newValue.selection;
    final int oldSelectionStart = oldSelection.isValid ? oldSelection.start : 0;
    final int oldSelectionEnd = oldSelection.isValid ? oldSelection.end : 0;
    final int newSelectionStart = newSelection.isValid ? newSelection.start : 0;
    final int newSelectionEnd = newSelection.isValid ? newSelection.end : 0;
    int realStart = min(oldSelectionStart, newSelectionStart);
    final int styleLength = formatStyle.length;
    if (realStart > styleLength) {
      _maskedText = newValue.text;
      return newValue;
    }
    int selection = 0;
    int lastIndex = 0;
    bool isErasing = false;
    int placeholderIndex = -1;
    _tempPlaceholderList.clear();
    if (_placeholderList.length > 0) {
      for (int i = _placeholderList.length - 1; i >= 0; i--) {
        final placeholderSpan = _placeholderList[i];
        int currentIndex = placeholderSpan.index;
        if (currentIndex + 1 == realStart) {
          while (
              i - 1 >= 0 && _placeholderList[i - 1].index == currentIndex - 1) {
            currentIndex = _placeholderList[i - 1].index;
            i -= 1;
            continue;
          }
          realStart = currentIndex;
          placeholderIndex = i;
          if (i != 0) {
            _tempPlaceholderList.addAll(_placeholderList.sublist(0, i));
          }
          break;
        } else if (currentIndex + 1 < realStart) {
          placeholderIndex = i;
          _tempPlaceholderList.addAll(_placeholderList.sublist(0, i + 1));
          break;
        } else {
          placeholderIndex = i;
        }
      }
    }
    final StringBuffer buffer = StringBuffer();
    if (realStart > 0) {
      buffer.write(oldText.substring(0, realStart));
    }
    if (newSelectionStart > oldSelectionStart) {
      if (oldSelectionStart != newSelectionEnd) {
        buffer.write(newText.substring(oldSelectionStart, newSelectionEnd));
      }
    } else {
      isErasing = true;
    }
    selection = buffer.length;
    if (oldSelectionEnd < oldText.length) {
      if (placeholderIndex != -1) {
        lastIndex = oldSelectionEnd;
        for (int i = placeholderIndex; i < _placeholderList.length; i++) {
          int currentIndex = _placeholderList[i].index;
          if (currentIndex > lastIndex) {
            buffer.write(oldText.substring(lastIndex, currentIndex));
          }
          lastIndex = max(currentIndex + 1, lastIndex);
        }
        buffer.write(oldText.substring(lastIndex));
      } else {
        buffer.write(oldText.substring(oldSelectionEnd));
      }
    }
    final String needFormatText = buffer.toString();
    buffer.clear();
    if (isErasing && needFormatText.isEmpty) {
      _placeholderList.clear();
      _maskedText = needFormatText;
      return TextEditingValue(
          text: needFormatText,
          selection: newValue.selection
              .copyWith(baseOffset: selection, extentOffset: selection));
    }
    buffer.write(needFormatText.substring(0, realStart));
    final preSelectionSpanCount =
        _formatMask(buffer, needFormatText, realStart, selection);
    _maskedText = buffer.toString();
    int offset = min(selection + preSelectionSpanCount, _maskedText.length);
    return TextEditingValue(
        text: _maskedText,
        selection: newValue.selection
            .copyWith(baseOffset: offset, extentOffset: offset));
  }

  int _formatMask(StringBuffer buffer, String text, int start, int selection) {
    final int styleLength = formatStyle.length;
    int newValueLength = text.length;
    int indexInStyle = start + _rangeCountEscapeChar(start);
    int indexInText = start;
    int preSelectionSpanCount = 0;
    int lastRealTextCharLength = 0;
    int lastRealTextCharPlaceholderIndex = -1;
    bool nextCharIsText = false;
    bool emptyPlaceholderAdded = false;
    while (indexInStyle < styleLength) {
      int charInStyle = formatStyle.codeUnitAt(indexInStyle);
      if (!nextCharIsText && _isMaskChar(charInStyle)) {
        if (indexInText >= newValueLength) {
          if (emptyPlaceholder != _sDefaultEmptyPlaceholder) {
            emptyPlaceholderAdded = true;
            buffer.write(emptyPlaceholderString);
            _tempPlaceholderList.add(_SingleSpan(
                text: emptyPlaceholderString,
                index: buffer.length - 1,
                isEmptyPlaceholder: true));
            indexInText += 1;
            indexInStyle += 1;
          } else {
            break;
          }
        } else if (_isMismatchMask(charInStyle, text.codeUnitAt(indexInText))) {
          if (selection > indexInText) {
            preSelectionSpanCount -= 1;
          }
          indexInText += 1;
          continue;
        } else {
          buffer.write(text.substring(indexInText, indexInText + 1));
          lastRealTextCharLength = buffer.length;
          lastRealTextCharPlaceholderIndex = _tempPlaceholderList.length;
          indexInText += 1;
          indexInStyle += 1;
        }
      } else if (!nextCharIsText && charInStyle == escapeMark) {
        nextCharIsText = true;
        indexInStyle += 1;
      } else {
        if (selection > indexInText) {
          preSelectionSpanCount += 1;
        }
        buffer.write(String.fromCharCode(charInStyle));
        _tempPlaceholderList.add(_SingleSpan(
            text: String.fromCharCode(charInStyle),
            index: buffer.length - 1,
            isEmptyPlaceholder: false));
        nextCharIsText = false;
        indexInStyle += 1;
      }
    }
    if (indexInText < newValueLength) {
      buffer.write(text.substring(indexInText, newValueLength));
    } else if (!emptyPlaceholderAdded &&
        lastRealTextCharPlaceholderIndex != -1) {
      final String text = buffer.toString();
      buffer.clear();
      buffer.write(text.substring(0, lastRealTextCharLength));
      _tempPlaceholderList.removeRange(
          lastRealTextCharPlaceholderIndex, _tempPlaceholderList.length);
    } else if (emptyPlaceholderAdded &&
        _tempPlaceholderList.length == buffer.length) {
      buffer.clear();
      _tempPlaceholderList.clear();
    }
    _placeholderList.clear();
    _placeholderList.addAll(_tempPlaceholderList);
    return preSelectionSpanCount;
  }

  int _rangeCountEscapeChar(int end) {
    if (indexes == null || indexes.length == 0) {
      return 0;
    }
    int count = 0;
    for (final int escapeIndex in indexes) {
      if (escapeIndex < end) {
        count += 1;
      } else {
        break;
      }
    }
    return count;
  }

  void _clear() {
    _placeholderList.clear();
    _maskedText = null;
  }

  String _getRealText() {
    if (isEmpty(_maskedText)) {
      return "";
    }
    if (_placeholderList.length == 0) {
      return _maskedText;
    }
    final StringBuffer buffer = StringBuffer();
    int lastIndex = 0;
    for (final span in _placeholderList) {
      int currentIndex = span.index;
      if (currentIndex > lastIndex) {
        buffer.write(_maskedText.substring(lastIndex, currentIndex));
      }
      lastIndex = currentIndex + 1;
    }
    if (lastIndex < _maskedText.length) {
      buffer.write(_maskedText.substring(lastIndex));
    }
    return buffer.toString();
  }

  bool _isMismatchMask(int mask, int value) {
    if (filters != null) {
      if (filters.containsKey(mask)) {
        return !filters[mask].hasMatch(String.fromCharCode(value));
      }
      return false;
    }
    return mask != _sCharacterMask &&
        (mask != _sLetterMask || !isLetter(value)) &&
        (mask != _sDigitMask || !isDigit(value)) &&
        (mask != _sDigitOrLetterMask || (!isDigit(value) && !isLetter(value)));
  }

  bool _isMaskChar(int mask) {
    if (filters != null) {
      return filters.containsKey(mask);
    }
    return mask == _sDigitMask ||
        mask == _sLetterMask ||
        mask == _sDigitOrLetterMask ||
        mask == _sCharacterMask;
  }

  static bool isEmpty(String str) {
    return str == null || str.isEmpty;
  }

  static bool isDigit(int c) {
    return c >= 0x30 && c <= 0x39;
  }

  static bool isLetter(int c) {
    return (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
  }
}

class _SingleSpan {
  final String text;
  final int index;
  final bool isEmptyPlaceholder;

  _SingleSpan({
    this.text,
    this.index,
    this.isEmptyPlaceholder,
  });

  @override
  String toString() {
    return '_SingleSpan{text: $text, index: $index, isEmptyPlaceholder: $isEmptyPlaceholder}';
  }
}
