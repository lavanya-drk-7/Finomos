import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finomos/core/services/cache_service.dart';
import 'package:finomos/features/auth_kyc/providers/auth_kyc_provider.dart';
import 'package:finomos/features/splash/presentation/splash_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/login_screen.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Session Persistence & Cold-Launch Routing Tests', () {
    setUp(() {
      LocalCacheService().remove('is_logged_in');
      LocalCacheService().remove('auth_session');
    });

    tearDown(() {
      LocalCacheService().remove('is_logged_in');
      LocalCacheService().remove('auth_session');
      LocalCacheService().remove('bank_accounts');
      LocalCacheService().remove('income_entries');
      LocalCacheService().remove('expenses_entries');
      LocalCacheService().remove('user_liquid_cash_amount');
    });

    test('1. isSessionActive returns false initially when not logged in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authKycProvider.notifier);
      expect(notifier.isSessionActive(), isFalse);
    });

    test('2. persistSession saves state to cache and isSessionActive becomes true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authKycProvider.notifier);
      notifier.persistSession(
        token: 'jwt-test-token-12345',
        userId: 'user_100',
        name: 'Sireesha Bandaru',
        phone: '7207535810',
      );

      expect(notifier.isSessionActive(), isTrue);
      final cached = LocalCacheService().get('auth_session');
      expect(cached, isNotNull);
      expect(cached['isLoggedIn'], isTrue);
      expect(cached['phone'], '7207535810');
      expect(cached['token'], 'jwt-test-token-12345');
    });

    test('3. logout clears persisted session and isSessionActive becomes false', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authKycProvider.notifier);
      notifier.persistSession(
        token: 'jwt-test-token-12345',
        phone: '7207535810',
      );
      expect(notifier.isSessionActive(), isTrue);

      await notifier.logout();

      expect(notifier.isSessionActive(), isFalse);
      expect(LocalCacheService().get('is_logged_in'), isFalse);
      expect(LocalCacheService().get('auth_session'), isNull);
    });

    testWidgets('4. SplashScreen routes to /dashboard when session is active', (WidgetTester tester) async {
      LocalCacheService().save('is_logged_in', true);
      LocalCacheService().save('auth_session', {
        'isLoggedIn': true,
        'token': 'jwt-token-active',
        'phone': '7207535810',
      });

      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
          GoRoute(path: '/dashboard', builder: (_, __) => const Scaffold(body: Text('DASHBOARD_SCREEN'))),
          GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('LOGIN_SCREEN'))),
        ],
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Verify splash screen renders FINOMOS
      expect(find.text('FINOMOS'), findsOneWidget);
      expect(container.read(authKycProvider.notifier).isSessionActive(), isTrue);

      // Advance 3-second splash timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Verify navigated to dashboard!
      expect(find.text('DASHBOARD_SCREEN'), findsOneWidget);
    });

    testWidgets('5. SplashScreen routes to /login when user is logged out', (WidgetTester tester) async {
      LocalCacheService().save('is_logged_in', false);
      LocalCacheService().remove('auth_session');

      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
          GoRoute(path: '/dashboard', builder: (_, __) => const Scaffold(body: Text('DASHBOARD_SCREEN'))),
          GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('LOGIN_SCREEN'))),
        ],
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('FINOMOS'), findsOneWidget);
      expect(container.read(authKycProvider.notifier).isSessionActive(), isFalse);

      // Advance 3-second splash timer
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Verify navigated to login!
      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
    });

    test('6. logout preserves existing user internal data (income, expense, bank accounts, liquid cash)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Seed internal data for existing user
      LocalCacheService().save('bank_accounts', [{'id': 'acc_1', 'bankName': 'HDFC Bank', 'availableBalance': 50000.0}]);
      LocalCacheService().save('income_entries', {'entries': [{'id': 'inc_1', 'amount': 85000.0, 'source': 'Salary'}]});
      LocalCacheService().save('expenses_entries', {'entries': [{'id': 'exp_1', 'amount': 4500.0, 'description': 'Groceries'}]});
      LocalCacheService().save('user_liquid_cash_amount', 15000.0);

      final notifier = container.read(authKycProvider.notifier);
      notifier.persistSession(
        token: 'jwt-test-token-12345',
        userId: 'user_sireesha',
        phone: '7207535810',
      );

      // User performs logout
      await notifier.logout();

      // Session is revoked and marked logged out
      expect(notifier.isSessionActive(), isFalse);
      expect(LocalCacheService().get('is_logged_in'), isFalse);
      expect(LocalCacheService().get('auth_session'), isNull);

      // Existing user's internal data remains intact
      expect(LocalCacheService().get('bank_accounts'), isNotNull);
      expect(LocalCacheService().get('income_entries'), isNotNull);
      expect(LocalCacheService().get('expenses_entries'), isNotNull);
      expect(LocalCacheService().get('user_liquid_cash_amount'), 15000.0);
    });
    testWidgets('7. LoginScreen initializes with completely blank Mobile Number field', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final mobileField = find.widgetWithText(TextFormField, 'Mobile Number');
      expect(mobileField, findsOneWidget);

      final formField = tester.widget<TextFormField>(mobileField);
      expect(formField.controller?.text, isEmpty);
    });

    testWidgets('8. LoginScreen does NOT render Live API User Switcher', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LIVE API USER SWITCHER'), findsNothing);
      expect(find.text('Sireesha'), findsNothing);
      expect(find.text('Live Streams'), findsNothing);
      expect(find.text('Keerthi'), findsNothing);
      expect(find.text('Fresh Profile'), findsNothing);
    });
  });
}
