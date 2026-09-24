import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typographic system strictly mapped to the Stitch Plus Jakarta Sans tokens.
class AppTypography {
  AppTypography._();

  static const String fontFamilyName = 'Plus Jakarta Sans';

  static TextStyle get displayHero => GoogleFonts.plusJakartaSans(
    fontSize: 48.0,
    fontWeight: FontWeight.w800,
    height: 54.0 / 48.0,
    letterSpacing: -1.44, // -0.03em
    color: AppColors.primary,
  );

  static TextStyle get displayHeroMobile => GoogleFonts.plusJakartaSans(
    fontSize: 36.0,
    fontWeight: FontWeight.w800,
    height: 42.0 / 36.0,
    letterSpacing: -0.9, // -0.025em
    color: AppColors.primary,
  );

  /// Oversized numerical readouts (e.g. ₹3,350 Saved, 1,245 sq.ft)
  static TextStyle get statCounter => GoogleFonts.plusJakartaSans(
    fontSize: 40.0,
    fontWeight: FontWeight.w800,
    height: 44.0 / 40.0,
    letterSpacing: -1.2, // -0.03em
    color: AppColors.primary,
  );

  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 38.0 / 32.0,
    letterSpacing: -0.64,
    color: AppColors.primary,
  );

  static TextStyle get headlineLgMobile => GoogleFonts.plusJakartaSans(
    fontSize: 26.0,
    fontWeight: FontWeight.w700,
    height: 32.0 / 26.0,
    letterSpacing: -0.39,
    color: AppColors.primary,
  );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    height: 28.0 / 22.0,
    color: AppColors.onSurface,
  );

  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 24.0 / 18.0,
    color: AppColors.onSurface,
  );

  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 24.0 / 16.0,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 20.0 / 14.0,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    height: 18.0 / 14.0,
    letterSpacing: 0.28,
    color: AppColors.onSurface,
  );

  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    height: 16.0 / 12.0,
    letterSpacing: 0.36,
    color: AppColors.onSurfaceVariant,
  );

  /// Standard text theme builder for ThemeData
  static TextTheme createTextTheme() {
    return TextTheme(
      displayLarge: displayHero,
      displayMedium: displayHeroMobile,
      displaySmall: statCounter,
      headlineLarge: headlineLg,
      headlineMedium: headlineMd,
      headlineSmall: headlineSm,
      titleLarge: headlineSm,
      titleMedium: labelLg,
      titleSmall: labelMd,
      bodyLarge: bodyLg,
      bodyMedium: bodyMd,
      labelLarge: labelLg,
      labelMedium: labelMd,
    );
  }
}
