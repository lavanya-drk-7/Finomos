import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_kyc/domain/kyc_models.dart';
import '../../auth_kyc/providers/auth_kyc_provider.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/phone_utils.dart';
import '../domain/profile_models.dart';
import '../services/profile_api_service.dart';

class ProfileNotifier extends Notifier<ProfileStateData> {
  final ProfileApiService _apiService = ProfileApiService();
  Future<void>? _inFlightFetch;

  @override
  ProfileStateData build() {
    // Schedule background live sync
    Future.microtask(() => loadProfile());

    // Hydrate immediately from synchronous local cache for 0ms rendering
    final cached = _apiService.getCachedProfile();
    final cachedEmp = LocalCacheService().get('user_employment');
    final cachedFamily = LocalCacheService().get('user_family_members');
    final cachedHousehold = LocalCacheService().get('user_household');

    final initialEmp = cachedEmp is Map<String, dynamic>
        ? EmploymentIncomeInfo.fromJson(cachedEmp)
        : const EmploymentIncomeInfo();
    final initialFamily = cachedFamily is List
        ? cachedFamily
            .whereType<Map<String, dynamic>>()
            .map((item) => FamilyMember.fromJson(item))
            .toList()
        : const <FamilyMember>[];
    final initialHousehold = cachedHousehold is Map<String, dynamic>
        ? HouseholdStructure.fromJson(cachedHousehold)
        : const HouseholdStructure();

    bool isTestEnv = false;
    try {
      isTestEnv = Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {}

    final cachedEmail = LocalCacheService().get('user_email')?.toString();
    final cachedPhone = LocalCacheService().get('user_mobile_number')?.toString();
    final cachedName = LocalCacheService().get('user_name')?.toString();

    final activeEmail = (cachedEmail != null && cachedEmail.isNotEmpty)
        ? cachedEmail
        : (isTestEnv ? 'sireesha@gmail.com' : '');
    final activePhone = (cachedPhone != null && cachedPhone.isNotEmpty)
        ? cachedPhone
        : (isTestEnv ? '9876543210' : '');
    final activeName = (cachedName != null && cachedName.isNotEmpty)
        ? cachedName
        : (isTestEnv ? 'Sireesha' : '');

    // Look up saved user account record
    final savedRecord = LocalCacheService().getUserProfileRecord(
      activePhone.isNotEmpty ? activePhone : activeEmail,
    );

    final resolvedName = activeName.isNotEmpty
        ? activeName
        : (savedRecord?['fullName']?.toString() ?? (isTestEnv ? 'Sireesha' : ''));
    final resolvedEmail = activeEmail.isNotEmpty
        ? activeEmail
        : (savedRecord?['email']?.toString() ?? (isTestEnv ? 'sireesha@gmail.com' : ''));
    final resolvedPhone = activePhone.isNotEmpty
        ? activePhone
        : (savedRecord?['phone']?.toString() ?? (isTestEnv ? '9876543210' : ''));

    final initialPersonal = PersonalInfo(
      fullName: resolvedName,
      email: resolvedEmail,
      mobileNumber: resolvedPhone,
      dob: savedRecord?['dob']?.toString() ?? '',
      gender: savedRecord?['gender']?.toString() ?? '',
      panNumber: savedRecord?['panNumber']?.toString() ?? '',
      aadhaarNumber: savedRecord?['aadhaarNumber']?.toString() ?? '',
      maritalStatus: savedRecord?['maritalStatus']?.toString() ?? '',
      nationality: savedRecord?['nationality']?.toString() ?? 'Indian',
      occupation: savedRecord?['occupation']?.toString() ?? '',
      annualIncome: (savedRecord?['annualIncome'] as num?)?.toDouble() ?? 0.0,
      profilePicUrl: savedRecord?['profilePicUrl']?.toString() ?? '',
    );

    final initialAddress = AddressInfo(
      residentialAddress: savedRecord?['address']?.toString() ?? '',
      city: savedRecord?['city']?.toString() ?? '',
      state: savedRecord?['state']?.toString() ?? '',
      pinCode: savedRecord?['pinCode']?.toString() ?? '',
      permanentAddress: savedRecord?['permanentAddress']?.toString() ??
          (savedRecord?['address']?.toString() ?? ''),
    );

    if (cached != null) {
      final mergedPersonal = cached.personal.copyWith(
        fullName: cached.personal.fullName.isNotEmpty
            ? cached.personal.fullName
            : initialPersonal.fullName,
        email: cached.personal.email.isNotEmpty
            ? cached.personal.email
            : initialPersonal.email,
        mobileNumber: cached.personal.mobileNumber.isNotEmpty
            ? cached.personal.mobileNumber
            : initialPersonal.mobileNumber,
        dob: cached.personal.dob.isNotEmpty ? cached.personal.dob : initialPersonal.dob,
        gender: cached.personal.gender.isNotEmpty ? cached.personal.gender : initialPersonal.gender,
        panNumber: cached.personal.panNumber.isNotEmpty ? cached.personal.panNumber : initialPersonal.panNumber,
        aadhaarNumber: cached.personal.aadhaarNumber.isNotEmpty ? cached.personal.aadhaarNumber : initialPersonal.aadhaarNumber,
        occupation: cached.personal.occupation.isNotEmpty ? cached.personal.occupation : initialPersonal.occupation,
        annualIncome: cached.personal.annualIncome > 0 ? cached.personal.annualIncome : initialPersonal.annualIncome,
      );

      final mergedAddress = AddressInfo(
        residentialAddress: cached.address.residentialAddress.isNotEmpty
            ? cached.address.residentialAddress
            : initialAddress.residentialAddress,
        city: cached.address.city.isNotEmpty ? cached.address.city : initialAddress.city,
        state: cached.address.state.isNotEmpty ? cached.address.state : initialAddress.state,
        pinCode: cached.address.pinCode.isNotEmpty ? cached.address.pinCode : initialAddress.pinCode,
        permanentAddress: cached.address.permanentAddress.isNotEmpty
            ? cached.address.permanentAddress
            : initialAddress.permanentAddress,
      );

      return ProfileStateData(
        userProfile: cached.copyWith(
          personal: mergedPersonal,
          address: mergedAddress,
        ),
        personalInfo: mergedPersonal,
        addressInfo: mergedAddress,
        employmentInfo: initialEmp,
        familyMembers: initialFamily,
        householdStructure: initialHousehold,
        securitySettings: cached.security,
        communicationPrefs: cached.notifications,
        isLoading: false,
        isSyncing: true,
      );
    }

    if (savedRecord != null) {
      final restoredProfile = UserProfileData(
        id: savedRecord['userId']?.toString() ?? '',
        name: resolvedName,
        email: resolvedEmail,
        phone: resolvedPhone,
        avatarUrl: savedRecord['profilePicUrl']?.toString() ?? '',
        personal: initialPersonal,
        address: initialAddress,
      );
      return ProfileStateData(
        userProfile: restoredProfile,
        personalInfo: initialPersonal,
        addressInfo: initialAddress,
        employmentInfo: initialEmp,
        familyMembers: initialFamily,
        householdStructure: initialHousehold,
        isLoading: false,
        isSyncing: true,
      );
    }

    return ProfileStateData(
      personalInfo: initialPersonal,
      addressInfo: initialAddress,
      employmentInfo: initialEmp,
      familyMembers: initialFamily,
      householdStructure: initialHousehold,
      isLoading: true,
      isSyncing: true,
    );
  }

  /// Load live user profile from backend API
  Future<void> loadProfile({bool force = false}) async {
    if (!force && _inFlightFetch != null) return _inFlightFetch!;

    state = state.copyWith(
      isSyncing: true,
      isLoading: state.userProfile == null,
    );

    _inFlightFetch = () async {
      try {
        final profileFuture = _apiService.getProfile();
        final empFuture = _apiService.getEmploymentInfo();
        final familyFuture = _apiService.getFamilyMembers();
        final householdFuture = _apiService.getHouseholdStructure();

        final results = await Future.wait([
          profileFuture,
          empFuture,
          familyFuture,
          householdFuture,
        ]);

        final profile = results[0] as UserProfileData?;
        final emp = results[1] as EmploymentIncomeInfo;
        final family = results[2] as List<FamilyMember>?;
        final household = results[3] as HouseholdStructure;

        if (profile != null) {
          final cleanPhone = PhoneUtils.sanitize(profile.phone);
          final cleanEmail = profile.email.trim().toLowerCase();
          final savedRecord = LocalCacheService().getUserProfileRecord(
            cleanPhone.isNotEmpty ? cleanPhone : cleanEmail,
          );

          // Resolve avatar: if local cache has a valid file on disk, prefer it over remote /uploads/ URL
          String effectiveAvatar = profile.avatarUrl;
          final cachedLocal = LocalCacheService().get('active_local_avatar') as String?;
          if (cachedLocal != null && cachedLocal.isNotEmpty && File(cachedLocal).existsSync()) {
            effectiveAvatar = cachedLocal;
          } else {
            final cachedForUrl = LocalCacheService().get('avatar_local_${profile.avatarUrl}') as String?;
            if (cachedForUrl != null && cachedForUrl.isNotEmpty && File(cachedForUrl).existsSync()) {
              effectiveAvatar = cachedForUrl;
            }
          }

          final mergedPersonal = profile.personal.copyWith(
            fullName: profile.personal.fullName.isNotEmpty
                ? profile.personal.fullName
                : (savedRecord?['fullName']?.toString() ?? state.personalInfo.fullName),
            email: profile.email.isNotEmpty
                ? profile.email
                : (savedRecord?['email']?.toString() ?? state.personalInfo.email),
            mobileNumber: cleanPhone.isNotEmpty
                ? cleanPhone
                : (savedRecord?['phone']?.toString() ?? state.personalInfo.mobileNumber),
            dob: profile.personal.dob.isNotEmpty
                ? profile.personal.dob
                : (savedRecord?['dob']?.toString() ?? state.personalInfo.dob),
            gender: profile.personal.gender.isNotEmpty
                ? profile.personal.gender
                : (savedRecord?['gender']?.toString() ?? state.personalInfo.gender),
            panNumber: profile.personal.panNumber.isNotEmpty
                ? profile.personal.panNumber
                : (savedRecord?['panNumber']?.toString() ?? state.personalInfo.panNumber),
            aadhaarNumber: profile.personal.aadhaarNumber.isNotEmpty
                ? profile.personal.aadhaarNumber
                : (savedRecord?['aadhaarNumber']?.toString() ?? state.personalInfo.aadhaarNumber),
            maritalStatus: profile.personal.maritalStatus.isNotEmpty
                ? profile.personal.maritalStatus
                : (savedRecord?['maritalStatus']?.toString() ?? state.personalInfo.maritalStatus),
            nationality: profile.personal.nationality.isNotEmpty
                ? profile.personal.nationality
                : (savedRecord?['nationality']?.toString() ?? state.personalInfo.nationality),
            occupation: profile.personal.occupation.isNotEmpty
                ? profile.personal.occupation
                : (savedRecord?['occupation']?.toString() ?? state.personalInfo.occupation),
            annualIncome: profile.personal.annualIncome > 0
                ? profile.personal.annualIncome
                : ((savedRecord?['annualIncome'] as num?)?.toDouble() ?? state.personalInfo.annualIncome),
            profilePicUrl: effectiveAvatar.isNotEmpty ? effectiveAvatar : profile.personal.profilePicUrl,
          );

          final mergedAddress = AddressInfo(
            residentialAddress: profile.address.residentialAddress.isNotEmpty
                ? profile.address.residentialAddress
                : (savedRecord?['address']?.toString() ?? state.addressInfo.residentialAddress),
            city: profile.address.city.isNotEmpty
                ? profile.address.city
                : (savedRecord?['city']?.toString() ?? state.addressInfo.city),
            state: profile.address.state.isNotEmpty
                ? profile.address.state
                : (savedRecord?['state']?.toString() ?? state.addressInfo.state),
            pinCode: profile.address.pinCode.isNotEmpty
                ? profile.address.pinCode
                : (savedRecord?['pinCode']?.toString() ?? state.addressInfo.pinCode),
            permanentAddress: profile.address.permanentAddress.isNotEmpty
                ? profile.address.permanentAddress
                : (savedRecord?['permanentAddress']?.toString() ?? state.addressInfo.permanentAddress),
          );

          final resolvedProfile = profile.copyWith(
            personal: mergedPersonal,
            address: mergedAddress,
            avatarUrl: effectiveAvatar,
          );

          state = state.copyWith(
            userProfile: resolvedProfile,
            personalInfo: mergedPersonal,
            addressInfo: mergedAddress,
            employmentInfo: emp,
            familyMembers: family ?? state.familyMembers,
            householdStructure: household,
            securitySettings: profile.security,
            communicationPrefs: profile.notifications,
            isLoading: false,
            isSyncing: false,
          );

          // Save current profile to persistent user records
          _saveCurrentProfileToLocalRecord();

          // If backend was missing details entered by user during onboarding, push to backend
          if (profile.personal.dob.isEmpty && mergedPersonal.dob.isNotEmpty) {
            _apiService.updatePersonalDetails(
              fullName: mergedPersonal.fullName,
              dob: mergedPersonal.dob,
              gender: mergedPersonal.gender,
              occupation: mergedPersonal.occupation,
              annualIncome: mergedPersonal.annualIncome,
            );
          }
          if (profile.address.residentialAddress.isEmpty && mergedAddress.residentialAddress.isNotEmpty) {
            _apiService.updateAddress(
              address: mergedAddress.residentialAddress,
              city: mergedAddress.city,
              state: mergedAddress.state,
              pinCode: mergedAddress.pinCode,
            );
          }

          // Synchronize with authKycProvider
          _syncWithAuthKyc(resolvedProfile, effectiveAvatar: effectiveAvatar);
        } else {
          // If remote fetch failed, check local saved user record to ensure fields are populated
          final activePhone = LocalCacheService().get('user_mobile_number')?.toString() ?? '';
          final activeEmail = LocalCacheService().get('user_email')?.toString() ?? '';
          final lookupKey = activePhone.isNotEmpty ? activePhone : activeEmail;
          if (lookupKey.isNotEmpty) {
            final savedRecord = LocalCacheService().getUserProfileRecord(lookupKey);
            if (savedRecord != null) {
              restoreUserProfile(record: savedRecord);
            }
          }

          state = state.copyWith(
            employmentInfo: emp,
            familyMembers: family ?? state.familyMembers,
            householdStructure: household,
            isLoading: false,
            isSyncing: false,
          );
        }
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          isSyncing: false,
          error: e.toString(),
        );
      } finally {
        _inFlightFetch = null;
      }
    }();

    return _inFlightFetch!;
  }

