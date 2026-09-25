import 'package:apnasolar/app/routes.dart';
import 'package:apnasolar/core/theme/app_theme.dart';
import 'package:apnasolar/screens/cost_breakdown/cost_breakdown_screen.dart';
import 'package:apnasolar/screens/recommendation/solar_recommendation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SolarRecommendationScreen Widget Tests', () {
    testWidgets('Renders all Stitch visual hierarchy, charts, and metrics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SolarRecommendationScreen(),
          routes: {
            AppRoutes.costBreakdown: (context) => const CostBreakdownScreen(),
          },
        ),
      );

      // Pump frame to trigger animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1400));

      // 1. Progress Header & Hero Header
      expect(find.text('Step 4 of 5'), findsOneWidget);
      expect(find.text('AI Optimized'), findsOneWidget);
      expect(find.text('98.4% Solar Insolation Match'), findsOneWidget);
      expect(find.text('Your Perfect Solar Match'), findsOneWidget);

      // 2. 3D Rooftop Hero Visual
      expect(find.text('5.8 kW System Capacity'), findsOneWidget);
      expect(find.text('Bangalore Sun-Path: 5.2 hrs/day'), findsOneWidget);
      expect(find.textContaining('Bi-Facial Panels'), findsOneWidget);
      expect(find.text('TopCon 550W Tier-1'), findsOneWidget);

      // 3. PRIMARY SOLAR RESULT: Giant Impact Block
      expect(find.text('ESTIMATED ELECTRICITY DROP'), findsOneWidget);
      expect(find.text('₹3,350'), findsOneWidget);
      expect(find.text('/ mo saved'), findsOneWidget);
      expect(find.text('87% Cut'), findsOneWidget);
      expect(find.text('₹500'), findsOneWidget);
      expect(
        find.textContaining('₹40,200/year back in your bank account'),
        findsOneWidget,
      );

      // 4. Annual Generation Curve Chart
      expect(find.text('Annual Generation Curve'), findsOneWidget);
      expect(find.text('8,640 kWh/yr'), findsOneWidget);
      expect(find.text('Solar Generated'), findsOneWidget);
      expect(find.text('Baseline Use (420)'), findsOneWidget);

      // 5. System & Financial Metrics Bento
      expect(find.text('Solar & Financial Metrics'), findsOneWidget);
      expect(find.text('Usable Rooftop Area'), findsOneWidget);
      expect(find.text('1,120 sq. ft'), findsOneWidget);
      expect(find.text('Net Turnkey Cost'), findsOneWidget);
      expect(find.text('Payback Period'), findsOneWidget);
      expect(find.text('Payback vs 25-Year System Lifetime'), findsOneWidget);

      // 6. Key Plan Highlights
      expect(find.text('Key Plan Highlights'), findsOneWidget);
      expect(find.text('100% Day Load Covered'), findsOneWidget);
      expect(find.text('25-Year Generation Guarantee'), findsOneWidget);
      expect(find.text('₹78,000 Direct DBT Subsidy'), findsOneWidget);

      // 7. Environmental Impact
      expect(find.text('Lifetime Eco Impact'), findsOneWidget);
      expect(find.textContaining('Trees Saved'), findsOneWidget);

      // 8. Primary CTA Button
      final ctaFinder = find.text('View Equipment & Cost Details');
      expect(ctaFinder, findsOneWidget);

      await tester.ensureVisible(ctaFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(ctaFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CostBreakdownScreen), findsOneWidget);
    });

    testWidgets('Customizer modal opens and adjusts system size', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SolarRecommendationScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1400));

      final customizeFinder = find.text(
        'Customize system size (3.5 kW - 7.5 kW)',
      );
      expect(customizeFinder, findsOneWidget);

      await tester.ensureVisible(customizeFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(customizeFinder);
      await tester.pump();

      // Tick through the bottom sheet opening animation
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Verify modal is open
      expect(find.text('Adjust System Size'), findsOneWidget);
      expect(find.text('3.5 kW (Budget)'), findsOneWidget);
      expect(find.text('7.5 kW (Max Generation)'), findsOneWidget);

      final applyBtnFinder = find.text('Apply Size');
      expect(applyBtnFinder, findsOneWidget);

      // Apply and close modal
      await tester.tap(applyBtnFinder);
      await tester.pump();

      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Adjust System Size'), findsNothing);
    });
  });
}
