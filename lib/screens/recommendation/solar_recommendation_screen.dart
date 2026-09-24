import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Solar Recommendation Screen (Stitch: 904784247fc147f8a1a540e7e943ab7d)
class SolarRecommendationScreen extends StatelessWidget {
  const SolarRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Solar Recommendation',
      stitchScreenId: '904784247fc147f8a1a540e7e943ab7d',
      description: 'Step 4 of 5: System sizing customizer (3.5 - 7.5 kW), before/after bill reduction (₹3,850 → ₹500), ₹40,200/yr savings, and PM Surya Ghar eligibility.',
      icon: Icons.auto_awesome_rounded,
      nextRoute: AppRoutes.costBreakdown,
      nextLabel: 'View Cost & Subsidy Details',
      quickNavActions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.equipment),
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('View Hardware & Equipment Specs'),
        ),
      ],
    );
  }
}
