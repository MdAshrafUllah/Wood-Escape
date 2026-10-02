import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:woodescape/core/router/router.dart';
import 'package:woodescape/core/theme/app_theme.dart';
import 'package:woodescape/data/local/storage_service.dart';
import 'package:woodescape/data/local/user_progress_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await StorageService.init();

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
      child: const WoodEscapeApp(),
    ),
  );
}

class WoodEscapeApp extends ConsumerWidget {
  const WoodEscapeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'WoodEscape',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
