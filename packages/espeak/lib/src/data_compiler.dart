import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'bindings_generated.dart';

/// Compiles espeak-ng data files (phonemes, intonation, dictionaries)
/// from the source tree.
///
/// The compiled data is platform-independent binary files that espeak-ng
/// loads at runtime for phonemization.
class EspeakDataCompiler {
  /// Compile all espeak-ng data from source.
  ///
  /// [sourceRoot] is the espeak-ng source tree root (containing `phsource/`
  /// and `dictsource/` directories).
  /// [outputPath] is where `espeak-ng-data/` will be populated with compiled
  /// binary files.
  /// [languages] is the list of language codes to compile dictionaries for.
  /// Defaults to `['en']`.
  static void compile(
    String sourceRoot,
    String outputPath, {
    List<String> languages = const ['en'],
  }) {
    final phsource = '$sourceRoot/phsource';
    final dictsource = '$sourceRoot/dictsource';
    final dataDir = '$outputPath/espeak-ng-data';

    Directory(dataDir).createSync(recursive: true);
    _copyDirIfNeeded('$sourceRoot/espeak-ng-data/lang', '$dataDir/lang');
    _copyDirIfNeeded('$sourceRoot/espeak-ng-data/voices', '$dataDir/voices');

    using((arena) {
      espeak_ng_InitializePath(
        outputPath.toNativeUtf8(allocator: arena).cast(),
      );
    });

    _compileIntonation(phsource, dataDir);
    _compilePhonemes(phsource, dataDir);

    using((arena) {
      final result = espeak_Initialize(
        espeak_AUDIO_OUTPUT.AUDIO_OUTPUT_RETRIEVAL,
        0,
        outputPath.toNativeUtf8(allocator: arena).cast(),
        0,
      );
      if (result == -1) {
        throw StateError('espeak_Initialize failed');
      }
    });

    try {
      final failed = <String>[];
      for (final lang in languages) {
        try {
          _compileDictionary(dictsource, lang);
        } catch (e) {
          failed.add(lang);
        }
      }
      if (failed.isNotEmpty) {
        print('Warning: ${failed.length} languages failed: ${failed.join(", ")}');
      }
    } finally {
      espeak_Terminate();
    }
  }

  static void _compileIntonation(String phsource, String dataDir) {
    using((arena) {
      final status = espeak_ng_CompileIntonationPath(
        phsource.toNativeUtf8(allocator: arena).cast(),
        dataDir.toNativeUtf8(allocator: arena).cast(),
        nullptr,
        nullptr,
      );
      if (status != espeak_ng_STATUS.ENS_OK) {
        throw StateError('CompileIntonation failed: $status');
      }
    });
  }

  static void _compilePhonemes(String phsource, String dataDir) {
    using((arena) {
      final status = espeak_ng_CompilePhonemeDataPath(
        22050,
        phsource.toNativeUtf8(allocator: arena).cast(),
        dataDir.toNativeUtf8(allocator: arena).cast(),
        nullptr,
        nullptr,
      );
      if (status != espeak_ng_STATUS.ENS_OK) {
        throw StateError('CompilePhonemeData failed: $status');
      }
    });
  }

  static void _compileDictionary(String dictsource, String lang) {
    using((arena) {
      espeak_SetVoiceByName(
        lang.toNativeUtf8(allocator: arena).cast(),
      );
    });

    using((arena) {
      final status = espeak_ng_CompileDictionary(
        '$dictsource/'.toNativeUtf8(allocator: arena).cast(),
        lang.toNativeUtf8(allocator: arena).cast(),
        nullptr,
        0,
        nullptr,
      );
      if (status != espeak_ng_STATUS.ENS_OK) {
        throw StateError('CompileDictionary($lang) failed: $status');
      }
    });
  }

  static void _copyDirIfNeeded(String src, String dst) {
    if (Directory(dst).existsSync()) return;
    final srcDir = Directory(src);
    if (!srcDir.existsSync()) return;

    Directory(dst).createSync(recursive: true);
    for (final entity in srcDir.listSync(recursive: true)) {
      final relativePath = entity.path.substring(srcDir.path.length);
      final targetPath = '$dst$relativePath';
      switch (entity) {
        case Directory():
          Directory(targetPath).createSync(recursive: true);
        case File():
          Directory(File(targetPath).parent.path).createSync(recursive: true);
          entity.copySync(targetPath);
      }
    }
  }
}
