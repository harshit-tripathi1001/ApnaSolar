import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apnasolar/app/apnasolar_app.dart';
import 'package:apnasolar/app/routes.dart';
import 'package:apnasolar/screens/activated/system_activated_screen.dart';
import 'package:apnasolar/screens/analysis/ai_roof_analysis_screen.dart';
import 'package:apnasolar/screens/cost_breakdown/cost_breakdown_screen.dart';
import 'package:apnasolar/screens/home/home_screen.dart';
import 'package:apnasolar/screens/installers/nearby_installers_screen.dart';
import 'package:apnasolar/screens/location/confirm_location_screen.dart';
import 'package:apnasolar/screens/property/property_details_screen.dart';
import 'package:apnasolar/screens/recommendation/solar_recommendation_screen.dart';
import 'package:apnasolar/screens/roof_drawing/satellite_roof_drawing_screen.dart';
import 'package:apnasolar/screens/roof_result/roof_result_screen.dart';
import 'package:apnasolar/screens/splash/splash_screen.dart';
import 'package:apnasolar/screens/subsidy_payback/subsidy_payback_screen.dart';
import 'package:apnasolar/screens/timeline/installation_timeline_screen.dart';
import 'package:apnasolar/screens/welcome/welcome_screen.dart';
import 'package:apnasolar/services/solar_session_service.dart';

