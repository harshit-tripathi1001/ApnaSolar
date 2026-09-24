import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Cost Breakdown Screen (Stitch: 4ead5303038c462988e392b0f92a109d)
class CostBreakdownScreen extends StatelessWidget {
  const CostBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Simple, Honest Pricing',
      stitchScreenId: '4ead5303038c462988e392b0f92a109d',
      description: 'Net payable ₹2,62,000 (after ₹78,000 direct govt subsidy). Itemized breakdown: panels (48%), inverter (22%), structure (15%), meter & approvals (15%).',
      icon: Icons.currency_rupee_rounded,
      nextRoute: AppRoutes.subsidyPayback,
      nextLabel: 'See Subsidy & Payback Period',
      quickNavActions: [
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.nearbyInstallers),
          icon: const Icon(Icons.people_outline),
          label: const Text('Connect with Verified Local Installers'),
        ),
      ],
    );
  }
}
