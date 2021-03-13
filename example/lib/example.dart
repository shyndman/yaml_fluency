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
          Ontario native, and dog whisperer.
          Programming Dart/Flutter these days.
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
        ..writeBool('awesome', true)
        ..writeString('bio', stripLeadingSpace('''
          California dog, coming to terms
          with the Canadian winter.
        '''), multiline: true),
    );
  print(userWriter.toString());
}

String stripLeadingSpace(String string) {
  return string.replaceAllMapped(
      RegExp(r'^\s+(.*)$', multiLine: true), (match) => match[1]);
}
