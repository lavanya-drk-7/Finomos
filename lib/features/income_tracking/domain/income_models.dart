class IncomeEntry {
  final String id;
  final String source;
  final String category; // Salary, Business, Freelance, Rental, Dividend, Interest, Bonus, Other
  final String type; // Active, Passive, Windfall
  final double amount;
  final String date;
  final String frequency; // Monthly, One-time, Yearly, Bi-weekly, Quarterly
  final String notes;
  final bool isVerified;
  final String bankAccount;
  final String? documentName;
  final String? documentPath;

  const IncomeEntry({
    required this.id,
    required this.source,
    required this.category,
    this.type = 'Active',
    required this.amount,
    required this.date,
    required this.frequency,
    this.notes = '',
    this.isVerified = true,
    this.bankAccount = 'HDFC Bank ••••4587',
    this.documentName,
    this.documentPath,
  });

  IncomeEntry copyWith({
    String? id,
    String? source,
    String? category,
    String? type,
    double? amount,
    String? date,
    String? frequency,
    String? notes,
    bool? isVerified,
    String? bankAccount,
    String? documentName,
    String? documentPath,
  }) {
    return IncomeEntry(
      id: id ?? this.id,
      source: source ?? this.source,
      category: category ?? this.category,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      frequency: frequency ?? this.frequency,
      notes: notes ?? this.notes,
      isVerified: isVerified ?? this.isVerified,
      bankAccount: bankAccount ?? this.bankAccount,
      documentName: documentName ?? this.documentName,
      documentPath: documentPath ?? this.documentPath,
    );
  }
}

class IncomeState {
  final List<IncomeEntry> entries;
  final String searchQuery;
  final String selectedCategoryFilter;
  final String selectedTypeFilter;
  final String selectedBankAccountFilter;
  final String selectedDateFilter;
  final String forecastHorizon; // '30D', '90D', '1Y', '5Y'
  final bool autoTrackingEnabled;

  const IncomeState({
    required this.entries,
    this.searchQuery = '',
    this.selectedCategoryFilter = 'All',
    this.selectedTypeFilter = 'All',
    this.selectedBankAccountFilter = 'All',
    this.selectedDateFilter = 'All',
    this.forecastHorizon = '30D',
    this.autoTrackingEnabled = true,
  });

  double _getMonthlyEquivalent(IncomeEntry e) {
    final freq = e.frequency.toLowerCase();
    if (freq == 'one-time' || e.type.toLowerCase() == 'windfall') return 0.0;
    if (freq == 'yearly') return e.amount / 12.0;
    if (freq == 'quarterly') return e.amount / 3.0;
    if (freq == 'bi-weekly') return e.amount * 2.0;
    return e.amount;
  }

  double get totalMonthlyIncome {
    return entries.fold(0.0, (sum, e) => sum + _getMonthlyEquivalent(e));
  }

  double get activeMonthlyIncome {
    return entries.fold(0.0, (sum, e) {
      if (e.type.toLowerCase() == 'active') {
        return sum + _getMonthlyEquivalent(e);
      }
      return sum;
    });
  }

  double get passiveMonthlyIncome {
    return entries.fold(0.0, (sum, e) {
      if (e.type.toLowerCase() == 'passive') {
        return sum + _getMonthlyEquivalent(e);
      }
      return sum;
    });
  }

  double get windfallTotalIncome {
    return entries.fold(0.0, (sum, e) {
      if (e.type.toLowerCase() == 'windfall' || e.frequency.toLowerCase() == 'one-time') {
        return sum + e.amount;
      }
      return sum;
    });
  }

  double get totalAnnualIncome => (totalMonthlyIncome * 12) + windfallTotalIncome;

  double get passiveRatio {
    if (totalMonthlyIncome <= 0) return 0.0;
    return ((passiveMonthlyIncome / totalMonthlyIncome) * 100).clamp(0.0, 100.0);
  }

  double get stabilityScore {
    if (entries.isEmpty || totalMonthlyIncome <= 0) return 50.0;
    final total = totalMonthlyIncome + windfallTotalIncome;
    final recurringRatio = total > 0 ? (totalMonthlyIncome / total) : 1.0;
    final countWeight = (entries.length / 5).clamp(0.0, 1.0);
    final passiveBonus = (passiveRatio / 50.0).clamp(0.0, 0.2);
    final score = (recurringRatio * 55) + (countWeight * 35) + (passiveBonus * 10);
    return score.clamp(40.0, 96.0);
  }

  double get topDependencyPercent {
    if (entries.isEmpty || totalMonthlyIncome <= 0) return 0.0;
    double maxAmt = 0.0;
    for (final e in entries) {
      final monthly = _getMonthlyEquivalent(e);
      if (monthly > maxAmt) {
        maxAmt = monthly;
      }
    }
    return ((maxAmt / totalMonthlyIncome) * 100).clamp(0.0, 100.0);
  }

  double getForecastAmount(String horizon) {
    switch (horizon) {
      case '30D':
        return totalMonthlyIncome;
      case '90D':
        return totalMonthlyIncome * 3;
      case '1Y':
        return totalAnnualIncome;
      case '5Y':
        // Accounts for ~8% compounding on recurring streams + 5x windfall
        return (totalMonthlyIncome * 12 * 5.86) + (windfallTotalIncome * 5);
      default:
        return totalMonthlyIncome;
    }
  }

  IncomeState copyWith({
    List<IncomeEntry>? entries,
    String? searchQuery,
    String? selectedCategoryFilter,
    String? selectedTypeFilter,
    String? selectedBankAccountFilter,
    String? selectedDateFilter,
    String? forecastHorizon,
    bool? autoTrackingEnabled,
  }) {
    return IncomeState(
      entries: entries ?? this.entries,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryFilter: selectedCategoryFilter ?? this.selectedCategoryFilter,
      selectedTypeFilter: selectedTypeFilter ?? this.selectedTypeFilter,
      selectedBankAccountFilter: selectedBankAccountFilter ?? this.selectedBankAccountFilter,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      forecastHorizon: forecastHorizon ?? this.forecastHorizon,
      autoTrackingEnabled: autoTrackingEnabled ?? this.autoTrackingEnabled,
    );
  }
}
