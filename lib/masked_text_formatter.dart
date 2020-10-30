import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// author:dkzwm
/// Used dart to write a flutter version about [FormatEditText](https://github.com/dkzwm/FormatEditText)
class MaskedTextFormatter extends TextInputFormatter {
  SpanText _spanText;

  MaskedTextFormatter.simple(
    String formatStyle, {
    String placeholder,
    bool matchLength = true,
    bool deleteEndPlaceholder = true,
  }) {
    if (SpanText.isEmpty(formatStyle)) {
      throw ArgumentError.value(
          formatStyle, "formatStyle", "Must have character");
    }
    final iterator = formatStyle.runes.iterator;
    while (iterator.moveNext()) {
      if (!SpanText.isDigit(iterator.currentAsString)) {
        throw ArgumentError.value(formatStyle, "formatStyle", "Must be digit");
      }
    }
    iterator.reset();
    if (placeholder != null && placeholder.runes.length > 1) {
      throw ArgumentError.value(
          placeholder, "placeholder", "Must be null or length one character");
    }
    placeholder = placeholder ?? SpanText._sDefaultPlaceHolder;
    final StringBuffer buffer = StringBuffer();
    iterator.moveNext();
    while (iterator.current != -1) {
      int count = int.parse(iterator.currentAsString, radix: 10);
      while (count > 0) {
        buffer.write(SpanText._sDigitMask);
        count -= 1;
      }
      if (iterator.moveNext()) {
        buffer.write(placeholder);
      }
    }
    _spanText = SpanText._(buffer.toString().runes.iterator,
        matchLength: matchLength, deleteEndPlaceholder: deleteEndPlaceholder);
  }

  MaskedTextFormatter.complex(
    String formatStyle, {
    String mark,
    bool matchLength = true,
    bool deleteEndPlaceholder = true,
  }) {
    if (SpanText.isEmpty(formatStyle)) {
      throw ArgumentError.value(
          formatStyle, "formatStyle", "Must have character");
    }
    if (mark != null && mark.runes.length > 1) {
      throw ArgumentError.value(
          mark, "mark", "Must be null or length one character");
    }
    mark = mark ?? SpanText._sDefaultMark;
    if (!formatStyle.contains(mark)) {
      throw ArgumentError.value(
          formatStyle, "formatStyle", "Must have mark:'$mark' character");
    }
    final StringBuffer buffer = StringBuffer();
    List<int> indexes = [];
    final iterator = formatStyle.runes.iterator;
    var index = 0;
    while (iterator.moveNext()) {
      final next = iterator.currentAsString;
      if (next == mark) {
        buffer.write(SpanText._sDigitMask);
        index += 1;
      } else if (next == SpanText._sDigitOrLetterMask ||
          next == SpanText._sDigitMask ||
          next == SpanText._sLetterMask ||
          next == SpanText._sEscapeMark) {
        indexes.add(index);
        index += 2;
        buffer.write(SpanText._sEscapeMark);
        buffer.write(next);
      } else {
        buffer.write(next);
        index += 1;
      }
    }
    _spanText = SpanText._(buffer.toString().runes.iterator,
        matchLength: matchLength, deleteEndPlaceholder: deleteEndPlaceholder);
  }

  MaskedTextFormatter.mask(
    String formatStyle, {
    String emptyPlaceholder,
    bool matchLength = true,
    bool deleteEndPlaceholder = true,
  }) {
    if (SpanText.isEmpty(formatStyle)) {
      throw ArgumentError.value(
          formatStyle, "formatStyle", "Must have character");
    }
    if (emptyPlaceholder != null && emptyPlaceholder.runes.length > 1) {
      throw ArgumentError.value(emptyPlaceholder, "emptyPlaceholder",
          "Must be null or length one character");
    }
    _spanText = SpanText._(formatStyle.runes.iterator,
        emptyPlaceholder: emptyPlaceholder,
        matchLength: matchLength,
        deleteEndPlaceholder: deleteEndPlaceholder);
  }

