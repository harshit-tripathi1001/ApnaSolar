import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Satellite Roof Drawing Screen (Stitch: c2f5849a2fce475e852355ebbd623291)
class SatelliteRoofDrawingScreen extends StatelessWidget {
  const SatelliteRoofDrawingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Roof Boundary',
      stitchScreenId: 'c2f5849a2fce475e852355ebbd623291',
      description: 'Step 2 of 5: Drag pins to calibrate terrace parapet boundary. Auto-detects usable area (1,245 sq ft) and excludes overhead water tanks (-115 sq ft).',
      icon: Icons.edit_road_rounded,
      nextRoute: AppRoutes.aiRoofAnalysis,
      nextLabel: 'Run AI Roof Analysis',
      quickNavActions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.rooftopPhoto),
          icon: const Icon(Icons.photo_camera),
          label: const Text('Switch to Camera Photo instead'),
        ),
      ],
    );
  }
}
