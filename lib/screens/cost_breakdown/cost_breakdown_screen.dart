import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Cost Breakdown Screen (Stitch: 4ead5303038c462988e392b0f92a109d)
class CostBreakdownScreen extends StatelessWidget {
  const CostBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    final net = session.financialBreakdown.netPayableCost.toInt();
    final subsidy = session.financialBreakdown.centralDbtSubsidy.toInt();
    final gross = session.financialBreakdown.grossTurnkeyCost.toInt();
    final capacity = session.selectedCapacityKw.toStringAsFixed(1);

    return BasePlaceholderScreen(
      title: 'Simple, Honest Pricing',
      stitchScreenId: '4ead5303038c462988e392b0f92a109d',
      propertyAddress: session.selectedProperty.formattedAddress,
      description: 'System size: $capacity kW | Gross turnkey: ₹$gross | Central DBT Subsidy: ₹$subsidy | Net payable: ₹$net.\nItemized breakdown: panels (48%), inverter (22%), structure (15%), meter & approvals (15%).',
      icon: Icons.currency_rupee_rounded,
      nextRoute: AppRoutes.subsidyPayback,
      nextLabel: 'See Subsidy & Payback Period',
      quickNavActions: [
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.quotationAnalysis),
          icon: const Icon(Icons.request_quote_rounded),
          label: const Text('View Official Turnkey Quotation'),
        ),
        const SizedBox(height: 8),
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
