import 'package:yaml/yaml.dart';
import 'package:yaml_fluency/yaml_fluency.dart';
import 'package:test/test.dart';

void main() {
  group('YAML writing tests', () {
    test('Scalar entries', () {
      final mapWriter = YamlMapWriter()
        ..writeBool('bool', true)
        ..writeNumber('int', 1)
        ..writeNumber('double', 4.5)
        ..writeString('unquoted_string', 'This is a test', quoted: false)
        ..writeString('single_line_string', 'This is a test')
        ..writeString(
            'single_line_with_escapables', "This is 'a test'\nor something")
        ..writeString('multi_line_string', 'This\nis\na\nmultiline\nstring',
            multiline: true);

      expect(
        loadYaml(mapWriter.toString()),
        {
          'bool': true,
          'int': 1,
          'double': 4.5,
          'single_line_string': 'This is a test',
          'unquoted_string': 'This is a test',
          'single_line_with_escapables': "This is 'a test'\nor something",
          'multi_line_string': 'This\nis\na\nmultiline\nstring',
        },
      );
    });

    group('Maps', () {
      test('Formatted representation of nested maps', () {
        final mapWriter = YamlMapWriter()
          ..writeMap(
            'a',
            (w) => w
              ..writeBool('a', true)
              ..writeMap('b', (w) => w..writeNumber('a', 5))
              ..writeMap('c', (w) => w..writeNumber('a', 5)),
          )
          ..writeMap(
            'b',
            (w) => w
              ..writeMap(
                'a',
                (w) => w
                  ..writeMap(
                    'a',
                    (w) => w..writeBool('a', true),
                  ),
              ),
          )
          ..writeString('unquoted_string', 'no quotes', quoted: false);

        expect(
            mapWriter.toString(),
            'a: \n'
            '  a: true\n'
            '  b: \n'
            '    a: 5\n'
            '  c: \n'
            '    a: 5\n'
            'b: \n'
            '  a: \n'
            '    a: \n'
            '      a: true\n'
            'unquoted_string: no quotes\n');
      });

      test('Nested maps', () {
        final mapWriter = YamlMapWriter()
          ..writeMap(
            'a',
            (w) => w
              ..writeBool('a', true)
              ..writeMap('b', (w) => w..writeNumber('a', 5)),
          )
          ..writeMap(
            'b',
            (w) => w
              ..writeMap(
                'a',
                (w) => w
                  ..writeMap(
                    'a',
                    (w) => w..writeBool('a', true),
                  ),
              ),
          );

        expect(
          loadYaml(mapWriter.toString()),
          {
            'a': {
              'a': true,
              'b': {'a': 5}
            },
            'b': {
              'a': {
                'a': {'a': true}
              }
            }
          },
        );
      });

      test('Nested lists', () {
        final mapWriter = YamlMapWriter()
          ..writeList(
              'list',
              (w) => w
                ..writeBool(true)
                ..writeNumber(4));

        expect(
          loadYaml(mapWriter.toString()),
          {
            'list': [true, 4],
          },
        );
      });

      test('Can omit null entries', () {
        final mapWriter = YamlMapWriter(writeNullEntries: false)
          ..writeBool('flag', null);
        expect(mapWriter.toString(), '');
      });

      test('Throw error if writer is disposed', () {
        YamlMapWriter nestedMapWriter;
        YamlMapWriter().writeMap('nested', (w) => nestedMapWriter = w);

        expect(
          () => nestedMapWriter.writeBool('no', false),
          throwsStateError,
        );
      });
    });

    group('Lists', () {
      test('Scalars', () {
        final listWriter = YamlListWriter()
          ..writeBool(true)
          ..writeNumber(1)
          ..writeString('Multiline\nstring', multiline: true)
          ..writeString('Single line\nstring');

        expect(
          loadYaml(listWriter.toString()),
          [
            true,
            1,
            'Multiline\nstring',
            'Single line\nstring',
          ],
        );
      });

      test('Nested lists', () {
        final listWriter = YamlListWriter()
          ..writeList((w) => w
            ..writeList((w) => w
              ..writeBool(true)
              ..writeString('hi'))
            ..writeNumber(5))
          ..writeBool(false);

        expect(
          loadYaml(listWriter.toString()),
          [
            [
              [true, 'hi'],
              5,
            ],
            false,
          ],
        );
      });

      test('Nested maps', () {
        final listWriter = YamlListWriter()
          ..writeMap((w) => w.writeString('foo', 'bar'))
          ..writeBool(true)
          ..writeMap((w) => w.writeString('foo', 'bar'));

        expect(
          loadYaml(listWriter.toString()),
          [
            {'foo': 'bar'},
            true,
            {'foo': 'bar'},
          ],
        );
      });

      test('Formatted representation of nested maps', () {
        final listWriter = YamlListWriter()
          ..writeMap((w) => w
            ..writeString('foo', 'bar')
            ..writeString('baz', 'snaz', quoted: false));

        expect(
          listWriter.toString(),
          '- foo: "bar"\n'
          '  baz: snaz\n',
        );
      });

      test('Throw error if writer is disposed', () {
        YamlListWriter nestedListWriter;
        YamlListWriter().writeList((w) => nestedListWriter = w);

        expect(
          () => nestedListWriter.writeBool(false),
          throwsStateError,
        );
      });
    });
  });
}
