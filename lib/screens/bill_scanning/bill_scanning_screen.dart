import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Bill Scanning Screen (Stitch: bd41e1cad69e47ce9abf91575c9bd443)
class BillScanningScreen extends StatelessWidget {
  const BillScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    return BasePlaceholderScreen(
      title: 'Scan Electricity Bill',
      stitchScreenId: 'bd41e1cad69e47ce9abf91575c9bd443',
      propertyAddress: session.selectedProperty.formattedAddress,
      description:
          'Camera viewport with bounding guide to scan BESCOM/DISCOM bill for ${session.selectedProperty.locality}, extracting Account ID, tariff slab, and sanctioned kW load via OCR.',
      icon: Icons.document_scanner_rounded,
      nextRoute: AppRoutes.billResult,
      nextLabel: 'Process Scanned Bill',
    );
  }
}
