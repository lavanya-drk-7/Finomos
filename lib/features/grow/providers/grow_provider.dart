import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return GrowState(
      portfolioValue: 2850000,
      investedValue: 2100000,
      xirr: 15.4,
      totalMonthlySip: 35000,
      holdings: [
        InvestmentHolding(
          id: 'i1',
          name: 'Nippon India Large Cap Fund',
          assetClass: 'Equity Mutual Fund',
          investedAmount: 800000,
          currentValue: 1150000,
          returnsPercentage: 43.75,
          monthlySipAmount: 15000,
        ),
        InvestmentHolding(
          id: 'i2',
          name: 'Parag Parikh Flexi Cap Fund',
          assetClass: 'Equity Mutual Fund',
          investedAmount: 700000,
          currentValue: 980000,
          returnsPercentage: 40.0,
          monthlySipAmount: 12000,
        ),
        InvestmentHolding(
          id: 'i3',
          name: 'Sovereign Gold Bond (SGB)',
          assetClass: 'Gold',
          investedAmount: 300000,
          currentValue: 420000,
          returnsPercentage: 40.0,
          monthlySipAmount: 4000,
        ),
        InvestmentHolding(
          id: 'i4',
          name: 'HDFC Corporate Bond Fund',
          assetClass: 'Debt',
          investedAmount: 300000,
          currentValue: 300000,
          returnsPercentage: 0.0,
          monthlySipAmount: 4000,
        ),
      ],
      netWorth: 3340000,
      financialIndependenceRatio: 1.15,
      milestones: [
        NetWorthMilestone(
          title: 'First ₹10 Lakhs Net Worth',
          targetAmount: 1000000,
          currentAmount: 1000000,
          targetDate: 'Achieved Jan 2024',
          isCompleted: true,
        ),
        NetWorthMilestone(
          title: 'Quarter Crore Milestone (₹25 Lakhs)',
          targetAmount: 2500000,
          currentAmount: 2500000,
          targetDate: 'Achieved Nov 2025',
          isCompleted: true,
        ),
        NetWorthMilestone(
          title: 'Half Crore Milestone (₹50 Lakhs)',
          targetAmount: 5000000,
          currentAmount: 3340000,
          targetDate: 'Expected Oct 2027',
          isCompleted: false,
        ),
        NetWorthMilestone(
          title: '₹1.0 Crore Net Worth',
          targetAmount: 10000000,
          currentAmount: 3340000,
          targetDate: 'Expected Nov 2029',
          isCompleted: false,
        ),
      ],
    );
  }
}

final growProvider = NotifierProvider<GrowNotifier, GrowState>(() {
  return GrowNotifier();
});
