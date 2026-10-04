import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:woodescape/core/constants/app_audio.dart';
import 'package:woodescape/data/local/user_progress_notifier.dart';
import 'package:woodescape/domain/engine/game_board.dart';
import 'package:woodescape/domain/engine/level_generator.dart';
import 'package:woodescape/domain/models/block.dart';
import 'package:woodescape/domain/models/level_data.dart';
import 'package:woodescape/services/audio_service.dart';
import 'package:woodescape/services/haptic_service.dart';

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
  final List<GameBoard> _history = [];

  bool get hasHistory => _history.isNotEmpty;

  static LevelDifficulty getDifficultyForLevel(int level) {
    return LevelGenerator.getDifficultyForLevel(level);
  }

  @override
  GameState build() {
    // 1. Storage থেকে আগের সেভ করা ডেটা লোড
    final savedProgress = ref.read(progressProvider);
    final level = savedProgress.currentLevel;

    _history.clear();
    final (blocks, minMoves) = LevelGenerator.generate(level);

    return GameState(
      currentLevel: level,
      unlockedLevel: savedProgress.unlockedLevel,
      board: GameBoard(blocks: blocks),
      difficulty: getDifficultyForLevel(level),
      moveCount: 0,
      minMoves: minMoves,
      isCompleted: false,
    );
  }

  void selectLevel(int level) {
    final currentUnlocked = ref.read(progressProvider).unlockedLevel;

    if (level <= currentUnlocked) {
      _history.clear();
      final (blocks, minMoves) = LevelGenerator.generate(level);

      state = state.copyWith(
        currentLevel: level,
        unlockedLevel: currentUnlocked,
        board: GameBoard(blocks: blocks),
        difficulty: getDifficultyForLevel(level),
        moveCount: 0,
        minMoves: minMoves,
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
      AudioService().playSfx(AppAudio.move);
      HapticService().lightImpact();

      _history.add(state.board);
      if (_history.length > 100) {
        _history.removeAt(0);
      }

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
        AudioService().playSfx(AppAudio.win);
        HapticService().winVibration();
        ref
            .read(progressProvider.notifier)
            .recordStars(state.currentLevel, state.stars);
      }
    }
  }

  void undo() {
    if (state.isCompleted) return;
    if (_history.isEmpty) return;

    final previousBoard = _history.removeLast();

    state = state.copyWith(
      board: previousBoard,
      moveCount: state.moveCount > 0 ? state.moveCount - 1 : 0,
      isCompleted: false,
    );

    // AudioService().playSfx(AppAudio.undo); // Pending asset
    HapticService().lightImpact();
  }

  void loadNextLevel() {
    final completedLevel = state.currentLevel;
    final nextLevel = completedLevel + 1;

    final updatedUnlocked = nextLevel > state.unlockedLevel
        ? nextLevel
        : state.unlockedLevel;

    _history.clear();
    final (blocks, minMoves) = LevelGenerator.generate(nextLevel);

    state = GameState(
      currentLevel: nextLevel,
      unlockedLevel: updatedUnlocked,
      board: GameBoard(blocks: blocks),
      difficulty: getDifficultyForLevel(nextLevel),
      moveCount: 0,
      minMoves: minMoves,
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
    _history.clear();
    final (blocks, minMoves) = LevelGenerator.generate(state.currentLevel);
    state = state.copyWith(
      board: GameBoard(blocks: blocks),
      minMoves: minMoves,
      moveCount: 0,
      isCompleted: false,
    );
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);
