import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/features/expense_tracking/presentation/expense_tracking_screen.dart';
import 'package:finomos/features/income_tracking/presentation/income_tracking_screen.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';
import 'package:finomos/features/expense_tracking/providers/expense_provider.dart';
import 'package:finomos/features/income_tracking/domain/income_models.dart';
import 'package:finomos/features/income_tracking/providers/income_provider.dart';

class _TestExpenseNotifier extends ExpenseNotifier {
  @override
  ExpenseState build() {
    return const ExpenseState(
      expenses: [
        ExpenseEntry(
          id: 'exp_1',
          description: 'Apartment Rent (Koramangala)',
          category: 'Housing',
          amount: 22000.0,
          date: '01 Aug 2025',
          paymentMode: 'UPI',
          priority: 'P1 - Survival',
          merchant: 'Owner Transfer',
          bankAccount: 'HDFC Bank ••••4587',
          documentName: 'rent_agreement_koramangala.pdf',
        ),
      ],
      isLoading: false,
    );
  }
}

class _TestIncomeNotifier extends IncomeNotifier {
  @override
  IncomeState build() {
    return const IncomeState(
      entries: [
        IncomeEntry(
          id: 'inc_1',
          source: 'Tech Corp India Pvt Ltd',
          category: 'Salary',
          type: 'Active',
          amount: 85000.0,
          date: '25 Aug 2025',
          frequency: 'Monthly',
          bankAccount: 'HDFC Bank ••••4587',
          documentName: 'salary_slip_aug_2025.pdf',
        ),
      ],
      isLoading: false,
    );
  }
}

void main() {
  testWidgets(
    'ExpenseTrackingScreen: selecting a transaction displays full details with Download Invoice button and downloads PDF',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseProvider.overrideWith(() => _TestExpenseNotifier()),
          ],
          child: const MaterialApp(home: ExpenseTrackingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find an expense transaction card on Tab 0 (e.g., -₹22,000 for rent)
      final expenseAmountFinder = find.text('-₹22,000');
      expect(expenseAmountFinder, findsOneWidget);

      // Tap on the expense transaction card to select it
      await tester.tap(expenseAmountFinder);
      await tester.pumpAndSettle();

      // Verify that the whole transaction details are displayed in that screen
      expect(find.text('Transaction Details'), findsOneWidget);
      expect(
        find.text('Official Expense Record & Tax Invoice'),
        findsOneWidget,
      );
      expect(find.text('TOTAL AMOUNT PAID'), findsOneWidget);
      expect(find.text('TRANSACTION SUMMARY'), findsOneWidget);
      expect(find.text('Apartment Rent (Koramangala)'), findsWidgets);
      expect(find.text('Housing'), findsWidgets);
      expect(find.text('Download Invoice'), findsOneWidget);
      expect(find.text('Preview Invoice Document'), findsOneWidget);

      // Tap Download Invoice button
      await tester.tap(find.text('Download Invoice'));
      await tester.pumpAndSettle();

      // Verify download success snackbar
      expect(find.textContaining('to device'), findsWidgets);

      // Test Preview Invoice Document button
      await tester.tap(find.text('Preview Invoice Document'));
      await tester.pumpAndSettle();

      expect(find.text('Uploaded Verification Document'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close preview dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Close transaction details sheet
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(find.text('Transaction Details'), findsNothing);
    },
  );

  testWidgets(
    'IncomeTrackingScreen: selecting an income transaction displays full details with Download Invoice button and downloads PDF',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            incomeProvider.overrideWith(() => _TestIncomeNotifier()),
          ],
          child: const MaterialApp(home: IncomeTrackingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find an income transaction card on Tab 0 (e.g., +₹85,000 for Tech Corp India Pvt Ltd)
      final incomeAmountFinder = find.text('+₹85,000');
      expect(incomeAmountFinder, findsOneWidget);

      // Tap on the income transaction card to select it
      await tester.tap(incomeAmountFinder);
      await tester.pumpAndSettle();

      // Verify that the whole transaction details are displayed in that screen
      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('Official Income Receipt & Voucher'), findsOneWidget);
      expect(find.text('TOTAL AMOUNT RECEIVED'), findsOneWidget);
      expect(find.text('INCOME SUMMARY'), findsOneWidget);
      expect(find.text('Tech Corp India Pvt Ltd'), findsWidgets);
      expect(find.text('Salary'), findsWidgets);
      expect(find.text('Download Invoice'), findsOneWidget);
      expect(find.text('Preview Invoice Document'), findsOneWidget);

      // Tap Download Invoice button
      await tester.tap(find.text('Download Invoice'));
      await tester.pumpAndSettle();

      // Verify download success snackbar
      expect(find.textContaining('to device'), findsWidgets);

      // Test Preview Invoice Document button
      await tester.tap(find.text('Preview Invoice Document'));
      await tester.pumpAndSettle();

      expect(find.text('Uploaded Verification Document'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close preview dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Close transaction details sheet
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(find.text('Transaction Details'), findsNothing);
    },
  );
}
