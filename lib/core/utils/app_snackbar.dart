import 'package:flutter/material.dart';
import 'package:woodescape/core/theme/app_colors.dart';

class AppSnackbar {
  final BuildContext context;

  const AppSnackbar(this.context);

  static const Duration _defaultDuration = Duration(seconds: 2);

  static const SnackBarBehavior _behavior = SnackBarBehavior.floating;

  static const EdgeInsets _margin = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  static final ShapeBorder _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );

  void info(String message, {Duration? duration}) {
    _show(
      message: message,
      backgroundColor: AppColors.cardSurface,
      textColor: AppColors.textPrimary,
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.accentGold,
      duration: duration,
    );
  }

  void success(String message, {Duration? duration}) {
    _show(
      message: message,
      backgroundColor: AppColors.accentDarkBrown,
      textColor: AppColors.textPrimary,
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.accentGold,
      duration: duration,
    );
  }

  void error(String message, {Duration? duration}) {
    _show(
      message: message,
      backgroundColor: AppColors.accentDarkRed,
      textColor: AppColors.white,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.accentSoftRed,
      duration: duration,
    );
  }

  void warning(String message, {Duration? duration}) {
    _show(
      message: message,
      backgroundColor: AppColors.accentDeepBrown,
      textColor: AppColors.textPrimary,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.accentAmber,
      duration: duration,
    );
  }

  void locked(String message, {Duration? duration}) {
    _show(
      message: message,
      backgroundColor: AppColors.accentDeepBrown,
      textColor: AppColors.textPrimary,
      icon: Icons.lock_rounded,
      iconColor: AppColors.accentGold,
      duration: duration,
    );
  }

  static void showInfo(BuildContext context, String message) =>
      AppSnackbar(context).info(message);

  static void showSuccess(BuildContext context, String message) =>
      AppSnackbar(context).success(message);

  static void showError(BuildContext context, String message) =>
      AppSnackbar(context).error(message);

  static void showWarning(BuildContext context, String message) =>
      AppSnackbar(context).warning(message);

  static void showLocked(BuildContext context, String message) =>
      AppSnackbar(context).locked(message);

  void _show({
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration ?? _defaultDuration,
        behavior: _behavior,
        margin: _behavior == SnackBarBehavior.floating ? _margin : null,
        shape: _shape,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.withAlpha(iconColor, 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.withAlpha(AppColors.black, 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
