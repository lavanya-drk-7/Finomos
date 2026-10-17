import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/utils/validators.dart';
import 'package:finomos/features/auth_kyc/presentation/login_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/sign_up_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/consent_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/privacy_policy_screen.dart';
import 'package:finomos/features/auth_kyc/providers/auth_kyc_provider.dart';

void main() {
  group('FormValidators Unit Tests', () {
    test('validateFullName validates correctly', () {
      expect(FormValidators.validateFullName(null), 'Full name is required');
      expect(FormValidators.validateFullName(''), 'Full name is required');
      expect(FormValidators.validateFullName('   '), 'Full name is required');
      expect(FormValidators.validateFullName('Ab'), 'Full name must be at least 3 characters');
      expect(FormValidators.validateFullName('John123'), 'Full name should only contain letters and spaces');
      expect(FormValidators.validateFullName('Sireesha'), isNull);
      expect(FormValidators.validateFullName('John Doe'), isNull);
    });

    test('validateEmail validates correctly', () {
      expect(FormValidators.validateEmail(null), 'Email ID is required');
      expect(FormValidators.validateEmail(''), 'Email ID is required');
      expect(FormValidators.validateEmail('   '), 'Email ID is required');
      expect(FormValidators.validateEmail('invalidemail'), 'Please enter a valid email address');
      expect(FormValidators.validateEmail('test@com'), 'Please enter a valid email address');
      expect(FormValidators.validateEmail('user@domain.c'), 'Please enter a valid email address');
      expect(FormValidators.validateEmail('sireesha@gmail.com'), isNull);
      expect(FormValidators.validateEmail('john.doe@finomos.io'), isNull);
    });

    test('validatePassword validates correctly', () {
      expect(FormValidators.validatePassword(null), 'Password is required');
      expect(FormValidators.validatePassword(''), 'Password is required');
      expect(FormValidators.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(FormValidators.validatePassword('123456'), isNull);
      expect(FormValidators.validatePassword('Password@123'), isNull);
    });

    test('validateMobile validates correctly', () {
      expect(FormValidators.validateMobile(null), 'Mobile number is required');
      expect(FormValidators.validateMobile(''), 'Mobile number is required');
      expect(FormValidators.validateMobile('12345'), 'Please enter a valid 10-digit mobile number');
      expect(FormValidators.validateMobile('1234567890'), 'Mobile number should start with 6, 7, 8, or 9');
      expect(FormValidators.validateMobile('9876543210'), isNull);
      expect(FormValidators.validateMobile('+91 98765 43210'), isNull);
      expect(FormValidators.validateMobile('919876543210'), isNull);
    });

    test('validateOtp validates correctly', () {
      expect(FormValidators.validateOtp(null), 'Please enter 6-digit OTP');
      expect(FormValidators.validateOtp(''), 'Please enter 6-digit OTP');
      expect(FormValidators.validateOtp('123'), 'Please enter complete 6-digit OTP');
      expect(FormValidators.validateOtp('12345a'), 'Please enter complete 6-digit OTP');
      expect(FormValidators.validateOtp('123456'), isNull);
    });
  });

  group('LoginScreen Validation Widget Tests', () {
    testWidgets('shows validation error when email is cleared and Verify Email is clicked', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Email text field and enter empty string
      final emailField = find.widgetWithText(TextFormField, 'Email ID');
      expect(emailField, findsOneWidget);
      await tester.enterText(emailField, '');
      await tester.pumpAndSettle();

      // Tap "Verify Email" button
      final verifyEmailBtn = find.widgetWithText(ElevatedButton, 'Verify Email');
      await tester.ensureVisible(verifyEmailBtn);
      await tester.tap(verifyEmailBtn);
      await tester.pumpAndSettle();

      // Inline validation error & snackbar displayed
      expect(find.text('Email ID is required'), findsWidgets);
    });

    testWidgets('shows validation error when invalid email format is entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email ID');
      await tester.enterText(emailField, 'notanemail');
      await tester.pumpAndSettle();

      final verifyEmailBtn = find.widgetWithText(ElevatedButton, 'Verify Email');
      await tester.ensureVisible(verifyEmailBtn);
      await tester.tap(verifyEmailBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsWidgets);
    });

    testWidgets('shows validation error when password is too short in Login', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, '123');
      await tester.pumpAndSettle();

      final verifyEmailBtn = find.widgetWithText(ElevatedButton, 'Verify Email');
      await tester.ensureVisible(verifyEmailBtn);
      await tester.tap(verifyEmailBtn);
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsWidgets);
    });

    testWidgets('shows validation error when mobile is cleared and Verify Mobile OTP is clicked', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final mobileTab = find.text('Mobile Number');
      if (mobileTab.evaluate().isNotEmpty) {
        await tester.tap(mobileTab.first);
        await tester.pumpAndSettle();
      }

      final mobileField = find.widgetWithText(TextFormField, 'Mobile Number');
      await tester.ensureVisible(mobileField);
      await tester.enterText(mobileField, '');
      await tester.pumpAndSettle();

      final verifyMobileBtn = find.widgetWithText(ElevatedButton, 'Verify Mobile OTP');
      await tester.ensureVisible(verifyMobileBtn);
      await tester.tap(verifyMobileBtn);
      await tester.pumpAndSettle();

      expect(find.text('Mobile number is required'), findsWidgets);
    });

    testWidgets('successfully logs in with Email ID and Password', (WidgetTester tester) async {
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

      final emailField = find.widgetWithText(TextFormField, 'Email ID');
      await tester.enterText(emailField, 'sireesha@gmail.com');
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, 'Password123');
      await tester.pumpAndSettle();

      final verifyEmailBtn = find.widgetWithText(ElevatedButton, 'Verify Email');
      await tester.ensureVisible(verifyEmailBtn);
      await tester.tap(verifyEmailBtn);
      await tester.pump();

      expect(find.text('Login Successful!'), findsWidgets);
      expect(container.read(authKycProvider).isExistingUser, isTrue);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
    });

    testWidgets('successfully logs in with Mobile Number and 6-Digit OTP', (WidgetTester tester) async {
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

      final mobileTab = find.text('Mobile Number');
      await tester.tap(mobileTab.first);
      await tester.pumpAndSettle();

      final mobileField = find.widgetWithText(TextFormField, 'Mobile Number');
      await tester.ensureVisible(mobileField);
      await tester.enterText(mobileField, '9876543210');
      await tester.pumpAndSettle();

      final verifyMobileBtn = find.widgetWithText(ElevatedButton, 'Verify Mobile OTP');
      await tester.ensureVisible(verifyMobileBtn);
      await tester.tap(verifyMobileBtn);
      await tester.pump();

      expect(find.text('Login Successful!'), findsWidgets);
      expect(container.read(authKycProvider).isExistingUser, isTrue);
      expect(container.read(authKycProvider).isMobileVerified, isTrue);
      expect(container.read(authKycProvider).isOtpVerified, isTrue);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
    });
  });

  group('SignUpScreen Validation Widget Tests', () {
    testWidgets('shows validation error when full name is empty in SignUp', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextFormField, 'Full Name');
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      final verifyEmailBtn = find.widgetWithText(ElevatedButton, 'Verify Email');
      await tester.tap(verifyEmailBtn);
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsWidgets);
    });

    testWidgets('shows validation error when full name is less than 3 chars in SignUp', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextFormField, 'Full Name');
      await tester.enterText(nameField, 'Ab');
      await tester.pumpAndSettle();

      final verifyEmailBtn = find.widgetWithText(ElevatedButton, 'Verify Email');
      await tester.tap(verifyEmailBtn);
      await tester.pumpAndSettle();

      expect(find.text('Full name must be at least 3 characters'), findsWidgets);
    });

    testWidgets('shows validation error when mobile is invalid in SignUp', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final phoneField = find.widgetWithText(TextFormField, 'Mobile Number');
      await tester.ensureVisible(phoneField);
      await tester.enterText(phoneField, '12345');
      await tester.pumpAndSettle();

      final verifyMobileBtn = find.widgetWithText(ElevatedButton, 'Verify Mobile OTP');
      await tester.ensureVisible(verifyMobileBtn);
      await tester.tap(verifyMobileBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid 10-digit mobile number'), findsWidgets);
    });
  });

  group('ConsentScreen Widget Tests', () {
    testWidgets('checkboxes start unchecked and clicking green check box selects all 3 checkboxes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ConsentScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(3));

      // Checkboxes must start unchecked
      expect(tester.widget<Checkbox>(checkboxes.at(0)).value, isFalse);
      expect(tester.widget<Checkbox>(checkboxes.at(1)).value, isFalse);
      expect(tester.widget<Checkbox>(checkboxes.at(2)).value, isFalse);

      // Attempting to continue without accepting shows validation error
      final continueBtn = find.widgetWithText(ElevatedButton, 'Continue');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please accept all consent checkboxes to proceed.'), findsWidgets);

      // Tap the Green Check Box (Consent Acceptance) to select all
      final greenCheckbox = find.text('Consent Acceptance');
      await tester.ensureVisible(greenCheckbox);
      await tester.tap(greenCheckbox);
      await tester.pumpAndSettle();

      // All 3 checkboxes should now be selected
      expect(tester.widget<Checkbox>(checkboxes.at(0)).value, isTrue);
      expect(tester.widget<Checkbox>(checkboxes.at(1)).value, isTrue);
      expect(tester.widget<Checkbox>(checkboxes.at(2)).value, isTrue);

      // Tap Green Check Box again to deselect all
      await tester.tap(greenCheckbox);
      await tester.pumpAndSettle();

      expect(tester.widget<Checkbox>(checkboxes.at(0)).value, isFalse);
      expect(tester.widget<Checkbox>(checkboxes.at(1)).value, isFalse);
      expect(tester.widget<Checkbox>(checkboxes.at(2)).value, isFalse);
    });
  });

  group('PrivacyPolicyScreen Widget Tests', () {
    testWidgets('privacy checkbox starts unchecked and validates before moving to next step', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PrivacyPolicyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Checkbox starts unchecked
      expect(tester.widget<Checkbox>(checkbox).value, isFalse);

      // Attempting to submit without accepting shows validation error
      final submitBtn = find.widgetWithText(ElevatedButton, 'Submit KYC');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please accept the Privacy Policy to proceed.'), findsWidgets);

      // Tap checkbox to accept
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      expect(tester.widget<Checkbox>(checkbox).value, isTrue);
    });
  });
}
