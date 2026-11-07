import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/services/cache_service.dart';
import 'package:finomos/features/notifications/providers/notification_provider.dart';
import 'package:finomos/features/notifications/presentation/notifications_screen.dart';
import 'package:finomos/features/income_tracking/domain/income_models.dart';
import 'package:finomos/features/income_tracking/providers/income_provider.dart';
import 'package:finomos/features/income_tracking/presentation/income_tracking_screen.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';
import 'package:finomos/features/expense_tracking/providers/expense_provider.dart';
import 'package:finomos/features/expense_tracking/presentation/expense_tracking_screen.dart';

void main() {
  setUp(() {
    LocalCacheService().remove('deleted_notification_ids');
    LocalCacheService().remove('saved_notification_ids');
    LocalCacheService().remove('app_notifications');
    LocalCacheService().remove('cached_notifications');
    // Seed a test mobile number and mark SMS as allowed so the
    // NotificationsScreen shows SMS cards instead of the "Allow SMS" banner.
    LocalCacheService().save('user_mobile_number', '9876543210');
    LocalCacheService().save('sms_allowed_9876543210', true);
    LocalCacheService().save('sms_tracking_enabled', true);
  });

  tearDown(() {
    LocalCacheService().remove('deleted_notification_ids');
    LocalCacheService().remove('saved_notification_ids');
    LocalCacheService().remove('app_notifications');
    LocalCacheService().remove('cached_notifications');
    LocalCacheService().remove('user_mobile_number');
    LocalCacheService().remove('sms_allowed_9876543210');
    LocalCacheService().remove('sms_tracking_enabled');
  });
  group('SMS Notifications Provider Unit Tests', () {
    test('Initial state contains seeded SMS notifications for Credit, Debit, FD, Promotion', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(notificationsProvider);
      expect(state.notifications.isNotEmpty, true);
      expect(state.smsCount, greaterThanOrEqualTo(5));
      expect(state.savedCount, 0);

      final creditSms = state.notifications.firstWhere((n) => n.isCreditSms);
      expect(creditSms.bankName, 'HDFC Bank');
      expect(creditSms.amount, 85000.0);
      expect(creditSms.smsCategory, 'Credit');

      final debitSms = state.notifications.firstWhere((n) => n.isDebitSms);
      expect(debitSms.amount, 450.0);
      expect(debitSms.smsCategory, 'Debit');

      final fdSms = state.notifications.firstWhere((n) => n.isFixedDepositSms);
      expect(fdSms.amount, 100000.0);
      expect(fdSms.smsCategory, 'Fixed Deposit');

      final promoSms = state.notifications.firstWhere((n) => n.isPromotionSms);
      expect(promoSms.smsCategory, 'Promotion');
    });

    test('toggleSaveNotification saves and unsaves SMS notification', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationsProvider.notifier);
      final initial = container.read(notificationsProvider);
      final target = initial.notifications.firstWhere((n) => n.isSms);

      expect(target.isSaved, false);

      notifier.toggleSaveNotification(target.id);
      final afterSave = container.read(notificationsProvider);
      final savedItem = afterSave.notifications.firstWhere((n) => n.id == target.id);
      expect(savedItem.isSaved, true);
      expect(afterSave.savedCount, 1);

      notifier.toggleSaveNotification(target.id);
      final afterUnsave = container.read(notificationsProvider);
      final unsavedItem = afterUnsave.notifications.firstWhere((n) => n.id == target.id);
      expect(unsavedItem.isSaved, false);
      expect(afterUnsave.savedCount, 0);
    });

    test('deleteNotification removes notification from screen', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationsProvider.notifier);
      final initial = container.read(notificationsProvider);
      final target = initial.notifications.firstWhere((n) => n.isSms);
      final initialTotal = initial.totalAlerts;

      notifier.deleteNotification(target.id);
      final afterDelete = container.read(notificationsProvider);
      expect(afterDelete.notifications.any((n) => n.id == target.id), false);
      expect(afterDelete.totalAlerts, initialTotal - 1);
    });

    test('Filter chips update selectedFilter correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notificationsProvider.notifier);
      expect(container.read(notificationsProvider).selectedFilter, 'All');

      notifier.setFilter('Credits');
      expect(container.read(notificationsProvider).selectedFilter, 'Credits');

      notifier.setFilter('Debits');
      expect(container.read(notificationsProvider).selectedFilter, 'Debits');

      notifier.setFilter('Fixed Deposits');
      expect(container.read(notificationsProvider).selectedFilter, 'Fixed Deposits');

      notifier.setFilter('Promotions');
      expect(container.read(notificationsProvider).selectedFilter, 'Promotions');

      notifier.setFilter('Saved');
      expect(container.read(notificationsProvider).selectedFilter, 'Saved');
    });
  });

  group('Income Tracking Detected Inflow (Short Box) Unit Tests', () {
    test('addDetectedInflow, approveDetectedInflow and dismissDetectedInflow work as expected', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final incomeNotifier = container.read(incomeProvider.notifier);
      final initialDetectedCount = container.read(incomeProvider).detectedInflows.length;

      const testInflow = DetectedInflow(
        detectedId: 'sms_test_inflow_01',
        amount: 85000.0,
        detectedSource: 'Salary Credit - TechCorp Global',
        bankAccount: 'HDFC Bank XX4589',
        date: '2026-11-03',
        suggestedCategory: 'Salary',
        detectionChannel: 'SMS Notification',
        confidenceScore: 0.98,
      );

      incomeNotifier.addDetectedInflow(testInflow);
      var current = container.read(incomeProvider);
      expect(current.detectedInflows.length, initialDetectedCount + 1);
      expect(current.detectedInflows.first.detectedId, 'sms_test_inflow_01');

      // Dismiss test
      incomeNotifier.dismissDetectedInflow('sms_test_inflow_01');
      current = container.read(incomeProvider);
      expect(current.detectedInflows.any((i) => i.detectedId == 'sms_test_inflow_01'), false);

      // Add back and Approve test
      incomeNotifier.addDetectedInflow(testInflow);
      final initialEntriesCount = container.read(incomeProvider).entries.length;

      await incomeNotifier.approveDetectedInflow(testInflow);
      current = container.read(incomeProvider);
      // Inflow should be removed from detected
      expect(current.detectedInflows.any((i) => i.detectedId == 'sms_test_inflow_01'), false);
      // And added to active streams
      expect(current.entries.length, initialEntriesCount + 1);
      final approvedEntry = current.entries.first;
      expect(approvedEntry.source, testInflow.detectedSource);
      expect(approvedEntry.amount, testInflow.amount);
      expect(approvedEntry.category, 'Salary');
      expect(approvedEntry.isVerified, true);
    });
  });

  group('Expense Tracking Detected Expense (Short Box) Unit Tests', () {
    test('addDetectedExpense, approveDetectedExpense and dismissDetectedExpense work as expected', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final expenseNotifier = container.read(expenseProvider.notifier);
      final initialDetectedCount = container.read(expenseProvider).detectedExpenses.length;

      const testExpense = DetectedExpense(
        detectionId: 'sms_test_exp_01',
        amount: 450.0,
        description: 'Swiggy Food Delivery',
        merchant: 'Swiggy',
        bankAccount: 'ICICI Bank XX1029',
        date: '2026-11-03',
        suggestedCategory: 'Food & Dining',
        suggestedPriority: 'P5 - Lifestyle',
        channel: 'SMS Notification',
        paymentMode: 'Debit Card',
        isDebit: true,
        confidenceScore: 0.95,
      );

      expenseNotifier.addDetectedExpense(testExpense);
      var current = container.read(expenseProvider);
      expect(current.detectedExpenses.length, initialDetectedCount + 1);
      expect(current.detectedExpenses.first.detectionId, 'sms_test_exp_01');

      // Dismiss test
      expenseNotifier.dismissDetectedExpense('sms_test_exp_01');
      current = container.read(expenseProvider);
      expect(current.detectedExpenses.any((e) => e.detectionId == 'sms_test_exp_01'), false);

      // Add back and Approve test
      expenseNotifier.addDetectedExpense(testExpense);
      final initialExpensesCount = container.read(expenseProvider).expenses.length;

      await expenseNotifier.approveDetectedExpense(testExpense);
      current = container.read(expenseProvider);
      // Expense should be removed from detected
      expect(current.detectedExpenses.any((e) => e.detectionId == 'sms_test_exp_01'), false);
      // And added to active expenses
      expect(current.expenses.length, initialExpensesCount + 1);
      final approvedEntry = current.expenses.first;
      expect(approvedEntry.description, testExpense.description);
      expect(approvedEntry.amount, testExpense.amount);
      expect(approvedEntry.category, 'Food & Dining');
      expect(approvedEntry.paymentMode, 'Debit Card');
    });
  });

  group('Notifications Screen & Short Box Widget Tests', () {
    testWidgets('NotificationsScreen displays SMS cards with Save and Delete options below', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Screen title and stat badges
      expect(find.text('Notifications & Alerts'), findsOneWidget);
      expect(find.text('SMS Inflow'), findsOneWidget);

      // Verify Save and Delete options exist below cards
      expect(find.text('Save'), findsWidgets);
      expect(find.text('Delete'), findsWidgets);

      // Tap the first Save button
      final saveButtons = find.widgetWithText(OutlinedButton, 'Save');
      expect(saveButtons, findsWidgets);
      await tester.tap(saveButtons.first);
      await tester.pumpAndSettle();

      // Verify that after selecting Save, saved count increments
      final updatedState = container.read(notificationsProvider);
      expect(updatedState.savedCount, greaterThan(0));

      // Test Delete button action
      final deleteButtons = find.widgetWithText(OutlinedButton, 'Delete');
      expect(deleteButtons, findsWidgets);
      final countBeforeDelete = updatedState.notifications.length;
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      final stateAfterDelete = container.read(notificationsProvider);
      expect(stateAfterDelete.notifications.length, countBeforeDelete - 1);
    });

    testWidgets('IncomeTrackingScreen renders detected Short Box with Approve and Delete buttons', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const testInflow = DetectedInflow(
        detectedId: 'sms_widget_test_inflow',
        amount: 85000.0,
        detectedSource: 'Salary Credit - TechCorp Global',
        bankAccount: 'HDFC Bank XX4589',
        date: '2026-11-03',
        suggestedCategory: 'Salary',
        detectionChannel: 'SMS Notification',
        confidenceScore: 0.99,
      );

      container.read(incomeProvider.notifier).addDetectedInflow(testInflow);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: IncomeTrackingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Short Box renders
      expect(find.textContaining('TechCorp Global'), findsWidgets);
      expect(find.textContaining('+₹85,000'), findsWidgets);
      expect(find.widgetWithText(OutlinedButton, 'Delete'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Approve'), findsOneWidget);

      // Tap Approve
      await tester.tap(find.widgetWithText(ElevatedButton, 'Approve'));
      await tester.pumpAndSettle();

      // Inflow should be approved into active entries and removed from short box
      expect(container.read(incomeProvider).detectedInflows.any((i) => i.detectedId == 'sms_widget_test_inflow'), false);
      expect(container.read(incomeProvider).entries.any((i) => i.source == testInflow.detectedSource), true);
    });

    testWidgets('ExpenseTrackingScreen renders detected Short Box with Approve and Delete buttons', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const testExpense = DetectedExpense(
        detectionId: 'sms_widget_test_exp',
        amount: 450.0,
        description: 'Swiggy Food Delivery',
        merchant: 'Swiggy',
        bankAccount: 'ICICI Bank XX1029',
        date: '2026-11-03',
        suggestedCategory: 'Food & Dining',
        suggestedPriority: 'P5 - Lifestyle',
        channel: 'SMS Notification',
        paymentMode: 'Debit Card',
        isDebit: true,
        confidenceScore: 0.95,
      );

      container.read(expenseProvider.notifier).addDetectedExpense(testExpense);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ExpenseTrackingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Short Box renders
      expect(find.textContaining('Swiggy Food Delivery'), findsWidgets);
      expect(find.textContaining('-₹450'), findsWidgets);
      expect(find.widgetWithText(OutlinedButton, 'Delete'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Approve'), findsOneWidget);

      // Tap Approve
      await tester.tap(find.widgetWithText(ElevatedButton, 'Approve'));
      await tester.pumpAndSettle();

      // Expense should be approved into active expenses and removed from short box
      expect(container.read(expenseProvider).detectedExpenses.any((e) => e.detectionId == 'sms_widget_test_exp'), false);
      expect(container.read(expenseProvider).expenses.any((e) => e.description == testExpense.description), true);
    });
  });
}
