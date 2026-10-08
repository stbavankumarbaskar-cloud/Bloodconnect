import 'package:flutter_test/flutter_test.dart';
import 'package:donor_search/main.dart';

void main() {
  testWidgets('BloodBridge App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BloodBridgeApp());
    expect(find.byType(BloodBridgeApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
