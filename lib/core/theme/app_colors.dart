import 'package:flutter/material.dart';

/// Disha Makeover Brand Colors
/// Inspired by the official Disha Makeover Logo:
/// - Rich Burgundy / Deep Wine / Ruby Magenta
/// - Metallic Champagne Gold & Warm Amber
/// - Frosted Glass & Luxury Soft Glows
class AppColors {
  // Brand Wine & Ruby Palette (From Logo Lettering & Silhouette)
  static const Color wineDark = Color(0xFF4A081E);
  static const Color winePrimary = Color(0xFF800C36);
  static const Color wineAccent = Color(0xFFA6134B);
  static const Color wineLight = Color(0xFFD6336C);
  static const Color wineSoft = Color(0xFFFBE8F0);

  // Brand Gold Palette (From Logo Golden Ring, Leaves & Accents)
  static const Color goldDark = Color(0xFF9E7818);
  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldGlow = Color(0xFFFFE082);
  static const Color goldAmber = Color(0xFFE5A93C);

  // Backgrounds & Canvas
  static const Color bgDark = Color(0xFF15050D);
  static const Color bgSurface = Color(0xFF220B16);
  static const Color bgElevated = Color(0xFF2E1020);
  static const Color bgLight = Color(0xFFFFF9F9);

  // Glass Window Effects
  static const Color glassWhite = Color(0x1FFFFFFF);
  static const Color glassWhiteStrong = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x3DFFFFFF);
  static const Color glassBorderGold = Color(0x59D4AF37);
  static const Color glassWine = Color(0x40800C36);
  static const Color glassDark = Color(0x7015050D);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE2CCD6);
  static const Color textMuted = Color(0xFFA68D9A);
  static const Color textGold = Color(0xFFF5E4B3);

  // Status Colors
  static const Color statusPaid = Color(0xFF10B981);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusDue = Color(0xFFEF4444);
  static const Color whatsappGreen = Color(0xFF25D366);

  // Luxury Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFDF7D), Color(0xFFD4AF37), Color(0xFFAA8014)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient wineGradient = LinearGradient(
    colors: [Color(0xFFA6134B), Color(0xFF800C36), Color(0xFF4A081E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryCardGradient = LinearGradient(
    colors: [Color(0x35FFFFFF), Color(0x10FFFFFF), Color(0x18D4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient appBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF2B0716),
      Color(0xFF15050D),
      Color(0xFF1C0712),
      Color(0xFF350A1C),
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
