import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:woodescape/core/router/routers.dart';
import 'package:woodescape/core/theme/app_colors.dart';
import 'package:woodescape/domain/engine/puzzle_solver.dart';
import 'package:woodescape/domain/models/block.dart';
import 'package:woodescape/presentation/controllers/game_controller.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  double dragAccumulator = 0.0;
  bool isLevelCompleting = false;

  // Hint Animation variables
  String? highlightedBlockId;
  late AnimationController _hintAnimationController;
  late Animation<double> _hintGlowAnimation;

  @override
  void initState() {
    super.initState();
    _hintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _hintGlowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
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
          setState(() => highlightedBlockId = null);
        }
      }
    });
  }

  int _hintAnimationCount = 0;

  void _triggerHintAnimation(String blockId) {
    setState(() {
      highlightedBlockId = blockId;
      _hintAnimationCount = 0;
    });
    _hintAnimationController.forward();
  }

  @override
  void dispose() {
    _hintAnimationController.dispose();
    super.dispose();
  }

  void _handleWin() {
    if (isLevelCompleting) return;
    setState(() => isLevelCompleting = true);

    final gameState = ref.read(gameProvider);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'WinDialog',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: AppColors.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(
                color: AppColors.accentTrophyOrange,
                width: 2,
              ),
            ),
            title: Column(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.accentGold,
                  size: 64,
                ),
                const SizedBox(height: 8),
                Text(
                  'LEVEL ${gameState.currentLevel} PASSED!',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Awesome work! Ready for the next puzzle?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  context.pop();
                  ref.read(gameProvider.notifier).loadNextLevel();
                  setState(() => isLevelCompleting = false);
                },
                child: const Text(
                  'NEXT LEVEL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final board = gameState.board;
    final currentLevel = gameState.currentLevel;

    const double borderWidth = 16.0;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.withAlpha(AppColors.cardSurface, 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.withAlpha(
                    AppColors.accentLightBrownGradient,
                    0.4,
                  ),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.grid_view_rounded,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                    onPressed: () => context.goNamed(AppRoutes.level),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.frameBorderLight,
                          AppColors.accentDarkBrownGradient,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.withAlpha(AppColors.textPrimary, 0.5),
                      ),
                    ),
                    child: Text(
                      'LEVEL $currentLevel / 100',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.textPrimary,
                          size: 26,
                        ),
                        onPressed: () =>
                            ref.read(gameProvider.notifier).resetLevel(),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.accentGold,
                          size: 26,
                        ),
                        onPressed: () {
                          final solution = PuzzleSolver.solve(board);
                          if (solution != null && solution.isNotEmpty) {
                            final nextMove = solution.first;
                            _triggerHintAnimation(nextMove.blockId);
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: AppColors.cardSurface,
                                title: const Text(
                                  'No Solution',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                content: const Text(
                                  'No solution found for current layout.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                        color: AppColors.accentOrange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Game Board Component
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
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
                            color: AppColors.withAlpha(Colors.black, 0.7),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          // 1. Grid Background Slots
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
                                      border: Border.all(
                                        color: AppColors.accentSlotBorder,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          // 2. Blocks Layer
                          // Non-target blocks clipped inside boundary
                          Positioned(
                            left: borderWidth,
                            top: borderWidth,
                            width: boardInnerWidth,
                            height: boardInnerWidth,
                            child: ClipRect(
                              child: AnimatedBuilder(
                                animation: _hintGlowAnimation,
                                builder: (context, child) {
                                  return Stack(
                                    children: board.blocks
                                        .where((b) => !b.isTarget)
                                        .map(
                                          (block) =>
                                              _buildBlock(block, ref, cellSize),
                                        )
                                        .toList(),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Target Red Block (Allowed to slide right through exit doorway)
                          Positioned(
                            left: borderWidth,
                            top: borderWidth,
                            width: boardInnerWidth + borderWidth,
                            height: boardInnerWidth,
                            child: AnimatedBuilder(
                              animation: _hintGlowAnimation,
                              builder: (context, child) {
                                final targetBlock = board.blocks.firstWhere(
                                  (b) => b.isTarget,
                                  orElse: () => board.blocks.first,
                                );
                                return Stack(
                                  children: [
                                    if (board.blocks.any((b) => b.isTarget))
                                      _buildBlock(targetBlock, ref, cellSize),
                                  ],
                                );
                              },
                            ),
                          ),

                          // 3. Wooden Frame Overlay (Renders ON TOP of inner grid and blocks)
                          // Top Outer Frame Border
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

                          // Bottom Outer Frame Border
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

                          // Left Outer Frame Border
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

                          // Right Top Frame (Above Exit Cutout)
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

                          // Right Bottom Frame (Below Exit Cutout)
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

                          // Exit Arrow Indicator Doorway
                          Positioned(
                            right: 1,
                            top:
                                borderWidth +
                                (2 * cellSize) +
                                (cellSize / 2) -
                                10,
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
                ),
              ),
            ),

            const Spacer(),

            // Bottom Instructions
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.withAlpha(AppColors.cardSurface, 0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Slide blocks to clear exit path',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Block Builder Widget
  Widget _buildBlock(Block block, WidgetRef ref, double cellSize) {
    final isHorizontal = block.orientation == BlockOrientation.horizontal;
    final isHighlighted = (block.id == highlightedBlockId);

    return Positioned(
      left: block.col * cellSize,
      top: block.row * cellSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => dragAccumulator = 0.0,
        onPanUpdate: (details) {
          if (isLevelCompleting) return;

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

            if (ref.read(gameProvider).board.isWinConditionMet()) {
              _handleWin();
            }
          }
        },
        child: Container(
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
                    width: isHorizontal ? (block.length * cellSize * 0.45) : 3,
                    height: isHorizontal ? 3 : (block.length * cellSize * 0.45),
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
      ),
    );
  }
}
