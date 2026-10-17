import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/bank_aggregation/presentation/bank_aggregation_screen.dart';

void main() {
  testWidgets('Test BankAggregationScreen layout, rendering and scrolling without overflows', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BankAggregationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify key titles and header elements
    expect(find.text('Bank & Aggregation'), findsOneWidget);
    expect(find.text('CONSOLIDATED FINANCIAL NET WORTH'), findsOneWidget);
    expect(find.text('Connected Accounts'), findsOneWidget);
    expect(find.text('UPI Accounts & Mandates'), findsOneWidget);
    expect(find.text('Credit Cards & Limits'), findsOneWidget);
    expect(find.text('Loan Accounts & Liabilities'), findsOneWidget);

    // Scroll to middle
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Investment & Retirement Portfolio'), findsOneWidget);
    expect(find.text('Insurance Protection Coverage'), findsOneWidget);

    // Scroll to bottom
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.text('Consent Management (FAA-SEC-11)'), findsOneWidget);
    expect(find.text('Institution Directory & Open Banking (FAA-SEC-01)'), findsOneWidget);
    expect(find.text('Recent Ingested Transactions'), findsOneWidget);

    // Scroll back to top
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, 1400));
    await tester.pumpAndSettle();

    // Tap UPI tab filter
    await tester.tap(find.text('UPI (3)'));
    await tester.pumpAndSettle();
    expect(find.text('UPI Accounts & Mandates'), findsOneWidget);

    // Tap All tab
    await tester.tap(find.textContaining('All ('));
    await tester.pumpAndSettle();

    // Tap Sync icon in AppBar
    await tester.tap(find.byIcon(Icons.sync));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
