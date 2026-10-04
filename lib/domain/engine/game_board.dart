import '../models/block.dart';
import '../models/level_data.dart';

class GameBoard {
  final int gridSize = 6;
  final List<Block> blocks;
  final ExitSide exitSide;

  GameBoard({required this.blocks, required this.exitSide});

  bool isCellOccupied(int row, int col, String currentBlockId) {
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
      return true;
    }

    for (var b in blocks) {
      if (b.id == currentBlockId) continue;

      if (b.orientation == BlockOrientation.horizontal) {
        if (b.row == row && col >= b.col && col < b.col + b.length) {
          return true;
        }
      } else {
        if (b.col == col && row >= b.row && row < b.row + b.length) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMove(Block block, int deltaRow, int deltaCol) {
    if (deltaRow == 0 && deltaCol == 0) return false;

    // Movement strictly restricted to axis
    if (block.orientation == BlockOrientation.horizontal && deltaRow != 0) {
      return false;
    }
    if (block.orientation == BlockOrientation.vertical && deltaCol != 0) {
      return false;
    }

    int newRow = block.row + deltaRow;
    int newCol = block.col + deltaCol;

    // Bounds checking
    if (block.orientation == BlockOrientation.horizontal) {
      if (newCol < 0 || newCol + block.length > gridSize) return false;

      // Check every cell along the path
      if (deltaCol > 0) {
        for (
          int c = block.col + block.length;
          c < block.col + block.length + deltaCol;
          c++
        ) {
          if (isCellOccupied(block.row, c, block.id)) return false;
        }
      } else {
        for (int c = block.col - 1; c >= block.col + deltaCol; c--) {
          if (isCellOccupied(block.row, c, block.id)) return false;
        }
      }
    } else {
      if (newRow < 0 || newRow + block.length > gridSize) return false;

      if (deltaRow > 0) {
        for (
          int r = block.row + block.length;
          r < block.row + block.length + deltaRow;
          r++
        ) {
          if (isCellOccupied(r, block.col, block.id)) return false;
        }
      } else {
        for (int r = block.row - 1; r >= block.row + deltaRow; r--) {
          if (isCellOccupied(r, block.col, block.id)) return false;
        }
      }
    }

    return true;
  }

  bool tryMoveBlock(Block block, int steps) {
    int deltaRow = block.isHorizontal ? 0 : steps;
    int deltaCol = block.isHorizontal ? steps : 0;

    if (canMove(block, deltaRow, deltaCol)) {
      int index = blocks.indexWhere((b) => b.id == block.id);
      if (index != -1) {
        blocks[index] = block.copyWith(
          row: block.row + deltaRow,
          col: block.col + deltaCol,
        );
        return true;
      }
    }
    return false;
  }

  bool isWinConditionMet() {
    final target = blocks.firstWhere(
      (b) => b.isTarget,
      orElse: () => blocks.first,
    );
    switch (exitSide) {
      case ExitSide.right:
        return target.orientation == BlockOrientation.horizontal &&
            target.col + target.length == gridSize;
      case ExitSide.left:
        return target.orientation == BlockOrientation.horizontal &&
            target.col == 0;
      case ExitSide.top:
        return target.orientation == BlockOrientation.vertical &&
            target.row == 0;
      case ExitSide.bottom:
        return target.orientation == BlockOrientation.vertical &&
            target.row + target.length == gridSize;
    }
  }
}
