import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/transaction_detection/domain/detected_transaction_model.dart';
import 'package:finomos/features/transaction_detection/domain/sms_parser_engine.dart';
import 'package:finomos/features/transaction_detection/providers/transaction_detection_provider.dart';
import 'package:finomos/features/budget_management/domain/budget_models.dart';
import 'package:finomos/features/budget_management/providers/budget_provider.dart';
import 'package:finomos/features/expense_tracking/providers/expense_provider.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';
import 'package:finomos/features/income_tracking/providers/income_provider.dart';

void main() {
  group('SMS Detection & Parser Engine Tests', () {
    test('Scenario 1: ₹1,000 restaurant debit from HDFC Bank', () {
      const sms = 'Rs. 1,000 debited from your HDFC Bank account ••••4587 to VPA restaurant@upi. Ref 429182391024';
      final result = SmsParserEngine.parse(sms);

      expect(result.isSuccess, isTrue);
      final txn = result.transaction!;
      expect(txn.amount, 1000.0);
      expect(txn.type, TransactionClassification.expense);
      expect(txn.bankName, contains('HDFC'));
      expect(txn.accountIdentifier, '••••4587');
      expect(txn.suggestedCategory, 'Food & Dining');
      expect(txn.referenceId, '429182391024');
    });

    test('Scenario 3: ₹30,000 salary credit to SBI Bank', () {
      const sms = 'Your A/C XXXXXX4821 is credited by Rs 30,000.00 on 15/10/26 by transfer from TECH CORP SALARY. Ref 392817263518';
      final result = SmsParserEngine.parse(sms);

      expect(result.isSuccess, isTrue);
      final txn = result.transaction!;
      expect(txn.amount, 30000.0);
      expect(txn.type, TransactionClassification.income);
      expect(txn.bankName, contains('State Bank of India'));
      expect(txn.suggestedCategory, 'Salary');
      expect(txn.referenceId, '392817263518');
    });

    test('Scenario 7: Internal self transfer is classified as transfer', () {
      const sms = 'Rs 5,000 transferred between your accounts from HDFC Bank 4587 to SBI 4821. Ref 882918239102';
      final result = SmsParserEngine.parse(sms);

      expect(result.isSuccess, isTrue);
      final txn = result.transaction!;
      expect(txn.amount, 5000.0);
      expect(txn.type, TransactionClassification.transfer);
    });

    test('Scenario 8: Refund is classified as refund', () {
      const sms = 'Rs. 1,500 refund credited to your HDFC Bank account ••••4587 from Amazon India. Ref 991827361829';
      final result = SmsParserEngine.parse(sms);

      expect(result.isSuccess, isTrue);
      final txn = result.transaction!;
      expect(txn.amount, 1500.0);
      expect(txn.type, TransactionClassification.refund);
    });

    test('Scenario 9: Duplicate SMS detection rejects repeated transaction', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const sms = 'Rs. 1,000 debited from your HDFC Bank account ••••4587. Ref DUP99881122';
      final first = container.read(transactionDetectionProvider.notifier).processIncomingSms(sms);
      expect(first.isSuccess, isTrue);

      // Attempting to ingest the exact same SMS reference again
      final second = container.read(transactionDetectionProvider.notifier).processIncomingSms(sms);
      expect(second.isSuccess, isFalse);
      expect(second.errorMessage, contains('Duplicate transaction detected'));
    });
  });

  group('Budget Management & Overspending Alert Tests', () {
    test('Scenario 4 & 5: ₹10,000 budget decreases to ₹9,000 after ₹1,000 expense & updates on second expense', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial food budget is ₹10,000 with spent = ₹0
      var state = container.read(budgetProvider);
      final foodBudget = state.budgets.firstWhere((b) => b.category == 'Food & Dining');
      expect(foodBudget.amount, 10000.0);
      expect(foodBudget.spent, 0.0);
      expect(foodBudget.remaining, 10000.0);

      // Apply ₹1,000 expense
      container.read(budgetProvider.notifier).applyExpense(
            category: 'Food & Dining',
            amount: 1000.0,
            description: 'Restaurant bill',
          );

      state = container.read(budgetProvider);
      final updatedFood = state.budgets.firstWhere((b) => b.category == 'Food & Dining');
      expect(updatedFood.spent, 1000.0);
      expect(updatedFood.remaining, 9000.0);
      expect(updatedFood.utilizationPercentage, 10.0);

      // Apply second eligible expense of ₹1,500
      container.read(budgetProvider.notifier).applyExpense(
            category: 'Food & Dining',
            amount: 1500.0,
            description: 'Cafe coffee',
          );

      state = container.read(budgetProvider);
      final secondUpdate = state.budgets.firstWhere((b) => b.category == 'Food & Dining');
      expect(secondUpdate.spent, 2500.0);
      expect(secondUpdate.remaining, 7500.0);
      expect(secondUpdate.utilizationPercentage, 25.0);
    });

    test('Spending in other category (Groceries) does NOT deduct from Food & Dining budget', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(budgetProvider.notifier).applyExpense(
            category: 'Groceries',
            amount: 2000.0,
            description: 'Supermarket vegetables',
          );

      final state = container.read(budgetProvider);
      final foodBudget = state.budgets.firstWhere((b) => b.category == 'Food & Dining');
      expect(foodBudget.spent, 0.0); // Food & Dining remains untouched!

      final grocBudget = state.budgets.firstWhere((b) => b.category == 'Groceries');
      expect(grocBudget.spent, 2000.0);
    });

    test('Scenario 6: Spending ₹11,000 against ₹10,000 budget triggers prominent red overspending alert for ₹1,000', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final alert = container.read(budgetProvider.notifier).applyExpense(
            category: 'Food & Dining',
            amount: 11000.0,
            description: 'Banquet Luxury Dining',
          );

      expect(alert, isNotNull);
      expect(alert!.level, BudgetAlertLevel.exceeded);
      expect(alert.title, 'Budget Exceeded!');
      expect(alert.overspentAmount, 1000.0);
      expect(alert.message, contains('exceeded your budget by ₹1000'));

      final state = container.read(budgetProvider);
      final foodBudget = state.budgets.firstWhere((b) => b.category == 'Food & Dining');
      expect(foodBudget.isExceeded, isTrue);
      expect(foodBudget.overspentAmount, 1000.0);
    });

    test('Scenario 10 & 11: Deleting or recalculating expenses updates budget totals correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final expenses = [
        const ExpenseEntry(
          id: 'test_exp_1',
          description: 'Lunch',
          category: 'Food',
          amount: 800.0,
          date: '15 Oct 2026',
        ),
        const ExpenseEntry(
          id: 'test_exp_2',
          description: 'Dinner',
          category: 'Food',
          amount: 1200.0,
          date: '16 Oct 2026',
        ),
      ];

      container.read(budgetProvider.notifier).recalculateFromExpenses(expenses);
      var state = container.read(budgetProvider);
      var food = state.budgets.firstWhere((b) => b.category == 'Food & Dining');
      expect(food.spent, 2000.0);

      // Delete one expense
      final remaining = expenses.sublist(1);
      container.read(budgetProvider.notifier).recalculateFromExpenses(remaining);
      state = container.read(budgetProvider);
      food = state.budgets.firstWhere((b) => b.category == 'Food & Dining');
      expect(food.spent, 1200.0);
    });
  });

  group('End-to-End Transaction Confirmation Tests', () {
    test('Scenario 2: Confirming expense persists in expenseProvider and updates budget', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialExpenses = container.read(expenseProvider).expenses.length;

      container.read(transactionDetectionProvider.notifier).confirmAsExpense(
            transactionId: 'txn_init_1',
            amount: 1000.0,
            category: 'Food & Dining',
            bankAccount: 'HDFC Bank ••••4587',
            paymentMode: 'UPI',
            merchant: 'Toit Restaurant',
            description: 'Toit Restaurant Dinner',
            notes: 'Team dinner',
            date: '15 Oct 2026',
            documentName: 'receipt.pdf',
            documentPath: '/path/to/receipt.pdf',
          );

      // Verify saved in expenseProvider
      final updatedExpenses = container.read(expenseProvider).expenses;
      expect(updatedExpenses.length, initialExpenses + 1);
      final savedExpense = updatedExpenses.first;
      expect(savedExpense.amount, 1000.0);
      expect(savedExpense.category, 'Food & Dining');
      expect(savedExpense.merchant, 'Toit Restaurant');
      expect(savedExpense.documentName, 'receipt.pdf');

      // Verify budget updated
      final foodBudget = container
          .read(budgetProvider)
          .budgets
          .firstWhere((b) => b.category == 'Food & Dining');
      expect(foodBudget.spent, 1000.0);
      expect(foodBudget.remaining, 9000.0);
    });

    test('Confirming income persists in incomeProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialCount = container.read(incomeProvider).entries.length;

      container.read(transactionDetectionProvider.notifier).confirmAsIncome(
            transactionId: 'txn_inc_test',
            amount: 30000.0,
            category: 'Salary',
            bankAccount: 'SBI ••••4821',
            source: 'Tech Corp Salary',
            notes: 'October monthly salary',
            date: '15 Oct 2026',
          );

      final updatedIncomes = container.read(incomeProvider).entries;
      expect(updatedIncomes.length, initialCount + 1);
      final saved = updatedIncomes.first;
      expect(saved.amount, 30000.0);
      expect(saved.source, 'Tech Corp Salary');
      expect(saved.category, 'Salary');
    });

    test('Scenario 13: Denying SMS permissions does not break manual transaction entry', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Simulate user denying SMS permission
      container.read(transactionDetectionProvider.notifier).updatePermissionStatus(false);
      final detectionState = container.read(transactionDetectionProvider);
      expect(detectionState.isPermissionGranted, isFalse);

      // Manual expense creation proceeds normally without throwing
      final initialExpenses = container.read(expenseProvider).expenses.length;
      container.read(expenseProvider.notifier).addExpense(
            const ExpenseEntry(
              id: 'manual_exp_1',
              description: 'Manual Groceries',
              category: 'Groceries',
              amount: 500.0,
              date: '15 Oct 2026',
            ),
          );
      expect(container.read(expenseProvider).expenses.length, initialExpenses + 1);
    });

    test('Scenario 15: Budget alerts are not repeatedly generated during ordinary refreshes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger initial crossing
      final alert1 = container.read(budgetProvider.notifier).applyExpense(
            category: 'Food & Dining',
            amount: 11000.0,
            description: 'Overspending banquet',
          );
      expect(alert1, isNotNull);
      expect(alert1!.level, BudgetAlertLevel.exceeded);

      // Next ordinary refresh with no threshold change
      final budget = container.read(budgetProvider).budgets.firstWhere((b) => b.category == 'Food & Dining');
      expect(budget.lastAlertTriggered, BudgetAlertLevel.exceeded);

      // Applying a non-crossing expense (already exceeded) returns null alert to avoid spamming
      final alert2 = container.read(budgetProvider.notifier).applyExpense(
            category: 'Food & Dining',
            amount: 200.0,
            description: 'Water bottle',
          );
      expect(alert2, isNull);
    });

    test('Scenario 16: Transactions are associated with correct bank, category, and period', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(transactionDetectionProvider.notifier).confirmAsExpense(
            transactionId: 'txn_assoc_test',
            amount: 750.0,
            category: 'Transportation',
            bankAccount: 'Axis Bank ••••3301',
            paymentMode: 'UPI',
            merchant: 'Uber Ride',
            description: 'Airport cab',
            notes: 'Business travel',
            date: '15 Oct 2026',
          );

      final saved = container.read(expenseProvider).expenses.firstWhere((e) => e.description == 'Airport cab');
      expect(saved.bankAccount, 'Axis Bank ••••3301');
      expect(saved.category, 'Transportation');
      expect(saved.merchant, 'Uber Ride');

      final budget = container.read(budgetProvider).budgets.firstWhere((b) => b.category == 'Transportation');
      expect(budget.period, 'October 2026');
      expect(budget.spent, 2750.0); // 2000 initial + 750 new
    });
  });
}
