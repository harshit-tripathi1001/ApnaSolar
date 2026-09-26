import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Compare Vendors Screen (Stitch: 528ebef0099d40869ebc2347c5513332)
class CompareVendorsScreen extends StatelessWidget {
  const CompareVendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    return BasePlaceholderScreen(
      title: 'Compare Vendor Quotes',
      stitchScreenId: '528ebef0099d40869ebc2347c5513332',
      propertyAddress: session.selectedProperty.formattedAddress,
      description:
          'Side-by-side comparison of local certified vendors across warranty terms, panel brands (Tata Power, Waaree, Adani), inverter models, and price for your ${session.selectedCapacityKw.toStringAsFixed(1)} kW system.',
      icon: Icons.compare_arrows_rounded,
      nextRoute: AppRoutes.vendorProfile,
      nextLabel: 'Inspect Selected Vendor Profile',
    );
  }
}
