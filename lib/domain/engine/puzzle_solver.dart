import 'dart:collection';

import '../engine/game_board.dart';
import '../models/block.dart';

class Move {
  final String blockId;
  final int deltaRow;
  final int deltaCol;

  Move(this.blockId, this.deltaRow, this.deltaCol);
}

class PuzzleSolver {
  static String _serialize(List<Block> blocks) {
    final sorted = List<Block>.from(blocks)
      ..sort((a, b) => a.id.compareTo(b.id));
    return sorted.map((b) => '${b.id}:${b.row},${b.col}').join('|');
  }

  static List<Move>? solve(GameBoard board) {
    final queue = Queue<List<Block>>();
    final parentMap = <String, (List<Block>, Move)>{};

    final initialState = board.blocks;
    queue.add(initialState);
    parentMap[_serialize(initialState)] = (initialState, Move('', 0, 0));

    final visited = <String>{_serialize(initialState)};

    while (queue.isNotEmpty) {
      final currentBlocks = queue.removeFirst();
      final currentBoard = GameBoard(
        blocks: currentBlocks,
        exitSide: board.exitSide,
      );

      if (currentBoard.isWinConditionMet()) {
        return _reconstructPath(parentMap, currentBlocks);
      }

      for (final block in currentBlocks) {
        for (int d = -5; d <= 5; d++) {
          if (d == 0) continue;

          int dr = block.orientation == BlockOrientation.vertical ? d : 0;
          int dc = block.orientation == BlockOrientation.horizontal ? d : 0;

          if (currentBoard.canMove(block, dr, dc)) {
            final nextBlocks = currentBlocks
                .map(
                  (b) => b.id == block.id
                      ? b.copyWith(row: b.row + dr, col: b.col + dc)
                      : b,
                )
                .toList();

            final stateKey = _serialize(nextBlocks);
            if (!visited.contains(stateKey)) {
              visited.add(stateKey);
              parentMap[stateKey] = (currentBlocks, Move(block.id, dr, dc));
              queue.add(nextBlocks);
            }
          }
        }
      }
    }
    return null;
  }

  static List<Move> _reconstructPath(
    Map<String, (List<Block>, Move)> parentMap,
    List<Block> winState,
  ) {
    final path = <Move>[];
    var current = winState;
    while (true) {
      final entry = parentMap[_serialize(current)];
      if (entry == null || entry.$2.blockId == '') break;
      path.insert(0, entry.$2);
      current = entry.$1;
    }
    return path;
  }
}
