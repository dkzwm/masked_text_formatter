# masked_text_formatter
[![Version](https://img.shields.io/pub/v/masked_text_formatter.svg)](https://pub.dartlang.org/packages/masked_text_formatter)
![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)

## [English](README_EN.md) | 中文

本库提供了一个TextInputFormatter用于TextField或者TextFormField，按照给定的格式进行格式化，或者按照给定的格式将格式化字符串设置到Text。

## 快照

![](snapshot/android.gif)
![](snapshot/ios.gif)

## 引入
添加如下到你的pubspec.yaml文件:
```
dependencies:
  masked_text_formatter: ^0.0.1
```
## 如何使用
### 导入
```dart
import 'package:masked_text_formatter/masked_text_formatter.dart';
```
### 创建
```dart
//Simple格式化
var maskedFormatter = new MaskedTextFormatter.simple("344");
//Complex格式化
var maskedFormatter = new MaskedTextFormatter.complex("😊😊😊****😊😊😊", mark: "*",
                                        deleteEndPlaceholder: false)
//Mask格式化
var maskedFormatter = new MaskedTextFormatter.mask("000 0000 0000", emptyPlaceholder: "_");
//Custom格式化
var maskedFormatter = new MaskedTextFormatter.custom("000 000 0000 0000 000X",
                                        emptyPlaceholder: "_",
                                        filterRules: {
                                          "X": RegExpMatcher.from(r'[0-9Xx]'),
                                          "0": RegExpMatcher.from(r'[0-9]')
                                        });
```
### 方法定义
|Name|Params|Desc|
|---|:---:|:---:|
|formatMask|String|格式化文本(可以用来设置到Text)|
|clear|Void|清除已格式化的字符串|
|getRealText|Void|获取真实的字符串|

### License
MIT License

Copyright (c) 2020 dkzwm

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.