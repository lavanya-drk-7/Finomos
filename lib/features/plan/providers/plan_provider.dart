import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/plan_models.dart';

class PlanState {
  final List<FinancialGoal> goals;
  final RetirementPlan retirementPlan;

  PlanState({
    required this.goals,
    required this.retirementPlan,
  });
}

class PlanNotifier extends Notifier<PlanState> {
  @override
  PlanState build() {
    return PlanState(
      goals: [
        FinancialGoal(
          id: 'g1',
          title: 'Child Higher Education Fund',
          category: 'Education',
          targetAmount: 5000000,
          currentCorpus: 1800000,
          monthlyContribution: 20000,
          targetYear: '2034',
          successProbability: 92.0,
          priority: 'High Priority',
        ),
        FinancialGoal(
          id: 'g2',
          title: 'Dream Villa Purchase Downpayment',
          category: 'Real Estate',
          targetAmount: 3000000,
          currentCorpus: 1200000,
          monthlyContribution: 15000,
          targetYear: '2029',
          successProbability: 84.0,
          priority: 'Medium Priority',
        ),
        FinancialGoal(
          id: 'g3',
          title: 'Europe Family Vacation',
          category: 'Lifestyle',
          targetAmount: 600000,
          currentCorpus: 450000,
          monthlyContribution: 10000,
          targetYear: '2027',
          successProbability: 98.0,
          priority: 'Optional Priority',
        ),
      ],
      retirementPlan: RetirementPlan(
        currentAge: 32,
        targetRetirementAge: 52,
        requiredCorpus: 48000000,
        projectedCorpus: 51200000,
        fireReadinessScore: 88.0,
        monthlyRetirementExpenses: 180000,
      ),
    );
  }
}

final planProvider = NotifierProvider<PlanNotifier, PlanState>(() {
  return PlanNotifier();
});
