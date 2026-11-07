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

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentCorpus: (json['currentCorpus'] as num?)?.toDouble() ?? 0.0,
      monthlyContribution: (json['monthlyContribution'] as num?)?.toDouble() ?? 0.0,
      targetYear: json['targetYear']?.toString() ?? '2028',
      successProbability: (json['successProbability'] as num?)?.toDouble() ?? 80.0,
      priority: json['priority']?.toString() ?? 'Medium Priority',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'targetAmount': targetAmount,
      'currentCorpus': currentCorpus,
      'monthlyContribution': monthlyContribution,
      'targetYear': targetYear,
      'successProbability': successProbability,
      'priority': priority,
    };
  }
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
