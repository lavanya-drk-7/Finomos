export 'auth_onboarding_models.dart';

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
  final String occupation;
  final num annualIncome;
  final String idProofFileName;
  final String profilePicUrl;
  final List<KycDocumentRecord> kycDocuments;
  final bool consentProcessing;
  final bool consentSharing;
  final bool consentTermsPrivacy;
  final bool agreeTerms;
  final bool agreePrivacy;
  final String authToken;
  final String? userId;

  const UserRegistrationData({
    this.fullName = '',
    this.email = '',
    this.mobileNumber = '',
    this.password = '',
    this.authToken = '',
    this.userId = '',
    this.dob = '',
    this.gender = '',
    this.panNumber = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pinCode = '',
    this.occupation = '',
    this.annualIncome = 0,
    this.idProofFileName = '',
    this.profilePicUrl = '',
    this.kycDocuments = const [],
    this.consentProcessing = false,
    this.consentSharing = false,
    this.consentTermsPrivacy = false,
    this.agreeTerms = false,
    this.agreePrivacy = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'mobileNumber': mobileNumber,
      'password': password,
      'authToken': authToken,
      'userId': userId,
      'dob': dob,
      'gender': gender,
      'panNumber': panNumber,
      'address': address,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'occupation': occupation,
      'annualIncome': annualIncome,
      'idProofFileName': idProofFileName,
      'profilePicUrl': profilePicUrl,
      'consentProcessing': consentProcessing,
      'consentSharing': consentSharing,
      'consentTermsPrivacy': consentTermsPrivacy,
      'agreeTerms': agreeTerms,
      'agreePrivacy': agreePrivacy,
    };
  }

  factory UserRegistrationData.fromJson(Map<String, dynamic> json) {
    return UserRegistrationData(
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? json['phone']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      authToken: json['authToken']?.toString() ?? json['token']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      panNumber: json['panNumber']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pinCode: json['pinCode']?.toString() ?? '',
      occupation: json['occupation']?.toString() ?? '',
      annualIncome: (json['annualIncome'] as num?)?.toDouble() ?? 0,
      idProofFileName: json['idProofFileName']?.toString() ?? '',
      profilePicUrl: json['profilePicUrl']?.toString() ?? json['avatarUrl']?.toString() ?? '',
      consentProcessing: json['consentProcessing'] as bool? ?? false,
      consentSharing: json['consentSharing'] as bool? ?? false,
      consentTermsPrivacy: json['consentTermsPrivacy'] as bool? ?? false,
      agreeTerms: json['agreeTerms'] as bool? ?? false,
      agreePrivacy: json['agreePrivacy'] as bool? ?? false,
    );
  }

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
    String? occupation,
    num? annualIncome,
    String? idProofFileName,
    String? profilePicUrl,
    List<KycDocumentRecord>? kycDocuments,
    bool? consentProcessing,
    bool? consentSharing,
    bool? consentTermsPrivacy,
    bool? agreeTerms,
    bool? agreePrivacy,
    String? authToken,
    String? userId,
  }) {
    return UserRegistrationData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      password: password ?? this.password,
      authToken: authToken ?? this.authToken,
      userId: userId ?? this.userId,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      panNumber: panNumber ?? this.panNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      occupation: occupation ?? this.occupation,
      annualIncome: annualIncome ?? this.annualIncome,
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



class KycTimelineItem {
  final int step;
  final String title;
  final String description;
  final String status;
  final int? documentsCount;
  final String? completedAt;

  const KycTimelineItem({
    required this.step,
    required this.title,
    required this.description,
    required this.status,
    this.documentsCount,
    this.completedAt,
  });

  factory KycTimelineItem.fromJson(Map<String, dynamic> json) {
    return KycTimelineItem(
      step: json['step'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'COMPLETED',
      documentsCount: json['documentsCount'] as int?,
      completedAt: json['completedAt'] as String?,
    );
  }

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isInProgress =>
      status.toUpperCase() == 'IN_PROGRESS' || status.toUpperCase() == 'PENDING';
  bool get isFailed => status.toUpperCase() == 'FAILED' || status.toUpperCase() == 'REJECTED';
}

class KycSummary {
  final String panNumber;
  final int documentsSubmitted;
  final int consentsAccepted;

  const KycSummary({
    this.panNumber = '',
    this.documentsSubmitted = 10,
    this.consentsAccepted = 12,
  });

  factory KycSummary.fromJson(Map<String, dynamic> json) {
    return KycSummary(
      panNumber: json['panNumber'] as String? ?? '',
      documentsSubmitted: json['documentsSubmitted'] as int? ?? 0,
      consentsAccepted: json['consentsAccepted'] as int? ?? 0,
    );
  }
}

class KycStatusResponse {
  final String userId;
  final String kycStatus;
  final bool isVerified;
  final String redirectRoute;
  final int currentStep;
  final int totalSteps;
  final List<KycTimelineItem> timeline;
  final KycSummary summary;

  const KycStatusResponse({
    this.userId = '',
    this.kycStatus = 'VERIFIED',
    this.isVerified = true,
    this.redirectRoute = '/dashboard',
    this.currentStep = 6,
    this.totalSteps = 6,
    this.timeline = const [],
    this.summary = const KycSummary(),
  });

  factory KycStatusResponse.fromJson(Map<String, dynamic> json) {
    final rawTimeline = json['timeline'] as List? ?? [];
    final timelineItems = rawTimeline
        .whereType<Map<String, dynamic>>()
        .map((t) => KycTimelineItem.fromJson(t))
        .toList();

    return KycStatusResponse(
      userId: json['userId'] as String? ?? '',
      kycStatus: json['kycStatus'] as String? ?? 'VERIFIED',
      isVerified: json['isVerified'] as bool? ?? true,
      redirectRoute: json['redirectRoute'] as String? ?? '/dashboard',
      currentStep: json['currentStep'] as int? ?? 6,
      totalSteps: json['totalSteps'] as int? ?? 6,
      timeline: timelineItems,
      summary: json['summary'] is Map<String, dynamic>
          ? KycSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : const KycSummary(),
    );
  }
}

class KycDocumentItem {
  final String id;
  final String documentType;
  final String idNumber;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String sha256Hash;
  final String status;
  final String? rejectionReason;
  final String? verifiedAt;
  final String? createdAt;
  final String? downloadUrl;

  const KycDocumentItem({
    required this.id,
    required this.documentType,
    required this.idNumber,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.sha256Hash,
    required this.status,
    this.rejectionReason,
    this.verifiedAt,
    this.createdAt,
    this.downloadUrl,
  });

  factory KycDocumentItem.fromJson(Map<String, dynamic> json) {
    return KycDocumentItem(
      id: json['id'] as String? ?? '',
      documentType: json['documentType'] as String? ?? 'PAN',
      idNumber: (json['idNumber'] ?? json['documentNumber']) as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileSize: (json['fileSize'] is num)
          ? (json['fileSize'] as num).toInt()
          : (int.tryParse(json['fileSize']?.toString() ?? '') ?? 0),
      mimeType: json['mimeType'] as String? ?? 'application/pdf',
      sha256Hash: json['sha256Hash'] as String? ?? '',
      status: json['status'] as String? ?? ((json['isVerified'] == true) ? 'VERIFIED' : 'PENDING'),
      rejectionReason: json['rejectionReason'] as String?,
      verifiedAt: json['verifiedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
    );
  }

  bool get isVerified => status.toUpperCase() == 'VERIFIED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  String get formattedFileSize {
    if (fileSize >= 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (fileSize >= 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '$fileSize B';
  }

  String get displayType {
    switch (documentType.toUpperCase()) {
      case 'PAN':
        return 'PAN Card';
      case 'AADHAAR':
        return 'Masked Aadhaar Card';
      case 'PASSPORT':
        return 'Passport';
      case 'DRIVING_LICENSE':
        return 'Driving License';
      default:
        return documentType;
    }
  }
}

class KycUploadResult {
  final String id;
  final String documentType;
  final String idNumber;
  final String fileName;
  final String sha256Hash;
  final String status;
  final String? verifiedAt;

  const KycUploadResult({
    required this.id,
    required this.documentType,
    required this.idNumber,
    required this.fileName,
    required this.sha256Hash,
    required this.status,
    this.verifiedAt,
  });

  factory KycUploadResult.fromJson(Map<String, dynamic> json) {
    return KycUploadResult(
      id: json['id'] as String? ?? '',
      documentType: json['documentType'] as String? ?? '',
      idNumber: json['idNumber'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      sha256Hash: json['sha256Hash'] as String? ?? '',
      status: json['status'] as String? ?? 'VERIFIED',
      verifiedAt: json['verifiedAt'] as String?,
    );
  }
}

class KycReVerifyResult {
  final String id;
  final String userId;
  final String documentType;
  final String idNumber;
  final String? filePath;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String sha256Hash;
  final String status;
  final String? rejectionReason;
  final String? verifiedAt;
  final String? createdAt;
  final String? updatedAt;

  const KycReVerifyResult({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.idNumber,
    this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.sha256Hash,
    required this.status,
    this.rejectionReason,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory KycReVerifyResult.fromJson(Map<String, dynamic> json) {
    return KycReVerifyResult(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      documentType: json['documentType'] as String? ?? '',
      idNumber: json['idNumber'] as String? ?? '',
      filePath: json['filePath'] as String?,
      fileName: json['fileName'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? 'application/pdf',
      sha256Hash: json['sha256Hash'] as String? ?? '',
      status: json['status'] as String? ?? 'VERIFIED',
      rejectionReason: json['rejectionReason'] as String?,
      verifiedAt: json['verifiedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
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
  final KycStatusResponse? liveStatus;
  final List<KycDocumentItem> liveDocuments;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final String? successMessage;

  const KycStateData({
    this.currentStep = 1,
    this.user = const UserRegistrationData(),
    this.isMobileVerified = false,
    this.isOtpVerified = false,
    this.isExistingUser = false,
    this.kycStatus = KycStatus.verified,
    this.registrationCompletedTime = '30 Sep 2026, 12:00 PM',
    this.kycSubmittedTime = '30 Sep 2026, 12:30 PM',
    this.liveStatus,
    this.liveDocuments = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.successMessage,
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
    KycStatusResponse? liveStatus,
    List<KycDocumentItem>? liveDocuments,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    String? successMessage,
  }) {
    return KycStateData(
      currentStep: currentStep ?? this.currentStep,
      user: user ?? this.user,
      isMobileVerified: isMobileVerified ?? this.isMobileVerified,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      isExistingUser: isExistingUser ?? this.isExistingUser,
      kycStatus: kycStatus ?? this.kycStatus,
      registrationCompletedTime:
          registrationCompletedTime ?? this.registrationCompletedTime,
      kycSubmittedTime: kycSubmittedTime ?? this.kycSubmittedTime,
      liveStatus: liveStatus ?? this.liveStatus,
      liveDocuments: liveDocuments ?? this.liveDocuments,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      successMessage: successMessage,
    );
  }
}
