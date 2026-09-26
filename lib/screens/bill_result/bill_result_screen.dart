import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Bill Result Screen (Stitch: 526524d1071f4590afe01e5c8d532356)
class BillResultScreen extends StatelessWidget {
  const BillResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    return BasePlaceholderScreen(
      title: 'Scanned Bill Summary',
      stitchScreenId: '526524d1071f4590afe01e5c8d532356',
      propertyAddress: session.selectedProperty.formattedAddress,
      description:
          'Extracted details: Consumer Account #BESCOM-3829104, Sanctioned Load ${session.sanctionedLoadKw.toStringAsFixed(1)} kW, currently paying ₹${session.monthlyBill.toInt()}/mo.',
      icon: Icons.receipt_long_rounded,
      nextRoute: AppRoutes.solarRecommendation,
      nextLabel: 'View Solar Recommendations',
    );
  }
}
