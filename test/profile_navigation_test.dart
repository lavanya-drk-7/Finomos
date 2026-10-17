import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/router/app_router.dart';
import 'package:finomos/features/profile/presentation/sub_screens/security_settings_sub_screen.dart';
import 'package:finomos/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('SecuritySettingsSubScreen renders without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SecuritySettingsSubScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Security & Login'), findsOneWidget);
    expect(find.text('Two-Factor Authentication (2FA)'), findsOneWidget);
    expect(find.text('Change Account Password'), findsOneWidget);
  });

  testWidgets('SettingsScreen renders without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Settings & Preferences'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
  });

  testWidgets('AppRouter navigates to all 5 target screens', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to /profile
    appRouter.go('/profile');
    await tester.pumpAndSettle();
    expect(find.text('Sireesha'), findsAtLeastNWidgets(1));

    // 1. Navigate to /profile/security
    appRouter.go('/profile/security');
    await tester.pumpAndSettle();
    expect(find.text('Security & Login'), findsOneWidget);

    // 2. Navigate to /profile-management
    appRouter.go('/profile-management');
    await tester.pumpAndSettle();
    expect(find.text('Profile Management'), findsOneWidget);

    // 3. Navigate to /document-vault
    appRouter.go('/document-vault');
    await tester.pumpAndSettle();
    expect(find.text('Document Vault'), findsOneWidget);

    // 4. Navigate to /bank-aggregation
    appRouter.go('/bank-aggregation');
    await tester.pumpAndSettle();
    expect(find.text('Bank Account Aggregation'), findsOneWidget);

    // 5. Navigate to /settings
    appRouter.go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('Settings & Preferences'), findsOneWidget);
  });

  testWidgets('DashboardScreen profile icon sheet displays 2 options and opens sub-sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/dashboard');
    await tester.pumpAndSettle();

    // Tap the Profile icon in top header action bar
    final profileIconButton = find.byTooltip('Profile & Settings');
    expect(profileIconButton, findsOneWidget);
    await tester.tap(profileIconButton);
    await tester.pumpAndSettle();

    // Verify 3 options are displayed initially
    expect(find.text('Profile Options'), findsOneWidget);
    expect(find.text('Personal Profile'), findsOneWidget);
    expect(find.text('Account Settings'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    // Tap Option 1: Personal Profile
    await tester.tap(find.text('Personal Profile'));
    await tester.pumpAndSettle();

    // Verify Personal Profile 4 sub-sections display
    expect(find.text('Personal Information & Identity'), findsOneWidget);
    expect(find.text('Address & Residence Details'), findsOneWidget);
    expect(find.text('Employment & Income Details'), findsOneWidget);
    expect(find.text('Family & Household Management'), findsOneWidget);

    // Tap Back icon
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Tap Option 2: Account Settings
    await tester.tap(find.text('Account Settings'));
    await tester.pumpAndSettle();

    // Verify Account Settings 4 sub-sections display
    expect(find.text('Security & Login Settings'), findsOneWidget);
    expect(find.text('Communication Preferences'), findsOneWidget);
    expect(find.text('Bank Accounts & Aggregation'), findsOneWidget);
    expect(find.text('App Settings & Support'), findsOneWidget);

    // Tap a sub-section to navigate
    await tester.ensureVisible(find.text('Security & Login Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Security & Login Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Security & Login'), findsOneWidget);
  });

  testWidgets('DashboardScreen profile drawer Logout option displays confirmation and logs out to login route', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/dashboard');
    await tester.pumpAndSettle();

    // Open profile drawer
    final profileIconButton = find.byTooltip('Profile & Settings');
    await tester.tap(profileIconButton);
    await tester.pumpAndSettle();

    // Verify Logout option is present
    final logoutFinder = find.text('Logout');
    expect(logoutFinder, findsOneWidget);

    // Tap Logout button
    await tester.tap(logoutFinder);
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Confirm Logout'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel first to ensure dialog can be dismissed
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Logout'), findsNothing);

    // Tap Logout again
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Now confirm logout on the dialog
    final confirmLogoutBtn = find.widgetWithText(ElevatedButton, 'Logout');
    expect(confirmLogoutBtn, findsOneWidget);
    await tester.tap(confirmLogoutBtn);
    await tester.pumpAndSettle();

    // Expect navigated to login screen
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
