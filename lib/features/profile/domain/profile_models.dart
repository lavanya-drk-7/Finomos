import '../../../core/services/cache_service.dart';
import '../../../core/utils/phone_utils.dart';

class PersonalInfo {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String dob;
  final String gender;
  final String occupation;
  final double annualIncome;
  final String nationality;
  final String profilePicUrl;
  final String panNumber;
  final String aadhaarNumber;
  final String maritalStatus;

  const PersonalInfo({
    this.fullName = '',
    this.email = '',
    this.mobileNumber = '',
    this.dob = '',
    this.gender = '',
    this.occupation = '',
    this.annualIncome = 0.0,
    this.nationality = 'Indian',
    this.profilePicUrl = '',
    this.panNumber = '',
    this.aadhaarNumber = '',
    this.maritalStatus = '',
  });

  factory PersonalInfo.fromJson(
    Map<String, dynamic> json, {
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    double parseIncome(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      final cleaned = val.toString().replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }

    final activeEmail = email ?? LocalCacheService().get('user_email')?.toString() ?? '';
    final activePhone = phone ?? LocalCacheService().get('user_mobile_number')?.toString() ?? '';
    final activeName = LocalCacheService().get('user_name')?.toString() ?? '';

    return PersonalInfo(
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? activeName,
      dob: json['dob'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      annualIncome: parseIncome(json['annualIncome']),
      panNumber: json['panNumber'] as String? ?? '',
      aadhaarNumber: json['aadhaarMasked'] as String? ??
          json['aadhaarNumber'] as String? ??
          '',
      email: json['email'] as String? ?? activeEmail,
      mobileNumber: PhoneUtils.sanitize(json['mobileNumber'] as String? ?? json['phone'] as String? ?? activePhone),
      profilePicUrl: avatarUrl ?? json['profilePicUrl'] as String? ?? '',
      nationality: json['nationality'] as String? ?? 'Indian',
      maritalStatus: json['maritalStatus'] as String? ?? '',
    );
  }

  Map<String, dynamic> toPersonalPutJson() {
    return {
      'fullName': fullName,
      'dob': dob,
      'gender': gender,
      'occupation': occupation,
      'annualIncome': annualIncome,
    };
  }

  PersonalInfo copyWith({
    String? fullName,
    String? email,
    String? mobileNumber,
    String? dob,
    String? gender,
    String? occupation,
    double? annualIncome,
    String? nationality,
    String? profilePicUrl,
    String? panNumber,
    String? aadhaarNumber,
    String? maritalStatus,
  }) {
    return PersonalInfo(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      annualIncome: annualIncome ?? this.annualIncome,
      nationality: nationality ?? this.nationality,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      panNumber: panNumber ?? this.panNumber,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      maritalStatus: maritalStatus ?? this.maritalStatus,
    );
  }
}

class AddressInfo {
  final String residentialAddress;
  final String city;
  final String state;
  final String pinCode;
  final String permanentAddress;

  const AddressInfo({
    this.residentialAddress = '',
    this.city = '',
    this.state = '',
    this.pinCode = '',
    this.permanentAddress = '',
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    final resAddr = json['residentialAddress'] as String? ??
        json['address'] as String? ??
        '';
    return AddressInfo(
      residentialAddress: resAddr,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pinCode: json['pinCode'] as String? ?? '',
      permanentAddress: json['permanentAddress'] as String? ??
          (resAddr.isNotEmpty ? resAddr : ''),
    );
  }

  Map<String, dynamic> toAddressPutJson() {
    return {
      'address': residentialAddress,
      'city': city,
      'state': state,
      'pinCode': pinCode,
    };
  }

  AddressInfo copyWith({
    String? residentialAddress,
    String? city,
    String? state,
    String? pinCode,
    String? permanentAddress,
  }) {
    return AddressInfo(
      residentialAddress: residentialAddress ?? this.residentialAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      permanentAddress: permanentAddress ?? this.permanentAddress,
    );
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String relation; // Spouse, Child, Parent, Dependent
  final int age;
  final bool isDependent;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.age,
    this.isDependent = true,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      relation: json['relation'] as String? ?? json['relationship'] as String? ?? 'Dependent',
      age: (json['age'] as num?)?.toInt() ?? 0,
      isDependent: json['isDependent'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relation,
      'relation': relation,
      'age': age,
      'isDependent': isDependent,
    };
  }

  FamilyMember copyWith({
    String? id,
    String? name,
    String? relation,
    int? age,
    bool? isDependent,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      age: age ?? this.age,
      isDependent: isDependent ?? this.isDependent,
    );
  }
}

class HouseholdStructure {
  final bool jointFinancesEnabled;
  final String sharedExpensesMonthly;
  final int familyGoalsCount;

  const HouseholdStructure({
    this.jointFinancesEnabled = false,
    this.sharedExpensesMonthly = '',
    this.familyGoalsCount = 0,
  });

  factory HouseholdStructure.fromJson(Map<String, dynamic> json) {
    return HouseholdStructure(
      jointFinancesEnabled: json['jointFinancesEnabled'] as bool? ?? false,
      sharedExpensesMonthly: json['sharedExpensesMonthly'] as String? ?? '',
      familyGoalsCount: (json['familyGoalsCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jointFinancesEnabled': jointFinancesEnabled,
      'sharedExpensesMonthly': sharedExpensesMonthly,
      'familyGoalsCount': familyGoalsCount,
    };
  }

  HouseholdStructure copyWith({
    bool? jointFinancesEnabled,
    String? sharedExpensesMonthly,
    int? familyGoalsCount,
  }) {
    return HouseholdStructure(
      jointFinancesEnabled: jointFinancesEnabled ?? this.jointFinancesEnabled,
      sharedExpensesMonthly: sharedExpensesMonthly ?? this.sharedExpensesMonthly,
      familyGoalsCount: familyGoalsCount ?? this.familyGoalsCount,
    );
  }
}

class EmploymentIncomeInfo {
  final String employmentType;
  final String companyName;
  final String designation;
  final String workExperience;
  final String workLocation;
  final String sourceOfIncome;
  final String annualIncome;
  final String monthlyIncome;

  const EmploymentIncomeInfo({
    this.employmentType = 'Salaried',
    this.companyName = '',
    this.designation = '',
    this.workExperience = '',
    this.workLocation = '',
    this.sourceOfIncome = 'Salary',
    this.annualIncome = '',
    this.monthlyIncome = '',
  });

  factory EmploymentIncomeInfo.fromJson(Map<String, dynamic> json) {
    return EmploymentIncomeInfo(
      employmentType: json['employmentType'] as String? ?? 'Salaried',
      companyName: json['companyName'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      workExperience: json['workExperience'] as String? ?? json['experienceYears']?.toString() ?? '',
      workLocation: json['workLocation'] as String? ?? '',
      sourceOfIncome: json['sourceOfIncome'] as String? ?? 'Salary',
      annualIncome: json['annualIncome']?.toString() ?? '',
      monthlyIncome: json['monthlyIncome']?.toString() ?? json['monthlyInHand']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employmentType': employmentType,
      'companyName': companyName,
      'designation': designation,
      'workExperience': workExperience,
      'workLocation': workLocation,
      'sourceOfIncome': sourceOfIncome,
      'annualIncome': annualIncome,
      'monthlyIncome': monthlyIncome,
    };
  }

  EmploymentIncomeInfo copyWith({
    String? employmentType,
    String? companyName,
    String? designation,
    String? workExperience,
    String? workLocation,
    String? sourceOfIncome,
    String? annualIncome,
    String? monthlyIncome,
  }) {
    return EmploymentIncomeInfo(
      employmentType: employmentType ?? this.employmentType,
      companyName: companyName ?? this.companyName,
      designation: designation ?? this.designation,
      workExperience: workExperience ?? this.workExperience,
      workLocation: workLocation ?? this.workLocation,
      sourceOfIncome: sourceOfIncome ?? this.sourceOfIncome,
      annualIncome: annualIncome ?? this.annualIncome,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    );
  }
}

class SecuritySettings {
  final bool is2FAEnabled;
  final bool biometricEnabled;
  final bool hasPassword;
  final bool areSecurityQuestionsConfigured;

  const SecuritySettings({
    this.is2FAEnabled = false,
    this.biometricEnabled = true,
    this.hasPassword = true,
    this.areSecurityQuestionsConfigured = true,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      is2FAEnabled: json['twoFactorEnabled'] as bool? ?? false,
      biometricEnabled: json['biometricEnabled'] as bool? ?? true,
      hasPassword: json['hasPassword'] as bool? ?? true,
      areSecurityQuestionsConfigured: true,
    );
  }

  Map<String, dynamic> toSecurityPutJson() {
    return {
      'twoFactorEnabled': is2FAEnabled,
      'biometricEnabled': biometricEnabled,
    };
  }

  SecuritySettings copyWith({
    bool? is2FAEnabled,
    bool? biometricEnabled,
    bool? hasPassword,
    bool? areSecurityQuestionsConfigured,
  }) {
    return SecuritySettings(
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      hasPassword: hasPassword ?? this.hasPassword,
      areSecurityQuestionsConfigured:
          areSecurityQuestionsConfigured ?? this.areSecurityQuestionsConfigured,
    );
  }
}

class CommunicationPreferences {
  final bool emailNotifications;
  final bool smsNotifications;
  final bool whatsappNotifications;
  final bool pushNotifications;

  const CommunicationPreferences({
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.whatsappNotifications = true,
    this.pushNotifications = true,
  });

  factory CommunicationPreferences.fromJson(Map<String, dynamic> json) {
    return CommunicationPreferences(
      emailNotifications: json['email'] as bool? ?? true,
      smsNotifications: json['sms'] as bool? ?? true,
      whatsappNotifications: json['whatsapp'] as bool? ?? true,
      pushNotifications: json['push'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toNotificationsPutJson() {
    return {
      'email': emailNotifications,
      'sms': smsNotifications,
      'whatsapp': whatsappNotifications,
    };
  }

  CommunicationPreferences copyWith({
    bool? emailNotifications,
    bool? smsNotifications,
    bool? whatsappNotifications,
    bool? pushNotifications,
  }) {
    return CommunicationPreferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      whatsappNotifications: whatsappNotifications ?? this.whatsappNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}

class ProfileStats {
  final int linkedAccountsCount;
  final int kycDocumentsCount;
  final int consentsCount;

  const ProfileStats({
    this.linkedAccountsCount = 0,
    this.kycDocumentsCount = 0,
    this.consentsCount = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      linkedAccountsCount: (json['linkedAccountsCount'] as num?)?.toInt() ?? 0,
      kycDocumentsCount: (json['kycDocumentsCount'] as num?)?.toInt() ?? 0,
      consentsCount: (json['consentsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class UserProfileData {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String kycStatus;
  final String kycBadge;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String createdAt;
  final PersonalInfo personal;
  final AddressInfo address;
  final SecuritySettings security;
  final CommunicationPreferences notifications;
  final ProfileStats stats;

  const UserProfileData({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.avatarUrl = '',
    this.kycStatus = 'INCOMPLETE',
    this.kycBadge = 'Unverified',
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.createdAt = '',
    this.personal = const PersonalInfo(),
    this.address = const AddressInfo(),
    this.security = const SecuritySettings(),
    this.notifications = const CommunicationPreferences(),
    this.stats = const ProfileStats(),
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    final activeEmail = LocalCacheService().get('user_email')?.toString() ?? '';
    final activePhone = LocalCacheService().get('user_mobile_number')?.toString() ?? '';
    final activeName = LocalCacheService().get('user_name')?.toString() ?? '';
    final activeId = LocalCacheService().get('user_id')?.toString() ?? '';

    final email = json['email'] as String? ?? activeEmail;
    final phone = PhoneUtils.sanitize(json['phone'] as String? ?? activePhone);
    final avatar = json['avatarUrl'] as String? ?? '';
    final name = json['name'] as String? ?? activeName;
    final id = json['id'] as String? ?? activeId;

    return UserProfileData(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatar,
      kycStatus: json['kycStatus'] as String? ?? 'VERIFIED',
      kycBadge: json['kycBadge'] as String? ?? 'Verified',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      personal: json['personal'] is Map<String, dynamic>
          ? PersonalInfo.fromJson(
              json['personal'] as Map<String, dynamic>,
              email: email,
              phone: phone,
              avatarUrl: avatar,
            )
          : PersonalInfo(
              fullName: name,
              email: email,
              mobileNumber: phone,
              profilePicUrl: avatar,
            ),
      address: json['address'] is Map<String, dynamic>
          ? AddressInfo.fromJson(json['address'] as Map<String, dynamic>)
          : const AddressInfo(),
      security: json['security'] is Map<String, dynamic>
          ? SecuritySettings.fromJson(json['security'] as Map<String, dynamic>)
          : const SecuritySettings(),
      notifications: json['notifications'] is Map<String, dynamic>
          ? CommunicationPreferences.fromJson(
              json['notifications'] as Map<String, dynamic>)
          : const CommunicationPreferences(),
      stats: json['stats'] is Map<String, dynamic>
          ? ProfileStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const ProfileStats(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'kycStatus': kycStatus,
      'kycBadge': kycBadge,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt,
      'personal': {
        'fullName': personal.fullName,
        'email': personal.email,
        'mobileNumber': personal.mobileNumber,
        'dob': personal.dob,
        'gender': personal.gender,
        'occupation': personal.occupation,
        'annualIncome': personal.annualIncome,
        'nationality': personal.nationality,
        'profilePicUrl': personal.profilePicUrl,
        'panNumber': personal.panNumber,
        'aadhaarNumber': personal.aadhaarNumber,
        'maritalStatus': personal.maritalStatus,
      },
      'address': {
        'residentialAddress': address.residentialAddress,
        'city': address.city,
        'state': address.state,
        'pinCode': address.pinCode,
        'permanentAddress': address.permanentAddress,
      },
      'security': security.toSecurityPutJson(),
      'notifications': notifications.toNotificationsPutJson(),
      'stats': {
        'linkedAccountsCount': stats.linkedAccountsCount,
        'kycDocumentsCount': stats.kycDocumentsCount,
        'consentsCount': stats.consentsCount,
      },
    };
  }

  UserProfileData copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? kycStatus,
    String? kycBadge,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? createdAt,
    PersonalInfo? personal,
    AddressInfo? address,
    SecuritySettings? security,
    CommunicationPreferences? notifications,
    ProfileStats? stats,
  }) {
    return UserProfileData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      kycStatus: kycStatus ?? this.kycStatus,
      kycBadge: kycBadge ?? this.kycBadge,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      personal: personal ?? this.personal,
      address: address ?? this.address,
      security: security ?? this.security,
      notifications: notifications ?? this.notifications,
      stats: stats ?? this.stats,
    );
  }
}

class ProfileStateData {
  final UserProfileData? userProfile;
  final PersonalInfo personalInfo;
  final AddressInfo addressInfo;
  final EmploymentIncomeInfo employmentInfo;
  final List<FamilyMember> familyMembers;
  final HouseholdStructure householdStructure;
  final SecuritySettings securitySettings;
  final CommunicationPreferences communicationPrefs;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final String? successMessage;

  const ProfileStateData({
    this.userProfile,
    this.personalInfo = const PersonalInfo(),
    this.addressInfo = const AddressInfo(),
    this.employmentInfo = const EmploymentIncomeInfo(),
    this.familyMembers = const [],
    this.householdStructure = const HouseholdStructure(),
    this.securitySettings = const SecuritySettings(),
    this.communicationPrefs = const CommunicationPreferences(),
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.successMessage,
  });

  ProfileStateData copyWith({
    UserProfileData? userProfile,
    PersonalInfo? personalInfo,
    AddressInfo? addressInfo,
    EmploymentIncomeInfo? employmentInfo,
    List<FamilyMember>? familyMembers,
    HouseholdStructure? householdStructure,
    SecuritySettings? securitySettings,
    CommunicationPreferences? communicationPrefs,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    String? successMessage,
  }) {
    return ProfileStateData(
      userProfile: userProfile ?? this.userProfile,
      personalInfo: personalInfo ?? this.personalInfo,
      addressInfo: addressInfo ?? this.addressInfo,
      employmentInfo: employmentInfo ?? this.employmentInfo,
      familyMembers: familyMembers ?? this.familyMembers,
      householdStructure: householdStructure ?? this.householdStructure,
      securitySettings: securitySettings ?? this.securitySettings,
      communicationPrefs: communicationPrefs ?? this.communicationPrefs,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      successMessage: successMessage,
    );
  }
}
