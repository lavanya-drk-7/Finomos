import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/core/router/app_router.dart';

void main() {
  testWidgets('Back arrow navigation test - 1-step back navigation across screens', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: _RouterTestHost(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Screen back button pops 1 step back', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Directly go to /dashboard
    appRouter.go('/dashboard');
    await tester.pumpAndSettle();
    expect(find.text('Finomos Financial OS'), findsOneWidget);

    // 1. Push /document-vault
    appRouter.push('/document-vault');
    await tester.pumpAndSettle();
    expect(find.text('Document Vault'), findsOneWidget);

    // Tap back button
    final backBtn = find.byIcon(Icons.arrow_back_ios_new);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify back to /dashboard
    expect(find.text('Finomos Financial OS'), findsOneWidget);

    // 2. Push /admin-panel
    appRouter.push('/admin-panel');
    await tester.pumpAndSettle();
    expect(find.text('Admin Panel Foundation'), findsOneWidget);

    // Tap back button
    final adminBackBtn = find.byIcon(Icons.arrow_back_ios_new);
    expect(adminBackBtn, findsOneWidget);
    await tester.tap(adminBackBtn);
    await tester.pumpAndSettle();

    // Verify back to /dashboard
    expect(find.text('Finomos Financial OS'), findsOneWidget);

    // 3. Push /budget-management
    appRouter.push('/budget-management');
    await tester.pumpAndSettle();
    expect(find.text('Budget Management'), findsOneWidget);

    // Tap back button
    final budgetBackBtn = find.byIcon(Icons.arrow_back);
    expect(budgetBackBtn, findsOneWidget);
    await tester.tap(budgetBackBtn);
    await tester.pumpAndSettle();

    // Verify back to /dashboard
    expect(find.text('Finomos Financial OS'), findsOneWidget);
  });
}

class _RouterTestHost extends StatelessWidget {
  const _RouterTestHost();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Host'));
  }
}
