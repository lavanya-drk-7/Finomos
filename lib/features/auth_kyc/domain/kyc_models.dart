enum KycStatus {
  pending,
  verified,
  rejected,
}

class UserRegistrationData {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final String dob;
  final String gender;
  final String panNumber;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String idProofFileName;
  final String profilePicUrl;
  final List<KycDocumentRecord> kycDocuments;
  final bool consentProcessing;
  final bool consentSharing;
  final bool consentTermsPrivacy;
  final bool agreeTerms;
  final bool agreePrivacy;

  const UserRegistrationData({
    this.fullName = 'Sireesha',
    this.email = 'sireesha@gmail.com',
    this.mobileNumber = '+91 98765 43210',
    this.password = 'Password@123',
    this.dob = '1995-08-15',
    this.gender = 'Female',
    this.panNumber = 'ABCDE1234F',
    this.address = '101, Tech Park Avenue, Hitech City',
    this.city = 'Hyderabad',
    this.state = 'Telangana',
    this.pinCode = '500081',
    this.idProofFileName = 'PAN_Card_Sireesha.pdf',
    this.profilePicUrl = '',
    this.kycDocuments = const [
      KycDocumentRecord(
        id: 'kyc_pan_1',
        idType: 'PAN Card',
        idNumber: 'ABCDE1234F',
        fileName: 'PAN_Card_Sireesha.pdf',
        fileSize: '1.2 MB',
        uploadDate: '30 Sep 2026',
        isUploaded: true,
        isVerified: true,
      ),
      KycDocumentRecord(
        id: 'kyc_aadhaar_2',
        idType: 'Aadhaar Card',
        idNumber: '•••• •••• 5678',
        fileName: 'Aadhaar_Card_Sireesha.pdf',
        fileSize: '2.4 MB',
        uploadDate: '30 Sep 2026',
        isUploaded: true,
        isVerified: true,
      ),
    ],
    this.consentProcessing = false,
    this.consentSharing = false,
    this.consentTermsPrivacy = false,
    this.agreeTerms = false,
    this.agreePrivacy = false,
  });

  UserRegistrationData copyWith({
    String? fullName,
    String? email,
    String? mobileNumber,
    String? password,
    String? dob,
    String? gender,
    String? panNumber,
    String? address,
    String? city,
    String? state,
    String? pinCode,
    String? idProofFileName,
    String? profilePicUrl,
    List<KycDocumentRecord>? kycDocuments,
    bool? consentProcessing,
    bool? consentSharing,
    bool? consentTermsPrivacy,
    bool? agreeTerms,
    bool? agreePrivacy,
  }) {
    return UserRegistrationData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      password: password ?? this.password,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      panNumber: panNumber ?? this.panNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      idProofFileName: idProofFileName ?? this.idProofFileName,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      kycDocuments: kycDocuments ?? this.kycDocuments,
      consentProcessing: consentProcessing ?? this.consentProcessing,
      consentSharing: consentSharing ?? this.consentSharing,
      consentTermsPrivacy: consentTermsPrivacy ?? this.consentTermsPrivacy,
      agreeTerms: agreeTerms ?? this.agreeTerms,
      agreePrivacy: agreePrivacy ?? this.agreePrivacy,
    );
  }
}

class KycDocumentRecord {
  final String id;
  final String idType;
  final String idNumber;
  final String fileName;
  final String uploadDate;
  final String fileSize;
  final String fileUrl;
  final bool isUploaded;
  final bool isVerified;

  const KycDocumentRecord({
    required this.id,
    required this.idType,
    required this.idNumber,
    required this.fileName,
    this.uploadDate = '30 Sep 2026',
    this.fileSize = '1.2 MB',
    this.fileUrl = '',
    this.isUploaded = true,
    this.isVerified = true,
  });

  KycDocumentRecord copyWith({
    String? id,
    String? idType,
    String? idNumber,
    String? fileName,
    String? uploadDate,
    String? fileSize,
    String? fileUrl,
    bool? isUploaded,
    bool? isVerified,
  }) {
    return KycDocumentRecord(
      id: id ?? this.id,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      fileName: fileName ?? this.fileName,
      uploadDate: uploadDate ?? this.uploadDate,
      fileSize: fileSize ?? this.fileSize,
      fileUrl: fileUrl ?? this.fileUrl,
      isUploaded: isUploaded ?? this.isUploaded,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class KycStateData {
  final int currentStep;
  final UserRegistrationData user;
  final bool isMobileVerified;
  final bool isOtpVerified;
  final bool isExistingUser;
  final KycStatus kycStatus;
  final String registrationCompletedTime;
  final String kycSubmittedTime;

  const KycStateData({
    this.currentStep = 1,
    this.user = const UserRegistrationData(),
    this.isMobileVerified = false,
    this.isOtpVerified = false,
    this.isExistingUser = false,
    this.kycStatus = KycStatus.verified,
    this.registrationCompletedTime = '30 Sep 2026, 12:00 PM',
    this.kycSubmittedTime = '30 Sep 2026, 12:30 PM',
  });

  KycStateData copyWith({
    int? currentStep,
    UserRegistrationData? user,
    bool? isMobileVerified,
    bool? isOtpVerified,
    bool? isExistingUser,
    KycStatus? kycStatus,
    String? registrationCompletedTime,
    String? kycSubmittedTime,
  }) {
    return KycStateData(
      currentStep: currentStep ?? this.currentStep,
      user: user ?? this.user,
      isMobileVerified: isMobileVerified ?? this.isMobileVerified,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      isExistingUser: isExistingUser ?? this.isExistingUser,
      kycStatus: kycStatus ?? this.kycStatus,
      registrationCompletedTime: registrationCompletedTime ?? this.registrationCompletedTime,
      kycSubmittedTime: kycSubmittedTime ?? this.kycSubmittedTime,
    );
  }
}
