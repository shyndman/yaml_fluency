import 'package:uuid/uuid.dart';
import 'package:yaml_fluency/yaml_fluency.dart';

void main() {
  final userWriter = YamlMapWriter()
    ..writeMap(
      'man',
      (man) => man
        ..writeString('email', 'scott@madewithfelt.com')
        ..writeString('displayName', 'shyndman', quoted: false)
        ..writeBool('activated', true)
        ..writeString('bio', stripLeadingSpace('''
          Scott really likes writing Dart.
          How much?
          Quite a bit.
        '''), multiline: true)
        ..writeMap(
          'account',
          (account) => account
            ..writeNumber('loginCount', 5)
            ..writeString(
              'ticket',
              Uuid().v4(),
            ),
        ),
    )
    ..writeMap(
      'dog',
      (dog) => dog
        ..writeString('name', 'Henry')
        ..writeNumber('weight (lbs)', 24.5)
        ..writeBool('awesome', true),
    );
  print(userWriter.toString());
}

String stripLeadingSpace(String string) {
  return string.replaceAllMapped(
      RegExp(r'^\s+(.*)$', multiLine: true), (match) => match[1]);
}
