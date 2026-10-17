import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/features/income_tracking/presentation/income_tracking_screen.dart';
import 'package:finomos/features/expense_tracking/presentation/expense_tracking_screen.dart';

void main() {
  testWidgets(
    'IncomeTrackingScreen displays Transactions History on Tab 0 and Sources with Edit/Delete on Tab 1',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: IncomeTrackingScreen())),
      );
      await tester.pumpAndSettle();

      // Verify Tab 0 is Income Streams (Transaction History only - no Edit Details or Delete)
      expect(find.text('Income History'), findsOneWidget);
      expect(find.text('Edit Details'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      // Tab 0 transactions must have '+' before amount, and must NOT show uploaded document badges
      expect(find.text('+₹85,000'), findsOneWidget);
      expect(find.text('salary_slip_aug_2025.pdf'), findsNothing);

      // Verify TabBar has Income Sources
      expect(find.text('Income Sources'), findsOneWidget);

      // Switch to Income Sources tab
      await tester.tap(find.text('Income Sources'));
      await tester.pumpAndSettle();

      // Verify Income Sources UI elements
      expect(find.text('Active Income Sources'), findsOneWidget);
      expect(find.text('Add New Income Source'), findsOneWidget);

      // Verify Edit Details and Delete buttons are visible on sources in Tab 1
      expect(find.text('Edit Details'), findsWidgets);
      expect(find.text('Delete'), findsWidgets);

      // Test Delete confirmation dialog
      final deleteButtons = find.text('Delete');
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Verify confirmation modal opens
      expect(find.text('Delete Income Source'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Income Source'), findsNothing);

      // Test Edit modal has Document actions
      final editButtons = find.text('Edit Details');
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      // Verify Edit modal is visible
      expect(find.text('Edit Income Stream'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      // Verify document attached with Eye and Download buttons beside Close
      expect(find.text('salary_slip_aug_2025.pdf'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      expect(find.byIcon(Icons.close), findsWidgets);

      // Verify removed subtitle and removed toggle
      expect(
        find.text(
          'Record recurring or one-time earnings to update cash forecasting.',
        ),
        findsNothing,
      );
      expect(find.text('Mark as Verified Stream'), findsNothing);

      // Test Eye Symbol opens real document preview dialog
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Uploaded Verification Document'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      // Tap Close on preview dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Test Download Symbol triggers device file download
      await tester.tap(find.byIcon(Icons.download_outlined));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Downloaded "salary_slip_aug_2025.pdf" to device'),
        findsOneWidget,
      );

      // Change amount from 85000 to 10000
      final amountField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Income Amount (₹)',
      );
      await tester.enterText(amountField, '10000');
      await tester.pumpAndSettle();

      // Tap Save Changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Check edited value appears
      expect(find.text('₹10,000'), findsWidgets);
    },
  );

  testWidgets(
    'ExpenseTrackingScreen displays Transactions History on Tab 0 and Sources with Edit/Delete on Tab 1',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ExpenseTrackingScreen())),
      );
      await tester.pumpAndSettle();

      // Verify Tab 0 is Expense List (Transaction History only - no Edit Details or Delete)
      expect(find.text('Expense List'), findsOneWidget);
      expect(find.text('Edit Details'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      // Tab 0 transactions must have '-' before amount, and must NOT show uploaded document badges
      expect(find.text('-₹22,000'), findsOneWidget);
      expect(find.text('rent_agreement_koramangala.pdf'), findsNothing);

      // Verify TabBar has Expense Sources
      expect(find.text('Expense Sources'), findsOneWidget);

      // Switch to Expense Sources tab
      await tester.tap(find.text('Expense Sources'));
      await tester.pumpAndSettle();

      // Verify Expense Sources UI elements
      expect(find.text('Active Expense Sources'), findsOneWidget);
      expect(find.text('Add New Expense Source'), findsOneWidget);

      // Verify Edit Details and Delete buttons are visible in Tab 1
      expect(find.text('Edit Details'), findsWidgets);
      expect(find.text('Delete'), findsWidgets);

      // Test Delete confirmation dialog
      final deleteButtons = find.text('Delete');
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Verify confirmation modal opens
      expect(find.text('Delete Expense Source'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Expense Source'), findsNothing);

      // Test Edit modal has Document actions
      final editButtons = find.text('Edit Details');
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      // Verify Edit modal is visible
      expect(find.text('Edit Expense Record'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      // Verify document attached with Eye and Download buttons beside Close
      expect(find.text('rent_agreement_koramangala.pdf'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      expect(find.byIcon(Icons.close), findsWidgets);

      // Verify removed subtitle and removed toggle
      expect(
        find.text(
          'Pillar 2: SPEND • Track outflows, priority weights, and recurring bills.',
        ),
        findsNothing,
      );
      expect(
        find.text('Recurring Commitment (Bill / Sub / EMI)'),
        findsNothing,
      );

      // Test Eye Symbol opens real document preview dialog
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Uploaded Verification Document'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      // Tap Close on preview dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Test Download Symbol triggers device file download
      await tester.tap(find.byIcon(Icons.download_outlined));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          'Downloaded "rent_agreement_koramangala.pdf" to device',
        ),
        findsOneWidget,
      );

      // Change amount to 15000
      final amountField = find.byWidgetPredicate(
        (w) =>
            w is TextField && w.decoration?.labelText == 'Expense Amount (₹)',
      );
      await tester.enterText(amountField, '15000');
      await tester.pumpAndSettle();

      // Tap Save Changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Verify update reflected
      expect(find.text('₹15,000'), findsWidgets);
    },
  );

  testWidgets(
    'Income module Record Stream validates amount, parses commas, and auto-fills source fallback',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: IncomeTrackingScreen())),
      );
      await tester.pumpAndSettle();

      // Open Add Income Stream sheet via AppBar action
      final addBtn = find.byTooltip('Add Income');
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.text('Add Income Stream'), findsOneWidget);
      expect(find.text('Record Stream'), findsOneWidget);

      // 1. Try to submit without amount: should show amount error, NOT generic block
      await tester.tap(find.text('Record Stream'));
      await tester.pumpAndSettle();
      expect(
        find.text('Please enter an amount greater than ₹0'),
        findsOneWidget,
      );

      // 2. Enter amount with currency symbol and commas: ₹35,000
      final amountField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Income Amount (₹)',
      );
      await tester.enterText(amountField, '₹35,000');
      await tester.pumpAndSettle();

      // Leave source field empty to test auto-fallback to category ('Salary')
      await tester.tap(find.text('Record Stream'));
      await tester.pumpAndSettle();

      // Bottom sheet closes and success snackbar is shown
      expect(find.text('Add Income Stream'), findsNothing);
      expect(find.text('Income stream recorded!'), findsOneWidget);
      expect(find.text('+₹35,000'), findsWidgets);
    },
  );

  testWidgets(
    'Expense module Record Outflow validates amount, parses commas, and auto-fills description fallback',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ExpenseTrackingScreen())),
      );
      await tester.pumpAndSettle();

      // Open Record New Expense sheet via AppBar action
      final addBtn = find.byTooltip('Add Expense');
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.text('Record New Expense'), findsOneWidget);
      expect(find.text('Record Outflow'), findsOneWidget);

      // 1. Try to submit without amount: should show amount error
      await tester.tap(find.text('Record Outflow'));
      await tester.pumpAndSettle();
      expect(
        find.text('Please enter an amount greater than ₹0'),
        findsOneWidget,
      );

      // 2. Enter amount with commas: 2,450
      final amountField = find.byWidgetPredicate(
        (w) =>
            w is TextField && w.decoration?.labelText == 'Expense Amount (₹)',
      );
      await tester.enterText(amountField, '2,450');
      await tester.pumpAndSettle();

      // Leave description field empty, enter Merchant 'Zomato'
      final merchantField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Merchant / Payee',
      );
      await tester.enterText(merchantField, 'Zomato');
      await tester.pumpAndSettle();

      // Tap Record Outflow
      await tester.tap(find.text('Record Outflow'));
      await tester.pumpAndSettle();

      // Bottom sheet closes and success snackbar is shown
      expect(find.text('Record New Expense'), findsNothing);
      expect(find.textContaining('Expense recorded!'), findsOneWidget);
      expect(find.text('-₹2,450'), findsWidgets);
    },
  );
}
