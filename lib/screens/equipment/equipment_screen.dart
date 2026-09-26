import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Equipment Screen (Stitch: 095076ebc18e4bf7990119f18d02f2d7)
class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    final panels = session.solarEstimate.panelCount;
    final capacity = session.selectedCapacityKw.toStringAsFixed(1);

    return BasePlaceholderScreen(
      title: 'Solar Hardware & Equipment',
      stitchScreenId: '095076ebc18e4bf7990119f18d02f2d7',
      propertyAddress: session.selectedProperty.formattedAddress,
      description: 'Hardware for $capacity kW system: $panels TopCon 550W bi-facial panels (25-yr guarantee), 5 kW Smart Hybrid Inverter with WiFi IoT, and Hot-dip galvanized mounting structures.',
      icon: Icons.precision_manufacturing_rounded,
      nextRoute: AppRoutes.costBreakdown,
      nextLabel: 'Proceed to Cost Breakdown',
    );
  }
}
