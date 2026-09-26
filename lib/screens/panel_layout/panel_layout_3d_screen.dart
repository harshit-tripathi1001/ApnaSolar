import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// 3D Panel Layout Screen (Stitch: 623c46c677a14cb8859bc0c0284b480c)
class PanelLayout3dScreen extends StatelessWidget {
  const PanelLayout3dScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    return BasePlaceholderScreen(
      title: '3D Solar Panel Layout',
      stitchScreenId: '623c46c677a14cb8859bc0c0284b480c',
      propertyAddress: session.selectedProperty.formattedAddress,
      description:
          'Interactive 3D model showing realistic solar module placement for ${session.selectedCapacityKw.toStringAsFixed(1)} kW (${session.solarEstimate.panelCount} modules), azimuth orientation, tilt angles, and terrace walkway clearances.',
      icon: Icons.view_in_ar_rounded,
      nextRoute: AppRoutes.solarRecommendation,
      nextLabel: 'Proceed to Solar Recommendation',
    );
  }
}
