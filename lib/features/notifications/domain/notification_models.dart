class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // Budget, KYC, Document, Account, Security, Payment
  final String priority; // High, Info, Medium, Low
  final String timestamp;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? priority,
    String? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
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
  final String selectedFilter; // All, Alerts, Transactions, Account, Security

  const NotificationsState({
    required this.notifications,
    required this.preferences,
    this.selectedFilter = 'All',
  });

  int get totalAlerts => notifications.length;
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  int get readCount => notifications.where((n) => n.isRead).length;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    NotificationPreferencesState? preferences,
    String? selectedFilter,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}
