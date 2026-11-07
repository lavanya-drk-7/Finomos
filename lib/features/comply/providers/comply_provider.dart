import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../income_tracking/providers/income_provider.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
import '../domain/comply_models.dart';

class ComplyState {
  final double itrReadinessScore;
  final String recommendedForm; // ITR-1, ITR-2
  final List<TaxDeduction> deductions;
  final TaxRegimeComparison regimeComparison;
  final bool isDraftReady;

  ComplyState({
    required this.itrReadinessScore,
    required this.recommendedForm,
    required this.deductions,
    required this.regimeComparison,
    required this.isDraftReady,
  });
}

class ComplyNotifier extends Notifier<ComplyState> {
  @override
  ComplyState build() {
    final incomeState = ref.watch(incomeProvider);
    final bankState = ref.watch(bankAggregationProvider);

    final double annualIncome = incomeState.summaryData?.totalAnnualIncome ??
        (incomeState.entries.fold(0.0, (s, e) => s + e.amount) * 12);

    final double grossIncome = annualIncome > 0 ? annualIncome : 0.0;
    final double homeLoanDeduction = bankState.loans
        .where((l) => l.loanType.toLowerCase().contains('home'))
        .fold(0.0, (s, l) => s + (l.monthlyEmi * 0.4 * 12))
        .clamp(0.0, 200000.0);

    final List<TaxDeduction> deductions = grossIncome > 0
        ? [
            TaxDeduction(
              section: 'Section 80C',
              title: 'ELSS + EPF + Life Insurance',
              limit: 150000,
              utilized: (grossIncome * 0.1).clamp(0.0, 150000.0),
            ),
            TaxDeduction(
              section: 'Section 80D',
              title: 'Health Insurance Premium',
              limit: 50000,
              utilized: bankState.insurancePolicies
                  .where((p) => p.policyType.toLowerCase().contains('health'))
                  .fold(0.0, (s, p) => s + p.premiumAmount)
                  .clamp(0.0, 50000.0),
            ),
            TaxDeduction(
              section: 'Section 80CCD(1B)',
              title: 'National Pension System (NPS)',
              limit: 50000,
              utilized: (grossIncome * 0.03).clamp(0.0, 50000.0),
            ),
            if (homeLoanDeduction > 0)
              TaxDeduction(
                section: 'Section 24(b)',
                title: 'Home Loan Interest Deduction',
                limit: 200000,
                utilized: homeLoanDeduction,
              ),
          ]
        : const [];

    final double totalDeductions = deductions.fold(0.0, (s, d) => s + d.utilized);
    final double taxableOld = (grossIncome - 50000 - totalDeductions).clamp(0.0, double.infinity);
    final double taxableNew = (grossIncome - 75000).clamp(0.0, double.infinity);

    final double oldTax = grossIncome > 500000 ? taxableOld * 0.20 : 0.0;
    final double newTax = grossIncome > 700000 ? taxableNew * 0.15 : 0.0;

    return ComplyState(
      itrReadinessScore: grossIncome > 0 ? 94.0 : 0.0,
      recommendedForm: grossIncome > 0 ? 'ITR-1 (Salaried)' : 'N/A',
      deductions: deductions,
      regimeComparison: TaxRegimeComparison(
        grossIncome: grossIncome,
        oldRegimeTax: oldTax,
        newRegimeTax: newTax,
        recommendedRegime: oldTax > newTax ? 'New Tax Regime' : 'Old Tax Regime',
        netTaxSavings: (oldTax - newTax).abs(),
      ),
      isDraftReady: grossIncome > 0,
    );
  }
}

final complyProvider = NotifierProvider<ComplyNotifier, ComplyState>(() {
  return ComplyNotifier();
});
