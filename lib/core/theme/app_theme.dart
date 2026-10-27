import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get luxuryTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.winePrimary,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.wineAccent,
        secondary: AppColors.goldPrimary,
        surface: AppColors.bgSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: AppColors.goldLight,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: AppColors.goldLight,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        titleMedium: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: AppColors.textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.goldPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.glassWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgElevated.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.glassBorderGold, width: 1.5),
        ),
      ),
    );
  }
}
