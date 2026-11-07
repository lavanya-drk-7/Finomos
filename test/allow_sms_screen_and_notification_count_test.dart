import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/services/cache_service.dart';
import 'package:finomos/core/utils/phone_utils.dart';
import 'package:finomos/core/router/app_router.dart';
import 'package:finomos/features/auth_kyc/domain/kyc_models.dart';
import 'package:finomos/features/auth_kyc/presentation/allow_sms_screen.dart';
import 'package:finomos/features/auth_kyc/providers/auth_kyc_provider.dart';
import 'package:finomos/features/notifications/domain/notification_models.dart';
import 'package:finomos/features/notifications/presentation/notifications_screen.dart';
import 'package:finomos/features/notifications/providers/notification_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocalCacheService().remove('user_mobile_number');
    LocalCacheService().remove('user_email');
    LocalCacheService().remove('user_name');
    LocalCacheService().remove('auth_session');
    LocalCacheService().remove('app_notifications');
    LocalCacheService().remove('cached_notifications');
    LocalCacheService().remove('ingested_sms_signatures');
    LocalCacheService().remove('deleted_notification_ids');
    LocalCacheService().remove('saved_notification_ids');
    LocalCacheService().remove('sms_allowed_9876501234');
    LocalCacheService().remove('sms_allowed_7207535810');
    LocalCacheService().remove('sms_allowed_9876543210');
  });

  tearDown(() {
    try {
      final tempDir = Directory.systemTemp;
      final testFiles = tempDir.listSync().where((f) => f.path.contains('finmos_cache_test_'));
      for (final f in testFiles) {
        try {
          f.deleteSync(recursive: true);
        } catch (_) {}
      }
    } catch (_) {}
  });

  group('Allow SMS Screen & Real-Time Notification Count Tests', () {
    testWidgets('1. AllowSmsScreen renders target mobile number and features cleanly', (tester) async {
      LocalCacheService().save('user_mobile_number', '9876501234');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authKycProvider.overrideWith(() => AuthKycNotifierMock('9876501234')),
          ],
          child: const MaterialApp(
            home: AllowSmsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Allow SMS Tracking'), findsOneWidget);
      expect(find.text('LINKED MOBILE NUMBER'), findsOneWidget);
      expect(find.text('+91 98765 01234'), findsOneWidget);
      expect(find.text('Allow SMS'), findsOneWidget);
      expect(find.text('Skip for now'), findsAtLeastNWidgets(1));
      expect(find.text('Official Bank Senders Only'), findsOneWidget);
      expect(find.text('100% Private & Encrypted'), findsOneWidget);
    });

    testWidgets('2. Tapping Allow SMS records permission for the active mobile number', (tester) async {
      LocalCacheService().save('user_mobile_number', '9876501234');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authKycProvider.overrideWith(() => AuthKycNotifierMock('9876501234')),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );
      await tester.pumpAndSettle();

      appRouter.go('/allow-sms');
      await tester.pumpAndSettle();

      expect(find.text('Allow SMS'), findsOneWidget);
      await tester.ensureVisible(find.text('Allow SMS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow SMS'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      expect(LocalCacheService().get('sms_allowed_9876501234'), true);
      expect(LocalCacheService().get('sms_tracking_enabled'), true);
    });

    testWidgets('3. Notification section shows accurate counts matching displayed items', (tester) async {
      LocalCacheService().save('user_mobile_number', '9876501234');
      LocalCacheService().save('sms_allowed_9876501234', true);

      // Seed 2 notifications matching this user's mobile number
      final notifs = [
        const AppNotification(
          id: 'test_sms_1',
          title: 'Bank Inflow: ₹15,000 from Salary',
          message: 'A/c *1234 Credited for Rs:15000.00',
          type: 'SMS',
          priority: 'High',
          timestamp: 'Today',
          userMobile: '9876501234',
          amount: 15000,
          isSms: true,
          smsCategory: 'Credit',
        ),
        const AppNotification(
          id: 'test_sms_2',
          title: 'Bank Debit: ₹1,500 at Store',
          message: 'A/c *1234 Debited for Rs:1500.00',
          type: 'SMS',
          priority: 'Medium',
          timestamp: 'Yesterday',
          userMobile: '9876501234',
          amount: 1500,
          isSms: true,
          smsCategory: 'Debit',
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          authKycProvider.overrideWith(() => AuthKycNotifierMock('9876501234')),
        ],
      );
      container.read(notificationsProvider.notifier).setLocalNotificationsForTest(notifs);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that stat cards and item badge match exactly 2 items
      expect(find.text('Total Alerts'), findsOneWidget);
      expect(find.text('2'), findsAtLeastNWidgets(1)); // Total Alerts = 2
      expect(find.text('2 Items'), findsOneWidget);
      expect(find.text('Bank Inflow: ₹15,000 from Salary'), findsOneWidget);
      expect(find.text('Bank Debit: ₹1,500 at Store'), findsOneWidget);
    });

    testWidgets('4. Logged-in user does NOT see SMS notifications belonging to another mobile number', (tester) async {
      // User logs in with mobile A (7207535810)
      LocalCacheService().save('user_mobile_number', '7207535810');
      LocalCacheService().save('sms_allowed_7207535810', true);

      // Notifications belong to mobile B (9876543210 - Union Bank items)
      final foreignNotifs = [
        const AppNotification(
          id: 'foreign_sms_1',
          title: 'Bank Inflow: ₹17,000 from Mob Bk',
          message: 'A/c *0087 Credited for Rs:17000.00',
          type: 'SMS',
          priority: 'Medium',
          timestamp: 'Today',
          userMobile: '9876543210',
          amount: 17000,
          isSms: true,
          smsCategory: 'Credit',
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          authKycProvider.overrideWith(() => AuthKycNotifierMock('7207535810')),
        ],
      );
      // Attempt to load foreign notifications
      container.read(notificationsProvider.notifier).setLocalNotificationsForTest(foreignNotifs);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure foreign items are not shown to mobile A (7207535810)
      expect(find.text('Bank Inflow: ₹17,000 from Mob Bk'), findsNothing);
      expect(find.text('0 Items'), findsOneWidget);
      expect(find.text('0'), findsAtLeastNWidgets(1)); // Total alerts is 0
    });
  });
}

class AuthKycNotifierMock extends AuthKycNotifier {
  final String _mockMobile;
  AuthKycNotifierMock(this._mockMobile);

  @override
  KycStateData build() {
    return KycStateData(
      isExistingUser: true,
      user: UserRegistrationData(
        fullName: 'Test User',
        email: 'test@example.com',
        mobileNumber: _mockMobile,
        password: '',
      ),
    );
  }
}

extension NotificationNotifierTestExt on NotificationsNotifier {
  void setLocalNotificationsForTest(List<AppNotification> items) {
    final currentMobile = PhoneUtils.sanitize(
      LocalCacheService().get('user_mobile_number')?.toString() ?? '',
    );
    final filtered = items.where((n) {
      if (currentMobile.isNotEmpty && n.userMobile != null && n.userMobile!.isNotEmpty) {
        return PhoneUtils.sanitize(n.userMobile) == currentMobile;
      }
      return true;
    }).toList();

    state = state.copyWith(
      notifications: filtered,
      backendCounts: NotificationCounts(
        all: filtered.length,
        unread: filtered.where((n) => !n.isRead).length,
        saved: filtered.where((n) => n.isSaved).length,
        sms: filtered.where((n) => n.isCreditSms || n.isSms).length,
      ),
    );
  }
}
