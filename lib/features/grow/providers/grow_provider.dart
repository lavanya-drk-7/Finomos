import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
import '../domain/grow_models.dart';

class GrowState {
  final double portfolioValue;
  final double investedValue;
  final double xirr;
  final double totalMonthlySip;
  final List<InvestmentHolding> holdings;
  final double netWorth;
  final double financialIndependenceRatio;
  final List<NetWorthMilestone> milestones;

  GrowState({
    required this.portfolioValue,
    required this.investedValue,
    required this.xirr,
    required this.totalMonthlySip,
    required this.holdings,
    required this.netWorth,
    required this.financialIndependenceRatio,
    required this.milestones,
  });
}

class GrowNotifier extends Notifier<GrowState> {
  @override
  GrowState build() {
    final bankState = ref.watch(bankAggregationProvider);
    final investments = bankState.investments;

    final portfolioValue = bankState.totalInvestments;
    final investedValue = investments.fold(0.0, (s, i) => s + i.investedValue);
    final xirr = investedValue > 0
        ? (((portfolioValue - investedValue) / investedValue) * 100)
        : 0.0;

    final mappedHoldings = investments.map((inv) => InvestmentHolding(
      id: inv.id,
      name: inv.institution,
      assetClass: inv.assetType,
      investedAmount: inv.investedValue,
      currentValue: inv.currentValue,
      returnsPercentage: inv.returnPercentage,
      monthlySipAmount: 0,
    )).toList();

    return GrowState(
      portfolioValue: portfolioValue,
      investedValue: investedValue,
      xirr: xirr,
      totalMonthlySip: 0,
      holdings: mappedHoldings,
      netWorth: bankState.netWorth,
      financialIndependenceRatio: investedValue > 0 ? 0.35 : 0.0,
      milestones: portfolioValue > 0
          ? [
              NetWorthMilestone(
                title: 'Next Growth Target',
                targetAmount: portfolioValue * 1.5,
                currentAmount: portfolioValue,
                targetDate: '2027',
                isCompleted: false,
              ),
            ]
          : const [],
    );
  }
}

final growProvider = NotifierProvider<GrowNotifier, GrowState>(() {
  return GrowNotifier();
});
