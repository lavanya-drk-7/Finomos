import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/budget_models.dart';

class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() {
    return const BudgetState(
      budgets: [
        BudgetItem(
          id: 'b_1',
          name: 'Food & Dining',
          type: 'Category-wise Budget',
          category: 'Food & Dining',
          amount: 8000.0,
          spent: 5500.0,
          startDate: '01/09/2026',
          endDate: '30/09/2026',
        ),
        BudgetItem(
          id: 'b_2',
          name: 'Travel',
          type: 'Category-wise Budget',
          category: 'Travel',
          amount: 5000.0,
          spent: 2000.0,
          startDate: '01/09/2026',
          endDate: '30/09/2026',
        ),
        BudgetItem(
          id: 'b_3',
          name: 'Shopping',
          type: 'Category-wise Budget',
          category: 'Shopping',
          amount: 6000.0,
          spent: 3500.0,
          startDate: '01/09/2026',
          endDate: '30/09/2026',
        ),
        BudgetItem(
          id: 'b_4',
          name: 'Entertainment',
          type: 'Category-wise Budget',
          category: 'Entertainment',
          amount: 4000.0,
          spent: 1200.0,
          startDate: '01/09/2026',
          endDate: '30/09/2026',
        ),
      ],
    );
  }

  void addBudget(BudgetItem item) {
    state = state.copyWith(budgets: [...state.budgets, item]);
  }

  void updateBudget(BudgetItem item) {
    final updated = state.budgets.map((b) => b.id == item.id ? item : b).toList();
    state = state.copyWith(budgets: updated);
  }

  void deleteBudget(String id) {
    state = state.copyWith(budgets: state.budgets.where((b) => b.id != id).toList());
  }

  void toggleAlert(bool val) {
    state = state.copyWith(alertEnabled: val);
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(() {
  return BudgetNotifier();
});
