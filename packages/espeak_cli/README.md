# espeak_cli

[![pub package](https://img.shields.io/pub/v/espeak_cli.svg)](https://pub.dev/packages/espeak_cli)

CLI tool for compiling [espeak-ng](https://github.com/espeak-ng/espeak-ng) phoneme data.

Downloads espeak-ng source automatically on first run. Compiled data is platform-independent and works with the [espeak](https://pub.dev/packages/espeak) package.

## Install

```bash
dart pub global activate espeak_cli
```

## Usage

```bash
espeakc                                # English only
espeakc --all --exclude=fo             # All languages except Faroese
espeakc --languages=en,fr,de,ja        # Specific languages
espeakc --output ./my-data             # Custom output directory
espeakc --force                        # Recompile
```

## Using the compiled data

```dart
import 'package:espeak/espeak.dart';

final espeak = Espeak.init('./espeak-data');
print(espeak.phonemize('Hello world')); // həlˈoʊ wˈɜːld
```
