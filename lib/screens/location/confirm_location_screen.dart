import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Confirm Location Screen (Stitch: 29594313ffc24d539db94b05f63c3ae2)
class ConfirmLocationScreen extends StatelessWidget {
  const ConfirmLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Confirm Location',
      stitchScreenId: '29594313ffc24d539db94b05f63c3ae2',
      description: 'Step 1 of 5: Interactive solar map canvas with address search, GPS locator, 5.2 peak sun-hours indicator, and property pin confirmation.',
      icon: Icons.location_on_rounded,
      nextRoute: AppRoutes.satelliteRoofDrawing,
      nextLabel: 'Confirm Location & Draw Roof',
    );
  }
}
