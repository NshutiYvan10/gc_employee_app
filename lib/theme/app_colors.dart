import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary brand: Yale Blue ────────────────────────────────────────────────
  static const Color primary      = Color(0xFF264567); // Yale Blue
  static const Color primaryLight = Color(0xFF3A6491);
  static const Color primaryDark  = Color(0xFF1A3149);

  // ── Accent: GC Gold ─────────────────────────────────────────────────────────
  static const Color accent      = Color(0xFFC9A227); // GC Gold
  static const Color accentLight = Color(0xFFF5E48B);
  static const Color gold        = Color(0xFFC9A227); // alias
  static const Color goldLight   = Color(0xFFF5E48B); // alias
  static const Color goldMuted   = Color(0xFFE8C84B);

  // ── Secondary blue ──────────────────────────────────────────────────────────
  static const Color secondary      = Color(0xFF4A7FB5);
  static const Color secondaryLight = Color(0xFFD6E6F5);

  // ── Pastels (blue-gray toned) ────────────────────────────────────────────────
  static const Color warmIvory = Color(0xFFFAF8F2);
  static const Color mistBlue  = Color(0xFFEBF0FA);
  static const Color blush     = Color(0xFFFFF0F0);
  static const Color sage      = Color(0xFFEEF5F1);
  static const Color lavender  = Color(0xFFEBF0FA);
  static const Color peach     = Color(0xFFFFF5EE);

  // ── Semantic ─────────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF2EB86E);
  static const Color successLight = Color(0xFFE5F7EE);
  static const Color warning      = Color(0xFFE8A020);
  static const Color warningLight = Color(0xFFFFF5E0);
  static const Color error        = Color(0xFFE84545);
  static const Color errorLight   = Color(0xFFFFECEC);
  static const Color info         = Color(0xFF4A9FD4);
  static const Color infoLight    = Color(0xFFE5F3FC);

  // ── Neutrals (blue-gray cast) ────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF12213A);
  static const Color textSecondary = Color(0xFF546480);
  static const Color textTertiary  = Color(0xFF9DAABB);
  static const Color border        = Color(0xFFDDE4EE);
  static const Color divider       = Color(0xFFEEF2F8);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color background    = Color(0xFFF4F7FB);
  static const Color cardShadow    = Color(0x0D0A1525);

  // ── Glass ────────────────────────────────────────────────────────────────────
  static const Color glassWhite   = Color(0xB3FFFFFF); // 70 %
  static const Color glassBorder  = Color(0x40FFFFFF); // 25 %
  static const Color glassOverlay = Color(0x14FFFFFF); //  8 %

  // ── Gradients ────────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF264567), Color(0xFF3A6491)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF12243C), Color(0xFF264567), Color(0xFF2D5580)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9A227), Color(0xFFE8C84B)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A76), Color(0xFFFECF71)],
  );

  static const LinearGradient coolGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A9FD4), Color(0xFF264567)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2EB86E), Color(0xFF4A9FD4)],
  );

  static const LinearGradient meshBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4F7FB), Color(0xFFEBF0FA), Color(0xFFF4F7FB)],
  );
}
