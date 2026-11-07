import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/core/constants/api_constants.dart';
import 'package:finomos/features/auth_kyc/domain/auth_onboarding_models.dart';

void main() {
  group('Auth & Onboarding API Contracts and Serialization Tests', () {
    test('1. POST /api/auth/signup request & response parsing', () {
      const request = SignupRequest(
        name: 'Sireesha Bandaru',
        email: 'sireeshapodhalakur@gmail.com',
        phone: '7207535810',
        password: 'Sireesha@123',
      );

      final reqJson = request.toJson();
      expect(reqJson['name'], 'Sireesha Bandaru');
      expect(reqJson['email'], 'sireeshapodhalakur@gmail.com');
      expect(reqJson['phone'], '7207535810');
      expect(reqJson['password'], 'Sireesha@123');

      final rawResponse = {
        "success": true,
        "message":
            "User created successfully. Verification OTP dispatched to phone and email.",
        "userId": "cmvyvocvu0000rixp0nwlb0gi",
        "token": "jwt-token-cmvyvocvu0000rixp0nwlb0gi",
        "user": {
          "id": "cmvyvocvu0000rixp0nwlb0gi",
          "name": "Sireesha Bandaru",
          "email": "sireesha_new@finmos.com",
          "phone": "9876543210",
          "kycStatus": "INCOMPLETE"
        },
        "dev_otp": "710008",
        "email_otp": "212314",
        "phone_otp": "710008"
      };

      final response = SignupResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.userId, 'cmvyvocvu0000rixp0nwlb0gi');
      expect(response.token, 'jwt-token-cmvyvocvu0000rixp0nwlb0gi');
      expect(response.user?.name, 'Sireesha Bandaru');
      expect(response.user?.kycStatus, 'INCOMPLETE');
      expect(response.devOtp, '710008');
      expect(response.emailOtp, '212314');
      expect(response.phoneOtp, '710008');
    });

    test('2. POST /api/auth/signup/verify-email response parsing', () {
      final rawResponse = {
        "success": true,
        "message": "Email address verified successfully"
      };

      final response = AuthApiResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.message, 'Email address verified successfully');
    });

    test('3. POST /api/auth/signup/verify-mobile response parsing', () {
      final rawResponse = {
        "success": true,
        "message": "Phone number verified successfully"
      };

      final response = AuthApiResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.message, 'Phone number verified successfully');
    });

    test('4. PUT /api/auth/onboarding/user-details request & response parsing',
        () {
      const request = OnboardingUserDetailsRequest(
        dob: '1998-05-15',
        gender: 'Female',
        address: 'Flat 402, Sai Residency, Indiranagar',
        city: 'Bengaluru',
        state: 'Karnataka',
        pinCode: '560038',
        occupation: 'Software Professional',
        annualIncome: 1200000,
      );

      final reqJson = request.toJson();
      expect(reqJson['dob'], '1998-05-15');
      expect(reqJson['gender'], 'Female');
      expect(reqJson['address'], 'Flat 402, Sai Residency, Indiranagar');
      expect(reqJson['city'], 'Bengaluru');
      expect(reqJson['state'], 'Karnataka');
      expect(reqJson['pinCode'], '560038');
      expect(reqJson['occupation'], 'Software Professional');
      expect(reqJson['annualIncome'], 1200000);

      final rawResponse = {
        "success": true,
        "message": "Onboarding Step 2: User details saved successfully",
        "data": {
          "id": "cmvw1s0a4000113hmni4koswd",
          "userId": "cmuzhxi5a000asr4p9f6jcndp",
          "dob": "1998-05-15",
          "gender": "Female",
          "address": "Flat 402, Sai Residency, Indiranagar",
          "city": "Bengaluru",
          "state": "Karnataka",
          "pinCode": "560038",
          "occupation": "Software Professional",
          "annualIncome": 1200000,
          "avatarUrl": "/uploads/1793601507202-569072927-profile.png",
          "createdAt": "2026-10-31T06:56:06.506Z",
          "updatedAt": "2026-11-02T08:28:41.347Z"
        }
      };

      final response = OnboardingUserDetailsResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.data?.id, 'cmvw1s0a4000113hmni4koswd');
      expect(response.data?.userId, 'cmuzhxi5a000asr4p9f6jcndp');
      expect(response.data?.dob, '1998-05-15');
      expect(response.data?.city, 'Bengaluru');
      expect(response.data?.state, 'Karnataka');
      expect(response.data?.occupation, 'Software Professional');
      expect(response.data?.annualIncome, 1200000);
      expect(response.data?.avatarUrl,
          '/uploads/1793601507202-569072927-profile.png');
    });

    test('5. POST /api/auth/onboarding/kyc-documents request & response parsing',
        () {
      const request = OnboardingKycDocumentsRequest(
        panNumber: 'ABCDE1234F',
        aadhaarNumber: '•••• •••• 9110',
      );

      final reqJson = request.toJson();
      expect(reqJson['panNumber'], 'ABCDE1234F');
      expect(reqJson['aadhaarNumber'], '•••• •••• 9110');

      final rawResponse = {
        "success": true,
        "message":
            "Onboarding Step 3: KYC document references attached successfully",
        "documentsCount": 2,
        "data": [
          {
            "id": "cmvz002ug0008thzqhni9k539",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "documentType": "PAN",
            "idNumber": "ABCDE1234F",
            "filePath": null,
            "fileName": "PAN_Card.pdf",
            "fileSize": 1420500,
            "mimeType": "application/pdf",
            "sha256Hash":
                "d56343d325cc132be5fe86f47ec9e1cc340067d86b84829a2dc54b3461f28b45",
            "status": "VERIFIED",
            "rejectionReason": null,
            "verifiedAt": "2026-11-02T08:29:42.375Z",
            "createdAt": "2026-11-02T08:29:42.376Z",
            "updatedAt": "2026-11-02T08:29:42.376Z"
          },
          {
            "id": "cmvz003ed000athzqizg9z73a",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "documentType": "AADHAAR",
            "idNumber": "•••• •••• 9110",
            "filePath": null,
            "fileName": "Masked_Aadhaar.pdf",
            "fileSize": 2150000,
            "mimeType": "application/pdf",
            "sha256Hash":
                "888df993b3d856f24a7b58112c5d344c8073feb3689824aff4ab909b98049f1b",
            "status": "VERIFIED",
            "rejectionReason": null,
            "verifiedAt": "2026-11-02T08:29:43.092Z",
            "createdAt": "2026-11-02T08:29:43.093Z",
            "updatedAt": "2026-11-02T08:29:43.093Z"
          }
        ]
      };

      final response = OnboardingKycDocumentsResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.documentsCount, 2);
      expect(response.data.length, 2);

      final pan = response.data[0];
      expect(pan.id, 'cmvz002ug0008thzqhni9k539');
      expect(pan.documentType, 'PAN');
      expect(pan.displayType, 'PAN Card');
      expect(pan.idNumber, 'ABCDE1234F');
      expect(pan.isVerified, true);
      expect(pan.sha256Hash.startsWith('d56343'), true);

      final aadhaar = response.data[1];
      expect(aadhaar.id, 'cmvz003ed000athzqizg9z73a');
      expect(aadhaar.documentType, 'AADHAAR');
      expect(aadhaar.displayType, 'Masked Aadhaar Card');
      expect(aadhaar.isVerified, true);
    });

    test('6. POST /api/auth/onboarding/consent request & response parsing', () {
      const request = OnboardingConsentRequest(
        consentTypes: ['ACCOUNT_AGGREGATOR', 'DPDP_ACT_2023', 'PRIVACY_POLICY'],
        isAgreed: true,
        version: 'v2.1',
      );

      final reqJson = request.toJson();
      expect(reqJson['consentTypes'],
          ['ACCOUNT_AGGREGATOR', 'DPDP_ACT_2023', 'PRIVACY_POLICY']);
      expect(reqJson['isAgreed'], true);
      expect(reqJson['version'], 'v2.1');

      final rawResponse = {
        "success": true,
        "message":
            "Onboarding Steps 4 & 5: Statutory consent and legal policy acceptance recorded",
        "data": {
          "userId": "cmuzhxi5a000asr4p9f6jcndp",
          "kycStatus": "VERIFIED",
          "redirectRoute": "/dashboard",
          "consents": [
            {
              "id": "cmvz01qub000dthzqxujxbjb2",
              "userId": "cmuzhxi5a000asr4p9f6jcndp",
              "consentType": "ACCOUNT_AGGREGATOR",
              "version": "v2.1",
              "isAgreed": true,
              "ipAddress": "::1",
              "userAgent": "PostmanRuntime/2.12.2",
              "timestamp": "2026-11-02T08:31:00.132Z"
            },
            {
              "id": "cmvz01re6000fthzq9i7x689u",
              "userId": "cmuzhxi5a000asr4p9f6jcndp",
              "consentType": "DPDP_ACT_2023",
              "version": "v2.1",
              "isAgreed": true,
              "ipAddress": "::1",
              "userAgent": "PostmanRuntime/2.12.2",
              "timestamp": "2026-11-02T08:31:00.846Z"
            },
            {
              "id": "cmvz01rxy000hthzq3i3pfgxf",
              "userId": "cmuzhxi5a000asr4p9f6jcndp",
              "consentType": "PRIVACY_POLICY",
              "version": "v2.1",
              "isAgreed": true,
              "ipAddress": "::1",
              "userAgent": "PostmanRuntime/2.12.2",
              "timestamp": "2026-11-02T08:31:01.558Z"
            }
          ]
        }
      };

      final response = OnboardingConsentResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.data?.userId, 'cmuzhxi5a000asr4p9f6jcndp');
      expect(response.data?.kycStatus, 'VERIFIED');
      expect(response.data?.redirectRoute, '/dashboard');
      expect(response.data?.consents.length, 3);
      expect(response.data?.consents[0].consentType, 'ACCOUNT_AGGREGATOR');
      expect(response.data?.consents[1].consentType, 'DPDP_ACT_2023');
      expect(response.data?.consents[2].consentType, 'PRIVACY_POLICY');
    });

    test('7. ApiConstants contains all 6 endpoints', () {
      expect(ApiConstants.signup, '/api/auth/signup');
      expect(ApiConstants.signupVerifyEmail, '/api/auth/signup/verify-email');
      expect(ApiConstants.signupVerifyMobile, '/api/auth/signup/verify-mobile');
      expect(ApiConstants.onboardingUserDetails,
          '/api/auth/onboarding/user-details');
      expect(ApiConstants.onboardingKycDocuments,
          '/api/auth/onboarding/kyc-documents');
      expect(ApiConstants.onboardingConsent, '/api/auth/onboarding/consent');
    });
  });
}
