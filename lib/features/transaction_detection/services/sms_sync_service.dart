import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/feature_flags.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/phone_utils.dart';
import '../../auth_kyc/providers/auth_kyc_provider.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
import '../../expense_tracking/domain/expense_models.dart';
import '../../expense_tracking/providers/expense_provider.dart';
import '../../income_tracking/domain/income_models.dart';
import '../../income_tracking/providers/income_provider.dart';
import '../../notifications/domain/notification_models.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../notifications/services/notification_api_service.dart';

class SmsSyncResultSummary {
  final int totalScanned;
  final int financialDetected;
  final int newlyIngested;
  final int alreadyIngested;
  final int failed;
  final List<String> detectedIds;

  const SmsSyncResultSummary({
    this.totalScanned = 0,
    this.financialDetected = 0,
    this.newlyIngested = 0,
    this.alreadyIngested = 0,
    this.failed = 0,
    this.detectedIds = const [],
  });

  Map<String, dynamic> toJson() => {
        'totalScanned': totalScanned,
        'financialDetected': financialDetected,
        'newlyIngested': newlyIngested,
        'alreadyIngested': alreadyIngested,
        'failed': failed,
        'detectedIds': detectedIds,
      };
}

class SmsSyncService {
  static final SmsSyncService _instance = SmsSyncService._internal();
  factory SmsSyncService() => _instance;
  SmsSyncService._internal();

  static const MethodChannel _smsChannel = MethodChannel('com.finomos/sms');

  /// Known Indian Bank & Financial Service Sender ID Patterns (e.g. VK-HDFCBK, AD-SBIINB)
  static final RegExp _bankSenderPattern = RegExp(
    r'(HDFC|SBI|ICICI|AXIS|KOTAK|PNB|BOB|CANARA|INDUS|UNION|YESBK|IDFC|FED|RBL|CITI|HSBC|PAYTM|GPAY|PHONEPE|CRED|SLICE|JUPITER|FI)',
    caseSensitive: false,
  );

  /// Financial keywords typically found in transaction SMS
  static final List<String> _financialKeywords = [
    'debited',
    'debit',
    'credited',
    'credit',
    'withdrawn',
    'spent',
    'transfer',
    'transferred',
    'upi',
    'a/c',
    'acct',
    'inr',
    'rs.',
    'rs ',
    'fixed deposit',
    'fd',
    'avl bal',
    'bal:',
    'balance',
    'ref no',
    'ref ',
    'payment',
    'paid',
    'received',
    'refund',
    'txn',
  ];

