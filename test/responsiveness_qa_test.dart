import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apnasolar/screens/activated/system_activated_screen.dart';
import 'package:apnasolar/screens/analysis/ai_roof_analysis_screen.dart';
import 'package:apnasolar/screens/compare_vendors/compare_vendors_screen.dart';
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
import 'package:apnasolar/screens/vendor_profile/vendor_profile_screen.dart';
import 'package:apnasolar/screens/welcome/welcome_screen.dart';
import 'package:apnasolar/services/solar_session_service.dart';

void main() {
  setUp(() {
    SolarSessionState().reset();
  });

  const viewports = <String, Size>{
    'Small Phone (360x640)': Size(360, 640),
    'Normal Phone (390x844)': Size(390, 844),
    'Large Phone (428x926)': Size(428, 926),
    'Tablet Width (768x1024)': Size(768, 1024),
  };

  group('Visual Responsiveness & Layout QA Across Viewports', () {
    for (final entry in viewports.entries) {
      final name = entry.key;
      final size = entry.value;

      testWidgets('Renders all screens cleanly without overflow on $name', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final screens = <String, Widget>{
          'Splash': const SplashScreen(),
          'Welcome': const WelcomeScreen(),
          'Home': const HomeScreen(),
          'Location': const ConfirmLocationScreen(),
          'Property': const PropertyDetailsScreen(),
          'RoofDrawing': const SatelliteRoofDrawingScreen(),
          'AiAnalysis': const AiRoofAnalysisScreen(),
          'RoofResult': const RoofResultScreen(),
          'SolarRecommendation': const SolarRecommendationScreen(),
          'CostBreakdown': const CostBreakdownScreen(),
          'SubsidyPayback': const SubsidyPaybackScreen(),
          'NearbyInstallers': const NearbyInstallersScreen(),
          'CompareVendors': const CompareVendorsScreen(),
          'VendorProfile': const VendorProfileScreen(),
          'Timeline': const InstallationTimelineScreen(),
          'Activated': const SystemActivatedScreen(),
        };

        for (final screenEntry in screens.entries) {
          final screenTitle = screenEntry.key;
          final widget = screenEntry.value;

          FlutterErrorDetails? errorDetails;
          final originalOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            errorDetails = details;
            originalOnError?.call(details);
          };

          await tester.pumpWidget(
            MaterialApp(
              home: widget,
              theme: ThemeData(fontFamily: 'Plus Jakarta Sans'),
            ),
          );
          await tester.pump(const Duration(milliseconds: 200));

          FlutterError.onError = originalOnError;

          // Ensure no unhandled exception or overflow error
          final dynamic exception = tester.takeException();
          if (exception != null) {
            // ignore: avoid_print
            print('EXCEPTION on $screenTitle at $name: $exception');
            if (errorDetails != null) {
              // ignore: avoid_print
              print('FULL DETAILS:\n$errorDetails');
            }
          }
          expect(
            exception,
            isNull,
            reason:
                'Screen "$screenTitle" failed or threw overflow on viewport $name: $exception',
          );
        }
      });
    }
  });
}
