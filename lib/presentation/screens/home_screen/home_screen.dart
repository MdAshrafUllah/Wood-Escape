import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:woodescape/core/constants/app_audio.dart';
import 'package:woodescape/core/router/routers.dart';
import 'package:woodescape/core/theme/app_colors.dart';
import 'package:woodescape/core/utils/localized_number.dart';
import 'package:woodescape/presentation/controllers/game_controller.dart';
import 'package:woodescape/services/audio_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    AudioService().playBackgroundMusic(AppAudio.bgMusic);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.withAlpha(AppColors.accentTrophyOrange, 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.withAlpha(AppColors.accentLightRed, 0.08),
              ),
            ),
          ),

          SafeArea(
            child: OrientationBuilder(
              builder: (context, orientation) {
                final isLandscape = orientation == Orientation.landscape;

                if (isLandscape) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 16.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _buildLogo(size: 80, iconSize: 40),
                                        const SizedBox(height: 12),
                                        _buildTitleText(
                                          subtitleSize: 16,
                                          mainTitleSize: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildSubtitleBanner(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _buildMenuButtons(context, gameState),
                                        const SizedBox(height: 16),
                                        _buildProgressFooter(gameState),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 20.0,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(height: 10),
                                Column(
                                  children: [
                                    _buildLogo(size: 110, iconSize: 56),
                                    const SizedBox(height: 24),
                                    _buildTitleText(
                                      subtitleSize: 22,
                                      mainTitleSize: 42,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSubtitleBanner(),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  children: [
                                    _buildMenuButtons(context, gameState),
                                    const SizedBox(height: 24),
                                    _buildProgressFooter(gameState),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo({required double size, required double iconSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.standardBlockGradient,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: AppColors.accentLightPeach.withValues(alpha: 0.8),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.grid_view_rounded,
          size: iconSize,
          color: AppColors.splashIconColor,
        ),
      ),
    );
  }

  Widget _buildTitleText({
    required double subtitleSize,
    required double mainTitleSize,
  }) {
    return Column(
      children: [
        Text(
          'WOODEN'.toUpperCase(),
          style: TextStyle(
            fontSize: subtitleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 8,
            color: AppColors.textSecondary,
            shadows: [
              Shadow(
                color: AppColors.withAlpha(AppColors.black, 0.8),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        Text(
          'ESCAPE'.toUpperCase(),
          style: TextStyle(
            fontSize: mainTitleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            color: AppColors.textPrimary,
            shadows: [
              Shadow(
                color: AppColors.withAlpha(AppColors.black, 0.9),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitleBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.withAlpha(AppColors.accentLightBrownGradient, 0.3),
        ),
      ),
      child: Text(
        'home.subtitle'.tr(),
        style: TextStyle(
          color: AppColors.withAlpha(AppColors.accentLightBrown, 0.9),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context, GameState gameState) {
    return Column(
      children: [
        _buildWoodenButton(
          context: context,
          label: 'home.play'.tr(
            namedArgs: {
              'level': localizedNumber(context, gameState.currentLevel),
            },
          ),
          icon: Icons.play_arrow_rounded,
          isPrimary: true,
          onTap: () => context.push(AppRoutes.game),
        ),
        const SizedBox(height: 10),
        _buildWoodenButton(
          context: context,
          label: 'home.select_level'.tr(),
          icon: Icons.grid_view_rounded,
          isPrimary: false,
          onTap: () => context.push(AppRoutes.level),
        ),
        const SizedBox(height: 10),
        _buildWoodenButton(
          context: context,
          label: 'home.settings'.tr(),
          icon: Icons.settings_rounded,
          isPrimary: false,
          onTap: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildProgressFooter(GameState gameState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 18),
        const SizedBox(width: 6),
        Text(
          'home.unlocked'.tr(
            namedArgs: {
              'count': localizedNumber(context, gameState.unlockedLevel),
              'total': localizedNumber(context, 30000),
            },
          ),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWoodenButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? AppColors.accentOrangeGradient
            : const LinearGradient(
                colors: [
                  AppColors.accentButtonGradientStart,
                  AppColors.accentButtonGradientEnd,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        border: Border.all(
          color: isPrimary
              ? AppColors.accentLightOrange
              : AppColors.withAlpha(AppColors.accentLightBrownGradient, 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? AppColors.withAlpha(AppColors.accentRed, 0.4)
                : AppColors.withAlpha(AppColors.black, 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? AppColors.white : AppColors.textPrimary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isPrimary
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
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
