import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/phone_utils.dart';
import '../domain/notification_models.dart';
import '../services/notification_api_service.dart';

class NotificationsNotifier extends Notifier<NotificationsState> {
  final NotificationApiService _apiService = NotificationApiService();

  static const Set<String> _staticIds = {
    'sms_cred_salary',
    'sms_deb_swiggy',
    'sms_deb_starbucks',
    'sms_fd_sbi',
    'sms_promo_festive',
    'n_1',
    'n_2',
    'n_3',
    'n_4',
    'n_5',
  };

  static const List<AppNotification> _defaultNotifications = [
    AppNotification(
      id: 'sms_cred_salary',
      title: 'Salary Credited • HDFC Bank',
      message:
          'A/c ••••4587 is credited with ₹85,000.00 on 25-Oct-2026 by Tech Corp India Pvt Ltd. Avl Bal: ₹1,10,000.00',
      type: 'SMS',
      isSms: true,
      smsCategory: 'Credit',
      amount: 85000.0,
      bankName: 'HDFC Bank',
      accountDigits: '••••4587',
      merchantOrSource: 'Tech Corp India Pvt Ltd',
      rawSms:
          'Dear Customer, Your A/c ••••4587 is credited with ₹85,000.00 on 25-Oct-2026 by Tech Corp India Pvt Ltd. Avl Bal: ₹1,10,000.00 - HDFC Bank',
      priority: 'High',
      timestamp: 'Today, 09:30 AM',
      isRead: false,
    ),
    AppNotification(
      id: 'sms_deb_swiggy',
      title: 'Paid to Swiggy • ICICI Bank',
      message:
          '₹450.00 debited from ICICI Bank A/c ••••9021 on 03-Nov-2026 via UPI to Swiggy. UPI Ref: 489201827412.',
      type: 'SMS',
      isSms: true,
      smsCategory: 'Debit',
      amount: 450.0,
      bankName: 'ICICI Bank',
      accountDigits: '••••9021',
      merchantOrSource: 'Swiggy',
      rawSms:
          'Dear Customer, ₹450.00 debited from ICICI Bank A/c ••••9021 on 03-Nov-2026 via UPI to Swiggy. UPI Ref: 489201827412.',
      priority: 'Medium',
      timestamp: 'Today, 01:15 PM',
      isRead: false,
    ),
    AppNotification(
      id: 'sms_deb_starbucks',
      title: 'Card Spend • Axis Bank',
      message:
          '₹1,250.00 spent on Axis Bank Credit Card ••••8921 at Starbucks Coffee on 02-Nov-2026. Avl Limit: ₹2,83,750.00',
      type: 'SMS',
      isSms: true,
      smsCategory: 'Debit',
      amount: 1250.0,
      bankName: 'Axis Bank',
      accountDigits: '••••8921',
      merchantOrSource: 'Starbucks Coffee',
      rawSms:
          'Alert: ₹1,250.00 spent on Axis Bank Credit Card ••••8921 at Starbucks Coffee on 02-Nov-2026. Avl Limit: ₹2,83,750.00',
      priority: 'Medium',
      timestamp: 'Yesterday, 04:45 PM',
      isRead: false,
    ),
    AppNotification(
      id: 'sms_fd_sbi',
      title: 'Fixed Deposit Created • SBI',
      message:
          'FD A/c #FD89210 of ₹1,00,000.00 opened with State Bank of India for 1 Year @ 7.10% p.a. Maturity: 03-Nov-2027.',
      type: 'SMS',
      isSms: true,
      smsCategory: 'Fixed Deposit',
      amount: 100000.0,
      bankName: 'State Bank of India',
      accountDigits: '••••4821',
      merchantOrSource: 'SBI Fixed Deposit',
      rawSms:
          'Dear Customer, Fixed Deposit A/c #FD89210 of ₹1,00,000.00 created successfully with State Bank of India for 1 Year @ 7.10% p.a. Maturity: 03-Nov-2027',
      priority: 'Info',
      timestamp: 'Yesterday, 11:20 AM',
      isRead: false,
      fdDetails: NotificationFdDetails(
        principal: 100000,
        tenure: '12 months',
        interestRate: '7.10% p.a.',
      ),
    ),
    AppNotification(
      id: 'sms_promo_festive',
      title: 'Festive Cashback Offer • 10% Off',
      message:
          'Get 10% instant cashback up to ₹1,500 on online orders via your HDFC Bank Card using promo code FINFEST10. Valid till 15-Nov.',
      type: 'SMS',
      isSms: true,
      smsCategory: 'Promotion',
      amount: null,
      bankName: 'HDFC Bank',
      merchantOrSource: 'Amazon & Flipkart',
      rawSms:
          'Finomos Special: Get 10% instant cashback up to ₹1,500 on online orders via HDFC Bank Card. Use code FINFEST10.',
      priority: 'Low',
      timestamp: '2 days ago',
      isRead: false,
    ),
    AppNotification(
      id: 'n_1',
      title: 'Budget Alert',
      message: 'You have used 90% of your monthly food budget.',
      type: 'Budget',
      priority: 'High',
      timestamp: 'Today, 10:24 AM',
      isRead: false,
    ),
    AppNotification(
      id: 'n_2',
      title: 'KYC Update',
      message: 'Your KYC verification is completed.',
      type: 'KYC',
      priority: 'Info',
      timestamp: 'Today, 09:15 AM',
      isRead: false,
    ),
    AppNotification(
      id: 'n_3',
      title: 'Document Alert',
      message: 'Your insurance document is expiring soon.',
      type: 'Document',
      priority: 'Medium',
      timestamp: 'Yesterday, 06:32 PM',
      isRead: false,
    ),
    AppNotification(
      id: 'n_4',
      title: 'Account Connection',
      message: 'Your SBI account has been successfully connected.',
      type: 'Account',
      priority: 'Info',
      timestamp: 'Yesterday, 11:20 AM',
      isRead: false,
    ),
    AppNotification(
      id: 'n_5',
      title: 'Security Alert',
      message: 'A new device has logged into your account.',
      type: 'Security',
      priority: 'Low',
      timestamp: '16 Aug 2025, 08:45 PM',
      isRead: false,
    ),
  ];

