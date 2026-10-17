class ExpenseEntry {
  final String id;
  final String description;
  final String category; // Housing, Food, Utilities, Transport, Healthcare, Shopping, Entertainment, Subscriptions, Bills, Other
  final double amount;
  final String date;
  final String paymentMode; // UPI, Credit Card, Debit Card, Net Banking, Cash
  final String priority; // P1 - Survival, P2 - Protection, P3 - Obligations, P4 - Growth, P5 - Lifestyle, P6 - Luxury
  final bool isRecurring;
  final String merchant;
  final String notes;
  final String bankAccount;
  final String? documentName;
  final String? documentPath;

  const ExpenseEntry({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    this.paymentMode = 'UPI',
    this.priority = 'P1 - Survival',
    this.isRecurring = false,
    this.merchant = '',
    this.notes = '',
    this.bankAccount = 'HDFC Bank ••••4587',
    this.documentName,
    this.documentPath,
  });

  ExpenseEntry copyWith({
    String? id,
    String? description,
    String? category,
    double? amount,
    String? date,
    String? paymentMode,
    String? priority,
    bool? isRecurring,
    String? merchant,
    String? notes,
    String? bankAccount,
    String? documentName,
    String? documentPath,
  }) {
    return ExpenseEntry(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentMode: paymentMode ?? this.paymentMode,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      merchant: merchant ?? this.merchant,
      notes: notes ?? this.notes,
      bankAccount: bankAccount ?? this.bankAccount,
      documentName: documentName ?? this.documentName,
      documentPath: documentPath ?? this.documentPath,
    );
  }
}

class ExpenseState {
  final List<ExpenseEntry> expenses;
  final String searchQuery;
  final String selectedCategoryFilter;
  final String selectedPriorityFilter;
  final String selectedBankAccountFilter;
  final String selectedDateFilter;
  final double monthlyInflow;

  const ExpenseState({
    required this.expenses,
    this.searchQuery = '',
    this.selectedCategoryFilter = 'All',
    this.selectedPriorityFilter = 'All',
    this.selectedBankAccountFilter = 'All',
    this.selectedDateFilter = 'All',
    this.monthlyInflow = 132500.0,
  });

  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get monthlyAverage => totalExpenses;

  double get dailyAverage => totalExpenses / 30.0;

  double get monthlyRecurringExpenses =>
      expenses.fold(0.0, (sum, e) => e.isRecurring ? sum + e.amount : sum);

  double get discretionaryExpenses =>
      (totalExpenses - monthlyRecurringExpenses).clamp(0.0, double.infinity);

  double get netCashFlow => monthlyInflow - totalExpenses;

  double get savingsRate {
    if (monthlyInflow <= 0) return 0.0;
    return (((monthlyInflow - totalExpenses) / monthlyInflow) * 100).clamp(-100.0, 100.0);
  }

  double get cashRunwayMonths {
    if (totalExpenses <= 0) return 12.0;
    return (300000.0 / totalExpenses).clamp(1.0, 24.0);
  }

  double get survivalP1Total =>
      expenses.where((e) => e.priority.startsWith('P1')).fold(0.0, (sum, e) => sum + e.amount);

  double get protectionP2Total =>
      expenses.where((e) => e.priority.startsWith('P2')).fold(0.0, (sum, e) => sum + e.amount);

  double get obligationsP3Total =>
      expenses.where((e) => e.priority.startsWith('P3')).fold(0.0, (sum, e) => sum + e.amount);

  double get lifestyleP5Total => expenses
      .where((e) => e.priority.startsWith('P5') || e.priority.startsWith('P6'))
      .fold(0.0, (sum, e) => sum + e.amount);

  double get needsRatio {
    if (totalExpenses <= 0) return 0.0;
    return (((survivalP1Total + protectionP2Total + obligationsP3Total) / totalExpenses) * 100)
        .clamp(0.0, 100.0);
  }

  double get wantsRatio {
    if (totalExpenses <= 0) return 0.0;
    return (100.0 - needsRatio).clamp(0.0, 100.0);
  }

  double get expenseHealthScore {
    if (expenses.isEmpty) return 75.0;
    double score = 70.0;
    if (savingsRate >= 30) {
      score += 15;
    } else if (savingsRate >= 15) {
      score += 8;
    } else {
      score -= 10;
    }

    if (needsRatio <= 70) {
      score += 10;
    } else {
      score -= 8;
    }

    return score.clamp(35.0, 95.0);
  }

  ExpenseState copyWith({
    List<ExpenseEntry>? expenses,
    String? searchQuery,
    String? selectedCategoryFilter,
    String? selectedPriorityFilter,
    String? selectedBankAccountFilter,
    String? selectedDateFilter,
    double? monthlyInflow,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryFilter: selectedCategoryFilter ?? this.selectedCategoryFilter,
      selectedPriorityFilter: selectedPriorityFilter ?? this.selectedPriorityFilter,
      selectedBankAccountFilter: selectedBankAccountFilter ?? this.selectedBankAccountFilter,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      monthlyInflow: monthlyInflow ?? this.monthlyInflow,
    );
  }
}
