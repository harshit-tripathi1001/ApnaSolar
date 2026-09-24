import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Rooftop Photo Screen (Stitch: d10b09a44dc24a2893b0af79cac292a0)
class RooftopPhotoScreen extends StatelessWidget {
  const RooftopPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Rooftop Photo Upload',
      stitchScreenId: 'd10b09a44dc24a2893b0af79cac292a0',
      description: 'Take or upload 2 to 4 photos of your terrace showing parapet, water tank, and sun line for enhanced computer vision accuracy.',
      icon: Icons.camera_alt_rounded,
      nextRoute: AppRoutes.aiRoofAnalysis,
      nextLabel: 'Analyze Uploaded Photos',
    );
  }
}
