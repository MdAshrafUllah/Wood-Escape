import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:woodescape/domain/engine/game_board.dart';
import 'package:woodescape/domain/models/block.dart';

class GameState {
  final int currentLevel;
  final int unlockedLevel;
  final GameBoard board;

  GameState({
    required this.currentLevel,
    required this.unlockedLevel,
    required this.board,
  });

  GameState copyWith({
    int? currentLevel,
    int? unlockedLevel,
    GameBoard? board,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      board: board ?? this.board,
    );
  }
}

class GameNotifier extends Notifier<GameState> {
  static List<Block> generateLevel(int level) {
    int pattern = (level - 1) % 4;

    switch (pattern) {
      case 0:
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
            row: 1,
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
            row: 3,
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
            id: 'h_mid_2',
            isTarget: false,
            orientation: BlockOrientation.horizontal,
            length: 3,
            row: 4,
            col: 3,
          ),
          Block(
            id: 'h_bottom',
            isTarget: false,
            orientation: BlockOrientation.horizontal,
            length: 3,
            row: 5,
            col: 1,
          ),
        ];
      case 1:
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
          Block(
            id: 'v3',
            isTarget: false,
            orientation: BlockOrientation.vertical,
            length: 2,
            row: 3,
            col: 0,
          ),
        ];
      case 2:
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
          Block(
            id: 'v3',
            isTarget: false,
            orientation: BlockOrientation.vertical,
            length: 2,
            row: 3,
            col: 0,
          ),
        ];
      default:
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
          Block(
            id: 'v3',
            isTarget: false,
            orientation: BlockOrientation.vertical,
            length: 2,
            row: 3,
            col: 5,
          ),
        ];
    }
  }

  @override
  GameState build() {
    return GameState(
      currentLevel: 1,
      unlockedLevel: 1,
      board: GameBoard(blocks: generateLevel(1)),
    );
  }

  void selectLevel(int level) {
    if (level <= state.unlockedLevel) {
      state = state.copyWith(
        currentLevel: level,
        board: GameBoard(blocks: generateLevel(level)),
      );
    }
  }

  void moveBlock(Block block, int deltaRow, int deltaCol) {
    if (deltaRow == 0 && deltaCol == 0) return;

    if (state.board.canMove(block, deltaRow, deltaCol)) {
      final updatedBlocks = state.board.blocks.map((b) {
        if (b.id == block.id) {
          return b.copyWith(row: b.row + deltaRow, col: b.col + deltaCol);
        }
        return b;
      }).toList();

      state = state.copyWith(board: GameBoard(blocks: updatedBlocks));
    }
  }

  void loadNextLevel() {
    int nextLevel = state.currentLevel + 1;
    if (nextLevel > 100) nextLevel = 1;

    int newUnlockedLevel = nextLevel > state.unlockedLevel
        ? nextLevel
        : state.unlockedLevel;

    state = state.copyWith(
      currentLevel: nextLevel,
      unlockedLevel: newUnlockedLevel,
      board: GameBoard(blocks: generateLevel(nextLevel)),
    );
  }

  void resetLevel() {
    state = state.copyWith(
      board: GameBoard(blocks: generateLevel(state.currentLevel)),
    );
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});
