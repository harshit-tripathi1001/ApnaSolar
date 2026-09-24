import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Bill Result Screen (Stitch: 526524d1071f4590afe01e5c8d532356)
class BillResultScreen extends StatelessWidget {
  const BillResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Scanned Bill Summary',
      stitchScreenId: '526524d1071f4590afe01e5c8d532356',
      description: 'Extracted details: Consumer Account #3829104, Sanctioned Load 5.0 kW, 420 kWh monthly average, currently paying ₹3,850/mo.',
      icon: Icons.receipt_long_rounded,
      nextRoute: AppRoutes.solarRecommendation,
      nextLabel: 'View Solar Recommendations',
    );
  }
}
