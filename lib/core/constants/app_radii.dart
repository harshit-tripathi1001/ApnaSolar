import 'package:flutter/widgets.dart';

/// Corner radius tokens matching Stitch Organic Soft-Surface Modernism.
class AppRadii {
  AppRadii._();

  static const double smValue = 8.0;
  static const double mdValue = 16.0;
  static const double lgValue = 24.0;
  static const double xlValue = 32.0;
  static const double fullValue = 9999.0;

  static const Radius rSm = Radius.circular(smValue);
  static const Radius rMd = Radius.circular(mdValue);
  static const Radius rLg = Radius.circular(lgValue);
  static const Radius rXl = Radius.circular(xlValue);
  static const Radius rFull = Radius.circular(fullValue);

  static const BorderRadius sm = BorderRadius.all(rSm);
  static const BorderRadius md = BorderRadius.all(rMd);
  static const BorderRadius lg = BorderRadius.all(rLg);
  static const BorderRadius xl = BorderRadius.all(rXl);
  static const BorderRadius full = BorderRadius.all(rFull);

  /// Top rounded sheets
  static const BorderRadius topLg = BorderRadius.vertical(top: rLg);
  static const BorderRadius topXl = BorderRadius.vertical(top: rXl);

  /// Bottom rounded hero section
  static const BorderRadius bottomXl = BorderRadius.vertical(bottom: rXl);
}
