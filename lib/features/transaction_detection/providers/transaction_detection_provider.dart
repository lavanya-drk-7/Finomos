import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/detected_transaction_model.dart';
import '../domain/sms_parser_engine.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../notifications/domain/notification_models.dart';
import '../../expense_tracking/providers/expense_provider.dart';
import '../../expense_tracking/domain/expense_models.dart';
import '../../income_tracking/providers/income_provider.dart';
import '../../income_tracking/domain/income_models.dart';
import '../../budget_management/providers/budget_provider.dart';
import '../../budget_management/domain/budget_models.dart';

class TransactionDetectionState {
  final List<DetectedTransaction> detectedTransactions;
  final bool autoDetectionEnabled;
  final bool isPermissionGranted;
  final DetectedTransaction? latestAlertTransaction;
  final String? lastError;

  const TransactionDetectionState({
    required this.detectedTransactions,
    this.autoDetectionEnabled = true,
    this.isPermissionGranted = true,
    this.latestAlertTransaction,
    this.lastError,
  });

  List<DetectedTransaction> get pendingTransactions =>
      detectedTransactions.where((t) => t.status == DetectedTransactionStatus.pendingReview).toList();

  int get pendingCount => pendingTransactions.length;

  TransactionDetectionState copyWith({
    List<DetectedTransaction>? detectedTransactions,
    bool? autoDetectionEnabled,
    bool? isPermissionGranted,
    DetectedTransaction? latestAlertTransaction,
    bool clearAlert = false,
    String? lastError,
  }) {
    return TransactionDetectionState(
      detectedTransactions: detectedTransactions ?? this.detectedTransactions,
      autoDetectionEnabled: autoDetectionEnabled ?? this.autoDetectionEnabled,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      latestAlertTransaction: clearAlert ? null : (latestAlertTransaction ?? this.latestAlertTransaction),
      lastError: lastError,
    );
  }
}

