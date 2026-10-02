import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:woodescape/presentation/screens/game_screen/game_screen.dart';
import 'package:woodescape/presentation/screens/home_screen/home_screen.dart';
import 'package:woodescape/presentation/screens/level_select_screen/level_select_screen.dart';
import 'package:woodescape/presentation/screens/settings_screen/settings_screen.dart';
import 'package:woodescape/presentation/screens/splash_screen/splash_screen.dart';

import 'routers.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.root,
  routes: [
    GoRoute(
      name: PageRoutes.root,
      path: AppRoutes.root,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: PageRoutes.home,
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: PageRoutes.level,
      path: AppRoutes.level,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LevelSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      name: PageRoutes.game,
      path: AppRoutes.game,
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      name: PageRoutes.settings,
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
);
