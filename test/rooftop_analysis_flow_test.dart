import 'package:apnasolar/app/routes.dart';
import 'package:apnasolar/core/theme/app_theme.dart';
import 'package:apnasolar/screens/analysis/ai_roof_analysis_screen.dart';
import 'package:apnasolar/screens/recommendation/solar_recommendation_screen.dart';
import 'package:apnasolar/screens/roof_result/roof_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rooftop Analysis Flow Tests', () {
    testWidgets('AiRoofAnalysisScreen renders and navigates to roof result', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AiRoofAnalysisScreen(),
          routes: {AppRoutes.roofResult: (context) => const RoofResultScreen()},
        ),
      );

      expect(find.text('AI Roof Analysis'), findsWidgets);
      expect(find.textContaining('Step 3 of 5'), findsOneWidget);

      final nextBtn = find.text('View Roof Assessment Results');
      expect(nextBtn, findsOneWidget);

      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.text('Roof Assessment Result'), findsWidgets);
    });

    testWidgets('RoofResultScreen renders and navigates to recommendation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RoofResultScreen(),
          routes: {
            AppRoutes.solarRecommendation: (context) =>
                const SolarRecommendationScreen(),
          },
        ),
      );

      expect(find.text('Roof Assessment Result'), findsWidgets);
      expect(
        find.textContaining('1,120 sq ft usable terrace area'),
        findsOneWidget,
      );

      final ctaBtn = find.text('See Recommended Solar System');
      expect(ctaBtn, findsOneWidget);

      await tester.tap(ctaBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SolarRecommendationScreen), findsOneWidget);
    });
  });
}
