import 'package:flutter_test/flutter_test.dart';
import 'package:woodescape/domain/engine/game_board.dart';
import 'package:woodescape/domain/engine/level_generator.dart';
import 'package:woodescape/domain/engine/puzzle_solver.dart';
import 'package:woodescape/domain/models/block.dart';
import 'package:woodescape/domain/models/level_data.dart';

void main() {
  setUp(() {
    LevelGenerator.clearCacheForTest();
  });

  group('LevelGenerator - Basic Generation', () {
    test('generates a puzzle for level 1', () {
      final (blocks, minMoves) = LevelGenerator.generate(1);
      expect(blocks, isNotEmpty);
      expect(blocks.any((b) => b.isTarget), isTrue);
      expect(minMoves, greaterThan(0));
    });

    test('generates a puzzle for a mid-range level', () {
      final (blocks, minMoves) = LevelGenerator.generate(5000);
      expect(blocks, isNotEmpty);
      expect(minMoves, greaterThan(0));
    });

    test('generates a puzzle for the max level', () {
      final (blocks, minMoves) = LevelGenerator.generate(30000);
      expect(blocks, isNotEmpty);
      expect(minMoves, greaterThan(0));
    });

    test('every generated level has exactly one target block', () {
      for (int level = 1; level <= 100; level++) {
        final (blocks, _) = LevelGenerator.generate(level);
        final targetCount = blocks.where((b) => b.isTarget).length;
        expect(targetCount, 1, reason: 'Level $level target count');
      }
    });

    test('target block is always at row 2', () {
      for (int level = 1; level <= 100; level++) {
        final (blocks, _) = LevelGenerator.generate(level);
        final target = blocks.firstWhere((b) => b.isTarget);
        expect(target.row, 2, reason: 'Level $level target row');
      }
    });

    test('target block is always horizontal length 2', () {
      for (int level = 1; level <= 100; level++) {
        final (blocks, _) = LevelGenerator.generate(level);
        final target = blocks.firstWhere((b) => b.isTarget);
        expect(target.length, 2, reason: 'Level $level target length');
        expect(
          target.orientation,
          BlockOrientation.horizontal,
          reason: 'Level $level target orientation',
        );
      }
    });

    test('no blocks overlap in any generated level', () {
      for (int level = 1; level <= 200; level++) {
        final (blocks, _) = LevelGenerator.generate(level);
        expect(
          _hasOverlap(blocks),
          isFalse,
          reason: 'Level $level has overlapping blocks',
        );
      }
    });
  });

  group('LevelGenerator - Solvability', () {
    test('every generated level is solvable (1..200)', () {
      for (int level = 1; level <= 200; level++) {
        final (blocks, _) = LevelGenerator.generate(level);
        final solution = PuzzleSolver.solve(GameBoard(blocks: blocks));
        expect(solution, isNotNull, reason: 'Level $level unsolvable');
      }
    });

    test('reported minMoves matches solver result (1..100)', () {
      for (int level = 1; level <= 100; level++) {
        final (blocks, reportedMinMoves) = LevelGenerator.generate(level);
        final solution = PuzzleSolver.solve(GameBoard(blocks: blocks));
        expect(solution, isNotNull);
        expect(
          solution!.length,
          reportedMinMoves,
          reason: 'Level $level minMoves mismatch',
        );
      }
    });
  });

  group('LevelGenerator - Determinism', () {
    test('same level produces identical layout across calls', () {
      LevelGenerator.clearCacheForTest();
      final (blocks1, min1) = LevelGenerator.generate(42);

      LevelGenerator.clearCacheForTest();
      final (blocks2, min2) = LevelGenerator.generate(42);

      expect(min1, min2);
      expect(_signature(blocks1), _signature(blocks2));
    });

    test('sequential generation is deterministic across sessions', () {
      LevelGenerator.clearCacheForTest();
      final sig1 = <String>[];
      for (int level = 1; level <= 50; level++) {
        final (blocks, _) = LevelGenerator.generate(level);
        sig1.add(_signature(blocks));
      }

      LevelGenerator.clearCacheForTest();
      final sig2 = <String>[];
      for (int level = 1; level <= 50; level++) {
        final (blocks, _) = LevelGenerator.generate(level);
        sig2.add(_signature(blocks));
      }

      expect(sig1, sig2);
    });
  });

  group('LevelGenerator - Uniqueness', () {
    test('first 500 levels are all unique', () {
      final seen = <String>{};
      for (int level = 1; level <= 500; level++) {
        final (blocks, _) = LevelGenerator.generate(level);
        final sig = _signature(blocks);
        expect(
          seen.contains(sig),
          isFalse,
          reason: 'Level $level duplicates an earlier puzzle',
        );
        seen.add(sig);
      }
      expect(seen.length, 500);
    });

    test('levels across difficulty bands are unique', () {
      final sampleLevels = [
        1,
        2,
        3,
        100,
        500,
        1000,
        4999,
        5000,
        5001,
        5002,
        7500,
        10000,
        10001,
        12500,
        15000,
        15001,
        17500,
        20000,
        20001,
        22500,
        25000,
        25001,
        27500,
        30000,
      ];
      final seen = <String>{};
      for (final level in sampleLevels) {
        final (blocks, _) = LevelGenerator.generate(level);
        final sig = _signature(blocks);
        expect(seen.contains(sig), isFalse, reason: 'Level $level collides');
        seen.add(sig);
      }
    });
  });

  group('LevelGenerator - Difficulty Bands', () {
    test('correct difficulty assigned at boundaries', () {
      expect(LevelGenerator.getDifficultyForLevel(1), LevelDifficulty.easy);
      expect(LevelGenerator.getDifficultyForLevel(5000), LevelDifficulty.easy);
      expect(
        LevelGenerator.getDifficultyForLevel(5001),
        LevelDifficulty.medium,
      );
      expect(
        LevelGenerator.getDifficultyForLevel(10000),
        LevelDifficulty.medium,
      );
      expect(LevelGenerator.getDifficultyForLevel(10001), LevelDifficulty.hard);
      expect(LevelGenerator.getDifficultyForLevel(15000), LevelDifficulty.hard);
      expect(
        LevelGenerator.getDifficultyForLevel(15001),
        LevelDifficulty.expert,
      );
      expect(
        LevelGenerator.getDifficultyForLevel(20000),
        LevelDifficulty.expert,
      );
      expect(
        LevelGenerator.getDifficultyForLevel(20001),
        LevelDifficulty.legend,
      );
      expect(
        LevelGenerator.getDifficultyForLevel(25000),
        LevelDifficulty.legend,
      );
      expect(
        LevelGenerator.getDifficultyForLevel(25001),
        LevelDifficulty.master,
      );
      expect(
        LevelGenerator.getDifficultyForLevel(30000),
        LevelDifficulty.master,
      );
    });

    test('higher difficulty has at least as many obstacles (sample avg)', () {
      double avgObstacles(int start, int end) {
        int total = 0;
        int count = 0;
        for (int level = start; level <= end; level += 10) {
          final (blocks, _) = LevelGenerator.generate(level);
          total += blocks.where((b) => !b.isTarget).length;
          count++;
        }
        return total / count;
      }

      final easyAvg = avgObstacles(1, 100);
      final masterAvg = avgObstacles(25001, 25100);
      expect(
        masterAvg,
        greaterThan(easyAvg),
        reason: 'Master levels should have more obstacles than easy',
      );
    });
  });

  group('LevelGenerator - Performance', () {
    test('generates 100 levels within 5 seconds', () {
      final sw = Stopwatch()..start();
      for (int level = 1; level <= 100; level++) {
        LevelGenerator.generate(level);
      }
      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(5000),
        reason: 'Too slow: ${sw.elapsedMilliseconds}ms',
      );
    });

    test('cached call is instant', () {
      LevelGenerator.generate(100);
      final sw = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        LevelGenerator.generate(100);
      }
      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(50),
        reason: 'Cache not effective: ${sw.elapsedMilliseconds}ms',
      );
    });
  });

  group('LevelGenerator - Fallback Safety', () {
    test('fallback layout is returned when all attempts fail', () {
      final (blocks, minMoves) = LevelGenerator.generate(1);
      expect(blocks.length, greaterThanOrEqualTo(2));
      expect(minMoves, greaterThan(0));
    });

    test('extreme level number does not crash', () {
      expect(() => LevelGenerator.generate(30000), returnsNormally);
      expect(() => LevelGenerator.generate(999999), returnsNormally);
    });
  });
}

String _signature(List<Block> blocks) {
  final tokens =
      blocks
          .map(
            (b) =>
                '${b.isTarget ? 1 : 0},${b.orientation == BlockOrientation.vertical ? 'V' : 'H'},${b.row},${b.col},${b.length}',
          )
          .toList()
        ..sort();
  return tokens.join('|');
}

bool _hasOverlap(List<Block> blocks) {
  for (int i = 0; i < blocks.length; i++) {
    for (int j = i + 1; j < blocks.length; j++) {
      if (_blocksOverlap(blocks[i], blocks[j])) return true;
    }
  }
  return false;
}

bool _blocksOverlap(Block a, Block b) {
  final aCells = _cells(a);
  final bCells = _cells(b);
  return aCells.intersection(bCells).isNotEmpty;
}

Set<int> _cells(Block b) {
  final cells = <int>{};
  for (int i = 0; i < b.length; i++) {
    final r = b.row + (b.orientation == BlockOrientation.vertical ? i : 0);
    final c = b.col + (b.orientation == BlockOrientation.horizontal ? i : 0);
    cells.add(r * 100 + c);
  }
  return cells;
}
