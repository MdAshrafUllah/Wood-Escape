import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color primaryBackground = Color(0xFF1E0E07);
  static const Color boardBackground = Color(0xFF1B0D07);
  static const Color tileSlotColor = Color(0xFF26130B);
  static const Color cardSurface = Color(0xFF2C160B);

  // Borders
  static const Color frameBorderLight = Color(0xFF8D5B36);
  static const Color frameBorderDark = Color(0xFF7A4D2C);

  // Text & Icons
  static const Color textPrimary = Color(0xFFF3C892);
  static const Color textSecondary = Color(0xFFB38257);
  static const Color accentOrange = Color(0xFFFF8C00);
  static const Color accentRed = Color(0xFFD84315);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color accentLightOrange = Color(0xFFFFD180);
  static const Color accentLightRed = Color(0xFFFF5252);
  static const Color accentDarkRed = Color(0xFFB71C1C);
  static const Color accentLightBrown = Color(0xFFD3A173);
  static const Color accentBeige = Color(0xFFF3D4B3);
  static const Color accentDarkBrown = Color(0xFF3D2115);
  static const Color accentDeepBrown = Color(0xFF5A351D);
  static const Color accentVeryDarkBrown = Color(0xFF381F14);
  static const Color accentMutedBrown = Color(0xFF6E5144);
  static const Color accentSlotBorder = Color(0xFF170A05);
  static const Color accentLightPeach = Color(0xFFF5C999);
  static const Color splashTitleColor = Color(0xFFF5EBE1);
  static const Color accentSoftRed = Color(0xFFFF8A80);
  static const Color accentAmber = Color(0xFFFFC107);
  static const Color accentYellow = Color(0xFFFFFF00);
  static const Color accentTrophyOrange = Color(0xFFE28B38);
  static const Color accentLockedLevel = Color(0xFF3B2820);
  static const Color accentUnlockedBorder = Color(0xFFBA804C);
  static const Color accentLockedLevelGradientStart = Color(0xFF2A1C16);
  static const Color accentLockedLevelGradientEnd = Color(0xFF1F1410);
  static const Color accentDarkBrownGradient = Color(0xFF3D2115);
  static const Color accentLightBrownGradient = Color(0xFF8C532B);
  static const Color accentButtonGradientStart = Color(0xFF5A351D);
  static const Color accentButtonGradientEnd = Color(0xFF381F14);
  static const Color accentHintGlow = Color(0xFFFFEA00);
  static const Color accentStandardBlockStart = Color(0xFFD38E53);
  static const Color accentStandardBlockEnd = Color(0xFF8B5129);

  // Specific UI colors
  static const Color woodGradientStart = Color(0xFFD38E53);
  static const Color woodGradientEnd = Color(0xFF8B5129);
  static const Color splashIconColor = Color(0xFFFFF3E0);
  // System Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient accentOrangeGradient = LinearGradient(
    colors: [accentOrange, accentRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient targetBlockGradient = LinearGradient(
    colors: [accentLightRed, accentDarkRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient standardBlockGradient = LinearGradient(
    colors: [accentStandardBlockStart, accentStandardBlockEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Helper for alpha (Flutter 3.27+ syntax)
  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }
}
