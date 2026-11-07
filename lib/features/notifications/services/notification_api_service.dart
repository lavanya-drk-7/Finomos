import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/phone_utils.dart';
import '../domain/notification_models.dart';

class NotificationApiService {
  final ApiClient _client = ApiClient();

  /// Map UI filter names to backend filter query strings
  String _normalizeFilter(String filter) {
    switch (filter.trim().toLowerCase()) {
      case 'sms notifications':
      case 'sms':
      case 'credits':
      case 'debits':
      case 'fixed deposits':
      case 'promotions':
        return 'sms';
      case 'saved':
        return 'saved';
      case 'unread':
        return 'unread';
      case 'all':
      default:
        return 'all';
    }
  }

  /// Fetch notifications list from live backend with filters and pagination
  /// GET /api/v1/notifications?filter=all&page=1&limit=50
  Future<NotificationListResponse?> getNotifications({
    String filter = 'all',
    int page = 1,
    int limit = 50,
    String? userMobile,
  }) async {
    try {
      final backendFilter = _normalizeFilter(filter);
      final cleanMobile = PhoneUtils.sanitize(userMobile ?? LocalCacheService().get('user_mobile_number')?.toString());
      final response = await _client.get(
        ApiConstants.notificationsQuery(
          filter: backendFilter,
          page: page,
          limit: limit,
          userMobile: cleanMobile.isNotEmpty ? cleanMobile : null,
        ),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          List<dynamic> notifsJson = [];
          NotificationPagination pagination = const NotificationPagination();
          NotificationCounts counts = const NotificationCounts();

          if (body['data'] is List) {
            notifsJson = body['data'] as List<dynamic>;
            final total = (body['total'] as num?)?.toInt() ?? notifsJson.length;
            final pageNum = (body['page'] as num?)?.toInt() ?? page;
            final limitNum = (body['limit'] as num?)?.toInt() ?? limit;
            pagination = NotificationPagination(
              total: total,
              page: pageNum,
              limit: limitNum,
              totalPages: limitNum > 0 ? (total / limitNum).ceil().clamp(1, 9999) : 1,
            );
            final unreadCount = notifsJson.where((n) => n is Map && n['isRead'] != true).length;
            final savedCount = notifsJson.where((n) => n is Map && n['isSaved'] == true).length;
            final smsCount = notifsJson.where((n) => n is Map && (n['isSms'] == true || n['type'] == 'SMS')).length;
            counts = NotificationCounts(
              all: total,
              unread: unreadCount,
              saved: savedCount,
              sms: smsCount,
            );
          } else if (body['data'] is Map<String, dynamic>) {
            final data = body['data'] as Map<String, dynamic>;
            notifsJson = (data['notifications'] as List<dynamic>?) ??
                (data['data'] as List<dynamic>?) ??
                [];
            pagination = NotificationPagination.fromJson(
              data['pagination'] as Map<String, dynamic>?,
            );
            counts = NotificationCounts.fromJson(
              data['counts'] as Map<String, dynamic>?,
            );
          }

          final notifs = notifsJson
              .whereType<Map>()
              .map((n) => AppNotification.fromJson(
                    Map<String, dynamic>.from(n),
                    defaultUserMobile: cleanMobile.isNotEmpty ? cleanMobile : null,
                  ))
              .toList();

          if (page == 1 && backendFilter == 'all') {
            LocalCacheService().save(
              'cached_notifications',
              notifs.map((n) => n.toJson()).toList(),
            );
          }

          return NotificationListResponse(
            notifications: notifs,
            pagination: pagination,
            counts: counts,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch live unread notifications count
  /// GET /api/v1/notifications/unread-count
  Future<NotificationUnreadCounts?> getUnreadCountsDetailed() async {
    try {
      final response = await _client.get(ApiConstants.notificationsUnreadCount);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return NotificationUnreadCounts.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<int?> getUnreadCount() async {
    final counts = await getUnreadCountsDetailed();
    return counts?.unreadCount;
  }

  /// Ingest raw SMS for classification, entity extraction & redirection
  /// POST /api/v1/notifications/sms/ingest
  Future<SmsIngestResult?> ingestSms({
    required String sender,
    required String body,
    String? userMobile,
  }) async {
    try {
      final cleanMobile = PhoneUtils.sanitize(userMobile ?? LocalCacheService().get('user_mobile_number')?.toString());
      final response = await _client.post(
        ApiConstants.notificationsSmsIngest,
        body: {
          'sender': sender,
          'body': body,
          if (cleanMobile.isNotEmpty) 'userMobile': cleanMobile,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> resBody = jsonDecode(response.body);
        return SmsIngestResult.fromJson(resBody);
      }
    } catch (_) {}
    return null;
  }

  /// Batch sync device SMS inbox messages with live backend
  /// POST /api/v1/notifications/sms/batch-sync
  Future<SmsBatchSyncResult?> batchSyncSms({
    required String userMobile,
    required List<Map<String, dynamic>> messages,
    String syncMode = 'HISTORICAL',
  }) async {
    try {
      final cleanMobile = PhoneUtils.sanitize(userMobile);
      final normalizedMessages = messages.map((m) {
        final body = (m['body']?.toString() ?? '').replaceAll('\r\n', ' ').replaceAll('\n', ' ').trim();
        return {
          'sender': m['sender']?.toString().trim() ?? '',
          'body': body,
          'timestamp': m['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
        };
      }).toList();

      final response = await _client.post(
        ApiConstants.notificationsSmsBatchSync,
        body: {
          'userMobile': cleanMobile.isNotEmpty ? cleanMobile : userMobile,
          'syncMode': syncMode,
          'deviceTimestamp': DateTime.now().toUtc().toIso8601String(),
          'messages': normalizedMessages,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> resBody = jsonDecode(response.body);
        return SmsBatchSyncResult.fromJson(resBody);
      }
    } catch (_) {}
    return null;
  }

  /// Save or unsave a notification to/from vault
  /// PATCH /api/v1/notifications/:id/save
  Future<bool?> toggleSaveNotification(String id) async {
    try {
      final response = await _client.patch(ApiConstants.notificationSave(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return body['data']['isSaved'] as bool?;
        }
        return true;
      }
    } catch (_) {}
    return null;
  }

  /// Delete a notification from backend
  /// DELETE /api/v1/notifications/:id
  Future<bool> deleteNotification(String id) async {
    try {
      final response = await _client.delete(ApiConstants.notificationById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  /// Mark single notification as read
  /// PATCH /api/v1/notifications/:id/read
  Future<bool> markAsRead(String id) async {
    try {
      final response = await _client.patch(ApiConstants.notificationRead(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  /// Mark all notifications as read
  /// POST /api/v1/notifications/read-all with fallback to PATCH
  Future<bool> markAllAsRead() async {
    try {
      var response = await _client.post(ApiConstants.notificationsReadAll);
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await _client.patch(ApiConstants.notificationsReadAll);
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  /// Delete all notifications from backend
  /// DELETE /api/v1/notifications
  Future<int?> deleteAllNotifications() async {
    try {
      final response = await _client.delete(ApiConstants.notifications);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return (body['deletedCount'] as num?)?.toInt() ?? 0;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Read cached notifications from local persistent cache
  NotificationListResponse? getCachedNotifications() {
    try {
      final cached = LocalCacheService().get('cached_notifications');
      if (cached is Map<String, dynamic>) {
        final notifsJson = cached['notifications'] as List<dynamic>? ?? [];
        final notifs = notifsJson
            .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
            .toList();
        final pagination = NotificationPagination.fromJson(
          cached['pagination'] as Map<String, dynamic>?,
        );
        final counts = NotificationCounts.fromJson(
          cached['counts'] as Map<String, dynamic>?,
        );
        return NotificationListResponse(
          notifications: notifs,
          pagination: pagination,
          counts: counts,
        );
      }
    } catch (_) {}
    return null;
  }
}

