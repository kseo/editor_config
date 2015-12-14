// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library editor_config.base;

import 'dart:convert';

import 'package:glob/glob.dart';
import 'package:ini/ini.dart';

typedef Properties _Lookup(String pattern);

class ParseError extends Error {
  final String message;

  ParseError(this.message);

  @override
  String toString() => message;
}

class EditorConfig {
  List<_Lookup> _lookupFuncs = [];

  static bool _parseBool(String value) {
    switch (value) {
      case 'true':
        return true;
      case 'false':
        return false;
    }
    throw new ParseError('Malformed bool value: $value');
  }

  static int _parseInt(String value) {
    try {
      return int.parse(value);
    } catch (exception) {
      throw new ParseError('Malformatted int value: $value');
    }
  }

  static Encoding _parseCharset(String value) => Encoding.getByName(value);

  static EndOfLine _parseEndOfLine(String value) {
    switch (value) {
      case 'cr':
        return EndOfLine.cr;
      case 'lf':
        return EndOfLine.lf;
      case 'crlf':
        return EndOfLine.crlf;
    }
    throw new ParseError('Malformatted end_of_line value: $value');
  }

  static IndentStyle _parseIndentStyle(String value) {
    switch (value) {
      case 'tab':
        return IndentStyle.tab;
      case 'space':
        return IndentStyle.space;
    }
    throw new ParseError('Malformatted indent_style value: $value');
  }

  static Properties _parseProperties(Config config, String glob) {
    Map<String, dynamic> propertiesMap = {};

    for (final option in config.options(glob)) {
      final value = config.get(glob, option);
      switch (option) {
        case 'indent_style':
          propertiesMap['indent_style'] = _parseIndentStyle(value);
          break;
        case 'indent_size':
          propertiesMap['indent_size'] = _parseInt(value);
          break;
        case 'tab_width':
          propertiesMap['tab_width'] = _parseInt(value);
          break;
        case 'end_of_line':
          propertiesMap['end_of_line'] = _parseEndOfLine(value);
          break;
        case 'charset':
          propertiesMap['charset'] = _parseCharset(value);
          break;
        case 'trim_trailing_whitespace':
          propertiesMap['trim_trailing_whitespace'] = _parseBool(value);
          break;
        case 'insert_final_newline':
          propertiesMap['insert_final_newline'] = _parseBool(value);
          break;
        default:
          print('Unrecognized option: $option = $value');
          break;
      }
    }

    return new Properties._(propertiesMap);
  }

  /// Creates a [EditorConfig] instance from the given [string].
  ///
  /// Throws a [ParseError] if the config is malformatted.
  EditorConfig.fromString(String string) {
    _load(string);
  }

  void _load(String string) {
    final config = new Config.fromString(string);

    for (final section in config.sections()) {
      final properties = _parseProperties(config, section);
      _lookupFuncs.add((path) =>
          new Glob(section).matches(path) ? properties : Properties.empty);
    }
  }

  /// Looks up the properties for the given [path].
  Properties lookup(String path) => _lookupFuncs.fold(
      Properties.empty,
      (Properties properties, _Lookup lookupFunc) =>
          properties.mergeWith(lookupFunc(path)));
}

enum IndentStyle { tab, space }

enum EndOfLine { lf, cr, crlf }

class Properties {
  static Properties empty = new Properties._empty();

  final Map<String, dynamic> _propertiesMap;

  /// Set to tab or space to use hard tabs or soft tabs respectively.
  IndentStyle get indentStyle => _propertiesMap['indent_style'];

  /// A whole number defining the number of columns used for each indentation
  /// level and the width of soft tabs (when supported). When set to tab,
  /// the value of tabWidth (if specified) will be used.
  int get indentSize => _propertiesMap['indent_size'];

  /// A whole number defining the number of columns used to represent a tab
  /// character.
  int get tabWidth => _propertiesMap['tab_width'];

  /// Returns how line breaks are represented.
  EndOfLine get endOfLine => _propertiesMap['end_of_line'];

  /// Returns the encoding.
  Encoding get charset => _propertiesMap['charset'];

  /// Set to true to remove any whitespace characters preceding newline
  /// characters and false to ensure it doesn't.
  bool get trimTrailingWhitespace => _propertiesMap['trim_trailing_whitespace'];

  /// Set to true ensure file ends with a newline when saving and false to
  /// ensure it doesn't.
  bool get insertFinalNewline => _propertiesMap['insert_final_newline'];

  /// Special property that should be specified at the top of the file outside
  /// of any sections. Set to `true` to stop .editorconfig files search on
  /// current file.
  bool get root => _propertiesMap['root'];

  Properties._empty() : _propertiesMap = const {};

  Properties._(this._propertiesMap);

  Properties mergeWith(Properties other) =>
      new Properties._(new Map<String, dynamic>.from(_propertiesMap)
        ..addAll(other._propertiesMap));
}
