import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:woodescape/data/local/user_progress_notifier.dart';
import 'package:woodescape/domain/engine/game_board.dart';
import 'package:woodescape/domain/models/block.dart';
import 'package:woodescape/domain/models/level_data.dart';

class GameState {
  final int currentLevel;
  final int unlockedLevel;
  final GameBoard board;
  final int moveCount;
  final int minMoves;
  final bool isCompleted;
  final LevelDifficulty difficulty;

  GameState({
    required this.currentLevel,
    required this.unlockedLevel,
    required this.board,
    required this.difficulty,
    this.moveCount = 0,
    this.minMoves = 10,
    this.isCompleted = false,
  });

  GameState copyWith({
    int? currentLevel,
    int? unlockedLevel,
    GameBoard? board,
    LevelDifficulty? difficulty,
    int? moveCount,
    int? minMoves,
    bool? isCompleted,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      board: board ?? this.board,
      difficulty: difficulty ?? this.difficulty,
      moveCount: moveCount ?? this.moveCount,
      minMoves: minMoves ?? this.minMoves,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  int get stars => calculateStars(moveCount, minMoves);
}

int calculateStars(int moves, int minMoves) {
  if (moves <= minMoves + 2) {
    return 3;
  } else if (moves <= minMoves + 8) {
    return 2;
  } else {
    return 1;
  }
}

class GameNotifier extends Notifier<GameState> {
  static LevelDifficulty getDifficultyForLevel(int level) {
    if (level <= 5000) return LevelDifficulty.easy;
    if (level <= 10000) return LevelDifficulty.medium;
    if (level <= 15000) return LevelDifficulty.hard;
    if (level <= 20000) return LevelDifficulty.expert;
    if (level <= 25000) return LevelDifficulty.legend;
    return LevelDifficulty.master;
  }

  static List<Block> generateLevel(int level) {
    final difficulty = getDifficultyForLevel(level);

    switch (difficulty) {
      case LevelDifficulty.easy:
        return _generateEasyLevel(level);
      case LevelDifficulty.medium:
        return _generateMediumLevel(level);
      case LevelDifficulty.hard:
        return _generateHardLevel(level);
      case LevelDifficulty.expert:
        return _generateExpertLevel(level);
      case LevelDifficulty.legend:
        return _generateLegendLevel(level);
      case LevelDifficulty.master:
        return _generateMasterLevel(level);
    }
  }

  // --- EASY LAYOUTS (Level 1 - 20) ---
  static List<Block> _generateEasyLevel(int level) {
    int variant = (level - 1) % 5;
    if (variant == 0) {
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
    } else if (variant == 1) {
      return [
        Block(
          id: 'target',
          isTarget: true,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 2,
          col: 1,
        ),
        Block(
          id: 'v1',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 0,
          col: 3,
        ),
        Block(
          id: 'h1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 5,
          col: 2,
        ),
      ];
    } else if (variant == 2) {
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
          row: 1,
          col: 2,
        ),
        Block(
          id: 'v2',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 2,
          row: 3,
          col: 3,
        ),
      ];
    } else if (variant == 3) {
      return [
        Block(
          id: 'target',
          isTarget: true,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 2,
          col: 1,
        ),
        Block(
          id: 'v1',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 1,
          col: 4,
        ),
        Block(
          id: 'h1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 0,
          col: 0,
        ),
      ];
    } else {
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
          length: 3,
          row: 0,
          col: 2,
        ),
        Block(
          id: 'h1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 3,
          row: 4,
          col: 0,
        ),
      ];
    }
  }

  // --- MEDIUM LAYOUTS ---
  static List<Block> _generateMediumLevel(int level) {
    int variant = (level - 21) % 4;
    if (variant == 0) {
      return [
        Block(
          id: 'target',
          isTarget: true,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 2,
          col: 1,
        ),
        Block(
          id: 'v1',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 0,
          col: 3,
        ),
        Block(
          id: 'v2',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 2,
          row: 1,
          col: 0,
        ),
        Block(
          id: 'h1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 3,
          col: 1,
        ),
        Block(
          id: 'h2',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 3,
          row: 5,
          col: 2,
        ),
      ];
    } else if (variant == 1) {
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
          length: 3,
          row: 0,
          col: 2,
        ),
        Block(
          id: 'h1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 0,
          col: 0,
        ),
        Block(
          id: 'v2',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 1,
          col: 5,
        ),
        Block(
          id: 'h2',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 3,
          row: 5,
          col: 2,
        ),
      ];
    } else if (variant == 2) {
      return [
        Block(
          id: 'target',
          isTarget: true,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 2,
          col: 2,
        ),
        Block(
          id: 'v1',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 2,
          row: 0,
          col: 1,
        ),
        Block(
          id: 'h1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 3,
          row: 0,
          col: 2,
        ),
        Block(
          id: 'v2',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 2,
          col: 4,
        ),
        Block(
          id: 'h2',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 4,
          col: 1,
        ),
      ];
    } else {
      return [
        Block(
          id: 'target',
          isTarget: true,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 2,
          col: 1,
        ),
        Block(
          id: 'v1',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 2,
          row: 0,
          col: 0,
        ),
        Block(
          id: 'h1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 0,
          col: 3,
        ),
        Block(
          id: 'v2',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 1,
          col: 3,
        ),
        Block(
          id: 'h2',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 5,
          col: 0,
        ),
      ];
    }
  }

  // --- HARD LAYOUTS ---
  static List<Block> _generateHardLevel(int level) {
    int variant = (level - 51) % 3;
    if (variant == 0) {
      return [
        Block(
          id: 'target',
          isTarget: true,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 2,
          col: 1,
        ),
        Block(
          id: 'v_left',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 0,
          col: 0,
        ),
        Block(
          id: 'v_top',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 2,
          row: 0,
          col: 1,
        ),
        Block(
          id: 'v_mid',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 0,
          col: 3,
        ),
        Block(
          id: 'v_right',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 0,
          col: 5,
        ),
        Block(
          id: 'v_center_bottom',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 2,
          row: 4,
          col: 2,
        ),
        Block(
          id: 'h_mid_1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 3,
          row: 3,
          col: 3,
        ),
        Block(
          id: 'h_bottom',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 3,
          row: 5,
          col: 3,
        ),
      ];
    } else if (variant == 1) {
      return [
        Block(
          id: 'target',
          isTarget: true,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 2,
          col: 1,
        ),
        Block(
          id: 'v1',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 0,
          col: 0,
        ),
        Block(
          id: 'v2',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 2,
          row: 0,
          col: 3,
        ),
        Block(
          id: 'v3',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 0,
          col: 5,
        ),
        Block(
          id: 'h1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 3,
          row: 3,
          col: 3,
        ),
        Block(
          id: 'h2',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 3,
          row: 4,
          col: 0,
        ),
        Block(
          id: 'h3',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 5,
          col: 3,
        ),
      ];
    } else {
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
          length: 3,
          row: 0,
          col: 2,
        ),
        Block(
          id: 'v2',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 0,
          col: 3,
        ),
        Block(
          id: 'v3',
          isTarget: false,
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 0,
          col: 4,
        ),
        Block(
          id: 'h1',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 3,
          col: 0,
        ),
        Block(
          id: 'h2',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 3,
          row: 4,
          col: 2,
        ),
        Block(
          id: 'h3',
          isTarget: false,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 5,
          col: 0,
        ),
      ];
    }
  }

  static List<Block> _generateExpertLevel(int level) =>
      _generateHardLevel(level);
  static List<Block> _generateLegendLevel(int level) =>
      _generateHardLevel(level);
  static List<Block> _generateMasterLevel(int level) =>
      _generateHardLevel(level);

  static int getMinMovesForLevel(int level) {
    final diff = getDifficultyForLevel(level);
    switch (diff) {
      case LevelDifficulty.easy:
        return 5 + (level % 3);
      case LevelDifficulty.medium:
        return 8 + (level % 4);
      case LevelDifficulty.hard:
        return 12 + (level % 5);
      case LevelDifficulty.expert:
        return 16 + (level % 6);
      case LevelDifficulty.legend:
        return 22 + (level % 8);
      case LevelDifficulty.master:
        return 28 + (level % 10);
    }
  }

  @override
  GameState build() {
    // 1. Storage থেকে আগের সেভ করা ডেটা লোড
    final savedProgress = ref.read(progressProvider);
    final level = savedProgress.currentLevel;

    return GameState(
      currentLevel: level,
      unlockedLevel: savedProgress.unlockedLevel,
      board: GameBoard(blocks: generateLevel(level)),
      difficulty: getDifficultyForLevel(level),
      moveCount: 0,
      minMoves: getMinMovesForLevel(level),
      isCompleted: false,
    );
  }

  void selectLevel(int level) {
    final currentUnlocked = ref.read(progressProvider).unlockedLevel;

    if (level <= currentUnlocked) {
      state = state.copyWith(
        currentLevel: level,
        unlockedLevel: currentUnlocked,
        board: GameBoard(blocks: generateLevel(level)),
        difficulty: getDifficultyForLevel(level),
        moveCount: 0,
        minMoves: getMinMovesForLevel(level),
        isCompleted: false,
      );

      // Current level পারসিস্টেন্সের জন্য সেভ করা
      ref.read(progressProvider.notifier).setCurrentLevel(level);
    }
  }

  void slideBlock(Block block, int totalDeltaRow, int totalDeltaCol) {
    if (state.isCompleted || (totalDeltaRow == 0 && totalDeltaCol == 0)) return;

    int maxSteps = 0;
    int stepR = totalDeltaRow.sign;
    int stepC = totalDeltaCol.sign;
    int limit = totalDeltaRow != 0 ? totalDeltaRow.abs() : totalDeltaCol.abs();

    for (int i = 1; i <= limit; i++) {
      if (state.board.canMove(block, stepR * i, stepC * i)) {
        maxSteps = i;
      } else {
        break;
      }
    }

    if (maxSteps > 0) {
      final updatedBlocks = state.board.blocks.map((b) {
        if (b.id == block.id) {
          return b.copyWith(
            row: b.row + (stepR * maxSteps),
            col: b.col + (stepC * maxSteps),
          );
        }
        return b;
      }).toList();

      final updatedBoard = GameBoard(blocks: updatedBlocks);
      final isWon = updatedBoard.isWinConditionMet();

      state = state.copyWith(
        board: updatedBoard,
        moveCount: state.moveCount + 1,
        isCompleted: isWon,
      );

      // লেভেল জিতলে সাথে সাথে স্টার সেভ করা
      if (isWon) {
        ref
            .read(progressProvider.notifier)
            .recordStars(state.currentLevel, state.stars);
      }
    }
  }

  void loadNextLevel() {
    final completedLevel = state.currentLevel;
    final nextLevel = completedLevel + 1;

    final updatedUnlocked = nextLevel > state.unlockedLevel
        ? nextLevel
        : state.unlockedLevel;

    state = GameState(
      currentLevel: nextLevel,
      unlockedLevel: updatedUnlocked,
      board: GameBoard(blocks: generateLevel(nextLevel)),
      difficulty: getDifficultyForLevel(nextLevel),
      moveCount: 0,
      minMoves: getMinMovesForLevel(nextLevel),
      isCompleted: false,
    );

    // 2. সেভ লেভেল স্টেট
    ref.read(progressProvider.notifier).setUnlockedLevel(updatedUnlocked);
    ref.read(progressProvider.notifier).setCurrentLevel(nextLevel);
  }

  void nextLevel() {
    loadNextLevel();
  }

  void resetLevel() {
    state = state.copyWith(
      board: GameBoard(blocks: generateLevel(state.currentLevel)),
      moveCount: 0,
      isCompleted: false,
    );
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);
