import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/budget_management/presentation/budget_management_screen.dart';

void main() {
  testWidgets('BudgetManagementScreen renders without exceptions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BudgetManagementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(BudgetManagementScreen), findsOneWidget);
    expect(find.text('Budget Management'), findsWidgets);
    expect(find.text('Filter'), findsOneWidget);
  });

  testWidgets('Tapping Filter button opens bottom sheet modal with status and category options', (tester) async {
    // Set a realistic phone screen size for widget test
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BudgetManagementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify filter button exists and tap it
    final filterButton = find.text('Filter');
    expect(filterButton, findsOneWidget);
    await tester.tap(filterButton);
    await tester.pumpAndSettle();

    // Verify filter modal bottom sheet contents
    expect(find.text('Filter Budgets'), findsOneWidget);
    expect(find.text('Budget Status'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Sort By'), findsOneWidget);
    expect(find.text('Apply Filters'), findsOneWidget);
    expect(find.text('Reset All'), findsOneWidget);

    // Verify status chips
    expect(find.text('On Track'), findsOneWidget);
    expect(find.text('80% Warning'), findsOneWidget);
    expect(find.text('Exceeded'), findsOneWidget);

    // Tap 'Exceeded' status chip and apply
    await tester.tap(find.text('Exceeded'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    // Verify sheet closed and active filter badge is displayed
    expect(find.text('Filter Budgets'), findsNothing);
    expect(find.text('Status: Exceeded'), findsOneWidget);
    expect(find.text('Clear All'), findsOneWidget);

    // Tap Clear All and verify active filter badge removed
    await tester.tap(find.text('Clear All'));
    await tester.pumpAndSettle();
    expect(find.text('Status: Exceeded'), findsNothing);
  });
}