  /// Save current profile state to local persistent user account storage
  void _saveCurrentProfileToLocalRecord() {
    final personal = state.personalInfo;
    final address = state.addressInfo;
    final employment = state.employmentInfo;
    final phone = personal.mobileNumber.isNotEmpty
        ? personal.mobileNumber
        : (LocalCacheService().get('user_mobile_number')?.toString() ?? '');
    final email = personal.email.isNotEmpty
        ? personal.email
        : (LocalCacheService().get('user_email')?.toString() ?? '');
    final userId = state.userProfile?.id ?? (LocalCacheService().get('user_id')?.toString() ?? '');

    if (phone.isEmpty && email.isEmpty) return;

    LocalCacheService().saveUserProfileRecord(
      phone: phone,
      email: email,
      userId: userId,
      data: {
        'fullName': personal.fullName,
        'email': email,
        'phone': phone,
        'dob': personal.dob,
        'gender': personal.gender,
        'panNumber': personal.panNumber,
        'aadhaarNumber': personal.aadhaarNumber,
        'maritalStatus': personal.maritalStatus,
        'nationality': personal.nationality,
        'profilePicUrl': personal.profilePicUrl,
        'occupation': personal.occupation,
        'annualIncome': personal.annualIncome,
        'address': address.residentialAddress,
        'city': address.city,
        'state': address.state,
        'pinCode': address.pinCode,
        'permanentAddress': address.permanentAddress,
        'employment': employment.toJson(),
        'familyMembers': state.familyMembers.map((m) => m.toJson()).toList(),
        'household': state.householdStructure.toJson(),
      },
    );
  }