void main() {
  setUp(() {
    SolarSessionState().reset();
  });

  group('ApnaSolar End-To-End Prototype Flow Tests', () {
    testWidgets(
      'Flow Run 1: Complete 10-step forward prototype flow from Splash to System Activation',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // 1. Launch App at Splash / Entry
        await tester.pumpWidget(const ApnaSolarApp());
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('ApnaSolar'), findsOneWidget);

        // Tap to advance through Splash or wait timer
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // 2. Onboarding: WelcomeScreen
        expect(find.byType(WelcomeScreen), findsOneWidget);
        expect(find.text('SURYAGHAR'), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);

        // Tap "Get Started" to advance to Home
        await tester.tap(find.text('Get Started'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // 3. Home Dashboard: HomeScreen
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('Indiranagar, Bengaluru'), findsOneWidget);
        expect(find.text('Check My Solar Potential'), findsOneWidget);

        // Tap "Check My Solar Potential" to enter Location confirmation
        await tester.tap(find.text('Check My Solar Potential'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // 4. Location: ConfirmLocationScreen (Step 1 of 5)
        expect(find.byType(ConfirmLocationScreen), findsOneWidget);
        expect(find.text('Step 1 of 5 · Location'), findsOneWidget);
        expect(find.text('Confirm Location'), findsOneWidget);

        // Tap "Confirm Location" to advance to Property Details
        await tester.tap(find.text('Confirm Location'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // 5. Property: PropertyDetailsScreen (Step 2 of 5)
        expect(find.byType(PropertyDetailsScreen), findsOneWidget);
        expect(find.text('Step 2 of 5 · Property'), findsOneWidget);
        expect(find.text('Building Structure'), findsOneWidget);
        expect(find.text('Rooftop Surface'), findsOneWidget);
        expect(find.text('Proceed to Rooftop Boundary'), findsOneWidget);

        // Tap "Proceed to Rooftop Boundary"
        await tester.tap(find.text('Proceed to Rooftop Boundary'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // 6. Rooftop: SatelliteRoofDrawingScreen (Step 3 of 5)
        expect(find.byType(SatelliteRoofDrawingScreen), findsOneWidget);
        expect(find.text('Step 3 of 5 · Roof Boundary'), findsOneWidget);
        expect(find.text('Use This Roof Boundary'), findsOneWidget);

        // Tap "Use This Roof Boundary" to proceed to AI Scan
        await tester.tap(find.text('Use This Roof Boundary'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // 7. Analysis: AiRoofAnalysisScreen (Step 3 of 5 · AI Analysis)
        expect(find.byType(AiRoofAnalysisScreen), findsOneWidget);
        expect(find.text('· AI Analysis'), findsOneWidget);

        // Tap Skip button to fast-forward LiDAR scanner to completion
        final skipFinder = find.text('Skip');
        expect(skipFinder, findsOneWidget);
        await tester.tap(skipFinder);
        await tester.pump(const Duration(milliseconds: 100));

        // Tap CTA to view results
        final viewResultsFinder = find.text('View Solar Assessment Results');
        expect(viewResultsFinder, findsOneWidget);
        await tester.ensureVisible(viewResultsFinder);
        await tester.tap(viewResultsFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // 8. Results: RoofResultScreen (Step 3 of 5 · Roof Assessment)
        expect(find.byType(RoofResultScreen), findsOneWidget);
        expect(find.text('Roof Assessment'), findsOneWidget);
        expect(find.text('1,120'), findsOneWidget);
        expect(find.text('5.8 kW Peak Capacity'), findsOneWidget);
        expect(find.text('Fits 12 Monocrystalline Panels'), findsOneWidget);
        expect(find.text('See My Solar Plan'), findsOneWidget);

        // Tap "See My Solar Plan" to view detailed recommendations
        await tester.ensureVisible(find.text('See My Solar Plan'));
        await tester.tap(find.text('See My Solar Plan'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));

        // SolarRecommendationScreen
        expect(find.byType(SolarRecommendationScreen), findsOneWidget);
        expect(find.text('5.8 kW System Capacity'), findsOneWidget);
        expect(find.textContaining('78,000'), findsWidgets); // PM Surya Ghar subsidy

        // 9. Insights: Cost Breakdown
        final breakdownFinder = find.text('View Equipment & Cost Details');
        expect(breakdownFinder, findsOneWidget);
        await tester.ensureVisible(breakdownFinder);
        await tester.tap(breakdownFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(CostBreakdownScreen), findsOneWidget);
        expect(find.text('Simple, Honest Pricing'), findsWidgets);

        // Proceed to Subsidy Payback
        final subsidyFinder = find.text('See Subsidy & Payback Period');
        expect(subsidyFinder, findsOneWidget);
        await tester.tap(subsidyFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(SubsidyPaybackScreen), findsOneWidget);
        expect(find.text('Subsidy & Payback Timeline'), findsWidgets);

        // 10. Summary / Next Action: Connect with Installers & Activate
        final installersFinder = find.text('Explore Certified Installers');
        expect(installersFinder, findsOneWidget);
        await tester.tap(installersFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(NearbyInstallersScreen), findsOneWidget);
        expect(find.text('Nearby Verified Installers'), findsWidgets);

        // Proceed to Compare Vendors
        await tester.tap(find.text('Compare Vendor Quotes').first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Proceed to Vendor Profile
        await tester.tap(find.text('Inspect Selected Vendor Profile'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Proceed to Installation Timeline
        await tester.tap(find.text('Accept Quote & View Timeline'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(InstallationTimelineScreen), findsOneWidget);

        // Complete installation and reach System Activated screen
        await tester.tap(find.text('Simulate System Activation'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(SystemActivatedScreen), findsOneWidget);
        expect(find.textContaining('Solar System Activated'), findsWidgets);

        // Return to Home Dashboard
        await tester.tap(find.text('Return to Home Dashboard'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Flow Run 2: Custom property selection and customized data flow through application',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Start directly at Confirm Location
        await tester.pumpWidget(
          MaterialApp(
            initialRoute: AppRoutes.confirmLocation,
            routes: {
              AppRoutes.home: (context) => const HomeScreen(),
              AppRoutes.confirmLocation: (context) =>
                  const ConfirmLocationScreen(),
              AppRoutes.property: (context) => const PropertyDetailsScreen(),
              AppRoutes.satelliteRoofDrawing: (context) =>
                  const SatelliteRoofDrawingScreen(),
              AppRoutes.aiRoofAnalysis: (context) =>
                  const AiRoofAnalysisScreen(),
              AppRoutes.roofResult: (context) => const RoofResultScreen(),
              AppRoutes.solarRecommendation: (context) =>
                  const SolarRecommendationScreen(),
            },
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));

        // Search for another location
        await tester.tap(find.byType(TextField));
        await tester.pump();
        expect(find.textContaining('100 Feet Rd'), findsOneWidget);

        // Select the Indiranagar 100 Feet Rd suggestion
        await tester.tap(find.textContaining('100 Feet Rd'));
        await tester.pump();

        // Confirm Location
        await tester.tap(find.text('Confirm Location'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Property Details Screen
        expect(find.byType(PropertyDetailsScreen), findsOneWidget);

        // Select ₹5200/mo bill preset
        expect(find.text('₹5200'), findsOneWidget);
        await tester.tap(find.text('₹5200'));
        await tester.pump();

        // Select Row House structure
        await tester.tap(find.text('Row House / Duplex'));
        await tester.pump();

        // Save & proceed to rooftop boundary
        await tester.tap(find.text('Proceed to Rooftop Boundary'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(SatelliteRoofDrawingScreen), findsOneWidget);

        // Proceed to AI Analysis
        await tester.tap(find.text('Use This Roof Boundary'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(AiRoofAnalysisScreen), findsOneWidget);

        // Fast-forward AI analysis
        final skipFinder = find.text('Skip');
        expect(skipFinder, findsOneWidget);
        await tester.tap(skipFinder);
        await tester.pump(const Duration(milliseconds: 100));

        // Tap CTA to view results
        final viewResultsFinder = find.text('View Solar Assessment Results');
        expect(viewResultsFinder, findsOneWidget);
        await tester.ensureVisible(viewResultsFinder);
        await tester.tap(viewResultsFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify custom bill is reflected in financial calculations
        expect(find.byType(RoofResultScreen), findsOneWidget);
        expect(SolarSessionState().monthlyBill, 5200.0);
        expect(SolarSessionState().propertyType, 'Row House / Duplex');
      },
    );

    testWidgets(
      'Flow Run 3: Back navigation traverses screens without crashing or losing state',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            initialRoute: AppRoutes.property,
            routes: {
              AppRoutes.confirmLocation: (context) =>
                  const ConfirmLocationScreen(),
              AppRoutes.property: (context) => const PropertyDetailsScreen(),
              AppRoutes.satelliteRoofDrawing: (context) =>
                  const SatelliteRoofDrawingScreen(),
            },
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(PropertyDetailsScreen), findsOneWidget);

        // Proceed forward to Roof Drawing
        await tester.tap(find.text('Proceed to Rooftop Boundary'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(SatelliteRoofDrawingScreen), findsOneWidget);

        // Pop backward from Roof Drawing to Property Details
        final backButtonFinder = find.byIcon(Icons.arrow_back);
        expect(backButtonFinder, findsOneWidget);
        await tester.tap(backButtonFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(PropertyDetailsScreen), findsOneWidget);

        // Pop backward from Property Details to Confirm Location
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(ConfirmLocationScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Flow Run 4: App restart and re-initialization causes no crashes',
      (tester) async {
        // Mount initial instance
        await tester.pumpWidget(const ApnaSolarApp());
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(SplashScreen), findsOneWidget);

        // Simulate app restart / recreation
        SolarSessionState().reset();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 100));

        // Remount fresh instance
        await tester.pumpWidget(const ApnaSolarApp());
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(SplashScreen), findsOneWidget);

        // Advance to Welcome
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(WelcomeScreen), findsOneWidget);
      },
    );
  });
}