class TransactionDetectionNotifier extends Notifier<TransactionDetectionState> {
  @override
  TransactionDetectionState build() {
    return TransactionDetectionState(
      detectedTransactions: [
        DetectedTransaction(
          id: 'txn_init_1',
          rawSmsBody:
              'Rs. 1,000 debited from your HDFC Bank account ••••4587 at TOIT RESTAURANT on 15 Oct 2026. UPI/429182391024',
          sender: 'VK-HDFCBK',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          type: TransactionClassification.expense,
          amount: 1000.0,
          currency: '₹',
          bankName: 'HDFC Bank',
          accountIdentifier: '••••4587',
          referenceId: 'UPI/429182391024',
          merchantOrSource: 'TOIT RESTAURANT',
          paymentMethod: 'UPI',
          suggestedCategory: 'Food & Dining',
          description: 'TOIT RESTAURANT payment via HDFC Bank',
          source: DetectionSource.sms,
          status: DetectedTransactionStatus.pendingReview,
          confidenceScore: 0.95,
          duplicateFingerprint: 'hdfc_1000.00_expense_upi/429182391024',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
      autoDetectionEnabled: true,
      isPermissionGranted: true,
    );
  }

  void toggleAutoDetection(bool enabled) {
    state = state.copyWith(autoDetectionEnabled: enabled);
  }

  void updatePermissionStatus(bool granted) {
    state = state.copyWith(isPermissionGranted: granted);
  }

  void dismissAlertBanner() {
    state = state.copyWith(clearAlert: true);
  }

  /// Ingests and processes a bank SMS message.
  /// Validates, checks for duplicates, extracts details, and notifies.
  ParseResult processIncomingSms(
    String rawSms, {
    String sender = 'BANK-ALERT',
  }) {
    final parseResult = SmsParserEngine.parse(rawSms, sender: sender);

    if (!parseResult.isSuccess || parseResult.transaction == null) {
      state = state.copyWith(lastError: parseResult.errorMessage ?? 'Parsing failed');
      return parseResult;
    }

    final newTxn = parseResult.transaction!;

    // 1. Deduplication Check
    final isDuplicate = state.detectedTransactions.any(
      (t) =>
          t.duplicateFingerprint == newTxn.duplicateFingerprint ||
          (t.referenceId != null &&
              newTxn.referenceId != null &&
              t.referenceId == newTxn.referenceId),
    );

    if (isDuplicate) {
      return ParseResult(
        isSuccess: false,
        errorMessage: 'Duplicate transaction detected: Reference ${newTxn.referenceId ?? "matching details"} already processed.',
      );
    }

    // 2. Add to Detected Transactions
    state = state.copyWith(
      detectedTransactions: [newTxn, ...state.detectedTransactions],
      latestAlertTransaction: newTxn,
      lastError: null,
    );

    // 3. Dispatch In-App Notification
    final notifTitle = newTxn.isDebit ? 'Expense detected' : 'Income detected';
    final notifMsg =
        '₹${newTxn.amount.toStringAsFixed(0)} ${newTxn.isDebit ? "debited from" : "credited to"} your ${newTxn.bankName} account.';

    ref.read(notificationsProvider.notifier).state = ref.read(notificationsProvider).copyWith(
      notifications: [
        AppNotification(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          title: notifTitle,
          message: '$notifMsg Action: Review Transaction',
          type: 'Payment',
          priority: 'High',
          timestamp: 'Just now',
          isRead: false,
        ),
        ...ref.read(notificationsProvider).notifications,
      ],
    );

    return ParseResult(isSuccess: true, transaction: newTxn);
  }

  /// Confirms transaction as Expense and synchronizes with Expense History & Budget Management.
  void confirmAsExpense({
    required String transactionId,
    required double amount,
    required String category,
    required String bankAccount,
    required String paymentMode,
    required String merchant,
    required String description,
    required String notes,
    required String date,
    String? documentName,
    String? documentPath,
  }) {
    // 1. Add to Expense History
    final newExpenseId = 'exp_${DateTime.now().millisecondsSinceEpoch}';
    final expenseEntry = ExpenseEntry(
      id: newExpenseId,
      description: description.isNotEmpty ? description : '$merchant expense',
      category: category,
      amount: amount,
      date: date,
      paymentMode: paymentMode,
      merchant: merchant,
      notes: notes,
      bankAccount: bankAccount,
      documentName: documentName,
      documentPath: documentPath,
    );
    ref.read(expenseProvider.notifier).addExpense(expenseEntry);

    // 2. Synchronize with Budget Management
    final budgetAlert = ref.read(budgetProvider.notifier).applyExpense(
          category: category,
          amount: amount,
          description: description,
        );

    // 3. If budget alert triggered, push notification
    if (budgetAlert != null) {
      ref.read(notificationsProvider.notifier).state = ref.read(notificationsProvider).copyWith(
        notifications: [
          AppNotification(
            id: 'notif_budget_${DateTime.now().millisecondsSinceEpoch}',
            title: budgetAlert.title,
            message: budgetAlert.message,
            type: 'Budget',
            priority: budgetAlert.level == BudgetAlertLevel.exceeded ? 'High' : 'Medium',
            timestamp: 'Just now',
            isRead: false,
          ),
          ...ref.read(notificationsProvider).notifications,
        ],
      );
    }

    // 4. Mark Detected Transaction as Confirmed
    _markStatus(transactionId, DetectedTransactionStatus.confirmed, newExpenseId);
  }

  /// Confirms transaction as Income and synchronizes with Income History.
  void confirmAsIncome({
    required String transactionId,
    required double amount,
    required String category,
    required String bankAccount,
    required String source,
    required String notes,
    required String date,
    String? documentName,
    String? documentPath,
  }) {
    // 1. Add to Income History
    final newIncomeId = 'inc_${DateTime.now().millisecondsSinceEpoch}';
    final incomeEntry = IncomeEntry(
      id: newIncomeId,
      source: source.isNotEmpty ? source : 'Credit Transaction',
      category: category,
      amount: amount,
      date: date,
      frequency: 'Monthly',
      notes: notes,
      bankAccount: bankAccount,
      documentName: documentName,
      documentPath: documentPath,
    );
    ref.read(incomeProvider.notifier).addIncome(incomeEntry);

    // 2. Mark Detected Transaction as Confirmed
    _markStatus(transactionId, DetectedTransactionStatus.confirmed, newIncomeId);
  }

  /// Marks a transaction as Dismissed.
  void dismissTransaction(String transactionId) {
    _markStatus(transactionId, DetectedTransactionStatus.dismissed, null);
  }

  void _markStatus(String transactionId, DetectedTransactionStatus status, String? recordId) {
    final updated = state.detectedTransactions.map((t) {
      if (t.id == transactionId) {
        return t.copyWith(
          status: status,
          confirmedRecordId: recordId,
          updatedAt: DateTime.now(),
        );
      }
      return t;
    }).toList();

    state = state.copyWith(
      detectedTransactions: updated,
      clearAlert: state.latestAlertTransaction?.id == transactionId,
    );
  }

  /// Test preset simulation for instant demo and automated scenarios.
  ParseResult simulatePreset(String presetKey) {
    switch (presetKey) {
      case 'hdfc_1000_food':
        return processIncomingSms(
          'Rs. 1,000 debited from your HDFC Bank account ••••4587 on 15 Oct 2026 to VPA restaurant@upi. Ref 429182391024',
          sender: 'VK-HDFCBK',
        );
      case 'sbi_30000_salary':
        return processIncomingSms(
          'Rs. 30,000 credited to your SBI Bank account ••••4821 on 15/10/26 by transfer from TECH CORP SALARY. Ref 392817263518',
          sender: 'SBIINB',
        );
      case 'axis_2000_groceries':
        return processIncomingSms(
          'INR 2,000 spent on Axis Bank A/c 3301 at NATURE BASKET GROCERIES on 15-Oct-26. UPI/928192837192',
          sender: 'AXISBK',
        );
      case 'hdfc_11000_overspent':
        return processIncomingSms(
          'Rs. 11,000 debited from your HDFC Bank account ••••4587 to Food & Dining Restaurant Luxury Banquet. Ref 778291029381',
          sender: 'VK-HDFCBK',
        );
      case 'transfer_5000':
        return processIncomingSms(
          'Rs 5,000 transferred between your accounts from HDFC Bank 4587 to SBI 4821. Ref 882918239102',
          sender: 'HDFCBK',
        );
      case 'refund_1500':
        return processIncomingSms(
          'Rs. 1,500 refund credited to your HDFC Bank account ••••4587 from Amazon India. Ref 991827361829',
          sender: 'VK-HDFCBK',
        );
      default:
        return processIncomingSms(
          'Rs. 1,000 debited from your HDFC Bank account.',
          sender: 'HDFCBK',
        );
    }
  }
}

final transactionDetectionProvider =
    NotifierProvider<TransactionDetectionNotifier, TransactionDetectionState>(() {
  return TransactionDetectionNotifier();
});
