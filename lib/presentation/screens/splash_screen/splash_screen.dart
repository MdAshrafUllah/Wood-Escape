import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:woodescape/core/theme/app_colors.dart';

import '../../../core/router/routers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          // Background Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.9,
                colors: [AppColors.cardSurface, AppColors.primaryBackground],
              ),
            ),
          ),

          // Main Animated Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 3D Wooden Icon Frame
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: AppColors.standardBlockGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.accentLightPeach.withValues(
                            alpha: 0.8,
                          ),
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
                      child: const Center(
                        child: Icon(
                          Icons.grid_view_rounded,
                          size: 56,
                          color: AppColors.splashIconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Game Title
                    const Text(
                      'WoodEscape',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: AppColors.splashTitleColor,
                        shadows: [
                          Shadow(
                            color: AppColors.black,
                            offset: Offset(2, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'UNBLOCK THE WAY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.0,
                        color: AppColors.woodGradientStart.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Progress Indicator at Bottom
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.woodGradientStart.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
