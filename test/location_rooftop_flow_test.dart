import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apnasolar/app/routes.dart';
import 'package:apnasolar/screens/location/confirm_location_screen.dart';
import 'package:apnasolar/screens/roof_drawing/satellite_roof_drawing_screen.dart';

void main() {
  group('Location & Rooftop Selection Flow Tests', () {
    testWidgets(
      'ConfirmLocationScreen renders all Stitch components & interactions',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            routes: {
              AppRoutes.confirmLocation: (context) =>
                  const ConfirmLocationScreen(),
              AppRoutes.satelliteRoofDrawing: (context) =>
                  const SatelliteRoofDrawingScreen(),
            },
            home: const ConfirmLocationScreen(),
          ),
        );

        // Pump initial render without waiting for infinite pulsing dot
        await tester.pump(const Duration(milliseconds: 300));

        // 1. Verify Step Badge
        expect(find.text('Step 1 of 5 · Location'), findsOneWidget);

        // 2. Verify Search Bar pre-fill
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('GPS'), findsOneWidget);

        // 3. Verify Floating Sunlight Chip
        expect(find.text('5.2 Peak Sun-Hours / day'), findsOneWidget);

        // 4. Verify Map Zoom controls
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byIcon(Icons.remove), findsOneWidget);
        expect(find.byIcon(Icons.layers), findsOneWidget);

        // 5. Test Zoom buttons tap
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump(const Duration(milliseconds: 100));

        // 6. Test Satellite Layer toggle
        await tester.tap(find.byIcon(Icons.layers));
        await tester.pump(const Duration(milliseconds: 500));
        expect(
          find.text('Satellite simulation · Bengaluru calibrated'),
          findsOneWidget,
        );

        // 7. Verify Bottom Confirmation Card
        expect(find.text('Is this your home?'), findsOneWidget);
        expect(find.text('High Solar Yield'), findsOneWidget);
        expect(find.text('Est. Area'), findsOneWidget);
        expect(find.text('1,420'), findsOneWidget);
        expect(find.text('Move map to adjust pin'), findsOneWidget);
        expect(find.text('Confirm Location'), findsOneWidget);

        // 8. Test Search Suggestions
        await tester.tap(find.byType(TextField));
        await tester.pump();
        expect(find.textContaining('100 Feet Rd'), findsOneWidget);
        await tester.tap(find.textContaining('100 Feet Rd'));
        await tester.pump();

        // 9. Test Confirm Location navigation
        await tester.tap(find.text('Confirm Location'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Verify navigated to SatelliteRoofDrawingScreen
        expect(find.text('Step 3 of 5 · Roof Boundary'), findsOneWidget);
      },
    );

    testWidgets(
      'SatelliteRoofDrawingScreen renders draggable boundary & calculates metrics',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            routes: {
              AppRoutes.satelliteRoofDrawing: (context) =>
                  const SatelliteRoofDrawingScreen(),
              AppRoutes.aiRoofAnalysis: (context) =>
                  const Scaffold(body: Text('AI Roof Analysis Screen Mock')),
              AppRoutes.rooftopPhoto: (context) =>
                  const Scaffold(body: Text('Rooftop Photo Screen Mock')),
            },
            home: const SatelliteRoofDrawingScreen(),
          ),
        );

        await tester.pump(const Duration(milliseconds: 300));

        // 1. Verify Step Capsule & Micro Stepper
        expect(find.text('Step 3 of 5 · Roof Boundary'), findsOneWidget);
        expect(find.text('Sat'), findsOneWidget);
        expect(find.text('3D'), findsOneWidget);

        // 2. Test 3D perspective toggle
        await tester.tap(find.text('3D'));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.text('Sat'));
        await tester.pump(const Duration(milliseconds: 400));

        // 3. Verify Instruction pill & Reset
        expect(find.text('Drag pins to match terrace parapet'), findsOneWidget);
        expect(find.text('Reset'), findsOneWidget);

        // 4. Verify Center Rooftop Metrics & Water Tank exclusion
        expect(find.text('1,245 sq. ft'), findsOneWidget);
        expect(find.text('94% Solar Viable'), findsOneWidget);
        expect(find.text('Water Tank Excluded'), findsOneWidget);

        // 5. Verify Terrace Specs Bento Card
        expect(find.text('Terrace Analysis'), findsOneWidget);
        expect(find.text('High Irradiance'), findsOneWidget);
        expect(find.text('Net Usable'), findsOneWidget);
        expect(find.text('Max Power'), findsOneWidget);
        expect(find.text('Obstacles'), findsOneWidget);
        expect(
          find.text('Qualifies for ₹78,000 central PM Surya Ghar DBT subsidy.'),
          findsOneWidget,
        );

        // 6. Test dragging a vertex handle
        final handleFinders = find.byType(GestureDetector);
        expect(handleFinders, findsWidgets);
        await tester.drag(handleFinders.at(2), const Offset(20, 20));
        await tester.pump();

        // 7. Test Reset button
        await tester.tap(find.text('Reset'), warnIfMissed: false);
        await tester.pump();
        expect(find.text('1,245 sq. ft'), findsOneWidget);

        // 8. Test Navigation to AI Roof Analysis
        expect(find.text('Use This Roof Boundary'), findsOneWidget);
        await tester.tap(find.text('Use This Roof Boundary'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('AI Roof Analysis Screen Mock'), findsOneWidget);
      },
    );

    testWidgets(
      'SatelliteRoofDrawingScreen secondary CTA navigates to Rooftop Photo',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            routes: {
              AppRoutes.satelliteRoofDrawing: (context) =>
                  const SatelliteRoofDrawingScreen(),
              AppRoutes.rooftopPhoto: (context) =>
                  const Scaffold(body: Text('Rooftop Photo Screen Mock')),
            },
            home: const SatelliteRoofDrawingScreen(),
          ),
        );

        await tester.pump(const Duration(milliseconds: 300));

        final cameraCta = find.text('Switch to Camera Photo instead');
        expect(cameraCta, findsOneWidget);
        await tester.tap(cameraCta);
        await tester.pumpAndSettle();

        expect(find.text('Rooftop Photo Screen Mock'), findsOneWidget);
      },
    );
  });
}
