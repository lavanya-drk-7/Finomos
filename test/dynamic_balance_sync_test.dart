import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/bank_aggregation/providers/bank_aggregation_provider.dart';
import 'package:finomos/features/income_tracking/providers/income_provider.dart';
import 'package:finomos/features/income_tracking/domain/income_models.dart';
import 'package:finomos/features/expense_tracking/providers/expense_provider.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';
import 'package:finomos/features/budget_management/providers/budget_provider.dart';
import 'package:finomos/features/budget_management/domain/budget_models.dart';
import 'package:finomos/core/services/cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocalCacheService().remove('bank_accounts');
    LocalCacheService().remove('user_liquid_cash_amount');
    LocalCacheService().remove('user_liquid_cash_entries');
    LocalCacheService().remove('deleted_bank_account_ids');
    LocalCacheService().remove('expenses_entries');
    LocalCacheService().remove('deleted_expense_ids');
    LocalCacheService().remove('income_entries');
    LocalCacheService().remove('deleted_income_ids');
    LocalCacheService().remove('budgets_list');
    LocalCacheService().remove('deleted_budget_ids');
  });

  test('User links bank account with ₹500 balance, adds ₹500 income -> balance updates to ₹1,000, adds ₹300 expense -> balance updates to ₹700', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final bankNotifier = container.read(bankAggregationProvider.notifier);

    // 1. Initial state: 0 bank accounts, 0 balance
    expect(container.read(bankAggregationProvider).bankAccounts.isEmpty, isTrue);
    expect(container.read(bankAggregationProvider).totalBankCash, equals(0.0));

    // 2. User adds bank account with available balance = ₹500
    bankNotifier.addBankAccount(
      bankName: 'HDFC Bank',
      accountType: 'Savings Account',
      maskedAccountNumber: '••••4587',
      ifscCode: 'HDFC0001234',
      accountHolder: 'Test User',
      currentBalance: 500.0,
    );

    var bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.length, equals(1));
    expect(bankState.bankAccounts.first.availableBalance, equals(500.0));
    expect(bankState.totalBankCash, equals(500.0));

    // 3. User adds income of ₹500 to that account
    final incomeNotifier = container.read(incomeProvider.notifier);
    await incomeNotifier.addIncome(
      const IncomeEntry(
        id: 'inc_test_1',
        source: 'Consulting Fee',
        category: 'Consulting',
        amount: 500.0,
        date: '05 Nov 2026',
        frequency: 'One-Time',
        bankAccount: 'HDFC Bank ••••4587',
      ),
    );

    // Verify balance dynamically updated to ₹1,000
    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.first.availableBalance, equals(1000.0));
    expect(bankState.totalBankCash, equals(1000.0));

    // 4. User adds expense of ₹300 from that account
    final expenseNotifier = container.read(expenseProvider.notifier);
    await expenseNotifier.addExpense(
      const ExpenseEntry(
        id: 'exp_test_1',
        description: 'Swiggy Dinner',
        category: 'Food & Dining',
        amount: 300.0,
        date: '05 Nov 2026',
        paymentMode: 'UPI',
        bankAccount: 'HDFC Bank ••••4587',
      ),
    );

    // Verify balance dynamically decreased to ₹700
    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.first.availableBalance, equals(700.0));
    expect(bankState.totalBankCash, equals(700.0));

    // 5. User deletes the ₹300 expense (e.g. refunded or cancelled)
    await expenseNotifier.deleteExpense('exp_test_1');

    // Verify balance restored to ₹1,000
    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.first.availableBalance, equals(1000.0));
    expect(bankState.totalBankCash, equals(1000.0));

    // 6. User deletes the ₹500 income
    await incomeNotifier.deleteIncome('inc_test_1');

    // Verify balance restored to initial ₹500
    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.first.availableBalance, equals(500.0));
    expect(bankState.totalBankCash, equals(500.0));
  });

  test('Exact User Scenario: Bank balance 500, receives 200 -> 700, spends 200 -> 500 (NOT 300), and budget reflects spending', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final bankNotifier = container.read(bankAggregationProvider.notifier);
    final incomeNotifier = container.read(incomeProvider.notifier);
    final expenseNotifier = container.read(expenseProvider.notifier);
    final budgetNotifier = container.read(budgetProvider.notifier);

    // 1. User configures a budget for Food & Dining of 1,000
    budgetNotifier.seedBudgets([
      const BudgetItem(
        id: 'b_food_test',
        name: 'Dining Out',
        type: 'Category-wise Budget',
        category: 'Food & Dining',
        amount: 1000.0,
        spent: 0.0,
        startDate: '2026-11-01',
        endDate: '2026-11-30',
      ),
    ]);

    expect(container.read(budgetProvider).budgets.first.spent, equals(0.0));
    expect(container.read(budgetProvider).budgets.first.remaining, equals(1000.0));

    // 2. Add bank account with 500 balance (like Union Bank 0087)
    bankNotifier.addBankAccount(
      bankName: 'Union Bank of India',
      accountType: 'Savings Account',
      maskedAccountNumber: '••••0087',
      ifscCode: 'UBIN0823554',
      accountHolder: 'Sireesha Bandaru',
      currentBalance: 500.0,
    );

    var bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.first.availableBalance, equals(500.0));
    expect(bankState.totalBankCash, equals(500.0));

    // 3. User receives 200 to that account
    await incomeNotifier.addIncome(
      const IncomeEntry(
        id: 'inc_test_200',
        source: 'Client Inflow',
        category: 'Consulting',
        amount: 200.0,
        date: '05 Nov 2026',
        frequency: 'One-Time',
        bankAccount: 'Union Bank of India •••• 0087',
      ),
    );

    // Balance MUST be 700 (500 + 200)
    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.first.availableBalance, equals(700.0));
    expect(bankState.totalBankCash, equals(700.0));

    // 4. User spends 200 from that account
    await expenseNotifier.addExpense(
      const ExpenseEntry(
        id: 'exp_test_200',
        description: 'Dinner with friends',
        category: 'Food & Dining',
        amount: 200.0,
        date: '05 Nov 2026',
        paymentMode: 'UPI',
        bankAccount: 'Union Bank of India •••• 0087',
      ),
    );

    // Balance MUST be 500 (700 - 200 = 500, NOT 300!)
    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.first.availableBalance, equals(500.0));
    expect(bankState.totalBankCash, equals(500.0));

    // Budget spent MUST be 200 and remaining 800
    var budgetState = container.read(budgetProvider);
    expect(budgetState.budgets.first.spent, equals(200.0));
    expect(budgetState.budgets.first.remaining, equals(800.0));

    // 5. If user deletes the 200 expense, balance returns to 700 and budget spent returns to 0
    await expenseNotifier.deleteExpense('exp_test_200');
    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.first.availableBalance, equals(700.0));

    budgetState = container.read(budgetProvider);
    expect(budgetState.budgets.first.spent, equals(0.0));
    expect(budgetState.budgets.first.remaining, equals(1000.0));
  });

  test('Adding income or expense to existing bank account never adds an extra bank field - updates existing bank only', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final bankNotifier = container.read(bankAggregationProvider.notifier);
    final incomeNotifier = container.read(incomeProvider.notifier);
    final expenseNotifier = container.read(expenseProvider.notifier);

    // 1. User adds bank account with 500 balance
    bankNotifier.addBankAccount(
      bankName: 'Union Bank of India',
      accountType: 'Savings Account',
      maskedAccountNumber: '••••0087',
      rawAccountNumber: '0087',
      ifscCode: 'UBIN0823554',
      accountHolder: 'Sireesha Bandaru',
      currentBalance: 500.0,
    );

    var bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.length, equals(1), reason: 'Must have exactly 1 bank account');
    expect(bankState.bankAccounts.first.availableBalance, equals(500.0));

    // 2. User adds income of 500 to that SAME bank account
    await incomeNotifier.addIncome(
      const IncomeEntry(
        id: 'inc_test_same_bank_1',
        source: 'Consulting Income',
        category: 'Consulting',
        amount: 500.0,
        date: '06 Nov 2026',
        frequency: 'One-Time',
        bankAccount: 'Union Bank of India ••••0087',
      ),
    );

    // CRITICAL: bankAccounts.length MUST STILL BE 1 (NO EXTRA FIELD IN BANK)
    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.length, equals(1), reason: 'Must NOT add extra field in bank when adding income!');
    expect(bankState.bankAccounts.first.availableBalance, equals(1000.0), reason: 'Existing bank balance must be updated to 1000');

    // 3. User adds another income of 300 to that SAME bank account
    await incomeNotifier.addIncome(
      const IncomeEntry(
        id: 'inc_test_same_bank_2',
        source: 'Bonus Income',
        category: 'Bonus',
        amount: 300.0,
        date: '06 Nov 2026',
        frequency: 'One-Time',
        bankAccount: 'Union Bank of India •••• 0087',
      ),
    );

    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.length, equals(1), reason: 'Must NOT add extra field in bank on second income!');
    expect(bankState.bankAccounts.first.availableBalance, equals(1300.0));

    // 4. User adds expense of 400 from that SAME bank account
    await expenseNotifier.addExpense(
      const ExpenseEntry(
        id: 'exp_test_same_bank_1',
        description: 'Office Supplies',
        category: 'Shopping',
        amount: 400.0,
        date: '06 Nov 2026',
        bankAccount: 'Union Bank of India ••••0087',
      ),
    );

    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.length, equals(1), reason: 'Must NOT add extra field in bank when adding expense!');
    expect(bankState.bankAccounts.first.availableBalance, equals(900.0));

    // 5. User re-enters or updates the same bank account with same account number 0087
    bankNotifier.addBankAccount(
      bankName: 'Union Bank of India',
      accountType: 'Savings Account',
      maskedAccountNumber: '••••0087',
      rawAccountNumber: '0087',
      ifscCode: 'UBIN0823554',
      accountHolder: 'Sireesha Bandaru',
      currentBalance: 900.0,
    );

    bankState = container.read(bankAggregationProvider);
    expect(bankState.bankAccounts.length, equals(1), reason: 'Re-adding same account number must update, NOT create extra field!');
    expect(bankState.bankAccounts.first.availableBalance, equals(900.0));
  });
}
