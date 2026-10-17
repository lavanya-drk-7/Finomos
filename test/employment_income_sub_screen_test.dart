import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/profile/presentation/sub_screens/employment_income_sub_screen.dart';

void main() {
  testWidgets('EmploymentIncomeSubScreen renders and dynamically updates fields for dropdown options including Others', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EmploymentIncomeSubScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state (Salaried)
    expect(find.text('Employment & Income'), findsOneWidget);
    expect(find.text('Salaried'), findsOneWidget);
    expect(find.text('Company / Organization Name'), findsOneWidget);
    expect(find.text('Designation / Job Role'), findsOneWidget);

    // Open Employment Type dropdown
    await tester.tap(find.text('Salaried'));
    await tester.pumpAndSettle();

    // Verify 'Others' option is present in the dropdown items
    expect(find.text('Others'), findsOneWidget);

    // Select 'Others'
    await tester.tap(find.text('Others').last);
    await tester.pumpAndSettle();

    // Verify dynamic fields for 'Others' are displayed
    expect(find.text('Specify Occupation / Activity'), findsOneWidget);
    expect(find.text('Entity / Source Name'), findsOneWidget);
    expect(find.text('Years / Experience Duration'), findsOneWidget);
    expect(find.text('Primary Location'), findsOneWidget);

    // Open Employment Type dropdown again and select 'Business Owner'
    await tester.tap(find.text('Others').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Business Owner').last);
    await tester.pumpAndSettle();

    // Verify dynamic fields for 'Business Owner' are displayed
    expect(find.text('Business / Enterprise Name'), findsOneWidget);
    expect(find.text('Industry / Sector'), findsOneWidget);
    expect(find.text('Annual Business Turnover / Revenue'), findsOneWidget);
  });
}
