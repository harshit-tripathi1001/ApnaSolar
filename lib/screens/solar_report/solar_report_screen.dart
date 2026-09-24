import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Solar Report Screen (Stitch: 547ed46925cc4a00bf224ff0c2c0ec81)
class SolarReportScreen extends StatelessWidget {
  const SolarReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Complete Solar Audit Report',
      stitchScreenId: '547ed46925cc4a00bf224ff0c2c0ec81',
      description: 'Comprehensive 8-page diagnostic summary: Satellite terrace analysis, solar irradiance heat map, seasonal generation curve, and PM Surya Ghar clearance dossier.',
      icon: Icons.description_rounded,
      nextRoute: AppRoutes.installationTimeline,
      nextLabel: 'Track Installation Progress',
    );
  }
}
