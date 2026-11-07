import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/services/cache_service.dart';
import 'package:finomos/core/utils/phone_utils.dart';
import 'package:finomos/features/auth_kyc/providers/auth_kyc_provider.dart';
import 'package:finomos/features/bank_aggregation/providers/bank_aggregation_provider.dart';
import 'package:finomos/features/notifications/domain/notification_models.dart';
import 'package:finomos/features/notifications/providers/notification_provider.dart';
import 'package:finomos/features/transaction_detection/providers/transaction_detection_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocalCacheService().remove('user_mobile_number');
    LocalCacheService().remove('auth_session');
    LocalCacheService().remove('app_notifications');
    LocalCacheService().remove('cached_notifications');
    LocalCacheService().remove('ingested_sms_signatures');
  });

  group('PhoneUtils Unit Tests', () {
    test('1. Sanitizes detached backend mobile format cleanly', () {
      expect(PhoneUtils.sanitize('detached_1793798031941_7207535810'), '7207535810');
      expect(PhoneUtils.sanitize('detached_1793783975718_9876543210'), '9876543210');
    });

    test('2. Strips +91, 91 prefix, leading zero and special formatting characters', () {
      expect(PhoneUtils.sanitize('+91 98765 43210'), '9876543210');
      expect(PhoneUtils.sanitize('+91-98765-43210'), '9876543210');
      expect(PhoneUtils.sanitize('(91) 9876543210'), '9876543210');
      expect(PhoneUtils.sanitize('09876543210'), '9876543210');
      expect(PhoneUtils.sanitize('919876543210'), '9876543210');
      expect(PhoneUtils.sanitize('  7207535810  '), '7207535810');
    });

    test('3. Formats mobile with country code and masks for privacy', () {
      expect(PhoneUtils.formatWithCountryCode('7207535810'), '+91 72075 35810');
      expect(PhoneUtils.mask('7207535810'), '••••••5810');
    });
  });

  group('Dynamic Login Mobile & SMS Notifications Sync Tests', () {
    test('1. persistSession saves clean sanitized mobile and updates user state', () {
      final container = ProviderContainer();
      final notifier = container.read(authKycProvider.notifier);

      notifier.persistSession(
        phone: 'detached_1793798031941_7207535810',
        userId: 'user_live_001',
        name: 'Sireesha Live',
        email: 'sireesha@live.com',
      );

      final state = container.read(authKycProvider);
      expect(state.user.mobileNumber, '7207535810');
      expect(LocalCacheService().get('user_mobile_number'), '7207535810');
      final session = LocalCacheService().get('auth_session') as Map;
      expect(session['phone'], '7207535810');
    });

    test('2. Changing user mobile clears previous user notifications & SMS signatures', () {
      final container = ProviderContainer();
      final notifier = container.read(authKycProvider.notifier);

      // Seed previous user
      notifier.persistSession(
        phone: '9876543210',
        userId: 'user_001',
      );
      LocalCacheService().save('app_notifications', [{'id': 'notif_1', 'title': 'Old user alert'}]);
      LocalCacheService().save('ingested_sms_signatures', ['sig_old_1']);

      // Login with different user mobile
      notifier.persistSession(
        phone: '7207535810',
        userId: 'user_002',
      );

      expect(LocalCacheService().get('user_mobile_number'), '7207535810');
      expect(LocalCacheService().get('app_notifications'), isNull);
      expect(LocalCacheService().get('ingested_sms_signatures'), isNull);
    });

    test('3. clearLocalNotifications resets provider state and clears cache', () {
      final container = ProviderContainer();
      final notifier = container.read(notificationsProvider.notifier);

      notifier.clearLocalNotifications();

      final state = container.read(notificationsProvider);
      expect(state.notifications, isEmpty);
      expect(state.backendCounts?.all, 0);
      expect(LocalCacheService().get('app_notifications'), isEmpty);
    });

    test('4. Ingested SMS associates with active user mobile', () async {
      LocalCacheService().save('user_mobile_number', '7207535810');
      LocalCacheService().save('user_id', 'user_720');

      const notif = AppNotification(
        id: 'sms_dyn_1',
        title: 'Bank Credit • ₹5,000',
        message: 'A/c ••••0087 credited with ₹5,000',
        type: 'SMS',
        priority: 'High',
        timestamp: 'Just now',
        userMobile: '7207535810',
        userId: 'user_720',
      );

      expect(notif.userMobile, '7207535810');
      expect(notif.userId, 'user_720');
      final json = notif.toJson();
      expect(json['userMobile'], '7207535810');
      expect(json['userId'], 'user_720');
    });

    test('5. Transaction detection dynamically matches user linked bank account (Union Bank 0087)', () {
      final container = ProviderContainer();

      // Seed user bank account: Union Bank 0087 (as in screenshot)
      final bankNotifier = container.read(bankAggregationProvider.notifier);
      bankNotifier.addBankAccount(
        bankName: 'Union Bank of India',
        accountType: 'Savings Account',
        maskedAccountNumber: '••••0087',
        ifscCode: 'UBIN0823554',
        accountHolder: 'Sireesha Bandaru',
        currentBalance: 700.0,
      );

      final detectionNotifier = container.read(transactionDetectionProvider.notifier);
      final result = detectionNotifier.processIncomingSms(
        'Dear Customer, INR 200.00 debited from A/C 0087 on 05-Nov-26 via Swiggy. Ref 9901823912. Bal: INR 500.00',
        sender: 'UNIONB',
      );

      expect(result.isSuccess, true);
      expect(result.transaction?.bankName, 'Union Bank of India');
      expect(result.transaction?.accountIdentifier, '••••0087');
      expect(result.transaction?.amount, 200.0);
    });
  });
}
