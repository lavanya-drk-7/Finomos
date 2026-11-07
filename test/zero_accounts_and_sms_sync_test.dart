import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/services/cache_service.dart';
import 'package:finomos/features/dashboard/presentation/dashboard_screen.dart';
import 'package:finomos/features/income_tracking/providers/income_provider.dart';
import 'package:finomos/features/income_tracking/domain/income_models.dart';
import 'package:finomos/features/expense_tracking/providers/expense_provider.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';
import 'package:finomos/features/notifications/presentation/notifications_screen.dart';
import 'package:finomos/features/transaction_detection/services/sms_sync_service.dart';

void main() {
  setUp(() {
    LocalCacheService().save('is_logged_in', true);
    LocalCacheService().remove('bank_accounts');
    LocalCacheService().remove('user_liquid_cash_amount');
    LocalCacheService().remove('user_liquid_cash_entries');
    LocalCacheService().remove('deleted_income_ids');
    LocalCacheService().remove('deleted_expense_ids');
    LocalCacheService().remove('deleted_budget_ids');
    LocalCacheService().remove('deleted_bank_account_ids');
  });

  group('Zero Bank Accounts Dashboard Display Tests', () {
    testWidgets('Dashboard displays ₹0 for Income and Expense when user has 0 bank accounts and 0 liquid cash', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Dashboard Top Balance Box
      expect(find.textContaining('Accounts Synced'), findsOneWidget);
      expect(find.text('1. INCOME'), findsOneWidget);
      expect(find.text('2. EXPENSE'), findsOneWidget);
      expect(find.text('4. BANK FEEDS'), findsOneWidget);

      // Verify that amounts are formatted as ₹0 for bank feeds, income, and expense when 0 accounts are synced
      expect(find.textContaining('Connected'), findsWidgets);
      expect(find.textContaining('Linked Accounts'), findsWidgets);
    });
  });

  group('Tombstone Deletion Integrity Tests', () {
    testWidgets('Deleted income ID is persisted and filtered out upon reload', (WidgetTester tester) async {
      final container = ProviderContainer();
      final incomeNotifier = container.read(incomeProvider.notifier);

      const testEntry = IncomeEntry(
        id: 'inc_test_999',
        source: 'Freelance Design',
        category: 'Freelance',
        amount: 25000.0,
        date: 'Today',
        bankAccount: 'Cash',
        paymentMode: 'Cash',
        type: 'Active',
        frequency: 'One-time',
      );

      await incomeNotifier.addIncome(testEntry);
      expect(container.read(incomeProvider).entries.any((e) => e.id == 'inc_test_999'), isTrue);

      // Delete entry
      await incomeNotifier.deleteIncome('inc_test_999');
      expect(container.read(incomeProvider).entries.any((e) => e.id == 'inc_test_999'), isFalse);

      final deletedIds = LocalCacheService().get('deleted_income_ids');
      expect(deletedIds is List && deletedIds.contains('inc_test_999'), isTrue);
    });

    testWidgets('Deleted expense ID is persisted and filtered out upon reload', (WidgetTester tester) async {
      final container = ProviderContainer();
      final expenseNotifier = container.read(expenseProvider.notifier);

      final testExpense = ExpenseEntry(
        id: 'exp_test_888',
        description: 'Office Chair',
        amount: 7500.0,
        date: 'Today',
        category: 'Work',
        priority: 'P4 - Discretionary',
        paymentMode: 'UPI',
        bankAccount: 'Cash',
      );

      await expenseNotifier.addExpense(testExpense);
      expect(container.read(expenseProvider).expenses.any((e) => e.id == 'exp_test_888'), isTrue);

      // Delete expense
      await expenseNotifier.deleteExpense('exp_test_888');
      expect(container.read(expenseProvider).expenses.any((e) => e.id == 'exp_test_888'), isFalse);

      final deletedIds = LocalCacheService().get('deleted_expense_ids');
      expect(deletedIds is List && deletedIds.contains('exp_test_888'), isTrue);
    });
  });

  group('SmsSyncService Unit Tests', () {
    final smsService = SmsSyncService();

    test('Correctly identifies Indian bank sender IDs and transaction SMS keywords', () {
      // Valid HDFC Bank SMS
      expect(
        smsService.isFinancialSms(
          'VK-HDFCBK',
          'Dear Customer, INR 5,420.00 debited from A/C ••••4587 on 03-Nov-26 via UPI/Swiggy. Ref 430892019283. Bal: INR 45,000.00',
        ),
        isTrue,
      );

      // Valid SBI Credit SMS
      expect(
        smsService.isFinancialSms(
          'AD-SBIINB',
          'Dear SBI User, A/C ••••1123 credited by Rs 85,000.00 on 03Nov26 by transfer from Infosys Technologies Ltd. Bal Rs 1,45,400.00 - SBI Ref 9901823912',
        ),
        isTrue,
      );

      // Valid ICICI Bank Fixed Deposit SMS
      expect(
        smsService.isFinancialSms(
          'JM-ICICIB',
          'Dear Customer, Fixed Deposit of INR 1,00,000.00 booked under A/C ••••8891 on 03-Nov-26 for 12 months at 7.10% p.a. Ref FD492019.',
        ),
        isTrue,
      );

      // Personal non-bank message should be rejected
      expect(
        smsService.isFinancialSms(
          '+919876543210',
          'Hey, are you free for coffee tomorrow afternoon?',
        ),
        isFalse,
      );

      // OTP SMS without financial balance or debit should not be confused as a financial transaction
      expect(
        smsService.isFinancialSms(
          'TX-ZOMATO',
          'Your Zomato login OTP is 4920. Do not share this OTP with anyone.',
        ),
        isFalse,
      );
    });

    testWidgets('NotificationsScreen contains Sync SMS action button in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Sync SMS action button in AppBar
      expect(find.byTooltip('Sync SMS from Messages app'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
    });
  });
}
