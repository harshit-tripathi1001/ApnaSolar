import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// System Activated Screen (Stitch: 64eae02560c14086bb0909c1328c4e4d)
class SystemActivatedScreen extends StatelessWidget {
  const SystemActivatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    final daily = session.solarEstimate.dailyGenerationKwh;
    final subsidy = session.financialBreakdown.centralDbtSubsidy.toInt();

    return BasePlaceholderScreen(
      title: 'Solar System Activated 🎉',
      stitchScreenId: '64eae02560c14086bb0909c1328c4e4d',
      propertyAddress: session.selectedProperty.formattedAddress,
      description: 'Live generation active: Generating ~$daily kWh today.\nBESCOM net meter spinning backward! ₹$subsidy DBT subsidy credited directly to your bank account.',
      icon: Icons.electric_bolt_rounded,
      nextRoute: AppRoutes.home,
      nextLabel: 'Return to Home Dashboard',
    );
  }
}
