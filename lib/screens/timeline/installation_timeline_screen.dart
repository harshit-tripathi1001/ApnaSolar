import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../common/base_placeholder_screen.dart';

/// Installation Timeline Screen (Stitch: e7eb6bd5ee9c4719b60f6fe51f835abe)
class InstallationTimelineScreen extends StatelessWidget {
  const InstallationTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();

    return BasePlaceholderScreen(
      title: 'Installation Countdown',
      stitchScreenId: 'e7eb6bd5ee9c4719b60f6fe51f835abe',
      propertyAddress: session.selectedProperty.formattedAddress,
      description: '14-day timeline for ${session.selectedProperty.locality} installation:\nSite survey (Done) → BESCOM sanction (Done) → Panel dispatch (Today) → Rooftop mounting (Day 8) → Bi-directional Net meter swap (Day 14).',
      icon: Icons.timeline_rounded,
      nextRoute: AppRoutes.systemActivated,
      nextLabel: 'Simulate System Activation',
    );
  }
}
