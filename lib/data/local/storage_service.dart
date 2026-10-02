import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _progressKey = 'user_progress_v1';
  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  String? readProgress() => _prefs.getString(_progressKey);

  Future<void> writeProgress(String json) =>
      _prefs.setString(_progressKey, json);

  Future<void> clear() => _prefs.remove(_progressKey);
}
