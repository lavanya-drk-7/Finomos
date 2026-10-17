class VaultDocument {
  final String id;
  final String name;
  final String category; // 'KYC & ID Proof', 'PAN', 'Bank Statements', 'Insurance', 'Tax', 'Investment', 'Other'
  final String fileSize;
  final String uploadDate;
  final String expiryDate;
  final String fileUrl;
  final String idType; // 'PAN Card', 'Aadhaar Card', 'Passport', 'Driving License', etc.
  final String documentNumber; // e.g. 'ABCDE1234F'
  final bool isUploaded;
  final bool isVerified;
  final bool isFromKyc;

  const VaultDocument({
    required this.id,
    required this.name,
    required this.category,
    required this.fileSize,
    required this.uploadDate,
    this.expiryDate = '-',
    this.fileUrl = '',
    this.idType = 'Govt ID',
    this.documentNumber = '',
    this.isUploaded = true,
    this.isVerified = true,
    this.isFromKyc = false,
  });

  VaultDocument copyWith({
    String? id,
    String? name,
    String? category,
    String? fileSize,
    String? uploadDate,
    String? expiryDate,
    String? fileUrl,
    String? idType,
    String? documentNumber,
    bool? isUploaded,
    bool? isVerified,
    bool? isFromKyc,
  }) {
    return VaultDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      fileSize: fileSize ?? this.fileSize,
      uploadDate: uploadDate ?? this.uploadDate,
      expiryDate: expiryDate ?? this.expiryDate,
      fileUrl: fileUrl ?? this.fileUrl,
      idType: idType ?? this.idType,
      documentNumber: documentNumber ?? this.documentNumber,
      isUploaded: isUploaded ?? this.isUploaded,
      isVerified: isVerified ?? this.isVerified,
      isFromKyc: isFromKyc ?? this.isFromKyc,
    );
  }
}

class DocumentVaultState {
  final List<VaultDocument> documents;
  final String searchQuery;
  final String selectedCategoryFilter;
  final double storageUsedGB;
  final double storageLimitGB;

  const DocumentVaultState({
    required this.documents,
    this.searchQuery = '',
    this.selectedCategoryFilter = 'All',
    this.storageUsedGB = 2.5,
    this.storageLimitGB = 10.0,
  });

  int get totalDocuments => documents.length;
  double get storagePercentage => (storageUsedGB / storageLimitGB).clamp(0.0, 1.0) * 100;

  DocumentVaultState copyWith({
    List<VaultDocument>? documents,
    String? searchQuery,
    String? selectedCategoryFilter,
    double? storageUsedGB,
    double? storageLimitGB,
  }) {
    return DocumentVaultState(
      documents: documents ?? this.documents,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryFilter: selectedCategoryFilter ?? this.selectedCategoryFilter,
      storageUsedGB: storageUsedGB ?? this.storageUsedGB,
      storageLimitGB: storageLimitGB ?? this.storageLimitGB,
    );
  }
}
