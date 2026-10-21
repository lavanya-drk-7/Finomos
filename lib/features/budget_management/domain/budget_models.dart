enum BudgetAlertLevel {
  none,
  approaching80,
  limitReached100,
  exceeded,
}

class BudgetItem {
  final String id;
  final String name;
  final String type; // 'Monthly Budget', 'Category-wise Budget'
  final String category;
  final double amount;
  final double spent;
  final String startDate;
  final String endDate;
  final String period; // e.g. "October 2026"
  final BudgetAlertLevel lastAlertTriggered;

  const BudgetItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.amount,
    required this.spent,
    required this.startDate,
    required this.endDate,
    this.period = 'October 2026',
    this.lastAlertTriggered = BudgetAlertLevel.none,
  });

  /// Remaining Budget = Budget Amount − Total Eligible Expenses
  double get remaining => (amount - spent) >= 0 ? (amount - spent) : 0.0;

  /// Overspent Amount = Total Eligible Expenses − Budget Amount
  double get overspentAmount => spent > amount ? (spent - amount) : 0.0;

  /// Budget Utilization = (Total Eligible Expenses ÷ Budget Amount) × 100
  double get utilizationPercentage => amount > 0 ? ((spent / amount) * 100) : 0.0;

  /// Progress ratio clamped between 0.0 and 1.0 for standard UI progress indicators
  double get progressPercentage => amount > 0 ? (spent / amount).clamp(0.0, 1.0) * 100 : 0.0;

  bool get isExceeded => spent > amount;
  bool get isApproachingLimit => spent >= (amount * 0.8) && spent < amount;
  bool get isLimitReached => spent >= amount && spent <= (amount * 1.001);

  BudgetAlertLevel get currentAlertLevel {
    if (isExceeded) return BudgetAlertLevel.exceeded;
    if (isLimitReached) return BudgetAlertLevel.limitReached100;
    if (isApproachingLimit) return BudgetAlertLevel.approaching80;
    return BudgetAlertLevel.none;
  }

  BudgetItem copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    double? amount,
    double? spent,
    String? startDate,
    String? endDate,
    String? period,
    BudgetAlertLevel? lastAlertTriggered,
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
      period: period ?? this.period,
      lastAlertTriggered: lastAlertTriggered ?? this.lastAlertTriggered,
    );
  }
}

class BudgetAlertEvent {
  final BudgetItem budget;
  final BudgetAlertLevel level;
  final String title;
  final String message;
  final double overspentAmount;
  final double utilizationPercentage;

  const BudgetAlertEvent({
    required this.budget,
    required this.level,
    required this.title,
    required this.message,
    required this.overspentAmount,
    required this.utilizationPercentage,
  });
}

class BudgetState {
  final List<BudgetItem> budgets;
  final bool alertEnabled;
  final BudgetAlertEvent? activeBannerAlert;

  const BudgetState({
    required this.budgets,
    this.alertEnabled = true,
    this.activeBannerAlert,
  });

  double get totalBudget => budgets.fold(0.0, (sum, b) => sum + b.amount);
  double get totalSpent => budgets.fold(0.0, (sum, b) => sum + b.spent);
  double get totalRemaining => (totalBudget - totalSpent) >= 0 ? (totalBudget - totalSpent) : 0.0;
  double get totalOverspent => totalSpent > totalBudget ? (totalSpent - totalBudget) : 0.0;
  double get overallUsagePercentage => totalBudget > 0 ? ((totalSpent / totalBudget) * 100).clamp(0.0, 999.0) : 0.0;

  List<BudgetItem> get exceededBudgets => budgets.where((b) => b.isExceeded).toList();
  List<BudgetItem> get warningBudgets => budgets.where((b) => b.isApproachingLimit).toList();

  BudgetState copyWith({
    List<BudgetItem>? budgets,
    bool? alertEnabled,
    BudgetAlertEvent? activeBannerAlert,
    bool clearActiveBanner = false,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      activeBannerAlert: clearActiveBanner ? null : (activeBannerAlert ?? this.activeBannerAlert),
    );
  }
}
