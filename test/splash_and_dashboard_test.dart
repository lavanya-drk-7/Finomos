import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/main.dart';
import 'package:finomos/core/services/cache_service.dart';
import 'package:finomos/features/dashboard/presentation/dashboard_screen.dart';

void main() {
  setUp(() {
    LocalCacheService().remove('user_liquid_cash_entries');
    LocalCacheService().remove('user_liquid_cash_amount');
    LocalCacheService().remove('is_logged_in');
    LocalCacheService().remove('auth_session');
  });

  tearDown(() {
    LocalCacheService().remove('user_liquid_cash_entries');
    LocalCacheService().remove('user_liquid_cash_amount');
    LocalCacheService().remove('is_logged_in');
    LocalCacheService().remove('auth_session');
  });

  testWidgets('Splash screen has no buttons and navigates to login after 3-second timeline', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FinomosApp(),
      ),
    );

    // Initial frame on splash screen
    await tester.pump();

    // Verify buttons are removed
    expect(find.text('Login (Registered User)'), findsNothing);
    expect(find.text('New User Registration'), findsNothing);
    expect(find.text('FINOMOS'), findsWidgets);

    // Advance virtual clock by 3 seconds
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Should have navigated to Login Screen (Image 2)
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login to your FINMOS account'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('DashboardScreen AppBar does not have a back arrow', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify back arrow icon is not present
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);

    // Verify dashboard content is present
    expect(find.text('Finomos Financial OS'), findsOneWidget);
  });

  testWidgets('DashboardScreen AI Personal CFO section displays Total Available Balance and Liquid Cash Balance', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      LocalCacheService().remove('bank_accounts');
    });

    LocalCacheService().save('bank_accounts', [
      {
        'id': 'bank_1',
        'bankName': 'State Bank of India',
        'accountNumber': '••••4821',
        'accountType': 'Savings',
        'balance': 142850.00,
        'status': 'Active',
        'lastSynced': 'Just now',
      },
      {
        'id': 'bank_2',
        'bankName': 'HDFC Bank',
        'accountNumber': '••••9104',
        'accountType': 'Salary',
        'balance': 75900.00,
        'status': 'Active',
        'lastSynced': '5 mins ago',
      },
    ]);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify health badge is kept, while removed header elements are gone
    expect(find.text('HEALTH: 88/100'), findsOneWidget);
    expect(find.text('AI PERSONAL CFO'), findsNothing);
    expect(find.text('Virtual Digital Twin & Autopilot Active'), findsNothing);
    expect(find.textContaining('Runway: 8.5 Mos'), findsNothing);

    // Verify Total Available Balance in Accounts
    expect(find.text('Total Available Balance'), findsOneWidget);
    expect(find.text('In Connected Accounts'), findsOneWidget);
    expect(find.text('₹2,18,750'), findsWidgets); // Both in AI CFO card and Bank Feeds tile

    // Verify Liquid Cash Balance (down from Available Balance)
    expect(find.text('Liquid Cash Balance'), findsOneWidget);
    expect(find.textContaining('Instant Access'), findsOneWidget);
    expect(find.text('₹0'), findsWidgets);

    // Verify Launch AI CFO Copilot button is removed, but account sync badge is present
    expect(find.text('Launch AI CFO Copilot'), findsNothing);
    expect(find.text('2 Accounts Synced'), findsOneWidget);
  });
}
