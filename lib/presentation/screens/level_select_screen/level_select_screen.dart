import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:woodescape/core/router/routers.dart';
import 'package:woodescape/core/theme/app_colors.dart';
import 'package:woodescape/core/utils/app_snackbar.dart';
import 'package:woodescape/domain/models/level_data.dart';
import 'package:woodescape/presentation/controllers/game_controller.dart';
import 'package:woodescape/services/haptic_service.dart';

final selectedTabProvider = StateProvider<LevelDifficulty>(
  (ref) => LevelDifficulty.easy,
);

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final selectedDifficulty = ref.watch(selectedTabProvider);

    int startLevel = 1;
    int endLevel = 5000;

    switch (selectedDifficulty) {
      case LevelDifficulty.easy:
        startLevel = 1;
        endLevel = 5000;
        break;
      case LevelDifficulty.medium:
        startLevel = 5001;
        endLevel = 10000;
        break;
      case LevelDifficulty.hard:
        startLevel = 10001;
        endLevel = 15000;
        break;
      case LevelDifficulty.expert:
        startLevel = 15001;
        endLevel = 20000;
        break;
      case LevelDifficulty.legend:
        startLevel = 20001;
        endLevel = 25000;
        break;
      case LevelDifficulty.master:
        startLevel = 25001;
        endLevel = 30000;
        break;
    }

    final levelCount = (endLevel - startLevel) + 1;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SELECT LEVEL',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Progress Card (More polished)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentDarkBrown, AppColors.cardSurface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.withAlpha(AppColors.accentGold, 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withAlpha(60),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
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
                        'CAMPAIGN PROGRESS',
                        style: TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Level ${gameState.unlockedLevel} / 30,000 Unlocked',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentOrangeGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentTrophyOrange.withAlpha(100),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Smooth Scrollable Filter Tabs
            SizedBox(
              height: 55,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: LevelDifficulty.values.length,
                itemBuilder: (context, index) {
                  final diff = LevelDifficulty.values[index];
                  final isSelected = diff == selectedDifficulty;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedTabProvider.notifier).state = diff;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppColors.selectedTabGradient
                              : AppColors.unselectedTabGradient,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentAmber
                                : AppColors.withAlpha(AppColors.white, 0.1),
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.withAlpha(
                                      AppColors.accentAmber,
                                      0.47,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          diff.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.black
                                : AppColors.withAlpha(AppColors.white, 0.7),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            // Grid of Levels with Enhanced Graphics
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: levelCount,
                itemBuilder: (context, index) {
                  final levelNumber = startLevel + index;
                  final isUnlocked = levelNumber <= gameState.unlockedLevel;
                  final isCurrent = levelNumber == gameState.currentLevel;

                  return GestureDetector(
                    onTap: () {
                      if (isUnlocked) {
                        HapticService().mediumImpact();
                        ref
                            .read(gameProvider.notifier)
                            .selectLevel(levelNumber);
                        context.push(AppRoutes.game);
                      } else {
                        HapticService().mediumImpact();
                        AppSnackbar(context).locked(
                          'Level $levelNumber is locked! Complete previous levels first.',
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isCurrent
                            ? AppColors.levelCurrentGradient
                            : isUnlocked
                            ? AppColors.levelUnlockedGradient
                            : AppColors.levelLockedGradient,

                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.accentYellow
                              : isUnlocked
                              ? AppColors.withAlpha(AppColors.accentGold, 0.59)
                              : AppColors.withAlpha(AppColors.white, 0.06),
                          width: isCurrent ? 2.5 : 1.2,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.withAlpha(
                                    AppColors.accentAmber,
                                    0.59,
                                  ),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : isUnlocked
                            ? [
                                BoxShadow(
                                  color: AppColors.withAlpha(
                                    AppColors.black,
                                    0.2,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isUnlocked) ...[
                            Text(
                              '$levelNumber',
                              style: TextStyle(
                                color: isCurrent
                                    ? AppColors.white
                                    : AppColors.accentLightOrange,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (s) => Icon(
                                  Icons.star_rounded,
                                  size: 11,
                                  color: isCurrent
                                      ? AppColors.white
                                      : AppColors.accentGold,
                                ),
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.lock_rounded,
                              color: AppColors.withAlpha(AppColors.white, 0.16),
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$levelNumber',
                              style: TextStyle(
                                color: AppColors.withAlpha(
                                  AppColors.white,
                                  0.16,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
