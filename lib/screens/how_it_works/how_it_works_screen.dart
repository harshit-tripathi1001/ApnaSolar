import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// How It Works Screen (Stitch: 17832eea8c204ea5b3a0f81b3d06bb52)
class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'How ApnaSolar Works',
      stitchScreenId: '17832eea8c204ea5b3a0f81b3d06bb52',
      description: '3-step onboarding walkthrough explaining satellite solar detection, PM Surya Ghar central subsidy entitlement, and verified installer bidding.',
      icon: Icons.lightbulb_outline_rounded,
      nextRoute: AppRoutes.confirmLocation,
      nextLabel: 'Start Roof Assessment',
    );
  }
}
