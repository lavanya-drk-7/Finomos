import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';
import 'package:finomos/features/expense_tracking/presentation/expense_tracking_screen.dart';
import 'package:finomos/features/expense_tracking/providers/expense_provider.dart';

void main() {
  group('Expense Payment Status Domain Tests', () {
    test('Calculates Payment Success when status is SUCCESS', () {
      final entry = ExpenseEntry(
        id: 'fd_01',
        description: 'Fixed Deposit Monthly Installment',
        category: 'Fixed Deposit / RD',
        amount: 5000,
        date: '2026-11-05',
        paymentStatus: 'SUCCESS',
        recurringDayOfMonth: 5,
        isRecurring: true,
      );

      final statusInfo = entry.statusInfo;
      expect(statusInfo.status, ExpensePaymentStatus.paymentSuccess);
      expect(statusInfo.label, 'Payment Success');
      expect(statusInfo.primaryColor, const Color(0xFF059669));
    });

    test('Calculates Payment Failed when status is FAILED', () {
      final entry = ExpenseEntry(
        id: 'loan_01',
        description: 'Home Loan EMI',
        category: 'Loan & EMI',
        amount: 25000,
        date: '2026-11-05',
        paymentStatus: 'FAILED',
        recurringDayOfMonth: 5,
        isRecurring: true,
      );

      final statusInfo = entry.statusInfo;
      expect(statusInfo.status, ExpensePaymentStatus.paymentFailed);
      expect(statusInfo.label, 'Payment Failed');
      expect(statusInfo.primaryColor, const Color(0xFFDC2626));
    });

    test('Calculates Pay Immediately when status is OVERDUE', () {
      final entry = ExpenseEntry(
        id: 'fd_02',
        description: 'Recurring Deposit Monthly',
        category: 'Fixed Deposit / RD',
        amount: 5000,
        date: '2026-10-05',
        paymentStatus: 'OVERDUE',
        recurringDayOfMonth: 5,
        isRecurring: true,
      );

      final statusInfo = entry.statusInfo;
      expect(statusInfo.status, ExpensePaymentStatus.payImmediately);
      expect(statusInfo.label, 'Pay Immediately');
    });

    test('Calculates Due in 7 Days when status is DUE_SOON', () {
      final entry = ExpenseEntry(
        id: 'util_01',
        description: 'Electricity Bill',
        category: 'Utilities',
        amount: 2400,
        date: '2026-11-10',
        paymentStatus: 'DUE_SOON',
        recurringDayOfMonth: 10,
        isRecurring: true,
      );

      final statusInfo = entry.statusInfo;
      expect(statusInfo.status, ExpensePaymentStatus.dueInDays);
      expect(statusInfo.label, 'Due in 7 Days');
    });

    test('Auto-calculates status from recurringDayOfMonth when status is not explicit', () {
      final now = DateTime.now();
      // Past day in current month -> Pay Immediately
      if (now.day > 1) {
        final pastEntry = ExpenseEntry(
          id: 'past_01',
          description: 'Past Auto-Debit',
          category: 'Bills',
          amount: 1500,
          date: '2026-11-01',
          recurringDayOfMonth: now.day - 1,
          isRecurring: true,
        );
        expect(pastEntry.statusInfo.status, ExpensePaymentStatus.payImmediately);
        expect(pastEntry.statusInfo.label, 'Pay Immediately');
      }

      // Today -> Due Today
      final todayEntry = ExpenseEntry(
        id: 'today_01',
        description: 'Today Auto-Debit',
        category: 'Bills',
        amount: 1500,
        date: '2026-11-03',
        recurringDayOfMonth: now.day,
        isRecurring: true,
      );
      expect(todayEntry.statusInfo.status, ExpensePaymentStatus.dueInDays);
      expect(todayEntry.statusInfo.label, 'Due Today');
    });
  });

  group('ExpenseTrackingScreen Payment Status Widget Tests', () {
    testWidgets('Displays status badge, recurring day, and updates via Pay Now action', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Create a test container with custom initial expense
      final container = ProviderContainer();
      final fdExpense = ExpenseEntry(
        id: 'test_fd_5000',
        description: 'Fixed Deposit HDFC',
        category: 'Fixed Deposit / RD',
        amount: 5000,
        date: '5th of month',
        bankAccount: 'HDFC Bank ••••4587',
        paymentStatus: 'OVERDUE',
        recurringDayOfMonth: 5,
        isRecurring: true,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ExpenseTrackingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Add the FD expense directly to state
      container.read(expenseProvider.notifier).addExpense(fdExpense);
      await tester.pumpAndSettle();

      // Navigate to Expense Sources tab (Tab 1)
      await tester.tap(find.text('Expense Sources'));
      await tester.pumpAndSettle();

      // Verify Fixed Deposit source is shown
      expect(find.text('Fixed Deposit HDFC'), findsWidgets);
      expect(find.text('₹5,000'), findsWidgets);

      // Verify Pay Immediately status badge is shown
      expect(find.text('Pay Immediately'), findsWidgets);

      // Verify recurring day scheduling text
      expect(find.text('Scheduled for 5th of every month'), findsWidgets);

      // Verify "Pay Now" action button is present for overdue expense
      expect(find.text('Pay Now'), findsWidgets);

      // Tap "Pay Now"
      await tester.tap(find.text('Pay Now').first);
      await tester.pumpAndSettle();

      // Status should update to Payment Success
      expect(find.text('Payment Success'), findsWidgets);
      expect(find.textContaining('Marked "Fixed Deposit HDFC" as Payment Success!'), findsOneWidget);
    });

    testWidgets('Supports adding a Fixed Deposit with 5th date auto-debit via Add Sheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ExpenseTrackingScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Expense Sources tab
      await tester.tap(find.text('Expense Sources'));
      await tester.pumpAndSettle();

      // Tap Add New Expense Source
      await tester.tap(find.text('Add New Expense Source'));
      await tester.pumpAndSettle();

      // Verify Record New Expense modal opens
      expect(find.text('Record New Expense'), findsOneWidget);

      // Enter Amount: 5000
      final amountField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Expense Amount (₹)',
      );
      await tester.enterText(amountField, '5000');

      // Enter Description: FD Monthly Debit
      final descField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Description / Purpose',
      );
      await tester.enterText(descField, 'FD Monthly Debit');
      await tester.pumpAndSettle();

      // Select Category "Fixed Deposit / RD"
      final categoryDropdown = find.byWidgetPredicate(
        (w) => w is DropdownButtonFormField<String> && w.decoration.labelText == 'Category',
      );
      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fixed Deposit / RD').last);
      await tester.pumpAndSettle();

      // Toggle Monthly Auto-Debit Schedule switch
      final scheduleSwitch = find.byType(Switch);
      await tester.tap(scheduleSwitch.first);
      await tester.pumpAndSettle();

      // Verify Monthly Debit Day dropdown appears
      expect(find.text('Monthly Debit Day'), findsOneWidget);

      // Tap Save (Record Outflow button)
      final recordButton = find.widgetWithText(ElevatedButton, 'Record Outflow');
      await tester.tap(recordButton);
      await tester.pumpAndSettle();

      // Switch back to Expense Sources tab if needed and verify added item
      await tester.tap(find.text('Expense Sources'));
      await tester.pumpAndSettle();

      expect(find.text('FD Monthly Debit'), findsWidgets);
      expect(find.text('Fixed Deposit / RD'), findsWidgets);
      expect(find.text('Scheduled for 5th of every month'), findsWidgets);
    });
  });
}

