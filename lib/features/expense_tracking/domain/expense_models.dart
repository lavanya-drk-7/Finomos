import 'package:flutter/material.dart';

enum ExpensePaymentStatus {
  paymentSuccess, // Payment Success
  dueInDays, // Due in 7 Days (or X days)
  payImmediately, // Pay Immediately (Overdue)
  paymentFailed, // Payment Failed
}

class ExpenseStatusInfo {
  final ExpensePaymentStatus status;
  final String label;
  final Color primaryColor;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;

  const ExpenseStatusInfo({
    required this.status,
    required this.label,
    required this.primaryColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });
}

class ExpenseEntry {
  final String id;
  final String description;
  final String
  category; // Housing, Food, Utilities, Transport, Healthcare, Shopping, Entertainment, Subscriptions, Bills, Other, Food & Dining, Fixed Deposit / RD, Loan & EMI
  final double amount;
  final String date;
  final String
  paymentMode; // UPI, Credit Card, Debit Card, Net Banking, Cash, HDFC Bank (**** 8754)
  final String
  priority; // P1 - Survival, P2 - Protection, P3 - Obligations, P4 - Growth, P5 - Lifestyle, P6 - Luxury
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
  final String? paymentStatus; // SUCCESS, DUE_SOON, OVERDUE, FAILED
  final int? recurringDayOfMonth; // e.g., 5 for 5th of every month
  final String? dueDate;
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
    this.bankAccount = '',
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
    this.paymentStatus,
    this.recurringDayOfMonth,
    this.dueDate,
    this.account,
  });

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) {
    final desc =
        (json['description'] ?? json['merchant'] ?? '')?.toString() ?? '';
    final merchantStr =
        (json['merchant'] ?? json['description'] ?? '')?.toString() ?? '';
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
      bankAccount:
          (json['bankAccount'] ?? json['paymentMode'])?.toString() ?? '',
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
      remainingBalanceOrCredit: (json['remainingBalanceOrCredit'] as num?)
          ?.toDouble(),
      transactionStatus: json['transactionStatus'] as String?,
      paymentStatus:
          (json['paymentStatus'] ?? json['status'] ?? json['transactionStatus'])
              ?.toString(),
      recurringDayOfMonth: (json['recurringDayOfMonth'] as num?)?.toInt(),
      dueDate: json['dueDate']?.toString(),
      account: json['account'] is Map<String, dynamic>
          ? ExpenseAccountDetail.fromJson(
              json['account'] as Map<String, dynamic>,
            )
          : null,
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
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      if (recurringDayOfMonth != null)
        'recurringDayOfMonth': recurringDayOfMonth,
      if (dueDate != null) 'dueDate': dueDate,
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
    String? paymentStatus,
    int? recurringDayOfMonth,
    String? dueDate,
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
      paymentStatus: paymentStatus ?? this.paymentStatus,
      recurringDayOfMonth: recurringDayOfMonth ?? this.recurringDayOfMonth,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  /// Calculates dynamic payment status for expense sources & commitments:
  /// - Payment Success
  /// - Due in 7 Days (or X days)
  /// - Pay Immediately (Overdue)
  /// - Payment Failed
  ExpenseStatusInfo get statusInfo {
    // 1. Explicit status check
    final raw = (paymentStatus ?? transactionStatus ?? '').toUpperCase();
    if (raw == 'FAILED' || raw.contains('FAIL')) {
      return const ExpenseStatusInfo(
        status: ExpensePaymentStatus.paymentFailed,
        label: 'Payment Failed',
        primaryColor: Color(0xFFDC2626),
        backgroundColor: Color(0xFFFEF2F2),
        borderColor: Color(0xFFFCA5A5),
        icon: Icons.cancel_rounded,
      );
    }

    if (raw == 'OVERDUE' || raw == 'PAY_IMMEDIATELY') {
      return const ExpenseStatusInfo(
        status: ExpensePaymentStatus.payImmediately,
        label: 'Pay Immediately',
        primaryColor: Color(0xFFDC2626),
        backgroundColor: Color(0xFFFEF2F2),
        borderColor: Color(0xFFFECACA),
        icon: Icons.warning_amber_rounded,
      );
    }

    if (raw == 'DUE_SOON' || raw == 'DUE_IN_7_DAYS') {
      return const ExpenseStatusInfo(
        status: ExpensePaymentStatus.dueInDays,
        label: 'Due in 7 Days',
        primaryColor: Color(0xFFD97706),
        backgroundColor: Color(0xFFFFFBEB),
        borderColor: Color(0xFFFDE68A),
        icon: Icons.schedule_rounded,
      );
    }

    if (raw == 'SUCCESS' ||
        raw == 'PAID' ||
        raw == 'COMPLETED' ||
        raw == 'SETTLED') {
      return const ExpenseStatusInfo(
        status: ExpensePaymentStatus.paymentSuccess,
        label: 'Payment Success',
        primaryColor: Color(0xFF059669),
        backgroundColor: Color(0xFFECFDF5),
        borderColor: Color(0xFFA7F3D0),
        icon: Icons.check_circle_rounded,
      );
    }

    // 2. Calculation based on recurringDayOfMonth (e.g. 5th of every month)
    final now = DateTime.now();
    int? targetDay = recurringDayOfMonth;

    // If recurringDayOfMonth not set but notes or date mentions day
    if (targetDay == null && isRecurring) {
      final match = RegExp(
        r'(\d{1,2})(?:st|nd|rd|th)?\b',
      ).firstMatch(notes.isNotEmpty ? notes : date);
      if (match != null) {
        final parsed = int.tryParse(match.group(1)!);
        if (parsed != null && parsed >= 1 && parsed <= 31) {
          targetDay = parsed;
        }
      }
    }

    if (targetDay != null && targetDay >= 1 && targetDay <= 31) {
      DateTime targetDueDate;
      try {
        targetDueDate = DateTime(now.year, now.month, targetDay);
      } catch (_) {
        targetDueDate = DateTime(now.year, now.month + 1, 0);
      }

      final todayMidnight = DateTime(now.year, now.month, now.day);
      final diff = targetDueDate.difference(todayMidnight).inDays;

      if (diff < 0) {
        // Due date has completed / passed and user has not paid
        return const ExpenseStatusInfo(
          status: ExpensePaymentStatus.payImmediately,
          label: 'Pay Immediately',
          primaryColor: Color(0xFFDC2626),
          backgroundColor: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFECACA),
          icon: Icons.warning_amber_rounded,
        );
      } else if (diff == 0) {
        return const ExpenseStatusInfo(
          status: ExpensePaymentStatus.dueInDays,
          label: 'Due Today',
          primaryColor: Color(0xFFD97706),
          backgroundColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
          icon: Icons.schedule_rounded,
        );
      } else if (diff == 1) {
        return const ExpenseStatusInfo(
          status: ExpensePaymentStatus.dueInDays,
          label: 'Due Tomorrow',
          primaryColor: Color(0xFFD97706),
          backgroundColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
          icon: Icons.schedule_rounded,
        );
      } else if (diff <= 7) {
        return ExpenseStatusInfo(
          status: ExpensePaymentStatus.dueInDays,
          label: 'Due in $diff Days',
          primaryColor: const Color(0xFFD97706),
          backgroundColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
          icon: Icons.schedule_rounded,
        );
      } else {
        return ExpenseStatusInfo(
          status: ExpensePaymentStatus.dueInDays,
          label: 'Due in $diff Days',
          primaryColor: const Color(0xFF2563EB),
          backgroundColor: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFBFDBFE),
          icon: Icons.calendar_today_outlined,
        );
      }
    }

    // 3. Calculation based on dueDate string if provided
    if (dueDate != null && dueDate!.isNotEmpty) {
      final parsedDate = DateTime.tryParse(dueDate!);
      if (parsedDate != null) {
        final todayMidnight = DateTime(now.year, now.month, now.day);
        final diff = parsedDate.difference(todayMidnight).inDays;
        if (diff < 0) {
          return const ExpenseStatusInfo(
            status: ExpensePaymentStatus.payImmediately,
            label: 'Pay Immediately',
            primaryColor: Color(0xFFDC2626),
            backgroundColor: Color(0xFFFEF2F2),
            borderColor: Color(0xFFFECACA),
            icon: Icons.warning_amber_rounded,
          );
        } else if (diff <= 7) {
          return ExpenseStatusInfo(
            status: ExpensePaymentStatus.dueInDays,
            label: diff == 0
                ? 'Due Today'
                : (diff == 1 ? 'Due Tomorrow' : 'Due in $diff Days'),
            primaryColor: const Color(0xFFD97706),
            backgroundColor: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFDE68A),
            icon: Icons.schedule_rounded,
          );
        }
      }
    }

    // 4. Fallback for past recorded expenses
    return const ExpenseStatusInfo(
      status: ExpensePaymentStatus.paymentSuccess,
      label: 'Payment Success',
      primaryColor: Color(0xFF059669),
      backgroundColor: Color(0xFFECFDF5),
      borderColor: Color(0xFFA7F3D0),
      icon: Icons.check_circle_rounded,
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

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'perPage': perPage,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
    };
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
    dynamic data = json['data'] ?? json['expenses'] ?? json['entries'];
    List<ExpenseEntry> expList = [];
    ExpensePagination pag = const ExpensePagination();

    if (data is Map<String, dynamic>) {
      final rawList = data['expenses'] ?? data['entries'] ?? data['items'];
      if (rawList is List) {
        expList = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => ExpenseEntry.fromJson(e))
            .toList();
      }
      if (data['pagination'] is Map<String, dynamic>) {
        pag = ExpensePagination.fromJson(
          data['pagination'] as Map<String, dynamic>,
        );
      }
    } else if (data is List) {
      expList = data
          .whereType<Map<String, dynamic>>()
          .map((e) => ExpenseEntry.fromJson(e))
          .toList();
    }
    if (json['pagination'] is Map<String, dynamic>) {
      pag = ExpensePagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      );
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
      cashRunwayMonths: (json['cashRunwayMonths'] as num?)?.toDouble() ?? 0.0,
      recurringExpenses: (json['recurringExpenses'] as num?)?.toDouble() ?? 0.0,
      discretionaryExpenses:
          (json['discretionaryExpenses'] as num?)?.toDouble() ?? 0.0,
      priorityBreakdown: priMap,
      needsRatio: (json['needsRatio'] as num?)?.toDouble() ?? 0.0,
      wantsRatio: (json['wantsRatio'] as num?)?.toDouble() ?? 0.0,
      expenseHealthScore:
          (json['expenseHealthScore'] as num?)?.toDouble() ?? 75.0,
      healthScoreRating:
          json['healthScoreRating']?.toString() ?? 'Good Financial Health',
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
  final String? rawSms;
  final String? referenceId;
  final String? status;

  const DetectedExpense({
    required this.detectionId,
    required this.description,
    required this.suggestedCategory,
    required this.suggestedPriority,
    required this.amount,
    required this.date,
    this.paymentMode = 'UPI',
    this.bankAccount = 'Other / Cash',
    this.merchant = '',
    this.isDebit = true,
    this.confidenceScore = 0.94,
    this.channel = 'SMS_ALERT',
    this.rawSms,
    this.referenceId,
    this.status = 'UNCONFIRMED',
  });

  factory DetectedExpense.fromJson(Map<String, dynamic> json) {
    double amt = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final raw = json['rawSms']?.toString();
    if (amt <= 0.0 && raw != null && raw.isNotEmpty) {
      final match = RegExp(
        r'(?:Rs\.?|INR)\s*[:.]?\s*([\d,]+\.?\d*)',
        caseSensitive: false,
      ).firstMatch(raw);
      if (match != null) {
        final clean = match.group(1)!.replaceAll(',', '');
        amt = double.tryParse(clean) ?? amt;
      }
    }

    return DetectedExpense(
      detectionId: (json['detectionId'] ?? json['id'])?.toString() ?? '',
      description:
          (json['description'] ?? json['merchant'])?.toString() ??
          'Detected Outflow',
      suggestedCategory:
          (json['suggestedCategory'] ?? json['category'])?.toString() ??
          'Other',
      suggestedPriority:
          (json['suggestedPriority'] ?? json['priority'])?.toString() ??
          'P1 - Survival',
      amount: amt,
      date: json['date']?.toString() ?? '',
      paymentMode: json['paymentMode']?.toString() ?? 'UPI',
      bankAccount:
          (json['bankAccount'] ?? json['paymentMode'] ?? json['bankName'])
              ?.toString() ??
          'Other / Cash',
      merchant: (json['merchant'] ?? json['description'])?.toString() ?? '',
      isDebit: json['isDebit'] as bool? ?? true,
      confidenceScore:
          ((json['confidenceScore'] ?? json['confidence']) as num?)
              ?.toDouble() ??
          0.9,
      channel: json['channel']?.toString() ?? 'SMS_ALERT',
      rawSms: raw,
      referenceId: json['referenceId']?.toString(),
      status: json['status']?.toString() ?? 'UNCONFIRMED',
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
      if (rawSms != null) 'rawSms': rawSms,
      if (referenceId != null) 'referenceId': referenceId,
      if (status != null) 'status': status,
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

  double get monthlyAverage => summaryData?.monthlyAverage ?? totalExpenses;

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
    return (((monthlyInflow - totalExpenses) / monthlyInflow) * 100).clamp(
      -100.0,
      100.0,
    );
  }

  double get cashRunwayMonths {
    if (summaryData != null) return summaryData!.cashRunwayMonths;
    if (totalExpenses <= 0) return 12.0;
    return (300000.0 / totalExpenses).clamp(1.0, 24.0);
  }

  double get survivalP1Total {
    if (priorityBreakdown != null) return priorityBreakdown!.p1Survival;
    return expenses
        .where((e) => e.priority.startsWith('P1'))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get protectionP2Total {
    if (priorityBreakdown != null) return priorityBreakdown!.p2Protection;
    return expenses
        .where((e) => e.priority.startsWith('P2'))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get obligationsP3Total {
    if (priorityBreakdown != null) return priorityBreakdown!.p3Obligations;
    return expenses
        .where((e) => e.priority.startsWith('P3'))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get lifestyleP5Total {
    if (priorityBreakdown != null) {
      return priorityBreakdown!.p5Lifestyle + priorityBreakdown!.p6Luxury;
    }
    return expenses
        .where(
          (e) => e.priority.startsWith('P5') || e.priority.startsWith('P6'),
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get needsRatio {
    if (summaryData != null) return summaryData!.needsRatio;
    if (totalExpenses <= 0) return 0.0;
    return (((survivalP1Total + protectionP2Total + obligationsP3Total) /
                totalExpenses) *
            100)
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
      selectedCategoryFilter:
          selectedCategoryFilter ?? this.selectedCategoryFilter,
      selectedPriorityFilter:
          selectedPriorityFilter ?? this.selectedPriorityFilter,
      selectedBankAccountFilter:
          selectedBankAccountFilter ?? this.selectedBankAccountFilter,
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
      particularsTitle:
          json['particularsTitle']?.toString() ?? 'EXPENSE OUTFLOW DETAILS',
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
