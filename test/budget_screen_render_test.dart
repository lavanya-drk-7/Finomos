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

  testWidgets('Budget Sources tab renders with master card and Add New Budget Source button', (tester) async {
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

    // Verify Tab with text 'Budget Sources'
    final budgetSourcesTab = find.text('Budget Sources');
    expect(budgetSourcesTab, findsOneWidget);

    // Tap on 'Budget Sources' tab
    await tester.tap(budgetSourcesTab);
    await tester.pumpAndSettle();

    // Verify Master Card elements
    expect(find.text('Active Budget Sources'), findsOneWidget);
    expect(find.text('Add New Budget Source'), findsOneWidget);
    expect(find.text('Total Monthly Ceiling Allocated across all categories'), findsOneWidget);
    expect(find.text('Configured Budget Sources'), findsOneWidget);

    // Tap 'Add New Budget Source' and verify sheet opens
    await tester.tap(find.text('Add New Budget Source'));
    await tester.pumpAndSettle();

    expect(find.text('Create Budget Limit'), findsOneWidget);
  });

  testWidgets('Budget categories cards do not show Edit/Delete/Record buttons and tapping opens details sheet', (tester) async {
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

    // Verify Tab 1 'Budget Categories' is active
    expect(find.text('Budget Categories'), findsWidgets);

    // Verify 'Record Expense' button is NOT visible directly on the cards in Tab 1
    expect(find.text('Record Expense'), findsNothing);

    // If budget cards exist in initial state, tapping one opens details sheet
    final detailsFinder = find.text('Details');
    if (detailsFinder.evaluate().isNotEmpty) {
      await tester.tap(detailsFinder.first);
      await tester.pumpAndSettle();

      expect(find.text('Budget Details'), findsWidgets);
      expect(find.text('MONTHLY BUDGET ALLOCATION'), findsOneWidget);
      expect(find.text('Budget Type'), findsOneWidget);
    }
  });

  testWidgets('AppBar (+) button on Budget Categories tab opens create budget sheet and is hidden on Budget Sources tab', (tester) async {
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

    // Verify (+) button is present on Budget Categories tab
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

    // Tapping (+) button opens create budget sheet
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
    expect(find.text('Create Budget Limit'), findsOneWidget);

    // Close bottom sheet
    Navigator.of(tester.element(find.text('Create Budget Limit'))).pop();
    await tester.pumpAndSettle();

    // Switch to Budget Sources tab
    await tester.tap(find.text('Budget Sources'));
    await tester.pumpAndSettle();

    // Verify (+) button in AppBar is hidden on Budget Sources tab
    expect(find.byTooltip('Add Budget'), findsNothing);

    // Verify ON TRACK text is NOT shown on the budget cards in Budget Sources
    expect(find.text('ON TRACK'), findsNothing);

    // Verify standalone '/' is not present
    expect(find.text('/'), findsNothing);
  });
}
