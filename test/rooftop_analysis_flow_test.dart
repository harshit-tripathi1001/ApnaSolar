import 'package:apnasolar/app/routes.dart';
import 'package:apnasolar/core/theme/app_theme.dart';
import 'package:apnasolar/screens/analysis/ai_roof_analysis_screen.dart';
import 'package:apnasolar/screens/recommendation/solar_recommendation_screen.dart';
import 'package:apnasolar/screens/roof_drawing/satellite_roof_drawing_screen.dart';
import 'package:apnasolar/screens/roof_result/roof_result_screen.dart';
import 'package:apnasolar/services/rooftop_analysis_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rooftop Analysis Service & Progression Unit Tests', () {
    test(
      'MockRooftopAnalysisService progresses through all discrete phases',
      () async {
        final service = MockRooftopAnalysisService();
        final states = <AnalysisProgressState>[];

        service.progressStream.listen(states.add);

        // Run with Duration.zero for fast unit test execution
        await service.startAnalysis(stepDuration: Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(states.length, greaterThanOrEqualTo(5));
        expect(states.first.phase, AnalysisPhase.input);
        expect(states.last.phase, AnalysisPhase.resultReady);
        expect(states.last.isComplete, isTrue);
        expect(states.last.progress, 1.0);
        expect(states.last.usableAreaSqFt, 1120.0);
        expect(states.last.detectedGrossAreaSqFt, 1440.0);
        expect(states.last.recommendedCapacityKw, greaterThanOrEqualTo(3.0));

        final analysis = states.last.toRooftopAnalysis();
        expect(analysis.solarViabilityPercent, 78.0);
        expect(analysis.obstacleCount, 2);

        service.dispose();
      },
    );

    test('MockRooftopAnalysisService fastForward completes immediately', () {
      final service = MockRooftopAnalysisService();
      expect(service.currentState.isComplete, isFalse);

      service.fastForward();
      expect(service.currentState.isComplete, isTrue);
      expect(service.currentState.phase, AnalysisPhase.resultReady);

      service.dispose();
    });
  });

  group('AiRoofAnalysisScreen Widget Tests', () {
    testWidgets(
      'Renders all Stitch scanner elements, HUD tiles, and pipeline',
      (WidgetTester tester) async {
        final service = MockRooftopAnalysisService();

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: AiRoofAnalysisScreen(analysisService: service),
            routes: {
              AppRoutes.roofResult: (context) => const RoofResultScreen(),
            },
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        // Verify progress header meta
        expect(find.text('Step 3 of 5'), findsOneWidget);
        expect(find.text('· AI Analysis'), findsOneWidget);
        expect(find.text('0.3m Res'), findsOneWidget);

        // Verify HUD metric tiles
        expect(find.text('Irradiance'), findsOneWidget);
        expect(find.text('5.4'), findsOneWidget);
        expect(find.text('Roof Slope'), findsOneWidget);
        expect(find.text('Flat (0°)'), findsOneWidget);
        expect(find.text('Azimuth'), findsOneWidget);
        expect(find.text('180° South'), findsOneWidget);

        // Verify Reticle and Obstacle shadow zone tags
        expect(find.text('Target Reticle Active'), findsOneWidget);
        expect(find.text('Shadow Zone (Sintex)'), findsOneWidget);

        // Verify Pipeline Card steps
        expect(find.text('Boundary & Parapet Detected'), findsOneWidget);
        expect(find.text('1,480 sq.ft'), findsOneWidget);
        expect(find.text('Shadow Obstacles Isolated'), findsOneWidget);
        expect(find.text('2 Excluded'), findsOneWidget);
        expect(find.text('Calculating Optimal Panel Count'), findsOneWidget);

        // Verify Subsidy reassurance banner
        expect(find.text('PM Surya Ghar: Muft Bijli Yojana'), findsOneWidget);
        expect(
          find.textContaining('Central subsidy eligibility up to ₹78,000'),
          findsOneWidget,
        );

        // Fast forward service to completed state
        service.fastForward();
        await tester.pump(const Duration(milliseconds: 100));

        // CTA should now be "View Solar Assessment Results"
        final ctaFinder = find.text('View Solar Assessment Results');
        expect(ctaFinder, findsOneWidget);
        expect(find.text('LiDAR Mesh Locked'), findsOneWidget);

        // Scroll to make sure CTA is fully in view and tap it
        await tester.ensureVisible(ctaFinder);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(ctaFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(RoofResultScreen), findsOneWidget);
        service.dispose();
      },
    );
  });

  group('RoofResultScreen Widget Tests', () {
    testWidgets(
      'Renders all Stitch hero metrics, capacity, and action buttons',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const RoofResultScreen(),
            routes: {
              AppRoutes.solarRecommendation: (context) =>
                  const SolarRecommendationScreen(),
              AppRoutes.satelliteRoofDrawing: (context) =>
                  const SatelliteRoofDrawingScreen(),
            },
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        // Verify header & badges
        expect(find.text('Step 3 of 5'), findsOneWidget);
        expect(find.text('Roof Assessment'), findsOneWidget);
        expect(find.text('AI Verified'), findsOneWidget);

        // Verify hero overlay badges
        expect(find.text('Sunny Patch'), findsOneWidget);
        expect(find.text('Shadow Buffer'), findsOneWidget);
        expect(find.text('South-Facing'), findsOneWidget);
        expect(find.text('Plot #42, Indiranagar'), findsOneWidget);
        expect(find.text('Fine-Tune'), findsOneWidget);

        // Verify giant usable roof area
        expect(find.text('USABLE SOLAR TERRACE AREA'), findsOneWidget);
        expect(find.text('78% shadow-free'), findsOneWidget);
        expect(find.text('1,120'), findsOneWidget);
        expect(find.text('sq. ft'), findsOneWidget);

        // Verify Solar Capacity Highlight block
        expect(find.text('5.8 kW Peak Capacity'), findsOneWidget);
        expect(
          find.text('Generates ~22 clean units (kWh) / day'),
          findsOneWidget,
        );

        // Verify System Snapshot
        expect(find.text('Fits 12 Monocrystalline Panels'), findsOneWidget);
        expect(
          find.textContaining('78,000', findRichText: true),
          findsOneWidget,
        );

        // Verify Impact grid
        expect(find.text('Monthly Offset'), findsOneWidget);
        expect(find.text('₹4,250'), findsOneWidget);
        expect(find.text('92% bill reduction'), findsOneWidget);
        expect(find.text('Carbon Value'), findsOneWidget);
        expect(find.text('182 Trees'), findsOneWidget);

        // Verify Primary CTA: See My Solar Plan
        final seePlanFinder = find.text('See My Solar Plan');
        expect(seePlanFinder, findsOneWidget);
        await tester.ensureVisible(seePlanFinder);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(seePlanFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(SolarRecommendationScreen), findsOneWidget);
      },
    );
  });
}
