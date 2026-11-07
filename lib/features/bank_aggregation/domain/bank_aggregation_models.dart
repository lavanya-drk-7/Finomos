String _formatIsoDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  } catch (_) {
    return iso;
  }
}

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

  // Live API integration fields
  final String? rawAccountNumber;
  final String? branch;
  final String? city;
  final String? state;
  final double? openingBalance;
  final double? internalBalance;
  final String? nickname;
  final String? verificationStatus;
  final String? status;
  final String? userId;
  final String? createdAt;
  final String? updatedAt;
  final String? lastSyncedAt;
  final List<AggregatedExpenseItem>? expenses;
  final List<dynamic>? debitCards;

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
    this.rawAccountNumber,
    this.branch,
    this.city,
    this.state,
    this.openingBalance,
    this.internalBalance,
    this.nickname,
    this.verificationStatus,
    this.status,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.lastSyncedAt,
    this.expenses,
    this.debitCards,
  });

  factory BankAccountItem.fromJson(Map<String, dynamic> json) {
    final rawNumber = json['rawAccountNumber']?.toString() ?? '';
    final accountNum = json['accountNumber']?.toString() ?? '';
    final masked = accountNum.trim().isNotEmpty
        ? (accountNum.trim().startsWith('•') || accountNum.trim().startsWith('*') || accountNum.trim().startsWith('X')
            ? accountNum.trim()
            : '••••••••${accountNum.trim().length > 4 ? accountNum.trim().substring(accountNum.trim().length - 4) : accountNum.trim()}')
        : (rawNumber.length > 4 ? '••••••••${rawNumber.substring(rawNumber.length - 4)}' : '••••••••0000');

    final bank = json['bankName']?.toString() ?? json['name']?.toString() ?? 'Bank Account';
    final rawAccType = json['accountType']?.toString() ?? 'Savings Account';
    final upperAcc = rawAccType.toUpperCase();
    final accType = upperAcc.contains('SAVING')
        ? 'Savings Account'
        : (upperAcc.contains('CURRENT')
            ? 'Current Account'
            : (upperAcc.contains('SALARY')
                ? 'Salary Account'
                : (upperAcc.contains('FIXED') || upperAcc == 'FD'
                    ? 'Fixed Deposit (FD)'
                    : (upperAcc.contains('RECURRING') || upperAcc == 'RD'
                        ? 'Recurring Deposit (RD)'
                        : (upperAcc.contains('OVERDRAFT') || upperAcc == 'OD'
                            ? 'Overdraft (OD) Account'
                            : (upperAcc.contains('NRI') || upperAcc.contains('NRE') || upperAcc.contains('NRO')
                                ? 'NRI / NRE / NRO Account'
                                : rawAccType))))));
    final ifsc = json['ifsc']?.toString() ?? json['ifscCode']?.toString() ?? '';
    final holder = json['holderName']?.toString() ?? json['accountHolder']?.toString() ?? 'Account Holder';
    final curBal = (json['currentBalance'] ?? json['bankBalance'] ?? json['balance'] ?? json['openingBalance'] as num?)?.toDouble() ?? 0.0;
    final availBal = (json['availableBalance'] ?? json['internalBalance'] ?? json['balance'] ?? curBal as num?)?.toDouble() ?? curBal;
    final lastSyncRaw = json['lastSyncedAt']?.toString() ?? json['lastSynced']?.toString();
    final lastSync = lastSyncRaw != null && lastSyncRaw.contains('T')
        ? _formatIsoDate(lastSyncRaw)
        : (lastSyncRaw ?? 'Just now');
    final active = (json['status']?.toString().toUpperCase() != 'INACTIVE') &&
        (json['verificationStatus']?.toString().toUpperCase() != 'FAILED');

    List<AggregatedExpenseItem>? parsedExpenses;
    if (json['expenses'] is List) {
      parsedExpenses = (json['expenses'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => AggregatedExpenseItem.fromJson(e))
          .toList();
    }

    return BankAccountItem(
      id: json['id']?.toString() ?? '',
      bankName: bank,
      accountType: accType,
      maskedAccountNumber: masked,
      ifscCode: ifsc,
      accountHolder: holder,
      currentBalance: curBal,
      availableBalance: availBal,
      lastSynced: lastSync,
      isConnected: active,
      rawAccountNumber: rawNumber.isNotEmpty ? rawNumber : null,
      branch: json['branch']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      openingBalance: (json['openingBalance'] as num?)?.toDouble(),
      internalBalance: (json['internalBalance'] as num?)?.toDouble(),
      nickname: json['nickname']?.toString(),
      verificationStatus: json['verificationStatus']?.toString() ?? 'VERIFIED',
      status: json['status']?.toString() ?? 'ACTIVE',
      userId: json['userId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      lastSyncedAt: json['lastSyncedAt']?.toString(),
      expenses: parsedExpenses,
      debitCards: json['debitCards'] is List ? json['debitCards'] as List<dynamic> : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'accountType': accountType,
      'accountNumber': maskedAccountNumber,
      'rawAccountNumber': rawAccountNumber,
      'ifsc': ifscCode,
      'holderName': accountHolder,
      'currentBalance': currentBalance,
      'availableBalance': availableBalance,
      'branch': branch,
      'city': city,
      'state': state,
      'openingBalance': openingBalance,
      'internalBalance': internalBalance,
      'nickname': nickname,
      'verificationStatus': verificationStatus,
      'status': status,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastSyncedAt': lastSyncedAt,
    };
  }

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
    String? rawAccountNumber,
    String? branch,
    String? city,
    String? state,
    double? openingBalance,
    double? internalBalance,
    String? nickname,
    String? verificationStatus,
    String? status,
    String? userId,
    String? createdAt,
    String? updatedAt,
    String? lastSyncedAt,
    List<AggregatedExpenseItem>? expenses,
    List<dynamic>? debitCards,
  }) {
    final resolvedType = accountType != null
        ? (accountType.toUpperCase().contains('SAVING')
            ? 'Savings Account'
            : (accountType.toUpperCase().contains('CURRENT')
                ? 'Current Account'
                : (accountType.toUpperCase().contains('SALARY')
                    ? 'Salary Account'
                    : accountType)))
        : this.accountType;

    return BankAccountItem(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountType: resolvedType,
      maskedAccountNumber: maskedAccountNumber ?? this.maskedAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountHolder: accountHolder ?? this.accountHolder,
      currentBalance: currentBalance ?? this.currentBalance,
      availableBalance: availableBalance ?? this.availableBalance,
      lastSynced: lastSynced ?? this.lastSynced,
      isConnected: isConnected ?? this.isConnected,
      rawAccountNumber: rawAccountNumber ?? this.rawAccountNumber,
      branch: branch ?? this.branch,
      city: city ?? this.city,
      state: state ?? this.state,
      openingBalance: openingBalance ?? this.openingBalance,
      internalBalance: internalBalance ?? this.internalBalance,
      nickname: nickname ?? this.nickname,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      expenses: expenses ?? this.expenses,
      debitCards: debitCards ?? this.debitCards,
    );
  }
}

class FinancialPositions {
  final double totalCash;
  final double bankAccountsCash;
  final double walletsCash;
  final double totalInvestments;
  final double totalInvestedPrincipal;
  final double totalInvestmentReturns;
  final double totalDebt;
  final double creditCardsDebt;
  final double loansDebt;
  final double netWorth;
  final double creditUtilizationPercentage;
  final double monthlyEmiOutflow;
  final double totalInsuranceCover;

  const FinancialPositions({
    this.totalCash = 0.0,
    this.bankAccountsCash = 0.0,
    this.walletsCash = 0.0,
    this.totalInvestments = 0.0,
    this.totalInvestedPrincipal = 0.0,
    this.totalInvestmentReturns = 0.0,
    this.totalDebt = 0.0,
    this.creditCardsDebt = 0.0,
    this.loansDebt = 0.0,
    this.netWorth = 0.0,
    this.creditUtilizationPercentage = 0.0,
    this.monthlyEmiOutflow = 0.0,
    this.totalInsuranceCover = 0.0,
  });

