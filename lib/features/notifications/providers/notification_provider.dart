import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/notification_models.dart';

class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    return const NotificationsState(
      notifications: [
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
      ],
      preferences: NotificationPreferencesState(),
    );
  }

  void markAsRead(String id) {
    final updated = state.notifications.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    state = state.copyWith(notifications: updated);
  }

  void markAllAsRead() {
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  void updatePreferences(NotificationPreferencesState prefs) {
    state = state.copyWith(preferences: prefs);
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final notificationsProvider = NotifierProvider<NotificationsNotifier, NotificationsState>(() {
  return NotificationsNotifier();
});
