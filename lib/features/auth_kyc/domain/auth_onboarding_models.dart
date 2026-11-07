import 'kyc_models.dart';

/// Request body for POST /api/auth/signup
class SignupRequest {
  final String name;
  final String email;
  final String phone;
  final String password;

  const SignupRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.replaceAll(RegExp(r'\s+'), '').replaceAll('+91', '').trim(),
      'password': password.trim(),
    };
  }
}

/// User info returned inside POST /api/auth/signup
class SignupUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String kycStatus;

  const SignupUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.kycStatus,
  });

  factory SignupUser.fromJson(Map<String, dynamic> json) {
    return SignupUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      kycStatus: json['kycStatus'] as String? ?? 'INCOMPLETE',
    );
  }
}

/// Response payload from POST /api/auth/signup
class SignupResponse {
  final bool success;
  final String message;
  final String userId;
  final String token;
  final String? refreshToken;
  final SignupUser? user;
  final String? devOtp;
  final String? emailOtp;
  final String? phoneOtp;

  const SignupResponse({
    required this.success,
    required this.message,
    required this.userId,
    required this.token,
    this.refreshToken,
    this.user,
    this.devOtp,
    this.emailOtp,
    this.phoneOtp,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      success: json['success'] as bool? ?? false,
      message: (json['message'] ?? json['error'] ?? '') as String,
      userId: json['userId'] as String? ?? '',
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] is Map<String, dynamic>
          ? SignupUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      devOtp: json['dev_otp'] as String?,
      emailOtp: json['email_otp'] as String?,
      phoneOtp: json['phone_otp'] as String?,
    );
  }
}

/// Standard response model for verification endpoints
class AuthApiResponse {
  final bool success;
  final String message;

  const AuthApiResponse({
    required this.success,
    required this.message,
  });

  factory AuthApiResponse.fromJson(Map<String, dynamic> json) {
    return AuthApiResponse(
      success: json['success'] as bool? ?? false,
      message: (json['message'] ?? json['error'] ?? '') as String,
    );
  }
}

/// Request body for PUT /api/auth/onboarding/user-details
class OnboardingUserDetailsRequest {
  final String dob;
  final String gender;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String occupation;
  final num annualIncome;

  const OnboardingUserDetailsRequest({
    required this.dob,
    required this.gender,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.occupation,
    required this.annualIncome,
  });

  Map<String, dynamic> toJson() {
    return {
      'dob': dob.trim(),
      'gender': gender.trim(),
      'address': address.trim(),
      'city': city.trim(),
      'state': state.trim(),
      'pinCode': pinCode.trim(),
      'occupation': occupation.trim(),
      'annualIncome': annualIncome,
    };
  }
}

/// Data body returned by PUT /api/auth/onboarding/user-details
class OnboardingUserDetailsData {
  final String id;
  final String userId;
  final String dob;
  final String gender;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String occupation;
  final num annualIncome;
  final String? avatarUrl;
  final String? createdAt;
  final String? updatedAt;

