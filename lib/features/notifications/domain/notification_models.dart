class NotificationRedirection {
  final String? route;
  final String? action;
  final String? detectionId;
  final String? detectedId;
  final String? targetModule;
  final Map<String, dynamic>? fdDetails;

  const NotificationRedirection({
    this.route,
    this.action,
    this.detectionId,
    this.detectedId,
    this.targetModule,
    this.fdDetails,
  });

  String? get targetId => detectionId ?? detectedId;

  factory NotificationRedirection.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationRedirection();
    return NotificationRedirection(
      route: json['route']?.toString(),
      action: json['action']?.toString(),
      detectionId: (json['detectionId'] ?? json['detectedId'])?.toString(),
      detectedId: (json['detectedId'] ?? json['detectionId'])?.toString(),
      targetModule: json['targetModule']?.toString(),
      fdDetails: (json['fdDetails'] ?? json['modalDetails']) as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (route != null) 'route': route,
    if (action != null) 'action': action,
    if (detectionId != null) 'detectionId': detectionId,
    if (detectedId != null) 'detectedId': detectedId,
    if (targetModule != null) 'targetModule': targetModule,
    if (fdDetails != null) 'fdDetails': fdDetails,
  };
}

class NotificationFdDetails {
  final double? principal;
  final String? tenure;
  final String? interestRate;
  final double? maturityAmount;
  final String? maturityDate;

  const NotificationFdDetails({
    this.principal,
    this.tenure,
    this.interestRate,
    this.maturityAmount,
    this.maturityDate,
  });

  factory NotificationFdDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationFdDetails();
    final rawPrincipal = json['principal'] ?? json['depositAmount'];
    return NotificationFdDetails(
      principal: (rawPrincipal as num?)?.toDouble(),
      tenure: json['tenure']?.toString(),
      interestRate: json['interestRate']?.toString(),
      maturityAmount: (json['maturityAmount'] as num?)?.toDouble(),
      maturityDate: json['maturityDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (principal != null) 'principal': principal,
    if (tenure != null) 'tenure': tenure,
    if (interestRate != null) 'interestRate': interestRate,
    if (maturityAmount != null) 'maturityAmount': maturityAmount,
    if (maturityDate != null) 'maturityDate': maturityDate,
  };
}

class NotificationUnreadCounts {
  final int unreadCount;
  final int unreadSmsCount;
  final int unreadSystemCount;

  const NotificationUnreadCounts({
    this.unreadCount = 0,
    this.unreadSmsCount = 0,
    this.unreadSystemCount = 0,
  });

