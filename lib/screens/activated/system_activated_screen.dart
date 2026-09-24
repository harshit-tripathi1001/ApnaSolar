import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// System Activated Screen (Stitch: 64eae02560c14086bb0909c1328c4e4d)
class SystemActivatedScreen extends StatelessWidget {
  const SystemActivatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Solar System Activated 🎉',
      stitchScreenId: '64eae02560c14086bb0909c1328c4e4d',
      description: 'Live generation active: Generating 23.4 kWh today, grid export 12.1 kWh. BESCOM net meter spinning backward! ₹78,000 DBT subsidy credited.',
      icon: Icons.electric_bolt_rounded,
      nextRoute: AppRoutes.home,
      nextLabel: 'Return to Home Dashboard',
    );
  }
}
