class ExpenseEntry {
  final String id;
  final String description;
  final String category; // Housing, Food, Utilities, Transport, Healthcare, Shopping, Entertainment, Subscriptions, Bills, Other, Food & Dining
  final double amount;
  final String date;
  final String paymentMode; // UPI, Credit Card, Debit Card, Net Banking, Cash, HDFC Bank (**** 8754)
  final String priority; // P1 - Survival, P2 - Protection, P3 - Obligations, P4 - Growth, P5 - Lifestyle, P6 - Luxury
  final bool isRecurring;
  final String merchant;
  final String notes;
  final String bankAccount;
  final String? documentName;
  final String? documentPath;
  final String? invoiceNumber;
  final String? userId;
  final String? accountNumber;
  final double? balanceAfter;
  final String? receiptUrl;
  final bool isVerified;
  final String? rawDate;
  final String? budgetImpact;
  final String? createdAt;
  final String? accountId;
  final double? remainingBalanceOrCredit;
  final String? transactionStatus;
  final ExpenseAccountDetail? account;

  const ExpenseEntry({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    this.paymentMode = 'UPI',
    this.priority = 'P1 - Survival',
    this.isRecurring = false,
    this.merchant = '',
    this.notes = '',
    this.bankAccount = 'HDFC Bank ••••4587',
    this.documentName,
    this.documentPath,
    this.invoiceNumber,
    this.userId,
    this.accountNumber,
    this.balanceAfter,
    this.receiptUrl,
    this.isVerified = true,
    this.rawDate,
    this.budgetImpact,
    this.createdAt,
    this.accountId,
    this.remainingBalanceOrCredit,
    this.transactionStatus,
    this.account,
  });

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) {
    final desc = (json['description'] ?? json['merchant'] ?? '')?.toString() ?? '';
    final merchantStr = (json['merchant'] ?? json['description'] ?? '')?.toString() ?? '';
    return ExpenseEntry(
      id: json['id']?.toString() ?? '',
      description: desc.isNotEmpty ? desc : 'Expense',
      category: json['category']?.toString() ?? 'Other',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: (json['date'] ?? json['rawDate'])?.toString() ?? '',
      paymentMode: json['paymentMode']?.toString() ?? 'UPI',
      priority: json['priority']?.toString() ?? 'P1 - Survival',
      isRecurring: json['isRecurring'] as bool? ?? false,
      merchant: merchantStr,
      notes: json['notes']?.toString() ?? '',
      bankAccount: (json['bankAccount'] ?? json['paymentMode'])?.toString() ?? 'HDFC Bank ••••4587',
      documentName: json['documentName'] as String?,
      documentPath: (json['documentPath'] ?? json['receiptUrl']) as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      userId: json['userId'] as String?,
      accountNumber: json['accountNumber'] as String?,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      receiptUrl: json['receiptUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? true,
      rawDate: json['rawDate']?.toString(),
      budgetImpact: json['budgetImpact']?.toString(),
      createdAt: json['createdAt'] as String?,
      accountId: json['accountId'] as String?,
      remainingBalanceOrCredit: (json['remainingBalanceOrCredit'] as num?)?.toDouble(),
      transactionStatus: json['transactionStatus'] as String?,
      account: json['account'] is Map<String, dynamic> ? ExpenseAccountDetail.fromJson(json['account'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'category': category,
      'amount': amount,
      'date': date,
      'paymentMode': paymentMode,
      'priority': priority,
      'isRecurring': isRecurring,
      if (merchant.isNotEmpty) 'merchant': merchant,
      if (notes.isNotEmpty) 'notes': notes,
      if (bankAccount.isNotEmpty) 'bankAccount': bankAccount,
      if (documentName != null) 'documentName': documentName,
      if (documentPath != null) 'documentPath': documentPath,
    };
  }

  ExpenseEntry copyWith({
    String? id,
    String? description,
    String? category,
    double? amount,
    String? date,
    String? paymentMode,
    String? priority,
    bool? isRecurring,
    String? merchant,
    String? notes,
    String? bankAccount,
    String? documentName,
    String? documentPath,
    String? invoiceNumber,
    String? userId,
    String? accountNumber,
    double? balanceAfter,
    String? receiptUrl,
    bool? isVerified,
    String? rawDate,
    String? budgetImpact,
    String? createdAt,
  }) {
    return ExpenseEntry(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentMode: paymentMode ?? this.paymentMode,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      merchant: merchant ?? this.merchant,
      notes: notes ?? this.notes,
      bankAccount: bankAccount ?? this.bankAccount,
      documentName: documentName ?? this.documentName,
      documentPath: documentPath ?? this.documentPath,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      userId: userId ?? this.userId,
      accountNumber: accountNumber ?? this.accountNumber,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isVerified: isVerified ?? this.isVerified,
      rawDate: rawDate ?? this.rawDate,
      budgetImpact: budgetImpact ?? this.budgetImpact,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ExpensePagination {
  final int currentPage;
  final int perPage;
  final int totalRecords;
  final int totalPages;

  const ExpensePagination({
    this.currentPage = 1,
    this.perPage = 20,
    this.totalRecords = 0,
    this.totalPages = 1,
  });

  factory ExpensePagination.fromJson(Map<String, dynamic> json) {
    return ExpensePagination(
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      perPage: (json['perPage'] as num?)?.toInt() ?? 20,
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class ExpenseEntriesResponse {
  final List<ExpenseEntry> expenses;
  final ExpensePagination pagination;

  const ExpenseEntriesResponse({
    required this.expenses,
    required this.pagination,
  });

  factory ExpenseEntriesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<ExpenseEntry> expList = [];
    ExpensePagination pag = const ExpensePagination();

    if (data is Map<String, dynamic>) {
      if (data['expenses'] is List) {
        expList = (data['expenses'] as List)
            .map((e) => ExpenseEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data['pagination'] is Map<String, dynamic>) {
        pag = ExpensePagination.fromJson(data['pagination'] as Map<String, dynamic>);
      }
    } else if (data is List) {
      expList = data
          .map((e) => ExpenseEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ExpenseEntriesResponse(expenses: expList, pagination: pag);
  }
}

class ExpenseSummaryData {
  final double totalMonthlyExpenses;
  final double monthlyAverage;
  final double dailyAverage;
  final double monthlyInflow;
  final double netCashFlow;
  final double savingsRate;
  final double cashRunwayMonths;
  final double recurringExpenses;
  final double discretionaryExpenses;
  final Map<String, double> priorityBreakdown;
  final double needsRatio;
  final double wantsRatio;
  final double expenseHealthScore;
  final String healthScoreRating;
  final int totalCount;
  final String aiCfoInsight;

  const ExpenseSummaryData({
    required this.totalMonthlyExpenses,
    required this.monthlyAverage,
    required this.dailyAverage,
    required this.monthlyInflow,
    required this.netCashFlow,
    required this.savingsRate,
    required this.cashRunwayMonths,
    required this.recurringExpenses,
    required this.discretionaryExpenses,
    required this.priorityBreakdown,
    required this.needsRatio,
    required this.wantsRatio,
    required this.expenseHealthScore,
    required this.healthScoreRating,
    required this.totalCount,
    required this.aiCfoInsight,
  });

  factory ExpenseSummaryData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> priRaw =
        (json['priorityBreakdown'] as Map<String, dynamic>?) ?? {};
    final Map<String, double> priMap = {};
    priRaw.forEach((k, v) {
      priMap[k] = (v as num?)?.toDouble() ?? 0.0;
    });

    return ExpenseSummaryData(
      totalMonthlyExpenses:
          (json['totalMonthlyExpenses'] as num?)?.toDouble() ?? 0.0,
      monthlyAverage: (json['monthlyAverage'] as num?)?.toDouble() ?? 0.0,
      dailyAverage: (json['dailyAverage'] as num?)?.toDouble() ?? 0.0,
      monthlyInflow: (json['monthlyInflow'] as num?)?.toDouble() ?? 0.0,
      netCashFlow: (json['netCashFlow'] as num?)?.toDouble() ?? 0.0,
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0.0,
      cashRunwayMonths:
          (json['cashRunwayMonths'] as num?)?.toDouble() ?? 0.0,
      recurringExpenses:
          (json['recurringExpenses'] as num?)?.toDouble() ?? 0.0,
      discretionaryExpenses:
          (json['discretionaryExpenses'] as num?)?.toDouble() ?? 0.0,
      priorityBreakdown: priMap,
      needsRatio: (json['needsRatio'] as num?)?.toDouble() ?? 0.0,
      wantsRatio: (json['wantsRatio'] as num?)?.toDouble() ?? 0.0,
      expenseHealthScore:
          (json['expenseHealthScore'] as num?)?.toDouble() ?? 75.0,
      healthScoreRating: json['healthScoreRating']?.toString() ??
          'Good Financial Health',
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      aiCfoInsight: json['aiCfoInsight']?.toString() ?? '',
    );
  }
}

class ExpenseCategoryBreakdown {
  final String category;
  final double totalAmount;
  final double percentage;
  final int count;

  const ExpenseCategoryBreakdown({
    required this.category,
    required this.totalAmount,
    required this.percentage,
    required this.count,
  });

  factory ExpenseCategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryBreakdown(
      category: json['category']?.toString() ?? 'Other',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ExpensePriorityBreakdown {
  final double p1Survival;
  final double p2Protection;
  final double p3Obligations;
  final double p4Growth;
  final double p5Lifestyle;
  final double p6Luxury;

  const ExpensePriorityBreakdown({
    this.p1Survival = 0.0,
    this.p2Protection = 0.0,
    this.p3Obligations = 0.0,
    this.p4Growth = 0.0,
    this.p5Lifestyle = 0.0,
    this.p6Luxury = 0.0,
  });

  factory ExpensePriorityBreakdown.fromJson(Map<String, dynamic> json) {
    return ExpensePriorityBreakdown(
      p1Survival: (json['P1_Survival'] as num?)?.toDouble() ?? 0.0,
      p2Protection: (json['P2_Protection'] as num?)?.toDouble() ?? 0.0,
      p3Obligations: (json['P3_Obligations'] as num?)?.toDouble() ?? 0.0,
      p4Growth: (json['P4_Growth'] as num?)?.toDouble() ?? 0.0,
      p5Lifestyle: (json['P5_Lifestyle'] as num?)?.toDouble() ?? 0.0,
      p6Luxury: (json['P6_Luxury'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DetectedExpense {
  final String detectionId;
  final String description;
  final String suggestedCategory;
  final String suggestedPriority;
  final double amount;
  final String date;
  final String paymentMode;
  final String bankAccount;
  final String merchant;
  final bool isDebit;
  final double confidenceScore;
  final String channel;

  const DetectedExpense({
    required this.detectionId,
    required this.description,
    required this.suggestedCategory,
    required this.suggestedPriority,
    required this.amount,
    required this.date,
    this.paymentMode = 'UPI',
    this.bankAccount = 'Axis Bank ••••3301',
    this.merchant = '',
    this.isDebit = true,
    this.confidenceScore = 0.94,
    this.channel = 'SMS_ALERT',
  });

  factory DetectedExpense.fromJson(Map<String, dynamic> json) {
    return DetectedExpense(
      detectionId: json['detectionId']?.toString() ?? '',
      description: json['description']?.toString() ?? 'Detected Outflow',
      suggestedCategory: json['suggestedCategory']?.toString() ?? 'Other',
      suggestedPriority: json['suggestedPriority']?.toString() ?? 'P1 - Survival',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date']?.toString() ?? '',
      paymentMode: json['paymentMode']?.toString() ?? 'UPI',
      bankAccount: (json['bankAccount'] ?? json['paymentMode'])?.toString() ?? 'UPI',
      merchant: json['merchant']?.toString() ?? '',
      isDebit: json['isDebit'] as bool? ?? true,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.9,
      channel: json['channel']?.toString() ?? 'SMS_ALERT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detectionId': detectionId,
      'description': description,
      'suggestedCategory': suggestedCategory,
      'suggestedPriority': suggestedPriority,
      'amount': amount,
      'date': date,
      'paymentMode': paymentMode,
      'bankAccount': bankAccount,
      'merchant': merchant,
      'isDebit': isDebit,
      'confidenceScore': confidenceScore,
      'channel': channel,
    };
  }
}

class ExpenseState {
  final List<ExpenseEntry> expenses;
  final String searchQuery;
  final String selectedCategoryFilter;
  final String selectedPriorityFilter;
  final String selectedBankAccountFilter;
  final String selectedDateFilter;
  final double monthlyInflow;
  final bool isLoading;
  final bool isSyncing;
  final String? errorMessage;
  final ExpenseSummaryData? summaryData;
  final List<ExpenseCategoryBreakdown> categoryBreakdowns;
  final ExpensePriorityBreakdown? priorityBreakdown;
  final ExpensePagination? pagination;
  final List<DetectedExpense> detectedExpenses;

  const ExpenseState({
    required this.expenses,
    this.searchQuery = '',
    this.selectedCategoryFilter = 'All',
    this.selectedPriorityFilter = 'All',
    this.selectedBankAccountFilter = 'All',
    this.selectedDateFilter = 'All',
    this.monthlyInflow = 132500.0,
    this.isLoading = false,
    this.isSyncing = false,
    this.errorMessage,
    this.summaryData,
    this.categoryBreakdowns = const [],
    this.priorityBreakdown,
    this.pagination,
    this.detectedExpenses = const [],
  });

  double get totalExpenses =>
      summaryData?.totalMonthlyExpenses ??
      expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get monthlyAverage =>
      summaryData?.monthlyAverage ?? totalExpenses;

  double get dailyAverage =>
      summaryData?.dailyAverage ?? (totalExpenses / 30.0);

  double get monthlyRecurringExpenses =>
      summaryData?.recurringExpenses ??
      expenses.fold(0.0, (sum, e) => e.isRecurring ? sum + e.amount : sum);

  double get discretionaryExpenses =>
      summaryData?.discretionaryExpenses ??
      (totalExpenses - monthlyRecurringExpenses).clamp(0.0, double.infinity);

  double get netCashFlow =>
      summaryData?.netCashFlow ?? (monthlyInflow - totalExpenses);

  double get savingsRate {
    if (summaryData != null) return summaryData!.savingsRate;
    if (monthlyInflow <= 0) return 0.0;
    return (((monthlyInflow - totalExpenses) / monthlyInflow) * 100).clamp(-100.0, 100.0);
  }

  double get cashRunwayMonths {
    if (summaryData != null) return summaryData!.cashRunwayMonths;
    if (totalExpenses <= 0) return 12.0;
    return (300000.0 / totalExpenses).clamp(1.0, 24.0);
  }

  double get survivalP1Total {
    if (priorityBreakdown != null) return priorityBreakdown!.p1Survival;
    return expenses.where((e) => e.priority.startsWith('P1')).fold(0.0, (sum, e) => sum + e.amount);
  }

  double get protectionP2Total {
    if (priorityBreakdown != null) return priorityBreakdown!.p2Protection;
    return expenses.where((e) => e.priority.startsWith('P2')).fold(0.0, (sum, e) => sum + e.amount);
  }

  double get obligationsP3Total {
    if (priorityBreakdown != null) return priorityBreakdown!.p3Obligations;
    return expenses.where((e) => e.priority.startsWith('P3')).fold(0.0, (sum, e) => sum + e.amount);
  }

  double get lifestyleP5Total {
    if (priorityBreakdown != null) {
      return priorityBreakdown!.p5Lifestyle + priorityBreakdown!.p6Luxury;
    }
    return expenses.where((e) => e.priority.startsWith('P5') || e.priority.startsWith('P6')).fold(0.0, (sum, e) => sum + e.amount);
  }

  double get needsRatio {
    if (summaryData != null) return summaryData!.needsRatio;
    if (totalExpenses <= 0) return 0.0;
    return (((survivalP1Total + protectionP2Total + obligationsP3Total) / totalExpenses) * 100)
        .clamp(0.0, 100.0);
  }

  double get wantsRatio {
    if (summaryData != null) return summaryData!.wantsRatio;
    if (totalExpenses <= 0) return 0.0;
    return (100.0 - needsRatio).clamp(0.0, 100.0);
  }

  double get expenseHealthScore {
    if (summaryData != null) return summaryData!.expenseHealthScore;
    if (expenses.isEmpty) return 75.0;
    double score = 70.0;
    if (savingsRate >= 30) {
      score += 15;
    } else if (savingsRate >= 15) {
      score += 8;
    } else {
      score -= 10;
    }

    if (needsRatio <= 70) {
      score += 10;
    } else {
      score -= 8;
    }

    return score.clamp(35.0, 95.0);
  }

  String get aiCfoInsightText {
    if (summaryData != null && summaryData!.aiCfoInsight.isNotEmpty) {
      return summaryData!.aiCfoInsight;
    }
    return 'AI Personal CFO: Expense Health Score is ${expenseHealthScore.toStringAsFixed(0)}/100. Discretionary spending (${wantsRatio.toStringAsFixed(1)}%) is well within the 30% financial guardrail.';
  }

  ExpenseState copyWith({
    List<ExpenseEntry>? expenses,
    String? searchQuery,
    String? selectedCategoryFilter,
    String? selectedPriorityFilter,
    String? selectedBankAccountFilter,
    String? selectedDateFilter,
    double? monthlyInflow,
    bool? isLoading,
    bool? isSyncing,
    String? errorMessage,
    ExpenseSummaryData? summaryData,
    List<ExpenseCategoryBreakdown>? categoryBreakdowns,
    ExpensePriorityBreakdown? priorityBreakdown,
    ExpensePagination? pagination,
    List<DetectedExpense>? detectedExpenses,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryFilter: selectedCategoryFilter ?? this.selectedCategoryFilter,
      selectedPriorityFilter: selectedPriorityFilter ?? this.selectedPriorityFilter,
      selectedBankAccountFilter: selectedBankAccountFilter ?? this.selectedBankAccountFilter,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      monthlyInflow: monthlyInflow ?? this.monthlyInflow,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage ?? this.errorMessage,
      summaryData: summaryData ?? this.summaryData,
      categoryBreakdowns: categoryBreakdowns ?? this.categoryBreakdowns,
      priorityBreakdown: priorityBreakdown ?? this.priorityBreakdown,
      pagination: pagination ?? this.pagination,
      detectedExpenses: detectedExpenses ?? this.detectedExpenses,
    );
  }
}

class ExpenseReceiptUploadResult {
  final String documentName;
  final String documentPath;
  final int fileSizeBytes;
  final String mimeType;
  final String uploadedAt;

  const ExpenseReceiptUploadResult({
    required this.documentName,
    required this.documentPath,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.uploadedAt,
  });

  factory ExpenseReceiptUploadResult.fromJson(Map<String, dynamic> json) {
    return ExpenseReceiptUploadResult(
      documentName: json['documentName']?.toString() ?? '',
      documentPath: json['documentPath']?.toString() ?? '',
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      mimeType: json['mimeType']?.toString() ?? 'application/pdf',
      uploadedAt: json['uploadedAt']?.toString() ?? '',
    );
  }
}

class ExpenseInvoiceDetails {
  final String invoiceNumber;
  final String id;
  final String particularsTitle;
  final String description;
  final String category;
  final double amount;
  final String amountInWords;
  final String date;
  final String paymentMode;
  final String priority;
  final bool isRecurring;
  final String frequencyLabel;
  final String merchant;
  final String bankAccount;
  final String notes;
  final String? attachedDocumentUrl;
  final String invoicePdfUrl;
  final String complianceStandard;

  const ExpenseInvoiceDetails({
    required this.invoiceNumber,
    required this.id,
    required this.particularsTitle,
    required this.description,
    required this.category,
    required this.amount,
    required this.amountInWords,
    required this.date,
    required this.paymentMode,
    required this.priority,
    required this.isRecurring,
    required this.frequencyLabel,
    required this.merchant,
    required this.bankAccount,
    required this.notes,
    this.attachedDocumentUrl,
    required this.invoicePdfUrl,
    required this.complianceStandard,
  });

  factory ExpenseInvoiceDetails.fromJson(Map<String, dynamic> json) {
    return ExpenseInvoiceDetails(
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      particularsTitle: json['particularsTitle']?.toString() ?? 'EXPENSE OUTFLOW DETAILS',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountInWords: json['amountInWords']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      paymentMode: json['paymentMode']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      isRecurring: json['isRecurring'] as bool? ?? false,
      frequencyLabel: json['frequencyLabel']?.toString() ?? '',
      merchant: json['merchant']?.toString() ?? '',
      bankAccount: json['bankAccount']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      attachedDocumentUrl: json['attachedDocumentUrl']?.toString(),
      invoicePdfUrl: json['invoicePdfUrl']?.toString() ?? '',
      complianceStandard: json['complianceStandard']?.toString() ?? '',
    );
  }
}

class ExpenseAccountDetail {
  final String id;
  final String? userId;
  final String name;
  final String? holderName;
  final String? nickname;
  final String accountNumber;
  final String? rawAccountNumber;
  final String? ifsc;
  final String? branch;
  final String accountType;
  final String? upiId;
  final double bankBalance;
  final double internalBalance;
  final double openingBalance;
  final bool isAggregated;
  final String? consentId;
  final String? logo;
  final String? color;
  final String status;

  const ExpenseAccountDetail({
    required this.id,
    this.userId,
    required this.name,
    this.holderName,
    this.nickname,
    required this.accountNumber,
    this.rawAccountNumber,
    this.ifsc,
    this.branch,
    required this.accountType,
    this.upiId,
    this.bankBalance = 0.0,
    this.internalBalance = 0.0,
    this.openingBalance = 0.0,
    this.isAggregated = false,
    this.consentId,
    this.logo,
    this.color,
    this.status = 'ACTIVE',
  });

  factory ExpenseAccountDetail.fromJson(Map<String, dynamic> json) {
    return ExpenseAccountDetail(
      id: json['id']?.toString() ?? '',
      userId: json['userId'] as String?,
      name: json['name']?.toString() ?? '',
      holderName: json['holderName'] as String?,
      nickname: json['nickname'] as String?,
      accountNumber: json['accountNumber']?.toString() ?? '',
      rawAccountNumber: json['rawAccountNumber'] as String?,
      ifsc: json['ifsc'] as String?,
      branch: json['branch'] as String?,
      accountType: json['accountType']?.toString() ?? 'Savings Account',
      upiId: json['upiId'] as String?,
      bankBalance: (json['bankBalance'] as num?)?.toDouble() ?? 0.0,
      internalBalance: (json['internalBalance'] as num?)?.toDouble() ?? 0.0,
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      isAggregated: json['isAggregated'] as bool? ?? false,
      consentId: json['consentId'] as String?,
      logo: json['logo'] as String?,
      color: json['color'] as String?,
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }
}
