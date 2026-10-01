import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:woodescape/core/router/routers.dart';
import 'package:woodescape/core/theme/app_colors.dart';
import 'package:woodescape/presentation/controllers/game_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          // Background Glow & Pattern Accent
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 10),

                  // Game Logo & Title Header
                  Column(
                    children: [
                      // Decorative Icon Badge
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.frameBorderLight,
                              AppColors.accentDarkBrownGradient,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: AppColors.withAlpha(
                              AppColors.textPrimary,
                              0.6,
                            ),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.withAlpha(Colors.black, 0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.grid_4x4_rounded,
                          size: 48,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title Text
                      Text(
                        'WOODEN',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                          color: AppColors.textSecondary,
                          shadows: [
                            Shadow(
                              color: AppColors.withAlpha(Colors.black, 0.8),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'PUZZLE',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          color: AppColors.textPrimary,
                          shadows: [
                            Shadow(
                              color: AppColors.withAlpha(Colors.black, 0.9),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.withAlpha(
                              AppColors.accentLightBrownGradient,
                              0.3,
                            ),
                          ),
                        ),
                        child: Text(
                          'Unblock The Red Block',
                          style: TextStyle(
                            color: AppColors.withAlpha(
                              AppColors.accentLightBrown,
                              0.9,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Menu Action Buttons
                  Column(
                    children: [
                      // Play Resume Button (Primary)
                      _buildWoodenButton(
                        context: context,
                        label: 'PLAY (LEVEL ${gameState.currentLevel})',
                        icon: Icons.play_arrow_rounded,
                        isPrimary: true,
                        onTap: () => context.goNamed(AppRoutes.game),
                      ),
                      const SizedBox(height: 16),

                      // Select Level Button
                      _buildWoodenButton(
                        context: context,
                        label: 'SELECT LEVEL',
                        icon: Icons.grid_view_rounded,
                        isPrimary: false,
                        onTap: () => context.pushNamed(AppRoutes.level),
                      ),
                      const SizedBox(height: 16),

                      // Settings Button
                      _buildWoodenButton(
                        context: context,
                        label: 'SETTINGS',
                        icon: Icons.settings_rounded,
                        isPrimary: false,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings coming soon!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Footer Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.accentGold,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Unlocked: ${gameState.unlockedLevel} / 100',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom Wooden 3D Action Button Builder
  Widget _buildWoodenButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
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
                : AppColors.withAlpha(Colors.black, 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
                  color: isPrimary ? Colors.white : AppColors.textPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
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
