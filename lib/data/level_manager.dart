import '../domain/engine/game_board.dart';
import '../domain/models/block.dart';

class LevelManager {
  static GameBoard getLevel1() {
    return GameBoard(
      blocks: [
        // Target Red Block (Row 2, Col 0, Horizontal)
        Block(
          id: 'RED',
          isTarget: true,
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 2,
          col: 0,
        ),

        // Obstacles
        Block(
          id: 'v1',
          orientation: BlockOrientation.vertical,
          length: 3,
          row: 0,
          col: 2,
        ),
        Block(
          id: 'h1',
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 0,
          col: 3,
        ),
        Block(
          id: 'v2',
          orientation: BlockOrientation.vertical,
          length: 2,
          row: 3,
          col: 1,
        ),
        Block(
          id: 'h2',
          orientation: BlockOrientation.horizontal,
          length: 2,
          row: 4,
          col: 3,
        ),
      ],
    );
  }
}
