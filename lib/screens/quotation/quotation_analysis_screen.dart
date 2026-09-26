import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Quotation & Analysis Screen (Stitch: 938220953c87442f89dd5f589734e6c6)
class QuotationAnalysisScreen extends StatelessWidget {
  const QuotationAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    final address = session.selectedProperty.formattedAddress;
    final capacity = session.selectedCapacityKw.toStringAsFixed(1);
    final gross = session.financialBreakdown.grossTurnkeyCost.toInt();
    final subsidy = session.financialBreakdown.centralDbtSubsidy.toInt();
    final net = session.financialBreakdown.netPayableCost.toInt();

    return BasePlaceholderScreen(
      title: 'Quotation & Financial Analysis',
      stitchScreenId: '938220953c87442f89dd5f589734e6c6',
      propertyAddress: address,
      description: 'Official Turnkey Quotation for $capacity kW System.\nTotal Cost: ₹$gross | DBT Subsidy: ₹$subsidy | Net Customer Payable: ₹$net.\nIncludes DISCOM bidirectional meter swap, 25-yr warranties, and structure mounting.',
      icon: Icons.request_quote_rounded,
      nextRoute: AppRoutes.nearbyInstallers,
      nextLabel: 'Connect with Verified Installers',
      quickNavActions: [
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.compareVendors),
          icon: const Icon(Icons.compare_arrows_rounded),
          label: const Text('Compare Verified Vendor Quotes'),
        ),
      ],
    );
  }
}
