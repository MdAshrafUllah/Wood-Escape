import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:woodescape/core/router/routers.dart';
import 'package:woodescape/core/theme/app_colors.dart';
import 'package:woodescape/presentation/controllers/game_controller.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Select Level',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Progress Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentDarkBrown, AppColors.cardSurface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.withAlpha(AppColors.frameBorderLight, 0.4),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR PROGRESS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gameState.unlockedLevel} / 100 Levels Unlocked',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.accentTrophyOrange,
                    child: Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Grid of 100 Levels
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: 100,
                itemBuilder: (context, index) {
                  final levelNumber = index + 1;
                  final isUnlocked = levelNumber <= gameState.unlockedLevel;
                  final isCurrent = levelNumber == gameState.currentLevel;

                  return GestureDetector(
                    onTap: () {
                      if (isUnlocked) {
                        ref
                            .read(gameProvider.notifier)
                            .selectLevel(levelNumber);
                        context.goNamed(AppRoutes.game);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🔒 Level $levelNumber is locked! Complete Level ${levelNumber - 1} first.',
                            ),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isCurrent
                            ? AppColors.accentOrangeGradient
                            : isUnlocked
                            ? const LinearGradient(
                                colors: [
                                  AppColors.frameBorderLight,
                                  AppColors.accentDeepBrown,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [
                                  AppColors.accentLockedLevelGradientStart,
                                  AppColors.accentLockedLevelGradientEnd,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent
                              ? Colors.amber.shade300
                              : isUnlocked
                              ? AppColors.accentUnlockedBorder
                              : AppColors.accentLockedLevel,
                          width: isCurrent ? 2.5 : 1,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.withAlpha(Colors.amber, 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [
                                const BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isUnlocked) ...[
                            Text(
                              '$levelNumber',
                              style: TextStyle(
                                color: isCurrent
                                    ? Colors.white
                                    : AppColors.accentBeige,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (s) => Icon(
                                  Icons.star,
                                  size: 10,
                                  color: isCurrent
                                      ? Colors.yellowAccent
                                      : AppColors.accentGold,
                                ),
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              Icons.lock_rounded,
                              color: AppColors.accentMutedBrown,
                              size: 20,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$levelNumber',
                              style: const TextStyle(
                                color: AppColors.accentMutedBrown,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
