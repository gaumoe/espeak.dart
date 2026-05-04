import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings_generated.dart';

// Clause terminator intonation types (from translate.h).
const _clauseComma = 0x00001000;
const _clauseQuestion = 0x00002000;
const _clauseExclamation = 0x00003000;
const _clauseIntonationMask = 0x00007000;
const _initializeDontExit = 0x8000;

/// Text-to-phoneme engine powered by espeak-ng.
///
/// ```dart
/// final espeak = Espeak.init('/path/to/espeak-ng-data');
/// final phonemes = espeak.phonemize('Hello world');
/// print(phonemes); // həlˈoʊ wˈɜːld
/// espeak.dispose();
/// ```
class Espeak implements Finalizable {
  static final _finalizer = Finalizer<void Function()>((cleanup) => cleanup());

  bool _disposed = false;

  Espeak._();

  /// Initialize espeak-ng with data from [dataPath].
  ///
  /// [dataPath] is the directory containing `espeak-ng-data/`.
  /// [voice] is the default voice/language (e.g. `'en-us'`, `'fr'`).
  factory Espeak.init(String dataPath, {String voice = 'en-us'}) {
    using((arena) {
      final pathPtr = dataPath.toNativeUtf8(allocator: arena).cast<Char>();
      final result = espeak_Initialize(
        espeak_AUDIO_OUTPUT.AUDIO_OUTPUT_RETRIEVAL,
        0,
        pathPtr,
        _initializeDontExit,
      );
      if (result == -1) {
        throw StateError('espeak_Initialize failed (data path: $dataPath)');
      }
    });

    final instance = Espeak._();
    _finalizer.attach(instance, () => espeak_Terminate());
    instance.setVoice(voice);
    return instance;
  }

  /// Set the voice/language for phonemization.
  void setVoice(String name) {
    _checkAlive();
    using((arena) {
      final namePtr = name.toNativeUtf8(allocator: arena).cast<Char>();
      final result = espeak_SetVoiceByName(namePtr);
      if (result != espeak_ERROR.EE_OK) {
        throw ArgumentError('Unknown voice: $name');
      }
    });
  }

  /// Convert text to IPA phonemes with punctuation preserved.
  ///
  /// Uses `espeak_TextToPhonemesWithTerminator` to detect clause boundaries
  /// and re-insert punctuation (commas, periods, etc.) that espeak consumes.
  String phonemize(String text) {
    _checkAlive();
    return using((arena) {
      final textPtr = text.toNativeUtf8(allocator: arena).cast<Char>();
      final ptrHolder = arena<Pointer<Void>>();
      ptrHolder.value = textPtr.cast();
      final terminatorHolder = arena<Int>();

      final buf = StringBuffer();
      while (true) {
        final result = espeak_TextToPhonemesWithTerminator(
          ptrHolder,
          1, // UTF-8
          0x02, // IPA
          terminatorHolder,
        );
        if (result == nullptr) break;
        final segment = result.cast<Utf8>().toDartString();
        if (segment.isEmpty) break;

        buf.write(segment);

        // Re-insert punctuation based on clause terminator.
        final terminator = terminatorHolder.value;
        final intonation = terminator & _clauseIntonationMask;
        switch (intonation) {
          case _clauseComma:
            buf.write(',');
          case _clauseQuestion:
            buf.write('?');
          case _clauseExclamation:
            buf.write('!');
          case 0: // full stop
            buf.write('.');
        }
      }
      return buf.toString();
    });
  }

  /// Release espeak-ng resources.
  void dispose() {
    if (_disposed) return;
    espeak_Terminate();
    _disposed = true;
  }

  void _checkAlive() {
    if (_disposed) {
      throw StateError('Espeak has been disposed');
    }
  }
}
