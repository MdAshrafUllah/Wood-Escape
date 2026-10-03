import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _hapticsEnabled = true;
  bool _vibrationEnabled = true;

  bool get hapticsEnabled => _hapticsEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  void applySettings({required bool haptics, required bool vibration}) {
    _hapticsEnabled = haptics;
    _vibrationEnabled = vibration;
  }

  Future<void> lightImpact() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> mediumImpact() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavyImpact() async {
    if (!_hapticsEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> winVibration() async {
    if (!_vibrationEnabled) return;

    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    Vibration.vibrate(
      pattern: [0, 400, 150, 400, 150, 400],
      intensities: [0, 255, 0, 255, 0, 255],
    );
  }
}
