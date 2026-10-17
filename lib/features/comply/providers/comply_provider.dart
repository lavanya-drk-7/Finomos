import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return ComplyState(
      itrReadinessScore: 94.0,
      recommendedForm: 'ITR-2 (Salary + Capital Gains)',
      deductions: [
        TaxDeduction(section: 'Section 80C', title: 'ELSS + EPF + Life Insurance', limit: 150000, utilized: 150000),
        TaxDeduction(section: 'Section 80D', title: 'Health Insurance Premium', limit: 50000, utilized: 38500),
        TaxDeduction(section: 'Section 80CCD(1B)', title: 'National Pension System (NPS)', limit: 50000, utilized: 50000),
        TaxDeduction(section: 'Section 24(b)', title: 'Home Loan Interest Deduction', limit: 200000, utilized: 185000),
      ],
      regimeComparison: TaxRegimeComparison(
        grossIncome: 1800000,
        oldRegimeTax: 187200,
        newRegimeTax: 156000,
        recommendedRegime: 'New Tax Regime',
        netTaxSavings: 31200,
      ),
      isDraftReady: true,
    );
  }
}

final complyProvider = NotifierProvider<ComplyNotifier, ComplyState>(() {
  return ComplyNotifier();
});
