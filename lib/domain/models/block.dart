enum BlockOrientation { horizontal, vertical }

class Block {
  final String id;
  final bool isTarget;
  final BlockOrientation orientation;
  final int length;
  int row;
  int col;

  Block({
    required this.id,
    this.isTarget = false,
    required this.orientation,
    required this.length,
    required this.row,
    required this.col,
  });

  bool get isHorizontal => orientation == BlockOrientation.horizontal;

  Block copyWith({int? row, int? col}) {
    return Block(
      id: id,
      isTarget: isTarget,
      orientation: orientation,
      length: length,
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }
}
