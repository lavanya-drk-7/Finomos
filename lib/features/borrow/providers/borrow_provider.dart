import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/borrow_models.dart';

class BorrowState {
  final List<LoanAccount> loans;
  final double totalDebtOutstanding;
  final double totalMonthlyEmi;
  final double creditScore;
  final String creditRating;
  final List<DebtStrategy> strategies;

  BorrowState({
    required this.loans,
    required this.totalDebtOutstanding,
    required this.totalMonthlyEmi,
    required this.creditScore,
    required this.creditRating,
    required this.strategies,
  });
}

class BorrowNotifier extends Notifier<BorrowState> {
  @override
  BorrowState build() {
    return BorrowState(
      loans: [
        LoanAccount(
          id: 'l1',
          title: 'HDFC Home Loan',
          type: 'Home Loan',
          principalOutstanding: 1100000,
          interestRate: 8.5,
          monthlyEmi: 18500,
          remainingTenureMonths: 84,
          status: 'Auto-Pay Active',
        ),
        LoanAccount(
          id: 'l2',
          title: 'ICICI Credit Card Revolving',
          type: 'Credit Card',
          principalOutstanding: 140000,
          interestRate: 36.0,
          monthlyEmi: 6500,
          remainingTenureMonths: 18,
          status: 'High Interest Priority',
        ),
      ],
      totalDebtOutstanding: 1240000,
      totalMonthlyEmi: 25000,
      creditScore: 785,
      creditRating: 'EXCELLENT',
      strategies: [
        DebtStrategy(
          name: 'Debt Avalanche Strategy (Highest Interest First)',
          description: 'Focus extra ₹5,000/mo payment into ICICI Credit Card (36% APR). Saves max interest.',
          estimatedInterestSavings: 68400,
          monthsDebtFreeEarlier: 14,
        ),
        DebtStrategy(
          name: 'Debt Snowball Strategy (Smallest Balance First)',
          description: 'Clear ICICI Credit Card ₹1.4L balance first for quick psychological win.',
          estimatedInterestSavings: 52000,
          monthsDebtFreeEarlier: 12,
        ),
      ],
    );
  }
}

final borrowProvider = NotifierProvider<BorrowNotifier, BorrowState>(() {
  return BorrowNotifier();
});
