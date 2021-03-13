# YAML Fluency

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
        Scott really likes writing Dart. How much?
        Quite a bit. It's becoming a more interesting
        language by the day!
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
```

To get this:
```yaml
man:
  email: "scott@madewithfelt.com"
  displayName: shyndman
  activated: true
  bio: |-
    Scott really likes writing Dart. How much?
    Quite a bit. It isnʼt quite there, but who
    needs perfection, right?
  account:
    loginCount: 5
    ticket: "30fe6ea4-cdaa-4b92-93a9-66a38d589fa7"
dog:
  name: "Henry"
  weight (lbs): 24.5
  awesome: true

```
