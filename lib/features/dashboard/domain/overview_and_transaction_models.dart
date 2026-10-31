class UnifiedTransactionItem {
  final String id;
  final String txnId;
  final String date;
  final String bankName;
  final String? accountNumber;
  final String? accountId;
  final String? cardType;
  final String? maskedCardNumber;
  final String paymentMethod;
  final String type; // 'Income' or 'Expense'
  final String category;
  final String description;
  final double amount;
  final double? balanceAfter;
  final double? remainingBalanceOrCredit;
  final String transactionStatus;
  final String? cardId;
  final bool isAggregated;
  final String sourceType; // 'INCOME', 'EXPENSE'
  final bool isNegative;
  final String? createdAt;

  const UnifiedTransactionItem({
    required this.id,
    required this.txnId,
    required this.date,
    required this.bankName,
    this.accountNumber,
    this.accountId,
    this.cardType,
    this.maskedCardNumber,
    required this.paymentMethod,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    this.balanceAfter,
    this.remainingBalanceOrCredit,
    this.transactionStatus = 'Completed',
    this.cardId,
    this.isAggregated = false,
    this.sourceType = 'EXPENSE',
    this.isNegative = true,
    this.createdAt,
  });

  bool get isIncome => type.toLowerCase() == 'income' || !isNegative;
  bool get isExpense => type.toLowerCase() == 'expense' || isNegative;

  factory UnifiedTransactionItem.fromJson(Map<String, dynamic> json) {
    return UnifiedTransactionItem(
      id: json['id']?.toString() ?? '',
      txnId: json['txnId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      accountNumber: json['accountNumber'] as String?,
      accountId: json['accountId'] as String?,
      cardType: json['cardType'] as String?,
      maskedCardNumber: json['maskedCardNumber'] as String?,
      paymentMethod: json['paymentMethod']?.toString() ?? 'UPI',
      type: json['type']?.toString() ?? 'Expense',
      category: json['category']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      remainingBalanceOrCredit: (json['remainingBalanceOrCredit'] as num?)?.toDouble(),
      transactionStatus: json['transactionStatus']?.toString() ?? 'Completed',
      cardId: json['cardId'] as String?,
      isAggregated: json['isAggregated'] as bool? ?? false,
      sourceType: json['sourceType']?.toString() ?? 'EXPENSE',
      isNegative: json['isNegative'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'txnId': txnId,
      'date': date,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountId': accountId,
      'cardType': cardType,
      'maskedCardNumber': maskedCardNumber,
      'paymentMethod': paymentMethod,
      'type': type,
      'category': category,
      'description': description,
      'amount': amount,
      'balanceAfter': balanceAfter,
      'remainingBalanceOrCredit': remainingBalanceOrCredit,
      'transactionStatus': transactionStatus,
      'cardId': cardId,
      'isAggregated': isAggregated,
      'sourceType': sourceType,
      'isNegative': isNegative,
      'createdAt': createdAt,
    };
  }
}

class OverviewAccount {
  final String id;
  final String name;
  final String accountNumber;
  final String accountType;
  final double bankBalance;
  final double internalBalance;
  final bool isAggregated;
  final String? logo;
  final String? color;
  final String status;

  const OverviewAccount({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.accountType,
    required this.bankBalance,
    required this.internalBalance,
    this.isAggregated = false,
    this.logo,
    this.color,
    this.status = 'ACTIVE',
  });

  factory OverviewAccount.fromJson(Map<String, dynamic> json) {
    return OverviewAccount(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      accountType: json['accountType']?.toString() ?? 'Savings Account',
      bankBalance: (json['bankBalance'] as num?)?.toDouble() ?? 0.0,
      internalBalance: (json['internalBalance'] as num?)?.toDouble() ?? 0.0,
      isAggregated: json['isAggregated'] as bool? ?? false,
      logo: json['logo'] as String?,
      color: json['color'] as String?,
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'bankBalance': bankBalance,
      'internalBalance': internalBalance,
      'isAggregated': isAggregated,
      'logo': logo,
      'color': color,
      'status': status,
    };
  }
}

class DashboardOverviewData {
  final double totalBalance;
  final double totalBankVerifiedBalance;
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;
  final double totalCreditLimit;
  final double totalCreditOutstanding;
  final double totalCreditAvailable;
  final int debitCardsCount;
  final int creditCardsCount;
  final List<OverviewAccount> accounts;

  const DashboardOverviewData({
    this.totalBalance = 0.0,
    this.totalBankVerifiedBalance = 0.0,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.totalSavings = 0.0,
    this.totalCreditLimit = 0.0,
    this.totalCreditOutstanding = 0.0,
    this.totalCreditAvailable = 0.0,
    this.debitCardsCount = 0,
    this.creditCardsCount = 0,
    this.accounts = const [],
  });

  factory DashboardOverviewData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final accountsList = (data['accounts'] as List?)
            ?.map((e) => OverviewAccount.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return DashboardOverviewData(
      totalBalance: (data['totalBalance'] as num?)?.toDouble() ?? 0.0,
      totalBankVerifiedBalance: (data['totalBankVerifiedBalance'] as num?)?.toDouble() ?? 0.0,
      totalIncome: (data['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (data['totalExpense'] as num?)?.toDouble() ?? 0.0,
      totalSavings: (data['totalSavings'] as num?)?.toDouble() ?? 0.0,
      totalCreditLimit: (data['totalCreditLimit'] as num?)?.toDouble() ?? 0.0,
      totalCreditOutstanding: (data['totalCreditOutstanding'] as num?)?.toDouble() ?? 0.0,
      totalCreditAvailable: (data['totalCreditAvailable'] as num?)?.toDouble() ?? 0.0,
      debitCardsCount: (data['debitCardsCount'] as num?)?.toInt() ?? 0,
      creditCardsCount: (data['creditCardsCount'] as num?)?.toInt() ?? 0,
      accounts: accountsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'totalBankVerifiedBalance': totalBankVerifiedBalance,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'totalSavings': totalSavings,
      'totalCreditLimit': totalCreditLimit,
      'totalCreditOutstanding': totalCreditOutstanding,
      'totalCreditAvailable': totalCreditAvailable,
      'debitCardsCount': debitCardsCount,
      'creditCardsCount': creditCardsCount,
      'accounts': accounts.map((a) => a.toJson()).toList(),
    };
  }
}

