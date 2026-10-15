import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:woodescape/domain/engine/level_generator.dart';

const int kTotalLevels = 30000;
const int kChunkSize = 1000;

void main() {
  test('generate all levels', () async {
    final stopwatch = Stopwatch()..start();
    final outputDir = Directory('assets/levels');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    for (int start = 1; start <= kTotalLevels; start += kChunkSize) {
      final end = (start + kChunkSize - 1).clamp(0, kTotalLevels);
      final Map<String, dynamic> chunk = {};

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
          print('[${stopwatch.elapsed.inSeconds}s] level $level');
        }
      }

      final fileName = 'levels_${start}_$end.json';
      final file = File('${outputDir.path}/$fileName');
      await file.writeAsString(jsonEncode(chunk));
      print('WROTE $fileName');
    }

    print('Done in ${stopwatch.elapsed.inMinutes} min');
  }, timeout: const Timeout(Duration(hours: 12)));
}
