import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/block.dart';
import '../controllers/game_controller.dart';

class GameBoardWidget extends ConsumerStatefulWidget {
  final double borderWidth;

  const GameBoardWidget({super.key, this.borderWidth = 16.0});

  @override
  ConsumerState<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends ConsumerState<GameBoardWidget> {
  double dragAccumulator = 0.0;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final board = gameState.board;

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, outerConstraints) {
          final totalWidth = outerConstraints.maxWidth;
          final boardInnerWidth = totalWidth - (widget.borderWidth * 2);
          final cellSize = boardInnerWidth / 6;

          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B0D07),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // 1. Inner Grid Background Slots
                Positioned(
                  left: widget.borderWidth,
                  top: widget.borderWidth,
                  width: boardInnerWidth,
                  height: boardInnerWidth,
                  child: Stack(
                    children: List.generate(36, (index) {
                      int row = index ~/ 6;
                      int col = index % 6;
                      return Positioned(
                        left: col * cellSize,
                        top: row * cellSize,
                        width: cellSize,
                        height: cellSize,
                        child: Container(
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF26130B),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF170A05)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // 2. Standard Blocks (Clipped strictly inside board grid)
                Positioned(
                  left: widget.borderWidth,
                  top: widget.borderWidth,
                  width: boardInnerWidth,
                  height: boardInnerWidth,
                  child: ClipRect(
                    child: Stack(
                      children: board.blocks
                          .where((b) => !b.isTarget)
                          .map((block) => _buildBlockItem(block, cellSize))
                          .toList(),
                    ),
                  ),
                ),

                // 3. Red Target Block (Passes through exit doorway)
                Positioned(
                  left: widget.borderWidth,
                  top: widget.borderWidth,
                  width: boardInnerWidth + widget.borderWidth,
                  height: boardInnerWidth,
                  child: Stack(
                    children: board.blocks
                        .where((b) => b.isTarget)
                        .map((block) => _buildBlockItem(block, cellSize))
                        .toList(),
                  ),
                ),

                // 4. Outer Wooden Frame Overlays
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: widget.borderWidth,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF8D5B36),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: widget.borderWidth,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF8D5B36),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  width: widget.borderWidth,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF7A4D2C),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  width: widget.borderWidth,
                  height: widget.borderWidth + (2 * cellSize),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF7A4D2C),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  width: widget.borderWidth,
                  height: widget.borderWidth + (3 * cellSize),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF7A4D2C),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),

                // Doorway Indicator Icon
                Positioned(
                  right: 1,
                  top:
                      widget.borderWidth + (2 * cellSize) + (cellSize / 2) - 10,
                  width: widget.borderWidth - 2,
                  height: 20,
                  child: const Center(
                    child: Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: Color(0xFFFFB300),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlockItem(Block block, double cellSize) {
    final isHorizontal = block.orientation == BlockOrientation.horizontal;

    return Positioned(
      left: block.col * cellSize,
      top: block.row * cellSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => dragAccumulator = 0.0,
        onPanUpdate: (details) {
          final delta = isHorizontal ? details.delta.dx : details.delta.dy;
          dragAccumulator += delta;

          if (dragAccumulator.abs() >= cellSize * 0.4) {
            int step = dragAccumulator > 0 ? 1 : -1;
            int deltaRow = isHorizontal ? 0 : step;
            int deltaCol = isHorizontal ? step : 0;

            ref
                .read(gameProvider.notifier)
                .moveBlock(block, deltaRow, deltaCol);
            dragAccumulator = 0.0;
          }
        },
        child: Container(
          width: isHorizontal ? block.length * cellSize : cellSize,
          height: isHorizontal ? cellSize : block.length * cellSize,
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: block.isTarget
                    ? [const Color(0xFFFF5252), const Color(0xFFB71C1C)]
                    : [const Color(0xFFD38E53), const Color(0xFF8B5129)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: block.isTarget
                    ? const Color(0xFFFF8A80)
                    : const Color(0xFFF5C999).withValues(alpha: 0.9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: isHorizontal ? (block.length * cellSize * 0.45) : 3,
                    height: isHorizontal ? 3 : (block.length * cellSize * 0.45),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
