import 'package:flutter_test/flutter_test.dart';
import 'package:apnasolar/app/apnasolar_app.dart';

void main() {
  testWidgets('ApnaSolar app launches and renders splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ApnaSolarApp());
    expect(find.text('ApnaSolar'), findsOneWidget);
    expect(find.text('Know your roof. Know your savings.'), findsOneWidget);

    // Fast-forward through splash timer to transition to Welcome screen
    await tester.pumpAndSettle(const Duration(milliseconds: 1600));
    expect(find.text('Know your roof.\nKnow your savings.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
