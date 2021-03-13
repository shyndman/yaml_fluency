import 'package:yaml_fluency/yaml_fluency.dart';

void main() {
  final mapWriter = YamlMapWriter()
    ..writeMap(
      'a',
      (w) => w
        ..writeBool('a', true)
        ..writeMap('b', (w) => w..writeNumber('a', 5))
        ..writeString('c', 'a', quoted: false),
    )
    ..writeString('b', 'this\nis\nmultiline', multiline: true);
  print(mapWriter.toString());
}
