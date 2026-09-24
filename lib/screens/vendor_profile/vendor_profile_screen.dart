import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Vendor Profile Screen (Stitch: 34f6fda9939c473996162577e81322f3)
class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Solar EPC Vendor Profile',
      stitchScreenId: '34f6fda9939c473996162577e81322f3',
      description: 'Company profile, MNRE license #MNRE-2024-KA-092, 450+ installed residential capacity, customer testimonials, and installer crew certifications.',
      icon: Icons.badge_rounded,
      nextRoute: AppRoutes.projectDashboard,
      nextLabel: 'Accept Quote & Launch Project',
    );
  }
}
