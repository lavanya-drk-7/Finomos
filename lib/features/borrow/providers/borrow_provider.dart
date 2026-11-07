import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
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
    final bankState = ref.watch(bankAggregationProvider);
    final bankLoans = bankState.loans;

    final double totalDebt = bankState.totalLoanDebt;
    final double monthlyEmi = bankLoans.fold(0.0, (s, l) => s + l.monthlyEmi);

    final mappedLoans = bankLoans.map((l) => LoanAccount(
      id: l.id,
      title: '${l.lender} ${l.loanType}',
      type: l.loanType,
      principalOutstanding: l.outstandingPrincipal,
      interestRate: l.interestRate,
      monthlyEmi: l.monthlyEmi,
      remainingTenureMonths: l.tenureRemainingMonths,
      status: 'Active',
    )).toList();

    return BorrowState(
      loans: mappedLoans,
      totalDebtOutstanding: totalDebt,
      totalMonthlyEmi: monthlyEmi,
      creditScore: totalDebt > 0 ? 785 : 0,
      creditRating: totalDebt > 0 ? 'EXCELLENT' : 'N/A',
      strategies: totalDebt > 0
          ? [
              DebtStrategy(
                name: 'Debt Avalanche Strategy (Highest Interest First)',
                description: 'Focus extra payment into highest APR loan to minimize total interest outflow.',
                estimatedInterestSavings: totalDebt * 0.05,
                monthsDebtFreeEarlier: 12,
              ),
              DebtStrategy(
                name: 'Debt Snowball Strategy (Smallest Balance First)',
                description: 'Pay off smallest balance loans first for rapid psychological momentum.',
                estimatedInterestSavings: totalDebt * 0.03,
                monthsDebtFreeEarlier: 8,
              ),
            ]
          : const [],
    );
  }
}

final borrowProvider = NotifierProvider<BorrowNotifier, BorrowState>(() {
  return BorrowNotifier();
});
