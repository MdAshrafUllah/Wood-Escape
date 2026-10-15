import 'dart:async';

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
  final bool canUndo;
  final bool isLoading;
  final ExitSide exitSide;
  final LevelDifficulty difficulty;

  GameState({
    required this.currentLevel,
    required this.unlockedLevel,
    required this.board,
    required this.difficulty,
    required this.exitSide,
    this.moveCount = 0,
    this.minMoves = 10,
    this.isCompleted = false,
    this.canUndo = false,
    this.isLoading = false,
  });

  GameState copyWith({
    int? currentLevel,
    int? unlockedLevel,
    GameBoard? board,
    LevelDifficulty? difficulty,
    ExitSide? exitSide,
    int? moveCount,
    int? minMoves,
    bool? isCompleted,
    bool? canUndo,
    bool? isLoading,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      board: board ?? this.board,
      difficulty: difficulty ?? this.difficulty,
      exitSide: exitSide ?? this.exitSide,
      moveCount: moveCount ?? this.moveCount,
      minMoves: minMoves ?? this.minMoves,
      isCompleted: isCompleted ?? this.isCompleted,
      canUndo: canUndo ?? this.canUndo,
      isLoading: isLoading ?? this.isLoading,
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
  static const int _maxHistoryLength = 100;

  static LevelDifficulty getDifficultyForLevel(int level) {
    return LevelGenerator.getDifficultyForLevel(level);
  }

  @override
  GameState build() {
    final savedProgress = ref.read(progressProvider);
    final level = savedProgress.currentLevel;

    _history.clear();
    return GameState(
      currentLevel: level,
      unlockedLevel: savedProgress.unlockedLevel,
      board: GameBoard(blocks: const [], exitSide: ExitSide.right),
      difficulty: getDifficultyForLevel(level),
      exitSide: ExitSide.right,
      moveCount: 0,
      minMoves: 10,
      isCompleted: false,
      canUndo: false,
      isLoading: false,
    );
  }

  Future<void> selectLevel(int level) async {
    final currentUnlocked = ref.read(progressProvider).unlockedLevel;

    if (level <= currentUnlocked) {
      state = state.copyWith(
        currentLevel: level,
        isLoading: true,
        board: GameBoard(blocks: const [], exitSide: ExitSide.right),
        moveCount: 0,
        isCompleted: false,
        canUndo: false,
      );
      _history.clear();
      final generated = await LevelGenerator.generateAsync(level);

      state = state.copyWith(
        unlockedLevel: currentUnlocked,
        board: GameBoard(
          blocks: generated.blocks,
          exitSide: generated.exitSide,
        ),
        difficulty: getDifficultyForLevel(level),
        exitSide: generated.exitSide,
        moveCount: 0,
        minMoves: generated.minMoves,
        isCompleted: false,
        canUndo: false,
        isLoading: false,
      );

      ref.read(progressProvider.notifier).setCurrentLevel(level);
    }
    unawaited(LevelGenerator.prefetch(level + 1));
  }

  void slideBlock(Block block, int totalDeltaRow, int totalDeltaCol) {
    if (state.isCompleted || (totalDeltaRow == 0 && totalDeltaCol == 0)) {
      return;
    }

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
      if (_history.length > _maxHistoryLength) {
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

      final updatedBoard = GameBoard(
        blocks: updatedBlocks,
        exitSide: state.exitSide,
      );
      final isWon = updatedBoard.isWinConditionMet();

      state = state.copyWith(
        board: updatedBoard,
        moveCount: state.moveCount + 1,
        isCompleted: isWon,
        canUndo: true,
      );

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
      canUndo: _history.isNotEmpty,
    );

    HapticService().lightImpact();
  }

  Future<void> loadNextLevel() async {
    final completedLevel = state.currentLevel;
    final nextLevel = completedLevel + 1;

    final updatedUnlocked = nextLevel > state.unlockedLevel
        ? nextLevel
        : state.unlockedLevel;

    state = state.copyWith(
      currentLevel: nextLevel,
      isLoading: true,
      board: GameBoard(blocks: const [], exitSide: ExitSide.right),
      moveCount: 0,
      isCompleted: false,
      canUndo: false,
    );
    _history.clear();
    final generated = await LevelGenerator.generateAsync(nextLevel);

    state = state.copyWith(
      unlockedLevel: updatedUnlocked,
      board: GameBoard(blocks: generated.blocks, exitSide: generated.exitSide),
      difficulty: getDifficultyForLevel(nextLevel),
      exitSide: generated.exitSide,
      moveCount: 0,
      minMoves: generated.minMoves,
      isCompleted: false,
      canUndo: false,
      isLoading: false,
    );

    ref.read(progressProvider.notifier).setUnlockedLevel(updatedUnlocked);
    ref.read(progressProvider.notifier).setCurrentLevel(nextLevel);
    unawaited(LevelGenerator.prefetch(nextLevel + 1));
  }

  Future<void> nextLevel() async {
    await loadNextLevel();
  }

  Future<void> resetLevel() async {
    state = state.copyWith(
      isLoading: true,
      board: GameBoard(blocks: const [], exitSide: ExitSide.right),
      moveCount: 0,
      isCompleted: false,
      canUndo: false,
    );
    _history.clear();
    final generated = await LevelGenerator.generateAsync(state.currentLevel);

    state = state.copyWith(
      board: GameBoard(blocks: generated.blocks, exitSide: generated.exitSide),
      exitSide: generated.exitSide,
      minMoves: generated.minMoves,
      moveCount: 0,
      isCompleted: false,
      canUndo: false,
      isLoading: false,
    );
    unawaited(LevelGenerator.prefetch(state.currentLevel + 1));
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);
