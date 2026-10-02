import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;

  const SettingsState({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.vibrationEnabled,
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const String _soundKey = 'sound_enabled';
  static const String _musicKey = 'music_enabled';
  static const String _vibrationKey = 'vibration_enabled';

  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState(
      soundEnabled: true,
      musicEnabled: true,
      vibrationEnabled: true,
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      soundEnabled: prefs.getBool(_soundKey) ?? true,
      musicEnabled: prefs.getBool(_musicKey) ?? true,
      vibrationEnabled: prefs.getBool(_vibrationKey) ?? true,
    );
  }

  Future<void> toggleSound(bool value) async {
    state = state.copyWith(soundEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  Future<void> toggleMusic(bool value) async {
    state = state.copyWith(musicEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicKey, value);
  }

  Future<void> toggleVibration(bool value) async {
    state = state.copyWith(vibrationEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
