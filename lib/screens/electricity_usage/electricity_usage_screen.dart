import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Electricity Usage Screen (Stitch: 172eca06eabe436188a3eed1ec271bbf)
class ElectricityUsageScreen extends StatelessWidget {
  const ElectricityUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Electricity Usage',
      stitchScreenId: '172eca06eabe436188a3eed1ec271bbf',
      description: 'Input your monthly electricity bill spend or kWh consumption (e.g. 420 units/mo for BESCOM) to tailor system sizing.',
      icon: Icons.electric_meter_rounded,
      nextRoute: AppRoutes.solarRecommendation,
      nextLabel: 'Calculate Tailored Recommendation',
      quickNavActions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.billScanning),
          icon: const Icon(Icons.document_scanner),
          label: const Text('Scan Electricity Bill with Camera'),
        ),
      ],
    );
  }
}
