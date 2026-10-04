import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:woodescape/core/router/routers.dart';
import 'package:woodescape/core/theme/app_colors.dart';
import 'package:woodescape/core/utils/app_dialog.dart';
import 'package:woodescape/domain/engine/puzzle_solver.dart';
import 'package:woodescape/domain/models/block.dart';
import 'package:woodescape/domain/models/level_data.dart';
import 'package:woodescape/presentation/controllers/game_controller.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  double dragAccumulator = 0.0;
  bool isDialogShown = false;

  // Hint Animation variables
  String? highlightedBlockId;
  int? hintDeltaRow;
  int? hintDeltaCol;

  late AnimationController _hintAnimationController;
  late Animation<double> _hintGlowAnimation;
  late Animation<double> _hintArrowOffsetAnimation;
  int _hintAnimationCount = 0;

  @override
  void initState() {
    super.initState();
    _hintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _hintGlowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _hintAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _hintArrowOffsetAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _hintAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _hintAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _hintAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed &&
          highlightedBlockId != null) {
        if (_hintAnimationCount < 3) {
          _hintAnimationCount++;
          _hintAnimationController.forward();
        } else {
          setState(() {
            highlightedBlockId = null;
            hintDeltaRow = null;
            hintDeltaCol = null;
          });
        }
      }
    });
  }

  void _triggerHintAnimation(String blockId, int deltaRow, int deltaCol) {
    setState(() {
      highlightedBlockId = blockId;
      hintDeltaRow = deltaRow;
      hintDeltaCol = deltaCol;
      _hintAnimationCount = 0;
    });
    _hintAnimationController.forward();
  }

  @override
  void dispose() {
    _hintAnimationController.dispose();
    super.dispose();
  }

  void _showCompletionDialog(
    BuildContext context,
    WidgetRef ref,
    int level,
    int moves,
    int minMoves,
  ) {
    if (isDialogShown) return;
    isDialogShown = true;

    final stars = calculateStars(moves, minMoves);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.tileSlotColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.accentGold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.8),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isEarned = index < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.star_rounded,
                        size: index == 1 ? 52 : 42,
                        color: isEarned
                            ? AppColors.accentGold
                            : AppColors.starEmpty,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  'game.passed'.tr(namedArgs: {'level': '$level'}),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.splashTitleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'game.completed_in'.tr(namedArgs: {'moves': '$moves'}),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'game.best_possible'.tr(namedArgs: {'moves': '$minMoves'}),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.withAlpha(AppColors.splashTitleColor, 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(
                            color: AppColors.frameBorderLight,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          isDialogShown = false;
                          Navigator.of(context).pop();
                          ref.read(gameProvider.notifier).resetLevel();
                        },
                        child: Text(
                          'game.play_again'.tr(),
                          style: const TextStyle(
                            color: AppColors.splashTitleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          isDialogShown = false;
                          Navigator.of(context).pop();
                          ref.read(gameProvider.notifier).nextLevel();
                        },
                        child: Text(
                          'game.next_level'.tr(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final board = gameState.board;

    ref.listen<GameState>(gameProvider, (previous, next) {
      if (next.isCompleted && !(previous?.isCompleted ?? false)) {
        _showCompletionDialog(
          context,
          ref,
          next.currentLevel,
          next.moveCount,
          next.minMoves,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            if (isLandscape) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    // Left Side: Header Info & Hint Controls
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeaderCard(gameState, board),
                          const SizedBox(height: 12),
                          _buildInstructionBadge(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Side: Maximized Responsive Board
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _buildGameBoard(board),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Portrait Mode Layout
            return Column(
              children: [
                _buildHeaderCard(gameState, board),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildGameBoard(board),
                  ),
                ),
                const Spacer(),
                _buildInstructionBadge(),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }

  // Optimized Compact Header Widget
  Widget _buildHeaderCard(GameState gameState, dynamic board) {
    final hasHistory = ref.watch(gameProvider.notifier).hasHistory;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.withAlpha(AppColors.cardSurface, 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.withAlpha(AppColors.accentLightBrownGradient, 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () => context.pop(),
          ),
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            icon: Icon(
              Icons.undo_rounded,
              color: hasHistory
                  ? AppColors.textPrimary
                  : AppColors.withAlpha(AppColors.textPrimary, 0.3),
              size: 22,
            ),
            onPressed: hasHistory
                ? () => ref.read(gameProvider.notifier).undo()
                : null,
          ),
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            icon: const Icon(
              Icons.grid_view_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () => context.push(AppRoutes.level),
          ),

          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.withAlpha(AppColors.frameBorderLight, 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'game.level'.tr(
                        namedArgs: {'level': '${gameState.currentLevel}'},
                      ),
                      style: const TextStyle(
                        color: AppColors.splashTitleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.withAlpha(AppColors.accentGold, 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.accentGold,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        gameState.difficulty.translationKey.tr(),
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 1,
                      height: 12,
                      color: AppColors.withAlpha(AppColors.white, 24),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'game.moves'.tr(
                        namedArgs: {'count': '${gameState.moveCount}'},
                      ),
                      style: const TextStyle(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              isDialogShown = false;
              ref.read(gameProvider.notifier).resetLevel();
            },
          ),
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            icon: const Icon(
              Icons.lightbulb_rounded,
              color: AppColors.accentGold,
              size: 22,
            ),
            onPressed: () {
              final solution = PuzzleSolver.solve(board);
              if (solution != null && solution.isNotEmpty) {
                final nextMove = solution.first;
                _triggerHintAnimation(
                  nextMove.blockId,
                  nextMove.deltaRow,
                  nextMove.deltaCol,
                );
              } else {
                AppDialog(context).info(
                  title: 'game.no_solution'.tr(),
                  message: 'game.no_solution_msg'.tr(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Bottom Instruction Badge Widget
  Widget _buildInstructionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.withAlpha(AppColors.cardSurface, 0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_rounded,
            color: AppColors.textSecondary,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            'game.instruction'.tr(),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Board Graphics
  Widget _buildGameBoard(dynamic board) {
    const double borderWidth = 16.0;

    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final totalWidth = outerConstraints.maxWidth;
        final boardInnerWidth = totalWidth - (borderWidth * 2);
        final cellSize = boardInnerWidth / 6;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.boardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.withAlpha(AppColors.black, 0.7),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Grid Slots
              Positioned(
                left: borderWidth,
                top: borderWidth,
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
                          border: Border.all(color: AppColors.accentSlotBorder),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 2. Non-target blocks
              Positioned(
                left: borderWidth,
                top: borderWidth,
                width: boardInnerWidth,
                height: boardInnerWidth,
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: _hintAnimationController,
                    builder: (context, child) {
                      return Stack(
                        children: (board.blocks as List<Block>)
                            .where((b) => !b.isTarget)
                            .map((block) => _buildBlock(block, ref, cellSize))
                            .toList(),
                      );
                    },
                  ),
                ),
              ),

              // Target Red Block
              Positioned(
                left: borderWidth,
                top: borderWidth,
                width: boardInnerWidth + borderWidth,
                height: boardInnerWidth,
                child: AnimatedBuilder(
                  animation: _hintAnimationController,
                  builder: (context, child) {
                    final targetBlock = (board.blocks as List<Block>)
                        .firstWhere(
                          (b) => b.isTarget,
                          orElse: () => board.blocks.first,
                        );
                    return Stack(
                      children: [
                        if ((board.blocks as List<Block>).any(
                          (b) => b.isTarget,
                        ))
                          _buildBlock(targetBlock, ref, cellSize),
                      ],
                    );
                  },
                ),
              ),

              // 3. Wooden Frames
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: borderWidth,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.frameBorderLight,
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
                height: borderWidth,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.frameBorderLight,
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
                width: borderWidth,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.frameBorderDark,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 0,
                right: 0,
                width: borderWidth,
                height: borderWidth + (2 * cellSize),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.frameBorderDark,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                width: borderWidth,
                height: borderWidth + (3 * cellSize),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.frameBorderDark,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),

              // Exit Arrow
              Positioned(
                right: 1,
                top: borderWidth + (2 * cellSize) + (cellSize / 2) - 10,
                width: borderWidth - 2,
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
    );
  }

  // Block Widget
  Widget _buildBlock(Block block, WidgetRef ref, double cellSize) {
    final isHorizontal = block.orientation == BlockOrientation.horizontal;
    final isHighlighted = (block.id == highlightedBlockId);

    IconData arrowIcon = Icons.arrow_forward_rounded;
    if (hintDeltaRow != null && hintDeltaCol != null) {
      if (hintDeltaRow! < 0) arrowIcon = Icons.arrow_upward_rounded;
      if (hintDeltaRow! > 0) arrowIcon = Icons.arrow_downward_rounded;
      if (hintDeltaCol! < 0) arrowIcon = Icons.arrow_back_rounded;
      if (hintDeltaCol! > 0) arrowIcon = Icons.arrow_forward_rounded;
    }

    double arrowDx = (hintDeltaCol ?? 0) * _hintArrowOffsetAnimation.value;
    double arrowDy = (hintDeltaRow ?? 0) * _hintArrowOffsetAnimation.value;

    return Positioned(
      left: block.col * cellSize,
      top: block.row * cellSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          dragAccumulator = 0.0;
        },
        onPanUpdate: (details) {
          if (ref.read(gameProvider).isCompleted) return;
          final delta = isHorizontal ? details.delta.dx : details.delta.dy;
          dragAccumulator += delta;
        },
        onPanEnd: (_) {
          if (ref.read(gameProvider).isCompleted) return;

          int steps = (dragAccumulator / cellSize).round();

          if (steps != 0) {
            int deltaRow = isHorizontal ? 0 : steps;
            int deltaCol = isHorizontal ? steps : 0;

            ref
                .read(gameProvider.notifier)
                .slideBlock(block, deltaRow, deltaCol);
          }
          dragAccumulator = 0.0;
        },
        onPanCancel: () {
          dragAccumulator = 0.0;
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: isHorizontal ? block.length * cellSize : cellSize,
              height: isHorizontal ? cellSize : block.length * cellSize,
              padding: const EdgeInsets.all(2.5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  gradient: block.isTarget
                      ? AppColors.targetBlockGradient
                      : AppColors.standardBlockGradient,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isHighlighted
                        ? AppColors.withAlpha(
                            AppColors.accentHintGlow,
                            _hintGlowAnimation.value,
                          )
                        : (block.isTarget
                              ? AppColors.accentSoftRed
                              : AppColors.withAlpha(
                                  AppColors.accentLightPeach,
                                  0.9,
                                )),
                    width: isHighlighted ? 3.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isHighlighted
                          ? AppColors.withAlpha(
                              AppColors.accentHintGlow,
                              _hintGlowAnimation.value * 0.8,
                            )
                          : AppColors.withAlpha(Colors.black, 0.4),
                      blurRadius: isHighlighted ? 12 : 4,
                      spreadRadius: isHighlighted ? 2 : 0,
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
                            color: AppColors.withAlpha(Colors.white, 0.15),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: isHorizontal
                            ? (block.length * cellSize * 0.45)
                            : 3,
                        height: isHorizontal
                            ? 3
                            : (block.length * cellSize * 0.45),
                        decoration: BoxDecoration(
                          color: AppColors.withAlpha(Colors.black, 0.18),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isHighlighted && hintDeltaRow != null && hintDeltaCol != null)
              Transform.translate(
                offset: Offset(arrowDx, arrowDy),
                child: Opacity(
                  opacity: _hintGlowAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      arrowIcon,
                      color: AppColors.tileSlotColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
