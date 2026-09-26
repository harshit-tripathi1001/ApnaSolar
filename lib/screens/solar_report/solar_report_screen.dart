import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Solar Report Screen (Stitch: 547ed46925cc4a00bf224ff0c2c0ec81)
class SolarReportScreen extends StatelessWidget {
  const SolarReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    final address = session.selectedProperty.formattedAddress;
    final capacity = session.selectedCapacityKw.toStringAsFixed(1);
    final annualGeneration = session.solarEstimate.annualGenerationKwh.toInt();

    return BasePlaceholderScreen(
      title: 'Complete Solar Audit Report',
      stitchScreenId: '547ed46925cc4a00bf224ff0c2c0ec81',
      propertyAddress: address,
      description: 'Comprehensive 8-page diagnostic dossier for $capacity kW system.\nForecast: ~$annualGeneration kWh/yr. Includes satellite terrace analysis, seasonal irradiance curve, and MNRE/BESCOM grid clearance schematics.',
      icon: Icons.description_rounded,
      nextRoute: AppRoutes.quotationAnalysis,
      nextLabel: 'Proceed to Quotation Analysis',
      quickNavActions: [
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.installationTimeline),
          icon: const Icon(Icons.timeline_rounded),
          label: const Text('Track Installation Progress'),
        ),
      ],
    );
  }
}
