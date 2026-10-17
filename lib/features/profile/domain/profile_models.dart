class PersonalInfo {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String dob;
  final String gender;
  final String nationality;
  final String profilePicUrl;
  final String panNumber;
  final String aadhaarNumber;
  final String maritalStatus;

  const PersonalInfo({
    this.fullName = 'Sireesha',
    this.email = 'sireesha@gmail.com',
    this.mobileNumber = '+91 98765 43210',
    this.dob = '15 Aug 1995',
    this.gender = 'Female',
    this.nationality = 'Indian',
    this.profilePicUrl = '',
    this.panNumber = 'ABCDE1234F',
    this.aadhaarNumber = '•••• •••• 5678',
    this.maritalStatus = 'Married',
  });

  PersonalInfo copyWith({
    String? fullName,
    String? email,
    String? mobileNumber,
    String? dob,
    String? gender,
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
  final String permanentAddress;

  const AddressInfo({
    this.residentialAddress = 'Flat No. 302, Green Park Apartments, Madhapur, Hyderabad, Telangana - 500081',
    this.permanentAddress = 'Flat No. 302, Green Park Apartments, Madhapur, Hyderabad, Telangana - 500081',
  });

  AddressInfo copyWith({
    String? residentialAddress,
    String? permanentAddress,
  }) {
    return AddressInfo(
      residentialAddress: residentialAddress ?? this.residentialAddress,
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
    this.jointFinancesEnabled = true,
    this.sharedExpensesMonthly = '₹ 45,000',
    this.familyGoalsCount = 4,
  });

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
    this.companyName = 'TCS (Tata Consultancy Services)',
    this.designation = 'Software Engineer',
    this.workExperience = '5 Years',
    this.workLocation = 'Hyderabad',
    this.sourceOfIncome = 'Salary & Bonus',
    this.annualIncome = '₹ 8,00,000',
    this.monthlyIncome = '₹ 66,667',
  });

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
  final bool areSecurityQuestionsConfigured;

  const SecuritySettings({
    this.is2FAEnabled = false,
    this.areSecurityQuestionsConfigured = true,
  });

  SecuritySettings copyWith({
    bool? is2FAEnabled,
    bool? areSecurityQuestionsConfigured,
  }) {
    return SecuritySettings(
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      areSecurityQuestionsConfigured: areSecurityQuestionsConfigured ?? this.areSecurityQuestionsConfigured,
    );
  }
}

class CommunicationPreferences {
  final bool smsNotifications;
  final bool emailNotifications;
  final bool pushNotifications;

  const CommunicationPreferences({
    this.smsNotifications = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
  });

  CommunicationPreferences copyWith({
    bool? smsNotifications,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return CommunicationPreferences(
      smsNotifications: smsNotifications ?? this.smsNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}

class ProfileStateData {
  final PersonalInfo personalInfo;
  final AddressInfo addressInfo;
  final EmploymentIncomeInfo employmentInfo;
  final List<FamilyMember> familyMembers;
  final HouseholdStructure householdStructure;
  final SecuritySettings securitySettings;
  final CommunicationPreferences communicationPrefs;

  const ProfileStateData({
    this.personalInfo = const PersonalInfo(),
    this.addressInfo = const AddressInfo(),
    this.employmentInfo = const EmploymentIncomeInfo(),
    this.familyMembers = const [
      FamilyMember(id: '1', name: 'Rajesh Kumar', relation: 'Spouse', age: 32, isDependent: false),
      FamilyMember(id: '2', name: 'Ananya Kumar', relation: 'Child', age: 5, isDependent: true),
      FamilyMember(id: '3', name: 'Savitri Devi', relation: 'Parent', age: 64, isDependent: true),
    ],
    this.householdStructure = const HouseholdStructure(),
    this.securitySettings = const SecuritySettings(),
    this.communicationPrefs = const CommunicationPreferences(),
  });

  ProfileStateData copyWith({
    PersonalInfo? personalInfo,
    AddressInfo? addressInfo,
    EmploymentIncomeInfo? employmentInfo,
    List<FamilyMember>? familyMembers,
    HouseholdStructure? householdStructure,
    SecuritySettings? securitySettings,
    CommunicationPreferences? communicationPrefs,
  }) {
    return ProfileStateData(
      personalInfo: personalInfo ?? this.personalInfo,
      addressInfo: addressInfo ?? this.addressInfo,
      employmentInfo: employmentInfo ?? this.employmentInfo,
      familyMembers: familyMembers ?? this.familyMembers,
      householdStructure: householdStructure ?? this.householdStructure,
      securitySettings: securitySettings ?? this.securitySettings,
      communicationPrefs: communicationPrefs ?? this.communicationPrefs,
    );
  }
}
