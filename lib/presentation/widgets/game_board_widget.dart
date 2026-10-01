import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:woodescape/core/theme/app_colors.dart';
import 'package:woodescape/domain/models/block.dart';
import 'package:woodescape/presentation/controllers/game_controller.dart';

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
              color: AppColors.boardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.7),
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
                            color: AppColors.tileSlotColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.accentSlotBorder,
                            ),
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
                // Top Frame
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: widget.borderWidth,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.frameBorderLight,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                // Bottom Frame
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: widget.borderWidth,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.frameBorderLight,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                // Left Frame
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  width: widget.borderWidth,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.frameBorderDark,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                // Right Frame
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: widget.borderWidth,
                    decoration: const BoxDecoration(
                      color: AppColors.frameBorderDark,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
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
                      color: AppColors.accentGold,
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
                .slideBlock(block, deltaRow, deltaCol);
            dragAccumulator = 0.0;
          }
        },
        onPanEnd: (_) {
          if (dragAccumulator.abs() >= cellSize * 0.3) {
            int step = dragAccumulator > 0 ? 1 : -1;
            int deltaRow = isHorizontal ? 0 : step;
            int deltaCol = isHorizontal ? step : 0;

            ref
                .read(gameProvider.notifier)
                .slideBlock(block, deltaRow, deltaCol);
          }
          dragAccumulator = 0.0;
        },
        child: Container(
          width: isHorizontal ? block.length * cellSize : cellSize,
          height: isHorizontal ? cellSize : block.length * cellSize,
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              gradient: block.isTarget
                  ? AppColors.targetBlockGradient
                  : AppColors.standardBlockGradient,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: block.isTarget
                    ? AppColors.accentSoftRed
                    : AppColors.withAlpha(AppColors.accentLightPeach, 0.9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.4),
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
                        color: AppColors.withAlpha(AppColors.white, 0.15),
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
                      color: AppColors.withAlpha(AppColors.black, 0.18),
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
