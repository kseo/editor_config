// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library editor_config.example;

import 'package:editor_config/editor_config.dart';

const String configString = '''
# EditorConfig is awesome: http://EditorConfig.org

# Unix-style newlines with a newline ending every file
[*]
end_of_line = lf
insert_final_newline = true

# 4 space indentation
[*.py]
indent_style = space
indent_size = 4
''';

main() {
  final config = new EditorConfig.fromString(configString);
  Properties p = config.lookup('foo.py');
  print(p.indentSize); // 4
  print(p.indentStyle); // IndentStyle.space
}

