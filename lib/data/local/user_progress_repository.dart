import 'dart:convert';

import 'package:woodescape/data/local/storage_service.dart';
import 'package:woodescape/data/local/user_progress.dart';

class UserProgressRepository {
  final StorageService _storage;

  UserProgressRepository(this._storage);

  UserProgress load() {
    final raw = _storage.readProgress();
    if (raw == null || raw.isEmpty) return const UserProgress();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _migrate(UserProgress.fromJson(json));
    } catch (_) {
      return const UserProgress();
    }
  }

  Future<void> save(UserProgress progress) async {
    await _storage.writeProgress(jsonEncode(progress.toJson()));
  }

  UserProgress _migrate(UserProgress p) {
    return p;
  }
}
