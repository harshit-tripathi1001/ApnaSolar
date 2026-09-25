import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// AI Roof Analysis Screen (Stitch: 46721b493c494c3891ffe96a391ab0b2)
class AiRoofAnalysisScreen extends StatelessWidget {
  const AiRoofAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'AI Roof Analysis',
      stitchScreenId: '46721b493c494c3891ffe96a391ab0b2',
      description: 'Step 3 of 5: Computer-vision LiDAR scanning simulation with animated laser line, live HUD metrics (slope 0°, 180° South azimuth, 5.4 kWh/m²), and multi-step pipeline verification.',
      icon: Icons.biotech_rounded,
      nextRoute: AppRoutes.roofResult,
      nextLabel: 'View Roof Assessment Results',
    );
  }
}
