# espeak

[![pub package](https://img.shields.io/pub/v/espeak.svg)](https://pub.dev/packages/espeak)

Text to phoneme conversion, powered by [espeak-ng](https://github.com/espeak-ng/espeak-ng).

The native library compiles automatically via Dart Native Assets (requires a C compiler).

## Usage

```dart
import 'package:espeak/espeak.dart';

final espeak = Espeak.init('./espeak-data');
final phonemes = espeak.phonemize('Hello world');
print(phonemes); // həlˈoʊ wˈɜːld
espeak.dispose();
```

## Phoneme Data

espeak needs compiled phoneme data at runtime. Add espeak as a dependency and run the compiler:

```bash
dart run espeak:compile_data --all --exclude=fo --output ./espeak-data
```

Then pass the output path to `Espeak.init()`.

> **Note:** `espeak_cli` is also available but `dart pub global activate` doesn't support native assets yet. Use `dart run` from a project that depends on `espeak` instead.
