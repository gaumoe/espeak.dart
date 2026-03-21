import 'dart:io';

import 'package:espeak/espeak.dart';
import 'package:test/test.dart';

void main() {
  final dataPath = _findEspeakData();
  if (dataPath == null) {
    print('Skipping tests: no espeak-ng-data found.');
    print('Install via brew (macOS) or apt (Linux), or run espeakc first.');
    return;
  }

  test('phonemizes English text', () {
    final espeak = Espeak.init(dataPath);
    try {
      final phonemes = espeak.phonemize('Hello world');
      expect(phonemes, isNotEmpty);
      expect(phonemes, contains('h'));
    } finally {
      espeak.dispose();
    }
  });
}

String? _findEspeakData() {
  // Package compiled data.
  final packageData = '${Directory.current.path}/data';
  if (Directory('$packageData/espeak-ng-data').existsSync()) return packageData;

  // Homebrew (macOS).
  if (Directory('/opt/homebrew/share/espeak-ng-data').existsSync()) {
    return '/opt/homebrew/share';
  }

  // Linux system.
  if (Directory('/usr/share/espeak-ng-data').existsSync()) {
    return '/usr/share';
  }

  return null;
}
