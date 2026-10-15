import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:woodescape/data/local/storage_service.dart';
import 'package:woodescape/data/local/user_progress.dart';
import 'package:woodescape/data/local/user_progress_repository.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Override in main()');
});

final progressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  return UserProgressRepository(ref.watch(storageServiceProvider));
});

class UserProgressNotifier extends Notifier<UserProgress> {
  @override
  UserProgress build() {
    return ref.read(progressRepositoryProvider).load();
  }

  Future<void> _persist() async {
    await ref.read(progressRepositoryProvider).save(state);
  }

  Future<void> setUnlockedLevel(int level) async {
    if (level <= state.unlockedLevel) return;
    state = state.copyWith(unlockedLevel: level);
    await _persist();
  }

  Future<void> setCurrentLevel(int level) async {
    state = state.copyWith(currentLevel: level);
    await _persist();
  }

  Future<void> recordStars(int level, int stars) async {
    final current = state.stars[level] ?? 0;
    if (stars <= current) return;
    final updated = Map<int, int>.from(state.stars)..[level] = stars;
    state = state.copyWith(stars: updated);
    await _persist();
  }

  Future<void> updateSettings(SettingsModel settings) async {
    state = state.copyWith(settings: settings);
    await _persist();
  }

  Future<void> resetAll() async {
    state = const UserProgress();
    await _persist();
  }

  /// DEBUG ONLY — unlock all levels for testing.
  /// Remove before release.
  Future<void> debugUnlockAll({int totalLevels = 30000}) async {
    final updatedStars = Map<int, int>.from(state.stars);
    for (int i = 1; i <= totalLevels; i++) {
      updatedStars.putIfAbsent(i, () => 3);
    }
    state = state.copyWith(
      unlockedLevel: totalLevels,
      currentLevel: 1,
      stars: updatedStars,
    );
    await _persist();
  }
}

final progressProvider = NotifierProvider<UserProgressNotifier, UserProgress>(
  UserProgressNotifier.new,
);
