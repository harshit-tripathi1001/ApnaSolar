import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Compare Vendors Screen (Stitch: 528ebef0099d40869ebc2347c5513332)
class CompareVendorsScreen extends StatelessWidget {
  const CompareVendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Compare Vendor Quotes',
      stitchScreenId: '528ebef0099d40869ebc2347c5513332',
      description: 'Side-by-side comparison of local certified vendors across warranty terms, panel brands (Tata Power, Waaree, Adani), inverter models, and price.',
      icon: Icons.compare_arrows_rounded,
      nextRoute: AppRoutes.vendorProfile,
      nextLabel: 'Inspect Selected Vendor Profile',
    );
  }
}
