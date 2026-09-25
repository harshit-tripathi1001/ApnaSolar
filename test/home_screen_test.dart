import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apnasolar/screens/home/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets(
      'HomeScreen renders all Stitch sections and values faithfully',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

        // Pump entrance animations without waiting for infinite pulsing dot
        await tester.pump(const Duration(milliseconds: 800));

        // Verify Header Location & Solar pills
        expect(find.text('Indiranagar, Bengaluru'), findsOneWidget);
        expect(find.text('High Sun Day'), findsOneWidget);

        // Verify Greeting
        expect(find.text('Good morning, Ramesh'), findsOneWidget);
        expect(
          find.text(
            'Clear skies over your terrace today. Ready to turn sun into real savings?',
          ),
          findsOneWidget,
        );

        // Verify Hero Rooftop Card Badges & Values
        expect(find.text('1,240 sq ft Terraced Roof'), findsOneWidget);
        expect(find.text('Grade-A Solar Zone'), findsOneWidget);
        expect(find.text('ESTIMATED MONTHLY VALUE'), findsOneWidget);
        expect(find.text('85% bill reduction'), findsOneWidget);
        expect(find.text('Your roof saves '), findsOneWidget);
        expect(find.text('₹3,350'), findsOneWidget);
        expect(find.text(' / month'), findsOneWidget);
        expect(find.text('Check My Solar Potential'), findsOneWidget);

        // Verify Solar Journey Card
        expect(find.text('Your Solar Journey'), findsOneWidget);
        expect(find.text('Step 2 of 5'), findsOneWidget);
        expect(find.text('Rooftop Measured'), findsOneWidget);

        // Verify Quick Actions Section
        expect(find.text('Quick Actions'), findsOneWidget);
        expect(find.text('1-Tap Fast Track'), findsOneWidget);
        expect(find.text('Scan Bill'), findsOneWidget);
        expect(find.text('Instant OCR'), findsOneWidget);
        expect(find.text('Subsidy Check'), findsOneWidget);
        expect(find.text('₹78,000 Direct'), findsOneWidget);
        expect(find.text('Talk to Pro'), findsOneWidget);

        // Verify PM Surya Ghar Banner
        expect(find.text('PM Surya Ghar Yojana'), findsOneWidget);

        // Verify Neighborhood Impact
        expect(find.text('Neighborhood Impact'), findsOneWidget);
        expect(find.text('142'), findsOneWidget);
        expect(find.text('Trees planted offset'), findsOneWidget);
        expect(find.text('₹9.8 L'), findsOneWidget);
        expect(find.text('Projected total gain'), findsOneWidget);

        // Verify Warranty Card
        expect(
          find.text('25-Year Manufacturer Warranty included'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Tapping warranty card opens protection modal', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump(const Duration(milliseconds: 800));

      final warrantyFinder = find.text(
        '25-Year Manufacturer Warranty included',
      );
      await tester.ensureVisible(warrantyFinder);
      await tester.pump(const Duration(milliseconds: 300));
      expect(warrantyFinder, findsOneWidget);

      // Tap the warranty card
      await tester.tap(warrantyFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check modal content
      expect(find.text('25-Year Protection Package'), findsOneWidget);
      expect(find.text('25-Year Solar Panel Linear Output'), findsOneWidget);
      expect(find.text('Got It'), findsOneWidget);

      // Dismiss modal
      await tester.tap(find.text('Got It'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('25-Year Protection Package'), findsNothing);
    });
  });
}
