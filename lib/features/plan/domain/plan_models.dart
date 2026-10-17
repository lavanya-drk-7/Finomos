class FinancialGoal {
  final String id;
  final String title;
  final String category; // House, Car, Child Education, Vacation
  final double targetAmount;
  final double currentCorpus;
  final double monthlyContribution;
  final String targetYear;
  final double successProbability;
  final String priority;

  FinancialGoal({
    required this.id,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.currentCorpus,
    required this.monthlyContribution,
    required this.targetYear,
    required this.successProbability,
    required this.priority,
  });
}

class RetirementPlan {
  final int currentAge;
  final int targetRetirementAge;
  final double requiredCorpus;
  final double projectedCorpus;
  final double fireReadinessScore;
  final double monthlyRetirementExpenses;

  RetirementPlan({
    required this.currentAge,
    required this.targetRetirementAge,
    required this.requiredCorpus,
    required this.projectedCorpus,
    required this.fireReadinessScore,
    required this.monthlyRetirementExpenses,
  });
}
