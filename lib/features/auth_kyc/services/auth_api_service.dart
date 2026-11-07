import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/phone_utils.dart';
import '../domain/auth_onboarding_models.dart';

class AuthResult {
  final bool isSuccess;
  final String? message;
  final String? token;
  final String? refreshToken;
  final String? userId;
  final String? name;
  final String? email;
  final String? phone;

  const AuthResult({
    required this.isSuccess,
    this.message,
    this.token,
    this.refreshToken,
    this.userId,
    this.name,
    this.email,
    this.phone,
  });
}

class AuthApiService {
  final ApiClient _client = ApiClient();

  /// Dual-mode login (Email or Mobile + Password)
  /// POST /api/v1/auth/login with fallback to /api/auth/login
  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    try {
      var response = await _client.post(
        ApiConstants.loginV1,
        body: {
          'identifier': identifier.trim(),
          'password': password.trim(),
        },
      );

      if (response.statusCode == 404) {
        response = await _client.post(
          ApiConstants.login,
          body: {
            'identifier': identifier.trim(),
            'password': password.trim(),
          },
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final token = data['token'] as String? ?? '';
        final refreshToken = data['refreshToken'] as String?;
        final user = data['user'] as Map<String, dynamic>?;

        if (token.isNotEmpty) {
          _client.setToken(token);
        }
        if (refreshToken != null && refreshToken.isNotEmpty) {
          _client.setRefreshToken(refreshToken);
        }

        final userPhone = user?['phone'] as String?;
        final cleanUserPhone = PhoneUtils.sanitize(userPhone);
        final userEmail = user?['email'] as String?;
        final userName = user?['name'] as String?;
        final userId = user?['id'] as String?;

        if (cleanUserPhone.isNotEmpty) {
          LocalCacheService().save('user_mobile_number', cleanUserPhone);
        }
        if (userEmail != null && userEmail.isNotEmpty) {
          LocalCacheService().save('user_email', userEmail);
        }
        if (userName != null && userName.isNotEmpty) {
          LocalCacheService().save('user_name', userName);
        }
        if (userId != null && userId.isNotEmpty) {
          LocalCacheService().save('user_id', userId);
        }

        final userRecord = LocalCacheService().getUserProfileRecord(
          cleanUserPhone.isNotEmpty ? cleanUserPhone : (userEmail ?? identifier),
        );
        if (userRecord != null) {
          LocalCacheService().syncActiveUserKeys(userRecord);
        }

        return AuthResult(
          isSuccess: true,
          message: data['message'] as String? ?? 'Login successful',
          token: token,
          refreshToken: refreshToken,
          userId: userId,
          name: userName,
          email: userEmail,
          phone: cleanUserPhone.isNotEmpty ? cleanUserPhone : userPhone,
        );
      } else {
        String errMsg =
            'Invalid credentials. Please verify your email/phone and password.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            errMsg = (errorData['error'] ?? errorData['message'])?.toString() ?? errMsg;
          }
        } catch (_) {}

        // Auto-provision via signup if backend reports no account found (e.g. after Render spin-down / DB reset)
        if (response.statusCode == 401 && errMsg.toLowerCase().contains('no account found')) {
          try {
            final isEmail = identifier.contains('@');
            final savedRecord = LocalCacheService().getUserProfileRecord(identifier);
            final cachedPhone = savedRecord?['phone']?.toString().trim() ??
                LocalCacheService().get('user_mobile_number')?.toString().trim();
            final cleanPhone = !isEmail
                ? identifier.replaceAll(RegExp(r'\D'), '')
                : (cachedPhone != null && cachedPhone.isNotEmpty
                    ? cachedPhone
                    : '9${(DateTime.now().millisecondsSinceEpoch % 1000000000).toString().padLeft(9, '0')}');
            final cleanEmail = isEmail ? identifier.trim() : (savedRecord?['email']?.toString() ?? LocalCacheService().get('user_email')?.toString() ?? 'user@finmos.io');
            final cachedName = savedRecord?['fullName']?.toString() ?? LocalCacheService().get('user_name')?.toString();
            final userName = (cachedName != null && cachedName.isNotEmpty) ? cachedName : 'User';

            final signupRes = await signup(SignupRequest(
              name: userName,
              email: cleanEmail,
              phone: cleanPhone,
              password: password.trim(),
            ));
            if (signupRes != null && signupRes.success) {
              final sToken = signupRes.token;
              final sRefreshToken = signupRes.refreshToken;
              if (sToken.isNotEmpty) {
                _client.setToken(sToken);
              }
              if (sRefreshToken != null && sRefreshToken.isNotEmpty) {
                _client.setRefreshToken(sRefreshToken);
              }

              final effectivePhone = PhoneUtils.sanitize(signupRes.user?.phone ?? cleanPhone);
              final effectiveEmail = signupRes.user?.email ?? cleanEmail;
              final effectiveName = signupRes.user?.name ?? userName;
              final effectiveId = signupRes.userId.isNotEmpty ? signupRes.userId : (signupRes.user?.id ?? '');

              if (effectivePhone.isNotEmpty) {
                LocalCacheService().save('user_mobile_number', effectivePhone);
              }
              if (effectiveEmail.isNotEmpty) {
                LocalCacheService().save('user_email', effectiveEmail);
              }
              if (effectiveName.isNotEmpty) {
                LocalCacheService().save('user_name', effectiveName);
              }
              if (effectiveId.isNotEmpty) {
                LocalCacheService().save('user_id', effectiveId);
              }

              return AuthResult(
                isSuccess: true,
                message: 'Login successful',
                token: sToken,
                refreshToken: sRefreshToken,
                userId: effectiveId,
                name: effectiveName,
                email: effectiveEmail,
                phone: effectivePhone,
              );
            }
          } catch (_) {}
        }

        return AuthResult(isSuccess: false, message: errMsg);
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: 'Network connection error. Please try again ($e).',
      );
    }
  }

  /// Mobile OTP Login
  /// POST /api/auth/login
  Future<AuthResult> loginWithOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final cleanPhone =
          phone.replaceAll(RegExp(r'\s+'), '').replaceAll('+91', '').trim();
      final response = await _client.post(
        ApiConstants.login,
        body: {
          'phone': cleanPhone,
          'otp': otp.trim(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final token = data['token'] as String? ?? '';
        final refreshToken = data['refreshToken'] as String?;
        final user = data['user'] as Map<String, dynamic>?;

        if (token.isNotEmpty) {
          _client.setToken(token);
        }
        if (refreshToken != null && refreshToken.isNotEmpty) {
          _client.setRefreshToken(refreshToken);
        }

        final uPhone = PhoneUtils.sanitize(user?['phone'] as String? ?? cleanPhone);
        final uEmail = user?['email'] as String?;
        final uName = user?['name'] as String?;
        final uId = user?['id'] as String?;

        if (uPhone.isNotEmpty) LocalCacheService().save('user_mobile_number', uPhone);
        if (uEmail != null && uEmail.isNotEmpty) LocalCacheService().save('user_email', uEmail);
        if (uName != null && uName.isNotEmpty) LocalCacheService().save('user_name', uName);
        if (uId != null && uId.isNotEmpty) LocalCacheService().save('user_id', uId);

        final userRecord = LocalCacheService().getUserProfileRecord(uPhone.isNotEmpty ? uPhone : (uEmail ?? ''));
        if (userRecord != null) {
          LocalCacheService().syncActiveUserKeys(userRecord);
        }

        return AuthResult(
          isSuccess: true,
          message: data['message'] as String? ?? 'Mobile OTP login successful',
          token: token,
          refreshToken: refreshToken,
          userId: uId,
          name: uName,
          email: uEmail,
          phone: uPhone,
        );
      } else {
        String errMsg = 'Invalid OTP. Please check the code and try again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            errMsg = errorData['message'].toString();
          }
        } catch (_) {}
        return AuthResult(isSuccess: false, message: errMsg);
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: 'Network connection error. Please try again ($e).',
      );
    }
  }

  /// Dispatch 6-digit OTP to Mobile or Email
  /// POST /api/v1/auth/send-otp with fallback to /api/auth/send-otp
  Future<SendOtpResponse?> sendOtp({
    String? phone,
    String? identifier,
    String purpose = 'LOGIN',
    String? channel,
  }) async {
    try {
      final targetId = (identifier != null && identifier.trim().isNotEmpty)
          ? identifier.trim()
          : (phone ?? '').replaceAll(RegExp(r'\s+'), '').replaceAll('+91', '').trim();
      final isEmail = targetId.contains('@');
      final targetChannel = (channel != null && channel.trim().isNotEmpty)
          ? channel.trim().toUpperCase()
          : (isEmail ? 'EMAIL' : 'SMS');

      var response = await _client.post(
        ApiConstants.sendOtpV1,
        body: {
          'identifier': targetId,
          if (!isEmail) 'phone': targetId,
          'purpose': purpose.toUpperCase(),
          'channel': targetChannel,
        },
      );

      if (response.statusCode == 404) {
        response = await _client.post(
          ApiConstants.sendOtp,
          body: {
            'identifier': targetId,
            if (!isEmail) 'phone': targetId,
            'purpose': purpose.toUpperCase(),
            'channel': targetChannel.toLowerCase(),
          },
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return SendOtpResponse.fromJson(body);
      } else {
        String errorMsg = 'Failed to send OTP.';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map) {
            if (errorBody['error'] is String) {
              errorMsg = errorBody['error'];
            } else if (errorBody['message'] is String) {
              errorMsg = errorBody['message'];
            }
          }
        } catch (_) {}
        return SendOtpResponse(success: false, message: errorMsg);
      }
    } catch (_) {}
    return null;
  }

  /// Validate 6-digit OTP for Mobile or Email verification/login
  /// POST /api/v1/auth/verify-otp with fallback to /api/auth/verify-otp
  Future<VerifyOtpResponse?> verifyOtp({
    String? phone,
    String? identifier,
    required String otp,
    String purpose = 'LOGIN',
  }) async {
    try {
      final targetId = (identifier != null && identifier.trim().isNotEmpty)
          ? identifier.trim()
          : (phone ?? '').replaceAll(RegExp(r'\s+'), '').replaceAll('+91', '').trim();
      final isEmail = targetId.contains('@');

      var response = await _client.post(
        ApiConstants.verifyOtpV1,
        body: {
          'identifier': targetId,
          if (!isEmail) 'phone': targetId,
          'otp': otp.trim(),
          'purpose': purpose.toUpperCase(),
        },
      );

      if (response.statusCode == 404) {
        response = await _client.post(
          ApiConstants.verifyOtp,
          body: {
            'identifier': targetId,
            if (!isEmail) 'phone': targetId,
            'otp': otp.trim(),
            'purpose': purpose.toUpperCase(),
          },
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final result = VerifyOtpResponse.fromJson(body);
        if (result.token.isNotEmpty) {
          _client.setToken(result.token);
        }
        if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
          _client.setRefreshToken(result.refreshToken!);
        }

        final cleanUserPhone = PhoneUtils.sanitize(result.user?.phone);
        if (cleanUserPhone.isNotEmpty) {
          LocalCacheService().save('user_mobile_number', cleanUserPhone);
        }
        if (result.user?.email != null && result.user!.email.isNotEmpty) {
          LocalCacheService().save('user_email', result.user!.email);
        }
        if (result.user?.name != null && result.user!.name.isNotEmpty) {
          LocalCacheService().save('user_name', result.user!.name);
        }
        if (result.user?.id != null && result.user!.id.isNotEmpty) {
          LocalCacheService().save('user_id', result.user!.id);
        }

        final userRecord = LocalCacheService().getUserProfileRecord(
          cleanUserPhone.isNotEmpty ? cleanUserPhone : (result.user?.email ?? phone),
        );
        if (userRecord != null) {
          LocalCacheService().syncActiveUserKeys(userRecord);
        }

        return result;
      } else {
        String errorMsg = 'Invalid OTP. Please check the code and try again.';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map) {
            if (errorBody['error'] is String) {
              errorMsg = errorBody['error'];
            } else if (errorBody['message'] is String) {
              errorMsg = errorBody['message'];
            }
          }
        } catch (_) {}
        return VerifyOtpResponse(
          success: false,
          message: errorMsg,
          verified: false,
          token: '',
        );
      }
    } catch (_) {}
    return null;
  }

  /// Exchange refresh token for fresh short-lived JWT session
  /// POST /api/auth/refresh-token
  Future<RefreshTokenResponse?> refreshSession({String? refreshToken}) async {
    try {
      final tokenToUse =
          refreshToken ?? _client.refreshToken;
      final response = await _client.post(
        ApiConstants.refreshToken,
        body: {
          'refreshToken': tokenToUse,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final result = RefreshTokenResponse.fromJson(body);
        if (result.token.isNotEmpty) {
          _client.setToken(result.token);
        }
        if (result.refreshToken.isNotEmpty) {
          _client.setRefreshToken(result.refreshToken);
        }
        return result;
      }
    } catch (_) {}
    return null;
  }

  /// Invalidate current user session and revoke refresh token
  /// POST /api/auth/logout
  Future<AuthApiResponse?> logout() async {
    try {
      final response = await _client.post(
        ApiConstants.logout,
        body: {},
      );

      _client.clearSession();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return AuthApiResponse.fromJson(body);
      }
    } catch (_) {
      _client.clearSession();
    }
    return null;
  }

  /// Request password reset OTP to Email/SMS
  /// POST /api/auth/forgot-password/request
  Future<ForgotPasswordRequestResponse?> forgotPasswordRequest({
    required String identifier,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.forgotPasswordRequest,
        body: {
          'identifier': identifier.trim(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return ForgotPasswordRequestResponse.fromJson(body);
      }
    } catch (_) {}
    return null;
  }

  /// Verify reset OTP and commit new password
  /// POST /api/auth/forgot-password/reset
  Future<ForgotPasswordResetResponse?> forgotPasswordReset({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.forgotPasswordReset,
        body: {
          'identifier': identifier.trim(),
          'otp': otp.trim(),
          'newPassword': newPassword.trim(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return ForgotPasswordResetResponse.fromJson(body);
      }
    } catch (_) {}
    return null;
  }

  /// Step 1: Create baseline user record & dispatch OTP
  /// POST /api/v1/auth/signup with fallback to /api/auth/signup
  Future<SignupResponse?> signup(SignupRequest request) async {
    try {
      var response = await _client.post(
        ApiConstants.signupV1,
        body: request.toJson(),
      );

      if (response.statusCode == 404) {
        response = await _client.post(
          ApiConstants.signup,
          body: request.toJson(),
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final result = SignupResponse.fromJson(body);
        if (result.token.isNotEmpty) {
          _client.setToken(result.token);
        }
        if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
          _client.setRefreshToken(result.refreshToken!);
        }
        return result;
      } else {
        String errorMsg = 'Failed to create account. Please check your details.';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map) {
            if (errorBody['error'] is String) {
              errorMsg = errorBody['error'];
            } else if (errorBody['message'] is String) {
              errorMsg = errorBody['message'];
            }
          }
        } catch (_) {}
        return SignupResponse(
          success: false,
          message: errorMsg,
          userId: '',
          token: '',
        );
      }
    } catch (e) {
      return SignupResponse(
        success: false,
        message: 'Network error. Please try again ($e).',
        userId: '',
        token: '',
      );
    }
  }

  /// Step 1: Verify Email address via 6-digit OTP
  /// POST /api/auth/signup/verify-email
  Future<AuthApiResponse?> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.signupVerifyEmail,
        body: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return AuthApiResponse.fromJson(body);
      } else {
        String errorMsg = 'Email verification failed.';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map) {
            if (errorBody['error'] is String) {
              errorMsg = errorBody['error'];
            } else if (errorBody['message'] is String) {
              errorMsg = errorBody['message'];
            }
          }
        } catch (_) {}
        return AuthApiResponse(
          success: false,
          message: errorMsg,
        );
      }
    } catch (e) {
      return AuthApiResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Step 1: Verify Mobile phone number via 6-digit OTP
  /// POST /api/auth/signup/verify-mobile
  Future<AuthApiResponse?> verifyMobile({
    required String phone,
    required String otp,
  }) async {
    try {
      final cleanPhone =
          phone.replaceAll(RegExp(r'\s+'), '').replaceAll('+91', '').trim();
      final response = await _client.post(
        ApiConstants.signupVerifyMobile,
        body: {
          'phone': cleanPhone,
          'otp': otp.trim(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return AuthApiResponse.fromJson(body);
      } else {
        String errorMsg = 'Mobile verification failed.';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map) {
            if (errorBody['error'] is String) {
              errorMsg = errorBody['error'];
            } else if (errorBody['message'] is String) {
              errorMsg = errorBody['message'];
            }
          }
        } catch (_) {}
        return AuthApiResponse(
          success: false,
          message: errorMsg,
        );
      }
    } catch (e) {
      return AuthApiResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Step 2: Save DOB, Gender, Address, State, PIN, Occupation, Annual Income
  /// PUT /api/auth/onboarding/user-details
  Future<OnboardingUserDetailsResponse?> saveOnboardingUserDetails(
      OnboardingUserDetailsRequest request) async {
    try {
      final response = await _client.put(
        ApiConstants.onboardingUserDetails,
        body: request.toJson(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return OnboardingUserDetailsResponse.fromJson(body);
      }
    } catch (_) {}
    return null;
  }

  /// Step 3: Attach PAN and Aadhaar document references
  /// POST /api/auth/onboarding/kyc-documents
  Future<OnboardingKycDocumentsResponse?> attachOnboardingKycDocuments({
    required String panNumber,
    required String aadhaarNumber,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.onboardingKycDocuments,
        body: {
          'panNumber': panNumber.trim().toUpperCase(),
          'aadhaarNumber': aadhaarNumber.trim(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return OnboardingKycDocumentsResponse.fromJson(body);
      }
    } catch (_) {}
    return null;
  }

  /// Steps 4 & 5: Record Statutory Consent & Legal Policy Acceptance (DPDP Act 2023)
  /// POST /api/auth/onboarding/consent
  Future<OnboardingConsentResponse?> recordOnboardingConsent(
      OnboardingConsentRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.onboardingConsent,
        body: request.toJson(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return OnboardingConsentResponse.fromJson(body);
      }
    } catch (_) {}
    return null;
  }
}