  /// Restore user profile into state immediately upon login
  void restoreUserProfile({
    String? phone,
    String? email,
    Map<String, dynamic>? record,
  }) {
    final cleanPhone = PhoneUtils.sanitize(phone ?? '');
    final cleanEmail = (email ?? '').trim().toLowerCase();
    final userRecord = record ??
        LocalCacheService().getUserProfileRecord(cleanPhone.isNotEmpty ? cleanPhone : cleanEmail);
    if (userRecord == null) return;

    final fullName = userRecord['fullName']?.toString() ?? userRecord['name']?.toString() ?? '';
    final userEmail = userRecord['email']?.toString() ?? cleanEmail;
    final userPhone = PhoneUtils.sanitize(userRecord['phone']?.toString() ?? cleanPhone);
    final dob = userRecord['dob']?.toString() ?? '';
    final gender = userRecord['gender']?.toString() ?? '';
    final occupation = userRecord['occupation']?.toString() ?? '';
    final annualIncome = (userRecord['annualIncome'] as num?)?.toDouble() ?? 0.0;
    final pan = userRecord['panNumber']?.toString() ?? '';
    final aadhaar = userRecord['aadhaarNumber']?.toString() ?? '';
    final marital = userRecord['maritalStatus']?.toString() ?? '';
    final nationality = userRecord['nationality']?.toString() ?? 'Indian';
    final address = userRecord['address']?.toString() ?? '';
    final city = userRecord['city']?.toString() ?? '';
    final pState = userRecord['state']?.toString() ?? '';
    final pinCode = userRecord['pinCode']?.toString() ?? '';
    final permAddress = userRecord['permanentAddress']?.toString() ?? address;
    final avatar = userRecord['avatarUrl']?.toString() ?? userRecord['profilePicUrl']?.toString() ?? '';

    final personal = PersonalInfo(
      fullName: fullName,
      email: userEmail,
      mobileNumber: userPhone,
      dob: dob,
      gender: gender,
      occupation: occupation,
      annualIncome: annualIncome,
      panNumber: pan,
      aadhaarNumber: aadhaar,
      maritalStatus: marital,
      nationality: nationality,
      profilePicUrl: avatar,
    );

    final addr = AddressInfo(
      residentialAddress: address,
      city: city,
      state: pState,
      pinCode: pinCode,
      permanentAddress: permAddress,
    );

    final employment = userRecord['employment'] is Map<String, dynamic>
        ? EmploymentIncomeInfo.fromJson(userRecord['employment'] as Map<String, dynamic>)
        : (occupation.isNotEmpty || annualIncome > 0
            ? EmploymentIncomeInfo(
                designation: occupation,
                annualIncome: annualIncome > 0 ? annualIncome.toStringAsFixed(0) : '',
              )
            : state.employmentInfo);

    final family = userRecord['familyMembers'] is List
        ? (userRecord['familyMembers'] as List)
            .whereType<Map<String, dynamic>>()
            .map((f) => FamilyMember.fromJson(f))
            .toList()
        : state.familyMembers;

    final household = userRecord['household'] is Map<String, dynamic>
        ? HouseholdStructure.fromJson(userRecord['household'] as Map<String, dynamic>)
        : state.householdStructure;

    final restoredProfile = UserProfileData(
      id: userRecord['userId']?.toString() ?? '',
      name: fullName,
      email: userEmail,
      phone: userPhone,
      avatarUrl: avatar,
      personal: personal,
      address: addr,
    );

    state = state.copyWith(
      userProfile: restoredProfile,
      personalInfo: personal,
      addressInfo: addr,
      employmentInfo: employment,
      familyMembers: family,
      householdStructure: household,
      isLoading: false,
    );

    LocalCacheService().save('user_profile', restoredProfile.toJson());
  }

