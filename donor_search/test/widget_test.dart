import 'package:flutter_test/flutter_test.dart';
import 'package:donor_search/main.dart';

void main() {
  testWidgets('BloodConnect App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BloodConnectApp());
    expect(find.byType(BloodConnectApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
