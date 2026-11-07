enum BudgetAlertLevel {
  none,
  approaching80,
  limitReached100,
  exceeded,
}

class EligibleBudgetTransaction {
  final String id;
  final String? userId;
  final double amount;
  final String date;
  final String category;
  final String description;
  final String paymentMode;
  final String? merchant;
  final String? bankAccount;
  final String? invoiceNumber;
  final String? priority;
  final String? documentName;
  final String? documentPath;
  final String? receiptUrl;
  final bool isVerified;
  final String? createdAt;

  const EligibleBudgetTransaction({
    required this.id,
    this.userId,
    required this.amount,
    required this.date,
    required this.category,
    required this.description,
    required this.paymentMode,
    this.merchant,
    this.bankAccount,
    this.invoiceNumber,
    this.priority,
    this.documentName,
    this.documentPath,
    this.receiptUrl,
    this.isVerified = false,
    this.createdAt,
  });

  factory EligibleBudgetTransaction.fromJson(Map<String, dynamic> json) {
    return EligibleBudgetTransaction(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      paymentMode: json['paymentMode'] as String? ?? '',
      merchant: json['merchant'] as String?,
      bankAccount: json['bankAccount'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      priority: json['priority'] as String?,
      documentName: json['documentName'] as String?,
      documentPath: json['documentPath'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'amount': amount,
      'date': date,
      'category': category,
      'description': description,
      'paymentMode': paymentMode,
      if (merchant != null) 'merchant': merchant,
      if (bankAccount != null) 'bankAccount': bankAccount,
      if (invoiceNumber != null) 'invoiceNumber': invoiceNumber,
      if (priority != null) 'priority': priority,
      if (documentName != null) 'documentName': documentName,
      if (documentPath != null) 'documentPath': documentPath,
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
      'isVerified': isVerified,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}

class BudgetItem {
  final String id;
  final String name;
  final String type; // 'Monthly Budget', 'Category-wise Budget'
  final String category;
  final double amount;
  final double spent;
  final String startDate;
  final String endDate;
  final String period; // e.g. "Monthly" or "October 2026"
  final BudgetAlertLevel lastAlertTriggered;
  final String status; // 'none', 'onTrack', 'warning', 'exceeded'
  final String threshold;
  final double alertThreshold;
  final bool alertsEnabled;
  final int recentTransactionsCount;
  final List<EligibleBudgetTransaction> eligibleTransactions;
  final String? createdAt;
  final String? updatedAt;
  final double? dailyBurnRate;
  final double? projectedMonthEndSpent;
  final double? projectedVariance;

  const BudgetItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.amount,
    required this.spent,
    required this.startDate,
    required this.endDate,
    this.period = 'Monthly',
    this.lastAlertTriggered = BudgetAlertLevel.none,
    this.status = 'none',
    this.threshold = 'none',
    this.alertThreshold = 80.0,
    this.alertsEnabled = true,
    this.recentTransactionsCount = 0,
    this.eligibleTransactions = const [],
    this.createdAt,
    this.updatedAt,
    this.dailyBurnRate,
    this.projectedMonthEndSpent,
    this.projectedVariance,
  });

  /// Remaining Budget = Budget Amount − Total Eligible Expenses
  double get remaining => (amount - spent) >= 0 ? (amount - spent) : 0.0;

  /// Overspent Amount = Total Eligible Expenses − Budget Amount
  double get overspentAmount => spent > amount ? (spent - amount) : 0.0;

  /// Budget Utilization = (Total Eligible Expenses ÷ Budget Amount) × 100
  double get utilizationPercentage => amount > 0 ? ((spent / amount) * 100) : 0.0;

  /// Progress ratio clamped between 0.0 and 1.0 for standard UI progress indicators
  double get progressPercentage => amount > 0 ? (spent / amount).clamp(0.0, 1.0) * 100 : 0.0;

  bool get isExceeded => spent > amount || status.toLowerCase() == 'exceeded' || threshold.toLowerCase() == 'exceeded';
  bool get isApproachingLimit =>
      (spent >= (amount * (alertThreshold / 100)) && spent < amount) ||
      status.toLowerCase() == 'warning' ||
      threshold.toLowerCase() == 'warning';
  bool get isLimitReached => spent >= amount && spent <= (amount * 1.001);

  BudgetAlertLevel get currentAlertLevel {
    if (isExceeded) return BudgetAlertLevel.exceeded;
    if (isLimitReached) return BudgetAlertLevel.limitReached100;
    if (isApproachingLimit) return BudgetAlertLevel.approaching80;
    return BudgetAlertLevel.none;
  }

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    var rawTxs = json['eligibleTransactions'] ?? json['transactions'];
    List<EligibleBudgetTransaction> txList = [];
    if (rawTxs is List) {
      txList = rawTxs
          .whereType<Map<String, dynamic>>()
          .map((t) => EligibleBudgetTransaction.fromJson(t))
          .toList();
    }

    final double amt = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final double spnt = (json['spent'] as num?)?.toDouble() ?? 0.0;
    final String rawStatus = json['status'] as String? ?? 'none';

    BudgetAlertLevel alertLevel = BudgetAlertLevel.none;
    if (spnt > amt || rawStatus.toLowerCase() == 'exceeded') {
      alertLevel = BudgetAlertLevel.exceeded;
    } else if (spnt >= (amt * 0.8)) {
      alertLevel = BudgetAlertLevel.approaching80;
    }

    return BudgetItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? (json['category'] as String? ?? 'Budget'),
      type: json['type'] as String? ?? 'Category-wise Budget',
      category: json['category'] as String? ?? 'General',
      amount: amt,
      spent: spnt,
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      period: json['period'] as String? ?? 'Monthly',
      lastAlertTriggered: alertLevel,
      status: rawStatus,
      threshold: json['threshold'] as String? ?? 'none',
      alertThreshold: (json['alertThreshold'] as num?)?.toDouble() ?? 80.0,
      alertsEnabled: json['alertsEnabled'] as bool? ?? true,
      recentTransactionsCount: (json['recentTransactionsCount'] as num?)?.toInt() ?? txList.length,
      eligibleTransactions: txList,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      dailyBurnRate: (json['dailyBurnRate'] as num?)?.toDouble(),
      projectedMonthEndSpent: (json['projectedMonthEndSpent'] as num?)?.toDouble(),
      projectedVariance: (json['projectedVariance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'type': type,
      'period': period,
      'amount': amount,
      'spent': spent,
      'remaining': remaining,
      'overspent': overspentAmount,
      'utilizationPercentage': utilizationPercentage,
      'status': status,
      'threshold': threshold,
      'alertThreshold': alertThreshold,
      'alertsEnabled': alertsEnabled,
      'startDate': startDate,
      'endDate': endDate,
      'recentTransactionsCount': recentTransactionsCount,
      'eligibleTransactions': eligibleTransactions.map((t) => t.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (dailyBurnRate != null) 'dailyBurnRate': dailyBurnRate,
      if (projectedMonthEndSpent != null) 'projectedMonthEndSpent': projectedMonthEndSpent,
      if (projectedVariance != null) 'projectedVariance': projectedVariance,
    };
  }

  BudgetItem copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    double? amount,
    double? spent,
    String? startDate,
    String? endDate,
    String? period,
    BudgetAlertLevel? lastAlertTriggered,
    String? status,
    String? threshold,
    double? alertThreshold,
    bool? alertsEnabled,
    int? recentTransactionsCount,
    List<EligibleBudgetTransaction>? eligibleTransactions,
    String? createdAt,
    String? updatedAt,
    double? dailyBurnRate,
    double? projectedMonthEndSpent,
    double? projectedVariance,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      period: period ?? this.period,
      lastAlertTriggered: lastAlertTriggered ?? this.lastAlertTriggered,
      status: status ?? this.status,
      threshold: threshold ?? this.threshold,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      recentTransactionsCount: recentTransactionsCount ?? this.recentTransactionsCount,
      eligibleTransactions: eligibleTransactions ?? this.eligibleTransactions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dailyBurnRate: dailyBurnRate ?? this.dailyBurnRate,
      projectedMonthEndSpent: projectedMonthEndSpent ?? this.projectedMonthEndSpent,
      projectedVariance: projectedVariance ?? this.projectedVariance,
    );
  }
}

class BudgetSummaryData {
  final double totalBudget;
  final double totalSpent;
  final double remaining;
  final double overspent;
  final double overallUsage;
  final int activeCategoriesCount;
  final int totalBudgetsCount;
  final int exceededCount;
  final int warningCount;
  final int onTrackCount;
  final String aiCfoInsight;

