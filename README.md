# editor_config

editor_config is a parser for [EditorConfig][EditorConfig] file.

EditorConfig helps developers define and maintain consistent coding styles between different editors and IDEs. The EditorConfig project consists of a file format for defining coding styles and a collection of text editor plugins that enable editors to read the file format and adhere to defined styles. EditorConfig files are easily readable and they work nicely with version control systems.

[EditorConfig]: http://editorconfig.org/

## Supported properties

- root
- indent_style
- indent_size
- charset *(supported values: `latin1`, `utf-8`)*
- end_of_line *(supported values: `lf`, `crlf`)*


## Example file

```ini
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
```

## Usage

A simple usage example:

```dart
final config = new EditorConfig.fromString(configString);
Properties p = config.lookup('foo.js');
print(p.indent_size); // 4
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/kseo/editor_config/issues
