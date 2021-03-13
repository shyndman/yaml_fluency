import 'dart:convert';

import 'package:meta/meta.dart';

typedef ObjectWriteDelegate = void Function(YamlMapWriter);
typedef ListWriteDelegate = void Function(YamlListWriter);

class YamlScalarWriter extends _YamlWriter {
  YamlScalarWriter({
    StringSink destination,
    // The scalar writer only uses this value for indenting multiline strings
    int indentation,
  }) : super(destination: destination, indentation: indentation);

  void writeBool(bool value) => _write(value);
  void writeDate(DateTime date) => _write(date.toIso8601String());
  void writeNumber(num value) => _write(value);

  void writeString(String value, {bool multiline = false, bool quoted}) {
    // The default is to quote, unless we're outputting multiline
    quoted ??= !multiline;

    if (multiline && quoted) {
      throw ArgumentError('Strings cannot be quoted and multiline');
    }

    if (multiline) {
      _writeMultilineString(value);
    } else {
      _writeSinglelineString(value, quoted: quoted);
    }
  }

  void _writeSinglelineString(String string, {bool quoted}) {
    if (quoted) {
      final escapedString =
          string.replaceAll('"', r'\"').replaceAll('\n', r'\n');
      _write('"$escapedString"');
    } else {
      _write(string);
    }
  }

  void _writeMultilineString(String value) {
    _write('|-\n');
    _write(_prefixMultilineString(value, prefix: _indentWhitespace));
  }
}

class YamlListWriter extends _YamlWriter {
  YamlListWriter({
    StringSink destination,
    int indentation,
  }) : super(destination: destination, indentation: indentation) {
    _scalarWriter =
        YamlScalarWriter(destination: _sink, indentation: _indentation + 2);
  }

  YamlScalarWriter _scalarWriter;

  void writeBool(bool value) {
    _writeListItem();
    _scalarWriter.writeBool(value);
    newline();
  }

  void writeDate(DateTime value) {
    _writeListItem();
    _scalarWriter.writeDate(value);
    newline();
  }

  void writeNumber(num value) {
    _writeListItem();
    _scalarWriter.writeNumber(value);
    newline();
  }

  void writeString(String value, {bool multiline = false, bool quoted}) {
    _writeListItem();
    _scalarWriter.writeString(value, multiline: multiline, quoted: quoted);
    newline();
  }

  void writeMap(ObjectWriteDelegate delegate) {
    _writeListItem();
    final mapWriter = YamlMapWriter(
        destination: _sink,
        indentation: _indentation + 2,
        omitFirstIndent: true);
    try {
      delegate(mapWriter);
      if (!mapWriter._hasWritten) {
        newline();
      }
    } finally {
      mapWriter._disposed = true;
    }
  }

  void writeList(ListWriteDelegate delegate) {
    _writeListItem();
    newline(); // Lists begin on the line after the key
    final listWriter =
        YamlListWriter(destination: _sink, indentation: _indentation + 2);
    try {
      delegate(listWriter);
      if (!listWriter._hasWritten) {
        newline();
      }
    } finally {
      listWriter._disposed = true;
    }
  }

  void _writeListItem() {
    _write('$_indentWhitespace- ');
  }
}

class YamlMapWriter extends _YamlWriter {
  YamlMapWriter({
    StringSink destination,
    int indentation,
    this.omitFirstIndent = false,
    this.writeNullEntries = false,
  }) : super(destination: destination, indentation: indentation) {
    _scalarWriter =
        YamlScalarWriter(destination: _sink, indentation: _indentation + 2);
  }

  /// `true` if indentation on the first written field should be omitted
  final bool omitFirstIndent;

  /// Used in conjunction with [omitFirstIndent]
  bool _firstFieldWritten = false;

  /// `true` if `null` entries should be written. `false` if they should be
  /// omitted from the output entirely.
  final bool writeNullEntries;

  /// Used to write scalar YAML values.
  YamlScalarWriter _scalarWriter;

  void writeBool(String key, bool value) {
    _writeEntry(key, () {
      _scalarWriter.writeBool(value);
      return true;
    }, isValueNull: value == null);
  }

  void writeDate(String key, DateTime value) {
    _writeEntry(key, () {
      _scalarWriter.writeDate(value);
      return true;
    }, isValueNull: value == null);
  }

  void writeNumber(String key, num value) {
    _writeEntry(key, () {
      _scalarWriter.writeNumber(value);
      return true;
    }, isValueNull: value == null);
  }

  void writeString(
    String key,
    String value, {
    bool multiline = false,
    bool quoted,
  }) {
    _writeEntry(key, () {
      _scalarWriter.writeString(value, multiline: multiline, quoted: quoted);
      return true;
    }, isValueNull: value == null);
  }

  void writeMap(String key, ObjectWriteDelegate delegate) {
    _writeEntry(key, () {
      newline(); // Maps begin on the line after the key
      final mapWriter =
          YamlMapWriter(destination: _sink, indentation: _indentation + 2);
      try {
        delegate(mapWriter);
        return !mapWriter._hasWritten;
      } finally {
        mapWriter._disposed = true;
      }
    });
  }

  void writeList(String key, ListWriteDelegate delegate) {
    _writeEntry(key, () {
      newline(); // Lists begin on the line after the key
      final listWriter =
          YamlListWriter(destination: _sink, indentation: _indentation + 2);
      try {
        delegate(listWriter);
        return !listWriter._hasWritten;
      } finally {
        listWriter._disposed = true;
      }
    });
  }

  void _writeEntry(
    String key,
    bool Function() valueWriter, {
    bool isValueNull = false,
  }) {
    if (_disposed) {
      throw StateError('Write attempted to disposed YamlWriter');
    }

    if (isValueNull && !writeNullEntries) {
      return;
    }

    if (!omitFirstIndent || (omitFirstIndent && _firstFieldWritten)) {
      _write(_indentWhitespace);
    }

    _write('$key: ');

    var writeNewline = true;
    if (isValueNull) {
      _write('null');
    } else {
      writeNewline = valueWriter();
    }
    if (writeNewline) newline();

    _firstFieldWritten = true;
  }
}

class _YamlWriter {
  _YamlWriter({
    StringSink destination,
    int indentation,
  })  : _sink = destination ?? StringBuffer(),
        _indentation = indentation ?? 0,
        _indentWhitespace = ' ' * (indentation ?? 0);

  final StringSink _sink;

  /// The number of spaces to indent output
  final int _indentation;

  /// The string used to prefix writes
  final String _indentWhitespace;

  /// If `true`, writes will fail. Used to ensure that a writer is not used
  /// outside of its write block.
  bool _disposed = false;

  /// `true` if this writer has written at least once.
  bool _hasWritten = false;

  /// Writes a comment. The provided string can be multiline.
  void writeComment(String comment) {
    _write(_prefixMultilineString(comment, prefix: '$_indentWhitespace# '));
    newline();
  }

  /// Writes a newline
  void newline() => _write('\n');

  void _write(dynamic obj) {
    if (_disposed) {
      throw StateError('Write attempted on disposed YamlWriter');
    }
    _sink.write(obj);
    _hasWritten = true;
  }

  String _prefixMultilineString(String value, {@required String prefix}) {
    return LineSplitter.split(value).map((line) => '$prefix$line').join('\n');
  }

  @override
  String toString() => _sink.toString();
}
