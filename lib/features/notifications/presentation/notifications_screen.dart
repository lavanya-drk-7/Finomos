import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../income_tracking/domain/income_models.dart';
import '../../income_tracking/providers/income_provider.dart';
import '../../expense_tracking/domain/expense_models.dart';
import '../../expense_tracking/providers/expense_provider.dart';
import '../domain/notification_models.dart';
import '../providers/notification_provider.dart';
import '../../transaction_detection/services/sms_sync_service.dart';
import '../../auth_kyc/providers/auth_kyc_provider.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/phone_utils.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const List<String> _filters = [
    'All',
    'SMS Notifications',
    'Credits',
    'Debits',
    'Fixed Deposits',
    'Promotions',
    'Saved',
  ];

  String _formatRupees(double amount) {
    final int val = amount.round();
    final str = val.toString();
    if (str.length <= 3) return '₹$str';
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if ((rest.length - i) % 2 == 0 && i != 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    return '₹${buffer.toString()},$lastThree';
  }

  void _onNotificationTap(
      BuildContext context, WidgetRef ref, AppNotification notif) {
    ref.read(notificationsProvider.notifier).markAsRead(notif.id);

    // 1. CREDIT / INCOME SMS
    if (notif.isCreditSms) {
      final detectedId = notif.redirection?.targetId ??
          notif.metadata?['detectedId']?.toString() ??
          notif.metadata?['detectionId']?.toString() ??
          (notif.referenceId != null ? 'inf_${notif.referenceId}' : 'sms_inf_${notif.id}');

      final suggestedCategory = notif.metadata?['suggestedCategory']?.toString() ??
          notif.metadata?['category']?.toString() ??
          (notif.category != null && notif.category != 'Credit' && notif.category != 'SMS' ? notif.category! : 'Salary');

      final accounts = ref.read(bankAggregationProvider).bankAccounts;
      final defaultBank = accounts.isNotEmpty ? accounts.first.bankName : (notif.bankName ?? 'Bank Account');
      final defaultDigits = accounts.isNotEmpty
          ? '••••${accounts.first.maskedAccountNumber.replaceAll(RegExp(r'[^0-9]'), '')}'
          : (notif.accountDigits ?? '');

      double extractAmt(String? text) {
        if (text == null) return 0.0;
        final match = RegExp(r'(?:rs\.?|inr)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false).firstMatch(text);
        if (match != null) {
          return double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0.0;
        }
        return 0.0;
      }

      final inflow = DetectedInflow(
        detectedId: detectedId,
        detectedSource: notif.merchantOrSource ?? notif.title,
        suggestedCategory: suggestedCategory,
        amount: notif.amount ?? extractAmt(notif.rawSms ?? notif.message),
        date: notif.metadata?['date']?.toString() ?? 'Today',
        bankAccount:
            '${notif.bankName ?? defaultBank} ${notif.accountDigits ?? defaultDigits}',
        confidenceScore: 0.98,
        detectionChannel: 'SMS Alert',
        rawSms: notif.rawSms ?? notif.message,
        referenceId: notif.referenceId,
      );

      // Prepend to income screen's detected inflows
      ref.read(incomeProvider.notifier).addDetectedInflow(inflow);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Credit SMS identified: Navigating to Income screen to review details...'),
          backgroundColor: Color(0xFF059669),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to Income Tracking
      context.push('/income-tracking');
      return;
    }

    // 2. DEBIT / EXPENSE SMS
    if (notif.isDebitSms) {
      final detectionId = notif.redirection?.targetId ??
          (notif.referenceId != null ? 'deb_${notif.referenceId}' : 'sms_exp_${notif.id}');

      final accounts = ref.read(bankAggregationProvider).bankAccounts;
      final defaultBank = accounts.isNotEmpty ? accounts.first.bankName : (notif.bankName ?? 'Bank Account');
      final defaultDigits = accounts.isNotEmpty
          ? '••••${accounts.first.maskedAccountNumber.replaceAll(RegExp(r'[^0-9]'), '')}'
          : (notif.accountDigits ?? '');

      double extractAmt(String? text) {
        if (text == null) return 0.0;
        final match = RegExp(r'(?:rs\.?|inr)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false).firstMatch(text);
        if (match != null) {
          return double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0.0;
        }
        return 0.0;
      }

      final expense = DetectedExpense(
        detectionId: detectionId,
        description: notif.merchantOrSource ?? notif.title,
        suggestedCategory: notif.metadata?['suggestedCategory']?.toString() ?? 'Food & Dining',
        suggestedPriority: notif.metadata?['suggestedPriority']?.toString() ?? 'P4 - Discretionary',
        amount: notif.amount ?? extractAmt(notif.rawSms ?? notif.message),
        date: notif.metadata?['date']?.toString() ?? 'Today',
        paymentMode: 'UPI',
        bankAccount:
            '${notif.bankName ?? defaultBank} ${notif.accountDigits ?? defaultDigits}',
        merchant: notif.merchantOrSource ?? 'Merchant',
        isDebit: true,
        confidenceScore: 0.98,
        channel: 'SMS Alert',
        rawSms: notif.rawSms ?? notif.message,
        referenceId: notif.referenceId,
      );

      // Prepend to expense screen's detected expenses
      ref.read(expenseProvider.notifier).addDetectedExpense(expense);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Debit SMS identified: Navigating to Expense screen to review details...'),
          backgroundColor: Color(0xFFDC2626),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to Expense Tracking
      context.push('/expense-tracking');
      return;
    }

    // 3. FIXED DEPOSIT SMS
    if (notif.isFixedDepositSms) {
      _showFixedDepositSheet(context, ref, notif);
      return;
    }

    // 4. PROMOTION SMS
    if (notif.isPromotionSms) {
      _showPromotionSheet(context, ref, notif);
      return;
    }

    // 5. OTHER / BUDGET / KYC ALERTS
    _showAlertDetailSheet(context, ref, notif);
  }

  void _showFixedDepositSheet(
      BuildContext context, WidgetRef ref, AppNotification notif) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.15),
                    radius: 20,
                    child: const Icon(Icons.account_balance,
                        color: Color(0xFF8B5CF6), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540)),
                        ),
                        Text(
                          '${notif.bankName ?? "State Bank of India"} • Fixed Deposit',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('FD Alert',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B5CF6))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Principal Amount',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF64748B))),
                        Text(
                          notif.amount != null
                              ? _formatRupees(notif.amount!)
                              : '₹ 1,00,000',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF7C3AED)),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFDDD6FE)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tenor & Rate',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF64748B))),
                        Text(
                          '${notif.fdDetails?.tenure ?? "1 Year"} @ ${notif.fdDetails?.interestRate ?? "7.10% p.a."}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Account Link',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF64748B))),
                        Text(
                          '${notif.bankName ?? "SBI"} ${notif.accountDigits ?? "••••4821"}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                notif.message,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Text('View in Bank Aggregation & Wealth',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push('/bank-aggregation');
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(
                          notif.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          size: 16),
                      label: Text(notif.isSaved ? 'Saved' : 'Save SMS'),
                      onPressed: () {
                        ref
                            .read(notificationsProvider.notifier)
                            .toggleSaveNotification(notif.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(notif.isSaved
                                ? 'Removed from saved'
                                : 'SMS saved to your notification vault!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Dismiss'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPromotionSheet(
      BuildContext context, WidgetRef ref, AppNotification notif) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0066FF).withOpacity(0.15),
                    radius: 20,
                    child: const Icon(Icons.local_offer,
                        color: Color(0xFF0066FF), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540)),
                        ),
                        Text(
                          notif.bankName ?? 'Finomos Offers',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Promotion',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0066FF))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PROMO CODE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E40AF))),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('FINFEST10',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Color(0xFF0066FF))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF93C5FD)),
                          ),
                          child: const Text('10% CASHBACK',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0066FF))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(notif.message,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF1E3A8A))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(
                          notif.isSaved ? Icons.bookmark : Icons.bookmark_add,
                          color: Colors.white),
                      label: Text(
                        notif.isSaved ? 'Offer Saved' : 'Save Offer',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        ref
                            .read(notificationsProvider.notifier)
                            .toggleSaveNotification(notif.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(notif.isSaved
                                ? 'Offer removed from saved'
                                : 'Promotional offer saved to your vault!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Dismiss'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAlertDetailSheet(
      BuildContext context, WidgetRef ref, AppNotification notif) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            const Color(0xFFEF4444).withOpacity(0.15),
                        child: const Icon(Icons.pie_chart,
                            color: Color(0xFFEF4444)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notif.title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A2540))),
                          Text(notif.timestamp,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('${notif.priority} Priority',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCA5A5))),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: const [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                              value: 0.9,
                              strokeWidth: 8,
                              backgroundColor: Color(0xFFE2E8F0),
                              color: Color(0xFFEF4444)),
                        ),
                        Text('90%',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF0A2540))),
                      ],
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Food Budget',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF64748B))),
                          Text('₹ 8,000',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A2540))),
                          Text('Used: ₹ 7,200 • Remaining: ₹ 800',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: Color(0xFF0066FF), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'Tip: Consider reducing non-essential food expenses to stay within your budget.',
                          style:
                              TextStyle(fontSize: 11, color: Color(0xFF1E3A8A))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    ref
                        .read(notificationsProvider.notifier)
                        .markAsRead(notif.id);
                    Navigator.pop(ctx);
                    context.push('/budget-management');
                  },
                  child: const Text('View Budget',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    ref
                        .read(notificationsProvider.notifier)
                        .markAsRead(notif.id);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Mark as Read'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final activeMobile = PhoneUtils.sanitize(
      ref.watch(authKycProvider).user.mobileNumber.isNotEmpty
          ? ref.watch(authKycProvider).user.mobileNumber
          : (LocalCacheService().get('user_mobile_number')?.toString() ??
             (LocalCacheService().get('auth_session') as Map?)?['phone']?.toString() ?? ''),
    );

    final filteredNotifications = state.notifications.where((n) {
      switch (state.selectedFilter) {
        case 'SMS Notifications':
          return n.isSms;
        case 'Credits':
          return n.isCreditSms;
        case 'Debits':
          return n.isDebitSms;
        case 'Fixed Deposits':
          return n.isFixedDepositSms;
        case 'Promotions':
          return n.isPromotionSms;
        case 'Saved':
          return n.isSaved;
        case 'All':
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF0066FF)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const FinmosLogo(
            size: 26, showTagline: false, isHorizontal: true),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Color(0xFF0066FF)),
            tooltip: 'Sync SMS from Messages app',
            onPressed: () async {
              final activeMobile = PhoneUtils.sanitize(
                ref.read(authKycProvider).user.mobileNumber.isNotEmpty
                    ? ref.read(authKycProvider).user.mobileNumber
                    : (LocalCacheService().get('user_mobile_number')?.toString() ??
                       (LocalCacheService().get('auth_session') as Map?)?['phone']?.toString() ?? ''),
              );
              final bool isAllowed = activeMobile.isNotEmpty &&
                  LocalCacheService().get('sms_allowed_$activeMobile') == true;
              if (!isAllowed) {
                context.push('/allow-sms');
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scanning device SMS inbox for bank transactions...'),
                  duration: Duration(seconds: 1),
                ),
              );
              final result = await SmsSyncService().syncDeviceSms(ref: ref, userMobile: activeMobile);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.newlyIngested > 0
                          ? 'Sync complete! ${result.newlyIngested} new bank transactions detected.'
                          : 'SMS inbox up to date. No new transactions found.',
                    ),
                    backgroundColor: result.newlyIngested > 0 ? const Color(0xFF10B981) : const Color(0xFF0066FF),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          TextButton(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).markAllAsRead(),
            child: const Text('Mark all read',
                style: TextStyle(fontSize: 12, color: Color(0xFF0066FF))),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final activeMobile = PhoneUtils.sanitize(
              ref.read(authKycProvider).user.mobileNumber.isNotEmpty
                  ? ref.read(authKycProvider).user.mobileNumber
                  : (LocalCacheService().get('user_mobile_number')?.toString() ??
                     (LocalCacheService().get('auth_session') as Map?)?['phone']?.toString() ?? ''),
            );
            await ref.read(notificationsProvider.notifier).loadLiveNotifications(userMobile: activeMobile);
            final bool isAllowed = activeMobile.isNotEmpty &&
                LocalCacheService().get('sms_allowed_$activeMobile') == true;
            if (isAllowed) {
              await SmsSyncService().syncDeviceSms(ref: ref, userMobile: activeMobile);
            }
          },
          color: const Color(0xFF0066FF),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const Text('Notifications & Alerts',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2540))),
              const Text(
                  'Automated SMS tracking for Credits, Debits, Fixed Deposits & Promotions.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 16),

              if (activeMobile.isNotEmpty &&
                  LocalCacheService().get('sms_allowed_$activeMobile') != true) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.mark_chat_unread_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Allow SMS Tracking',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A2540),
                              ),
                            ),
                            Text(
                              'Auto-sync transaction alerts for +91 $activeMobile',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => context.push('/allow-sms'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Allow',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Overview Cards Row
              Row(
                children: [
                  Expanded(
                      child: _buildStatBadge('Total Alerts',
                          '${state.totalAlerts}', const Color(0xFF0066FF))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildStatBadge('SMS Inflow', '${state.smsCount}',
                          const Color(0xFF059669))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildStatBadge('Saved', '${state.savedCount}',
                          const Color(0xFF8B5CF6))),
                ],
              ),
              const SizedBox(height: 16),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = state.selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(filter),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                        selectedColor: const Color(0xFF0066FF),
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF0066FF)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        onSelected: (_) {
                          ref
                              .read(notificationsProvider.notifier)
                              .setFilter(filter);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      state.selectedFilter == 'All'
                          ? 'Recent Notifications'
                          : state.selectedFilter,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2540),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredNotifications.length} Items',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (filteredNotifications.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 40, color: const Color(0xFF94A3B8)),
                      const SizedBox(height: 8),
                      Text(
                        'No notifications found in ${state.selectedFilter}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredNotifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final notif = filteredNotifications[idx];

                    final Color iconBg;
                    final Color iconColor;
                    final IconData iconData;
                    final String badgeLabel;

                    if (notif.isCreditSms) {
                      iconBg = const Color(0xFFECFDF5);
                      iconColor = const Color(0xFF059669);
                      iconData = Icons.arrow_downward_rounded;
                      badgeLabel = 'Credit';
                    } else if (notif.isDebitSms) {
                      iconBg = const Color(0xFFFEF2F2);
                      iconColor = const Color(0xFFDC2626);
                      iconData = Icons.arrow_upward_rounded;
                      badgeLabel = 'Debit';
                    } else if (notif.isFixedDepositSms) {
                      iconBg = const Color(0xFFF5F3FF);
                      iconColor = const Color(0xFF8B5CF6);
                      iconData = Icons.account_balance;
                      badgeLabel = 'Fixed Deposit';
                    } else if (notif.isPromotionSms) {
                      iconBg = const Color(0xFFEFF6FF);
                      iconColor = const Color(0xFF0066FF);
                      iconData = Icons.local_offer;
                      badgeLabel = 'Promotion';
                    } else {
                      iconBg = notif.priority == 'High'
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFEFF6FF);
                      iconColor = notif.priority == 'High'
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF0066FF);
                      iconData = notif.type == 'Budget'
                          ? Icons.pie_chart
                          : notif.type == 'KYC'
                              ? Icons.verified_user
                              : Icons.notifications;
                      badgeLabel = notif.type;
                    }

                    return InkWell(
                      onTap: () => _onNotificationTap(context, ref, notif),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: notif.isRead
                              ? Colors.white
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: notif.isSaved
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFFE2E8F0),
                            width: notif.isSaved ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Category Badge, Bank Tag, Amount, Saved Tag
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: iconBg,
                                  child: Icon(iconData,
                                      color: iconColor, size: 14),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: iconBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      badgeLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: iconColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                if (notif.bankName != null) ...[
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      notif.bankName!,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF64748B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                if (notif.amount != null) ...[
                                  Text(
                                    notif.isCreditSms
                                        ? '+${_formatRupees(notif.amount!)}'
                                        : notif.isDebitSms
                                            ? '-${_formatRupees(notif.amount!)}'
                                            : _formatRupees(notif.amount!),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: notif.isCreditSms
                                          ? const Color(0xFF059669)
                                          : notif.isDebitSms
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF8B5CF6),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                if (notif.isSaved)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDBEAFE),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.bookmark,
                                            size: 10,
                                            color: Color(0xFF0066FF)),
                                        SizedBox(width: 2),
                                        Text('Saved',
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0066FF))),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Notification Title & Message
                            Text(
                              notif.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF0A2540),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF475569),
                                  height: 1.35),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  notif.timestamp,
                                  style: const TextStyle(
                                      fontSize: 10, color: Color(0xFF94A3B8)),
                                ),
                                if (notif.isCreditSms || notif.isDebitSms)
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            notif.isCreditSms
                                                ? 'Tap to review income'
                                                : 'Tap to review expense',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: notif.isCreditSms
                                                  ? const Color(0xFF059669)
                                                  : const Color(0xFFDC2626),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 14,
                                          color: notif.isCreditSms
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 8),

                            // ============================================
                            // Two Action Options: Save and Delete
                            // ============================================
                            Row(
                              children: [
                                // 1. Save Button
                                Expanded(
                                  child: OutlinedButton.icon(
                                    key: ValueKey('save_btn_${notif.id}'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: notif.isSaved
                                          ? const Color(0xFF0066FF)
                                          : const Color(0xFF475569),
                                      side: BorderSide(
                                        color: notif.isSaved
                                            ? const Color(0xFF93C5FD)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                      backgroundColor: notif.isSaved
                                          ? const Color(0xFFEFF6FF)
                                          : Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 7),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    icon: Icon(
                                      notif.isSaved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      size: 15,
                                      color: notif.isSaved
                                          ? const Color(0xFF0066FF)
                                          : const Color(0xFF475569),
                                    ),
                                    label: Text(
                                      notif.isSaved ? 'Saved' : 'Save',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: notif.isSaved
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                      ),
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(notificationsProvider.notifier)
                                          .toggleSaveNotification(notif.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(notif.isSaved
                                              ? 'SMS removed from saved'
                                              : 'SMS saved to your notification vault!'),
                                          duration:
                                              const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // 2. Delete Button
                                Expanded(
                                  child: OutlinedButton.icon(
                                    key: ValueKey('delete_btn_${notif.id}'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFDC2626),
                                      side: const BorderSide(
                                          color: Color(0xFFFCA5A5)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 7),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.delete_outline,
                                        size: 15, color: Color(0xFFDC2626)),
                                    label: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(notificationsProvider.notifier)
                                          .deleteNotification(notif.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('SMS notification deleted'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildStatBadge(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(count,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
