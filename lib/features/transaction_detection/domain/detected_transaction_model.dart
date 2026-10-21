enum TransactionClassification {
  expense,
  income,
  transfer,
  refund,
  other,
  reviewRequired,
}

enum DetectedTransactionStatus {
  pendingReview,
  confirmed,
  dismissed,
}

enum DetectionSource {
  sms,
  manualEntry,
  importBatch,
  bankIntegration,
}

class DetectedTransaction {
  final String id;
  final String userId;
  final String rawSmsBody;
  final String sender;
  final DateTime timestamp;
  final TransactionClassification type;
  final double amount;
  final String currency;
  final String bankName;
  final String accountIdentifier; // e.g. "••••4587" or "XXXXXX4821"
  final String? referenceId; // e.g. UPI Ref / UTR / Txn ID
  final String? merchantOrSource; // e.g. "Swiggy", "Restaurant", "Tech Corp Salary"
  final String paymentMethod; // UPI, Debit Card, Credit Card, Net Banking, Bank Transfer, Cash, Other
  final String suggestedCategory;
  final String description;
  final String notes;
  final String? documentName;
  final String? documentPath;
  final DetectionSource source;
  final DetectedTransactionStatus status;
  final double confidenceScore;
  final String duplicateFingerprint;
  final String? confirmedRecordId; // ID of saved ExpenseEntry or IncomeEntry
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DetectedTransaction({
    required this.id,
    this.userId = 'user_001',
    required this.rawSmsBody,
    this.sender = 'BANK-ALERT',
    required this.timestamp,
    required this.type,
    required this.amount,
    this.currency = '₹',
    required this.bankName,
    required this.accountIdentifier,
    this.referenceId,
    this.merchantOrSource,
    this.paymentMethod = 'UPI',
    this.suggestedCategory = 'Food & Dining',
    this.description = '',
    this.notes = '',
    this.documentName,
    this.documentPath,
    this.source = DetectionSource.sms,
    this.status = DetectedTransactionStatus.pendingReview,
    this.confidenceScore = 0.90,
    required this.duplicateFingerprint,
    this.confirmedRecordId,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isDebit =>
      type == TransactionClassification.expense ||
      (type == TransactionClassification.reviewRequired &&
          (rawSmsBody.toLowerCase().contains('debit') ||
              rawSmsBody.toLowerCase().contains('spent') ||
              rawSmsBody.toLowerCase().contains('paid') ||
              rawSmsBody.toLowerCase().contains('withdrawn')));

  bool get isCredit =>
      type == TransactionClassification.income ||
      (type == TransactionClassification.reviewRequired &&
          (rawSmsBody.toLowerCase().contains('credit') ||
              rawSmsBody.toLowerCase().contains('deposited') ||
              rawSmsBody.toLowerCase().contains('received')));

  String get typeDisplayString {
    switch (type) {
      case TransactionClassification.expense:
        return 'Expense';
      case TransactionClassification.income:
        return 'Income';
      case TransactionClassification.transfer:
        return 'Transfer';
      case TransactionClassification.refund:
        return 'Refund';
      case TransactionClassification.other:
        return 'Other';
      case TransactionClassification.reviewRequired:
        return 'Review Required';
    }
  }

  DetectedTransaction copyWith({
    String? id,
    String? userId,
    String? rawSmsBody,
    String? sender,
    DateTime? timestamp,
    TransactionClassification? type,
    double? amount,
    String? currency,
    String? bankName,
    String? accountIdentifier,
    String? referenceId,
    String? merchantOrSource,
    String? paymentMethod,
    String? suggestedCategory,
    String? description,
    String? notes,
    String? documentName,
    String? documentPath,
    DetectionSource? source,
    DetectedTransactionStatus? status,
    double? confidenceScore,
    String? duplicateFingerprint,
    String? confirmedRecordId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DetectedTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rawSmsBody: rawSmsBody ?? this.rawSmsBody,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      accountIdentifier: accountIdentifier ?? this.accountIdentifier,
      referenceId: referenceId ?? this.referenceId,
      merchantOrSource: merchantOrSource ?? this.merchantOrSource,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      documentName: documentName ?? this.documentName,
      documentPath: documentPath ?? this.documentPath,
      source: source ?? this.source,
      status: status ?? this.status,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      duplicateFingerprint: duplicateFingerprint ?? this.duplicateFingerprint,
      confirmedRecordId: confirmedRecordId ?? this.confirmedRecordId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
