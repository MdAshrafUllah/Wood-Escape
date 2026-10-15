import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:woodescape/domain/engine/level_generator.dart';

// ─────────────────────────────────────────────────────────────
// Config
// ─────────────────────────────────────────────────────────────

const int kEndLevel = 30000;
const int kChunkSize = 1000; // output file size (levels per file)
const int kPromptTimeoutSeconds = 5;
const String kProgressFile = '.generate_progress.json';
const String kOutputDir = 'assets/levels';

// ─────────────────────────────────────────────────────────────
// stdin broadcaster — fixes "Stream has already been listened to"
// ─────────────────────────────────────────────────────────────

final StreamController<String> _inputController =
    StreamController<String>.broadcast();
bool _stdinInitialized = false;

void _ensureStdinListener() {
  if (_stdinInitialized) return;
  _stdinInitialized = true;
  stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen(
    (line) => _inputController.add(line.trim().toLowerCase()),
    onDone: () {},
    onError: (_) {},
  );
}

/// Reads a single line of input with a timeout.
/// Returns 'y' on timeout (auto-continue).
Future<String> _readWithTimeout(int seconds) async {
  _ensureStdinListener();
  try {
    return await _inputController.stream
        .first
        .timeout(Duration(seconds: seconds));
  } on TimeoutException {
    return 'y';
  } catch (_) {
    return 'y';
  }
}

// ─────────────────────────────────────────────────────────────
// Progress persistence
// ─────────────────────────────────────────────────────────────

int _loadLastCompleted() {
  final file = File(kProgressFile);
  if (!file.existsSync()) return 15000; // levels 1-15000 already done
  try {
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return data['lastCompletedLevel'] as int;
  } catch (_) {
    return 15000;
  }
}

void _saveLastCompleted(int level) {
  File(kProgressFile).writeAsStringSync(
    jsonEncode({'lastCompletedLevel': level}),
  );
}

// ─────────────────────────────────────────────────────────────
// Level generation
// ─────────────────────────────────────────────────────────────

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
  }
  return chunk;
}

/// Merges [newLevels] into the 1000-level chunk file they belong to.
Future<void> _mergeIntoChunkFile(
  Directory outputDir,
  Map<String, dynamic> newLevels,
) async {
  // Group new levels by their 1000-chunk
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
        existing =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      } catch (_) {}
    }

    existing.addAll(grouped[chunkStart]!);
    await file.writeAsString(jsonEncode(existing));
  }
}

// ─────────────────────────────────────────────────────────────
// Mode 1 — interactive batch-10
// ─────────────────────────────────────────────────────────────

Future<void> _runBatch10(Directory outputDir, int lastCompleted) async {
  const int kBatchSize = 10;
  int nextStart = lastCompleted + 1;

  stdout.writeln('Mode 1: Batch 10 (interactive, Y/N, '
      '${kPromptTimeoutSeconds}s timeout → auto-Y)');
  stdout.writeln('');

  while (nextStart <= kEndLevel) {
    final nextEnd = (nextStart + kBatchSize - 1) > kEndLevel
        ? kEndLevel
        : (nextStart + kBatchSize - 1);

    final sw = Stopwatch()..start();
    final batch = _generateRange(nextStart, nextEnd);
    await _mergeIntoChunkFile(outputDir, batch);
    sw.stop();

    _saveLastCompleted(nextEnd);
    final secs = (sw.elapsedMilliseconds / 1000).toStringAsFixed(1);
    stdout.writeln('[$nextStart-$nextEnd] done in ${secs}s');

    nextStart = nextEnd + 1;

    if (nextStart > kEndLevel) {
      stdout.writeln('');
      stdout.writeln('✅ All levels generated!');
      return;
    }

    stdout.write('Continue with next $kBatchSize levels? '
        '(y/n, auto-Y in ${kPromptTimeoutSeconds}s): ');

    final choice = await _readWithTimeout(kPromptTimeoutSeconds);

    if (choice == 'n' || choice == 'no') {
      stdout.writeln('');
      stdout.writeln('Stopped at level $nextEnd.');
      stdout.writeln('Run again to continue from level ${nextEnd + 1}.');
      return;
    }

    stdout.writeln('');
  }
}

// ─────────────────────────────────────────────────────────────
// Mode 2 — auto batch-1000
// ─────────────────────────────────────────────────────────────

Future<void> _runBatch1000(Directory outputDir, int lastCompleted) async {
  const int kBatchSize = 1000;
  int nextStart = lastCompleted + 1;

  stdout.writeln('Mode 2: Batch 1000 (auto, no prompt)');
  stdout.writeln('');

  while (nextStart <= kEndLevel) {
    final nextEnd = (nextStart + kBatchSize - 1) > kEndLevel
        ? kEndLevel
        : (nextStart + kBatchSize - 1);

    final sw = Stopwatch()..start();
    final batch = _generateRange(nextStart, nextEnd);
    await _mergeIntoChunkFile(outputDir, batch);
    sw.stop();

    _saveLastCompleted(nextEnd);
    final secs = (sw.elapsedMilliseconds / 1000).toStringAsFixed(1);
    stdout.writeln('[$nextStart-$nextEnd] done in ${secs}s');

    nextStart = nextEnd + 1;
  }

  stdout.writeln('');
  stdout.writeln('✅ All levels generated!');
}

// ─────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────

Future<void> main() async {
  _ensureStdinListener();

  try {
    final outputDir = Directory(kOutputDir);
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final lastCompleted = _loadLastCompleted();

    stdout.writeln('═══════════════════════════════════════');
    stdout.writeln('Resume from level: ${lastCompleted + 1}');
    stdout.writeln('End at level:      $kEndLevel');
    stdout.writeln('═══════════════════════════════════════');
    stdout.writeln('');
    stdout.writeln('Which mode?');
    stdout.writeln('  1. Batch 10   (interactive, Y/N, '
        '${kPromptTimeoutSeconds}s timeout → auto-Y)');
    stdout.writeln('  2. Batch 1000 (auto, full speed)');
    stdout.write('Choose (1/2): ');

    String mode;
    try {
      mode = await _inputController.stream
          .first
          .timeout(const Duration(seconds: 30), onTimeout: () => '2');
    } catch (_) {
      mode = '2';
    }
    stdout.writeln('');

    if (mode == '1') {
      await _runBatch10(outputDir, lastCompleted);
    } else if (mode == '2') {
      await _runBatch1000(outputDir, lastCompleted);
    } else {
      stdout.writeln('Invalid choice. Run again and pick 1 or 2.');
      exit(1);
    }
  } finally {
    await _inputController.close();
  }
}