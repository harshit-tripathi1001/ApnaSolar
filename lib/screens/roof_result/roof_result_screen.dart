import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Roof Result Screen (Stitch: 3dbdce19abb641e586edd16c24173636)
class RoofResultScreen extends StatelessWidget {
  const RoofResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Roof Assessment Result',
      stitchScreenId: '3dbdce19abb641e586edd16c24173636',
      description: '1,120 sq ft usable terrace area (78% shadow-free), 5.8 kW peak capacity, 12 monocrystalline panels, ₹4,250/mo bill reduction, and 182 trees CO2 offset.',
      icon: Icons.check_circle_rounded,
      nextRoute: AppRoutes.solarRecommendation,
      nextLabel: 'See Recommended Solar System',
      quickNavActions: [
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.panelLayout3d),
          icon: const Icon(Icons.view_in_ar_rounded),
          label: const Text('View 3D Panel Layout'),
        ),
      ],
    );
  }
}
