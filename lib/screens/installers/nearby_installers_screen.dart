import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Nearby Installers Screen (Stitch: 1e0cc8027aab4bd1b7fa71e114f1c868)
class NearbyInstallersScreen extends StatelessWidget {
  const NearbyInstallersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    final locality = session.selectedProperty.locality;

    return BasePlaceholderScreen(
      title: 'Nearby Verified Installers',
      stitchScreenId: '1e0cc8027aab4bd1b7fa71e114f1c868',
      propertyAddress: session.selectedProperty.formattedAddress,
      description: 'MNRE & DISCOM accredited rooftop solar EPC contractors within 10km of $locality with ratings, verified customer installations, and fast quote turnaround.',
      icon: Icons.engineering_rounded,
      nextRoute: AppRoutes.compareVendors,
      nextLabel: 'Compare Vendor Quotes',
    );
  }
}
