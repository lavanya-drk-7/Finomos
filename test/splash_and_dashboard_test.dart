import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/main.dart';
import 'package:finomos/core/router/app_router.dart';
import 'package:finomos/features/splash/presentation/splash_screen.dart';
import 'package:finomos/features/dashboard/presentation/dashboard_screen.dart';

void main() {
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
}
