import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/core/constants/api_constants.dart';
import 'package:finomos/features/auth_kyc/domain/auth_onboarding_models.dart';

void main() {
  group('Authentication & Session API Payloads and Serialization Tests', () {
    test('1. POST /api/auth/login (Email & Password) response parsing', () {
      final rawResponse = {
        "success": true,
        "message": "Login successful",
        "token": "jwt-token-cmuzhxi5a000asr4p9f6jcndp",
        "refreshToken":
            "ref-token-7d5e7606df7989d71155b370826932e971257de5969caa6c",
        "user": {
          "id": "cmuzhxi5a000asr4p9f6jcndp",
          "name": "Sireesha Podalakuru",
          "email": "sireesha@gmail.com",
          "phone": "8985839110",
          "kycStatus": "VERIFIED",
          "avatarUrl":
              "/uploads/1793435929233-532470338-3.Money Managment Screen.png"
        }
      };

      final response = LoginResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.message, 'Login successful');
      expect(response.token, 'jwt-token-cmuzhxi5a000asr4p9f6jcndp');
      expect(response.refreshToken,
          'ref-token-7d5e7606df7989d71155b370826932e971257de5969caa6c');
      expect(response.user?.id, 'cmuzhxi5a000asr4p9f6jcndp');
      expect(response.user?.name, 'Sireesha Podalakuru');
      expect(response.user?.email, 'sireesha@gmail.com');
      expect(response.user?.phone, '8985839110');
      expect(response.user?.kycStatus, 'VERIFIED');
      expect(response.user?.avatarUrl, isNotNull);
    });

    test('2. POST /api/auth/login (Mobile OTP) response parsing', () {
      final rawResponse = {
        "success": true,
        "message": "Mobile OTP login successful",
        "token": "jwt-token-cmvyvcl470000we4nf22eqh7w",
        "refreshToken":
            "ref-token-433d3e7e5573f41c13b07c2980e655c609ab989f15b2c4e4",
        "user": {
          "id": "cmvyvcl470000we4nf22eqh7w",
          "name": "Sireesha Bandaru",
          "email": "sireesha_test_api@finmos.com",
          "phone": "7207535810",
          "kycStatus": "VERIFIED",
          "avatarUrl": null
        }
      };

      final response = LoginResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.message, 'Mobile OTP login successful');
      expect(response.token, 'jwt-token-cmvyvcl470000we4nf22eqh7w');
      expect(response.user?.name, 'Sireesha Bandaru');
      expect(response.user?.phone, '7207535810');
      expect(response.user?.avatarUrl, isNull);
    });

    test('3. POST /api/auth/send-otp response parsing', () {
      final rawResponse = {
        "success": true,
        "message":
            "6-digit verification code dispatched via Twilio Carrier SMS to +917207535810",
        "data": {
          "success": true,
          "message":
              "6-digit verification code dispatched via Twilio Carrier SMS to +917207535810",
          "identifier": "+917207535810",
          "purpose": "LOGIN",
          "expiresInSeconds": 600,
          "dev_otp": "765549",
          "twilioStatus": "pending",
          "emailStatus": null,
          "twilioDetails": {
            "success": true,
            "status": "pending",
            "sid": "VE6a33e79fb051443653474c790e8177de"
          },
          "emailDetails": null
        }
      };

      final response = SendOtpResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.data?.identifier, '+917207535810');
      expect(response.data?.purpose, 'LOGIN');
      expect(response.data?.expiresInSeconds, 600);
      expect(response.data?.devOtp, '765549');
      expect(response.data?.twilioStatus, 'pending');
    });

    test('4. POST /api/auth/verify-otp response parsing', () {
      final rawResponse = {
        "success": true,
        "message": "OTP verified successfully",
        "verified": true,
        "token": "jwt-token-cmvyvcl470000we4nf22eqh7w",
        "refreshToken":
            "ref-token-50e3b515ea7b55f9f9cd5ea340cd01696684988a27bc9559",
        "user": {
          "id": "cmvyvcl470000we4nf22eqh7w",
          "name": "Sireesha Podalakuru",
          "email": "sireesha.podalakuru@finmos.test",
          "phone": "7207535810",
          "kycStatus": "VERIFIED"
        }
      };

      final response = VerifyOtpResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.verified, true);
      expect(response.token, 'jwt-token-cmvyvcl470000we4nf22eqh7w');
      expect(response.refreshToken,
          'ref-token-50e3b515ea7b55f9f9cd5ea340cd01696684988a27bc9559');
      expect(response.user?.name, 'Sireesha Podalakuru');
      expect(response.user?.kycStatus, 'VERIFIED');
    });

    test('5. POST /api/auth/refresh-token response parsing', () {
      final rawResponse = {
        "success": true,
        "message": "Session refreshed successfully",
        "token": "jwt-token-cmvyvcl470000we4nf22eqh7w",
        "refreshToken":
            "ref-token-3a7ff15f2c9da14e9b04f93facfe453e49c8845805a926ec",
        "user": {
          "id": "cmvyvcl470000we4nf22eqh7w",
          "name": "Sireesha Bandaru",
          "email": "sireesha_test_api@finmos.com"
        }
      };

      final response = RefreshTokenResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.message, 'Session refreshed successfully');
      expect(response.token, 'jwt-token-cmvyvcl470000we4nf22eqh7w');
      expect(response.refreshToken,
          'ref-token-3a7ff15f2c9da14e9b04f93facfe453e49c8845805a926ec');
      expect(response.user?.id, 'cmvyvcl470000we4nf22eqh7w');
      expect(response.user?.name, 'Sireesha Bandaru');
    });

    test('6. POST /api/auth/logout response parsing', () {
      final rawResponse = {
        "success": true,
        "message": "Successfully logged out. Session invalidated."
      };

      final response = AuthApiResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.message,
          'Successfully logged out. Session invalidated.');
    });

    test('7. POST /api/auth/forgot-password/request response parsing', () {
      final rawResponse = {
        "success": true,
        "message":
            "Password reset OTP dispatched to sireeshapodhalakur@gmail.com",
        "dev_otp": "482256"
      };

      final response = ForgotPasswordRequestResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.devOtp, '482256');
    });

    test('8. POST /api/auth/forgot-password/reset response parsing', () {
      final rawResponse = {
        "success": true,
        "message":
            "Password reset successfully. You can now login with your new password."
      };

      final response = ForgotPasswordResetResponse.fromJson(rawResponse);
      expect(response.success, true);
      expect(response.message,
          'Password reset successfully. You can now login with your new password.');
    });

    test('9. ApiConstants contains all Authentication endpoints', () {
      expect(ApiConstants.login, '/api/auth/login');
      expect(ApiConstants.sendOtp, '/api/auth/send-otp');
      expect(ApiConstants.verifyOtp, '/api/auth/verify-otp');
      expect(ApiConstants.refreshToken, '/api/auth/refresh-token');
      expect(ApiConstants.logout, '/api/auth/logout');
      expect(ApiConstants.forgotPasswordRequest,
          '/api/auth/forgot-password/request');
      expect(ApiConstants.forgotPasswordReset,
          '/api/auth/forgot-password/reset');
    });
  });
}

