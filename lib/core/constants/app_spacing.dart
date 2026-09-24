import 'package:flutter/widgets.dart';

/// Spacing constants adhering to the Stitch 8pt modular rhythm scale.
class AppSpacing {
  AppSpacing._();

  /// 4.0 - Extra small spacing
  static const double spaceXs = 4.0;

  /// 8.0 - Small spacing
  static const double spaceSm = 8.0;

  /// 12.0 - Compact margin / medium-small
  static const double spaceCompact = 12.0;

  /// 16.0 - Standard gutters & modular padding
  static const double spaceMd = 16.0;

  /// 20.0 - Screen horizontal padding / standard margin
  static const double margin = 20.0;

  /// 24.0 - Section breaks & large cards
  static const double spaceLg = 24.0;

  /// 36.0 - Major vertical block gaps
  static const double spaceXl = 36.0;

  /// 48.0 - Hero block padding
  static const double spaceXxl = 48.0;

  // Insets helpers
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: margin,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(spaceMd);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(spaceLg);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 14.0,
  );
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 6.0,
  );
}
