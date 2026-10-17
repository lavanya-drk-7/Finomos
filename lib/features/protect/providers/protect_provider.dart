import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return ProtectState(
      emergencyFund: EmergencyFund(
        currentAmount: 425000,
        targetAmount: 500000,
        monthlyEssentialExpenses: 50000,
        runwayMonths: 8.5,
        readinessScore: 85.0,
      ),
      policies: [
        InsurancePolicy(
          id: 'p1',
          title: 'HDFC ERGO Optima Secure',
          category: 'Health',
          coverageAmount: 1000000,
          recommendedCoverage: 2000000,
          premiumAmount: 18500,
          expiryDate: DateTime.now().add(const Duration(days: 145)),
          status: 'Active (Gap ₹10L)',
        ),
        InsurancePolicy(
          id: 'p2',
          title: 'Max Life Smart Term Plan',
          category: 'Life',
          coverageAmount: 15000000,
          recommendedCoverage: 20000000,
          premiumAmount: 24000,
          expiryDate: DateTime.now().add(const Duration(days: 88)),
          status: 'Active (Optimal)',
        ),
        InsurancePolicy(
          id: 'p3',
          title: 'Tata AIG Comprehensive Car',
          category: 'Vehicle',
          coverageAmount: 650000,
          recommendedCoverage: 650000,
          premiumAmount: 12500,
          expiryDate: DateTime.now().add(const Duration(days: 22)),
          status: 'Renewal Due Soon',
        ),
      ],
    );
  }
}

final protectProvider = NotifierProvider<ProtectNotifier, ProtectState>(() {
  return ProtectNotifier();
});
