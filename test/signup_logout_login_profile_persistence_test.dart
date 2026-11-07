import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/services/cache_service.dart';
import 'package:finomos/features/auth_kyc/domain/kyc_models.dart';
import 'package:finomos/features/auth_kyc/providers/auth_kyc_provider.dart';
import 'package:finomos/features/profile/providers/profile_provider.dart';

void main() {
  group('User Signup -> Logout -> Login -> Profile Persistence Flow Tests', () {
    const testFullName = 'Vikram Podalakuru';
    const testEmail = 'vikram.p@example.com';
    const testMobile = '9876501234';
    const testPassword = 'Password@123';
    const testDob = '1992-05-20';
    const testGender = 'Male';
    const testAddress = 'Flat 501, Horizon Towers, Financial District';
    const testCity = 'Hyderabad';
    const testState = 'Telangana';
    const testPin = '500032';
    const testPan = 'ABCDE9876K';
    const testAadhaar = 'XXXX-XXXX-9012';
    const testOccupation = 'Principal Architect';
    const double testIncome = 2400000.0;

    setUp(() {
      LocalCacheService().remove('user_record_phone_$testMobile');
      LocalCacheService().remove('user_record_email_$testEmail');
      LocalCacheService().remove('user_record_id_user_vikram_123');
      LocalCacheService().remove('user_name');
      LocalCacheService().remove('user_email');
      LocalCacheService().remove('user_mobile_number');
      LocalCacheService().remove('user_profile');
      LocalCacheService().remove('auth_session');
      LocalCacheService().remove('is_logged_in');
      LocalCacheService().remove('registered_users_registry');
    });

    tearDown(() {
      LocalCacheService().remove('user_record_phone_$testMobile');
      LocalCacheService().remove('user_record_email_$testEmail');
      LocalCacheService().remove('user_record_id_user_vikram_123');
      LocalCacheService().remove('user_name');
      LocalCacheService().remove('user_email');
      LocalCacheService().remove('user_mobile_number');
      LocalCacheService().remove('user_profile');
      LocalCacheService().remove('auth_session');
      LocalCacheService().remove('is_logged_in');
      LocalCacheService().remove('registered_users_registry');
    });

    test('1. User signup and onboarding stores details in persistent user records', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Step 1: User signs up
      final authNotifier = container.read(authKycProvider.notifier);
      authNotifier.updateUserData(
        const UserRegistrationData().copyWith(
          fullName: testFullName,
          email: testEmail,
          mobileNumber: testMobile,
          password: testPassword,
          userId: 'user_vikram_123',
        ),
      );
      authNotifier.persistSession(
        phone: testMobile,
        email: testEmail,
        name: testFullName,
        userId: 'user_vikram_123',
      );

      // Verify immediate record exists by phone & email
      final initialRecord = LocalCacheService().getUserProfileRecord(testMobile);
      expect(initialRecord, isNotNull);
      expect(initialRecord!['fullName'], testFullName);
      expect(initialRecord['email'], testEmail);
      expect(initialRecord['phone'], testMobile);

      // Step 2: User completes UserDetails
      LocalCacheService().saveUserProfileRecord(
        phone: testMobile,
        email: testEmail,
        userId: 'user_vikram_123',
        data: {
          'dob': testDob,
          'gender': testGender,
          'address': testAddress,
          'city': testCity,
          'state': testState,
          'pinCode': testPin,
          'occupation': testOccupation,
          'annualIncome': testIncome,
        },
      );

      // Step 3: User completes KYC
      LocalCacheService().saveUserProfileRecord(
        phone: testMobile,
        email: testEmail,
        userId: 'user_vikram_123',
        data: {
          'panNumber': testPan,
          'aadhaarNumber': testAadhaar,
        },
      );

      // Verify all fields are recorded
      final completeRecord = LocalCacheService().getUserProfileRecord(testEmail);
      expect(completeRecord, isNotNull);
      expect(completeRecord!['fullName'], testFullName);
      expect(completeRecord['email'], testEmail);
      expect(completeRecord['phone'], testMobile);
      expect(completeRecord['dob'], testDob);
      expect(completeRecord['gender'], testGender);
      expect(completeRecord['address'], testAddress);
      expect(completeRecord['city'], testCity);
      expect(completeRecord['state'], testState);
      expect(completeRecord['pinCode'], testPin);
      expect(completeRecord['panNumber'], testPan);
      expect(completeRecord['aadhaarNumber'], testAadhaar);
      expect(completeRecord['occupation'], testOccupation);
      expect(completeRecord['annualIncome'], testIncome);
    });

    test('2. User logout clears active session but preserves user profile record', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Seed user profile record
      LocalCacheService().saveUserProfileRecord(
        phone: testMobile,
        email: testEmail,
        userId: 'user_vikram_123',
        data: {
          'fullName': testFullName,
          'email': testEmail,
          'phone': testMobile,
          'dob': testDob,
          'gender': testGender,
          'address': testAddress,
          'city': testCity,
          'state': testState,
          'pinCode': testPin,
          'panNumber': testPan,
          'aadhaarNumber': testAadhaar,
          'occupation': testOccupation,
          'annualIncome': testIncome,
        },
      );

      // Log in session
      container.read(authKycProvider.notifier).persistSession(
        phone: testMobile,
        email: testEmail,
        name: testFullName,
      );
      expect(container.read(authKycProvider.notifier).isSessionActive(), isTrue);

      // User logs out
      container.read(authKycProvider.notifier).clearPersistedSession();

      // Active session must be false
      expect(container.read(authKycProvider.notifier).isSessionActive(), isFalse);
      expect(LocalCacheService().get('auth_session'), isNull);

      // But saved record for Vikram must be intact!
      final preservedByPhone = LocalCacheService().getUserProfileRecord(testMobile);
      expect(preservedByPhone, isNotNull);
      expect(preservedByPhone!['fullName'], testFullName);
      expect(preservedByPhone['dob'], testDob);
      expect(preservedByPhone['address'], testAddress);

      final preservedByEmail = LocalCacheService().getUserProfileRecord(testEmail);
      expect(preservedByEmail, isNotNull);
      expect(preservedByEmail!['panNumber'], testPan);
      expect(preservedByEmail['occupation'], testOccupation);
    });

    test('3. Logging back in with same email or mobile restores all profile fields in Profile section', () {
      // Seed user profile record created during signup
      LocalCacheService().saveUserProfileRecord(
        phone: testMobile,
        email: testEmail,
        userId: 'user_vikram_123',
        data: {
          'fullName': testFullName,
          'email': testEmail,
          'phone': testMobile,
          'dob': testDob,
          'gender': testGender,
          'address': testAddress,
          'city': testCity,
          'state': testState,
          'pinCode': testPin,
          'panNumber': testPan,
          'aadhaarNumber': testAadhaar,
          'occupation': testOccupation,
          'annualIncome': testIncome,
        },
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // User logs back in with mobile and OTP / credentials
      final authNotifier = container.read(authKycProvider.notifier);
      final profileNotifier = container.read(profileProvider.notifier);

      authNotifier.setSessionUser(
        token: 'token_vikram_fresh_login',
        userId: 'user_vikram_123',
        name: testFullName,
        email: testEmail,
        phone: testMobile,
      );

      // Restore profile from local record
      final userRecord = LocalCacheService().getUserProfileRecord(testMobile);
      expect(userRecord, isNotNull);
      profileNotifier.restoreUserProfile(phone: testMobile, record: userRecord);

      // Verify all Profile State Data fields are fully restored
      final profileState = container.read(profileProvider);
      final personal = profileState.personalInfo;
      final address = profileState.addressInfo;
      final employment = profileState.employmentInfo;

      // Personal Information fields
      expect(personal.fullName, testFullName);
      expect(personal.email, testEmail);
      expect(personal.mobileNumber, testMobile);
      expect(personal.dob, testDob);
      expect(personal.gender, testGender);
      expect(personal.panNumber, testPan);
      expect(personal.aadhaarNumber, testAadhaar);
      expect(personal.occupation, testOccupation);
      expect(personal.annualIncome, testIncome);

      // Address Information fields
      expect(address.residentialAddress, testAddress);
      expect(address.city, testCity);
      expect(address.state, testState);
      expect(address.pinCode, testPin);

      // Employment Information fields
      expect(employment.designation, testOccupation);
      expect(employment.annualIncome, testIncome.toStringAsFixed(0));
    });

    test('4. Logging in with email identifier also restores full profile fields', () {
      LocalCacheService().saveUserProfileRecord(
        phone: testMobile,
        email: testEmail,
        userId: 'user_vikram_123',
        data: {
          'fullName': testFullName,
          'email': testEmail,
          'phone': testMobile,
          'dob': testDob,
          'gender': testGender,
          'address': testAddress,
          'city': testCity,
          'state': testState,
          'pinCode': testPin,
          'panNumber': testPan,
          'aadhaarNumber': testAadhaar,
          'occupation': testOccupation,
          'annualIncome': testIncome,
        },
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Log in via email
      container.read(authKycProvider.notifier).setSessionUser(
        token: 'token_vikram_fresh_login_email',
        userId: 'user_vikram_123',
        name: testFullName,
        email: testEmail,
        phone: testMobile,
      );

      final userRecord = LocalCacheService().getUserProfileRecord(testEmail);
      expect(userRecord, isNotNull);
      container.read(profileProvider.notifier).restoreUserProfile(email: testEmail, record: userRecord);

      final profileState = container.read(profileProvider);
      expect(profileState.personalInfo.fullName, testFullName);
      expect(profileState.personalInfo.email, testEmail);
      expect(profileState.personalInfo.mobileNumber, testMobile);
      expect(profileState.personalInfo.dob, testDob);
      expect(profileState.addressInfo.residentialAddress, testAddress);
      expect(profileState.addressInfo.city, testCity);
      expect(profileState.addressInfo.state, testState);
      expect(profileState.addressInfo.pinCode, testPin);
      expect(profileState.personalInfo.panNumber, testPan);
    });
  });
}

