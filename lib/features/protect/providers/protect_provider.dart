import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
import '../domain/protect_models.dart';

class ProtectState {
  final EmergencyFund emergencyFund;
  final List<InsurancePolicy> policies;

  ProtectState({
    required this.emergencyFund,
    required this.policies,
  });

  ProtectState copyWith({
    EmergencyFund? emergencyFund,
    List<InsurancePolicy>? policies,
  }) {
    return ProtectState(
      emergencyFund: emergencyFund ?? this.emergencyFund,
      policies: policies ?? this.policies,
    );
  }
}

class ProtectNotifier extends Notifier<ProtectState> {
  @override
  ProtectState build() {
    final bankState = ref.watch(bankAggregationProvider);
    final policies = bankState.insurancePolicies;

    final mappedPolicies = policies.map((p) => InsurancePolicy(
      id: p.id,
      title: '${p.provider} (${p.policyType})',
      category: p.policyType.contains('Health') ? 'Health' : (p.policyType.contains('Life') ? 'Life' : 'General'),
      coverageAmount: p.coverageAmount,
      recommendedCoverage: p.coverageAmount * 1.25,
      premiumAmount: p.premiumAmount,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      status: 'Active',
    )).toList();

    final liquidReserves = bankState.totalLiquidCash + bankState.totalBankCash;

    return ProtectState(
      emergencyFund: EmergencyFund(
        currentAmount: liquidReserves,
        targetAmount: liquidReserves > 0 ? liquidReserves * 1.5 : 0.0,
        monthlyEssentialExpenses: 0,
        runwayMonths: liquidReserves > 0 ? (liquidReserves / 30000) : 0.0,
        readinessScore: liquidReserves > 0 ? 80.0 : 0.0,
      ),
      policies: mappedPolicies,
    );
  }
}

final protectProvider = NotifierProvider<ProtectNotifier, ProtectState>(() {
  return ProtectNotifier();
});
