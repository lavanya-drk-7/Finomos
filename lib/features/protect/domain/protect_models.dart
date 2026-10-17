class EmergencyFund {
  final double currentAmount;
  final double targetAmount;
  final double monthlyEssentialExpenses;
  final double runwayMonths;
  final double readinessScore;

  EmergencyFund({
    required this.currentAmount,
    required this.targetAmount,
    required this.monthlyEssentialExpenses,
    required this.runwayMonths,
    required this.readinessScore,
  });
}

class InsurancePolicy {
  final String id;
  final String title;
  final String category; // Health, Life, Vehicle, Property
  final double coverageAmount;
  final double recommendedCoverage;
  final double premiumAmount;
  final DateTime expiryDate;
  final String status;

  InsurancePolicy({
    required this.id,
    required this.title,
    required this.category,
    required this.coverageAmount,
    required this.recommendedCoverage,
    required this.premiumAmount,
    required this.expiryDate,
    required this.status,
  });
}
