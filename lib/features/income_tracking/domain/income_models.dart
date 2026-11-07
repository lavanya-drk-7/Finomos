class IncomeEntry {
  final String id;
  final String source;
  final String category; // Salary, Business, Freelance, Rental, Dividend, Interest, Bonus, Other
  final String type; // Active, Passive, Windfall
  final double amount;
  final String date;
  final String frequency; // Monthly, One-time, Yearly, Bi-weekly, Quarterly
  final String notes;
  final bool isVerified;
  final String bankAccount;
  final String? documentName;
  final String? documentPath;
  final String? voucherNumber;
  final String? verificationType;
  final String? createdAt;
  final String? updatedAt;
  final String? userId;
  final String? accountId;
  final String? accountNumber;
  final double? balanceAfter;
  final String? paymentMode;
  final String? receiptUrl;

  const IncomeEntry({
    required this.id,
    required this.source,
    required this.category,
    this.type = 'Active',
    required this.amount,
    required this.date,
    required this.frequency,
    this.notes = '',
    this.isVerified = true,
    this.bankAccount = '',
    this.documentName,
    this.documentPath,
    this.voucherNumber,
    this.verificationType,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.accountId,
    this.accountNumber,
    this.balanceAfter,
    this.paymentMode,
    this.receiptUrl,
  });

  factory IncomeEntry.fromJson(Map<String, dynamic> json) {
    return IncomeEntry(
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      type: json['type']?.toString() ?? 'Active',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? 'Monthly',
      notes: json['notes']?.toString() ?? '',
      isVerified: json['isVerified'] as bool? ?? true,
      bankAccount: (json['bankAccount'] ?? json['paymentMode'])?.toString() ?? '',
      documentName: json['documentName'] as String?,
      documentPath: (json['documentPath'] ?? json['receiptUrl']) as String?,
      voucherNumber: json['voucherNumber'] as String?,
      verificationType: json['verificationType'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      userId: json['userId'] as String?,
      accountId: json['accountId'] as String?,
      accountNumber: json['accountNumber'] as String?,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      paymentMode: json['paymentMode'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'source': source,
      'category': category,
      'frequency': frequency,
      'bankAccount': bankAccount,
      'date': date,
      'notes': notes,
      if (userId != null) 'userId': userId,
      if (accountId != null) 'accountId': accountId,
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (paymentMode != null) 'paymentMode': paymentMode,
      if (voucherNumber != null) 'voucherNumber': voucherNumber,
      if (verificationType != null) 'verificationType': verificationType,
      if (documentName != null) 'documentName': documentName,
      if (documentPath != null) 'documentPath': documentPath,
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  IncomeEntry copyWith({
    String? id,
    String? source,
    String? category,
    String? type,
    double? amount,
    String? date,
    String? frequency,
    String? notes,
    bool? isVerified,
    String? bankAccount,
    String? documentName,
    String? documentPath,
    String? voucherNumber,
    String? verificationType,
    String? createdAt,
    String? updatedAt,
    String? userId,
    String? accountId,
    String? accountNumber,
    double? balanceAfter,
    String? paymentMode,
    String? receiptUrl,
  }) {
    return IncomeEntry(
      id: id ?? this.id,
      source: source ?? this.source,
      category: category ?? this.category,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      frequency: frequency ?? this.frequency,
      notes: notes ?? this.notes,
      isVerified: isVerified ?? this.isVerified,
      bankAccount: bankAccount ?? this.bankAccount,
      documentName: documentName ?? this.documentName,
      documentPath: documentPath ?? this.documentPath,
      voucherNumber: voucherNumber ?? this.voucherNumber,
      verificationType: verificationType ?? this.verificationType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      accountNumber: accountNumber ?? this.accountNumber,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      paymentMode: paymentMode ?? this.paymentMode,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }
}

class SalaryAllocationSplit {
  final String bucket;
  final double amount;
  final String status;

  const SalaryAllocationSplit({
    required this.bucket,
    required this.amount,
    required this.status,
  });

  factory SalaryAllocationSplit.fromJson(Map<String, dynamic> json) {
    return SalaryAllocationSplit(
      bucket: json['bucket']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'SCHEDULED',
    );
  }

  Map<String, dynamic> toJson() => {
    'bucket': bucket,
    'amount': amount,
    'status': status,
  };
}

class SalaryAllocationResult {
  final String allocationId;
  final double salaryAmount;
  final String source;
  final String status;
  final String executedAt;
  final List<SalaryAllocationSplit> splits;

  const SalaryAllocationResult({
    required this.allocationId,
    required this.salaryAmount,
    required this.source,
    required this.status,
    required this.executedAt,
    required this.splits,
  });

  factory SalaryAllocationResult.fromJson(Map<String, dynamic> json) {
    final splitsList = (json['splits'] as List<dynamic>?) ?? [];
    return SalaryAllocationResult(
      allocationId: json['allocationId']?.toString() ?? '',
      salaryAmount: (json['salaryAmount'] as num?)?.toDouble() ?? 0.0,
      source: json['source']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ALLOCATED',
      executedAt: json['executedAt']?.toString() ?? '',
      splits: splitsList.map((e) => SalaryAllocationSplit.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class IncomeSummaryData {
  final double totalMonthlyIncome;
  final double activeMonthlyIncome;
  final double passiveMonthlyIncome;
  final double windfallTotalIncome;
  final double totalAnnualIncome;
  final double stabilityScore;
  final String stabilityRating;
  final double passiveRatio;
  final double topDependencyPercent;
  final String topSource;
  final int totalStreamsCount;
  final bool autoTrackingEnabled;
  final String aiCfoInsight;
  final String selectedHorizon;
  final double projectedAmount;
  final Map<String, double> horizonBreakdown;

  const IncomeSummaryData({
    required this.totalMonthlyIncome,
    required this.activeMonthlyIncome,
    required this.passiveMonthlyIncome,
    required this.windfallTotalIncome,
    required this.totalAnnualIncome,
    required this.stabilityScore,
    required this.stabilityRating,
    required this.passiveRatio,
    required this.topDependencyPercent,
    required this.topSource,
    required this.totalStreamsCount,
    required this.autoTrackingEnabled,
    required this.aiCfoInsight,
    required this.selectedHorizon,
    required this.projectedAmount,
    required this.horizonBreakdown,
  });

  factory IncomeSummaryData.fromJson(Map<String, dynamic> json) {
    final forecast = json['forecast'] as Map<String, dynamic>? ?? {};
    final breakdownMap = forecast['horizonBreakdown'] as Map<String, dynamic>? ?? {};
    final convertedBreakdown = <String, double>{};
    breakdownMap.forEach((k, v) {
      if (v is num) {
        convertedBreakdown[k] = v.toDouble();
      }
    });

    return IncomeSummaryData(
      totalMonthlyIncome: (json['totalMonthlyIncome'] as num?)?.toDouble() ?? 0.0,
      activeMonthlyIncome: (json['activeMonthlyIncome'] as num?)?.toDouble() ?? 0.0,
      passiveMonthlyIncome: (json['passiveMonthlyIncome'] as num?)?.toDouble() ?? 0.0,
      windfallTotalIncome: (json['windfallTotalIncome'] as num?)?.toDouble() ?? 0.0,
      totalAnnualIncome: (json['totalAnnualIncome'] as num?)?.toDouble() ?? 0.0,
      stabilityScore: (json['stabilityScore'] as num?)?.toDouble() ?? 50.0,
      stabilityRating: json['stabilityRating']?.toString() ?? 'Moderate',
      passiveRatio: (json['passiveRatio'] as num?)?.toDouble() ?? 0.0,
      topDependencyPercent: (json['topDependencyPercent'] as num?)?.toDouble() ?? 0.0,
      topSource: json['topSource']?.toString() ?? '',
      totalStreamsCount: (json['totalStreamsCount'] as num?)?.toInt() ?? 0,
      autoTrackingEnabled: json['autoTrackingEnabled'] as bool? ?? true,
      aiCfoInsight: (json['aiCfoInsight'] ?? json['aicfoInsight'])?.toString() ?? '',
      selectedHorizon: forecast['selectedHorizon']?.toString() ?? '30D',
      projectedAmount: (forecast['projectedAmount'] as num?)?.toDouble() ?? 0.0,
      horizonBreakdown: convertedBreakdown,
    );
  }
}

class IncomeProofUploadResult {
  final String documentName;
  final String documentPath;
  final int fileSizeBytes;
  final String mimeType;
  final String uploadedAt;
  final String? linkedEntryId;

  const IncomeProofUploadResult({
    required this.documentName,
    required this.documentPath,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.uploadedAt,
    this.linkedEntryId,
  });

  factory IncomeProofUploadResult.fromJson(Map<String, dynamic> json) {
    return IncomeProofUploadResult(
      documentName: json['documentName']?.toString() ?? '',
      documentPath: json['documentPath']?.toString() ?? '',
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      mimeType: json['mimeType']?.toString() ?? '',
      uploadedAt: json['uploadedAt']?.toString() ?? '',
      linkedEntryId: (json['linkedEntryId'] ?? json['entryId'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentName': documentName,
      'documentPath': documentPath,
      'fileSizeBytes': fileSizeBytes,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt,
      if (linkedEntryId != null) 'linkedEntryId': linkedEntryId,
    };
  }
}

class IncomeVoucherData {
  final String voucherNumber;
  final String id;
  final String source;
  final String category;
  final String type;
  final double amount;
  final String amountInWords;
  final String date;
  final String frequency;
  final String bankAccount;
  final bool isVerified;
  final String verificationType;
  final String complianceStandard;
  final String? attachedDocumentUrl;
  final String? voucherPdfUrl;

  const IncomeVoucherData({
    required this.voucherNumber,
    required this.id,
    required this.source,
    required this.category,
    required this.type,
    required this.amount,
    required this.amountInWords,
    required this.date,
    required this.frequency,
    required this.bankAccount,
    required this.isVerified,
    required this.verificationType,
    required this.complianceStandard,
    this.attachedDocumentUrl,
    this.voucherPdfUrl,
  });

  factory IncomeVoucherData.fromJson(Map<String, dynamic> json) {
    return IncomeVoucherData(
      voucherNumber: json['voucherNumber']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountInWords: json['amountInWords']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      bankAccount: json['bankAccount']?.toString() ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      verificationType: json['verificationType']?.toString() ?? 'Digital Voucher',
      complianceStandard: json['complianceStandard']?.toString() ?? 'RBI Account Aggregator & Section 65B',
      attachedDocumentUrl: json['attachedDocumentUrl']?.toString(),
      voucherPdfUrl: json['voucherPdfUrl']?.toString(),
    );
  }
}


class IncomePaginationData {
  final int currentPage;
  final int perPage;
  final int totalRecords;
  final int totalPages;

  const IncomePaginationData({
    this.currentPage = 1,
    this.perPage = 20,
    this.totalRecords = 0,
    this.totalPages = 1,
  });

  factory IncomePaginationData.fromJson(Map<String, dynamic> json) {
    return IncomePaginationData(
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      perPage: (json['perPage'] as num?)?.toInt() ?? 20,
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'perPage': perPage,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
    };
  }
}

class IncomeEntriesResponse {
  final List<IncomeEntry> entries;
  final IncomePaginationData pagination;

  const IncomeEntriesResponse({
    required this.entries,
    required this.pagination,
  });
}

class IncomeForecastData {
  final String selectedHorizon;
  final double projectedAmount;
  final String compoundingRate;
  final double monthlyBaseline;
  final double annualBaseline;
  final Map<String, double> horizonBreakdown;

  const IncomeForecastData({
    required this.selectedHorizon,
    required this.projectedAmount,
    required this.compoundingRate,
    required this.monthlyBaseline,
    required this.annualBaseline,
    required this.horizonBreakdown,
  });

  factory IncomeForecastData.fromJson(Map<String, dynamic> json) {
    final breakdownMap = json['horizonBreakdown'] as Map<String, dynamic>? ?? {};
    final convertedBreakdown = <String, double>{};
    breakdownMap.forEach((k, v) {
      if (v is num) {
        convertedBreakdown[k] = v.toDouble();
      }
    });

    return IncomeForecastData(
      selectedHorizon: json['selectedHorizon']?.toString() ?? '30D',
      projectedAmount: (json['projectedAmount'] as num?)?.toDouble() ?? 0.0,
      compoundingRate: json['compoundingRate']?.toString() ?? '8.0% annual growth model',
      monthlyBaseline: (json['monthlyBaseline'] as num?)?.toDouble() ?? 0.0,
      annualBaseline: (json['annualBaseline'] as num?)?.toDouble() ?? 0.0,
      horizonBreakdown: convertedBreakdown,
    );
  }
}
class IncomeSyncResult {
  final String syncStatus;
  final String syncedAt;
  final int detectedCount;
  final List<String> channels;
  final String lastSyncTimestamp;

  const IncomeSyncResult({
    required this.syncStatus,
    required this.syncedAt,
    required this.detectedCount,
    required this.channels,
    required this.lastSyncTimestamp,
  });

  factory IncomeSyncResult.fromJson(Map<String, dynamic> json) {
    return IncomeSyncResult(
      syncStatus: json['syncStatus']?.toString() ?? 'SUCCESS',
      syncedAt: json['syncedAt']?.toString() ?? '',
      detectedCount: (json['detectedCount'] as num?)?.toInt() ?? 0,
      channels: (json['channels'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      lastSyncTimestamp: json['lastSyncTimestamp']?.toString() ?? '',
    );
  }
}

class DetectedInflow {
  final String detectedId;
  final String detectedSource;
  final String suggestedCategory;
  final double amount;
  final String date;
  final String bankAccount;
  final double confidenceScore;
  final String detectionChannel;
  final String? rawSms;
  final String? referenceId;
  final String? status;

  const DetectedInflow({
    required this.detectedId,
    required this.detectedSource,
    required this.suggestedCategory,
    required this.amount,
    required this.date,
    required this.bankAccount,
    required this.confidenceScore,
    required this.detectionChannel,
    this.rawSms,
    this.referenceId,
    this.status = 'UNCONFIRMED',
  });

  factory DetectedInflow.fromJson(Map<String, dynamic> json) {
    double amt = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final raw = json['rawSms']?.toString();
    if (amt <= 0.0 && raw != null && raw.isNotEmpty) {
      final match = RegExp(r'(?:Rs\.?|INR)\s*[:.]?\s*([\d,]+\.?\d*)', caseSensitive: false).firstMatch(raw);
      if (match != null) {
        final clean = match.group(1)!.replaceAll(',', '');
        amt = double.tryParse(clean) ?? amt;
      }
    }

    return DetectedInflow(
      detectedId: (json['detectedId'] ?? json['id'] ?? json['detectionId'])?.toString() ?? '',
      detectedSource: (json['detectedSource'] ?? json['sourceName'] ?? json['merchantOrSource'] ?? json['source'])?.toString() ?? '',
      suggestedCategory: (json['suggestedCategory'] ?? json['category'])?.toString() ?? 'Salary',
      amount: amt,
      date: json['date']?.toString() ?? '',
      bankAccount: (json['bankAccount'] ?? json['paymentMode'] ?? json['bankName'])?.toString() ?? '',
      confidenceScore: ((json['confidenceScore'] ?? json['confidence']) as num?)?.toDouble() ?? 0.95,
      detectionChannel: json['detectionChannel']?.toString() ?? 'ACCOUNT_AGGREGATOR',
      rawSms: raw,
      referenceId: json['referenceId']?.toString(),
      status: json['status']?.toString() ?? 'UNCONFIRMED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detectedId': detectedId,
      'detectedSource': detectedSource,
      'suggestedCategory': suggestedCategory,
      'amount': amount,
      'date': date,
      'bankAccount': bankAccount,
      'confidenceScore': confidenceScore,
      'detectionChannel': detectionChannel,
      if (rawSms != null) 'rawSms': rawSms,
      if (referenceId != null) 'referenceId': referenceId,
      if (status != null) 'status': status,
    };
  }
}

class IncomeState {
  final List<IncomeEntry> entries;
  final String searchQuery;
  final String selectedCategoryFilter;
  final String selectedTypeFilter;
  final String selectedBankAccountFilter;
  final String selectedDateFilter;
  final String forecastHorizon; // '30D', '90D', '1Y', '5Y'
  final bool autoTrackingEnabled;
  final bool isLoading;
  final bool isSyncing;
  final String? errorMessage;
  final IncomeSummaryData? summaryData;
  final IncomePaginationData? pagination;
  final IncomeForecastData? forecastData;
  final int currentPage;
  final List<DetectedInflow> detectedInflows;
  final IncomeSyncResult? lastSyncResult;

  const IncomeState({
    required this.entries,
    this.searchQuery = '',
    this.selectedCategoryFilter = 'All',
    this.selectedTypeFilter = 'All',
    this.selectedBankAccountFilter = 'All',
    this.selectedDateFilter = 'All',
    this.forecastHorizon = '30D',
    this.autoTrackingEnabled = true,
    this.isLoading = false,
    this.isSyncing = false,
    this.errorMessage,
    this.summaryData,
    this.pagination,
    this.forecastData,
    this.currentPage = 1,
    this.detectedInflows = const [],
    this.lastSyncResult,
  });

  double _getMonthlyEquivalent(IncomeEntry e) {
    final freq = e.frequency.toLowerCase();
    if (freq == 'one-time' || e.type.toLowerCase() == 'windfall') return 0.0;
    if (freq == 'yearly') return e.amount / 12.0;
    if (freq == 'quarterly') return e.amount / 3.0;
    if (freq == 'bi-weekly') return e.amount * 2.0;
    return e.amount;
  }

  double get totalMonthlyIncome {
    if (summaryData != null) return summaryData!.totalMonthlyIncome;
    return entries.fold(0.0, (sum, e) => sum + _getMonthlyEquivalent(e));
  }

  double get activeMonthlyIncome {
    if (summaryData != null) return summaryData!.activeMonthlyIncome;
    return entries.fold(0.0, (sum, e) {
      if (e.type.toLowerCase() == 'active') {
        return sum + _getMonthlyEquivalent(e);
      }
      return sum;
    });
  }

  double get passiveMonthlyIncome {
    if (summaryData != null) return summaryData!.passiveMonthlyIncome;
    return entries.fold(0.0, (sum, e) {
      if (e.type.toLowerCase() == 'passive') {
        return sum + _getMonthlyEquivalent(e);
      }
      return sum;
    });
  }

  double get windfallTotalIncome {
    if (summaryData != null) return summaryData!.windfallTotalIncome;
    return entries.fold(0.0, (sum, e) {
      if (e.type.toLowerCase() == 'windfall' || e.frequency.toLowerCase() == 'one-time') {
        return sum + e.amount;
      }
      return sum;
    });
  }

  double get totalAnnualIncome {
    if (summaryData != null) return summaryData!.totalAnnualIncome;
    return (totalMonthlyIncome * 12) + windfallTotalIncome;
  }

  double get passiveRatio {
    if (summaryData != null) return summaryData!.passiveRatio;
    if (totalMonthlyIncome <= 0) return 0.0;
    return ((passiveMonthlyIncome / totalMonthlyIncome) * 100).clamp(0.0, 100.0);
  }

  double get stabilityScore {
    if (summaryData != null) return summaryData!.stabilityScore;
    if (entries.isEmpty || totalMonthlyIncome <= 0) return 50.0;
    final total = totalMonthlyIncome + windfallTotalIncome;
    final recurringRatio = total > 0 ? (totalMonthlyIncome / total) : 1.0;
    final countWeight = (entries.length / 5).clamp(0.0, 1.0);
    final passiveBonus = (passiveRatio / 50.0).clamp(0.0, 0.2);
    final score = (recurringRatio * 55) + (countWeight * 35) + (passiveBonus * 10);
    return score.clamp(40.0, 96.0);
  }

  String get stabilityRating {
    if (summaryData != null) return summaryData!.stabilityRating;
    if (stabilityScore >= 75) return 'High Stability';
    if (stabilityScore >= 55) return 'Moderate Stability';
    return 'Low Stability';
  }

  double get topDependencyPercent {
    if (summaryData != null) return summaryData!.topDependencyPercent;
    if (entries.isEmpty || totalMonthlyIncome <= 0) return 0.0;
    double maxAmt = 0.0;
    for (final e in entries) {
      final monthly = _getMonthlyEquivalent(e);
      if (monthly > maxAmt) {
        maxAmt = monthly;
      }
    }
    return ((maxAmt / totalMonthlyIncome) * 100).clamp(0.0, 100.0);
  }

  String get topSource {
    if (summaryData != null && summaryData!.topSource.isNotEmpty) {
      return summaryData!.topSource;
    }
    if (entries.isEmpty) return '';
    IncomeEntry? maxEntry;
    double maxAmt = -1;
    for (final e in entries) {
      final m = _getMonthlyEquivalent(e);
      if (m > maxAmt) {
        maxAmt = m;
        maxEntry = e;
      }
    }
    return maxEntry?.source ?? '';
  }

  String get aiCfoInsight {
    if (summaryData != null && summaryData!.aiCfoInsight.isNotEmpty) {
      return summaryData!.aiCfoInsight;
    }
    return '$stabilityRating (Score ${stabilityScore.toStringAsFixed(0)}/100). Passive cash flow generates ₹${passiveMonthlyIncome.round()}/mo across holdings.';
  }

  double getForecastAmount(String horizon) {
    if (summaryData != null && summaryData!.selectedHorizon == horizon) {
      return summaryData!.projectedAmount;
    }
    if (forecastData != null && forecastData!.selectedHorizon == horizon) {
      return forecastData!.projectedAmount;
    }
    if (summaryData != null && summaryData!.horizonBreakdown.containsKey(horizon)) {
      return summaryData!.horizonBreakdown[horizon]!;
    }
    if (forecastData != null && forecastData!.horizonBreakdown.containsKey(horizon)) {
      return forecastData!.horizonBreakdown[horizon]!;
    }
    switch (horizon) {
      case '30D':
        return totalMonthlyIncome;
      case '90D':
        return totalMonthlyIncome * 3;
      case '1Y':
        return totalAnnualIncome;
      case '5Y':
        return (totalMonthlyIncome * 12 * 5.86) + (windfallTotalIncome * 5);
      default:
        return totalMonthlyIncome;
    }
  }

  IncomeState copyWith({
    List<IncomeEntry>? entries,
    String? searchQuery,
    String? selectedCategoryFilter,
    String? selectedTypeFilter,
    String? selectedBankAccountFilter,
    String? selectedDateFilter,
    String? forecastHorizon,
    bool? autoTrackingEnabled,
    bool? isLoading,
    bool? isSyncing,
    String? errorMessage,
    IncomeSummaryData? summaryData,
    IncomePaginationData? pagination,
    IncomeForecastData? forecastData,
    int? currentPage,
    List<DetectedInflow>? detectedInflows,
    IncomeSyncResult? lastSyncResult,
  }) {
    return IncomeState(
      entries: entries ?? this.entries,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryFilter: selectedCategoryFilter ?? this.selectedCategoryFilter,
      selectedTypeFilter: selectedTypeFilter ?? this.selectedTypeFilter,
      selectedBankAccountFilter: selectedBankAccountFilter ?? this.selectedBankAccountFilter,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      forecastHorizon: forecastHorizon ?? this.forecastHorizon,
      autoTrackingEnabled: autoTrackingEnabled ?? this.autoTrackingEnabled,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage,
      summaryData: summaryData ?? this.summaryData,
      pagination: pagination ?? this.pagination,
      forecastData: forecastData ?? this.forecastData,
      currentPage: currentPage ?? this.currentPage,
      detectedInflows: detectedInflows ?? this.detectedInflows,
      lastSyncResult: lastSyncResult ?? this.lastSyncResult,
    );
  }
}
