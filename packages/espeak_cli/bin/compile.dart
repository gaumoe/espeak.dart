// Compile espeak-ng phoneme data from source.
//
// Usage:
//   espeak_compile                                English only (default)
//   espeak_compile --all                          All languages
//   espeak_compile --all --exclude=fo             All except Faroese
//   espeak_compile --languages=en,fr,de           Specific languages
//   espeak_compile --output ./my-data             Custom output directory
//   espeak_compile --force                        Recompile even if cached
//
// Downloads espeak-ng source on first run (~56MB, cached in ~/.espeak_cli/).

import 'dart:io';

import 'package:espeak/src/data_compiler.dart';

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    print('Usage: espeak_compile [options]');
    print('');
    print('Options:');
    print('  --all                  Compile all languages');
    print('  --exclude=LANG,...     Exclude languages (use with --all)');
    print('  --languages=LANG,...   Compile specific languages (default: en)');
    print('  --output=DIR           Output directory (default: ./espeak-data)');
    print('  --force                Recompile even if cached');
    print('  --help                 Show this help');
    return;
  }

  final force = args.contains('--force');
  var outputPath = './espeak-data';
  var languages = ['en'];
  var exclude = <String>{};

  for (final arg in args) {
    if (arg.startsWith('--output=')) {
      outputPath = arg.substring('--output='.length);
    } else if (arg.startsWith('--exclude=')) {
      exclude = arg.substring('--exclude='.length).split(',').toSet();
    } else if (arg.startsWith('--languages=')) {
      languages = arg.substring('--languages='.length).split(',');
    }
  }

  // Download espeak-ng source if not cached.
  final cacheDir = _cacheDir();
  final sourceRoot = '$cacheDir/espeak-ng';

  if (!Directory('$sourceRoot/dictsource').existsSync()) {
    _downloadSource(cacheDir, sourceRoot);
  }

  if (args.contains('--all')) {
    languages = _discoverLanguages('$sourceRoot/dictsource')
        .where((l) => !exclude.contains(l))
        .toList();
  }

  if (!force &&
      Directory('$outputPath/espeak-ng-data').existsSync() &&
      languages.every(
        (l) => File('$outputPath/espeak-ng-data/${l}_dict').existsSync(),
      )) {
    print('Data already compiled at $outputPath/espeak-ng-data');
    print('Use --force to recompile.');
    return;
  }

  print('Compiling espeak-ng data...');
  print('  Source: $sourceRoot');
  print('  Output: $outputPath');
  print('  Languages: ${languages.length} (${languages.take(10).join(", ")}'
      '${languages.length > 10 ? ", ..." : ""})');

  final sw = Stopwatch()..start();
  EspeakDataCompiler.compile(sourceRoot, outputPath, languages: languages);
  sw.stop();

  print('Done in ${sw.elapsedMilliseconds}ms');
}

String _cacheDir() {
  final home = Platform.environment['HOME'] ??
      Platform.environment['USERPROFILE'] ??
      '.';
  final dir = '$home/.espeak_cli';
  Directory(dir).createSync(recursive: true);
  return dir;
}

void _downloadSource(String cacheDir, String sourceRoot) {
  print('Downloading espeak-ng source (first run only)...');

  // Download tarball from GitHub.
  const url =
      'https://github.com/espeak-ng/espeak-ng/archive/refs/heads/master.tar.gz';
  final tarPath = '$cacheDir/espeak-ng.tar.gz';

  final result = Process.runSync('curl', ['-fsSL', '-o', tarPath, url]);
  if (result.exitCode != 0) {
    throw StateError('Failed to download espeak-ng: ${result.stderr}');
  }

  // Extract.
  Process.runSync('tar', ['xzf', tarPath, '-C', cacheDir]);

  // Rename extracted directory.
  final extracted = Directory('$cacheDir/espeak-ng-master');
  if (extracted.existsSync()) {
    extracted.renameSync(sourceRoot);
  }

  File(tarPath).deleteSync();
  print('Cached at $sourceRoot');
}

List<String> _discoverLanguages(String dictsource) {
  final dir = Directory(dictsource);
  if (!dir.existsSync()) {
    throw StateError('dictsource not found: $dictsource');
  }
  return dir
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .where((name) => name.endsWith('_rules'))
      .map((name) => name.replaceAll('_rules', ''))
      .toList()
    ..sort();
}