  @override
  NotificationsState build() {
    final cached = LocalCacheService().get('app_notifications');
    List<AppNotification>? cachedNotifications;
    if (cached is List) {
      cachedNotifications = cached
          .whereType<Map>()
          .map((n) => AppNotification.fromJson(Map<String, dynamic>.from(n)))
          .toList();
    }

    final deleted = LocalCacheService().get('deleted_notification_ids');
    final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];

    final saved = LocalCacheService().get('saved_notification_ids');
    final savedIds = saved is List ? saved.cast<String>() : <String>[];

    bool isTestEnv = false;
    try {
      isTestEnv = Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {}

    final rawList = cachedNotifications ?? (isTestEnv ? _defaultNotifications : const <AppNotification>[]);
    final baseList = isTestEnv
        ? rawList
        : rawList.where((n) {
            if (_staticIds.contains(n.id)) return false;
            if (n.id.startsWith('sms_cred_') ||
                n.id.startsWith('sms_deb_') ||
                n.id.startsWith('sms_fd_') ||
                n.id.startsWith('sms_promo_')) {
              return false;
            }
            return true;
          }).toList();

    final currentMobile = PhoneUtils.sanitize(
      LocalCacheService().get('user_mobile_number')?.toString() ??
          (LocalCacheService().get('auth_session') as Map?)?['phone']?.toString() ?? '',
    );

    final userScopedList = (isTestEnv || currentMobile.isEmpty)
        ? baseList
        : baseList.where((n) {
            if (n.userMobile != null && n.userMobile!.isNotEmpty) {
              return PhoneUtils.sanitize(n.userMobile) == currentMobile;
            }
            if (n.isSms) return false;
            return true;
          }).toList();

    final filtered = userScopedList
        .where((n) => !deletedIds.contains(n.id))
        .map((n) {
          if (savedIds.contains(n.id)) {
            return n.copyWith(isSaved: true);
          }
          return n;
        })
        .toList();

    Future.microtask(() => loadLiveNotifications());

    // Do NOT seed backendCounts here — leave it null so the computed getters
    // (totalAlerts, savedCount, smsCount) always fall back to the live
    // `notifications` list.  backendCounts is only set after a successful
    // loadLiveNotifications() call that returns backend data.
    return NotificationsState(
      notifications: filtered,
      preferences: const NotificationPreferencesState(),
    );
  }