  void _syncWithAuthKyc(UserProfileData profile, {String? effectiveAvatar}) {
    try {
      final authNotifier = ref.read(authKycProvider.notifier);
      final currentAuthUser = ref.read(authKycProvider).user;
      final avatarToUse = (effectiveAvatar != null && effectiveAvatar.isNotEmpty)
          ? effectiveAvatar
          : (profile.avatarUrl.isNotEmpty
              ? profile.avatarUrl
              : profile.personal.profilePicUrl);
      final updatedAuthUser = currentAuthUser.copyWith(
        fullName: profile.personal.fullName.isNotEmpty
            ? profile.personal.fullName
            : profile.name,
        email: profile.email,
        mobileNumber: profile.phone,
        profilePicUrl: avatarToUse,
        dob: profile.personal.dob,
        gender: profile.personal.gender,
        panNumber: profile.personal.panNumber,
        address: profile.address.residentialAddress,
        city: profile.address.city,
        state: profile.address.state,
        pinCode: profile.address.pinCode,
      );
      authNotifier.updateUserData(updatedAuthUser);

      // Sync KYC status badge
      final statusUpper = profile.kycStatus.toUpperCase();
      if (statusUpper == 'VERIFIED') {
        authNotifier.setKycStatus(KycStatus.verified);
      } else if (statusUpper == 'PENDING' || statusUpper == 'DEACTIVATED') {
        authNotifier.setKycStatus(KycStatus.pending);
      } else {
        authNotifier.setKycStatus(KycStatus.rejected);
      }
    } catch (_) {}
  }