  MaskedTextFormatter.custom(
    String formatStyle, {
    String emptyPlaceholder,
    Map<String, Matcher> filterRules,
    Map<String, Matcher> placeholderRules,
    String escapeMark,
    bool matchLength = true,
    bool deleteEndPlaceholder = true,
  }) {
    if (SpanText.isEmpty(formatStyle)) {
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
    escapeMark = escapeMark ?? SpanText._sEscapeMark;
    _spanText = SpanText._(formatStyle.runes.iterator,
        emptyPlaceholder: emptyPlaceholder,
        maskFilters: filterRules,
        escapeMark: escapeMark,
        matchLength: matchLength,
        deleteEndPlaceholder: deleteEndPlaceholder);
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

class SpanText {
  /// ' '
  static const String _sDefaultPlaceHolder = " ";

  /// '*'
  static const String _sDefaultMark = "*";

  /// '0'
  static const String _sDigitMask = "0";

  /// 'A'
  static const String _sLetterMask = "A";

  /// '*'
  static const String _sDigitOrLetterMask = "*";

  /// '?'
  static const String _sCharacterMask = "?";

  /// '\'
  static const String _sEscapeMark = "\\";
  final List<_SingleSpan> _spanList = [];
  final List<_SingleSpan> _tempSpanList = [];
  final StringBuffer _buffer = StringBuffer();
  final RuneIterator styleRuneIterator;
  final String emptyPlaceholder;
  final Map<String, Matcher> maskFilters;
  final Map<String, PlaceholderConverter> placeholderFilters;
  final String escapeMark;
  final bool matchLength;
  final bool deleteEndPlaceholder;
  String _maskedText;
  String _lastNewText;

  SpanText._(this.styleRuneIterator,
      {this.emptyPlaceholder = "",
      this.maskFilters,
      this.placeholderFilters,
      this.escapeMark = _sEscapeMark,
      this.matchLength,
      this.deleteEndPlaceholder});

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
    int start = min(oldSelectionStart, newSelectionStart);
    int selection = 0;
    int lastIndex = 0;
    bool isErasing = false;
    int spanIndex = -1;
    _buffer.clear();
    _tempSpanList.clear();
    if (_spanList.length > 0) {
      for (int i = _spanList.length - 1; i >= 0; i--) {
        final span = _spanList[i];
        int index = span.index;
        if (index + span.size == start) {
          int j = i - 1;
          while (j >= 0 && _spanList[j].index == index - _spanList[j].size) {
            index = _spanList[j].index;
            i -= 1;
            j = i - 1;
            continue;
          }
          start = index;
          spanIndex = i;
          if (i != 0) {
            _tempSpanList.addAll(_spanList.getRange(0, i));
          }
          break;
        } else if (index + span.size < start) {
          spanIndex = i;
          _tempSpanList.addAll(_spanList.getRange(0, i + 1));
          break;
        } else {
          spanIndex = i;
        }
      }
    }
    if (start > 0) {
      _buffer.write(oldText.substring(0, start));
    }
    if (newSelectionStart > oldSelectionStart) {
      if (oldSelectionStart != newSelectionEnd) {
        _buffer.write(newText.substring(oldSelectionStart, newSelectionEnd));
      }
    } else {
      isErasing = true;
    }
    selection = _buffer.length;
    if (oldSelectionEnd < oldText.length) {
      if (spanIndex != -1) {
        lastIndex = oldSelectionEnd;
        for (int i = spanIndex; i < _spanList.length; i++) {
          int index = _spanList[i].index;
          if (index > lastIndex) {
            _buffer.write(oldText.substring(lastIndex, index));
          }
          lastIndex = max(index + _spanList[i].size, lastIndex);
        }
        _buffer.write(oldText.substring(lastIndex));
      } else {
        _buffer.write(oldText.substring(oldSelectionEnd));
      }
    }
    final String text = _buffer.toString();
    _buffer.clear();
    if (isErasing && text.isEmpty) {
      _spanList.clear();
      _maskedText = text;
      return TextEditingValue(
          text: text,
          selection: newValue.selection
              .copyWith(baseOffset: selection, extentOffset: selection));
    }
    _buffer.write(text.substring(0, start));
    final diffSelection = _formatMask(_buffer, text, start, selection);
    _maskedText = _buffer.toString();
    int offset = min(selection + diffSelection, _maskedText.length);
    return TextEditingValue(
        text: _maskedText,
        selection: newValue.selection
            .copyWith(baseOffset: offset, extentOffset: offset));
  }

  int _formatMask(StringBuffer buffer, String text, int start, int selection) {
    final bufferLength = buffer.length;
    final textRuneIterator = text.runes.iterator;
    int diffSelection = 0;
    int preMaskedLength = bufferLength;
    int preSpanIndex = _tempSpanList.length;
    bool nextTextIsText = false;
    bool emptyPlaceholderAdded = false;
    textRuneIterator.reset(0);
    textRuneIterator.moveNext();
    styleRuneIterator.reset(0);
    styleRuneIterator.moveNext();
    int index = start;
    int current = 0;
    while (styleRuneIterator.current != -1) {
      String textInStyle = styleRuneIterator.currentAsString;
      if (current < bufferLength) {
        if (!nextTextIsText && textInStyle == escapeMark) {
          nextTextIsText = true;
          styleRuneIterator.moveNext();
        } else {
          nextTextIsText = false;
          current += textRuneIterator.currentSize;
          textRuneIterator.moveNext();
          styleRuneIterator.moveNext();
        }
        continue;
      }
      if (!nextTextIsText && _isMaskChar(textInStyle)) {
        if (textRuneIterator.current == -1) {
          final int length = emptyPlaceholder?.length ?? 0;
          if (length > 0) {
            emptyPlaceholderAdded = true;
            buffer.write(emptyPlaceholder);
            _tempSpanList.add(
                _SingleSpan(emptyPlaceholder, index, length, isEmpty: true));
            index += length;
            styleRuneIterator.moveNext();
          } else {
            break;
          }
        } else if (_isMismatchMask(
            textInStyle, buffer.toString(), textRuneIterator.currentAsString)) {
          if (selection > start) {
            diffSelection -= textRuneIterator.currentSize;
          }
          start += textRuneIterator.currentSize;
          textRuneIterator.moveNext();
        } else {
          buffer.write(textRuneIterator.currentAsString);
          preMaskedLength = buffer.length;
          preSpanIndex = _tempSpanList.length;
          start += textRuneIterator.currentSize;
          index += styleRuneIterator.currentSize;
          textRuneIterator.moveNext();
          styleRuneIterator.moveNext();
        }
      } else if (!nextTextIsText && textInStyle == escapeMark) {
        nextTextIsText = true;
        styleRuneIterator.moveNext();
      } else {
        int size = styleRuneIterator.currentSize;
        if (placeholderFilters != null &&
            placeholderFilters.containsKey(textInStyle)) {
          textInStyle = placeholderFilters[textInStyle]
              .convert(buffer.toString(), textInStyle);
          if (textInStyle == null || textInStyle.runes.length != 1) {
            throw UnsupportedError(
                "the converted must be length one character");
          }
          size = textInStyle.length;
        }
        nextTextIsText = false;
        if (selection > start) {
          diffSelection += size;
        }
        buffer.write(textInStyle);
        _tempSpanList.add(_SingleSpan(textInStyle, index, size));
        index += size;
        styleRuneIterator.moveNext();
      }
    }
    _spanList.clear();
    if (!matchLength && start < text.length) {
      buffer.write(text.substring(start, text.length));
      _spanList.addAll(_tempSpanList);
    } else if (deleteEndPlaceholder &&
        !emptyPlaceholderAdded &&
        preSpanIndex > 0) {
      final String masked = buffer.toString();
      buffer.clear();
      buffer.write(masked.substring(0, preMaskedLength));
      _tempSpanList.removeRange(preSpanIndex, _tempSpanList.length);
      _spanList.addAll(_tempSpanList);
    } else if (_tempSpanList.length == buffer.length) {
      buffer.clear();
      _tempSpanList.clear();
    } else {
      _spanList.addAll(_tempSpanList);
    }
    return diffSelection;
  }

  void _clear() {
    _spanList.clear();
    _tempSpanList.clear();
    _maskedText = null;
  }

  String _getRealText() {
    if (isEmpty(_maskedText)) {
      return "";
    }
    if (_spanList.length == 0) {
      return _maskedText;
    }
    final StringBuffer buffer = StringBuffer();
    int lastIndex = 0;
    for (final span in _spanList) {
      int currentIndex = span.index;
      if (currentIndex > lastIndex) {
        buffer.write(_maskedText.substring(lastIndex, currentIndex));
      }
      lastIndex = currentIndex + span.size;
    }
    if (lastIndex < _maskedText.length) {
      buffer.write(_maskedText.substring(lastIndex));
    }
    return buffer.toString();
  }

  bool _isMismatchMask(String mask, String previousText, String value) {
    if (maskFilters != null) {
      if (maskFilters.containsKey(mask)) {
        return !maskFilters[mask].hasMatch(previousText, value);
      }
      return false;
    }
    return mask != _sCharacterMask &&
        (mask != _sLetterMask || !isLetter(value)) &&
        (mask != _sDigitMask || !isDigit(value)) &&
        (mask != _sDigitOrLetterMask || (!isDigit(value) && !isLetter(value)));
  }

  bool _isMaskChar(String mask) {
    if (maskFilters != null) {
      return maskFilters.containsKey(mask);
    }
    return mask == _sDigitMask ||
        mask == _sLetterMask ||
        mask == _sDigitOrLetterMask ||
        mask == _sCharacterMask;
  }

  static bool isEmpty(String str) {
    return str == null || str.isEmpty;
  }

  static bool isDigit(String c) {
    if (c.length > 1) {
      return false;
    }
    final int code = c.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }

  static bool isLetter(String c) {
    if (c.length > 1) {
      return false;
    }
    final int code = c.codeUnitAt(0);
    return (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A);
  }
}

class _SingleSpan {
  final String text;
  final int index;
  final int size;
  final bool isEmpty;

  _SingleSpan(
    this.text,
    this.index,
    this.size, {
    this.isEmpty = false,
  });

  @override
  String toString() {
    return '_SingleSpan{text: $text, index: $index, size: $size, isEmpty: $isEmpty}';
  }
}

abstract class Matcher {
  bool hasMatch(String previousText, String value);
}

abstract class PlaceholderConverter {
  String convert(String previousText, String value);
}

class RegExpMatcher extends Matcher {
  RegExp _regExp;

  RegExpMatcher(RegExp regExp) {
    this._regExp = regExp;
  }

  RegExpMatcher.from(String reg) {
    this._regExp = RegExp(reg);
  }

  @override
  bool hasMatch(String previousText, String value) {
    return _regExp?.hasMatch(value) ?? false;
  }
}
