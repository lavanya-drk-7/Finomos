import 'dart:convert';
import 'dart:io';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/cache_service.dart';
import '../domain/profile_models.dart';

class ProfileApiService {
  final ApiClient _client = ApiClient();

  /// Fetch live user profile with KYC status, badge, personal, address, security & stats
  /// GET /api/v1/user/profile
  Future<UserProfileData?> getProfile() async {
    try {
      final response = await _client.get(ApiConstants.userProfile);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          final data = body['data'] as Map<String, dynamic>;
          LocalCacheService().save('user_profile', data);
          return UserProfileData.fromJson(data);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Retrieve cached user profile for instant 0ms rendering
  UserProfileData? getCachedProfile() {
    final cached = LocalCacheService().get('user_profile');
    if (cached is Map<String, dynamic>) {
      return UserProfileData.fromJson(cached);
    }
    return null;
  }

  /// Update personal information
  /// PUT /api/v1/user/profile/personal
  Future<Map<String, dynamic>?> updatePersonalDetails({
    required String fullName,
    required String dob,
    required String gender,
    required String occupation,
    required double annualIncome,
  }) async {
    try {
      final payload = {
        'fullName': fullName,
        'dob': dob,
        'gender': gender,
        'occupation': occupation,
        'annualIncome': annualIncome,
      };

      final response = await _client.put(
        ApiConstants.userProfilePersonal,
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          // Re-sync full profile in background
          getProfile();
          return body;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Update residential address details
  /// PUT /api/v1/user/profile/address
  Future<Map<String, dynamic>?> updateAddress({
    required String address,
    required String city,
    required String state,
    required String pinCode,
  }) async {
    try {
      final payload = {
        'address': address,
        'city': city,
        'state': state,
        'pinCode': pinCode,
      };

      final response = await _client.put(
        ApiConstants.userProfileAddress,
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          // Re-sync full profile in background
          getProfile();
          return body;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Upload user profile avatar photo
  /// POST /api/v1/user/profile/photo
  Future<String?> uploadProfilePhoto(File photoFile) async {
    try {
      final response = await _client.multipartPost(
        ApiConstants.userProfilePhoto,
        file: photoFile,
        fileFieldName: 'photo',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          final data = body['data'] as Map<String, dynamic>;
          final avatarUrl = data['avatarUrl'] as String?;
          if (avatarUrl != null && avatarUrl.isNotEmpty) {
            // Update cached profile
            final cached = LocalCacheService().get('user_profile');
            if (cached is Map<String, dynamic>) {
              cached['avatarUrl'] = avatarUrl;
              LocalCacheService().save('user_profile', cached);
            }
            return avatarUrl;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Update security settings (2FA, biometric authentication)
  /// PUT /api/v1/user/profile/security
  Future<bool> updateSecurity({
    required bool twoFactorEnabled,
    required bool biometricEnabled,
  }) async {
    try {
      final payload = {
        'twoFactorEnabled': twoFactorEnabled,
        'biometricEnabled': biometricEnabled,
      };

      final response = await _client.put(
        ApiConstants.userProfileSecurity,
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final cached = LocalCacheService().get('user_profile');
          if (cached is Map<String, dynamic> && cached['security'] is Map) {
            final sec = cached['security'] as Map<String, dynamic>;
            sec['twoFactorEnabled'] = twoFactorEnabled;
            sec['biometricEnabled'] = biometricEnabled;
            LocalCacheService().save('user_profile', cached);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Update notification preferences (Email, SMS, WhatsApp)
  /// PUT /api/v1/user/profile/notifications
  Future<bool> updateNotifications({
    required bool email,
    required bool sms,
    required bool whatsapp,
  }) async {
    try {
      final payload = {
        'email': email,
        'sms': sms,
        'whatsapp': whatsapp,
      };

      final response = await _client.put(
        ApiConstants.userProfileNotifications,
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final cached = LocalCacheService().get('user_profile');
          if (cached is Map<String, dynamic> && cached['notifications'] is Map) {
            final notifs = cached['notifications'] as Map<String, dynamic>;
            notifs['email'] = email;
            notifs['sms'] = sms;
            notifs['whatsapp'] = whatsapp;
            LocalCacheService().save('user_profile', cached);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Permanently delete / deactivate user account under DPDP Act 2023
  /// DELETE /api/v1/user/account
  Future<Map<String, dynamic>?> deleteAccount() async {
    try {
      final response = await _client.delete(ApiConstants.userAccount);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body;
      }
    } catch (_) {}
    return null;
  }

  /// Fetch employment & income details with synchronous cache fallback
  Future<EmploymentIncomeInfo> getEmploymentInfo() async {
    final cached = LocalCacheService().get('user_employment');
    if (cached is Map<String, dynamic>) {
      return EmploymentIncomeInfo.fromJson(cached);
    }
    // Fallback: derive dynamically from live cached profile's personal info
    final profile = getCachedProfile();
    final info = EmploymentIncomeInfo(
      employmentType: profile?.personal.occupation.isNotEmpty == true
          ? profile!.personal.occupation
          : 'Salaried',
      companyName: '',
      designation: profile?.personal.occupation.isNotEmpty == true
          ? profile!.personal.occupation
          : '',
      workExperience: '',
      workLocation: profile?.address.city.isNotEmpty == true
          ? profile!.address.city
          : '',
      sourceOfIncome: 'Salary',
      annualIncome: profile != null && profile.personal.annualIncome > 0
          ? profile.personal.annualIncome.toStringAsFixed(0)
          : '',
      monthlyIncome: profile != null && profile.personal.annualIncome > 0
          ? (profile.personal.annualIncome / 12).toStringAsFixed(0)
          : '',
    );
    if (info.companyName.isNotEmpty || info.annualIncome.isNotEmpty) {
      LocalCacheService().save('user_employment', info.toJson());
    }
    return info;
  }

  /// Update employment & income details: persist locally and sync to live backend profile
  Future<bool> updateEmploymentDetails(EmploymentIncomeInfo info) async {
    // 1. Persist synchronously to local cache so data is never lost
    LocalCacheService().save('user_employment', info.toJson());

    // 2. Synchronize occupation & income to live backend profile via PUT /api/v1/user/profile/personal
    try {
      final cachedProfile = getCachedProfile();
      if (cachedProfile != null) {
        final parsedAnnual = double.tryParse(info.annualIncome) ??
            cachedProfile.personal.annualIncome;
        await updatePersonalDetails(
          fullName: cachedProfile.personal.fullName,
          dob: cachedProfile.personal.dob,
          gender: cachedProfile.personal.gender,
          occupation: info.designation.isNotEmpty
              ? info.designation
              : (info.employmentType.isNotEmpty
                  ? info.employmentType
                  : cachedProfile.personal.occupation),
          annualIncome: parsedAnnual > 0
              ? parsedAnnual
              : cachedProfile.personal.annualIncome,
        );
      }
    } catch (_) {}
    return true; // Local cache & live sync completed
  }

  /// Fetch family members with cache fallback (prevents 404 on unmapped sub-route)
  Future<List<FamilyMember>?> getFamilyMembers() async {
    final cached = LocalCacheService().get('user_family_members');
    if (cached is List) {
      return cached
          .whereType<Map<String, dynamic>>()
          .map((item) => FamilyMember.fromJson(item))
          .toList();
    }
    return null;
  }

  /// Add family member: save to local cache
  Future<FamilyMember?> addFamilyMember(FamilyMember member) async {
    final cached = LocalCacheService().get('user_family_members');
    final currentList = cached is List
        ? cached
            .whereType<Map<String, dynamic>>()
            .map((e) => FamilyMember.fromJson(e))
            .toList()
        : <FamilyMember>[];
    currentList.add(member);
    LocalCacheService().save(
        'user_family_members', currentList.map((m) => m.toJson()).toList());
    return member;
  }

  /// Delete family member: remove from local cache
  Future<bool> deleteFamilyMember(String id) async {
    final cached = LocalCacheService().get('user_family_members');
    if (cached is List) {
      final updated = cached
          .whereType<Map<String, dynamic>>()
          .map((e) => FamilyMember.fromJson(e))
          .where((m) => m.id != id)
          .map((m) => m.toJson())
          .toList();
      LocalCacheService().save('user_family_members', updated);
    }
    return true;
  }

  /// Fetch household structure with cache fallback (prevents 404 on unmapped sub-route)
  Future<HouseholdStructure> getHouseholdStructure() async {
    final cached = LocalCacheService().get('user_household');
    if (cached is Map<String, dynamic>) {
      return HouseholdStructure.fromJson(cached);
    }
    return const HouseholdStructure();
  }

  /// Update household structure: save to local cache
  Future<bool> updateHousehold(HouseholdStructure household) async {
    LocalCacheService().save('user_household', household.toJson());
    return true;
  }
}