  const BudgetSummaryData({
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.overspent,
    required this.overallUsage,
    required this.activeCategoriesCount,
    required this.totalBudgetsCount,
    required this.exceededCount,
    required this.warningCount,
    required this.onTrackCount,
    required this.aiCfoInsight,
  });

  factory BudgetSummaryData.fromJson(Map<String, dynamic> json) {
    return BudgetSummaryData(
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      overspent: (json['overspent'] as num?)?.toDouble() ?? 0.0,
      overallUsage: (json['overallUsage'] as num?)?.toDouble() ?? 0.0,
      activeCategoriesCount: (json['activeCategoriesCount'] as num?)?.toInt() ?? 0,
      totalBudgetsCount: (json['totalBudgetsCount'] as num?)?.toInt() ?? 0,
      exceededCount: (json['exceededCount'] as num?)?.toInt() ?? 0,
      warningCount: (json['warningCount'] as num?)?.toInt() ?? 0,
      onTrackCount: (json['onTrackCount'] as num?)?.toInt() ?? 0,
      aiCfoInsight: json['aiCfoInsight'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'remaining': remaining,
      'overspent': overspent,
      'overallUsage': overallUsage,
      'activeCategoriesCount': activeCategoriesCount,
      'totalBudgetsCount': totalBudgetsCount,
      'exceededCount': exceededCount,
      'warningCount': warningCount,
      'onTrackCount': onTrackCount,
      'aiCfoInsight': aiCfoInsight,
    };
  }
}

class CategoryUtilizationData {
  final String category;
  final String budgetId;
  final double budgeted;
  final double spent;
  final double remaining;
  final double utilizationPercentage;
  final String status;
  final int daysInPeriod;
  final int daysElapsed;
  final double dailyBurnRate;
  final double projectedMonthEndSpent;
  final double projectedVariance;

