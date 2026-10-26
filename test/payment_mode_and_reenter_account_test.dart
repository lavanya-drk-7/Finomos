import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/expense_tracking/presentation/expense_tracking_screen.dart';
import 'package:finomos/features/bank_aggregation/presentation/bank_aggregation_screen.dart';

void main() {
  testWidgets('Record New Expense modal has Mode of Payment label instead of Payment Channel', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
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

    // Open Record Expense modal
    final addExpenseBtn = find.byTooltip('Add Expense');
    expect(addExpenseBtn, findsOneWidget);
    await tester.tap(addExpenseBtn);
    await tester.pumpAndSettle();

    // Verify 'Mode of Payment' is displayed and 'Payment Channel' is removed
    expect(find.text('Mode of Payment'), findsOneWidget);
    expect(find.text('Payment Channel'), findsNothing);
  });

  testWidgets('Link Bank Account has Re-Enter Bank Account Number with matching, green tick mark, and IFSC auto-fetch', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
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

    // Open Link Bank modal
    final linkBankBtn = find.text('Link Bank');
    expect(linkBankBtn, findsOneWidget);
    await tester.tap(linkBankBtn);
    await tester.pumpAndSettle();

    expect(find.text('Link Bank Account'), findsOneWidget);

    // Verify both fields are present
    final accNumField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == 'Bank Account Number',
    );
    final reEnterField = find.byWidgetPredicate(
      (w) => w is TextField && (w.decoration?.labelText == 'Re-Enter Bank Account Number' || w.decoration?.labelText == 'Re-Enter Account Number'),
    );
    final ifscField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == 'Branch IFSC Code',
    );

    expect(accNumField, findsOneWidget);
    expect(reEnterField, findsOneWidget);

    // Enter Bank Account Number in first field
    await tester.enterText(accNumField, '501004329871');
    await tester.pumpAndSettle();

    // 1. Enter MISMATCHED account number in Re-Enter field
    await tester.enterText(reEnterField, '501004329999');
    await tester.pumpAndSettle();

    // Expect error text on mismatch
    expect(find.text('Account Number Mismatch Enter Correctly!'), findsOneWidget);

    // 2. Enter MATCHING account number in Re-Enter field
    await tester.enterText(reEnterField, '501004329871');
    await tester.pumpAndSettle();

    // Error text must disappear
    expect(find.text('Account Number Mismatch Enter Correctly!'), findsNothing);
    // Green tick mark should be visible (check_circle icon)
    expect(find.byIcon(Icons.check_circle), findsWidgets);

    // 3. Now enter IFSC code to trigger auto-fetch of Branch Location & Account Holder Name
    await tester.enterText(ifscField, 'SBIN0001234');
    await tester.pumpAndSettle();

    // Verify auto-fetched values
    expect(find.text('MG Road Main Branch, Bengaluru'), findsWidgets);
    expect(find.text('Sireesha Bandaru'), findsOneWidget);
    expect(find.text('VERIFIED'), findsOneWidget);

    // 4. Verify & Link Bank Account submission
    final submitBtn = find.text('Verify & Link Bank Account');
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Modal dismissed & success snackbar shown
    expect(find.text('Link Bank Account'), findsNothing);
    expect(find.textContaining('linked successfully!'), findsOneWidget);
  });
}