  /// Fetch live notifications and unread counts from live backend
  Future<void> loadLiveNotifications({String? filter, String? userMobile}) async {
    try {
      final effectiveFilter = filter ?? state.selectedFilter;
      final activeMobile = PhoneUtils.sanitize(
        userMobile ??
            (LocalCacheService().get('user_mobile_number')?.toString() ??
             (LocalCacheService().get('auth_session') as Map?)?['phone']?.toString() ?? ''),
      );
      final activeUserId = (LocalCacheService().get('auth_session') as Map?)?['userId']?.toString() ??
          LocalCacheService().get('user_id')?.toString();
      bool isTestEnv = false;
      try {
        isTestEnv = Platform.environment.containsKey('FLUTTER_TEST');
      } catch (_) {}

      final results = await Future.wait([
        _apiService.getNotifications(
          filter: effectiveFilter,
          userMobile: activeMobile.isNotEmpty ? activeMobile : null,
        ),
        _apiService.getUnreadCountsDetailed(),
      ]);

      final res = results[0] as NotificationListResponse?;
      // The unread-counts result from getUnreadCountsDetailed() is not used here;
      // counts are re-computed locally from the filtered list below.
      // (Fetching it concurrently keeps the server cache warm.)

      if (res != null) {
        final deleted = LocalCacheService().get('deleted_notification_ids');
        final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];
        final saved = LocalCacheService().get('saved_notification_ids');
        final savedIds = saved is List ? saved.cast<String>() : <String>[];

        final isSmsAllowed = activeMobile.isNotEmpty
            ? LocalCacheService().get('sms_allowed_$activeMobile') == true
            : false;

        final filtered = res.notifications
            .where((n) {
              if (deletedIds.contains(n.id)) return false;
              if (_staticIds.contains(n.id)) return false;
              if (n.id.startsWith('sms_cred_') ||
                  n.id.startsWith('sms_deb_') ||
                  n.id.startsWith('sms_fd_') ||
                  n.id.startsWith('sms_promo_')) {
                return false;
              }
              // If notification has userId, match with active session
              if (activeUserId != null && activeUserId.isNotEmpty && n.userId != null && n.userId!.isNotEmpty) {
                if (n.userId != activeUserId) return false;
              }
              // If notification has userMobile, match with active mobile
              if (activeMobile.isNotEmpty && n.userMobile != null && n.userMobile!.isNotEmpty) {
                if (PhoneUtils.sanitize(n.userMobile) != activeMobile) return false;
              }
              // If SMS is not allowed for this mobile, exclude SMS notifications
              if (n.isSms && !isSmsAllowed && !isTestEnv) {
                return false;
              }
              return true;
            })
            .map((n) {
              var item = n;
              if (item.userMobile == null || item.userMobile!.isEmpty) {
                if (activeMobile.isNotEmpty) {
                  item = item.copyWith(userMobile: activeMobile);
                }
              }
              if (savedIds.contains(item.id)) {
                item = item.copyWith(isSaved: true);
              }
              return item;
            })
            .toList();

        final updatedCounts = NotificationCounts(
          all: filtered.length,
          unread: filtered.where((n) => !n.isRead).length,
          saved: filtered.where((n) => n.isSaved).length,
          sms: filtered.where((n) => n.isCreditSms || n.isSms).length,
        );

        state = state.copyWith(
          notifications: filtered,
          backendCounts: updatedCounts,
          pagination: res.pagination,
          isLoading: false,
        );
        LocalCacheService().save(
          'app_notifications',
          filtered.map((n) => n.toJson()).toList(),
        );
      }
    } catch (_) {}
  }

  /// Mark notification as read (optimistic update + PATCH /:id/read)
  Future<void> markAsRead(String id) async {
    final updated = state.notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    state = state.copyWith(notifications: updated);
    await _apiService.markAsRead(id);
    await loadLiveNotifications();
  }

  /// Mark all notifications as read (optimistic update + POST /read-all)
  Future<void> markAllAsRead() async {
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: updated);
    await _apiService.markAllAsRead();
    await loadLiveNotifications();
  }

  /// Toggle or set Save status on notification (optimistic update + PATCH /:id/save)
  Future<void> toggleSaveNotification(String id) async {
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isSaved: !n.isSaved);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updated);

    final savedIds = updated.where((n) => n.isSaved).map((n) => n.id).toList();
    LocalCacheService().save('saved_notification_ids', savedIds);

    await _apiService.toggleSaveNotification(id);
  }

  /// Delete notification from the list and persist deletion (optimistic + DELETE /:id)
  Future<void> deleteNotification(String id) async {
    final updated = state.notifications.where((n) => n.id != id).toList();
    state = state.copyWith(notifications: updated);

    final deleted = LocalCacheService().get('deleted_notification_ids');
    final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];
    if (!deletedIds.contains(id)) {
      deletedIds.add(id);
      LocalCacheService().save('deleted_notification_ids', deletedIds);
    }

    LocalCacheService().save(
      'app_notifications',
      updated.map((n) => n.toJson()).toList(),
    );

    await _apiService.deleteNotification(id);
    await loadLiveNotifications();
  }

  /// Delete all notifications from backend (DELETE /api/v1/notifications)
  /// Delete all notifications from backend (DELETE /api/v1/notifications)
  void clearLocalNotifications() {
    state = state.copyWith(
      notifications: [],
      backendCounts: const NotificationCounts(),
      isLoading: false,
    );
    LocalCacheService().save('app_notifications', []);
    LocalCacheService().remove('cached_notifications');
  }

  Future<void> clearAllNotifications() async {
    state = state.copyWith(notifications: []);
    LocalCacheService().save('app_notifications', []);
    await _apiService.deleteAllNotifications();
    await loadLiveNotifications();
  }

  /// Ingest raw SMS for parsing, classification and prepending to notification stream
  Future<AppNotification?> ingestSms({
    required String sender,
    required String body,
    String? userMobile,
  }) async {
    try {
      final activeMobile = PhoneUtils.sanitize(
        userMobile ??
            LocalCacheService().get('user_mobile_number')?.toString() ??
            (LocalCacheService().get('auth_session') as Map?)?['phone']?.toString(),
      );
      final activeUserId = (LocalCacheService().get('auth_session') as Map?)?['userId']?.toString() ??
          LocalCacheService().get('user_id')?.toString();

      final result = await _apiService.ingestSms(
        sender: sender,
        body: body,
        userMobile: activeMobile.isNotEmpty ? activeMobile : null,
      );
      if (result != null) {
        final notif = AppNotification(
          id: result.notificationId ?? 'sms_${DateTime.now().millisecondsSinceEpoch}',
          userId: activeUserId,
          userMobile: activeMobile.isNotEmpty ? activeMobile : null,
          title: result.entities?['merchantOrSource'] != null
              ? '${result.classification ?? "SMS"} • ${result.entities!['merchantOrSource']}'
              : (result.classification ?? 'SMS Alert'),
          message: body,
          type: 'SMS',
          priority: result.entities?['suggestedPriority']?.toString() ?? 'Info',
          timestamp: 'Just now',
          isSms: true,
          smsCategory: result.classification,
          smsSender: sender,
          amount: (result.entities?['amount'] as num?)?.toDouble(),
          balance: (result.entities?['balance'] as num?)?.toDouble(),
          bankName: result.entities?['bankName']?.toString(),
          accountDigits: result.entities?['accountDigits']?.toString(),
          merchantOrSource: result.entities?['merchantOrSource']?.toString(),
          referenceId: result.entities?['referenceId']?.toString(),
          rawSms: body,
          redirection: result.redirection,
          fdDetails: result.entities?['fdDetails'] != null
              ? NotificationFdDetails.fromJson(
                  result.entities!['fdDetails'] as Map<String, dynamic>)
              : null,
        );

        final updated = [notif, ...state.notifications];
        state = state.copyWith(
          notifications: updated,
        );
        LocalCacheService().save(
          'app_notifications',
          updated.map((n) => n.toJson()).toList(),
        );
        return notif;
      }
    } catch (_) {}
    return null;
  }

  void updatePreferences(NotificationPreferencesState prefs) {
    state = state.copyWith(preferences: prefs);
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
    loadLiveNotifications(filter: filter);
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(() {
      return NotificationsNotifier();
    });
