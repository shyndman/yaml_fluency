# YAML Fluency

[![Pub](https://img.shields.io/pub/v/yaml_fluency)](https://pub.dev/packages/yaml_fluency)
[![Github test](https://github.com/madewithfelt/yaml_fluency/workflows/test/badge.svg?branch=main-null-unsafe)](https://github.com/madewithfelt/yaml_fluency/actions/workflows/test.yml?query=branch%3Amain-null-unsafe)

Writes YAML strings fluently

Write this:
```dart
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
```

To get this:
```yaml
man:
  email: "scott@madewithfelt.com"
  displayName: shyndman
  activated: true
  bio: |-
    Ontario native, and dog whisperer.
    Programming Dart/Flutter these days.
  account:
    loginCount: 5
    ticket: "d17933a8-4e24-4e66-9522-d59124f84503"
dog:
  name: "Henry"
  weight (lbs): 24.5
  awesome: true
  bio: |-
    California dog, coming to terms
    with the Canadian winter.
```
