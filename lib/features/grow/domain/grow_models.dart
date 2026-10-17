class InvestmentHolding {
  final String id;
  final String name;
  final String assetClass; // Equity, Debt, Gold, Real Estate, FDs
  final double investedAmount;
  final double currentValue;
  final double returnsPercentage;
  final double monthlySipAmount;

  InvestmentHolding({
    required this.id,
    required this.name,
    required this.assetClass,
    required this.investedAmount,
    required this.currentValue,
    required this.returnsPercentage,
    required this.monthlySipAmount,
  });
}

class NetWorthMilestone {
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String targetDate;
  final bool isCompleted;

  NetWorthMilestone({
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.isCompleted,
  });
}