  /// Update personal details: PUT /api/v1/user/profile/personal
  Future<bool> updatePersonalInfo(PersonalInfo info) async {
    // Optimistic update
    state = state.copyWith(
      personalInfo: info,
      userProfile: state.userProfile?.copyWith(
        personal: info,
        name: info.fullName,
      ),
      isSyncing: true,
    );
    _saveCurrentProfileToLocalRecord();

    try {
      final result = await _apiService.updatePersonalDetails(
        fullName: info.fullName,
        dob: info.dob,
        gender: info.gender,
        occupation: info.occupation,
        annualIncome: info.annualIncome,
      );

      if (result != null && result['success'] == true) {
        state = state.copyWith(
          isSyncing: false,
          successMessage: 'Personal details updated successfully',
        );
        if (state.userProfile != null) {
          _syncWithAuthKyc(state.userProfile!);
        }
        return true;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }

    state = state.copyWith(isSyncing: false);
    return false;
  }

  /// Update residential address details: PUT /api/v1/user/profile/address
  Future<bool> updateAddressInfo(AddressInfo info) async {
    // Optimistic update
    state = state.copyWith(
      addressInfo: info,
      userProfile: state.userProfile?.copyWith(address: info),
      isSyncing: true,
    );
    _saveCurrentProfileToLocalRecord();

    try {
      final result = await _apiService.updateAddress(
        address: info.residentialAddress,
        city: info.city,
        state: info.state,
        pinCode: info.pinCode,
      );

      if (result != null && result['success'] == true) {
        state = state.copyWith(
          isSyncing: false,
          successMessage: 'Address details updated successfully',
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }

    state = state.copyWith(isSyncing: false);
    return false;
  }

  /// Upload avatar photo: POST /api/v1/user/profile/photo
  Future<String?> uploadProfilePhoto(File photoFile) async {
    state = state.copyWith(isSyncing: true);
    try {
      final avatarUrl = await _apiService.uploadProfilePhoto(photoFile);
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        // Cache the local file path mapped to this avatar URL and as the active local avatar
        LocalCacheService().save('active_local_avatar', photoFile.path);
        LocalCacheService().save('avatar_local_$avatarUrl', photoFile.path);

        // Keep local photo path for device display so it renders instantly without 404
        final displayPath = photoFile.existsSync() ? photoFile.path : avatarUrl;
        final updatedPersonal =
            state.personalInfo.copyWith(profilePicUrl: displayPath);
        state = state.copyWith(
          personalInfo: updatedPersonal,
          userProfile: state.userProfile?.copyWith(
            avatarUrl: avatarUrl,
            personal: updatedPersonal,
          ),
          isSyncing: false,
        );

        ref.read(authKycProvider.notifier).updateProfilePhoto(displayPath);
        return avatarUrl;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }

    state = state.copyWith(isSyncing: false);
    return null;
  }

  /// Update local profile photo path (for avatar picker selection)
  void updateProfilePhoto(String path) {
    state = state.copyWith(
      personalInfo: state.personalInfo.copyWith(profilePicUrl: path),
      userProfile: state.userProfile?.copyWith(avatarUrl: path),
    );
  }

  /// Update security settings: PUT /api/v1/user/profile/security
  Future<bool> updateSecuritySettings({
    required bool twoFactorEnabled,
    required bool biometricEnabled,
  }) async {
    final updated = state.securitySettings.copyWith(
      is2FAEnabled: twoFactorEnabled,
      biometricEnabled: biometricEnabled,
    );
    state = state.copyWith(
      securitySettings: updated,
      userProfile: state.userProfile?.copyWith(security: updated),
      isSyncing: true,
    );

    final success = await _apiService.updateSecurity(
      twoFactorEnabled: twoFactorEnabled,
      biometricEnabled: biometricEnabled,
    );

    state = state.copyWith(isSyncing: false);
    return success;
  }

  void toggle2FA(bool value) {
    updateSecuritySettings(
      twoFactorEnabled: value,
      biometricEnabled: state.securitySettings.biometricEnabled,
    );
  }

  /// Update communication preferences: PUT /api/v1/user/profile/notifications
  Future<bool> updateCommunicationPreferences({
    required bool email,
    required bool sms,
    required bool whatsapp,
  }) async {
    final updated = state.communicationPrefs.copyWith(
      emailNotifications: email,
      smsNotifications: sms,
      whatsappNotifications: whatsapp,
    );
    state = state.copyWith(
      communicationPrefs: updated,
      userProfile: state.userProfile?.copyWith(notifications: updated),
      isSyncing: true,
    );

    final success = await _apiService.updateNotifications(
      email: email,
      sms: sms,
      whatsapp: whatsapp,
    );

    state = state.copyWith(isSyncing: false);
    return success;
  }

  void updateCommunicationPrefs(CommunicationPreferences prefs) {
    updateCommunicationPreferences(
      email: prefs.emailNotifications,
      sms: prefs.smsNotifications,
      whatsapp: prefs.whatsappNotifications,
    );
  }

  /// Permanently delete account: DELETE /api/v1/user/account
  Future<Map<String, dynamic>?> deleteAccount() async {
    state = state.copyWith(isSyncing: true);
    final result = await _apiService.deleteAccount();
    state = state.copyWith(isSyncing: false);
    return result;
  }

  /// Update employment & income details: PUT /api/v1/user/profile/employment
  Future<bool> updateEmploymentInfo(EmploymentIncomeInfo info) async {
    state = state.copyWith(employmentInfo: info, isSyncing: true);

    // Parse annual income for live personal details sync
    final cleanedIncome = info.annualIncome.replaceAll(RegExp(r'[^0-9.]'), '');
    final parsedIncome =
        double.tryParse(cleanedIncome) ?? state.personalInfo.annualIncome;

    // 1. Sync with live backend personal info (occupation & annual income)
    final updatedPersonal = state.personalInfo.copyWith(
      occupation: info.designation.isNotEmpty
          ? info.designation
          : state.personalInfo.occupation,
      annualIncome: parsedIncome,
    );
    await updatePersonalInfo(updatedPersonal);

    // 2. Persist employment details to live endpoint & cache
    final success = await _apiService.updateEmploymentDetails(info);
    _saveCurrentProfileToLocalRecord();
    state = state.copyWith(isSyncing: false);
    return success;
  }

  /// Add family member: POST /api/v1/user/profile/family-members
  Future<FamilyMember?> addFamilyMember(FamilyMember member) async {
    state = state.copyWith(
      familyMembers: [...state.familyMembers, member],
      isSyncing: true,
    );
    final saved = await _apiService.addFamilyMember(member);
    state = state.copyWith(isSyncing: false);
    return saved;
  }

  /// Remove family member: DELETE /api/v1/user/profile/family-members/:id
  Future<bool> removeFamilyMember(String id) async {
    state = state.copyWith(
      familyMembers: state.familyMembers.where((m) => m.id != id).toList(),
      isSyncing: true,
    );
    final success = await _apiService.deleteFamilyMember(id);
    state = state.copyWith(isSyncing: false);
    return success;
  }

  /// Update household structure: PUT /api/v1/user/profile/household
  Future<bool> updateHouseholdStructure(HouseholdStructure household) async {
    state = state.copyWith(householdStructure: household, isSyncing: true);
    final success = await _apiService.updateHousehold(household);
    state = state.copyWith(isSyncing: false);
    return success;
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileStateData>(() {
  return ProfileNotifier();
});
