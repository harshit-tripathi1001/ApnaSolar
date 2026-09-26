import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../services/solar_session_service.dart';
import '../../widgets/app_shell.dart';
import '../common/base_placeholder_screen.dart';

/// Project Dashboard Screen (Stitch: 7f53150992bc4caf908408ffe0795067)
class ProjectDashboardScreen extends StatelessWidget {
  const ProjectDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    final capacity = session.selectedCapacityKw.toStringAsFixed(1);

    return AppShell(
      currentIndex: 3,
      showHeader: false,
      child: BasePlaceholderScreen(
        title: 'Project Tracker',
        stitchScreenId: '7f53150992bc4caf908408ffe0795067',
        propertyAddress: session.selectedProperty.formattedAddress,
        description: 'Live milestone tracking for your $capacity kW rooftop project: Feasibility Approved → Delivery In Transit → Installation Scheduled → Net-Meter Applied.',
        icon: Icons.checklist_rounded,
        nextRoute: AppRoutes.installationTimeline,
        nextLabel: 'View Detailed 5-Stage Timeline',
      ),
    );
  }
}
