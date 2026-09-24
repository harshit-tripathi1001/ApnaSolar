import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Subsidy & Payback Screen (Stitch: e3fc713b984b488f94fa62612b292ec7)
class SubsidyPaybackScreen extends StatelessWidget {
  const SubsidyPaybackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Subsidy & Payback Timeline',
      stitchScreenId: 'e3fc713b984b488f94fa62612b292ec7',
      description: 'PM Surya Ghar DBT claim guide: 30-day Aadhaar credit, 3.2-year system breakeven, and 25-year cumulative gain of ₹9.8 Lakhs.',
      icon: Icons.savings_rounded,
      nextRoute: AppRoutes.nearbyInstallers,
      nextLabel: 'Explore Certified Installers',
    );
  }
}
