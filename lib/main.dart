import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:woodescape/core/router/router.dart';
import 'package:woodescape/core/theme/app_theme.dart';
import 'package:woodescape/data/local/storage_service.dart';
import 'package:woodescape/data/local/user_progress_notifier.dart';
import 'package:woodescape/data/local/user_progress_repository.dart';
import 'package:woodescape/services/audio_service.dart';
import 'package:woodescape/services/haptic_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  final storage = await StorageService.init();
  final repo = UserProgressRepository(storage);
  final progress = repo.load();

  await AudioService().init();
  await AudioService().applySettings(
    sound: progress.settings.sound,
    music: progress.settings.music,
  );

  HapticService().applySettings(
    haptics: progress.settings.haptics,
    vibration: progress.settings.vibration,
  );

  final debugContainer = ProviderContainer(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
  );
  await debugContainer.read(progressProvider.notifier).debugUnlockAll();
  debugContainer.dispose();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('bn')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(progress.settings.languageCode),
      saveLocale: true,
      child: ProviderScope(
        overrides: [storageServiceProvider.overrideWithValue(storage)],
        child: const WoodEscapeApp(),
      ),
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
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
