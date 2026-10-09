import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:woodescape/core/theme/app_colors.dart';
import 'package:woodescape/core/utils/app_dialog.dart';
import 'package:woodescape/core/utils/app_links.dart';
import 'package:woodescape/core/utils/app_snackbar.dart';
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
                  Expanded(
                    child: Text(
                      'settings.title'.tr(),
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
                    title: 'settings.sound'.tr(),
                    subtitle: 'settings.sound_sub'.tr(),
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
                  _buildActionTile(
                    title: 'settings.language'.tr(),
                    subtitle: context.locale.languageCode == 'bn'
                        ? 'বাংলা'
                        : 'English',
                    icon: Icons.language_rounded,
                    iconColor: AppColors.accentGold,
                    onTap: () => _showLanguagePicker(context),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleTile(
                    title: 'settings.music'.tr(),
                    subtitle: 'settings.music_sub'.tr(),
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
                    title: 'settings.haptics'.tr(),
                    subtitle: 'settings.haptics_sub'.tr(),
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
                    title: 'settings.vibration'.tr(),
                    subtitle: 'settings.vibration_sub'.tr(),
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
                  const SizedBox(height: 12),
                  _buildActionTile(
                    title: 'settings.rate_us'.tr(),
                    subtitle: 'settings.rate_us_sub'.tr(),
                    icon: Icons.star_outline_rounded,
                    iconColor: AppColors.accentGold,
                    onTap: () => AppLinks.rateApp(),
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    title: 'settings.share_app'.tr(),
                    subtitle: 'settings.share_app_sub'.tr(),
                    icon: Icons.share_rounded,
                    iconColor: AppColors.accentGold,
                    onTap: () => AppLinks.shareApp(),
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    title: 'settings.privacy_policy'.tr(),
                    subtitle: 'settings.privacy_policy_sub'.tr(),
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppColors.accentGold,
                    onTap: () => AppLinks.openPrivacyPolicy(),
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    title: 'settings.terms'.tr(),
                    subtitle: 'settings.terms_sub'.tr(),
                    icon: Icons.description_outlined,
                    iconColor: AppColors.accentGold,
                    onTap: () => AppLinks.openTerms(),
                  ),
                  const SizedBox(height: 24),
                  _buildActionTile(
                    title: 'settings.reset'.tr(),
                    subtitle: 'settings.reset_sub'.tr(),
                    icon: Icons.restore_rounded,
                    iconColor: AppColors.accentRed,
                    onTap: () => _showResetConfirmationDialog(context, ref),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'settings.version_label'.tr(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FutureBuilder<String>(
                    future: AppLinks.getAppVersion(),
                    builder: (context, snapshot) {
                      final version = snapshot.data ?? '...';
                      return Text(
                        'v$version',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
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
          localizedReason: 'settings.auth_reason'.tr(),
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
      AppSnackbar(context).success('settings.reset_done'.tr());
    } on PlatformException catch (_) {
      if (!context.mounted) return;
      AppSnackbar(context).error('settings.auth_failed'.tr());
    }
  }

  void _showResetConfirmationDialog(BuildContext context, WidgetRef ref) {
    AppDialog(context).confirm(
      title: 'settings.reset_confirm_title'.tr(),
      message: 'settings.reset_confirm_msg'.tr(),
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.accentRed,
      confirmColor: AppColors.accentRed,
      confirmText: 'settings.confirm_reset'.tr(),
      cancelText: 'settings.cancel'.tr(),
      onConfirm: () => _handleResetProcess(context, ref),
    );
  }
}

void _showLanguagePicker(BuildContext context) {
  AppDialog(context).custom(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text(
            'English',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          trailing: context.locale.languageCode == 'en'
              ? const Icon(Icons.check, color: AppColors.accentGold)
              : null,
          onTap: () {
            context.setLocale(const Locale('en'));
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text(
            'বাংলা',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          trailing: context.locale.languageCode == 'bn'
              ? const Icon(Icons.check, color: AppColors.accentGold)
              : null,
          onTap: () {
            context.setLocale(const Locale('bn'));
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
