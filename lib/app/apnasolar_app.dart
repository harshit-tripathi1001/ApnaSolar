import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../screens/activated/system_activated_screen.dart';
import '../screens/analysis/ai_roof_analysis_screen.dart';
import '../screens/bill_result/bill_result_screen.dart';
import '../screens/bill_scanning/bill_scanning_screen.dart';
import '../screens/compare_vendors/compare_vendors_screen.dart';
import '../screens/cost_breakdown/cost_breakdown_screen.dart';
import '../screens/electricity_usage/electricity_usage_screen.dart';
import '../screens/equipment/equipment_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/how_it_works/how_it_works_screen.dart';
import '../screens/installers/nearby_installers_screen.dart';
import '../screens/location/confirm_location_screen.dart';
import '../screens/panel_layout/panel_layout_3d_screen.dart';
import '../screens/property/property_details_screen.dart';
import '../screens/project_dashboard/project_dashboard_screen.dart';
import '../screens/quotation/quotation_analysis_screen.dart';
import '../screens/recommendation/solar_recommendation_screen.dart';
import '../screens/roof_drawing/satellite_roof_drawing_screen.dart';
import '../screens/roof_photo/rooftop_photo_screen.dart';
import '../screens/roof_result/roof_result_screen.dart';
import '../screens/solar_report/solar_report_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/subsidy_payback/subsidy_payback_screen.dart';
import '../screens/timeline/installation_timeline_screen.dart';
import '../screens/vendor_profile/vendor_profile_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import 'routes.dart';

/// ApnaSolar Main Application Configuration
class ApnaSolarApp extends StatelessWidget {
  const ApnaSolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ApnaSolar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.howItWorks: (context) => const HowItWorksScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.confirmLocation: (context) => const ConfirmLocationScreen(),
        AppRoutes.property: (context) => const PropertyDetailsScreen(),
        AppRoutes.satelliteRoofDrawing: (context) =>
            const SatelliteRoofDrawingScreen(),
        AppRoutes.rooftopPhoto: (context) => const RooftopPhotoScreen(),
        AppRoutes.aiRoofAnalysis: (context) => const AiRoofAnalysisScreen(),
        AppRoutes.roofResult: (context) => const RoofResultScreen(),
        AppRoutes.panelLayout3d: (context) => const PanelLayout3dScreen(),
        AppRoutes.electricityUsage: (context) => const ElectricityUsageScreen(),
        AppRoutes.billScanning: (context) => const BillScanningScreen(),
        AppRoutes.billResult: (context) => const BillResultScreen(),
        AppRoutes.solarRecommendation: (context) =>
            const SolarRecommendationScreen(),
        AppRoutes.equipment: (context) => const EquipmentScreen(),
        AppRoutes.costBreakdown: (context) => const CostBreakdownScreen(),
        AppRoutes.subsidyPayback: (context) => const SubsidyPaybackScreen(),
        AppRoutes.quotationAnalysis: (context) =>
            const QuotationAnalysisScreen(),
        AppRoutes.nearbyInstallers: (context) => const NearbyInstallersScreen(),
        AppRoutes.compareVendors: (context) => const CompareVendorsScreen(),
        AppRoutes.vendorProfile: (context) => const VendorProfileScreen(),
        AppRoutes.projectDashboard: (context) => const ProjectDashboardScreen(),
        AppRoutes.solarReport: (context) => const SolarReportScreen(),
        AppRoutes.installationTimeline: (context) =>
            const InstallationTimelineScreen(),
        AppRoutes.systemActivated: (context) => const SystemActivatedScreen(),
      },
    );
  }
}
