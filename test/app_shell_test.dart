import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apnasolar/widgets/app_shell.dart';
import 'package:apnasolar/widgets/common/app_button.dart';
import 'package:apnasolar/widgets/common/app_card.dart';
import 'package:apnasolar/widgets/common/app_flow_header.dart';
import 'package:apnasolar/widgets/common/app_journey_card.dart';
import 'package:apnasolar/widgets/common/app_metric_card.dart';
import 'package:apnasolar/widgets/common/app_quick_action.dart';
import 'package:apnasolar/widgets/common/status_badge.dart';

void main() {
  group('AppShell & Reusable Components Tests', () {
    testWidgets('AppShell renders Stitch global header and bottom navigation', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppShell(
            currentIndex: 0,
            child: Center(child: Text('Content Area')),
          ),
        ),
      );

      // Verify Header Elements
      expect(find.text('ApnaSolar'), findsOneWidget);
      expect(find.text('Bengaluru, KA'), findsOneWidget);
      expect(find.byIcon(Icons.solar_power_rounded), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Verify Bottom Navigation Items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Assess'), findsOneWidget);
      expect(find.text('Savings'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);

      // Verify Content Area
      expect(find.text('Content Area'), findsOneWidget);
    });

    testWidgets(
      'AppShell renders back button header when showBackButton=true',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AppShell(
              currentIndex: 1,
              showBackButton: true,
              title: 'Confirm Location',
              child: Center(child: Text('Map View')),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.text('Confirm Location'), findsOneWidget);
      },
    );

    testWidgets(
      'AppButton renders with trailing arrow badge and handles taps',
      (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Check My Solar Potential',
                leadingIcon: Icons.solar_power,
                showTrailingArrowBadge: true,
                onPressed: () => tapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Check My Solar Potential'), findsOneWidget);
        expect(find.byIcon(Icons.solar_power), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

        await tester.tap(find.text('Check My Solar Potential'));
        expect(tapped, isTrue);
      },
    );

    testWidgets('AppJourneyCard displays progress and step information', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppJourneyCard(
              currentStep: 2,
              totalSteps: 5,
              progressPercent: 0.4,
              completedMilestone: 'Rooftop Measured',
              nextMilestone: 'Subsidy Approval',
            ),
          ),
        ),
      );

      expect(find.text('Your Solar Journey'), findsOneWidget);
      expect(find.text('Step 2 of 5'), findsOneWidget);
      expect(find.text('Rooftop Measured'), findsOneWidget);
      expect(find.textContaining('Subsidy Approval'), findsOneWidget);
    });

    testWidgets('AppMetricCard renders value and label cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppMetricCard(
              icon: Icons.forest,
              iconColor: Colors.green,
              tag: 'Lifetime',
              value: '142',
              caption: 'Trees planted offset',
            ),
          ),
        ),
      );

      expect(find.text('142'), findsOneWidget);
      expect(find.text('Lifetime'), findsOneWidget);
      expect(find.text('Trees planted offset'), findsOneWidget);
    });

    testWidgets('AppQuickAction triggers callback on tap', (tester) async {
      bool actionTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppQuickAction(
              icon: Icons.document_scanner,
              iconContainerColor: Colors.green,
              iconColor: Colors.white,
              title: 'Scan Bill',
              subtitle: 'Instant OCR',
              onTap: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Scan Bill'), findsOneWidget);
      expect(find.text('Instant OCR'), findsOneWidget);

      await tester.tap(find.text('Scan Bill'));
      expect(actionTapped, isTrue);
    });

    testWidgets('AppFlowHeader renders step pill and action button', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppFlowHeader(
              stepText: 'Step 1 of 5 · Location',
              actionIcon: Icons.layers,
            ),
          ),
        ),
      );

      expect(find.text('Step 1 of 5 · Location'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.layers), findsOneWidget);
    });

    testWidgets('StatusBadge renders correctly with pulse dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Grade-A Solar Zone',
              variant: StatusBadgeVariant.secondaryFixed,
              hasPulseDot: true,
            ),
          ),
        ),
      );

      expect(find.text('Grade-A Solar Zone'), findsOneWidget);
    });

    testWidgets('AppCard renders with different variants', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppCard(
                  variant: AppCardVariant.standard,
                  child: Text('Standard Card'),
                ),
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Text('Elevated Card'),
                ),
                AppCard(
                  variant: AppCardVariant.banner,
                  child: Text('Banner Card'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Standard Card'), findsOneWidget);
      expect(find.text('Elevated Card'), findsOneWidget);
      expect(find.text('Banner Card'), findsOneWidget);
    });
  });
}
