import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:woodescape/core/theme/app_colors.dart';
import 'package:woodescape/data/local/user_progress_notifier.dart';
import 'package:woodescape/presentation/controllers/game_controller.dart';
import 'package:woodescape/services/audio_service.dart';
import 'package:woodescape/services/haptic_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(progressProvider, (previous, next) {
      HapticService().applySettings(
        haptics: next.settings.haptics,
        vibration: next.settings.vibration,
      );
    });
    final progress = ref.watch(progressProvider);
    final settings = progress.settings;
    final notifier = ref.read(progressProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.withAlpha(AppColors.cardSurface, 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.withAlpha(
                    AppColors.accentLightBrownGradient,
                    0.4,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.withAlpha(AppColors.black, 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'SETTINGS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildToggleTile(
                    title: 'Sound Effects',
                    subtitle: 'In-game move & completion sounds',
                    icon: Icons.volume_up_rounded,
                    value: settings.sound,
                    onChanged: (val) async {
                      HapticService().mediumImpact();
                      final updated = settings.copyWith(sound: val);
                      await notifier.updateSettings(updated);
                      await AudioService().applySettings(
                        sound: updated.sound,
                        music: updated.music,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildToggleTile(
                    title: 'Background Music',
                    subtitle: 'Relaxing background wooden audio',
                    icon: Icons.music_note_rounded,
                    value: settings.music,
                    onChanged: (val) async {
                      HapticService().mediumImpact();
                      final updated = settings.copyWith(music: val);
                      await notifier.updateSettings(updated);
                      await AudioService().applySettings(
                        sound: updated.sound,
                        music: updated.music,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildToggleTile(
                    title: 'Haptic Feedback',
                    subtitle: 'Micro-taps when sliding blocks',
                    icon: Icons.touch_app_rounded,
                    value: settings.haptics,
                    onChanged: (val) async {
                      final updated = settings.copyWith(haptics: val);
                      await notifier.updateSettings(updated);

                      HapticService().applySettings(
                        haptics: updated.haptics,
                        vibration: updated.vibration,
                      );

                      if (val) {
                        HapticService().lightImpact();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildToggleTile(
                    title: 'Vibration',
                    subtitle: 'Vibrate on level completion',
                    icon: Icons.vibration_rounded,
                    value: settings.vibration,
                    onChanged: (val) async {
                      final updated = settings.copyWith(vibration: val);
                      await notifier.updateSettings(updated);

                      HapticService().applySettings(
                        haptics: updated.haptics,
                        vibration: updated.vibration,
                      );

                      if (val) {
                        HapticService().winVibration();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildActionTile(
                    title: 'Reset Progress',
                    subtitle: 'Clear all unlocked levels and stars',
                    icon: Icons.restore_rounded,
                    iconColor: AppColors.accentRed,
                    onTap: () => _showResetConfirmationDialog(context, ref),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'WoodEscape v1.0.0',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.withAlpha(AppColors.accentLightBrown, 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentVeryDarkBrown,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accentGold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accentGold,
            activeTrackColor: AppColors.accentDarkBrown,
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.accentVeryDarkBrown,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.withAlpha(iconColor, 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.withAlpha(iconColor, 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResetProcess(BuildContext context, WidgetRef ref) async {
    final auth = LocalAuthentication();

    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final canAuthenticate =
          canCheckBiometrics || await auth.isDeviceSupported();

      bool authenticated = false;

      if (canAuthenticate) {
        authenticated = await auth.authenticate(
          localizedReason:
              'Please verify device PIN/Password to reset game progress',
          biometricOnly: false,
        );
      } else {
        authenticated = true;
      }

      if (!authenticated) return;

      await ref.read(progressProvider.notifier).resetAll();
      ref.read(gameProvider.notifier).selectLevel(1);

      if (!context.mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All progress and settings have been reset.'),
        ),
      );
    } on PlatformException catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed or cancelled.')),
      );
    }
  }

  void _showResetConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accentRed, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.accentRed,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'RESET PROGRESS?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will permanently reset all game progress. '
                  'Authentication required if device screen lock is set.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.frameBorderLight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => dialogContext.pop(),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          dialogContext.pop();
                          _handleResetProcess(context, ref);
                        },
                        child: const Text(
                          'RESET',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
