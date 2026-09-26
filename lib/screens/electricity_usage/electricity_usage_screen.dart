import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Electricity Usage Screen (Stitch: 172eca06eabe436188a3eed1ec271bbf)
class ElectricityUsageScreen extends StatelessWidget {
  const ElectricityUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    return BasePlaceholderScreen(
      title: 'Electricity Usage',
      stitchScreenId: '172eca06eabe436188a3eed1ec271bbf',
      propertyAddress: session.selectedProperty.formattedAddress,
      description:
          'Input your monthly electricity spend (currently ₹${session.monthlyBill.toInt()}/mo) or kWh consumption to tailor system sizing.',
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
