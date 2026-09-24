import 'package:flutter/material.dart';

/// ApnaSolar design system colors faithfully translated from Google Stitch.
class AppColors {
  AppColors._();

  // Primary - Deep Forest Green
  static const Color primary = Color(0xFF003323);
  static const Color primaryContainer = Color(0xFF164A38);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF85B9A1);
  static const Color primaryFixed = Color(0xFFB9EED5);
  static const Color primaryFixedDim = Color(0xFF9DD2BA);
  static const Color onPrimaryFixed = Color(0xFF002116);
  static const Color onPrimaryFixedVariant = Color(0xFF1C4F3D);

  // Secondary - Fresh Leaf Green (Clean Energy Flow & Positive Deltas)
  static const Color secondary = Color(0xFF0B6D33);
  static const Color secondaryFresh = Color(0xFF62B875);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF9BF3AA);
  static const Color secondaryContainerLight = Color(0xFFDDF0D8);
  static const Color onSecondaryContainer = Color(0xFF147137);
  static const Color secondaryFixed = Color(0xFF9EF6AD);
  static const Color secondaryFixedDim = Color(0xFF82D993);
  static const Color onSecondaryFixed = Color(0xFF00210A);
  static const Color onSecondaryFixedVariant = Color(0xFF005224);

  // Tertiary - Solar Golden Yellow (Irradiance, Highlights, Sun)
  static const Color tertiary = Color(0xFF382A00);
  static const Color tertiarySolar = Color(0xFFF5C542);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF533F00);
  static const Color onTertiaryContainer = Color(0xFFD5A825);
  static const Color tertiaryFixed = Color(0xFFFFDF95);
  static const Color tertiaryFixedDim = Color(0xFFF0C03E);
  static const Color onTertiaryFixed = Color(0xFF251A00);
  static const Color onTertiaryFixedVariant = Color(0xFF594400);

  // Surfaces & Backgrounds - Warm Cotton Paper & Cream
  static const Color background = Color(0xFFFCF9EF);
  static const Color surface = Color(0xFFFCF9EF);
  static const Color surfaceBright = Color(0xFFFCF9EF);
  static const Color surfaceDim = Color(0xFFDDDAD0);
  static const Color surfaceContainerLowest = Color(
    0xFFFFFFFF,
  ); // Elevated pure white cards
  static const Color surfaceContainerLow = Color(
    0xFFF7F4EA,
  ); // Warm cream canvas
  static const Color surfaceContainer = Color(
    0xFFF1EEE4,
  ); // Inputs and interactive slots
  static const Color surfaceContainerHigh = Color(0xFFEBE8DE);
  static const Color surfaceContainerHighest = Color(0xFFE5E2D9);
  static const Color surfaceTint = Color(0xFF366854);

  // Text & Outlines
  static const Color onSurface = Color(0xFF1C1C16); // Soft high-contrast ink
  static const Color onSurfaceVariant = Color(
    0xFF404944,
  ); // Subtle explanatory text
  static const Color onBackground = Color(0xFF1C1C16);
  static const Color outline = Color(0xFF707974);
  static const Color outlineVariant = Color(0xFFC0C9C2);

  // Semantic
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Ambient Shadows
  static const Color shadowTinted = Color(
    0x14164A38,
  ); // Soft green-tinted shadow
  static const Color shadowElevated = Color(0x24164A38);
}
