// Native Assets build hook for espeak-ng
//
// Compiles the espeak-ng C library during `dart run`, `dart test`,
// `flutter run`, and `flutter build`.

// ignore_for_file: depend_on_referenced_packages

import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    await CBuilder.library(
      name: 'espeak_native',
      assetName: 'espeak_native',
      sources: [
        // Core library
        'native/espeak-ng/src/libespeak-ng/common.c',
        'native/espeak-ng/src/libespeak-ng/compiledata.c',
        'native/espeak-ng/src/libespeak-ng/compiledict.c',
        'native/espeak-ng/src/libespeak-ng/dictionary.c',
        'native/espeak-ng/src/libespeak-ng/encoding.c',
        'native/espeak-ng/src/libespeak-ng/error.c',
        'native/espeak-ng/src/libespeak-ng/espeak_api.c',
        'native/espeak-ng/src/libespeak-ng/espeak_command.c',
        'native/espeak-ng/src/libespeak-ng/event.c',
        'native/espeak-ng/src/libespeak-ng/fifo.c',
        'native/espeak-ng/src/libespeak-ng/ieee80.c',
        'native/espeak-ng/src/libespeak-ng/intonation.c',
        'native/espeak-ng/src/libespeak-ng/klatt.c',
        'native/espeak-ng/src/libespeak-ng/langopts.c',
        'native/espeak-ng/src/libespeak-ng/mnemonics.c',
        'native/espeak-ng/src/libespeak-ng/numbers.c',
        'native/espeak-ng/src/libespeak-ng/phoneme.c',
        'native/espeak-ng/src/libespeak-ng/phonemelist.c',
        'native/espeak-ng/src/libespeak-ng/readclause.c',
        'native/espeak-ng/src/libespeak-ng/setlengths.c',
        'native/espeak-ng/src/libespeak-ng/soundicon.c',
        'native/espeak-ng/src/libespeak-ng/spect.c',
        'native/espeak-ng/src/libespeak-ng/speech.c',
        'native/espeak-ng/src/libespeak-ng/ssml.c',
        'native/espeak-ng/src/libespeak-ng/synthdata.c',
        'native/espeak-ng/src/libespeak-ng/synthesize.c',
        'native/espeak-ng/src/libespeak-ng/translate.c',
        'native/espeak-ng/src/libespeak-ng/translateword.c',
        'native/espeak-ng/src/libespeak-ng/tr_languages.c',
        'native/espeak-ng/src/libespeak-ng/voices.c',
        'native/espeak-ng/src/libespeak-ng/wavegen.c',
        // UCD (Unicode character data)
        'native/espeak-ng/src/ucd-tools/src/case.c',
        'native/espeak-ng/src/ucd-tools/src/categories.c',
        'native/espeak-ng/src/ucd-tools/src/ctype.c',
        'native/espeak-ng/src/ucd-tools/src/proplist.c',
        'native/espeak-ng/src/ucd-tools/src/scripts.c',
        'native/espeak-ng/src/ucd-tools/src/tostring.c',
      ],
      includes: [
        'native', // config.h
        'native/espeak-ng/src/include',
        'native/espeak-ng/src/include/compat', // cross-platform shims (endian.h, unistd.h, etc.)
        'native/espeak-ng/src/ucd-tools/src/include',
      ],
      language: Language.c,
    ).run(input: input, output: output);
  });
}
