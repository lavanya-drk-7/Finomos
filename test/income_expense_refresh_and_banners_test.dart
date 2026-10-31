import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/features/income_tracking/presentation/income_tracking_screen.dart';
import 'package:finomos/features/expense_tracking/presentation/expense_tracking_screen.dart';

void main() {
  testWidgets('IncomeTrackingScreen has RefreshIndicator and no AI Personal CFO banner', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: IncomeTrackingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify RefreshIndicator is present
    expect(find.byType(RefreshIndicator), findsOneWidget);

    // 2. Verify AI Personal CFO banner is completely removed
    expect(find.textContaining('AI Personal CFO: High Stability'), findsNothing);

    // 3. Test drag-to-refresh
    await tester.fling(find.byType(ListView).first, const Offset(0, 300), 1000);
    await tester.pump();
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('ExpenseTrackingScreen has RefreshIndicator and no AI Personal CFO banner', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ExpenseTrackingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify RefreshIndicator is present
    expect(find.byType(RefreshIndicator), findsOneWidget);

    // 2. Verify AI Personal CFO banner is completely removed
    expect(find.textContaining('AI Personal CFO: Expense Health Score'), findsNothing);

    // 3. Test drag-to-refresh
    await tester.fling(find.byType(ListView).first, const Offset(0, 300), 1000);
    await tester.pump();
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });
}

