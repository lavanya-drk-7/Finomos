class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://finmos-user.onrender.com',
  );

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String loginV1 = '/api/v1/auth/login';
  static const String sendOtp = '/api/auth/send-otp';
  static const String sendOtpV1 = '/api/v1/auth/send-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String verifyOtpV1 = '/api/v1/auth/verify-otp';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String logout = '/api/auth/logout';
  static const String forgotPasswordRequest = '/api/auth/forgot-password/request';
  static const String forgotPasswordReset = '/api/auth/forgot-password/reset';
  static const String signup = '/api/auth/signup';
  static const String signupV1 = '/api/v1/auth/signup';
  static const String signupVerifyEmail = '/api/auth/signup/verify-email';
  static const String signupVerifyMobile = '/api/auth/signup/verify-mobile';
  static const String onboardingUserDetails = '/api/auth/onboarding/user-details';
  static const String onboardingKycDocuments = '/api/auth/onboarding/kyc-documents';
  static const String onboardingConsent = '/api/auth/onboarding/consent';

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
  static const String expenseDetected = '/api/v1/expense/detected-expenses';
  static const String expenseDetectedExpenses = '/api/v1/expense/detected-expenses';
  static const String expenseReceiptUpload = '/api/v1/expenses/receipt-upload';
  static const String directExpense = '/api/expense';

  // Notifications module endpoints
  static const String notifications = '/api/v1/notifications';
  static const String notificationsUnreadCount = '/api/v1/notifications/unread-count';
  static const String notificationsReadAll = '/api/v1/notifications/read-all';
  static const String notificationsSmsIngest = '/api/v1/notifications/sms/ingest';
  static const String notificationsSmsBatchSync = '/api/v1/notifications/sms/batch-sync';

  // Budget module endpoints
  static const String budgetSummary = '/api/v1/budgets/summary';
  static const String budgets = '/api/v1/budgets';
  static const String budgetRecalculate = '/api/v1/budgets/recalculate';
  static const String budgetUtilizationAnalytics = '/api/v1/budgets/analytics/utilization';
  static const String budgetActiveAlerts = '/api/v1/budgets/alerts/active';
  static const String budgetGuardrailSettings = '/api/v1/budgets/settings/guardrails';
  static const String budgetRollover = '/api/v1/budgets/rollover';

  // User Profile module endpoints
  static const String userProfile = '/api/v1/user/profile';
  static const String userProfilePersonal = '/api/v1/user/profile/personal';
  static const String userProfileAddress = '/api/v1/user/profile/address';
  static const String userProfileEmployment = '/api/v1/user/profile/employment';
  static const String userProfileFamilyMembers = '/api/v1/user/profile/family-members';
  static const String userProfileHousehold = '/api/v1/user/profile/household';
  static const String userProfileDeviceToken = '/api/v1/user/profile/device-token';
  static const String userProfilePhoto = '/api/v1/user/profile/photo';
  static const String userProfileSecurity = '/api/v1/user/profile/security';
  static const String userProfileNotifications = '/api/v1/user/profile/notifications';
  static const String userAccount = '/api/v1/user/account';

  // KYC module endpoints
  static const String kycStatus = '/api/v1/kyc/status';
  static const String kycDocuments = '/api/v1/kyc/documents';
  static const String kycUpload = '/api/v1/kyc/upload';
  static const String kycReVerify = '/api/v1/kyc/re-verify';

  // Digital Locker & Document Vault module endpoints
  static const String vaultStorageSummary = '/api/v1/vault/storage-summary';
  static const String vaultDocuments = '/api/v1/vault/documents';
  static const String vaultUpload = '/api/v1/vault/documents/upload';
  static const String vaultSyncKyc = '/api/v1/vault/sync/kyc';
  static const String vaultCrossModuleSummary = '/api/v1/vault/cross-module/summary';

  // Bank Aggregation & Account Aggregator module endpoints
  static const String bankAggregationSummary = '/api/v1/bank-aggregation/summary';
  static const String bankAggregationSyncAll = '/api/v1/bank-aggregation/sync-all';
  static const String bankAggregationAccounts = '/api/v1/bank-aggregation/accounts';
  static const String bankAggregationCards = '/api/v1/bank-aggregation/cards';
  static const String bankAggregationLoans = '/api/v1/bank-aggregation/loans';
  static const String bankAggregationInvestments = '/api/v1/bank-aggregation/investments';
  static const String bankAggregationInsurance = '/api/v1/bank-aggregation/insurance';
  static const String bankAggregationUpiAccounts = '/api/v1/bank-aggregation/upi-accounts';
  static const String bankAggregationWallets = '/api/v1/bank-aggregation/wallets';
  static const String bankAggregationConsents = '/api/v1/bank-aggregation/consents';
  static const String bankAggregationConsentInitiate = '/api/v1/bank-aggregation/consents/initiate';
  static const String bankAggregationConsentCallback = '/api/v1/bank-aggregation/consents/callback';
  static const String bankAggregationTransactions = '/api/v1/bank-aggregation/transactions';
  static const String bankAggregationInstitutions = '/api/v1/bank-aggregation/institutions';

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
  static String incomeDismissDetectedInflow(String detectedId) => '$incomeDetectedInflows/$detectedId';
  static String expenseEntryById(String id) => '$expenseEntries/$id';
  static String expenseInvoiceById(String id) => '$expenseEntries/$id/invoice';
  static String expenseConfirmDetected(String detectionId) => '$expenseDetected/$detectionId/confirm';
  static String expenseConfirmDetectedExpense(String detectionId) => '$expenseDetectedExpenses/$detectionId/confirm';
  static String expenseDismissDetectedExpense(String detectionId) => '$expenseDetectedExpenses/$detectionId';
  static String expenseSummaryWithMonth(String month) => '$expenseSummary?month=$month';

  // Notifications URL Builders
  static String notificationSave(String id) => '$notifications/$id/save';
  static String notificationRead(String id) => '$notifications/$id/read';
  static String notificationById(String id) => '$notifications/$id';
  static String notificationsQuery({
    String filter = 'all',
    int page = 1,
    int limit = 50,
    String? userMobile,
  }) {
    String q = '$notifications?filter=$filter&page=$page&limit=$limit';
    if (userMobile != null && userMobile.isNotEmpty) {
      q += '&userMobile=$userMobile';
    }
    return q;
  }
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

  // Document Vault URL Builders
  static String userProfileFamilyMemberById(String id) => '$userProfileFamilyMembers/$id';
  static String vaultDocumentById(String id) => '$vaultDocuments/$id';
  static String vaultDocumentReplace(String id) => '$vaultDocuments/$id/replace';
  static String vaultDocumentFile(String id) => '$vaultDocuments/$id/file';
  static String vaultDocumentDownload(String id) => '$vaultDocuments/$id/download';
  static String vaultDocumentPreview(String id) => '$vaultDocuments/$id/preview';
  static String vaultDocumentShare(String id) => '$vaultDocuments/$id/share';
  static String vaultSharedDocument(String token) => '/api/v1/vault/shared/$token';

  // Bank Aggregation URL Builders
  static String bankAggregationLookupIfsc(String ifsc) => '/api/v1/bank-aggregation/lookup/ifsc/$ifsc';
  static String bankAggregationAccountById(String id) => '$bankAggregationAccounts/$id';
  static String bankAggregationAccountSync(String id) => '$bankAggregationAccounts/$id/sync';
  static String bankAggregationAccountsQuery({String type = 'all'}) => '$bankAggregationAccounts?type=$type';
  static String bankAggregationCardsQuery({String type = 'all'}) => '$bankAggregationCards?type=$type';
  static String bankAggregationCardById(String id) => '$bankAggregationCards/$id';
  static String bankAggregationLoanById(String id) => '$bankAggregationLoans/$id';
  static String bankAggregationInvestmentById(String id) => '$bankAggregationInvestments/$id';
  static String bankAggregationInsuranceById(String id) => '$bankAggregationInsurance/$id';
  static String bankAggregationUpiAccountById(String id) => '$bankAggregationUpiAccounts/$id';
  static String bankAggregationUpiSetPrimary(String id) => '$bankAggregationUpiAccounts/$id/set-primary';
  static String bankAggregationWalletById(String id) => '$bankAggregationWallets/$id';
  static String bankAggregationConsentRevoke(String id) => '$bankAggregationConsents/$id/revoke';
  static String bankAggregationConsentRenew(String id) => '$bankAggregationConsents/$id/renew';
  static String bankAggregationTransactionsQuery({int page = 1, int limit = 20}) =>
      '$bankAggregationTransactions?limit=$limit&page=$page';
  static String vaultDocumentsQuery({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    final params = <String>[];
    if (category != null && category.isNotEmpty && category != 'All') {
      params.add('category=${Uri.encodeComponent(category)}');
    }
    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search)}');
    }
    params.add('page=$page');
    params.add('limit=$limit');
    return '$vaultDocuments?${params.join('&')}';
  }

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
