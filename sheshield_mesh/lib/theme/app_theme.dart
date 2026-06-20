import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Neo-Brutalism Colors
  static const Color canvas = Color(0xFFE8EBE6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF0E0F0C); // Borders, Headings
  
  static const Color textMuted = Color(0xFF454745);
  static const Color textLight = Color(0xFF868685);
  
  static const Color redLight = Color(0xFFFBE4E4);
  static const Color redMedium = Color(0xFFF4BABA);
  static const Color redMain = Color(0xFFD03238);
  static const Color redDark = Color(0xFFA72027);

  static const Color greenLight = Color(0xFFE2F6D5);
  static const Color greenMedium = Color(0xFFC5EDAB);
  static const Color greenMain = Color(0xFF9FE870);
  static const Color greenText = Color(0xFF2EAD4B);
  static const Color greenDark = Color(0xFF163300);
  static const Color greenDarker = Color(0xFF054D28);

  // Legacy variables to keep old screens compiling
  static const Color primary = Color(0xFF6C63FF);
  static const Color primarySoft = Color(0xFF9F99FF);
  static const Color primaryLight = Color(0xFFEBEAFF);
  static const Color primaryDark = Color(0xFF4A41DB);
  static const Color body = Color(0xFF454745);
  static const Color muted = Color(0xFF868685);
  static const Color mutedSoft = Color(0xFFE5E7EB);
  static const Color hairline = Color(0xFFE5E7EB);
  static const Color hairlineSoft = Color(0xFFF3F4F6);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF9FAFB);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ink,
        primary: AppColors.ink,
        surface: AppColors.white,
        background: AppColors.canvas,
        error: AppColors.redMain,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.textMuted,
        displayColor: AppColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
