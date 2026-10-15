// tool/generate_levels_ci.dart
import 'dart:convert';
import 'dart:io';

import 'package:woodescape/domain/engine/level_generator.dart';

const int kChunkSize = 1000;
const String kOutputDir = 'assets/levels';

Map<String, dynamic> _generateRange(int start, int end) {
  final chunk = <String, dynamic>{};
  for (int level = start; level <= end; level++) {
    final generated = LevelGenerator.generate(level);
    chunk['$level'] = {
      'exitSide': generated.exitSide.name,
      'minMoves': generated.minMoves,
      'blocks': generated.blocks
          .map(
            (b) => {
              'id': b.id,
              'isTarget': b.isTarget,
              'orientation': b.orientation.name,
              'length': b.length,
              'row': b.row,
              'col': b.col,
            },
          )
          .toList(),
    };
    if (level % 100 == 0) {
      stdout.writeln('[${DateTime.now().toIso8601String()}] level $level');
    }
  }
  return chunk;
}

Future<void> _mergeIntoChunkFile(
  Directory outputDir,
  Map<String, dynamic> newLevels,
) async {
  final Map<int, Map<String, dynamic>> grouped = {};
  for (final entry in newLevels.entries) {
    final level = int.parse(entry.key);
    final chunkStart = ((level - 1) ~/ kChunkSize) * kChunkSize + 1;
    grouped.putIfAbsent(chunkStart, () => {})[entry.key] = entry.value;
  }

  for (final chunkStart in grouped.keys) {
    final chunkEnd = chunkStart + kChunkSize - 1;
    final fileName = 'levels_${chunkStart}_$chunkEnd.json';
    final file = File('${outputDir.path}/$fileName');

    Map<String, dynamic> existing = {};
    if (file.existsSync()) {
      try {
        existing = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      } catch (_) {}
    }

    existing.addAll(grouped[chunkStart]!);
    await file.writeAsString(jsonEncode(existing));
  }
}

Future<void> main(List<String> args) async {
  int startLevel = 20481;
  int endLevel = 21000;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--start' && i + 1 < args.length) {
      startLevel = int.parse(args[i + 1]);
    } else if (args[i] == '--end' && i + 1 < args.length) {
      endLevel = int.parse(args[i + 1]);
    }
  }

  stdout.writeln('Start: $startLevel');
  stdout.writeln('End: $endLevel');

  final outputDir = Directory(kOutputDir);
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final sw = Stopwatch()..start();
  final batch = _generateRange(startLevel, endLevel);
  await _mergeIntoChunkFile(outputDir, batch);
  sw.stop();

  stdout.writeln(
    'Done in ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(1)}s',
  );
}
