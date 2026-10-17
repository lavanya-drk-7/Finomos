class BankAccountItem {
  final String id;
  final String bankName;
  final String accountType; // Savings Account, Current Account
  final String maskedAccountNumber; // e.g. XXXXXX4821 (FAA-BR-002)
  final String ifscCode;
  final String accountHolder;
  final double currentBalance;
  final double availableBalance;
  final String lastSynced;
  final bool isConnected;

  const BankAccountItem({
    required this.id,
    required this.bankName,
    required this.accountType,
    required this.maskedAccountNumber,
    required this.ifscCode,
    required this.accountHolder,
    required this.currentBalance,
    required this.availableBalance,
    required this.lastSynced,
    this.isConnected = true,
  });

  BankAccountItem copyWith({
    String? id,
    String? bankName,
    String? accountType,
    String? maskedAccountNumber,
    String? ifscCode,
    String? accountHolder,
    double? currentBalance,
    double? availableBalance,
    String? lastSynced,
    bool? isConnected,
  }) {
    return BankAccountItem(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountType: accountType ?? this.accountType,
      maskedAccountNumber: maskedAccountNumber ?? this.maskedAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountHolder: accountHolder ?? this.accountHolder,
      currentBalance: currentBalance ?? this.currentBalance,
      availableBalance: availableBalance ?? this.availableBalance,
      lastSynced: lastSynced ?? this.lastSynced,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class UpiAccountItem {
  final String id;
  final String upiId; // e.g. sireesha@oksbi
  final String provider; // Google Pay, PhonePe, Paytm, BHIM
  final String linkedBank;
  final bool isPrimary;
  final String status;

  const UpiAccountItem({
    required this.id,
    required this.upiId,
    required this.provider,
    required this.linkedBank,
    this.isPrimary = false,
    this.status = 'Active',
  });

  UpiAccountItem copyWith({
    String? id,
    String? upiId,
    String? provider,
    String? linkedBank,
    bool? isPrimary,
    String? status,
  }) {
    return UpiAccountItem(
      id: id ?? this.id,
      upiId: upiId ?? this.upiId,
      provider: provider ?? this.provider,
      linkedBank: linkedBank ?? this.linkedBank,
      isPrimary: isPrimary ?? this.isPrimary,
      status: status ?? this.status,
    );
  }
}

class CreditCardItem {
  final String id;
  final String cardName; // HDFC Regalia Gold
  final String last4Digits; // 4567
  final double creditLimit;
  final double outstandingBalance;
  final double availableCredit;
  final String statementDueDate;
  final double minimumDue;
  final int rewardPoints;
  final String? cardHolderName;
  final String? issuedBank;
  final String? cardType; // Visa, Mastercard, RuPay, etc.
  final String? expiryDate; // MM/YY

  const CreditCardItem({
    required this.id,
    required this.cardName,
    required this.last4Digits,
    required this.creditLimit,
    required this.outstandingBalance,
    required this.availableCredit,
    required this.statementDueDate,
    required this.minimumDue,
    this.rewardPoints = 0,
    this.cardHolderName,
    this.issuedBank,
    this.cardType,
    this.expiryDate,
  });

  double get utilizationRatio => creditLimit > 0 ? (outstandingBalance / creditLimit) : 0.0;
  String get utilizationPercent => (utilizationRatio * 100).toStringAsFixed(1);

  CreditCardItem copyWith({
    String? id,
    String? cardName,
    String? last4Digits,
    double? creditLimit,
    double? outstandingBalance,
    double? availableCredit,
    String? statementDueDate,
    double? minimumDue,
    int? rewardPoints,
    String? cardHolderName,
    String? issuedBank,
    String? cardType,
    String? expiryDate,
  }) {
    return CreditCardItem(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      last4Digits: last4Digits ?? this.last4Digits,
      creditLimit: creditLimit ?? this.creditLimit,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      availableCredit: availableCredit ?? this.availableCredit,
      statementDueDate: statementDueDate ?? this.statementDueDate,
      minimumDue: minimumDue ?? this.minimumDue,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      issuedBank: issuedBank ?? this.issuedBank,
      cardType: cardType ?? this.cardType,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

class LoanAccountItem {
  final String id;
  final String loanType; // Home Loan, Vehicle Loan, Personal Loan
  final String lender; // State Bank of India
  final double outstandingPrincipal;
  final double interestRate; // 8.55%
  final double monthlyEmi;
  final int tenureRemainingMonths;
  final String nextDueDate;

  const LoanAccountItem({
    required this.id,
    required this.loanType,
    required this.lender,
    required this.outstandingPrincipal,
    required this.interestRate,
    required this.monthlyEmi,
    required this.tenureRemainingMonths,
    required this.nextDueDate,
  });

  LoanAccountItem copyWith({
    String? id,
    String? loanType,
    String? lender,
    double? outstandingPrincipal,
    double? interestRate,
    double? monthlyEmi,
    int? tenureRemainingMonths,
    String? nextDueDate,
  }) {
    return LoanAccountItem(
      id: id ?? this.id,
      loanType: loanType ?? this.loanType,
      lender: lender ?? this.lender,
      outstandingPrincipal: outstandingPrincipal ?? this.outstandingPrincipal,
      interestRate: interestRate ?? this.interestRate,
      monthlyEmi: monthlyEmi ?? this.monthlyEmi,
      tenureRemainingMonths: tenureRemainingMonths ?? this.tenureRemainingMonths,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }
}

class InvestmentHoldingItem {
  final String id;
  final String assetType; // Mutual Funds, Stocks, Fixed Deposits, Gold, EPF/PPF
  final String institution;
  final double currentValue;
  final double investedValue;
  final double returnPercentage;
  final bool isPositive;

  const InvestmentHoldingItem({
    required this.id,
    required this.assetType,
    required this.institution,
    required this.currentValue,
    required this.investedValue,
    required this.returnPercentage,
    this.isPositive = true,
  });

  InvestmentHoldingItem copyWith({
    String? id,
    String? assetType,
    String? institution,
    double? currentValue,
    double? investedValue,
    double? returnPercentage,
    bool? isPositive,
  }) {
    return InvestmentHoldingItem(
      id: id ?? this.id,
      assetType: assetType ?? this.assetType,
      institution: institution ?? this.institution,
      currentValue: currentValue ?? this.currentValue,
      investedValue: investedValue ?? this.investedValue,
      returnPercentage: returnPercentage ?? this.returnPercentage,
      isPositive: isPositive ?? this.isPositive,
    );
  }
}

class InsurancePolicyItem {
  final String id;
  final String policyType; // Health Insurance, Term Life Insurance, Vehicle Insurance
  final String policyNumberMasked;
  final String provider;
  final double coverageAmount;
  final double premiumAmount;
  final String renewalDate;
  final String nominee;

  const InsurancePolicyItem({
    required this.id,
    required this.policyType,
    required this.policyNumberMasked,
    required this.provider,
    required this.coverageAmount,
    required this.premiumAmount,
    required this.renewalDate,
    required this.nominee,
  });

  InsurancePolicyItem copyWith({
    String? id,
    String? policyType,
    String? policyNumberMasked,
    String? provider,
    double? coverageAmount,
    double? premiumAmount,
    String? renewalDate,
    String? nominee,
  }) {
    return InsurancePolicyItem(
      id: id ?? this.id,
      policyType: policyType ?? this.policyType,
      policyNumberMasked: policyNumberMasked ?? this.policyNumberMasked,
      provider: provider ?? this.provider,
      coverageAmount: coverageAmount ?? this.coverageAmount,
      premiumAmount: premiumAmount ?? this.premiumAmount,
      renewalDate: renewalDate ?? this.renewalDate,
      nominee: nominee ?? this.nominee,
    );
  }
}

class WalletAccountItem {
  final String id;
  final String walletName; // Amazon Pay, Paytm Wallet
  final double balance;
  final String status;

  const WalletAccountItem({
    required this.id,
    required this.walletName,
    required this.balance,
    this.status = 'Active',
  });
}

class AggregatorConsentItem {
  final String consentId; // AA908124567
  final String institution;
  final String consentType; // Account Access, Transaction Access, Balance Access
  final String startDate;
  final String expiryDate;
  final String purpose;
  final String dataShared;
  final String status; // Active, Expired, Revoked

  const AggregatorConsentItem({
    required this.consentId,
    required this.institution,
    required this.consentType,
    required this.startDate,
    required this.expiryDate,
    required this.purpose,
    required this.dataShared,
    required this.status,
  });
}

class InstitutionDirectoryItem {
  final String id;
  final String name;
  final String logoText;
  final String category; // Banks, UPI, Credit Cards, Loans, Investments, Insurance
  final bool apiEnabled;
  final bool aaSupported;
  final String status;

  const InstitutionDirectoryItem({
    required this.id,
    required this.name,
    required this.logoText,
    required this.category,
    this.apiEnabled = true,
    this.aaSupported = true,
    this.status = 'Active',
  });
}

class AggregatorTransactionItem {
  final String id;
  final String title;
  final String category;
  final double amount; // Positive = credit, Negative = debit
  final String date;
  final String institution;
  final String type; // UPI, NetBanking, Card, EMI

  const AggregatorTransactionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.institution,
    required this.type,
  });
}

class BankAggregationState {
  final List<BankAccountItem> bankAccounts;
  final List<UpiAccountItem> upiAccounts;
  final List<CreditCardItem> creditCards;
  final List<LoanAccountItem> loans;
  final List<InvestmentHoldingItem> investments;
  final List<InsurancePolicyItem> insurancePolicies;
  final List<WalletAccountItem> wallets;
  final List<AggregatorConsentItem> consents;
  final List<InstitutionDirectoryItem> institutionDirectory;
  final List<AggregatorTransactionItem> recentTransactions;
  final String selectedCategoryFilter;
  final String searchQuery;
  final int selectedTabIndex;
  final bool isSyncing;
  final String lastSyncedTime;
  final String connectionStatus;

  const BankAggregationState({
    required this.bankAccounts,
    required this.upiAccounts,
    required this.creditCards,
    required this.loans,
    required this.investments,
    required this.insurancePolicies,
    required this.wallets,
    required this.consents,
    required this.institutionDirectory,
    required this.recentTransactions,
    this.selectedCategoryFilter = 'All',
    this.searchQuery = '',
    this.selectedTabIndex = 0,
    this.isSyncing = false,
    this.lastSyncedTime = 'Just now • Every 4 Hours',
    this.connectionStatus = 'All 7 Pillars Connected & Synced',
  });

  // Consolidated Financial Position Calculations (Section 12 FRD/FRS)
  double get totalBankCash => bankAccounts.fold(0.0, (s, a) => s + a.currentBalance);
  double get totalWalletCash => wallets.fold(0.0, (s, w) => s + w.balance);
  double get totalCashPosition => totalBankCash + totalWalletCash;

  double get totalCreditCardDebt => creditCards.fold(0.0, (s, c) => s + c.outstandingBalance);
  double get totalLoanDebt => loans.fold(0.0, (s, l) => s + l.outstandingPrincipal);
  double get totalDebtPosition => totalCreditCardDebt + totalLoanDebt;

  double get totalInvestments => investments.fold(0.0, (s, i) => s + i.currentValue);
  double get totalInsuranceCoverage => insurancePolicies.fold(0.0, (s, p) => s + p.coverageAmount);

  double get totalAssets => totalCashPosition + totalInvestments;
  double get totalLiabilities => totalDebtPosition;
  double get netWorth => totalAssets - totalLiabilities;

  BankAggregationState copyWith({
    List<BankAccountItem>? bankAccounts,
    List<UpiAccountItem>? upiAccounts,
    List<CreditCardItem>? creditCards,
    List<LoanAccountItem>? loans,
    List<InvestmentHoldingItem>? investments,
    List<InsurancePolicyItem>? insurancePolicies,
    List<WalletAccountItem>? wallets,
    List<AggregatorConsentItem>? consents,
    List<InstitutionDirectoryItem>? institutionDirectory,
    List<AggregatorTransactionItem>? recentTransactions,
    String? selectedCategoryFilter,
    String? searchQuery,
    int? selectedTabIndex,
    bool? isSyncing,
    String? lastSyncedTime,
    String? connectionStatus,
  }) {
    return BankAggregationState(
      bankAccounts: bankAccounts ?? this.bankAccounts,
      upiAccounts: upiAccounts ?? this.upiAccounts,
      creditCards: creditCards ?? this.creditCards,
      loans: loans ?? this.loans,
      investments: investments ?? this.investments,
      insurancePolicies: insurancePolicies ?? this.insurancePolicies,
      wallets: wallets ?? this.wallets,
      consents: consents ?? this.consents,
      institutionDirectory: institutionDirectory ?? this.institutionDirectory,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      selectedCategoryFilter: selectedCategoryFilter ?? this.selectedCategoryFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedTime: lastSyncedTime ?? this.lastSyncedTime,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }
}
