import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/bank_aggregation/presentation/bank_aggregation_screen.dart';

void main() {
  testWidgets('Test Add Bank and Add Credit Card modals and interactions', (WidgetTester tester) async {
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

    // Enter matching bank account numbers and IFSC code
    final accNumField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Bank Account Number');
    final reEnterField = find.byWidgetPredicate((w) => w is TextField && (w.decoration?.labelText == 'Re-Enter Bank Account Number' || w.decoration?.labelText == 'Re-Enter Account Number'));
    await tester.enterText(accNumField, '501004329871');
    await tester.enterText(reEnterField, '501004329871');
    final ifscField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Branch IFSC Code');
    await tester.enterText(ifscField, 'SBIN0001234');
    await tester.pumpAndSettle();

    // Tap Verify & Link Bank Account
    await tester.tap(find.text('Verify & Link Bank Account'));
    await tester.pumpAndSettle();

    // Verify modal closed & snackbar appeared
    expect(find.textContaining('linked successfully!'), findsOneWidget);

// 2. Test + Add Card button in Credit Cards section
    final addCardBtn = find.text('Add Card');
    await tester.ensureVisible(addCardBtn);
    await tester.pumpAndSettle();
    expect(addCardBtn, findsOneWidget);
    await tester.tap(addCardBtn);
    await tester.pumpAndSettle();

    // Verify Add Credit Card modal content & options
    expect(find.text('Add Credit Card'), findsOneWidget);
    expect(find.text('Credit Card Issuer & Variant'), findsOneWidget);
    expect(find.text('Card Number'), findsOneWidget);
    expect(find.text('CVV Number'), findsOneWidget);
    expect(find.text('Card Type'), findsOneWidget);
    expect(find.text('Holder Name'), findsOneWidget);
    expect(find.text('Expiry (MM/YY)'), findsOneWidget);
    expect(find.text('Issued Bank'), findsOneWidget);
    expect(find.text('Link Bank Account'), findsOneWidget);
    expect(find.text('Last 4 Digits'), findsNothing);
    expect(find.text('Total Limit (₹)'), findsNothing);
    expect(find.text('Outstanding (₹)'), findsNothing);
    final submitCardBtn = find.text('Add Credit Card to Portfolio');
    await tester.ensureVisible(submitCardBtn);
    await tester.pumpAndSettle();
    expect(submitCardBtn, findsOneWidget);

    // Verify validation when submitting without card selection
    await tester.tap(submitCardBtn);
    await tester.pumpAndSettle();
    expect(find.text('Please select a credit card variant'), findsOneWidget);

    // Select card variant
    await tester.tap(find.text('Credit Card Issuer & Variant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HDFC Regalia Gold').last);
    await tester.pumpAndSettle();

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
    await tester.tap(find.text('Credit Card Issuer & Variant'));
    await tester.pumpAndSettle();

    final searchCardField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Search Credit Cards');
    await tester.enterText(searchCardField, 'Other');
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

    // 6. Try submitting without selecting bank -> should show error
    await tester.tap(submitCardBtn);
    await tester.pumpAndSettle();
    expect(find.text('Please select an issuing bank'), findsOneWidget);

    // 7. Open Issued Bank dropdown and search for HDFC
    await tester.ensureVisible(find.text('Issued Bank'));
    await tester.tap(find.text('Issued Bank'));
    await tester.pumpAndSettle();

    final searchBankField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Search Banks');
    await tester.enterText(searchBankField, 'HDFC');
    await tester.pumpAndSettle();
    final hdfcOption = find.descendant(of: find.byKey(const Key('dropdown_banks_list')), matching: find.text('HDFC Bank'));
    await tester.ensureVisible(hdfcOption);
    await tester.tap(hdfcOption);
    await tester.pumpAndSettle();

    // 8. Submit
    await tester.ensureVisible(submitCardBtn);
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

    // 5. Enter custom bank name 'Standard Chartered Bank' and required account numbers
    final otherBankField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Other Bank Name');
    await tester.enterText(otherBankField, 'Standard Chartered Bank');
    final accNumField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Bank Account Number');
    final reEnterField = find.byWidgetPredicate((w) => w is TextField && (w.decoration?.labelText == 'Re-Enter Bank Account Number' || w.decoration?.labelText == 'Re-Enter Account Number'));
    await tester.enterText(accNumField, '501004329871');
    await tester.enterText(reEnterField, '501004329871');
    await tester.pumpAndSettle();

    // 6. Submit
    await tester.tap(submitBankBtn);
    await tester.pumpAndSettle();

    // Verify modal dismissed and success message with custom bank name
    expect(find.text('Link Bank Account'), findsNothing);
    expect(find.textContaining('Standard Chartered Bank linked successfully!'), findsOneWidget);
  });

  testWidgets('Verify UPI, Digital Wallets, and Consent Management sections are removed from BankAggregationScreen', (WidgetTester tester) async {
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

    // Verify removed sections and buttons do not exist
    expect(find.text('UPI Accounts & Mandates', skipOffstage: false), findsNothing);
    expect(find.text('Add UPI', skipOffstage: false), findsNothing);
    expect(find.text('Digital Wallets & Cash Position (FAA-SEC-08)', skipOffstage: false), findsNothing);
    expect(find.text('Consent Management (FAA-SEC-11)', skipOffstage: false), findsNothing);
    expect(find.textContaining('UPI ('), findsNothing);
    expect(find.textContaining('Wallets ('), findsNothing);
    expect(find.textContaining('Consents ('), findsNothing);
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
    final reEnterField = find.byWidgetPredicate((w) => w is TextField && (w.decoration?.labelText == 'Re-Enter Bank Account Number' || w.decoration?.labelText == 'Re-Enter Account Number'));
    expect(accNumField, findsOneWidget);
    expect(reEnterField, findsOneWidget);

    // Enter matching account numbers (501004329871), IFSC and verify branch card
    await tester.enterText(accNumField, '501004329871');
    await tester.enterText(reEnterField, '501004329871');
    final ifscField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Branch IFSC Code');
    await tester.enterText(ifscField, 'SBIN0001234');
    await tester.pumpAndSettle();

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

    // Select card variant
    await tester.tap(find.text('Credit Card Issuer & Variant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HDFC Regalia Gold').last);
    await tester.pumpAndSettle();

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

  testWidgets('Test Add Card modal Credit & Debit options, Search Bar filtering, and adding Debit Card', (WidgetTester tester) async {
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

    // Verify section title is Credit & Debit Cards
    expect(find.text('Credit & Debit Cards'), findsOneWidget);

    // Tap Add Card button
    final addCardBtn = find.text('Add Card');
    await tester.ensureVisible(addCardBtn);
    await tester.tap(addCardBtn);
    await tester.pumpAndSettle();

    // 1. Verify 2 options are present: Credit Cards and Debit Cards
    expect(find.text('Credit Cards'), findsOneWidget);
    expect(find.text('Debit Cards'), findsOneWidget);

    // 2. Open Credit Cards dropdown to reveal Search Bar and cards list
    await tester.tap(find.text('Credit Card Issuer & Variant'));
    await tester.pumpAndSettle();

    expect(find.text('Search Credit Cards'), findsOneWidget);
    expect(find.byKey(const Key('dropdown_cards_list')), findsOneWidget);

    // Test Search Bar filters cards
    final searchField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Search Credit Cards');
    await tester.enterText(searchField, 'Amazon');
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byKey(const Key('dropdown_cards_list')), matching: find.text('ICICI Amazon Pay')), findsOneWidget);

    // 3. Switch to Debit Cards option
    await tester.tap(find.text('Debit Cards'));
    await tester.pumpAndSettle();

    // Header updates to Add Debit Card
    expect(find.text('Add Debit Card'), findsOneWidget);
    expect(find.text('Debit Card Issuer & Variant'), findsOneWidget);

    // Open Debit Cards dropdown
    await tester.tap(find.text('Debit Card Issuer & Variant'));
    await tester.pumpAndSettle();
    expect(find.text('Search Debit Cards'), findsOneWidget);
    expect(find.byKey(const Key('dropdown_cards_list')), findsOneWidget);

    // Select a debit card
    await tester.tap(find.descendant(of: find.byKey(const Key('dropdown_cards_list')), matching: find.text('HDFC Millennia Debit Card')));
    await tester.pumpAndSettle();

    // Verify Debit Card specific details: only the 7 requested fields are shown
    expect(find.text('Card Number'), findsOneWidget);
    expect(find.text('CVV Number'), findsOneWidget);
    expect(find.text('Card Type'), findsOneWidget);
    expect(find.text('Holder Name'), findsOneWidget);
    expect(find.text('Expiry (MM/YY)'), findsOneWidget);
    expect(find.text('Issued Bank'), findsOneWidget);
    expect(find.text('Link Bank Account'), findsOneWidget);
    expect(find.text('Daily ATM Limit (₹)'), findsNothing);
    expect(find.text('Daily POS / Online (₹)'), findsNothing);

    // Submit Debit Card
    final submitDebitBtn = find.text('Add Debit Card to Portfolio');
    await tester.ensureVisible(submitDebitBtn);
    await tester.tap(submitDebitBtn);
    await tester.pumpAndSettle();

    // Verify modal dismissed and success message
    expect(find.text('Add Debit Card'), findsNothing);
    expect(find.textContaining('added to Debit Cards!'), findsOneWidget);

    // Verify Debit Card badge and metrics are visible in Credit & Debit Cards section
    expect(find.text('Debit Card', skipOffstage: false), findsWidgets);
    expect(find.text('Daily ATM Limit', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Test Add Card modal Issued Bank dropdown search, bank selection, and null initial states in Credit and Debit cards', (WidgetTester tester) async {
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
    await tester.tap(addCardBtn);
    await tester.pumpAndSettle();

    // 1. Verify initial null states: placeholders are shown
    expect(find.text('Select Credit Card Variant'), findsOneWidget);
    expect(find.text('Select Issuing Bank'), findsOneWidget);

    // 2. Open Issued Bank dropdown
    await tester.ensureVisible(find.text('Issued Bank'));
    await tester.tap(find.text('Issued Bank'));
    await tester.pumpAndSettle();

    // Verify Search Bar and bank list are displayed
    expect(find.text('Search Banks'), findsOneWidget);
    expect(find.byKey(const Key('dropdown_banks_list')), findsOneWidget);

    // Test Search Bar filtering banks
    final searchBankField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Search Banks');
    await tester.enterText(searchBankField, 'ICICI');
    await tester.pumpAndSettle();

    final iciciOption = find.descendant(of: find.byKey(const Key('dropdown_banks_list')), matching: find.text('ICICI Bank'));
    expect(iciciOption, findsOneWidget);

    // Select ICICI Bank
    await tester.ensureVisible(iciciOption);
    await tester.tap(iciciOption);
    await tester.pumpAndSettle();

    // Dropdown is collapsed and Issued Bank now shows ICICI Bank
    expect(find.text('Search Banks'), findsNothing);
    expect(find.descendant(of: find.byType(BottomSheet), matching: find.text('ICICI Bank')), findsOneWidget);

    // 3. Switch to Debit Cards tab
    await tester.tap(find.text('Debit Cards'));
    await tester.pumpAndSettle();

    // Verify Debit Card placeholder is null/placeholder initially
    expect(find.text('Select Debit Card Variant'), findsOneWidget);

    // Open Issued Bank dropdown in Debit Cards section
    await tester.ensureVisible(find.text('Issued Bank'));
    await tester.tap(find.text('Issued Bank'));
    await tester.pumpAndSettle();

    expect(find.text('Search Banks'), findsOneWidget);
    expect(find.byKey(const Key('dropdown_banks_list')), findsOneWidget);

    // Search for State Bank
    final searchBankFieldDebit = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Search Banks');
    await tester.enterText(searchBankFieldDebit, 'State Bank');
    await tester.pumpAndSettle();

    final sbiOption = find.descendant(of: find.byKey(const Key('dropdown_banks_list')), matching: find.text('State Bank of India'));
    expect(sbiOption, findsOneWidget);

    // Select State Bank of India
    await tester.ensureVisible(sbiOption);
    await tester.tap(sbiOption);
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(BottomSheet), matching: find.text('State Bank of India')), findsOneWidget);
  });

  testWidgets('Test Add Card modal 12-digit Card Number validation and real-time feedback', (WidgetTester tester) async {
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
    await tester.tap(addCardBtn);
    await tester.pumpAndSettle();

    final cardNumField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Card Number');
    expect(cardNumField, findsOneWidget);

    // 1. Enter less than 12 digits (e.g. 8 digits)
    await tester.enterText(cardNumField, '1234 5678');
    await tester.pumpAndSettle();

    // Verify warning message is shown
    expect(find.text('Card Number must be at least 12 digits (8/12)'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    // 2. Select card variant and bank
    await tester.tap(find.text('Credit Card Issuer & Variant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HDFC Regalia Gold').last);
    await tester.pumpAndSettle();

    // Tap submit while card number is < 12 digits -> should show error SnackBar
    final submitBtn = find.text('Add Credit Card to Portfolio');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();
    expect(find.text('Card Number must be at least 12 digits (entered 8 digits)'), findsOneWidget);

    // 3. Enter full 12 digits
    await tester.enterText(cardNumField, '1234 5678 9012');
    await tester.pumpAndSettle();

    // Verify verified success indicator is displayed
    expect(find.text('Verified 12-Digit Credit Card Number'), findsOneWidget);

    // Tap submit -> succeeds
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();
    expect(find.textContaining('added to Credit Cards!'), findsOneWidget);
  });
}


