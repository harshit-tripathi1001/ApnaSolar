import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../common/base_placeholder_screen.dart';

/// Quotation & Analysis Screen (Stitch: 938220953c87442f89dd5f589734e6c6)
class QuotationAnalysisScreen extends StatelessWidget {
  const QuotationAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Quotation & Financial Analysis',
      stitchScreenId: '938220953c87442f89dd5f589734e6c6',
      description: 'Comprehensive quotation download with generation forecast, payback curves, bill offsets, and official DISCOM interconnection schematics.',
      icon: Icons.request_quote_rounded,
      nextRoute: AppRoutes.solarReport,
      nextLabel: 'View Detailed Solar Report',
    );
  }
}
