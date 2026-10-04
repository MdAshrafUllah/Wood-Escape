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
      final generated = LevelGenerator.generate(1);
      expect(generated.blocks, isNotEmpty);
      expect(generated.blocks.any((b) => b.isTarget), isTrue);
      expect(generated.minMoves, greaterThan(0));
    });

    test('generates a puzzle for a mid-range level', () {
      final generated = LevelGenerator.generate(5000);
      expect(generated.blocks, isNotEmpty);
      expect(generated.minMoves, greaterThan(0));
    });

    test('generates a puzzle for the max level', () {
      final generated = LevelGenerator.generate(30000);
      expect(generated.blocks, isNotEmpty);
      expect(generated.minMoves, greaterThan(0));
    });

    test('every generated level has exactly one target block', () {
      for (int level = 1; level <= 100; level++) {
        final generated = LevelGenerator.generate(level);
        final targetCount = generated.blocks.where((b) => b.isTarget).length;
        expect(targetCount, 1, reason: 'Level $level target count');
      }
    });

    test('target block orientation matches exit side', () {
      for (int level = 1; level <= 100; level++) {
        final generated = LevelGenerator.generate(level);
        final target = generated.blocks.firstWhere((b) => b.isTarget);
        final exitSide = generated.exitSide;

        if (exitSide == ExitSide.right || exitSide == ExitSide.left) {
          expect(
            target.orientation,
            BlockOrientation.horizontal,
            reason: 'Level $level horizontal target for $exitSide',
          );
        } else {
          expect(
            target.orientation,
            BlockOrientation.vertical,
            reason: 'Level $level vertical target for $exitSide',
          );
        }
        expect(target.length, 2, reason: 'Level $level target length');
      }
    });

    test('no blocks overlap in any generated level', () {
      for (int level = 1; level <= 200; level++) {
        final generated = LevelGenerator.generate(level);
        expect(
          _hasOverlap(generated.blocks),
          isFalse,
          reason: 'Level $level has overlapping blocks',
        );
      }
    });
  });

  group('LevelGenerator - Solvability', () {
    test('every generated level is solvable (1..200)', () {
      for (int level = 1; level <= 200; level++) {
        final generated = LevelGenerator.generate(level);
        final solution = PuzzleSolver.solve(
          GameBoard(blocks: generated.blocks, exitSide: generated.exitSide),
        );
        expect(solution, isNotNull, reason: 'Level $level unsolvable');
      }
    });

    test('reported minMoves matches solver result (1..100)', () {
      for (int level = 1; level <= 100; level++) {
        final generated = LevelGenerator.generate(level);
        final solution = PuzzleSolver.solve(
          GameBoard(blocks: generated.blocks, exitSide: generated.exitSide),
        );
        expect(solution, isNotNull);
        expect(
          solution!.length,
          generated.minMoves,
          reason: 'Level $level minMoves mismatch',
        );
      }
    });
  });

  group('LevelGenerator - Determinism', () {
    test('same level produces identical layout across calls', () {
      LevelGenerator.clearCacheForTest();
      final gen1 = LevelGenerator.generate(42);

      LevelGenerator.clearCacheForTest();
      final gen2 = LevelGenerator.generate(42);

      expect(gen1.minMoves, gen2.minMoves);
      expect(gen1.exitSide, gen2.exitSide);
      expect(
        _signature(gen1.blocks, gen1.exitSide),
        _signature(gen2.blocks, gen2.exitSide),
      );
    });

    test('sequential generation is deterministic across sessions', () {
      LevelGenerator.clearCacheForTest();
      final sig1 = <String>[];
      for (int level = 1; level <= 50; level++) {
        final generated = LevelGenerator.generate(level);
        sig1.add(_signature(generated.blocks, generated.exitSide));
      }

      LevelGenerator.clearCacheForTest();
      final sig2 = <String>[];
      for (int level = 1; level <= 50; level++) {
        final generated = LevelGenerator.generate(level);
        sig2.add(_signature(generated.blocks, generated.exitSide));
      }

      expect(sig1, sig2);
    });
  });

  group('LevelGenerator - Uniqueness', () {
    test('first 500 levels are all unique', () {
      final seen = <String>{};
      for (int level = 1; level <= 500; level++) {
        final generated = LevelGenerator.generate(level);
        final sig = _signature(generated.blocks, generated.exitSide);
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
        final generated = LevelGenerator.generate(level);
        final sig = _signature(generated.blocks, generated.exitSide);
        expect(seen.contains(sig), isFalse, reason: 'Level $level collides');
        seen.add(sig);
      }
    });
  });

  group('LevelGenerator - Exit Side Distribution', () {
    test('all 4 exit sides appear within first 20 levels', () {
      final sides = <ExitSide>{};
      for (int level = 1; level <= 20; level++) {
        final generated = LevelGenerator.generate(level);
        sides.add(generated.exitSide);
      }
      expect(sides.length, 4, reason: 'Expected all 4 exit sides');
    });

    test('same level always yields same exit side', () {
      LevelGenerator.clearCacheForTest();
      final side1 = LevelGenerator.generate(77).exitSide;

      LevelGenerator.clearCacheForTest();
      final side2 = LevelGenerator.generate(77).exitSide;

      expect(side1, side2);
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
          final generated = LevelGenerator.generate(level);
          total += generated.blocks.where((b) => !b.isTarget).length;
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
      final generated = LevelGenerator.generate(1);
      expect(generated.blocks.length, greaterThanOrEqualTo(2));
      expect(generated.minMoves, greaterThan(0));
    });

    test('extreme level number does not crash', () {
      expect(() => LevelGenerator.generate(30000), returnsNormally);
      expect(() => LevelGenerator.generate(999999), returnsNormally);
    });
  });
}

String _signature(List<Block> blocks, ExitSide exitSide) {
  final tokens =
      blocks
          .map(
            (b) =>
                '${b.isTarget ? 1 : 0},${b.orientation == BlockOrientation.vertical ? 'V' : 'H'},${b.row},${b.col},${b.length}',
          )
          .toList()
        ..sort();
  return '${exitSide.name}|${tokens.join('|')}';
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
