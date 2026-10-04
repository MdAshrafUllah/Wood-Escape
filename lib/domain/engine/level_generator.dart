import 'dart:math';

import 'package:woodescape/domain/engine/game_board.dart';
import 'package:woodescape/domain/engine/puzzle_solver.dart';
import 'package:woodescape/domain/models/block.dart';
import 'package:woodescape/domain/models/level_data.dart';

class GeneratedLevel {
  final List<Block> blocks;
  final int minMoves;
  final ExitSide exitSide;
  const GeneratedLevel(this.blocks, this.minMoves, this.exitSide);
}

class LevelGenerator {
  static final Map<int, GeneratedLevel> _cache = {};
  static final Set<String> _generatedSignatures = {};

  static GeneratedLevel generate(int level) {
    if (level == 1) return _returnFallback();
    if (_cache.containsKey(level)) return _cache[level]!;

    final baseSeed = level * 999999937;
    final difficulty = getDifficultyForLevel(level);

    int maxAttempts = 2000;
    for (int i = 0; i < maxAttempts; i++) {
      final rng = Random(baseSeed + (i * 12345));
      final exitSide = _pickExitSide(level);
      final blocks = _generateLayout(rng, difficulty, exitSide);

      final sig = _getSignature(blocks, exitSide);
      if (_generatedSignatures.contains(sig)) continue;

      final board = GameBoard(blocks: blocks, exitSide: exitSide);
      final solution = PuzzleSolver.solve(board);

      if (solution != null &&
          solution.length >= _getMinMoveThreshold(difficulty)) {
        _generatedSignatures.add(sig);
        final result = GeneratedLevel(blocks, solution.length, exitSide);
        _cache[level] = result;
        return result;
      }
    }

    return _returnFallback();
  }

  static ExitSide _pickExitSide(int level) => ExitSide.values[level % 4];

  static GeneratedLevel _returnFallback() {
    final fallback = GeneratedLevel(
      [
        Block(
          id: 'target',
          isTarget: true,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 2,
          col: 0,
        ),
        Block(
          id: 'v1',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 2,
          row: 0,
          col: 2,
        ),
        Block(
          id: 'h1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 3,
          row: 4,
          col: 1,
        ),
      ],
      2,
      ExitSide.right,
    );
    _generatedSignatures.add(_getSignature(fallback.blocks, fallback.exitSide));
    return fallback;
  }

  static String _getSignature(List<Block> blocks, ExitSide exitSide) {
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

  static String getSignatureForTest(List<Block> blocks, ExitSide exitSide) =>
      _getSignature(blocks, exitSide);

  static void clearCacheForTest() {
    _cache.clear();
    _generatedSignatures.clear();
  }

  static int _getMinMoveThreshold(LevelDifficulty diff) {
    switch (diff) {
      case LevelDifficulty.easy:
        return 1;
      case LevelDifficulty.medium:
        return 3;
      case LevelDifficulty.hard:
        return 6;
      case LevelDifficulty.expert:
        return 10;
      case LevelDifficulty.legend:
        return 15;
      case LevelDifficulty.master:
        return 20;
    }
  }

  static LevelDifficulty getDifficultyForLevel(int level) {
    if (level <= 5000) return LevelDifficulty.easy;
    if (level <= 10000) return LevelDifficulty.medium;
    if (level <= 15000) return LevelDifficulty.hard;
    if (level <= 20000) return LevelDifficulty.expert;
    if (level <= 25000) return LevelDifficulty.legend;
    return LevelDifficulty.master;
  }

  static List<Block> _generateLayout(
    Random rng,
    LevelDifficulty diff,
    ExitSide exitSide,
  ) {
    final blocks = <Block>[];

    switch (exitSide) {
      case ExitSide.right:
        blocks.add(
          Block(
            id: 'target',
            isTarget: true,
            orientation: BlockOrientation.horizontal,
            length: 2,
            row: 2,
            col: rng.nextInt(3),
          ),
        );
        break;
      case ExitSide.left:
        blocks.add(
          Block(
            id: 'target',
            isTarget: true,
            orientation: BlockOrientation.horizontal,
            length: 2,
            row: 2,
            col: 2 + rng.nextInt(3),
          ),
        );
        break;
      case ExitSide.top:
        blocks.add(
          Block(
            id: 'target',
            isTarget: true,
            orientation: BlockOrientation.vertical,
            length: 2,
            col: 2,
            row: 2 + rng.nextInt(3),
          ),
        );
        break;
      case ExitSide.bottom:
        blocks.add(
          Block(
            id: 'target',
            isTarget: true,
            orientation: BlockOrientation.vertical,
            length: 2,
            col: 2,
            row: rng.nextInt(3),
          ),
        );
        break;
    }

    final obstacleCount = _getObstacleCount(diff, rng);
    int attempts = 0;
    while (blocks.length < obstacleCount + 1 && attempts < 1000) {
      attempts++;
      final len = rng.nextInt(2) + 2;
      final isVertical = rng.nextBool();
      int row = isVertical ? rng.nextInt(6 - len + 1) : rng.nextInt(6);
      int col = isVertical ? rng.nextInt(6) : rng.nextInt(6 - len + 1);

      final newBlock = Block(
        id: 'obs_${rng.nextInt(1000000)}',
        isTarget: false,
        orientation: isVertical
            ? BlockOrientation.vertical
            : BlockOrientation.horizontal,
        length: len,
        row: row,
        col: col,
      );

      if (!_overlaps(newBlock, blocks)) blocks.add(newBlock);
    }
    return blocks;
  }

  static bool _overlaps(Block newBlock, List<Block> existing) {
    for (final b in existing) {
      for (int i = 0; i < newBlock.length; i++) {
        int r =
            newBlock.row +
            (newBlock.orientation == BlockOrientation.vertical ? i : 0);
        int c =
            newBlock.col +
            (newBlock.orientation == BlockOrientation.horizontal ? i : 0);
        for (int j = 0; j < b.length; j++) {
          int br = b.row + (b.orientation == BlockOrientation.vertical ? j : 0);
          int bc =
              b.col + (b.orientation == BlockOrientation.horizontal ? j : 0);
          if (r == br && c == bc) return true;
        }
      }
    }
    return false;
  }

  static int _getObstacleCount(LevelDifficulty diff, Random rng) {
    switch (diff) {
      case LevelDifficulty.easy:
        return rng.nextInt(2) + 2;
      case LevelDifficulty.medium:
        return rng.nextInt(2) + 3;
      case LevelDifficulty.hard:
        return rng.nextInt(2) + 5;
      case LevelDifficulty.expert:
        return rng.nextInt(2) + 6;
      case LevelDifficulty.legend:
        return rng.nextInt(2) + 7;
      case LevelDifficulty.master:
        return rng.nextInt(2) + 8;
    }
  }
}