  const OnboardingUserDetailsData({
    required this.id,
    required this.userId,
    required this.dob,
    required this.gender,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.occupation,
    required this.annualIncome,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory OnboardingUserDetailsData.fromJson(Map<String, dynamic> json) {
    return OnboardingUserDetailsData(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pinCode: json['pinCode'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      annualIncome: (json['annualIncome'] as num?) ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

/// Response payload from PUT /api/auth/onboarding/user-details
class OnboardingUserDetailsResponse {
  final bool success;
  final String message;
  final OnboardingUserDetailsData? data;

  const OnboardingUserDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OnboardingUserDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingUserDetailsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? OnboardingUserDetailsData.fromJson(
              json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Request body for POST /api/auth/onboarding/kyc-documents
class OnboardingKycDocumentsRequest {
  final String panNumber;
  final String aadhaarNumber;

  const OnboardingKycDocumentsRequest({
    required this.panNumber,
    required this.aadhaarNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'panNumber': panNumber.trim().toUpperCase(),
      'aadhaarNumber': aadhaarNumber.trim(),
    };
  }
}

/// Response payload from POST /api/auth/onboarding/kyc-documents
class OnboardingKycDocumentsResponse {
  final bool success;
  final String message;
  final int documentsCount;
  final List<KycDocumentItem> data;

  const OnboardingKycDocumentsResponse({
    required this.success,
    required this.message,
    required this.documentsCount,
    required this.data,
  });

  factory OnboardingKycDocumentsResponse.fromJson(Map<String, dynamic> json) {
    final rawDocs = json['data'] as List<dynamic>? ?? [];
    return OnboardingKycDocumentsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      documentsCount: (json['documentsCount'] as num?)?.toInt() ?? rawDocs.length,
      data: rawDocs
          .whereType<Map<String, dynamic>>()
          .map((d) => KycDocumentItem.fromJson(d))
          .toList(),
    );
  }
}

/// Request body for POST /api/auth/onboarding/consent
class OnboardingConsentRequest {
  final List<String> consentTypes;
  final bool isAgreed;
  final String version;

  const OnboardingConsentRequest({
    this.consentTypes = const [
      'ACCOUNT_AGGREGATOR',
      'DPDP_ACT_2023',
      'PRIVACY_POLICY'
    ],
    this.isAgreed = true,
    this.version = 'v2.1',
  });

  Map<String, dynamic> toJson() {
    return {
      'consentTypes': consentTypes,
      'isAgreed': isAgreed,
      'version': version,
    };
  }
}

/// Individual consent record item
class ConsentRecordItem {
  final String id;
  final String userId;
  final String consentType;
  final String version;
  final bool isAgreed;
  final String? ipAddress;
  final String? userAgent;
  final String? timestamp;

  const ConsentRecordItem({
    required this.id,
    required this.userId,
    required this.consentType,
    required this.version,
    required this.isAgreed,
    this.ipAddress,
    this.userAgent,
    this.timestamp,
  });

  factory ConsentRecordItem.fromJson(Map<String, dynamic> json) {
    return ConsentRecordItem(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      consentType: json['consentType'] as String? ?? '',
      version: json['version'] as String? ?? 'v2.1',
      isAgreed: json['isAgreed'] as bool? ?? true,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      timestamp: json['timestamp'] as String?,
    );
  }
}

/// Data body inside POST /api/auth/onboarding/consent response
class OnboardingConsentData {
  final String userId;
  final String kycStatus;
  final String redirectRoute;
  final List<ConsentRecordItem> consents;

  const OnboardingConsentData({
    required this.userId,
    required this.kycStatus,
    required this.redirectRoute,
    required this.consents,
  });

  factory OnboardingConsentData.fromJson(Map<String, dynamic> json) {
    final rawConsents = json['consents'] as List<dynamic>? ?? [];
    return OnboardingConsentData(
      userId: json['userId'] as String? ?? '',
      kycStatus: json['kycStatus'] as String? ?? 'VERIFIED',
      redirectRoute: json['redirectRoute'] as String? ?? '/dashboard',
      consents: rawConsents
          .whereType<Map<String, dynamic>>()
          .map((c) => ConsentRecordItem.fromJson(c))
          .toList(),
    );
  }
}

/// Response payload from POST /api/auth/onboarding/consent
class OnboardingConsentResponse {
  final bool success;
  final String message;
  final OnboardingConsentData? data;

  const OnboardingConsentResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OnboardingConsentResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingConsentResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? OnboardingConsentData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}



/// Shared user object returned by login, verify-otp, and refresh-token
class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? kycStatus;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.kycStatus,
    this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      kycStatus: json['kycStatus'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

/// Response payload from POST /api/auth/login
class LoginResponse {
  final bool success;
  final String message;
  final String token;
  final String? refreshToken;
  final AuthUser? user;

  const LoginResponse({
    required this.success,
    required this.message,
    required this.token,
    this.refreshToken,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] is Map<String, dynamic>
          ? AuthUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Internal data payload from POST /api/auth/send-otp
class SendOtpData {
  final bool success;
  final String message;
  final String identifier;
  final String purpose;
  final int expiresInSeconds;
  final String? devOtp;
  final String? twilioStatus;

  const SendOtpData({
    required this.success,
    required this.message,
    required this.identifier,
    required this.purpose,
    required this.expiresInSeconds,
    this.devOtp,
    this.twilioStatus,
  });

  factory SendOtpData.fromJson(Map<String, dynamic> json) {
    return SendOtpData(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      identifier: json['identifier'] as String? ?? '',
      purpose: json['purpose'] as String? ?? 'LOGIN',
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 600,
      devOtp: json['dev_otp'] as String?,
      twilioStatus: json['twilioStatus'] as String?,
    );
  }
}

/// Response payload from POST /api/auth/send-otp
class SendOtpResponse {
  final bool success;
  final String message;
  final SendOtpData? data;

  const SendOtpResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SendOtpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Response payload from POST /api/auth/verify-otp
class VerifyOtpResponse {
  final bool success;
  final String message;
  final bool verified;
  final String token;
  final String? refreshToken;
  final AuthUser? user;

  const VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.verified,
    required this.token,
    this.refreshToken,
    this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] is Map<String, dynamic>
          ? AuthUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Response payload from POST /api/auth/refresh-token
class RefreshTokenResponse {
  final bool success;
  final String message;
  final String token;
  final String refreshToken;
  final AuthUser? user;

  const RefreshTokenResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.refreshToken,
    this.user,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: json['user'] is Map<String, dynamic>
          ? AuthUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Response payload from POST /api/auth/forgot-password/request
class ForgotPasswordRequestResponse {
  final bool success;
  final String message;
  final String? devOtp;

  const ForgotPasswordRequestResponse({
    required this.success,
    required this.message,
    this.devOtp,
  });

  factory ForgotPasswordRequestResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequestResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      devOtp: json['dev_otp'] as String?,
    );
  }
}

/// Response payload from POST /api/auth/forgot-password/reset
class ForgotPasswordResetResponse {
  final bool success;
  final String message;

  const ForgotPasswordResetResponse({
    required this.success,
    required this.message,
  });

  factory ForgotPasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResetResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}
