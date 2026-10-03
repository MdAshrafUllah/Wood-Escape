import 'package:flutter/material.dart';
import 'package:woodescape/core/theme/app_colors.dart';

class AppDialog {
  final BuildContext context;

  const AppDialog(this.context);

  //  INFO
  Future<void> info({
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData icon = Icons.info_outline_rounded,
    Color? iconColor,
  }) {
    return _showSingleAction(
      title: title,
      message: message,
      buttonText: buttonText,
      icon: icon,
      iconColor: iconColor ?? AppColors.accentGold,
      buttonColor: AppColors.accentOrange,
      borderColor: AppColors.frameBorderLight,
    );
  }

  //  SUCCESS
  Future<void> success({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return _showSingleAction(
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.accentGold,
      buttonColor: AppColors.accentOrange,
      borderColor: AppColors.accentGold,
    );
  }

  //  ERROR
  Future<void> error({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return _showSingleAction(
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.accentSoftRed,
      buttonColor: AppColors.accentRed,
      borderColor: AppColors.accentRed,
    );
  }

  //  WARNING
  Future<void> warning({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return _showSingleAction(
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.accentAmber,
      buttonColor: AppColors.accentOrange,
      borderColor: AppColors.accentAmber,
    );
  }

  //  CONFIRM
  Future<void> confirm({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'CONFIRM',
    String cancelText = 'CANCEL',
    IconData icon = Icons.help_outline_rounded,
    Color? iconColor,
    Color? confirmColor,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.withAlpha(AppColors.black, 0.7),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.withAlpha(
                  iconColor ?? AppColors.accentGold,
                  0.5,
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.withAlpha(AppColors.black, 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor ?? AppColors.accentGold, size: 48),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(
                            color: AppColors.frameBorderLight,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          cancelText,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              confirmColor ?? AppColors.accentOrange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          onConfirm();
                        },
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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

  //  CUSTOM
  Future<T?> custom<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.withAlpha(AppColors.black, 0.7),
      builder: (_) => Dialog(
        backgroundColor: AppColors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.withAlpha(AppColors.accentGold, 0.5),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  //  Internal Single action dialog
  Future<void> _showSingleAction({
    required String title,
    required String message,
    required String buttonText,
    required IconData icon,
    required Color iconColor,
    required Color buttonColor,
    required Color borderColor,
  }) {
    return showDialog(
      context: context,
      barrierColor: AppColors.withAlpha(AppColors.black, 0.7),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.withAlpha(borderColor, 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.withAlpha(AppColors.black, 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 48),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
