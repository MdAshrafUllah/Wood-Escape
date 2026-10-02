import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  String? _lastBgmPath;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;

  Future<void> init() async {
    // শুধু audio context set করো — prefs পড়ো না
    await _sfxPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
      ),
    );
  }

  /// Settings থেকে call হবে — এটাই একমাত্র entry point
  Future<void> applySettings({required bool sound, required bool music}) async {
    _isSoundEnabled = sound;
    _isMusicEnabled = music;

    if (!_isMusicEnabled) {
      await _bgmPlayer.stop();
    } else if (_lastBgmPath != null) {
      await playBackgroundMusic(_lastBgmPath!);
    }
  }

  Future<void> playBackgroundMusic(String assetPath) async {
    _lastBgmPath = assetPath;
    if (!_isMusicEnabled) return;

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);

    if (_bgmPlayer.state == PlayerState.paused) {
      await _bgmPlayer.resume();
    } else if (_bgmPlayer.state != PlayerState.playing) {
      await _bgmPlayer.play(AssetSource(assetPath), volume: 0.5);
    }
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgmPlayer.pause();
  }

  Future<void> stopBackgroundMusic() async {
    await _bgmPlayer.stop();
  }

  Future<void> playSfx(String assetPath) async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop(); // Android lowLatency fix
      await _sfxPlayer.play(
        AssetSource(assetPath),
        mode: PlayerMode.mediaPlayer,
        volume: 1.0,
      );
    } catch (_) {}
  }
}