  /// Check whether runtime SMS permission is granted on Android
  Future<bool> hasPermission() async {
    // HIDE FOR GOOGLE PLAY POLICY COMPLIANCE:
    // If SMS permissions are disabled, return false immediately to prevent any policy-sensitive checks.
    if (!AppFeatureFlags.enableSmsPermissions) {
      return false;
    }
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      final bool? granted = await _smsChannel.invokeMethod<bool>('hasSmsPermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request runtime SMS permission on Android
  Future<bool> requestPermission() async {
    // HIDE FOR GOOGLE PLAY POLICY COMPLIANCE:
    // Return false without attempting native SMS permission request.
    if (!AppFeatureFlags.enableSmsPermissions) {
      return false;
    }
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      final bool? granted = await _smsChannel.invokeMethod<bool>('requestSmsPermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Read device SMS from Android native inbox
  Future<List<Map<String, dynamic>>> readDeviceSmsInbox({int limit = 60}) async {
    if (!AppFeatureFlags.enableSmsPermissions) {
      return [];
    }
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return [];
    }
    try {
      final List<dynamic>? rawMessages = await _smsChannel.invokeMethod<List<dynamic>>(
        'readInboxSms',
        {'limit': limit},
      );
      if (rawMessages == null) return [];

      return rawMessages
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    } catch (e) {
      debugPrint('[SmsSyncService] Error reading SMS inbox: $e');
      return [];
    }
  }

  /// Determines if an SMS is from a financial institution
  bool isFinancialSms(String sender, String body) {
    final senderUpper = sender.toUpperCase();
    final bodyLower = body.toLowerCase();

    // Check sender header pattern
    final bool matchesSender = _bankSenderPattern.hasMatch(senderUpper);

    // Check body transaction keywords
    final int keywordMatches = _financialKeywords.where((kw) => bodyLower.contains(kw)).length;

    // Direct transaction action indicators
    final bool hasStrongAction = bodyLower.contains('debit') ||
        bodyLower.contains('credit') ||
        bodyLower.contains('withdrawn') ||
        bodyLower.contains('spent') ||
        bodyLower.contains('transferred') ||
        bodyLower.contains('paid') ||
        bodyLower.contains('received') ||
        bodyLower.contains('refund') ||
        bodyLower.contains('deposit');

    return matchesSender || hasStrongAction || keywordMatches >= 1;
  }

  /// Generate a unique signature for an SMS to avoid redundant network ingestion
  String _generateSmsSignature(String sender, String body) {
    // Clean whitespace and digits
    final normalized = '${sender.trim().toUpperCase()}_${body.replaceAll(RegExp(r'\s+'), ' ').trim()}';
    return base64Url.encode(utf8.encode(normalized));
  }

  /// Sync device SMS inbox:
  /// 1. Reads incoming & inbox SMS from Android Messages app.
  /// 2. Filters financial SMS.
  /// 3. Ingests each into POST /api/v1/notifications/sms/ingest.
  /// 4. Updates NotificationProvider (badge on dashboard bell icon).
  /// 5. Populates Shortbox in Income or Expense tracking screen for user Approval.
  Future<SmsSyncResultSummary> syncDeviceSms({
    required WidgetRef ref,
    String? userMobile,
    int scanLimit = 60,
  }) async {
    int totalScanned = 0;
    int financialDetected = 0;
    int newlyIngested = 0;
    int alreadyIngestedCount = 0;
    int failedCount = 0;
    final List<String> detectedIds = [];

    // HIDE FOR GOOGLE PLAY POLICY COMPLIANCE:
    // If SMS permissions are disabled, return gracefully without triggering permission dialogs
    if (!AppFeatureFlags.enableSmsPermissions) {
      debugPrint('[SmsSyncService] SMS permissions hidden for Google Play compliance.');
      return const SmsSyncResultSummary();
    }

    // Ensure permission
    bool permitted = await hasPermission();
    if (!permitted) {
      permitted = await requestPermission();
      if (!permitted) {
        debugPrint('[SmsSyncService] SMS permission not granted by user.');
        return const SmsSyncResultSummary();
      }
    }

    final rawMessages = await readDeviceSmsInbox(limit: scanLimit);
    totalScanned = rawMessages.length;

    final cachedSignaturesRaw = LocalCacheService().get('ingested_sms_signatures');
    final Set<String> ingestedSignatures = cachedSignaturesRaw is List
        ? cachedSignaturesRaw.cast<String>().toSet()
        : <String>{};

    final notificationsNotifier = ref.read(notificationsProvider.notifier);
    final String candidateMobile = (userMobile != null && userMobile.trim().isNotEmpty)
        ? userMobile.trim()
        : (ref.read(authKycProvider).user.mobileNumber.isNotEmpty
            ? ref.read(authKycProvider).user.mobileNumber
            : ((LocalCacheService().get('auth_session') as Map?)?['phone']?.toString() ??
               LocalCacheService().get('user_mobile_number')?.toString() ?? ''));

    final effectiveUserMobile = PhoneUtils.sanitize(candidateMobile);
    if (effectiveUserMobile.isNotEmpty) {
      LocalCacheService().save('user_mobile_number', effectiveUserMobile);
    }

    final linkedAccounts = ref.read(bankAggregationProvider).bankAccounts;
    final defaultPrimaryBank = linkedAccounts.isNotEmpty ? linkedAccounts.first.bankName : 'Bank Account';
    final defaultPrimaryDigits = linkedAccounts.isNotEmpty
        ? '••••${linkedAccounts.first.maskedAccountNumber.replaceAll(RegExp(r'[^0-9]'), '')}'
        : '';
    final defaultExpenseBank = linkedAccounts.isNotEmpty ? linkedAccounts.first.bankName : 'Bank Account';
    final defaultExpenseDigits = linkedAccounts.isNotEmpty
        ? '••••${linkedAccounts.first.maskedAccountNumber.replaceAll(RegExp(r'[^0-9]'), '')}'
        : '';

    // Step 1: Filter and prepare financial messages
    final List<Map<String, dynamic>> newFinancialMessages = [];
    final Map<String, Map<String, dynamic>> signatureToMsg = {};

    for (final msg in rawMessages) {
      final sender = msg['sender']?.toString() ?? '';
      final body = msg['body']?.toString() ?? '';

      if (sender.isEmpty || body.isEmpty) continue;
      if (!isFinancialSms(sender, body)) continue;

      financialDetected++;

      final signature = _generateSmsSignature(sender, body);
      if (ingestedSignatures.contains(signature)) {
        alreadyIngestedCount++;
        continue;
      }

      newFinancialMessages.add({
        'sender': sender,
        'body': body,
        'timestamp': msg['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      });
      signatureToMsg[signature] = msg;
    }

    // Step 2: Pre-deduplicate messages within the batch by (normalizedSender, amount, accountDigits)
    // to prevent server-side Prisma dedupHash collision in batch-sync
    final Map<String, Map<String, dynamic>> dedupedBatchMap = {};
    for (final item in newFinancialMessages) {
      final s = item['sender']?.toString() ?? '';
      final b = item['body']?.toString() ?? '';
      final senderBase = s.replaceAll(RegExp(r'^[A-Z]{2}-'), '').replaceAll(RegExp(r'-[A-Z]$'), '').toUpperCase();
      final amtMatch = RegExp(r'(?:rs\.?|inr)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false).firstMatch(b);
      final amt = amtMatch?.group(1)?.replaceAll(',', '') ?? '';
      final accMatch = RegExp(r'(?:a\/c|acct|ac)\s*[\*•\s]*(\d{3,6})', caseSensitive: false).firstMatch(b);
      final acc = accMatch?.group(1) ?? '';

      final key = (amt.isNotEmpty || acc.isNotEmpty)
          ? '$senderBase|$amt|$acc'
          : '$senderBase|${b.replaceAll(RegExp(r'\d+'), '#').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase()}';
      dedupedBatchMap[key] = item;
    }
    final List<Map<String, dynamic>> dedupedBatchMessages = dedupedBatchMap.values.toList();

    // Attempt batch sync via POST /api/v1/notifications/sms/batch-sync
    bool batchSuccess = false;
    if (dedupedBatchMessages.isNotEmpty && effectiveUserMobile.isNotEmpty) {
      try {
        final batchResult = await NotificationApiService().batchSyncSms(
          userMobile: effectiveUserMobile,
          messages: dedupedBatchMessages,
          syncMode: 'HISTORICAL',
        );

        if (batchResult != null && batchResult.success) {
          batchSuccess = true;
          newlyIngested = batchResult.summary.ingested;
          alreadyIngestedCount += batchResult.summary.duplicatesSkipped;

          for (final sig in signatureToMsg.keys) {
            ingestedSignatures.add(sig);
          }

          for (final item in batchResult.data) {
            if (item.notificationId != null) {
              detectedIds.add(item.notificationId!);
            }
            final entities = item.entities ?? {};
            final classification = (item.classification ?? '').toLowerCase();
            final redirection = item.redirection;

            if (classification == 'credit' || redirection?.route == '/income') {
              final inflow = DetectedInflow(
                detectedId: redirection?.targetId ??
                    (entities['referenceId'] != null ? 'inf_${entities['referenceId']}' : 'sms_inf_${item.notificationId}'),
                detectedSource: entities['merchantOrSource']?.toString() ?? 'Credit Inflow',
                suggestedCategory: entities['suggestedCategory']?.toString() ?? 'Salary',
                amount: (entities['amount'] as num?)?.toDouble() ?? 0.0,
                date: entities['date']?.toString() ?? 'Today',
                bankAccount: '${entities['bankName'] ?? defaultPrimaryBank} ${entities['accountDigits'] ?? defaultPrimaryDigits}',
                confidenceScore: 0.98,
                detectionChannel: 'SMS Alert',
                rawSms: '',
                referenceId: entities['referenceId']?.toString(),
              );
              ref.read(incomeProvider.notifier).addDetectedInflow(inflow);
            } else if (classification == 'debit' || redirection?.route == '/expenses') {
              final expense = DetectedExpense(
                detectionId: redirection?.targetId ??
                    (entities['referenceId'] != null ? 'deb_${entities['referenceId']}' : 'sms_exp_${item.notificationId}'),
                description: entities['merchantOrSource']?.toString() ?? 'Debit Outflow',
                suggestedCategory: entities['suggestedCategory']?.toString() ?? 'Food & Dining',
                suggestedPriority: entities['suggestedPriority']?.toString() ?? 'P4 - Discretionary',
                amount: (entities['amount'] as num?)?.toDouble() ?? 0.0,
                date: entities['date']?.toString() ?? 'Today',
                paymentMode: 'UPI',
                bankAccount: '${entities['bankName'] ?? defaultExpenseBank} ${entities['accountDigits'] ?? defaultExpenseDigits}',
                merchant: entities['merchantOrSource']?.toString() ?? 'Merchant',
                isDebit: true,
                confidenceScore: 0.98,
                channel: 'SMS Alert',
                rawSms: '',
                referenceId: entities['referenceId']?.toString(),
              );
              ref.read(expenseProvider.notifier).addDetectedExpense(expense);
            } else if (classification == 'fixed deposit' || redirection?.route == '/bank-aggregation') {
              ref.read(bankAggregationProvider.notifier).loadInitialData();
            }
          }

          if (batchResult.summary.creditsCount > 0) {
            ref.read(incomeProvider.notifier).loadLiveIncomeData();
          }
          if (batchResult.summary.debitsCount > 0) {
            ref.read(expenseProvider.notifier).loadLiveExpenses();
          }
          await notificationsNotifier.loadLiveNotifications(userMobile: effectiveUserMobile);
        }
      } catch (e) {
        debugPrint('[SmsSyncService] Batch sync error, falling back to sequential: $e');
      }
    }

    // Step 3: Sequential fallback / single message ingestion
    if (!batchSuccess) {
      for (final entry in signatureToMsg.entries) {
        final signature = entry.key;
        final msg = entry.value;
        final sender = msg['sender']?.toString() ?? '';
        final body = msg['body']?.toString() ?? '';

        try {
          final AppNotification? ingested = await notificationsNotifier.ingestSms(
            sender: sender,
            body: body,
            userMobile: effectiveUserMobile,
          );

          if (ingested != null) {
            newlyIngested++;
            ingestedSignatures.add(signature);
            detectedIds.add(ingested.id);

            double extractAmt(String text) {
              final match = RegExp(r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false).firstMatch(text);
              if (match != null) {
                return double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0.0;
              }
              return 0.0;
            }

            // Route to Income / Expense / Bank Aggregation reactively
            if (ingested.isCreditSms) {
              final inflow = DetectedInflow(
                detectedId: ingested.redirection?.targetId ??
                    (ingested.referenceId != null ? 'inf_${ingested.referenceId}' : 'sms_inf_${ingested.id}'),
                detectedSource: ingested.merchantOrSource ?? ingested.title,
                suggestedCategory: ingested.metadata?['suggestedCategory']?.toString() ??
                    (ingested.category != null && ingested.category != 'Credit' ? ingested.category! : 'Salary'),
                amount: ingested.amount ?? extractAmt(body),
                date: ingested.metadata?['date']?.toString() ?? 'Today',
                bankAccount: '${ingested.bankName ?? defaultPrimaryBank} ${ingested.accountDigits ?? defaultPrimaryDigits}',
                confidenceScore: 0.98,
                detectionChannel: 'SMS Alert',
                rawSms: ingested.rawSms ?? body,
                referenceId: ingested.referenceId,
              );
              ref.read(incomeProvider.notifier).addDetectedInflow(inflow);
              ref.read(incomeProvider.notifier).loadLiveIncomeData();
            } else if (ingested.isDebitSms) {
              final expense = DetectedExpense(
                detectionId: ingested.redirection?.targetId ??
                    (ingested.referenceId != null ? 'deb_${ingested.referenceId}' : 'sms_exp_${ingested.id}'),
                description: ingested.merchantOrSource ?? ingested.title,
                suggestedCategory: ingested.metadata?['suggestedCategory']?.toString() ?? 'Food & Dining',
                suggestedPriority: ingested.metadata?['suggestedPriority']?.toString() ?? 'P4 - Discretionary',
                amount: ingested.amount ?? extractAmt(body),
                date: ingested.metadata?['date']?.toString() ?? 'Today',
                paymentMode: 'UPI',
                bankAccount: '${ingested.bankName ?? defaultExpenseBank} ${ingested.accountDigits ?? defaultExpenseDigits}',
                merchant: ingested.merchantOrSource ?? 'Merchant',
                isDebit: true,
                confidenceScore: 0.98,
                channel: 'SMS Alert',
                rawSms: ingested.rawSms ?? body,
                referenceId: ingested.referenceId,
              );
              ref.read(expenseProvider.notifier).addDetectedExpense(expense);
              ref.read(expenseProvider.notifier).loadLiveExpenses();
            } else if (ingested.isFixedDepositSms ||
                ingested.classification?.toLowerCase() == 'fixed deposit' ||
                ingested.redirection?.route == '/bank-aggregation') {
              ref.read(bankAggregationProvider.notifier).loadInitialData();
            }
          } else {
            failedCount++;
          }
        } catch (e) {
          debugPrint('[SmsSyncService] Error ingesting SMS ($sender): $e');
          failedCount++;
        }
      }
    }

    // Persist updated signatures
    LocalCacheService().save('ingested_sms_signatures', ingestedSignatures.toList());

    // Refresh notifications from backend to reflect live synced SMS
    await notificationsNotifier.loadLiveNotifications(userMobile: effectiveUserMobile);

    return SmsSyncResultSummary(
      totalScanned: totalScanned,
      financialDetected: financialDetected,
      newlyIngested: newlyIngested,
      alreadyIngested: alreadyIngestedCount,
      failed: failedCount,
      detectedIds: detectedIds,
    );
  }
}

