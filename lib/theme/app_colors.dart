import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand
  static const Color primary = Color(0xFF3B5EC9);
  static const Color primaryLight = Color(0xFF6B8AE6);
  static const Color primaryDark = Color(0xFF2A4494);

  // Accent
  static const Color accent = Color(0xFF7C5CFC);
  static const Color accentLight = Color(0xFFB8A4FF);

  // Pastels for backgrounds
  static const Color warmIvory = Color(0xFFFAF7F2);
  static const Color mistBlue = Color(0xFFEEF2FA);
  static const Color blush = Color(0xFFFFF0F0);
  static const Color sage = Color(0xFFEFF5F0);
  static const Color lavender = Color(0xFFF3EEFF);
  static const Color peach = Color(0xFFFFF5EE);

  // Semantic
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFE8F8ED);
  static const Color warning = Color(0xFFFFB830);
  static const Color warningLight = Color(0xFFFFF6E0);
  static const Color error = Color(0xFFFF4757);
  static const Color errorLight = Color(0xFFFFE8EA);
  static const Color info = Color(0xFF5AC8FA);
  static const Color infoLight = Color(0xFFE6F6FE);

  // Neutrals
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FC);
  static const Color cardShadow = Color(0x0D000000);

  // Glass
  static const Color glassWhite = Color(0x99FFFFFF);
  static const Color glassBorder = Color(0x3DFFFFFF);
  static const Color glassOverlay = Color(0x14FFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B5EC9), Color(0xFF7C5CFC)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B5EC9), Color(0xFF5A78DE), Color(0xFF7C5CFC)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A76), Color(0xFFFECF71)],
  );

  static const LinearGradient coolGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5AC8FA), Color(0xFF7C5CFC)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34C759), Color(0xFF5AC8FA)],
  );

  static const LinearGradient meshBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F9FC), Color(0xFFEEF2FA), Color(0xFFF8F9FC)],
  );
}