  factory FinancialPositions.fromJson(Map<String, dynamic> json) {
    return FinancialPositions(
      totalCash: (json['totalCash'] as num?)?.toDouble() ?? 0.0,
      bankAccountsCash: (json['bankAccountsCash'] as num?)?.toDouble() ?? 0.0,
      walletsCash: (json['walletsCash'] as num?)?.toDouble() ?? 0.0,
      totalInvestments: (json['totalInvestments'] as num?)?.toDouble() ?? 0.0,
      totalInvestedPrincipal: (json['totalInvestedPrincipal'] as num?)?.toDouble() ?? 0.0,
      totalInvestmentReturns: (json['totalInvestmentReturns'] as num?)?.toDouble() ?? 0.0,
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
      creditCardsDebt: (json['creditCardsDebt'] as num?)?.toDouble() ?? 0.0,
      loansDebt: (json['loansDebt'] as num?)?.toDouble() ?? 0.0,
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0.0,
      creditUtilizationPercentage: (json['creditUtilizationPercentage'] as num?)?.toDouble() ?? 0.0,
      monthlyEmiOutflow: (json['monthlyEmiOutflow'] as num?)?.toDouble() ?? 0.0,
      totalInsuranceCover: (json['totalInsuranceCover'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalCash': totalCash,
    'bankAccountsCash': bankAccountsCash,
    'walletsCash': walletsCash,
    'totalInvestments': totalInvestments,
    'totalInvestedPrincipal': totalInvestedPrincipal,
    'totalInvestmentReturns': totalInvestmentReturns,
    'totalDebt': totalDebt,
    'creditCardsDebt': creditCardsDebt,
    'loansDebt': loansDebt,
    'netWorth': netWorth,
    'creditUtilizationPercentage': creditUtilizationPercentage,
    'monthlyEmiOutflow': monthlyEmiOutflow,
    'totalInsuranceCover': totalInsuranceCover,
  };
}

class PillarCounts {
  final int bankAccounts;
  final int creditCards;
  final int debitCards;
  final int totalCards;
  final int loans;
  final int investments;
  final int insurancePolicies;
  final int upiAccounts;
  final int digitalWallets;
  final int activeAaConsents;

  const PillarCounts({
    this.bankAccounts = 0,
    this.creditCards = 0,
    this.debitCards = 0,
    this.totalCards = 0,
    this.loans = 0,
    this.investments = 0,
    this.insurancePolicies = 0,
    this.upiAccounts = 0,
    this.digitalWallets = 0,
    this.activeAaConsents = 0,
  });

  factory PillarCounts.fromJson(Map<String, dynamic> json) {
    return PillarCounts(
      bankAccounts: (json['bankAccounts'] as num?)?.toInt() ?? 0,
      creditCards: (json['creditCards'] as num?)?.toInt() ?? 0,
      debitCards: (json['debitCards'] as num?)?.toInt() ?? 0,
      totalCards: (json['totalCards'] as num?)?.toInt() ?? 0,
      loans: (json['loans'] as num?)?.toInt() ?? 0,
      investments: (json['investments'] as num?)?.toInt() ?? 0,
      insurancePolicies: (json['insurancePolicies'] as num?)?.toInt() ?? 0,
      upiAccounts: (json['upiAccounts'] as num?)?.toInt() ?? 0,
      digitalWallets: (json['digitalWallets'] as num?)?.toInt() ?? 0,
      activeAaConsents: (json['activeAaConsents'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'bankAccounts': bankAccounts,
    'creditCards': creditCards,
    'debitCards': debitCards,
    'totalCards': totalCards,
    'loans': loans,
    'investments': investments,
    'insurancePolicies': insurancePolicies,
    'upiAccounts': upiAccounts,
    'digitalWallets': digitalWallets,
    'activeAaConsents': activeAaConsents,
  };
}

class AggregationInsights {
  final double debtToAssetRatio;
  final String creditHealthStatus;
  final int emergencyFundRunwayMonths;
  final String aiRecommendation;

  const AggregationInsights({
    this.debtToAssetRatio = 0.0,
    this.creditHealthStatus = 'HEALTHY',
    this.emergencyFundRunwayMonths = 1,
    this.aiRecommendation = '',
  });

  factory AggregationInsights.fromJson(Map<String, dynamic> json) {
    return AggregationInsights(
      debtToAssetRatio: (json['debtToAssetRatio'] as num?)?.toDouble() ?? 0.0,
      creditHealthStatus: json['creditHealthStatus']?.toString() ?? 'HEALTHY',
      emergencyFundRunwayMonths: (json['emergencyFundRunwayMonths'] as num?)?.toInt() ?? 1,
      aiRecommendation: json['aiRecommendation']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'debtToAssetRatio': debtToAssetRatio,
    'creditHealthStatus': creditHealthStatus,
    'emergencyFundRunwayMonths': emergencyFundRunwayMonths,
    'aiRecommendation': aiRecommendation,
  };
}

class BankAggregationSummary {
  final FinancialPositions financialPositions;
  final PillarCounts pillarCounts;
  final AggregationInsights insights;
  final List<dynamic> recentTransactions;
  final String lastSyncedAt;

  const BankAggregationSummary({
    this.financialPositions = const FinancialPositions(),
    this.pillarCounts = const PillarCounts(),
    this.insights = const AggregationInsights(),
    this.recentTransactions = const [],
    this.lastSyncedAt = '',
  });

  factory BankAggregationSummary.fromJson(Map<String, dynamic> json) {
    return BankAggregationSummary(
      financialPositions: json['financialPositions'] is Map<String, dynamic>
          ? FinancialPositions.fromJson(json['financialPositions'])
          : const FinancialPositions(),
      pillarCounts: json['pillarCounts'] is Map<String, dynamic>
          ? PillarCounts.fromJson(json['pillarCounts'])
          : const PillarCounts(),
      insights: json['insights'] is Map<String, dynamic>
          ? AggregationInsights.fromJson(json['insights'])
          : const AggregationInsights(),
      recentTransactions: json['recentTransactions'] is List ? json['recentTransactions'] : const [],
      lastSyncedAt: json['lastSyncedAt']?.toString() ?? '',
    );
  }
}

class SyncAllPillarsResult {
  final String syncedAt;
  final List<String> refreshedPillars;
  final String syncStatus;

  const SyncAllPillarsResult({
    this.syncedAt = '',
    this.refreshedPillars = const [],
    this.syncStatus = 'SUCCESS',
  });

  factory SyncAllPillarsResult.fromJson(Map<String, dynamic> json) {
    return SyncAllPillarsResult(
      syncedAt: json['syncedAt']?.toString() ?? '',
      refreshedPillars: json['refreshedPillars'] is List
          ? (json['refreshedPillars'] as List).map((e) => e.toString()).toList()
          : const [],
      syncStatus: json['syncStatus']?.toString() ?? 'SUCCESS',
    );
  }
}

class IfscBranchDetails {
  final String ifsc;
  final String bank;
  final String bankName;
  final String bankCode;
  final String branch;
  final String address;
  final String city;
  final String district;
  final String state;
  final String contact;
  final String micr;
  final bool rtgs;
  final bool neft;
  final bool imps;
  final bool upi;
  final bool valid;
  final bool cached;

  const IfscBranchDetails({
    required this.ifsc,
    this.bank = '',
    this.bankName = '',
    this.bankCode = '',
    this.branch = '',
    this.address = '',
    this.city = '',
    this.district = '',
    this.state = '',
    this.contact = '',
    this.micr = '',
    this.rtgs = true,
    this.neft = true,
    this.imps = true,
    this.upi = true,
    this.valid = true,
    this.cached = false,
  });

  factory IfscBranchDetails.fromJson(Map<String, dynamic> json) {
    return IfscBranchDetails(
      ifsc: json['ifsc']?.toString() ?? '',
      bank: json['bank']?.toString() ?? json['bankName']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? json['bank']?.toString() ?? '',
      bankCode: json['bankCode']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      micr: json['micr']?.toString() ?? '',
      rtgs: json['rtgs'] == true,
      neft: json['neft'] == true,
      imps: json['imps'] == true,
      upi: json['upi'] == true,
      valid: json['valid'] != false,
      cached: json['cached'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'ifsc': ifsc,
    'bank': bank,
    'bankName': bankName,
    'bankCode': bankCode,
    'branch': branch,
    'address': address,
    'city': city,
    'district': district,
    'state': state,
    'contact': contact,
    'micr': micr,
    'rtgs': rtgs,
    'neft': neft,
    'imps': imps,
    'upi': upi,
    'valid': valid,
    'cached': cached,
  };
}

class AggregatedExpenseItem {
  final String id;
  final double amount;
  final String date;
  final String category;
  final String description;
  final String paymentMode;
  final String invoiceNumber;
  final String priority;
  final String merchant;
  final double balanceAfter;
  final bool isVerified;

  const AggregatedExpenseItem({
    required this.id,
    required this.amount,
    required this.date,
    required this.category,
    required this.description,
    required this.paymentMode,
    this.invoiceNumber = '',
    this.priority = '',
    this.merchant = '',
    this.balanceAfter = 0.0,
    this.isVerified = true,
  });

  factory AggregatedExpenseItem.fromJson(Map<String, dynamic> json) {
    return AggregatedExpenseItem(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      paymentMode: json['paymentMode']?.toString() ?? 'UPI',
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      merchant: json['merchant']?.toString() ?? '',
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['isVerified'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'date': date,
    'category': category,
    'description': description,
    'paymentMode': paymentMode,
    'invoiceNumber': invoiceNumber,
    'priority': priority,
    'merchant': merchant,
    'balanceAfter': balanceAfter,
    'isVerified': isVerified,
  };
}

class LinkBankAccountRequest {
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifsc;
  final String accountType;
  final double openingBalance;
  final String holderName;
  final String nickname;

  const LinkBankAccountRequest({
    required this.accountNumber,
    required this.confirmAccountNumber,
    required this.ifsc,
    required this.accountType,
    required this.openingBalance,
    required this.holderName,
    required this.nickname,
  });

  Map<String, dynamic> toJson() => {
    'accountNumber': accountNumber,
    'confirmAccountNumber': confirmAccountNumber,
    'ifsc': ifsc,
    'accountType': accountType,
    'openingBalance': openingBalance,
    'holderName': holderName,
    'nickname': nickname,
  };
}

class UpdateBankAccountRequest {
  final String nickname;
  final String accountType;

  const UpdateBankAccountRequest({
    required this.nickname,
    required this.accountType,
  });

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'accountType': accountType,
  };
}

class SyncAccountBalanceResult {
  final String accountId;
  final double currentBalance;
  final String lastSyncedAt;

  const SyncAccountBalanceResult({
    required this.accountId,
    required this.currentBalance,
    required this.lastSyncedAt,
  });

  factory SyncAccountBalanceResult.fromJson(Map<String, dynamic> json) {
    return SyncAccountBalanceResult(
      accountId: json['accountId']?.toString() ?? '',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      lastSyncedAt: json['lastSyncedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'currentBalance': currentBalance,
    'lastSyncedAt': lastSyncedAt,
  };
}

class UpiAccountsApiResponse {
  final bool success;
  final int count;
  final String? primaryVpa;
  final List<UpiAccountItem> accounts;

  const UpiAccountsApiResponse({
    required this.success,
    required this.count,
    this.primaryVpa,
    required this.accounts,
  });

  factory UpiAccountsApiResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] is List ? json['data'] as List : [];
    return UpiAccountsApiResponse(
      success: json['success'] == true,
      count: (json['count'] as num?)?.toInt() ?? list.length,
      primaryVpa: json['primaryVpa']?.toString(),
      accounts: list
          .whereType<Map<String, dynamic>>()
          .map((e) => UpiAccountItem.fromJson(e))
          .toList(),
    );
  }
}

class LinkUpiAccountRequest {
  final String vpa;
  final String bankName;
  final String appProvider;
  final bool isPrimary;

  const LinkUpiAccountRequest({
    required this.vpa,
    required this.bankName,
    required this.appProvider,
    this.isPrimary = true,
  });

  Map<String, dynamic> toJson() => {
    'vpa': vpa,
    'bankName': bankName,
    'appProvider': appProvider,
    'isPrimary': isPrimary,
  };
}

class UpiAccountItem {
  final String id;
  final String upiId; // e.g. sireesha@okaxis
  final String provider; // Google Pay, PhonePe, Paytm, BHIM
  final String linkedBank;
  final bool isPrimary;
  final String status;

  // Live API server fields
  final String? userId;
  final String? vpa;
  final String? bankName;
  final String? bankAccountId;
  final String? appProvider;
  final String? createdAt;
  final String? updatedAt;

  const UpiAccountItem({
    required this.id,
    required this.upiId,
    required this.provider,
    required this.linkedBank,
    this.isPrimary = false,
    this.status = 'ACTIVE',
    this.userId,
    this.vpa,
    this.bankName,
    this.bankAccountId,
    this.appProvider,
    this.createdAt,
    this.updatedAt,
  });

  factory UpiAccountItem.fromJson(Map<String, dynamic> json) {
    final rawVpa = json['vpa']?.toString() ?? json['upiId']?.toString() ?? '';
    final rawBank = json['bankName']?.toString() ?? json['linkedBank']?.toString() ?? 'Bank';
    final rawApp = json['appProvider']?.toString() ?? json['provider']?.toString() ?? 'UPI';
    final rawPrimary = json['isPrimary'] == true;
    final rawStatus = json['status']?.toString() ?? 'ACTIVE';

    return UpiAccountItem(
      id: json['id']?.toString() ?? '',
      upiId: rawVpa,
      provider: rawApp,
      linkedBank: rawBank,
      isPrimary: rawPrimary,
      status: rawStatus,
      userId: json['userId']?.toString(),
      vpa: rawVpa,
      bankName: rawBank,
      bankAccountId: json['bankAccountId']?.toString(),
      appProvider: rawApp,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'vpa': vpa ?? upiId,
    'bankName': bankName ?? linkedBank,
    'bankAccountId': bankAccountId,
    'appProvider': appProvider ?? provider,
    'isPrimary': isPrimary,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  UpiAccountItem copyWith({
    String? id,
    String? upiId,
    String? provider,
    String? linkedBank,
    bool? isPrimary,
    String? status,
    String? userId,
    String? vpa,
    String? bankName,
    String? bankAccountId,
    String? appProvider,
    String? createdAt,
    String? updatedAt,
  }) {
    return UpiAccountItem(
      id: id ?? this.id,
      upiId: upiId ?? this.upiId,
      provider: provider ?? this.provider,
      linkedBank: linkedBank ?? this.linkedBank,
      isPrimary: isPrimary ?? this.isPrimary,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      vpa: vpa ?? this.vpa,
      bankName: bankName ?? this.bankName,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      appProvider: appProvider ?? this.appProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// -----------------------------------------------------------------------------
// CARDS MODELS (CREDIT & DEBIT CARDS)
// -----------------------------------------------------------------------------

class CardsSummary {
  final int totalCreditCards;
  final int totalDebitCards;
  final double totalCreditLimit;
  final double totalOutstanding;
  final double totalAvailableCredit;
  final int totalRewardPoints;
  final double utilizationPercentage;

  const CardsSummary({
    this.totalCreditCards = 0,
    this.totalDebitCards = 0,
    this.totalCreditLimit = 0.0,
    this.totalOutstanding = 0.0,
    this.totalAvailableCredit = 0.0,
    this.totalRewardPoints = 0,
    this.utilizationPercentage = 0.0,
  });

  factory CardsSummary.fromJson(Map<String, dynamic> json) {
    return CardsSummary(
      totalCreditCards: (json['totalCreditCards'] as num?)?.toInt() ?? 0,
      totalDebitCards: (json['totalDebitCards'] as num?)?.toInt() ?? 0,
      totalCreditLimit: (json['totalCreditLimit'] as num?)?.toDouble() ?? 0.0,
      totalOutstanding: (json['totalOutstanding'] as num?)?.toDouble() ?? 0.0,
      totalAvailableCredit: (json['totalAvailableCredit'] as num?)?.toDouble() ?? 0.0,
      totalRewardPoints: (json['totalRewardPoints'] as num?)?.toInt() ?? 0,
      utilizationPercentage: (json['utilizationPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalCreditCards': totalCreditCards,
    'totalDebitCards': totalDebitCards,
    'totalCreditLimit': totalCreditLimit,
    'totalOutstanding': totalOutstanding,
    'totalAvailableCredit': totalAvailableCredit,
    'totalRewardPoints': totalRewardPoints,
    'utilizationPercentage': utilizationPercentage,
  };
}

class CardsApiResponse {
  final CardsSummary summary;
  final List<CreditCardItem> creditCards;
  final List<CreditCardItem> debitCards;

  const CardsApiResponse({
    this.summary = const CardsSummary(),
    this.creditCards = const [],
    this.debitCards = const [],
  });

  factory CardsApiResponse.fromJson(Map<String, dynamic> json) {
    final summaryMap = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    List<CreditCardItem> parsedCreditCards = [];
    if (dataMap['creditCards'] is List) {
      parsedCreditCards = (dataMap['creditCards'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => CreditCardItem.fromJson(c))
          .toList();
    }

    List<CreditCardItem> parsedDebitCards = [];
    if (dataMap['debitCards'] is List) {
      parsedDebitCards = (dataMap['debitCards'] as List)
          .whereType<Map<String, dynamic>>()
          .map((d) => CreditCardItem.fromJson(d))
          .toList();
    }

    return CardsApiResponse(
      summary: CardsSummary.fromJson(summaryMap),
      creditCards: parsedCreditCards,
      debitCards: parsedDebitCards,
    );
  }
}

class CreditCardItem {
  final String id;
  final String cardName; // HDFC Regalia Gold, HDFC Millennia Debit Card, etc.
  final String last4Digits; // 4567
  final String? cardNumber; // Full 12 to 16 digit card number
  final String? cvv; // 3-digit CVV
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
  final bool isDebit; // true for Debit Cards, false for Credit Cards
  final double? dailyAtmLimit; // e.g. 50,000
  final double? dailyPosLimit; // e.g. 100,000
  final String? linkedAccount; // e.g. Primary Savings A/C (••••6789)

  // Live API fields
  final String? userId;
  final String? network;
  final String? billingCycleDate;
  final double? totalCashLimit;
  final String? expiryMonth;
  final String? expiryYear;
  final String? status;
  final bool? isAggregated;
  final String? verificationStatus;
  final String? color;
  final String? createdAt;
  final String? updatedAt;

  const CreditCardItem({
    required this.id,
    required this.cardName,
    required this.last4Digits,
    this.cardNumber,
    this.cvv,
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
    this.isDebit = false,
    this.dailyAtmLimit,
    this.dailyPosLimit,
    this.linkedAccount,
    this.userId,
    this.network,
    this.billingCycleDate,
    this.totalCashLimit,
    this.expiryMonth,
    this.expiryYear,
    this.status,
    this.isAggregated,
    this.verificationStatus,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  double get utilizationRatio => (!isDebit && creditLimit > 0) ? (outstandingBalance / creditLimit) : 0.0;
  String get utilizationPercent => (utilizationRatio * 100).toStringAsFixed(1);

  factory CreditCardItem.fromJson(Map<String, dynamic> json) {
    final rawType = json['cardType']?.toString() ?? 'Credit';
    final isDebit = rawType.toLowerCase() == 'debit';
    final name = json['cardNickname']?.toString() ??
        json['cardName']?.toString() ??
        '${json['issuingBank'] ?? 'Credit'} Card';
    final last4 = json['lastFourDigits']?.toString() ??
        json['last4Digits']?.toString() ??
        '';
    final limit = (json['creditLimit'] as num?)?.toDouble() ?? 0.0;
    final outstanding = (json['currentOutstanding'] ?? json['outstandingBalance'] as num?)?.toDouble() ?? 0.0;
    final available = (json['availableCredit'] as num?)?.toDouble() ??
        (limit - outstanding).clamp(0.0, double.infinity);
    final dueDate = json['paymentDueDate']?.toString() ??
        json['statementDueDate']?.toString() ??
        '20th of month';
    final minDue = (json['minimumDue'] as num?)?.toDouble() ?? 0.0;
    final points = (json['rewardPoints'] as num?)?.toInt() ?? 0;
    final expMonth = json['expiryMonth']?.toString();
    final expYear = json['expiryYear']?.toString();
    final expiry = json['expiryDate']?.toString() ??
        (expMonth != null && expYear != null ? '$expMonth/$expYear' : null);

    return CreditCardItem(
      id: json['id']?.toString() ?? '',
      cardName: name,
      last4Digits: last4,
      creditLimit: limit,
      outstandingBalance: outstanding,
      availableCredit: available,
      statementDueDate: dueDate,
      minimumDue: minDue,
      rewardPoints: points,
      cardHolderName: json['cardholderName']?.toString() ?? json['cardHolderName']?.toString(),
      issuedBank: json['issuingBank']?.toString() ?? json['issuedBank']?.toString(),
      cardType: json['network']?.toString() ?? json['cardType']?.toString(),
      expiryDate: expiry,
      isDebit: isDebit,
      userId: json['userId']?.toString(),
      network: json['network']?.toString(),
      billingCycleDate: json['billingCycleDate']?.toString(),
      totalCashLimit: (json['totalCashLimit'] as num?)?.toDouble(),
      expiryMonth: expMonth,
      expiryYear: expYear,
      status: json['status']?.toString() ?? 'Active',
      isAggregated: json['isAggregated'] == true,
      verificationStatus: json['verificationStatus']?.toString() ?? 'AA Verified',
      color: json['color']?.toString() ?? '#1B2559',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardName': cardName,
    'cardNickname': cardName,
    'last4Digits': last4Digits,
    'lastFourDigits': last4Digits,
    'creditLimit': creditLimit,
    'outstandingBalance': outstandingBalance,
    'currentOutstanding': outstandingBalance,
    'availableCredit': availableCredit,
    'statementDueDate': statementDueDate,
    'paymentDueDate': statementDueDate,
    'minimumDue': minimumDue,
    'rewardPoints': rewardPoints,
    'cardHolderName': cardHolderName,
    'cardholderName': cardHolderName,
    'issuedBank': issuedBank,
    'issuingBank': issuedBank,
    'cardType': isDebit ? 'Debit' : 'Credit',
    'network': network ?? cardType,
    'expiryDate': expiryDate,
    'isDebit': isDebit,
    'userId': userId,
    'billingCycleDate': billingCycleDate,
    'totalCashLimit': totalCashLimit,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'status': status,
    'isAggregated': isAggregated,
    'verificationStatus': verificationStatus,
    'color': color,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  CreditCardItem copyWith({
    String? id,
    String? cardName,
    String? last4Digits,
    String? cardNumber,
    String? cvv,
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
    bool? isDebit,
    double? dailyAtmLimit,
    double? dailyPosLimit,
    String? linkedAccount,
    String? userId,
    String? network,
    String? billingCycleDate,
    double? totalCashLimit,
    String? expiryMonth,
    String? expiryYear,
    String? status,
    bool? isAggregated,
    String? verificationStatus,
    String? color,
    String? createdAt,
    String? updatedAt,
  }) {
    return CreditCardItem(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      last4Digits: last4Digits ?? this.last4Digits,
      cardNumber: cardNumber ?? this.cardNumber,
      cvv: cvv ?? this.cvv,
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
      isDebit: isDebit ?? this.isDebit,
      dailyAtmLimit: dailyAtmLimit ?? this.dailyAtmLimit,
      dailyPosLimit: dailyPosLimit ?? this.dailyPosLimit,
      linkedAccount: linkedAccount ?? this.linkedAccount,
      userId: userId ?? this.userId,
      network: network ?? this.network,
      billingCycleDate: billingCycleDate ?? this.billingCycleDate,
      totalCashLimit: totalCashLimit ?? this.totalCashLimit,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      status: status ?? this.status,
      isAggregated: isAggregated ?? this.isAggregated,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LinkCreditCardRequest {
  final String cardType; // "Credit" or "Debit"
  final String issuingBank;
  final String cardholderName;
  final String network;
  final String lastFourDigits;
  final double creditLimit;
  final double currentOutstanding;
  final String billingCycleDate;
  final String paymentDueDate;
  final int rewardPoints;

  const LinkCreditCardRequest({
    this.cardType = 'Credit',
    required this.issuingBank,
    required this.cardholderName,
    required this.network,
    required this.lastFourDigits,
    required this.creditLimit,
    required this.currentOutstanding,
    this.billingCycleDate = '20th of month',
    this.paymentDueDate = '2026-12-10',
    this.rewardPoints = 0,
  });

  Map<String, dynamic> toJson() => {
    'cardType': cardType,
    'issuingBank': issuingBank,
    'cardholderName': cardholderName,
    'network': network,
    'lastFourDigits': lastFourDigits,
    'creditLimit': creditLimit,
    'currentOutstanding': currentOutstanding,
    'billingCycleDate': billingCycleDate,
    'paymentDueDate': paymentDueDate,
    'rewardPoints': rewardPoints,
  };
}

class UpdateCreditCardRequest {
  final double? creditLimit;
  final double? currentOutstanding;
  final String? cardNickname;

  const UpdateCreditCardRequest({
    this.creditLimit,
    this.currentOutstanding,
    this.cardNickname,
  });

  Map<String, dynamic> toJson() => {
    if (creditLimit != null) 'creditLimit': creditLimit,
    if (currentOutstanding != null) 'currentOutstanding': currentOutstanding,
    if (cardNickname != null) 'cardNickname': cardNickname,
  };
}

// -----------------------------------------------------------------------------
// LOANS MODELS
// -----------------------------------------------------------------------------

class LoansSummary {
  final double totalSanctionedAmount;
  final double totalOutstandingPrincipal;
  final double totalMonthlyEmiBurden;

  const LoansSummary({
    this.totalSanctionedAmount = 0.0,
    this.totalOutstandingPrincipal = 0.0,
    this.totalMonthlyEmiBurden = 0.0,
  });

  factory LoansSummary.fromJson(Map<String, dynamic> json) {
    return LoansSummary(
      totalSanctionedAmount: (json['totalSanctionedAmount'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingPrincipal: (json['totalOutstandingPrincipal'] as num?)?.toDouble() ?? 0.0,
      totalMonthlyEmiBurden: (json['totalMonthlyEmiBurden'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalSanctionedAmount': totalSanctionedAmount,
    'totalOutstandingPrincipal': totalOutstandingPrincipal,
    'totalMonthlyEmiBurden': totalMonthlyEmiBurden,
  };
}

class LoansApiResponse {
  final int count;
  final LoansSummary summary;
  final List<LoanAccountItem> loans;

  const LoansApiResponse({
    this.count = 0,
    this.summary = const LoansSummary(),
    this.loans = const [],
  });

  factory LoansApiResponse.fromJson(Map<String, dynamic> json) {
    final summaryMap = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};
    List<LoanAccountItem> parsedLoans = [];
    if (json['data'] is List) {
      parsedLoans = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((l) => LoanAccountItem.fromJson(l))
          .toList();
    }
    return LoansApiResponse(
      count: (json['count'] as num?)?.toInt() ?? parsedLoans.length,
      summary: LoansSummary.fromJson(summaryMap),
      loans: parsedLoans,
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

  // Live API fields
  final String? userId;
  final String? accountNumber;
  final double? sanctionedAmount;
  final int? totalTenureMonths;
  final String? startDate;
  final String? endDate;
  final String? interestType;
  final String? status;
  final bool? isAggregated;
  final String? createdAt;
  final String? updatedAt;

  const LoanAccountItem({
    required this.id,
    required this.loanType,
    required this.lender,
    required this.outstandingPrincipal,
    required this.interestRate,
    required this.monthlyEmi,
    required this.tenureRemainingMonths,
    required this.nextDueDate,
    this.userId,
    this.accountNumber,
    this.sanctionedAmount,
    this.totalTenureMonths,
    this.startDate,
    this.endDate,
    this.interestType,
    this.status,
    this.isAggregated,
    this.createdAt,
    this.updatedAt,
  });

  factory LoanAccountItem.fromJson(Map<String, dynamic> json) {
    return LoanAccountItem(
      id: json['id']?.toString() ?? '',
      loanType: json['loanType']?.toString() ?? 'Home Loan',
      lender: json['lenderName']?.toString() ?? json['lender']?.toString() ?? 'Lender Bank',
      outstandingPrincipal: (json['outstandingPrincipal'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      monthlyEmi: (json['monthlyEmi'] as num?)?.toDouble() ?? 0.0,
      tenureRemainingMonths: (json['remainingTenureMonths'] ?? json['tenureRemainingMonths'] as num?)?.toInt() ?? 0,
      nextDueDate: json['nextEmiDate']?.toString() ?? json['nextDueDate']?.toString() ?? '',
      userId: json['userId']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
      sanctionedAmount: (json['sanctionedAmount'] as num?)?.toDouble(),
      totalTenureMonths: (json['totalTenureMonths'] as num?)?.toInt(),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      interestType: json['interestType']?.toString() ?? 'Floating',
      status: json['status']?.toString() ?? 'ACTIVE',
      isAggregated: json['isAggregated'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'loanType': loanType,
    'lender': lender,
    'lenderName': lender,
    'outstandingPrincipal': outstandingPrincipal,
    'interestRate': interestRate,
    'monthlyEmi': monthlyEmi,
    'tenureRemainingMonths': tenureRemainingMonths,
    'remainingTenureMonths': tenureRemainingMonths,
    'nextDueDate': nextDueDate,
    'nextEmiDate': nextDueDate,
    'userId': userId,
    'accountNumber': accountNumber,
    'sanctionedAmount': sanctionedAmount,
    'totalTenureMonths': totalTenureMonths,
    'startDate': startDate,
    'endDate': endDate,
    'interestType': interestType,
    'status': status,
    'isAggregated': isAggregated,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  LoanAccountItem copyWith({
    String? id,
    String? loanType,
    String? lender,
    double? outstandingPrincipal,
    double? interestRate,
    double? monthlyEmi,
    int? tenureRemainingMonths,
    String? nextDueDate,
    String? userId,
    String? accountNumber,
    double? sanctionedAmount,
    int? totalTenureMonths,
    String? startDate,
    String? endDate,
    String? interestType,
    String? status,
    bool? isAggregated,
    String? createdAt,
    String? updatedAt,
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
      userId: userId ?? this.userId,
      accountNumber: accountNumber ?? this.accountNumber,
      sanctionedAmount: sanctionedAmount ?? this.sanctionedAmount,
      totalTenureMonths: totalTenureMonths ?? this.totalTenureMonths,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      interestType: interestType ?? this.interestType,
      status: status ?? this.status,
      isAggregated: isAggregated ?? this.isAggregated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LinkLoanRequest {
  final String lenderName;
  final String loanType;
  final String accountNumber;
  final double sanctionedAmount;
  final double outstandingPrincipal;
  final double interestRate;
  final double monthlyEmi;
  final int totalTenureMonths;
  final int remainingTenureMonths;
  final String nextEmiDate;

  const LinkLoanRequest({
    required this.lenderName,
    required this.loanType,
    required this.accountNumber,
    required this.sanctionedAmount,
    required this.outstandingPrincipal,
    required this.interestRate,
    required this.monthlyEmi,
    required this.totalTenureMonths,
    required this.remainingTenureMonths,
    required this.nextEmiDate,
  });

  Map<String, dynamic> toJson() => {
    'lenderName': lenderName,
    'loanType': loanType,
    'accountNumber': accountNumber,
    'sanctionedAmount': sanctionedAmount,
    'outstandingPrincipal': outstandingPrincipal,
    'interestRate': interestRate,
    'monthlyEmi': monthlyEmi,
    'totalTenureMonths': totalTenureMonths,
    'remainingTenureMonths': remainingTenureMonths,
    'nextEmiDate': nextEmiDate,
  };
}

class UpdateLoanRequest {
  final double? outstandingPrincipal;
  final int? remainingTenureMonths;

  const UpdateLoanRequest({
    this.outstandingPrincipal,
    this.remainingTenureMonths,
  });

  Map<String, dynamic> toJson() => {
    if (outstandingPrincipal != null) 'outstandingPrincipal': outstandingPrincipal,
    if (remainingTenureMonths != null) 'remainingTenureMonths': remainingTenureMonths,
  };
}

// -----------------------------------------------------------------------------
// INVESTMENTS MODELS
// -----------------------------------------------------------------------------

class InvestmentAssetAllocation {
  final int count;
  final double currentValue;
  final double investedAmount;

  const InvestmentAssetAllocation({
    this.count = 0,
    this.currentValue = 0.0,
    this.investedAmount = 0.0,
  });

  factory InvestmentAssetAllocation.fromJson(Map<String, dynamic> json) {
    return InvestmentAssetAllocation(
      count: (json['count'] as num?)?.toInt() ?? 0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      investedAmount: (json['investedAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'count': count,
    'currentValue': currentValue,
    'investedAmount': investedAmount,
  };
}

class PortfolioSummary {
  final double totalInvestedAmount;
  final double totalCurrentValue;
  final double totalAbsoluteReturns;
  final double overallReturnPercentage;
  final Map<String, InvestmentAssetAllocation> assetAllocation;

  const PortfolioSummary({
    this.totalInvestedAmount = 0.0,
    this.totalCurrentValue = 0.0,
    this.totalAbsoluteReturns = 0.0,
    this.overallReturnPercentage = 0.0,
    this.assetAllocation = const {},
  });

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    final allocMap = <String, InvestmentAssetAllocation>{};
    if (json['assetAllocation'] is Map<String, dynamic>) {
      final map = json['assetAllocation'] as Map<String, dynamic>;
      map.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          allocMap[k] = InvestmentAssetAllocation.fromJson(v);
        }
      });
    }

    return PortfolioSummary(
      totalInvestedAmount: (json['totalInvestedAmount'] as num?)?.toDouble() ?? 0.0,
      totalCurrentValue: (json['totalCurrentValue'] as num?)?.toDouble() ?? 0.0,
      totalAbsoluteReturns: (json['totalAbsoluteReturns'] as num?)?.toDouble() ?? 0.0,
      overallReturnPercentage: (json['overallReturnPercentage'] as num?)?.toDouble() ?? 0.0,
      assetAllocation: allocMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalInvestedAmount': totalInvestedAmount,
    'totalCurrentValue': totalCurrentValue,
    'totalAbsoluteReturns': totalAbsoluteReturns,
    'overallReturnPercentage': overallReturnPercentage,
    'assetAllocation': assetAllocation.map((k, v) => MapEntry(k, v.toJson())),
  };
}

class InvestmentsApiResponse {
  final int count;
  final PortfolioSummary portfolioSummary;
  final List<InvestmentHoldingItem> investments;

  const InvestmentsApiResponse({
    this.count = 0,
    this.portfolioSummary = const PortfolioSummary(),
    this.investments = const [],
  });

  factory InvestmentsApiResponse.fromJson(Map<String, dynamic> json) {
    final summaryMap = json['portfolioSummary'] is Map<String, dynamic>
        ? json['portfolioSummary'] as Map<String, dynamic>
        : <String, dynamic>{};
    List<InvestmentHoldingItem> parsedInv = [];
    if (json['data'] is List) {
      parsedInv = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => InvestmentHoldingItem.fromJson(i))
          .toList();
    }
    return InvestmentsApiResponse(
      count: (json['count'] as num?)?.toInt() ?? parsedInv.length,
      portfolioSummary: PortfolioSummary.fromJson(summaryMap),
      investments: parsedInv,
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

  // Live API fields
  final String? userId;
  final String? name;
  final String? symbolOrFolio;
  final String? platform;
  final double? quantity;
  final double? buyNavOrPrice;
  final double? currentNavOrPrice;
  final double? absoluteReturn;
  final double? xirr;
  final String? asOfDate;
  final bool? isAggregated;
  final String? createdAt;
  final String? updatedAt;

  const InvestmentHoldingItem({
    required this.id,
    required this.assetType,
    required this.institution,
    required this.currentValue,
    required this.investedValue,
    required this.returnPercentage,
    this.isPositive = true,
    this.userId,
    this.name,
    this.symbolOrFolio,
    this.platform,
    this.quantity,
    this.buyNavOrPrice,
    this.currentNavOrPrice,
    this.absoluteReturn,
    this.xirr,
    this.asOfDate,
    this.isAggregated,
    this.createdAt,
    this.updatedAt,
  });

  factory InvestmentHoldingItem.fromJson(Map<String, dynamic> json) {
    final curVal = (json['currentValue'] as num?)?.toDouble() ?? 0.0;
    final invVal = (json['investedAmount'] ?? json['investedValue'] as num?)?.toDouble() ?? 0.0;
    final retPct = (json['returnPercentage'] as num?)?.toDouble() ?? 0.0;
    final absRet = (json['absoluteReturn'] as num?)?.toDouble() ?? (curVal - invVal);
    final inst = json['platform']?.toString() ??
        json['institution']?.toString() ??
        json['name']?.toString() ??
        'Groww';

    return InvestmentHoldingItem(
      id: json['id']?.toString() ?? '',
      assetType: json['assetType']?.toString() ?? 'Mutual Funds',
      institution: inst,
      currentValue: curVal,
      investedValue: invVal,
      returnPercentage: retPct,
      isPositive: retPct >= 0,
      userId: json['userId']?.toString(),
      name: json['name']?.toString(),
      symbolOrFolio: json['symbolOrFolio']?.toString(),
      platform: json['platform']?.toString(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      buyNavOrPrice: (json['buyNavOrPrice'] as num?)?.toDouble(),
      currentNavOrPrice: (json['currentNavOrPrice'] as num?)?.toDouble(),
      absoluteReturn: absRet,
      xirr: (json['xirr'] as num?)?.toDouble(),
      asOfDate: json['asOfDate']?.toString(),
      isAggregated: json['isAggregated'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetType': assetType,
    'institution': institution,
    'currentValue': currentValue,
    'investedValue': investedValue,
    'investedAmount': investedValue,
    'returnPercentage': returnPercentage,
    'isPositive': isPositive,
    'userId': userId,
    'name': name,
    'symbolOrFolio': symbolOrFolio,
    'platform': platform,
    'quantity': quantity,
    'buyNavOrPrice': buyNavOrPrice,
    'currentNavOrPrice': currentNavOrPrice,
    'absoluteReturn': absoluteReturn,
    'xirr': xirr,
    'asOfDate': asOfDate,
    'isAggregated': isAggregated,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  InvestmentHoldingItem copyWith({
    String? id,
    String? assetType,
    String? institution,
    double? currentValue,
    double? investedValue,
    double? returnPercentage,
    bool? isPositive,
    String? userId,
    String? name,
    String? symbolOrFolio,
    String? platform,
    double? quantity,
    double? buyNavOrPrice,
    double? currentNavOrPrice,
    double? absoluteReturn,
    double? xirr,
    String? asOfDate,
    bool? isAggregated,
    String? createdAt,
    String? updatedAt,
  }) {
    return InvestmentHoldingItem(
      id: id ?? this.id,
      assetType: assetType ?? this.assetType,
      institution: institution ?? this.institution,
      currentValue: currentValue ?? this.currentValue,
      investedValue: investedValue ?? this.investedValue,
      returnPercentage: returnPercentage ?? this.returnPercentage,
      isPositive: isPositive ?? this.isPositive,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      symbolOrFolio: symbolOrFolio ?? this.symbolOrFolio,
      platform: platform ?? this.platform,
      quantity: quantity ?? this.quantity,
      buyNavOrPrice: buyNavOrPrice ?? this.buyNavOrPrice,
      currentNavOrPrice: currentNavOrPrice ?? this.currentNavOrPrice,
      absoluteReturn: absoluteReturn ?? this.absoluteReturn,
      xirr: xirr ?? this.xirr,
      asOfDate: asOfDate ?? this.asOfDate,
      isAggregated: isAggregated ?? this.isAggregated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LinkInvestmentRequest {
  final String assetType;
  final String name;
  final String symbolOrFolio;
  final String platform;
  final double quantity;
  final double buyNavOrPrice;
  final double currentNavOrPrice;

  const LinkInvestmentRequest({
    required this.assetType,
    required this.name,
    required this.symbolOrFolio,
    required this.platform,
    required this.quantity,
    required this.buyNavOrPrice,
    required this.currentNavOrPrice,
  });

  Map<String, dynamic> toJson() => {
    'assetType': assetType,
    'name': name,
    'symbolOrFolio': symbolOrFolio,
    'platform': platform,
    'quantity': quantity,
    'buyNavOrPrice': buyNavOrPrice,
    'currentNavOrPrice': currentNavOrPrice,
  };
}

class UpdateInvestmentRequest {
  final double currentNavOrPrice;

  const UpdateInvestmentRequest({
    required this.currentNavOrPrice,
  });

  Map<String, dynamic> toJson() => {
    'currentNavOrPrice': currentNavOrPrice,
  };
}

class InsuranceSummary {
  final double totalSumInsuredCoverage;
  final double totalAnnualPremiumOutflow;
  final int activePoliciesCount;

  const InsuranceSummary({
    required this.totalSumInsuredCoverage,
    required this.totalAnnualPremiumOutflow,
    required this.activePoliciesCount,
  });

  factory InsuranceSummary.fromJson(Map<String, dynamic> json) {
    return InsuranceSummary(
      totalSumInsuredCoverage: (json['totalSumInsuredCoverage'] as num?)?.toDouble() ?? 0.0,
      totalAnnualPremiumOutflow: (json['totalAnnualPremiumOutflow'] as num?)?.toDouble() ?? 0.0,
      activePoliciesCount: (json['activePoliciesCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalSumInsuredCoverage': totalSumInsuredCoverage,
    'totalAnnualPremiumOutflow': totalAnnualPremiumOutflow,
    'activePoliciesCount': activePoliciesCount,
  };
}

class InsurancePoliciesApiResponse {
  final bool success;
  final int count;
  final InsuranceSummary summary;
  final List<InsurancePolicyItem> policies;

  const InsurancePoliciesApiResponse({
    required this.success,
    required this.count,
    required this.summary,
    required this.policies,
  });

  factory InsurancePoliciesApiResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] is List ? json['data'] as List : [];
    return InsurancePoliciesApiResponse(
      success: json['success'] == true,
      count: (json['count'] as num?)?.toInt() ?? list.length,
      summary: json['summary'] is Map<String, dynamic>
          ? InsuranceSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : const InsuranceSummary(totalSumInsuredCoverage: 0, totalAnnualPremiumOutflow: 0, activePoliciesCount: 0),
      policies: list
          .whereType<Map<String, dynamic>>()
          .map((e) => InsurancePolicyItem.fromJson(e))
          .toList(),
    );
  }
}

class LinkInsurancePolicyRequest {
  final String insuranceType;
  final String policyName;
  final String policyNumber;
  final String providerName;
  final double sumInsured;
  final double annualPremium;
  final String renewalDate;
  final String nomineeName;
  final String nomineeRelation;

  const LinkInsurancePolicyRequest({
    required this.insuranceType,
    required this.policyName,
    required this.policyNumber,
    required this.providerName,
    required this.sumInsured,
    required this.annualPremium,
    required this.renewalDate,
    required this.nomineeName,
    this.nomineeRelation = 'Self',
  });

  Map<String, dynamic> toJson() => {
    'insuranceType': insuranceType,
    'policyName': policyName,
    'policyNumber': policyNumber,
    'providerName': providerName,
    'sumInsured': sumInsured,
    'annualPremium': annualPremium,
    'renewalDate': renewalDate,
    'nomineeName': nomineeName,
    'nomineeRelation': nomineeRelation,
  };
}

class UpdateInsurancePolicyRequest {
  final double sumInsured;
  final double annualPremium;

  const UpdateInsurancePolicyRequest({
    required this.sumInsured,
    required this.annualPremium,
  });

  Map<String, dynamic> toJson() => {
    'sumInsured': sumInsured,
    'annualPremium': annualPremium,
  };
}

class InsurancePolicyItem {
  final String id;
  final String policyType; // Health Insurance, Term Life Insurance, Vehicle Insurance, etc.
  final String policyNumberMasked;
  final String provider;
  final double coverageAmount;
  final double premiumAmount;
  final String renewalDate;
  final String nominee;

  // Live API server fields
  final String? userId;
  final String? insuranceType;
  final String? policyName;
  final String? policyNumber;
  final String? providerName;
  final double? sumInsured;
  final double? annualPremium;
  final String? policyStartDate;
  final String? paymentFrequency;
  final String? nomineeName;
  final String? nomineeRelation;
  final String? status;
  final String? documentPath;
  final bool isAggregated;
  final String? createdAt;
  final String? updatedAt;

  const InsurancePolicyItem({
    required this.id,
    required this.policyType,
    required this.policyNumberMasked,
    required this.provider,
    required this.coverageAmount,
    required this.premiumAmount,
    required this.renewalDate,
    required this.nominee,
    this.userId,
    this.insuranceType,
    this.policyName,
    this.policyNumber,
    this.providerName,
    this.sumInsured,
    this.annualPremium,
    this.policyStartDate,
    this.paymentFrequency,
    this.nomineeName,
    this.nomineeRelation,
    this.status = 'ACTIVE',
    this.documentPath,
    this.isAggregated = true,
    this.createdAt,
    this.updatedAt,
  });

  factory InsurancePolicyItem.fromJson(Map<String, dynamic> json) {
    final polNum = json['policyNumber']?.toString() ?? json['policyNumberMasked']?.toString() ?? '';
    final insType = json['insuranceType']?.toString() ?? json['policyType']?.toString() ?? 'HEALTH';
    final prov = json['providerName']?.toString() ?? json['provider']?.toString() ?? 'Insurance Provider';
    final cov = (json['sumInsured'] ?? json['coverageAmount'] as num?)?.toDouble() ?? 0.0;
    final prem = (json['annualPremium'] ?? json['premiumAmount'] as num?)?.toDouble() ?? 0.0;
    final ren = json['renewalDate']?.toString() ?? '';
    final nom = json['nomineeName']?.toString() ?? json['nominee']?.toString() ?? 'Self';

    return InsurancePolicyItem(
      id: json['id']?.toString() ?? '',
      policyType: insType,
      policyNumberMasked: polNum,
      provider: prov,
      coverageAmount: cov,
      premiumAmount: prem,
      renewalDate: ren,
      nominee: nom,
      userId: json['userId']?.toString(),
      insuranceType: insType,
      policyName: json['policyName']?.toString(),
      policyNumber: polNum,
      providerName: prov,
      sumInsured: cov,
      annualPremium: prem,
      policyStartDate: json['policyStartDate']?.toString(),
      paymentFrequency: json['paymentFrequency']?.toString() ?? 'Annually',
      nomineeName: nom,
      nomineeRelation: json['nomineeRelation']?.toString() ?? 'Self',
      status: json['status']?.toString() ?? 'ACTIVE',
      documentPath: json['documentPath']?.toString(),
      isAggregated: json['isAggregated'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'insuranceType': insuranceType ?? policyType,
    'policyName': policyName ?? policyType,
    'policyNumber': policyNumber ?? policyNumberMasked,
    'providerName': providerName ?? provider,
    'sumInsured': sumInsured ?? coverageAmount,
    'annualPremium': annualPremium ?? premiumAmount,
    'policyStartDate': policyStartDate,
    'renewalDate': renewalDate,
    'paymentFrequency': paymentFrequency,
    'nomineeName': nomineeName ?? nominee,
    'nomineeRelation': nomineeRelation,
    'status': status,
    'documentPath': documentPath,
    'isAggregated': isAggregated,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  InsurancePolicyItem copyWith({
    String? id,
    String? policyType,
    String? policyNumberMasked,
    String? provider,
    double? coverageAmount,
    double? premiumAmount,
    String? renewalDate,
    String? nominee,
    String? userId,
    String? insuranceType,
    String? policyName,
    String? policyNumber,
    String? providerName,
    double? sumInsured,
    double? annualPremium,
    String? policyStartDate,
    String? paymentFrequency,
    String? nomineeName,
    String? nomineeRelation,
    String? status,
    String? documentPath,
    bool? isAggregated,
    String? createdAt,
    String? updatedAt,
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
      userId: userId ?? this.userId,
      insuranceType: insuranceType ?? this.insuranceType,
      policyName: policyName ?? this.policyName,
      policyNumber: policyNumber ?? this.policyNumber,
      providerName: providerName ?? this.providerName,
      sumInsured: sumInsured ?? this.sumInsured,
      annualPremium: annualPremium ?? this.annualPremium,
      policyStartDate: policyStartDate ?? this.policyStartDate,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      nomineeName: nomineeName ?? this.nomineeName,
      nomineeRelation: nomineeRelation ?? this.nomineeRelation,
      status: status ?? this.status,
      documentPath: documentPath ?? this.documentPath,
      isAggregated: isAggregated ?? this.isAggregated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WalletsApiResponse {
  final bool success;
  final int count;
  final double totalWalletBalance;
  final List<WalletAccountItem> wallets;

  const WalletsApiResponse({
    required this.success,
    required this.count,
    required this.totalWalletBalance,
    required this.wallets,
  });

  factory WalletsApiResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] is List ? json['data'] as List : [];
    return WalletsApiResponse(
      success: json['success'] == true,
      count: (json['count'] as num?)?.toInt() ?? list.length,
      totalWalletBalance: (json['totalWalletBalance'] as num?)?.toDouble() ?? 0.0,
      wallets: list
          .whereType<Map<String, dynamic>>()
          .map((e) => WalletAccountItem.fromJson(e))
          .toList(),
    );
  }
}

class WalletAccountItem {
  final String id;
  final String walletName; // Mobikwik Wallet, Amazon Pay, Paytm Wallet
  final double balance;
  final String status;

  // Live API server fields
  final String? userId;
  final String? walletProvider;
  final String? linkedMobile;
  final bool isKycDone;
  final String? createdAt;
  final String? updatedAt;

  const WalletAccountItem({
    required this.id,
    required this.walletName,
    required this.balance,
    this.status = 'ACTIVE',
    this.userId,
    this.walletProvider,
    this.linkedMobile,
    this.isKycDone = false,
    this.createdAt,
    this.updatedAt,
  });

  factory WalletAccountItem.fromJson(Map<String, dynamic> json) {
    return WalletAccountItem(
      id: json['id']?.toString() ?? '',
      walletName: json['walletName']?.toString() ?? 'Digital Wallet',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'ACTIVE',
      userId: json['userId']?.toString(),
      walletProvider: json['walletProvider']?.toString(),
      linkedMobile: json['linkedMobile']?.toString(),
      isKycDone: json['isKycDone'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'walletName': walletName,
    'walletProvider': walletProvider,
    'balance': balance,
    'linkedMobile': linkedMobile,
    'isKycDone': isKycDone,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  WalletAccountItem copyWith({
    String? id,
    String? walletName,
    double? balance,
    String? status,
    String? userId,
    String? walletProvider,
    String? linkedMobile,
    bool? isKycDone,
    String? createdAt,
    String? updatedAt,
  }) {
    return WalletAccountItem(
      id: id ?? this.id,
      walletName: walletName ?? this.walletName,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      walletProvider: walletProvider ?? this.walletProvider,
      linkedMobile: linkedMobile ?? this.linkedMobile,
      isKycDone: isKycDone ?? this.isKycDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LinkWalletRequest {
  final String walletName;
  final String walletProvider;
  final double balance;
  final String linkedMobile;

  const LinkWalletRequest({
    required this.walletName,
    required this.walletProvider,
    required this.balance,
    required this.linkedMobile,
  });

  Map<String, dynamic> toJson() => {
    'walletName': walletName,
    'walletProvider': walletProvider,
    'balance': balance,
    'linkedMobile': linkedMobile,
  };
}

class ConsentsApiResponse {
  final bool success;
  final int count;
  final int activeConsentsCount;
  final List<AggregatorConsentItem> consents;

  const ConsentsApiResponse({
    required this.success,
    required this.count,
    required this.activeConsentsCount,
    required this.consents,
  });

  factory ConsentsApiResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] is List ? json['data'] as List : [];
    return ConsentsApiResponse(
      success: json['success'] == true,
      count: (json['count'] as num?)?.toInt() ?? list.length,
      activeConsentsCount: (json['activeConsentsCount'] as num?)?.toInt() ?? 0,
      consents: list
          .whereType<Map<String, dynamic>>()
          .map((e) => AggregatorConsentItem.fromJson(e))
          .toList(),
    );
  }
}

class InitiateConsentRequest {
  final String fipId;
  final String fipName;
  final String fiTypes;
  final int validityDays;

  const InitiateConsentRequest({
    required this.fipId,
    required this.fipName,
    required this.fiTypes,
    this.validityDays = 365,
  });

  Map<String, dynamic> toJson() => {
    'fipId': fipId,
    'fipName': fipName,
    'fiTypes': fiTypes,
    'validityDays': validityDays,
  };
}

class InitiateConsentResponse {
  final bool success;
  final String message;
  final String consentHandle;
  final String artifactUrl;
  final AggregatorConsentItem? data;

  const InitiateConsentResponse({
    required this.success,
    required this.message,
    required this.consentHandle,
    required this.artifactUrl,
    this.data,
  });

  factory InitiateConsentResponse.fromJson(Map<String, dynamic> json) {
    return InitiateConsentResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      consentHandle: json['consentHandle']?.toString() ?? '',
      artifactUrl: json['artifactUrl']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? AggregatorConsentItem.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RenewConsentRequest {
  final int extensionDays;

  const RenewConsentRequest({
    this.extensionDays = 365,
  });

  Map<String, dynamic> toJson() => {
    'extensionDays': extensionDays,
  };
}

class AggregatorConsentItem {
  final String id;
  final String? userId;
  final String consentHandle;
  final String? consentArtifactId;
  final String? fipId;
  final String fipName;
  final String fiTypes;
  final String? consentMode;
  final String? fetchType;
  final String? dataFrequency;
  final String status; // ACTIVE, REVOKED, EXPIRED
  final String? validFrom;
  final String? validTo;
  final String? lastSyncedAt;
  final String? createdAt;
  final String? updatedAt;

  // Backward compatibility legacy fields
  final String? legacyConsentId;
  final String? legacyInstitution;
  final String? legacyConsentType;
  final String? legacyStartDate;
  final String? legacyExpiryDate;
  final String? legacyPurpose;
  final String? legacyDataShared;

  const AggregatorConsentItem({
    String? id,
    this.userId,
    String? consentHandle,
    this.consentArtifactId,
    this.fipId,
    String? fipName,
    String? fiTypes,
    this.consentMode = 'VIEW',
    this.fetchType = 'PERIODIC',
    this.dataFrequency = 'DAILY',
    this.status = 'ACTIVE',
    this.validFrom,
    this.validTo,
    this.lastSyncedAt,
    this.createdAt,
    this.updatedAt,
    String? consentId,
    String? institution,
    String? consentType,
    String? startDate,
    String? expiryDate,
    String? purpose,
    String? dataShared,
  })  : id = id ?? consentId ?? consentHandle ?? '',
        consentHandle = consentHandle ?? consentId ?? id ?? '',
        fipName = fipName ?? institution ?? 'Financial Institution',
        fiTypes = fiTypes ?? consentType ?? 'DEPOSIT,TERM_DEPOSIT',
        legacyConsentId = consentId,
        legacyInstitution = institution,
        legacyConsentType = consentType,
        legacyStartDate = startDate,
        legacyExpiryDate = expiryDate,
        legacyPurpose = purpose,
        legacyDataShared = dataShared;

  String get consentId => consentHandle.isNotEmpty ? consentHandle : id;
  String get institution => fipName;
  String get consentType => fiTypes;
  String get startDate => validFrom ?? legacyStartDate ?? 'Today';
  String get expiryDate => validTo ?? legacyExpiryDate ?? '1 Year';
  String get purpose => legacyPurpose ?? 'Real-time Net Worth & AI CFO Analytics';
  String get dataShared => legacyDataShared ?? fiTypes;

  factory AggregatorConsentItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? json['consentId']?.toString() ?? '';
    final handle = json['consentHandle']?.toString() ?? json['consentId']?.toString() ?? rawId;
    final fip = json['fipName']?.toString() ?? json['institution']?.toString() ?? 'Financial Institution';
    final types = json['fiTypes']?.toString() ?? json['consentType']?.toString() ?? 'DEPOSIT,TERM_DEPOSIT';
    final st = json['status']?.toString() ?? 'ACTIVE';

    return AggregatorConsentItem(
      id: rawId,
      userId: json['userId']?.toString(),
      consentHandle: handle,
      consentArtifactId: json['consentArtifactId']?.toString(),
      fipId: json['fipId']?.toString(),
      fipName: fip,
      fiTypes: types,
      consentMode: json['consentMode']?.toString(),
      fetchType: json['fetchType']?.toString(),
      dataFrequency: json['dataFrequency']?.toString(),
      status: st,
      validFrom: json['validFrom']?.toString() ?? json['startDate']?.toString(),
      validTo: json['validTo']?.toString() ?? json['expiryDate']?.toString(),
      lastSyncedAt: json['lastSyncedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      purpose: json['purpose']?.toString(),
      dataShared: json['dataShared']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'consentHandle': consentHandle,
    'consentArtifactId': consentArtifactId,
    'fipId': fipId,
    'fipName': fipName,
    'fiTypes': fiTypes,
    'consentMode': consentMode,
    'fetchType': fetchType,
    'dataFrequency': dataFrequency,
    'status': status,
    'validFrom': validFrom,
    'validTo': validTo,
    'lastSyncedAt': lastSyncedAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  AggregatorConsentItem copyWith({
    String? id,
    String? userId,
    String? consentHandle,
    String? consentArtifactId,
    String? fipId,
    String? fipName,
    String? fiTypes,
    String? consentMode,
    String? fetchType,
    String? dataFrequency,
    String? status,
    String? validFrom,
    String? validTo,
    String? lastSyncedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return AggregatorConsentItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      consentHandle: consentHandle ?? this.consentHandle,
      consentArtifactId: consentArtifactId ?? this.consentArtifactId,
      fipId: fipId ?? this.fipId,
      fipName: fipName ?? this.fipName,
      fiTypes: fiTypes ?? this.fiTypes,
      consentMode: consentMode ?? this.consentMode,
      fetchType: fetchType ?? this.fetchType,
      dataFrequency: dataFrequency ?? this.dataFrequency,
      status: status ?? this.status,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InstitutionDirectoryApiResponse {
  final bool success;
  final int totalSupported;
  final List<InstitutionDirectoryItem> institutions;

  const InstitutionDirectoryApiResponse({
    required this.success,
    required this.totalSupported,
    required this.institutions,
  });

  factory InstitutionDirectoryApiResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] is List ? json['data'] as List : [];
    return InstitutionDirectoryApiResponse(
      success: json['success'] == true,
      totalSupported: (json['totalSupported'] as num?)?.toInt() ?? list.length,
      institutions: list
          .whereType<Map<String, dynamic>>()
          .map((e) => InstitutionDirectoryItem.fromJson(e))
          .toList(),
    );
  }
}

class InstitutionDirectoryItem {
  final String id;
  final String name;
  final String logoText;
  final String category; // Banks, Credit Cards, Loans, Investments, Insurance
  final bool apiEnabled;
  final bool aaSupported;
  final String status;

  // Live API fields
  final String? fipId;
  final List<String> fiTypes;
  final String? liveStatus;

  const InstitutionDirectoryItem({
    required this.id,
    required this.name,
    this.logoText = 'BANK',
    required this.category,
    this.apiEnabled = true,
    this.aaSupported = true,
    this.status = 'Active',
    this.fipId,
    this.fiTypes = const [],
    this.liveStatus,
  });

  factory InstitutionDirectoryItem.fromJson(Map<String, dynamic> json) {
    final rawFip = json['fipId']?.toString();
    final rawName = json['name']?.toString() ?? 'Financial Institution';
    final rawCat = json['category']?.toString() ?? 'BANK';
    final rawStatus = json['liveStatus']?.toString() ?? 'ONLINE';

    List<String> types = [];
    if (json['fiTypes'] is List) {
      types = (json['fiTypes'] as List).map((e) => e.toString()).toList();
    }

    String logo = 'BANK';
    if (rawName.toUpperCase().contains('ICICI')) {
      logo = 'ICICI';
    } else if (rawName.toUpperCase().contains('HDFC')) {
      logo = 'HDFC';
    } else if (rawName.toUpperCase().contains('AXIS')) {
      logo = 'AXIS';
    } else if (rawName.toUpperCase().contains('SBI') || rawName.toUpperCase().contains('STATE BANK')) {
      logo = 'SBI';
    } else if (rawName.length >= 3) {
      logo = rawName.substring(0, 3).toUpperCase();
    }

    return InstitutionDirectoryItem(
      id: rawFip ?? json['id']?.toString() ?? rawName,
      name: rawName,
      logoText: json['logoText']?.toString() ?? logo,
      category: rawCat,
      apiEnabled: true,
      aaSupported: true,
      status: rawStatus == 'ONLINE' ? 'Active' : rawStatus,
      fipId: rawFip,
      fiTypes: types,
      liveStatus: rawStatus,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fipId': fipId ?? id,
    'name': name,
    'category': category,
    'fiTypes': fiTypes,
    'liveStatus': liveStatus,
    'logoText': logoText,
    'status': status,
  };
}

class AggregatorTransactionAggregates {
  final double totalDebits;
  final double totalCredits;

  const AggregatorTransactionAggregates({
    required this.totalDebits,
    required this.totalCredits,
  });

  factory AggregatorTransactionAggregates.fromJson(Map<String, dynamic> json) {
    return AggregatorTransactionAggregates(
      totalDebits: (json['totalDebits'] as num?)?.toDouble() ?? 0.0,
      totalCredits: (json['totalCredits'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalDebits': totalDebits,
    'totalCredits': totalCredits,
  };
}

class AggregatorTransactionsApiResponse {
  final bool success;
  final int totalRecords;
  final int currentPage;
  final int totalPages;
  final AggregatorTransactionAggregates aggregates;
  final List<AggregatorTransactionItem> transactions;

  const AggregatorTransactionsApiResponse({
    required this.success,
    required this.totalRecords,
    required this.currentPage,
    required this.totalPages,
    required this.aggregates,
    required this.transactions,
  });

  factory AggregatorTransactionsApiResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] is List ? json['data'] as List : [];
    return AggregatorTransactionsApiResponse(
      success: json['success'] == true,
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? list.length,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      aggregates: json['aggregates'] is Map<String, dynamic>
          ? AggregatorTransactionAggregates.fromJson(json['aggregates'] as Map<String, dynamic>)
          : const AggregatorTransactionAggregates(totalDebits: 0, totalCredits: 0),
      transactions: list
          .whereType<Map<String, dynamic>>()
          .map((e) => AggregatorTransactionItem.fromJson(e))
          .toList(),
    );
  }
}

class AggregatorTransactionItem {
  final String id;
  final String title;
  final String category;
  final double amount; // Positive = credit, Negative = debit
  final String date;
  final String institution;
  final String type; // UPI, NetBanking, Card, EMI

  // Live API fields
  final String? userId;
  final String? accountId;
  final String? referenceNumber;
  final double? balanceAfter;
  final String? mode;

  const AggregatorTransactionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.institution,
    required this.type,
    this.userId,
    this.accountId,
    this.referenceNumber,
    this.balanceAfter,
    this.mode,
  });

  factory AggregatorTransactionItem.fromJson(Map<String, dynamic> json) {
    final desc = json['description']?.toString() ?? json['title']?.toString() ?? json['narrative']?.toString() ?? 'Transaction';
    final cat = json['category']?.toString() ?? 'General';
    final amt = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final dt = json['date']?.toString() ?? json['transactionDate']?.toString() ?? '';
    final inst = json['institution']?.toString() ?? json['bankName']?.toString() ?? 'Bank';
    final t = json['type']?.toString() ?? json['paymentMode']?.toString() ?? 'UPI';

    return AggregatorTransactionItem(
      id: json['id']?.toString() ?? '',
      title: desc,
      category: cat,
      amount: amt,
      date: dt,
      institution: inst,
      type: t,
      userId: json['userId']?.toString(),
      accountId: json['accountId']?.toString(),
      referenceNumber: json['referenceNumber']?.toString() ?? json['txnId']?.toString(),
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      mode: json['mode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'amount': amount,
    'date': date,
    'institution': institution,
    'type': type,
    'userId': userId,
    'accountId': accountId,
    'referenceNumber': referenceNumber,
    'balanceAfter': balanceAfter,
    'mode': mode,
  };
}

class LiquidCashItem {
  final String id;
  final String title;
  final double amount;
  final String lastUpdated;
  final String? notes;

  const LiquidCashItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.lastUpdated,
    this.notes,
  });

  factory LiquidCashItem.fromJson(Map<String, dynamic> json) {
    return LiquidCashItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Physical Cash in Hand',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['lastUpdated']?.toString() ?? 'Today',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'lastUpdated': lastUpdated,
    if (notes != null) 'notes': notes,
  };

  LiquidCashItem copyWith({
    String? id,
    String? title,
    double? amount,
    String? lastUpdated,
    String? notes,
  }) {
    return LiquidCashItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
    );
  }
}

class BankAggregationState {
  final List<BankAccountItem> bankAccounts;
  final List<UpiAccountItem> upiAccounts;
  final List<CreditCardItem> creditCards;
  final List<LoanAccountItem> loans;
  final List<InvestmentHoldingItem> investments;
  final List<InsurancePolicyItem> insurancePolicies;
  final List<WalletAccountItem> wallets;
  final List<LiquidCashItem> cashEntries;
  final double liquidCash;
  final List<AggregatorConsentItem> consents;
  final List<InstitutionDirectoryItem> institutionDirectory;
  final List<AggregatorTransactionItem> recentTransactions;
  final String selectedCategoryFilter;
  final String searchQuery;
  final int selectedTabIndex;
  final bool isSyncing;
  final String lastSyncedTime;
  final String connectionStatus;
  final BankAggregationSummary? summary;
  final CardsSummary? cardsSummary;
  final LoansSummary? loansSummary;
  final PortfolioSummary? portfolioSummary;
  final InsuranceSummary? insuranceSummary;
  final String? primaryVpa;
  final double? totalWalletBalance;
  final int activeConsentsCount;
  final AggregatorTransactionAggregates? transactionAggregates;
  final bool isLoading;
  final String? errorMessage;

  const BankAggregationState({
    required this.bankAccounts,
    required this.upiAccounts,
    required this.creditCards,
    required this.loans,
    required this.investments,
    required this.insurancePolicies,
    required this.wallets,
    this.cashEntries = const [],
    this.liquidCash = 0.0,
    required this.consents,
    required this.institutionDirectory,
    required this.recentTransactions,
    this.selectedCategoryFilter = 'All',
    this.searchQuery = '',
    this.selectedTabIndex = 0,
    this.isSyncing = false,
    this.lastSyncedTime = 'Just now • Every 4 Hours',
    this.connectionStatus = 'All 5 Pillars Connected & Synced',
    this.summary,
    this.cardsSummary,
    this.loansSummary,
    this.portfolioSummary,
    this.insuranceSummary,
    this.primaryVpa,
    this.totalWalletBalance,
    this.activeConsentsCount = 0,
    this.transactionAggregates,
    this.isLoading = false,
    this.errorMessage,
  });

  // Consolidated Financial Position Calculations (Section 12 FRD/FRS)
  double get totalBankCash {
    if (bankAccounts.isNotEmpty) {
      return bankAccounts.fold(0.0, (s, a) => s + a.availableBalance);
    }
    if (summary != null && summary!.financialPositions.bankAccountsCash > 0) {
      return summary!.financialPositions.bankAccountsCash;
    }
    return 0.0;
  }

  double get totalLiquidCash {
    if (cashEntries.isNotEmpty) {
      return cashEntries.fold(0.0, (s, c) => s + c.amount);
    }
    return liquidCash;
  }

  double get totalWalletCash {
    if (totalWalletBalance != null && totalWalletBalance! > 0) {
      return totalWalletBalance!;
    }
    if (summary != null && summary!.financialPositions.walletsCash > 0) {
      return summary!.financialPositions.walletsCash;
    }
    return wallets.fold(0.0, (s, w) => s + w.balance);
  }

  double get totalCashPosition => totalBankCash + totalWalletCash + totalLiquidCash;

  double get totalCreditCardDebt {
    if (cardsSummary != null && cardsSummary!.totalOutstanding > 0) {
      return cardsSummary!.totalOutstanding;
    }
    if (summary != null && summary!.financialPositions.creditCardsDebt > 0) {
      return summary!.financialPositions.creditCardsDebt;
    }
    return creditCards.where((c) => !c.isDebit).fold(0.0, (s, c) => s + c.outstandingBalance);
  }

  double get totalLoanDebt {
    if (loansSummary != null && loansSummary!.totalOutstandingPrincipal > 0) {
      return loansSummary!.totalOutstandingPrincipal;
    }
    if (summary != null && summary!.financialPositions.loansDebt > 0) {
      return summary!.financialPositions.loansDebt;
    }
    return loans.fold(0.0, (s, l) => s + l.outstandingPrincipal);
  }

  double get totalDebtPosition => totalCreditCardDebt + totalLoanDebt;

  double get totalInvestments {
    if (portfolioSummary != null && portfolioSummary!.totalCurrentValue > 0) {
      return portfolioSummary!.totalCurrentValue;
    }
    if (summary != null && summary!.financialPositions.totalInvestments > 0) {
      return summary!.financialPositions.totalInvestments;
    }
    return investments.fold(0.0, (s, i) => s + i.currentValue);
  }

  double get totalInsuranceCoverage {
    if (insuranceSummary != null && insuranceSummary!.totalSumInsuredCoverage > 0) {
      return insuranceSummary!.totalSumInsuredCoverage;
    }
    if (summary != null && summary!.financialPositions.totalInsuranceCover > 0) {
      return summary!.financialPositions.totalInsuranceCover;
    }
    return insurancePolicies.fold(0.0, (s, p) => s + p.coverageAmount);
  }

  double get totalAssets => totalCashPosition + totalInvestments;
  double get totalLiabilities => totalDebtPosition;

  double get netWorth {
    if (summary != null && summary!.financialPositions.netWorth != 0) {
      return summary!.financialPositions.netWorth;
    }
    return totalAssets - totalLiabilities;
  }

  BankAggregationState copyWith({
    List<BankAccountItem>? bankAccounts,
    List<UpiAccountItem>? upiAccounts,
    List<CreditCardItem>? creditCards,
    List<LoanAccountItem>? loans,
    List<InvestmentHoldingItem>? investments,
    List<InsurancePolicyItem>? insurancePolicies,
    List<WalletAccountItem>? wallets,
    List<LiquidCashItem>? cashEntries,
    double? liquidCash,
    List<AggregatorConsentItem>? consents,
    List<InstitutionDirectoryItem>? institutionDirectory,
    List<AggregatorTransactionItem>? recentTransactions,
    String? selectedCategoryFilter,
    String? searchQuery,
    int? selectedTabIndex,
    bool? isSyncing,
    String? lastSyncedTime,
    String? connectionStatus,
    BankAggregationSummary? summary,
    CardsSummary? cardsSummary,
    LoansSummary? loansSummary,
    PortfolioSummary? portfolioSummary,
    InsuranceSummary? insuranceSummary,
    String? primaryVpa,
    double? totalWalletBalance,
    int? activeConsentsCount,
    AggregatorTransactionAggregates? transactionAggregates,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BankAggregationState(
      bankAccounts: bankAccounts ?? this.bankAccounts,
      upiAccounts: upiAccounts ?? this.upiAccounts,
      creditCards: creditCards ?? this.creditCards,
      loans: loans ?? this.loans,
      investments: investments ?? this.investments,
      insurancePolicies: insurancePolicies ?? this.insurancePolicies,
      wallets: wallets ?? this.wallets,
      cashEntries: cashEntries ?? this.cashEntries,
      liquidCash: liquidCash ?? this.liquidCash,
      consents: consents ?? this.consents,
      institutionDirectory: institutionDirectory ?? this.institutionDirectory,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      selectedCategoryFilter: selectedCategoryFilter ?? this.selectedCategoryFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedTime: lastSyncedTime ?? this.lastSyncedTime,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      summary: summary ?? this.summary,
      cardsSummary: cardsSummary ?? this.cardsSummary,
      loansSummary: loansSummary ?? this.loansSummary,
      portfolioSummary: portfolioSummary ?? this.portfolioSummary,
      insuranceSummary: insuranceSummary ?? this.insuranceSummary,
      primaryVpa: primaryVpa ?? this.primaryVpa,
      totalWalletBalance: totalWalletBalance ?? this.totalWalletBalance,
      activeConsentsCount: activeConsentsCount ?? this.activeConsentsCount,
      transactionAggregates: transactionAggregates ?? this.transactionAggregates,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