  factory NotificationUnreadCounts.fromJson(Map<String, dynamic> json) {
    return NotificationUnreadCounts(
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      unreadSmsCount: (json['unreadSmsCount'] as num?)?.toInt() ?? 0,
      unreadSystemCount: (json['unreadSystemCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'unreadCount': unreadCount,
    'unreadSmsCount': unreadSmsCount,
    'unreadSystemCount': unreadSystemCount,
  };
}

class NotificationCounts {
  final int all;
  final int unread;
  final int saved;
  final int sms;

  const NotificationCounts({
    this.all = 0,
    this.unread = 0,
    this.saved = 0,
    this.sms = 0,
  });

  factory NotificationCounts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationCounts();
    return NotificationCounts(
      all: (json['all'] as num?)?.toInt() ?? 0,
      unread: (json['unread'] as num?)?.toInt() ?? 0,
      saved: (json['saved'] as num?)?.toInt() ?? 0,
      sms: (json['sms'] as num?)?.toInt() ?? 0,
    );
  }

  NotificationCounts copyWith({
    int? all,
    int? unread,
    int? saved,
    int? sms,
  }) {
    return NotificationCounts(
      all: all ?? this.all,
      unread: unread ?? this.unread,
      saved: saved ?? this.saved,
      sms: sms ?? this.sms,
    );
  }

  Map<String, dynamic> toJson() => {
    'all': all,
    'unread': unread,
    'saved': saved,
    'sms': sms,
  };
}

class NotificationPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const NotificationPagination({
    this.total = 0,
    this.page = 1,
    this.limit = 50,
    this.totalPages = 1,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationPagination();
    return NotificationPagination(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 50,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
  };
}

class SmsIngestResult {
  final bool success;
  final bool alreadyIngested;
  final String message;
  final String? notificationId;
  final String? classification;
  final Map<String, dynamic>? entities;
  final NotificationRedirection? redirection;

  const SmsIngestResult({
    required this.success,
    this.alreadyIngested = false,
    this.message = '',
    this.notificationId,
    this.classification,
    this.entities,
    this.redirection,
  });

  factory SmsIngestResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return SmsIngestResult(
      success: json['success'] as bool? ?? true,
      alreadyIngested: json['alreadyIngested'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      notificationId: data?['notificationId']?.toString(),
      classification: data?['classification']?.toString(),
      entities: data?['entities'] as Map<String, dynamic>?,
      redirection: data?['redirection'] != null
          ? NotificationRedirection.fromJson(data!['redirection'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SmsBatchSyncSummary {
  final int totalReceived;
  final int ingested;
  final int duplicatesSkipped;
  final int creditsCount;
  final int debitsCount;
  final int fixedDepositsCount;

  const SmsBatchSyncSummary({
    this.totalReceived = 0,
    this.ingested = 0,
    this.duplicatesSkipped = 0,
    this.creditsCount = 0,
    this.debitsCount = 0,
    this.fixedDepositsCount = 0,
  });

  factory SmsBatchSyncSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SmsBatchSyncSummary();
    return SmsBatchSyncSummary(
      totalReceived: (json['totalReceived'] as num?)?.toInt() ?? 0,
      ingested: (json['ingested'] as num?)?.toInt() ?? 0,
      duplicatesSkipped: (json['duplicatesSkipped'] as num?)?.toInt() ?? 0,
      creditsCount: (json['creditsCount'] as num?)?.toInt() ?? 0,
      debitsCount: (json['debitsCount'] as num?)?.toInt() ?? 0,
      fixedDepositsCount: (json['fixedDepositsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class SmsBatchSyncResult {
  final bool success;
  final String message;
  final SmsBatchSyncSummary summary;
  final List<SmsIngestResult> data;

  const SmsBatchSyncResult({
    required this.success,
    this.message = '',
    this.summary = const SmsBatchSyncSummary(),
    this.data = const [],
  });

  factory SmsBatchSyncResult.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    final items = rawData
        .whereType<Map<String, dynamic>>()
        .map((item) => SmsIngestResult.fromJson({'success': true, 'data': item}))
        .toList();

    return SmsBatchSyncResult(
      success: json['success'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      summary: SmsBatchSyncSummary.fromJson(json['summary'] as Map<String, dynamic>?),
      data: items,
    );
  }
}

class NotificationListResponse {
  final List<AppNotification> notifications;
  final NotificationPagination pagination;
  final NotificationCounts counts;

  const NotificationListResponse({
    required this.notifications,
    required this.pagination,
    required this.counts,
  });
}

class AppNotification {
  final String id;
  final String? userId;
  final String? userMobile;
  final String? category;
  final String title;
  final String message;
  final String type; // Budget, KYC, Document, Account, Security, Payment, SMS, PROMOTION, etc.
  final String priority; // High, Info, Medium, Low
  final String timestamp;
  final String? createdAt;
  final String? updatedAt;
  final bool isRead;
  final bool isSaved;
  final bool isSms;
  final String? smsCategory; // 'Credit', 'Debit', 'Fixed Deposit', 'Promotion'
  final String? smsSender;
  final double? amount;
  final double? balance;
  final String? bankName;
  final String? accountDigits;
  final String? rawSms;
  final String? merchantOrSource;
  final String? referenceId;
  final String? classification;
  final String? actionUrl;
  final NotificationRedirection? redirection;
  final NotificationFdDetails? fdDetails;
  final Map<String, dynamic>? metadata;

  const AppNotification({
    required this.id,
    this.userId,
    this.userMobile,
    this.category,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.createdAt,
    this.updatedAt,
    this.isRead = false,
    this.isSaved = false,
    this.isSms = false,
    this.smsCategory,
    this.smsSender,
    this.amount,
    this.balance,
    this.bankName,
    this.accountDigits,
    this.rawSms,
    this.merchantOrSource,
    this.referenceId,
    this.classification,
    this.actionUrl,
    this.redirection,
    this.fdDetails,
    this.metadata,
  });

  bool get isCreditSms =>
      smsCategory?.toLowerCase() == 'credit' ||
      classification?.toLowerCase() == 'credit' ||
      type.toLowerCase() == 'credit' ||
      redirection?.route == '/income' ||
      redirection?.action == 'DETECTED_INFLOW_SHORTBOX' ||
      (rawSms != null &&
          (rawSms!.toLowerCase().contains('credit') ||
              rawSms!.toLowerCase().contains('deposited') ||
              rawSms!.toLowerCase().contains('received')));

  bool get isDebitSms =>
      smsCategory?.toLowerCase() == 'debit' ||
      classification?.toLowerCase() == 'debit' ||
      type.toLowerCase() == 'debit' ||
      redirection?.route == '/expenses' ||
      redirection?.action == 'DETECTED_OUTFLOW_SHORTBOX' ||
      (rawSms != null &&
          (rawSms!.toLowerCase().contains('debit') ||
              rawSms!.toLowerCase().contains('spent') ||
              rawSms!.toLowerCase().contains('paid')));

  bool get isFixedDepositSms =>
      smsCategory?.toLowerCase() == 'fixed deposit' ||
      classification?.toLowerCase() == 'fixed deposit' ||
      type.toLowerCase() == 'fixed deposit' ||
      redirection?.action == 'FIXED_DEPOSIT_MODAL' ||
      (rawSms != null &&
          (rawSms!.toLowerCase().contains('fixed deposit') ||
              rawSms!.toLowerCase().contains('fd ')));

  bool get isPromotionSms =>
      smsCategory?.toLowerCase() == 'promotion' ||
      classification?.toLowerCase() == 'promotion' ||
      type.toLowerCase() == 'promotion' ||
      type.toLowerCase() == 'promotion' ||
      redirection?.action == 'PROMOTION_OFFER' ||
      (rawSms != null &&
          (rawSms!.toLowerCase().contains('offer') ||
              rawSms!.toLowerCase().contains('cashback') ||
              rawSms!.toLowerCase().contains('discount')));

  factory AppNotification.fromJson(Map<String, dynamic> json, {String? defaultUserMobile}) {
    final meta = json['metadata'] as Map<String, dynamic>?;
    final entities = (json['entities'] ?? meta?['entities']) as Map<String, dynamic>?;

    final rawAmount = json['amount'] ?? entities?['amount'] ?? meta?['amount'];
    final rawBalance = json['balance'] ?? entities?['balance'] ?? meta?['balance'];
    final rawBankName = json['bankName'] ?? entities?['bankName'] ?? meta?['bankName'];
    final rawAccountDigits = json['accountDigits'] ?? entities?['accountDigits'] ?? meta?['accountDigits'];
    final rawMerchant = json['merchantOrSource'] ?? entities?['merchantOrSource'] ?? meta?['merchantOrSource'];
    final rawReferenceId = json['referenceId'] ?? entities?['referenceId'] ?? meta?['referenceId'];
    final rawClassification = json['classification'] ?? json['smsCategory'] ?? entities?['suggestedCategory'] ?? meta?['suggestedCategory'] ?? json['category'];
    final rawSms = json['smsRaw'] ?? json['rawSms'] ?? meta?['rawSms'] ?? json['body'];
    final rawSender = json['smsSender'] ?? json['sender'];
    final rawRedirection = json['redirection'] ?? meta?['redirection'];
    final rawFd = json['fdDetails'] ?? entities?['fdDetails'] ?? meta?['fdDetails'];

    // Format human timestamp if only createdAt is present
    String displayTime = json['timestamp']?.toString() ?? '';
    final createdAtStr = json['createdAt']?.toString();
    if (displayTime.isEmpty && createdAtStr != null && createdAtStr.isNotEmpty) {
      displayTime = _formatIsoTimestamp(createdAtStr);
    }
    if (displayTime.isEmpty) {
      displayTime = 'Just now';
    }

    // Determine isSms
    final bool isSmsFlag = json['isSms'] as bool? ??
        (rawSender != null && rawSender.toString().isNotEmpty) ||
        (json['type']?.toString().toUpperCase() == 'SMS') ||
        (json['type']?.toString().toUpperCase() == 'PROMOTION') ||
        (rawClassification != null && ['Credit', 'Debit', 'Fixed Deposit', 'Promotion'].contains(rawClassification));

    return AppNotification(
      id: (json['id'] ?? json['notificationId'])?.toString() ?? '',
      userId: json['userId']?.toString(),
      userMobile: json['userMobile']?.toString() ?? json['phone']?.toString() ?? defaultUserMobile,
      category: json['category']?.toString() ?? rawClassification?.toString(),
      title: json['title']?.toString() ?? (rawMerchant != null ? 'Alert • $rawMerchant' : 'Notification'),
      message: json['message']?.toString() ?? (rawSms?.toString() ?? ''),
      type: json['type']?.toString() ?? 'General',
      priority: json['priority']?.toString() ?? (meta?['suggestedPriority']?.toString() ?? 'Info'),
      timestamp: displayTime,
      createdAt: createdAtStr,
      updatedAt: json['updatedAt']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      isSms: isSmsFlag,
      smsCategory: rawClassification?.toString() ?? json['smsCategory']?.toString(),
      smsSender: rawSender?.toString(),
      amount: (rawAmount as num?)?.toDouble(),
      balance: (rawBalance as num?)?.toDouble(),
      bankName: rawBankName?.toString(),
      accountDigits: rawAccountDigits?.toString(),
      rawSms: rawSms?.toString(),
      merchantOrSource: rawMerchant?.toString(),
      referenceId: rawReferenceId?.toString(),
      classification: rawClassification?.toString(),
      actionUrl: json['actionUrl']?.toString(),
      redirection: rawRedirection is Map<String, dynamic>
          ? NotificationRedirection.fromJson(rawRedirection)
          : null,
      fdDetails: rawFd is Map<String, dynamic>
          ? NotificationFdDetails.fromJson(rawFd)
          : null,
      metadata: meta,
    );
  }

  static String _formatIsoTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 60) {
        return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24 && dt.day == now.day) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final minute = dt.minute.toString().padLeft(2, '0');
        return 'Today, $hour:$minute $ampm';
      } else if (diff.inDays <= 1 || (now.day - dt.day == 1 && diff.inHours < 48)) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final minute = dt.minute.toString().padLeft(2, '0');
        return 'Yesterday, $hour:$minute $ampm';
      } else {
        return '${dt.day.toString().padLeft(2, '0')}-${_shortMonth(dt.month)}-${dt.year}';
      }
    } catch (_) {
      return iso;
    }
  }

  static String _shortMonth(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (m >= 1 && m <= 12) return months[m - 1];
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      if (userMobile != null) 'userMobile': userMobile,
      if (category != null) 'category': category,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'timestamp': timestamp,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'isRead': isRead,
      'isSaved': isSaved,
      'isSms': isSms,
      if (smsCategory != null) 'smsCategory': smsCategory,
      if (smsSender != null) 'smsSender': smsSender,
      if (amount != null) 'amount': amount,
      if (balance != null) 'balance': balance,
      if (bankName != null) 'bankName': bankName,
      if (accountDigits != null) 'accountDigits': accountDigits,
      if (rawSms != null) 'rawSms': rawSms,
      if (merchantOrSource != null) 'merchantOrSource': merchantOrSource,
      if (referenceId != null) 'referenceId': referenceId,
      if (classification != null) 'classification': classification,
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (redirection != null) 'redirection': redirection!.toJson(),
      if (fdDetails != null) 'fdDetails': fdDetails!.toJson(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? userMobile,
    String? category,
    String? title,
    String? message,
    String? type,
    String? priority,
    String? timestamp,
    String? createdAt,
    String? updatedAt,
    bool? isRead,
    bool? isSaved,
    bool? isSms,
    String? smsCategory,
    String? smsSender,
    double? amount,
    double? balance,
    String? bankName,
    String? accountDigits,
    String? rawSms,
    String? merchantOrSource,
    String? referenceId,
    String? classification,
    String? actionUrl,
    NotificationRedirection? redirection,
    NotificationFdDetails? fdDetails,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userMobile: userMobile ?? this.userMobile,
      category: category ?? this.category,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      isSaved: isSaved ?? this.isSaved,
      isSms: isSms ?? this.isSms,
      smsCategory: smsCategory ?? this.smsCategory,
      smsSender: smsSender ?? this.smsSender,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      bankName: bankName ?? this.bankName,
      accountDigits: accountDigits ?? this.accountDigits,
      rawSms: rawSms ?? this.rawSms,
      merchantOrSource: merchantOrSource ?? this.merchantOrSource,
      referenceId: referenceId ?? this.referenceId,
      classification: classification ?? this.classification,
      actionUrl: actionUrl ?? this.actionUrl,
      redirection: redirection ?? this.redirection,
      fdDetails: fdDetails ?? this.fdDetails,
      metadata: metadata ?? this.metadata,
    );
  }
}

class NotificationPreferencesState {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final bool quietHoursEnabled;
  final String startTime;
  final String endTime;

  const NotificationPreferencesState({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
    this.quietHoursEnabled = false,
    this.startTime = '10:00 PM',
    this.endTime = '07:00 AM',
  });

  NotificationPreferencesState copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? quietHoursEnabled,
    String? startTime,
    String? endTime,
  }) {
    return NotificationPreferencesState(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class NotificationsState {
  final List<AppNotification> notifications;
  final NotificationPreferencesState preferences;
  final String selectedFilter; // All, SMS Notifications, Credits, Debits, Fixed Deposits, Promotions, Saved, Unread
  final bool isLoading;
  final String? errorMessage;
  final NotificationCounts? backendCounts;
  final NotificationPagination? pagination;

  const NotificationsState({
    required this.notifications,
    required this.preferences,
    this.selectedFilter = 'All',
    this.isLoading = false,
    this.errorMessage,
    this.backendCounts,
    this.pagination,
  });

  int get totalAlerts => backendCounts?.all ?? notifications.length;
  int get unreadCount => backendCounts?.unread ?? notifications.where((n) => !n.isRead).length;
  int get readCount => notifications.where((n) => n.isRead).length;
  int get savedCount => backendCounts?.saved ?? notifications.where((n) => n.isSaved).length;
  int get smsCount => backendCounts?.sms ?? notifications.where((n) => n.isSms).length;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    NotificationPreferencesState? preferences,
    String? selectedFilter,
    bool? isLoading,
    String? errorMessage,
    NotificationCounts? backendCounts,
    NotificationPagination? pagination,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      backendCounts: backendCounts ?? this.backendCounts,
      pagination: pagination ?? this.pagination,
    );
  }
}
