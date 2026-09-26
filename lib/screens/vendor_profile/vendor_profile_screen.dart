import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Vendor Profile Screen (Stitch: 34f6fda9939c473996162577e81322f3)
class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    return BasePlaceholderScreen(
      title: 'Solar EPC Vendor Profile',
      stitchScreenId: '34f6fda9939c473996162577e81322f3',
      propertyAddress: session.selectedProperty.formattedAddress,
      description:
          'Apex Solar Engineering (MNRE Lic #MNRE-2024-KA-092) - 450+ installations across ${session.selectedProperty.city}. Certified installer crew for ${session.selectedCapacityKw.toStringAsFixed(1)} kW turnkey system.',
      icon: Icons.badge_rounded,
      nextRoute: AppRoutes.installationTimeline,
      nextLabel: 'Accept Quote & View Timeline',
    );
  }
}
