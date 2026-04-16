import 'package:flutter_test/flutter_test.dart';
import 'package:venue_vantage/main.dart';

void main() {
  testWidgets('VenueVantage app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VenueVantageApp());
    expect(find.byType(VenueVantageApp), findsOneWidget);
  });
}
