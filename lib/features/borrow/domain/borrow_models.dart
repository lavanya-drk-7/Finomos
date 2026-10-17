class LoanAccount {
  final String id;
  final String title;
  final String type; // Home Loan, Personal Loan, Credit Card
  final double principalOutstanding;
  final double interestRate;
  final double monthlyEmi;
  final int remainingTenureMonths;
  final String status;

  LoanAccount({
    required this.id,
    required this.title,
    required this.type,
    required this.principalOutstanding,
    required this.interestRate,
    required this.monthlyEmi,
    required this.remainingTenureMonths,
    required this.status,
  });
}

class DebtStrategy {
  final String name; // Snowball, Avalanche
  final String description;
  final double estimatedInterestSavings;
  final int monthsDebtFreeEarlier;

  DebtStrategy({
    required this.name,
    required this.description,
    required this.estimatedInterestSavings,
    required this.monthsDebtFreeEarlier,
  });
}
