// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library editor_config.test;

import 'package:editor_config/editor_config.dart';
import 'package:test/test.dart';

const String configString = '''
# EditorConfig is awesome: http://EditorConfig.org

# top-most EditorConfig file
root = true

# Unix-style newlines with a newline ending every file
[*]
end_of_line = lf
insert_final_newline = true

# Matches multiple files with brace expansion notation
# Set default charset
[*.{js,py}]
charset = utf-8

# 4 space indentation
[*.py]
indent_style = space
indent_size = 4

# Tab indentation (no size specified)
[Makefile]
indent_style = tab

# Indentation override for all JS under lib directory
[lib/**.js]
indent_style = space
indent_size = 2

# Matches the exact files either package.json or .travis.yml
[{package.json,.travis.yml}]
indent_style = space
indent_size = 2
''';

void main() {
  group('EditorConfig tests', () {
    EditorConfig config;
    setUp(() {
      config = new EditorConfig.fromString(configString);
    });

    test('[*]', () {
      Properties p = config.lookup('foo.txt');
      expect(p.endOfLine, equals(EndOfLine.lf));
      expect(p.insertFinalNewline, isTrue);
    });

    test('[*.{js,py}]', () {
      Properties p = config.lookup('foo.js');
      expect(p.endOfLine, equals(EndOfLine.lf));
      expect(p.insertFinalNewline, isTrue);
      expect(p.charset.name, equals('utf-8'));
    });

    test('[*.py]', () {
      Properties p = config.lookup('foo.py');
      expect(p.endOfLine, equals(EndOfLine.lf));
      expect(p.insertFinalNewline, isTrue);
      expect(p.charset.name, equals('utf-8'));
      expect(p.indentSize, equals(4));
      expect(p.indentStyle, equals(IndentStyle.space));
    });

    test('Makefile', () {
      Properties p = config.lookup('Makefile');
      expect(p.endOfLine, equals(EndOfLine.lf));
      expect(p.insertFinalNewline, isTrue);
      expect(p.indentStyle, equals(IndentStyle.tab));
    });

    test('lib/**.js', () {
      Properties p1 = config.lookup('lib/foo.js');
      expect(p1.indentSize, equals(2));
      expect(p1.indentStyle, equals(IndentStyle.space));

      Properties p2 = config.lookup('foo.js');
      expect(p2.indentSize, isNot(equals(2)));
      expect(p2.indentStyle, isNot(equals(IndentStyle.space)));
    });

    test('[{package.json,.travis.yml}]', () {
      Properties p1 = config.lookup('package.json');
      expect(p1.endOfLine, equals(EndOfLine.lf));
      expect(p1.insertFinalNewline, isTrue);
      expect(p1.indentSize, equals(2));
      expect(p1.indentStyle, equals(IndentStyle.space));

      Properties p2 = config.lookup('.travis.yml');
      expect(p2.endOfLine, equals(EndOfLine.lf));
      expect(p2.insertFinalNewline, isTrue);
      expect(p2.indentSize, equals(2));
      expect(p2.indentStyle, equals(IndentStyle.space));
    });

    test('ParseError', () {
      const String configFileWithError1 = '''
[*]
end_of_line = x
''';

      const String configFileWithError2 = '''
[*]
indent_size = x
''';

      const String configFileWithError3 = '''
[*]
insert_final_newline = x
''';
      expect(() => new EditorConfig.fromString(configFileWithError1), throws);
      expect(() => new EditorConfig.fromString(configFileWithError2), throws);
      expect(() => new EditorConfig.fromString(configFileWithError3), throws);
    });
  });
}
