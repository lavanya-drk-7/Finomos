import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/cache_service.dart';
import '../../income_tracking/providers/income_provider.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
import '../domain/plan_models.dart';

class PlanState {
  final List<FinancialGoal> goals;
  final RetirementPlan retirementPlan;

  PlanState({
    required this.goals,
    required this.retirementPlan,
  });

  PlanState copyWith({
    List<FinancialGoal>? goals,
    RetirementPlan? retirementPlan,
  }) {
    return PlanState(
      goals: goals ?? this.goals,
      retirementPlan: retirementPlan ?? this.retirementPlan,
    );
  }
}

class PlanNotifier extends Notifier<PlanState> {
  @override
  PlanState build() {
    final incomeState = ref.watch(incomeProvider);
    final bankState = ref.watch(bankAggregationProvider);

    final cachedGoalsRaw = LocalCacheService().get('financial_goals');
    List<FinancialGoal> goals = [];
    if (cachedGoalsRaw is List) {
      goals = cachedGoalsRaw
          .whereType<Map>()
          .map((e) => FinancialGoal.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final double monthlyIncome = incomeState.summaryData?.totalMonthlyIncome ??
        incomeState.entries.fold(0.0, (s, e) => s + e.amount);
    final double netWorth = bankState.netWorth;

    final double requiredCorpus = monthlyIncome > 0 ? monthlyIncome * 12 * 25 : 0.0;
    final double projectedCorpus = netWorth > 0 ? netWorth * 4.5 : 0.0;
    final double fireScore = requiredCorpus > 0
        ? ((projectedCorpus / requiredCorpus) * 100).clamp(0.0, 100.0)
        : 0.0;

    return PlanState(
      goals: goals,
      retirementPlan: RetirementPlan(
        currentAge: 30,
        targetRetirementAge: 55,
        requiredCorpus: requiredCorpus,
        projectedCorpus: projectedCorpus,
        fireReadinessScore: fireScore,
        monthlyRetirementExpenses: monthlyIncome > 0 ? monthlyIncome * 0.7 : 0.0,
      ),
    );
  }

  void addGoal(FinancialGoal goal) {
    final updated = [...state.goals, goal];
    state = state.copyWith(goals: updated);
    LocalCacheService().save('financial_goals', updated.map((g) => g.toJson()).toList());
  }

  void deleteGoal(String id) {
    final updated = state.goals.where((g) => g.id != id).toList();
    state = state.copyWith(goals: updated);
    LocalCacheService().save('financial_goals', updated.map((g) => g.toJson()).toList());
  }
}

final planProvider = NotifierProvider<PlanNotifier, PlanState>(() {
  return PlanNotifier();
});
