import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/profile/presentation/profile_management_screen.dart';

void main() {
  testWidgets('ProfileManagementScreen renders without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileManagementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify key titles and content are rendered properly on screen
    expect(find.text('Profile Management'), findsOneWidget);
    expect(find.text('Sireesha', skipOffstage: false), findsAtLeastNWidgets(1));
    expect(find.text('Personal Information', skipOffstage: false), findsOneWidget);
    expect(find.text('Contact Information', skipOffstage: false), findsOneWidget);
    expect(find.text('Address Information', skipOffstage: false), findsOneWidget);
    expect(find.text('Employment & Income Details', skipOffstage: false), findsOneWidget);
    expect(find.text('The 7 Financial Pillars of PFOS', skipOffstage: false), findsOneWidget);
    expect(find.text('Financial Account Aggregation', skipOffstage: false), findsOneWidget);
    expect(find.text('AI Personal CFO & Financial Autopilot', skipOffstage: false), findsOneWidget);
    expect(find.text('Document Vault', skipOffstage: false), findsOneWidget);
    expect(find.text('Security Settings', skipOffstage: false), findsOneWidget);
    expect(find.text('Communication Preferences', skipOffstage: false), findsOneWidget);

    // Test filter pill tap to 7 Pillars
    await tester.tap(find.text('7 Pillars of PFOS'));
    await tester.pumpAndSettle();
    expect(find.text('The 7 Financial Pillars of PFOS', skipOffstage: false), findsOneWidget);

    // Test filter pill tap back to All Modules
    await tester.tap(find.text('All Modules'));
    await tester.pumpAndSettle();
    expect(find.text('Personal Information', skipOffstage: false), findsOneWidget);
  });
}
