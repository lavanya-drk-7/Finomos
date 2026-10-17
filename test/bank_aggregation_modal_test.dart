import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/bank_aggregation/presentation/bank_aggregation_screen.dart';

void main() {
  testWidgets('Test Add Bank, Add Credit Card and Add UPI modals and interactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(380, 840);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BankAggregationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify + Link Bank button and open modal
    final linkBankBtn = find.text('Link Bank');
    expect(linkBankBtn, findsOneWidget);
    await tester.tap(linkBankBtn);
    await tester.pumpAndSettle();

    // Verify Link Bank modal content & options
    expect(find.text('Link Bank Account'), findsOneWidget);
    expect(find.text('Select Financial Institution / Bank'), findsOneWidget);
    expect(find.text('Account Type'), findsOneWidget);
    expect(find.text('Bank Account Number'), findsOneWidget);
    expect(find.text('Branch IFSC Code'), findsOneWidget);
    expect(find.text('Verify & Link Bank Account'), findsOneWidget);

    // Tap Verify & Link Bank Account
    await tester.tap(find.text('Verify & Link Bank Account'));
    await tester.pumpAndSettle();

    // Verify modal closed & snackbar appeared
    expect(find.textContaining('linked successfully!'), findsOneWidget);

    // 2. Test + Add UPI button and open modal
    final addUpiBtn = find.text('Add UPI');
    await tester.ensureVisible(addUpiBtn);
    await tester.pumpAndSettle();
    expect(addUpiBtn, findsOneWidget);
    await tester.tap(addUpiBtn);
    await tester.pumpAndSettle();

    expect(find.text('Link New UPI Account & VPA'), findsOneWidget);
    expect(find.text('UPI ID (Virtual Payment Address)'), findsOneWidget);
    expect(find.text('UPI App Provider'), findsOneWidget);
    expect(find.text('Underlying Linked Bank Account'), findsOneWidget);

    // Submit UPI
    await tester.tap(find.text('Verify & Link UPI ID'));
    await tester.pumpAndSettle();
    expect(find.textContaining('linked successfully!'), findsOneWidget);

    // 3. Test + Add Card button in Credit Cards section
    final addCardBtn = find.text('Add Card');
    await tester.ensureVisible(addCardBtn);
    await tester.pumpAndSettle();
    expect(addCardBtn, findsOneWidget);
    await tester.tap(addCardBtn);
    await tester.pumpAndSettle();

    // Verify Add Credit Card modal content & options
    expect(find.text('Add Credit Card'), findsOneWidget);
    expect(find.text('Credit Card Issuer & Variant'), findsOneWidget);
    expect(find.text('Last 4 Digits'), findsOneWidget);
    expect(find.text('Total Limit (₹)'), findsOneWidget);
    expect(find.text('Outstanding (₹)'), findsOneWidget);
    final submitCardBtn = find.text('Add Credit Card to Portfolio');
    await tester.ensureVisible(submitCardBtn);
    await tester.pumpAndSettle();
    expect(submitCardBtn, findsOneWidget);

    // Submit Card
    await tester.tap(submitCardBtn);
    await tester.pumpAndSettle();
    expect(find.textContaining('added to Credit Cards!'), findsOneWidget);
  });

  testWidgets('Test Add Credit Card modal displays Other Credit Card field only when Other Credit Card is selected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(380, 840);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BankAggregationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open Add Card modal
    final addCardBtn = find.text('Add Card');
    await tester.ensureVisible(addCardBtn);
    await tester.pumpAndSettle();
    await tester.tap(addCardBtn);
    await tester.pumpAndSettle();

    expect(find.text('Add Credit Card'), findsOneWidget);

    // 1. Initially, other card name field must NOT be visible
    expect(find.text('Other Credit Card Name & Variant'), findsNothing);

    // 2. Select 'Other Credit Card' from dropdown
    await tester.tap(find.text('HDFC Regalia Gold').last);
    await tester.pumpAndSettle();

    final dropdownFinder = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.text('Other Credit Card'),
      100,
      scrollable: dropdownFinder,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other Credit Card').last);
    await tester.pumpAndSettle();

    // 3. Now the 'Other Credit Card Name & Variant' text field MUST be visible!
    expect(find.text('Other Credit Card Name & Variant'), findsOneWidget);

    // 4. Try submitting while custom card name field is empty -> should show error
    final submitCardBtn = find.text('Add Credit Card to Portfolio');
    await tester.ensureVisible(submitCardBtn);
    await tester.tap(submitCardBtn);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your credit card name'), findsOneWidget);

    // 5. Enter custom card name 'OneCard Metal'
    final otherCardField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Other Credit Card Name & Variant');
    await tester.enterText(otherCardField, 'OneCard Metal');
    await tester.pumpAndSettle();

    // 6. Submit
    await tester.tap(submitCardBtn);
    await tester.pumpAndSettle();

    // Verify modal dismissed and success message with custom card name
    expect(find.text('Add Credit Card'), findsNothing);
    expect(find.text('OneCard Metal added to Credit Cards!'), findsOneWidget);
  });

  testWidgets('Test Link Bank Account modal displays Other Bank field only when Others is selected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(380, 840);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BankAggregationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open Link Bank modal
    final linkBankBtn = find.text('Link Bank');
    await tester.tap(linkBankBtn);
    await tester.pumpAndSettle();

    expect(find.text('Link Bank Account'), findsOneWidget);

    // 1. Initially, other bank name field must NOT be visible
    expect(find.text('Other Bank Name'), findsNothing);

    // 2. Select 'Others' from dropdown
    await tester.tap(find.text('State Bank of India').last);
    await tester.pumpAndSettle();

    final dropdownFinder = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.text('Others'),
      100,
      scrollable: dropdownFinder,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Others').last);
    await tester.pumpAndSettle();

    // 3. Now the 'Other Bank Name' text field MUST be visible!
    expect(find.text('Other Bank Name'), findsOneWidget);

    // 4. Try submitting while other bank field is empty -> should show error
    final submitBankBtn = find.text('Verify & Link Bank Account');
    await tester.ensureVisible(submitBankBtn);
    await tester.tap(submitBankBtn);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your bank name'), findsOneWidget);

    // 5. Enter custom bank name 'Standard Chartered Bank'
    final otherBankField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Other Bank Name');
    await tester.enterText(otherBankField, 'Standard Chartered Bank');
    await tester.pumpAndSettle();

    // 6. Submit
    await tester.tap(submitBankBtn);
    await tester.pumpAndSettle();

    // Verify modal dismissed and success message with custom bank name
    expect(find.text('Link Bank Account'), findsNothing);
    expect(find.textContaining('Standard Chartered Bank linked successfully!'), findsOneWidget);
  });

  testWidgets('Test Link New UPI Account modal displays Other UPI field and Other Bank field when Others is selected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(380, 840);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BankAggregationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Open Add UPI modal
    final addUpiBtn = find.text('Add UPI');
    await tester.ensureVisible(addUpiBtn);
    await tester.tap(addUpiBtn);
    await tester.pumpAndSettle();

    expect(find.text('Link New UPI Account & VPA'), findsOneWidget);

    // Initially, neither other UPI field nor other bank field must be visible
    expect(find.text('Other UPI App / Provider Name'), findsNothing);
    expect(find.text('Other Linked Bank Name'), findsNothing);

    // 2. Select 'Other UPI' from UPI App Provider dropdown
    await tester.tap(find.text('Google Pay').last);
    await tester.pumpAndSettle();

    final dropdownFinder1 = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.text('Other UPI'),
      100,
      scrollable: dropdownFinder1,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other UPI').last);
    await tester.pumpAndSettle();

    // Now 'Other UPI App / Provider Name' MUST be visible!
    expect(find.text('Other UPI App / Provider Name'), findsOneWidget);

    // 3. Select 'Others' from Underlying Linked Bank Account dropdown
    await tester.tap(find.text('State Bank of India').last);
    await tester.pumpAndSettle();

    final dropdownFinder2 = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.text('Others'),
      100,
      scrollable: dropdownFinder2,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Others').last);
    await tester.pumpAndSettle();

    // Now 'Other Linked Bank Name' MUST be visible!
    expect(find.text('Other Linked Bank Name'), findsOneWidget);

    // 4. Try submitting while other UPI field is empty -> should show error
    final submitUpiBtn = find.text('Verify & Link UPI ID');
    await tester.ensureVisible(submitUpiBtn);
    await tester.tap(submitUpiBtn);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your UPI app / provider name'), findsOneWidget);

    // Enter custom UPI app 'Navi UPI'
    final otherUpiField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Other UPI App / Provider Name');
    await tester.enterText(otherUpiField, 'Navi UPI');
    await tester.pumpAndSettle();

    // Try submitting while other bank field is empty -> should show error
    await tester.tap(submitUpiBtn);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your linked bank name'), findsOneWidget);

    // Enter custom bank 'Yes Bank'
    final otherBankField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Other Linked Bank Name');
    await tester.enterText(otherBankField, 'Yes Bank');
    await tester.pumpAndSettle();

    // 5. Submit successfully
    await tester.tap(submitUpiBtn);
    await tester.pumpAndSettle();

    // Verify modal dismissed and success message
    expect(find.text('Link New UPI Account & VPA'), findsNothing);
    expect(find.textContaining('linked successfully!'), findsOneWidget);
  });

  testWidgets('Test Link Bank Account modal Re-Enter Account Number validation and Verified Bank Branch card', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(380, 840);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BankAggregationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Open Link Bank modal
    final linkBankBtn = find.text('Link Bank');
    await tester.tap(linkBankBtn);
    await tester.pumpAndSettle();

    // Verify both account number fields are present
    final accNumField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Bank Account Number');
    final reEnterField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Re-Enter Account Number');
    expect(accNumField, findsOneWidget);
    expect(reEnterField, findsOneWidget);

    // Initially with matching account numbers (501004329871), IFSC and holder, Verified Branch card is shown
    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.textContaining('Branch Verified'), findsNothing); // Checks label
    expect(find.textContaining('State Bank of India Branch'), findsOneWidget);
    expect(find.byIcon(Icons.verified), findsWidgets);

    // 2. Enter mismatched account number in Re-Enter field
    await tester.enterText(reEnterField, '999999999999');
    await tester.pumpAndSettle();

    // Inline error text must be displayed
    expect(find.text('Account Number Mismatch Enter Correctly!'), findsOneWidget);
    // Verified card should not be displayed when mismatched
    expect(find.text('VERIFIED'), findsNothing);

    // 3. Try submitting with mismatched account numbers -> SnackBar error shown
    final submitBtn = find.text('Verify & Link Bank Account');
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Account Number Mismatch Enter Correctly!'), findsWidgets);
    // Modal must NOT dismiss
    expect(find.text('Link Bank Account'), findsOneWidget);

    // 4. Enter matching account number again
    await tester.enterText(reEnterField, '501004329871');
    await tester.pumpAndSettle();

    // Error text must disappear and Verified badge must reappear
    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.textContaining('State Bank of India Branch'), findsOneWidget);

    // 5. Submit successfully
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Link Bank Account'), findsNothing);
    expect(find.textContaining('linked successfully!'), findsOneWidget);
  });

  testWidgets('Test Add Credit Card modal contains Holder Name, Issued Bank, Card Type, and Expiry (MM/YY)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(380, 840);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BankAggregationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to and click Add Card
    final addCardBtn = find.text('Add Card');
    await tester.ensureVisible(addCardBtn);
    await tester.tap(addCardBtn);
    await tester.pumpAndSettle();

    // Verify modal is open
    expect(find.text('Add Credit Card'), findsOneWidget);

    // Verify new fields are present
    expect(find.text('Holder Name'), findsOneWidget);
    expect(find.text('Issued Bank'), findsOneWidget);
    expect(find.text('Card Type'), findsOneWidget);
    expect(find.text('Expiry (MM/YY)'), findsOneWidget);

    // Enter details
    final holderField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Holder Name');
    await tester.enterText(holderField, 'Rahul Sharma');

    final expiryField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Expiry (MM/YY)');
    await tester.enterText(expiryField, '12/29');

    // Submit card
    final submitCardBtn = find.text('Add Credit Card to Portfolio');
    await tester.tap(submitCardBtn);
    await tester.pumpAndSettle();

    // Verify modal dismissed and success snackbar displayed
    expect(find.text('Add Credit Card'), findsNothing);
    expect(find.textContaining('added to Credit Cards!'), findsOneWidget);

    // Verify Rahul Sharma and 12/29 are visible in the cards section
    expect(find.textContaining('Rahul Sharma'), findsWidgets);
    expect(find.textContaining('12/29'), findsWidgets);
  });
}


