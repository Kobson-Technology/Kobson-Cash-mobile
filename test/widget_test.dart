import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kobson_cash/main.dart';

void main() {
  testWidgets('App smoke test - splash screen builds correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KobsonCashApp(),
      ),
    );
    expect(find.text('KOBSON CASH'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
