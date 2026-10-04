import 'dart:math';

import 'package:woodescape/domain/engine/game_board.dart';
import 'package:woodescape/domain/engine/puzzle_solver.dart';
import 'package:woodescape/domain/models/block.dart';
import 'package:woodescape/domain/models/level_data.dart';

class LevelGenerator {
  static final Map<int, (List<Block>, int)> _cache = {};
  static final Set<String> _generatedSignatures = {};

  static (List<Block>, int) generate(int level) {
    if (level == 1) {
      final blocks = _getFallbackLayout();
      final sig = _getSignature(blocks);
      _generatedSignatures.add(sig);
      return (blocks, 2);
    }
    if (_cache.containsKey(level)) return _cache[level]!;

    final difficulty = getDifficultyForLevel(level);
    final baseSeed = level * 999999937;

    int maxAttempts = 2000;
    for (int i = 0; i < maxAttempts; i++) {
      final rng = Random(baseSeed + (i * 12345));
      final blocks = _generateLayout(rng, difficulty);

      final sig = _getSignature(blocks);
      if (_generatedSignatures.contains(sig)) continue;

      final board = GameBoard(blocks: blocks);
      final solution = PuzzleSolver.solve(board);

      if (solution != null &&
          solution.length >= _getMinMoveThreshold(difficulty)) {
        _generatedSignatures.add(sig);
        final result = (blocks, solution.length);
        _cache[level] = result;
        return result;
      }
    }

    return (_getFallbackLayout(), 2);
  }

  static String _getSignature(List<Block> blocks) {
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

  static String getSignatureForTest(List<Block> blocks) =>
      _getSignature(blocks);

  static void clearCacheForTest() {
    _cache.clear();
    _generatedSignatures.clear();
  }

  static List<Block> _getFallbackLayout() {
    return [
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
    ];
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

  static List<Block> _generateLayout(Random rng, LevelDifficulty diff) {
    final blocks = <Block>[];
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
