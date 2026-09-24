import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Nearby Installers Screen (Stitch: 1e0cc8027aab4bd1b7fa71e114f1c868)
class NearbyInstallersScreen extends StatelessWidget {
  const NearbyInstallersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Nearby Verified Installers',
      stitchScreenId: '1e0cc8027aab4bd1b7fa71e114f1c868',
      description: 'MNRE & BESCOM accredited rooftop solar vendors within 10km of Indiranagar with ratings, local reviews, and fast quote turnaround.',
      icon: Icons.engineering_rounded,
      nextRoute: AppRoutes.compareVendors,
      nextLabel: 'Compare Vendor Quotes',
    );
  }
}
