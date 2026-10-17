class TaxDeduction {
  final String section; // 80C, 80D, 80CCD
  final String title;
  final double limit;
  final double utilized;

  TaxDeduction({
    required this.section,
    required this.title,
    required this.limit,
    required this.utilized,
  });
}

class TaxRegimeComparison {
  final double grossIncome;
  final double oldRegimeTax;
  final double newRegimeTax;
  final String recommendedRegime;
  final double netTaxSavings;

  TaxRegimeComparison({
    required this.grossIncome,
    required this.oldRegimeTax,
    required this.newRegimeTax,
    required this.recommendedRegime,
    required this.netTaxSavings,
  });
}
