import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/expense_models.dart';

class ExpenseNotifier extends Notifier<ExpenseState> {
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
          isRecurring: true,
          merchant: 'Owner Transfer',
          notes: 'Monthly residence lease',
          bankAccount: 'HDFC Bank ••••4587',
          documentName: 'rent_agreement_koramangala.pdf',
          documentPath: '/docs/rent_agreement_koramangala.pdf',
        ),
        ExpenseEntry(
          id: 'exp_2',
          description: 'Car Loan EMI',
          category: 'Bills',
          amount: 9500.0,
          date: '05 Aug 2025',
          paymentMode: 'Net Banking',
          priority: 'P3 - Obligations',
          isRecurring: true,
          merchant: 'HDFC Auto Finance',
          notes: 'Auto loan tenure month 14/36',
          bankAccount: 'HDFC Bank ••••4587',
        ),
        ExpenseEntry(
          id: 'exp_3',
          description: 'Health Insurance Premium',
          category: 'Healthcare',
          amount: 3200.0,
          date: '10 Aug 2025',
          paymentMode: 'Net Banking',
          priority: 'P2 - Protection',
          isRecurring: true,
          merchant: 'Star Health Care',
          notes: 'Annual policy monthly amortization',
          bankAccount: 'ICICI Bank ••••9021',
        ),
        ExpenseEntry(
          id: 'exp_4',
          description: 'Electricity & High-speed Wifi',
          category: 'Utilities',
          amount: 2350.0,
          date: '18 Aug 2025',
          paymentMode: 'UPI',
          priority: 'P1 - Survival',
          isRecurring: true,
          merchant: 'BESCOM & ACT Fibernet',
          notes: 'Utility mandates',
          bankAccount: 'SBI ••••1123',
        ),
        ExpenseEntry(
          id: 'exp_5',
          description: 'Supermarket Groceries & Provisions',
          category: 'Food',
          amount: 8400.0,
          date: '24 Aug 2025',
          paymentMode: 'UPI',
          priority: 'P1 - Survival',
          isRecurring: false,
          merchant: 'Nature Basket',
          notes: 'Monthly household staples',
          bankAccount: 'Axis Bank ••••3301',
        ),
        ExpenseEntry(
          id: 'exp_6',
          description: 'OTT & Cloud Subscriptions (Netflix, Prime)',
          category: 'Subscriptions',
          amount: 1199.0,
          date: '15 Aug 2025',
          paymentMode: 'Credit Card',
          priority: 'P5 - Lifestyle',
          isRecurring: true,
          merchant: 'Netflix & Spotify',
          notes: 'Digital entertainment pack',
          bankAccount: 'HDFC Bank ••••4587',
        ),
        ExpenseEntry(
          id: 'exp_7',
          description: 'Amazon Electronics & Apparel',
          category: 'Shopping',
          amount: 3450.0,
          date: '14 Aug 2025',
          paymentMode: 'Credit Card',
          priority: 'P5 - Lifestyle',
          isRecurring: false,
          merchant: 'Amazon India',
          notes: 'Home decor & headphones',
          bankAccount: 'ICICI Bank ••••9021',
        ),
        ExpenseEntry(
          id: 'exp_8',
          description: 'Weekend Dining & Socializing',
          category: 'Food',
          amount: 2800.0,
          date: '22 Aug 2025',
          paymentMode: 'Credit Card',
          priority: 'P5 - Lifestyle',
          isRecurring: false,
          merchant: 'Toit Microbrewery',
          notes: 'Team dinner & friends',
          bankAccount: 'Axis Bank ••••3301',
        ),
      ],
    );
  }

  void addExpense(ExpenseEntry entry) {
    state = state.copyWith(
      expenses: [entry, ...state.expenses],
      selectedCategoryFilter: 'All',
      selectedPriorityFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
    );
  }

  void updateExpense(ExpenseEntry entry) {
    final updated = state.expenses.map((e) => e.id == entry.id ? entry : e).toList();
    state = state.copyWith(
      expenses: updated,
      selectedCategoryFilter: 'All',
      selectedPriorityFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
    );
  }

  void deleteExpense(String id) {
    state = state.copyWith(expenses: state.expenses.where((e) => e.id != id).toList());
  }

  void resetFilters() {
    state = state.copyWith(
      selectedCategoryFilter: 'All',
      selectedPriorityFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategoryFilter: category);
  }

  void setPriorityFilter(String priority) {
    state = state.copyWith(selectedPriorityFilter: priority);
  }

  void setBankAccountFilter(String bank) {
    state = state.copyWith(selectedBankAccountFilter: bank);
  }

  void setDateFilter(String dateStr) {
    state = state.copyWith(selectedDateFilter: dateStr);
  }
}

final expenseProvider = NotifierProvider<ExpenseNotifier, ExpenseState>(() {
  return ExpenseNotifier();
});