  const CategoryUtilizationData({
    required this.category,
    required this.budgetId,
    required this.budgeted,
    required this.spent,
    required this.remaining,
    required this.utilizationPercentage,
    required this.status,
    required this.daysInPeriod,
    required this.daysElapsed,
    required this.dailyBurnRate,
    required this.projectedMonthEndSpent,
    required this.projectedVariance,
  });

  factory CategoryUtilizationData.fromJson(Map<String, dynamic> json) {
    return CategoryUtilizationData(
      category: json['category'] as String? ?? '',
      budgetId: json['budgetId'] as String? ?? '',
      budgeted: (json['budgeted'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      utilizationPercentage: (json['utilizationPercentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'none',
      daysInPeriod: (json['daysInPeriod'] as num?)?.toInt() ?? 30,
      daysElapsed: (json['daysElapsed'] as num?)?.toInt() ?? 0,
      dailyBurnRate: (json['dailyBurnRate'] as num?)?.toDouble() ?? 0.0,
      projectedMonthEndSpent: (json['projectedMonthEndSpent'] as num?)?.toDouble() ?? 0.0,
      projectedVariance: (json['projectedVariance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'budgetId': budgetId,
      'budgeted': budgeted,
      'spent': spent,
      'remaining': remaining,
      'utilizationPercentage': utilizationPercentage,
      'status': status,
      'daysInPeriod': daysInPeriod,
      'daysElapsed': daysElapsed,
      'dailyBurnRate': dailyBurnRate,
      'projectedMonthEndSpent': projectedMonthEndSpent,
      'projectedVariance': projectedVariance,
    };
  }
}

class BudgetAnalyticsResponse {
  final List<CategoryUtilizationData> categories;
  final String highestUtilizedCategory;
  final double totalDailyBurnRate;
  final double projectedTotalOutflow;

  const BudgetAnalyticsResponse({
    required this.categories,
    required this.highestUtilizedCategory,
    required this.totalDailyBurnRate,
    required this.projectedTotalOutflow,
  });

  factory BudgetAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    var rawCategories = json['categories'];
    List<CategoryUtilizationData> catList = [];
    if (rawCategories is List) {
      catList = rawCategories
          .whereType<Map<String, dynamic>>()
          .map((c) => CategoryUtilizationData.fromJson(c))
          .toList();
    }

    return BudgetAnalyticsResponse(
      categories: catList,
      highestUtilizedCategory: json['highestUtilizedCategory'] as String? ?? '',
      totalDailyBurnRate: (json['totalDailyBurnRate'] as num?)?.toDouble() ?? 0.0,
      projectedTotalOutflow: (json['projectedTotalOutflow'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ActiveBudgetAlert {
  final String alertId;
  final String budgetId;
  final String category;
  final String threshold;
  final String severity;
  final String title;
  final String message;
  final double utilizationPercentage;
  final bool isDismissed;
  final String createdAt;

  const ActiveBudgetAlert({
    required this.alertId,
    required this.budgetId,
    required this.category,
    required this.threshold,
    required this.severity,
    required this.title,
    required this.message,
    required this.utilizationPercentage,
    required this.isDismissed,
    required this.createdAt,
  });

  factory ActiveBudgetAlert.fromJson(Map<String, dynamic> json) {
    return ActiveBudgetAlert(
      alertId: json['alertId'] as String? ?? '',
      budgetId: json['budgetId'] as String? ?? '',
      category: json['category'] as String? ?? '',
      threshold: json['threshold'] as String? ?? 'none',
      severity: json['severity'] as String? ?? 'INFO',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      utilizationPercentage: (json['utilizationPercentage'] as num?)?.toDouble() ?? 0.0,
      isDismissed: json['isDismissed'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  ActiveBudgetAlert copyWith({bool? isDismissed}) {
    return ActiveBudgetAlert(
      alertId: alertId,
      budgetId: budgetId,
      category: category,
      threshold: threshold,
      severity: severity,
      title: title,
      message: message,
      utilizationPercentage: utilizationPercentage,
      isDismissed: isDismissed ?? this.isDismissed,
      createdAt: createdAt,
    );
  }
}

class GuardrailSettings {
  final bool autoSmsDeduction;
  final bool warning80Alerts;
  final bool overspendingBanners;
  final double thresholdPercent;
  final bool enableOverspendPush;
  final String? updatedAt;

  const GuardrailSettings({
    this.autoSmsDeduction = true,
    this.warning80Alerts = true,
    this.overspendingBanners = true,
    this.thresholdPercent = 80.0,
    this.enableOverspendPush = true,
    this.updatedAt,
  });

  factory GuardrailSettings.fromJson(Map<String, dynamic> json) {
    return GuardrailSettings(
      autoSmsDeduction: json['autoSmsDeduction'] as bool? ?? true,
      warning80Alerts: json['warning80Alerts'] as bool? ?? true,
      overspendingBanners: json['overspendingBanners'] as bool? ?? true,
      thresholdPercent: (json['thresholdPercent'] as num?)?.toDouble() ?? 80.0,
      enableOverspendPush: json['enableOverspendPush'] as bool? ?? true,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoSmsDeduction': autoSmsDeduction,
      'warning80Alerts': warning80Alerts,
      'overspendingBanners': overspendingBanners,
      'thresholdPercent': thresholdPercent,
      'enableOverspendPush': enableOverspendPush,
    };
  }

  GuardrailSettings copyWith({
    bool? autoSmsDeduction,
    bool? warning80Alerts,
    bool? overspendingBanners,
    double? thresholdPercent,
    bool? enableOverspendPush,
    String? updatedAt,
  }) {
    return GuardrailSettings(
      autoSmsDeduction: autoSmsDeduction ?? this.autoSmsDeduction,
      warning80Alerts: warning80Alerts ?? this.warning80Alerts,
      overspendingBanners: overspendingBanners ?? this.overspendingBanners,
      thresholdPercent: thresholdPercent ?? this.thresholdPercent,
      enableOverspendPush: enableOverspendPush ?? this.enableOverspendPush,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BudgetAlertEvent {
  final BudgetItem budget;
  final BudgetAlertLevel level;
  final String title;
  final String message;
  final double overspentAmount;
  final double utilizationPercentage;

  const BudgetAlertEvent({
    required this.budget,
    required this.level,
    required this.title,
    required this.message,
    required this.overspentAmount,
    required this.utilizationPercentage,
  });
}

class BudgetState {
  final List<BudgetItem> budgets;
  final bool alertEnabled;
  final BudgetAlertEvent? activeBannerAlert;
  final BudgetSummaryData? summary;
  final BudgetAnalyticsResponse? analytics;
  final List<ActiveBudgetAlert> activeAlerts;
  final GuardrailSettings guardrails;
  final bool isLoading;
  final bool isSyncing;
  final String? error;

  const BudgetState({
    required this.budgets,
    this.alertEnabled = true,
    this.activeBannerAlert,
    this.summary,
    this.analytics,
    this.activeAlerts = const [],
    this.guardrails = const GuardrailSettings(),
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
  });

  double get totalBudget {
    if (budgets.isNotEmpty) {
      return budgets.fold(0.0, (sum, b) => sum + b.amount);
    }
    return summary?.totalBudget ?? 0.0;
  }

  double get totalSpent {
    if (budgets.isNotEmpty) {
      return budgets.fold(0.0, (sum, b) => sum + b.spent);
    }
    return summary?.totalSpent ?? 0.0;
  }

  double get totalRemaining => (totalBudget - totalSpent) >= 0 ? (totalBudget - totalSpent) : 0.0;
  double get totalOverspent => totalSpent > totalBudget ? (totalSpent - totalBudget) : 0.0;
  double get overallUsagePercentage => totalBudget > 0 ? ((totalSpent / totalBudget) * 100).clamp(0.0, 999.0) : (summary?.overallUsage ?? 0.0);

  List<BudgetItem> get exceededBudgets => budgets.where((b) => b.isExceeded).toList();
  List<BudgetItem> get warningBudgets => budgets.where((b) => b.isApproachingLimit).toList();

  BudgetState copyWith({
    List<BudgetItem>? budgets,
    bool? alertEnabled,
    BudgetAlertEvent? activeBannerAlert,
    bool clearActiveBanner = false,
    BudgetSummaryData? summary,
    BudgetAnalyticsResponse? analytics,
    List<ActiveBudgetAlert>? activeAlerts,
    GuardrailSettings? guardrails,
    bool? isLoading,
    bool? isSyncing,
    String? error,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      activeBannerAlert: clearActiveBanner ? null : (activeBannerAlert ?? this.activeBannerAlert),
      summary: summary ?? this.summary,
      analytics: analytics ?? this.analytics,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      guardrails: guardrails ?? this.guardrails,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
    );
  }
}
