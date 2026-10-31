class ApiConstants {
  static const String baseUrl = 'https://finmos-user.onrender.com';

  // Auth endpoints
  static const String login = '/api/auth/login';

  // Income module endpoints
  static const String incomeSummary = '/api/v1/income/summary';
  static const String incomeEntries = '/api/v1/income/entries';
  static const String incomeProofUpload = '/api/v1/income/proof-upload';
  static const String incomeAutoTracking = '/api/v1/income/settings/auto-tracking';
  static const String incomeForecast = '/api/v1/income/forecast';
  static const String incomeSync = '/api/v1/income/sync';
  static const String incomeDetectedInflows = '/api/v1/income/detected-inflows';
  static const String salaryAllocation = '/api/v1/income/salary-allocation';
  static const String directIncome = '/api/income';

  // Expense module endpoints
  static const String expenseSummary = '/api/v1/expenses/summary';
  static const String expenseEntries = '/api/v1/expenses/entries';
  static const String expenseCategoryBreakdown = '/api/v1/expenses/breakdown/category';
  static const String expensePriorityBreakdown = '/api/v1/expenses/breakdown/priority';
  static const String expenseDetected = '/api/v1/expenses/detected';
  static const String expenseReceiptUpload = '/api/v1/expenses/receipt-upload';
  static const String directExpense = '/api/expense';

  // Budget module endpoints
  static const String budgetSummary = '/api/v1/budgets/summary';
  static const String budgets = '/api/v1/budgets';
  static const String budgetRecalculate = '/api/v1/budgets/recalculate';
  static const String budgetUtilizationAnalytics = '/api/v1/budgets/analytics/utilization';
  static const String budgetActiveAlerts = '/api/v1/budgets/alerts/active';
  static const String budgetGuardrailSettings = '/api/v1/budgets/settings/guardrails';
  static const String budgetRollover = '/api/v1/budgets/rollover';

  // Unified Transactions & Overview endpoints
  static const String transactions = '/api/transactions';
  static const String overview = '/api/overview';

  // Helper url builders
  static String incomeEntryById(String id) => '$incomeEntries/$id';
  static String incomeVoucherById(String id) => '$incomeEntries/$id/voucher';
  static String incomeVoucherPdf(String voucherNumber) {
    final cleanNumber = voucherNumber.endsWith('.pdf') ? voucherNumber : '$voucherNumber.pdf';
    return '/api/v1/income/vouchers/$cleanNumber';
  }
  static String incomeSummaryWithHorizon(String horizon) => '$incomeSummary?horizon=$horizon';
  static String incomeConfirmDetectedInflow(String detectedId) => '$incomeDetectedInflows/$detectedId/confirm';
  static String expenseEntryById(String id) => '$expenseEntries/$id';
  static String expenseInvoiceById(String id) => '$expenseEntries/$id/invoice';
  static String expenseConfirmDetected(String detectionId) => '$expenseDetected/$detectionId/confirm';
  static String expenseSummaryWithMonth(String month) => '$expenseSummary?month=$month';
  static String expenseEntriesQuery({
    String? search,
    String? category,
    String? priority,
    String? bankAccount,
    String? dateFilter,
    int page = 1,
    int limit = 20,
  }) {
    final params = <String>[];
    if (search != null && search.isNotEmpty) params.add('search=${Uri.encodeComponent(search)}');
    if (category != null && category != 'All' && category.isNotEmpty) params.add('category=${Uri.encodeComponent(category)}');
    if (priority != null && priority != 'All' && priority.isNotEmpty) params.add('priority=${Uri.encodeComponent(priority)}');
    if (bankAccount != null && bankAccount != 'All' && bankAccount.isNotEmpty) params.add('bankAccount=${Uri.encodeComponent(bankAccount)}');
    if (dateFilter != null && dateFilter != 'All' && dateFilter.isNotEmpty) params.add('dateFilter=${Uri.encodeComponent(dateFilter)}');
    params.add('page=$page');
    params.add('limit=$limit');
    return '$expenseEntries?${params.join('&')}';
  }

  static String budgetById(String id) => '$budgets/$id';
  static String budgetExpenses(String id) => '$budgets/$id/expenses';
  static String budgetDismissAlert(String alertId) => '/api/v1/budgets/alerts/$alertId/dismiss';
  static String budgetsQuery({
    String? period,
    String? category,
    String? status,
    int page = 1,
    int limit = 20,
  }) {
    final params = <String>[];
    if (period != null && period.isNotEmpty && period != 'all') params.add('period=${Uri.encodeComponent(period)}');
    if (category != null && category.isNotEmpty && category != 'all') params.add('category=${Uri.encodeComponent(category)}');
    if (status != null && status.isNotEmpty && status != 'all') params.add('status=${Uri.encodeComponent(status)}');
    params.add('page=$page');
    params.add('limit=$limit');
    return '$budgets?${params.join('&')}';
  }
}
