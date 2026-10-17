class BudgetItem {
  final String id;
  final String name;
  final String type; // Monthly Budget, Category-wise Budget
  final String category;
  final double amount;
  final double spent;
  final String startDate;
  final String endDate;

  const BudgetItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.amount,
    required this.spent,
    required this.startDate,
    required this.endDate,
  });

  double get remaining => amount - spent;
  double get progressPercentage => (spent / amount).clamp(0.0, 1.0) * 100;
  bool get isExceeded => spent > amount;

  BudgetItem copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    double? amount,
    double? spent,
    String? startDate,
    String? endDate,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class BudgetState {
  final List<BudgetItem> budgets;
  final bool alertEnabled;

  const BudgetState({
    required this.budgets,
    this.alertEnabled = true,
  });

  double get totalBudget => budgets.fold(0, (sum, b) => sum + b.amount);
  double get totalSpent => budgets.fold(0, (sum, b) => sum + b.spent);
  double get totalRemaining => totalBudget - totalSpent;
  double get overallUsagePercentage => (totalSpent / totalBudget).clamp(0.0, 1.0) * 100;

  BudgetState copyWith({
    List<BudgetItem>? budgets,
    bool? alertEnabled,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      alertEnabled: alertEnabled ?? this.alertEnabled,
    );
  }
}
