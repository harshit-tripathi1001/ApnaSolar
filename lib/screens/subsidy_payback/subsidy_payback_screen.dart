import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Subsidy & Payback Screen (Stitch: e3fc713b984b488f94fa62612b292ec7)
class SubsidyPaybackScreen extends StatelessWidget {
  const SubsidyPaybackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    final subsidy = session.financialBreakdown.centralDbtSubsidy.toInt();
    final payback = session.financialBreakdown.paybackPeriodYears;
    final totalGainLakhs = (session.financialBreakdown.cumulative25YearSavings / 100000).toStringAsFixed(1);

    return BasePlaceholderScreen(
      title: 'Subsidy & Payback Timeline',
      stitchScreenId: 'e3fc713b984b488f94fa62612b292ec7',
      propertyAddress: session.selectedProperty.formattedAddress,
      description: 'PM Surya Ghar DBT claim guide: ₹$subsidy direct credit into your Aadhaar-linked account within 30 days.\nEstimated system breakeven: $payback years, with 25-year cumulative gains of ₹$totalGainLakhs Lakhs.',
      icon: Icons.savings_rounded,
      nextRoute: AppRoutes.nearbyInstallers,
      nextLabel: 'Explore Certified Installers',
      quickNavActions: [
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.quotationAnalysis),
          icon: const Icon(Icons.request_quote_rounded),
          label: const Text('View Quotation Analysis'),
        ),
      ],
    );
  }
}
