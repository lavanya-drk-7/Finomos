class VaultAuditLog {
  final String id;
  final String documentId;
  final String userId;
  final String action;
  final Map<String, dynamic> details;
  final String createdAt;

  const VaultAuditLog({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.action,
    this.details = const {},
    required this.createdAt,
  });

  factory VaultAuditLog.fromJson(Map<String, dynamic> json) {
    return VaultAuditLog(
      id: json['id'] as String? ?? '',
      documentId: json['documentId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      action: json['action'] as String? ?? '',
      details: json['details'] is Map<String, dynamic>
          ? json['details'] as Map<String, dynamic>
          : {},
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'userId': userId,
      'action': action,
      'details': details,
      'createdAt': createdAt,
    };
  }
}

class VaultDocument {
  final String id;
  final String name;
  final String category; // 'KYC & Identity', 'Financial & Bank', 'Tax & Compliance', etc.
  final String fileSize;
  final String uploadDate;
  final String expiryDate;
  final String fileUrl;
  final String idType; // 'PAN Card', 'Aadhaar Card', 'Passport', 'Driving License', etc.
  final String documentNumber; // e.g. 'ABCDE1234F'
  final bool isUploaded;
  final bool isVerified;
  final bool isFromKyc;

  // Live Backend Metadata
  final String? mimeType;
  final int? size;
  final String? sizeFormatted;
  final String? sha256Hash;
  final int version;
  final String sourceModule; // 'VAULT', 'KYC'
  final String? issueDate;
  final String? createdAt;
  final String? updatedAt;
  final String? downloadUrl;
  final String? previewUrl;
  final List<Map<String, dynamic>> versions;
  final List<VaultAuditLog> auditLogs;

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
    this.mimeType,
    this.size,
    this.sizeFormatted,
    this.sha256Hash,
    this.version = 1,
    this.sourceModule = 'VAULT',
    this.issueDate,
    this.createdAt,
    this.updatedAt,
    this.downloadUrl,
    this.previewUrl,
    this.versions = const [],
    this.auditLogs = const [],
  });

  String get docNumber => documentNumber;

  factory VaultDocument.fromJson(Map<String, dynamic> json) {
    final rawSize = json['size'];
    final int sizeBytes = (rawSize is num) ? rawSize.toInt() : 0;
    final formattedSize = json['sizeFormatted'] as String? ??
        (sizeBytes >= 1024 * 1024
            ? '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
            : sizeBytes >= 1024
                ? '${(sizeBytes / 1024).toStringAsFixed(1)} KB'
                : '$sizeBytes B');

    final rawCreated = json['createdAt'] as String? ?? json['uploadDate'] as String? ?? '';
    String displayDate = 'Today';
    if (rawCreated.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawCreated).toLocal();
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        displayDate = '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {
        displayDate = rawCreated;
      }
    }

    final source = json['sourceModule'] as String? ?? 'VAULT';
    final rawCat = json['category'] as String? ?? 'KYC & Identity';
    final isKyc = source.toUpperCase() == 'KYC' ||
        rawCat.toLowerCase().contains('kyc') ||
        rawCat.toLowerCase().contains('pan') ||
        rawCat.toLowerCase().contains('aadhaar');

    final rawAudit = json['auditLogs'] as List<dynamic>? ?? [];
    final auditList = rawAudit
        .whereType<Map<String, dynamic>>()
        .map((a) => VaultAuditLog.fromJson(a))
        .toList();

    final rawVersions = json['versions'] as List<dynamic>? ?? [];
    final versionList = rawVersions.whereType<Map<String, dynamic>>().toList();

    return VaultDocument(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: rawCat,
      fileSize: formattedSize,
      uploadDate: displayDate,
      expiryDate: json['expiryDate'] as String? ?? '-',
      fileUrl: json['downloadUrl'] as String? ?? json['filePath'] as String? ?? '',
      idType: json['idType'] as String? ?? 'Govt ID',
      documentNumber: json['docNumber'] as String? ?? json['documentNumber'] as String? ?? '',
      isUploaded: json['isUploaded'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? true,
      isFromKyc: isKyc,
      mimeType: json['mimeType'] as String?,
      size: sizeBytes,
      sizeFormatted: formattedSize,
      sha256Hash: json['sha256Hash'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
      sourceModule: source,
      issueDate: json['issueDate'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      previewUrl: json['previewUrl'] as String?,
      versions: versionList,
      auditLogs: auditList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'idType': idType,
      'docNumber': documentNumber,
      'mimeType': mimeType,
      'size': size,
      'sizeFormatted': sizeFormatted ?? fileSize,
      'sha256Hash': sha256Hash,
      'version': version,
      'isUploaded': isUploaded,
      'isVerified': isVerified,
      'sourceModule': sourceModule,
      'issueDate': issueDate,
      'expiryDate': expiryDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'downloadUrl': downloadUrl ?? fileUrl,
      'previewUrl': previewUrl,
    };
  }

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
    String? mimeType,
    int? size,
    String? sizeFormatted,
    String? sha256Hash,
    int? version,
    String? sourceModule,
    String? issueDate,
    String? createdAt,
    String? updatedAt,
    String? downloadUrl,
    String? previewUrl,
    List<Map<String, dynamic>>? versions,
    List<VaultAuditLog>? auditLogs,
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
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      sizeFormatted: sizeFormatted ?? this.sizeFormatted,
      sha256Hash: sha256Hash ?? this.sha256Hash,
      version: version ?? this.version,
      sourceModule: sourceModule ?? this.sourceModule,
      issueDate: issueDate ?? this.issueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      versions: versions ?? this.versions,
      auditLogs: auditLogs ?? this.auditLogs,
    );
  }
}

class VaultCategorySummary {
  final String category;
  final int count;
  final int sizeBytes;
  final double usagePercentage;

  const VaultCategorySummary({
    required this.category,
    required this.count,
    required this.sizeBytes,
    required this.usagePercentage,
  });

  factory VaultCategorySummary.fromJson(Map<String, dynamic> json) {
    return VaultCategorySummary(
      category: json['category'] as String? ?? 'Other',
      count: (json['count'] as num?)?.toInt() ?? 0,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      usagePercentage: (json['usagePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'count': count,
      'sizeBytes': sizeBytes,
      'usagePercentage': usagePercentage,
    };
  }
}

class VaultStorageSummary {
  final double storageUsedGB;
  final num storageLimitGB;
  final int storageUsedBytes;
  final int storageLimitBytes;
  final double usagePercentage;
  final int totalDocuments;
  final int verifiedDocuments;
  final int pendingDocuments;
  final List<VaultCategorySummary> categories;

  const VaultStorageSummary({
    required this.storageUsedGB,
    required this.storageLimitGB,
    required this.storageUsedBytes,
    required this.storageLimitBytes,
    required this.usagePercentage,
    required this.totalDocuments,
    required this.verifiedDocuments,
    required this.pendingDocuments,
    this.categories = const [],
  });

  factory VaultStorageSummary.fromJson(Map<String, dynamic> json) {
    final rawCats = json['categories'] as List<dynamic>? ?? [];
    final catList = rawCats
        .whereType<Map<String, dynamic>>()
        .map((c) => VaultCategorySummary.fromJson(c))
        .toList();

    return VaultStorageSummary(
      storageUsedGB: (json['storageUsedGB'] as num?)?.toDouble() ?? 0.0,
      storageLimitGB: (json['storageLimitGB'] as num?) ?? 10,
      storageUsedBytes: (json['storageUsedBytes'] as num?)?.toInt() ?? 0,
      storageLimitBytes: (json['storageLimitBytes'] as num?)?.toInt() ?? 10737418240,
      usagePercentage: (json['usagePercentage'] as num?)?.toDouble() ?? 0.0,
      totalDocuments: (json['totalDocuments'] as num?)?.toInt() ?? 0,
      verifiedDocuments: (json['verifiedDocuments'] as num?)?.toInt() ?? 0,
      pendingDocuments: (json['pendingDocuments'] as num?)?.toInt() ?? 0,
      categories: catList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storageUsedGB': storageUsedGB,
      'storageLimitGB': storageLimitGB,
      'storageUsedBytes': storageUsedBytes,
      'storageLimitBytes': storageLimitBytes,
      'usagePercentage': usagePercentage,
      'totalDocuments': totalDocuments,
      'verifiedDocuments': verifiedDocuments,
      'pendingDocuments': pendingDocuments,
      'categories': categories.map((c) => c.toJson()).toList(),
    };
  }
}

class VaultPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const VaultPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory VaultPagination.fromJson(Map<String, dynamic> json) {
    return VaultPagination(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class VaultCrossModuleReceipt {
  final String id;
  final String description;
  final num amount;
  final String date;
  final String? receiptUrl;
  final String? documentPath;

  const VaultCrossModuleReceipt({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    this.receiptUrl,
    this.documentPath,
  });

  factory VaultCrossModuleReceipt.fromJson(Map<String, dynamic> json) {
    return VaultCrossModuleReceipt(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?) ?? 0,
      date: json['date'] as String? ?? '',
      receiptUrl: json['receiptUrl'] as String?,
      documentPath: json['documentPath'] as String?,
    );
  }
}

class VaultCrossModuleVoucher {
  final String id;
  final String source;
  final num amount;
  final String date;
  final String? voucherNumber;
  final String? documentPath;
  final String? receiptUrl;

  const VaultCrossModuleVoucher({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    this.voucherNumber,
    this.documentPath,
    this.receiptUrl,
  });

  factory VaultCrossModuleVoucher.fromJson(Map<String, dynamic> json) {
    return VaultCrossModuleVoucher(
      id: json['id'] as String? ?? '',
      source: json['source'] as String? ?? '',
      amount: (json['amount'] as num?) ?? 0,
      date: json['date'] as String? ?? '',
      voucherNumber: json['voucherNumber'] as String?,
      documentPath: json['documentPath'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
    );
  }
}

class VaultCrossModuleSummary {
  final int digitalLockerDocuments;
  final int expenseReceiptsCount;
  final int incomeVouchersCount;
  final int totalFinancialProofs;
  final List<VaultCrossModuleReceipt> recentExpenseReceipts;
  final List<VaultCrossModuleVoucher> recentIncomeVouchers;

  const VaultCrossModuleSummary({
    required this.digitalLockerDocuments,
    required this.expenseReceiptsCount,
    required this.incomeVouchersCount,
    required this.totalFinancialProofs,
    this.recentExpenseReceipts = const [],
    this.recentIncomeVouchers = const [],
  });

  factory VaultCrossModuleSummary.fromJson(Map<String, dynamic> json) {
    final rawReceipts = json['recentExpenseReceipts'] as List<dynamic>? ?? [];
    final receipts = rawReceipts
        .whereType<Map<String, dynamic>>()
        .map((r) => VaultCrossModuleReceipt.fromJson(r))
        .toList();

    final rawVouchers = json['recentIncomeVouchers'] as List<dynamic>? ?? [];
    final vouchers = rawVouchers
        .whereType<Map<String, dynamic>>()
        .map((v) => VaultCrossModuleVoucher.fromJson(v))
        .toList();

    return VaultCrossModuleSummary(
      digitalLockerDocuments: (json['digitalLockerDocuments'] as num?)?.toInt() ?? 0,
      expenseReceiptsCount: (json['expenseReceiptsCount'] as num?)?.toInt() ?? 0,
      incomeVouchersCount: (json['incomeVouchersCount'] as num?)?.toInt() ?? 0,
      totalFinancialProofs: (json['totalFinancialProofs'] as num?)?.toInt() ?? 0,
      recentExpenseReceipts: receipts,
      recentIncomeVouchers: vouchers,
    );
  }
}

class VaultSyncKycItem {
  final String id;
  final String name;
  final String idType;
  final String docNumber;
  final bool isVerified;
  final String sha256Hash;

  const VaultSyncKycItem({
    required this.id,
    required this.name,
    required this.idType,
    required this.docNumber,
    required this.isVerified,
    required this.sha256Hash,
  });

  factory VaultSyncKycItem.fromJson(Map<String, dynamic> json) {
    return VaultSyncKycItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      idType: json['idType'] as String? ?? '',
      docNumber: json['docNumber'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? true,
      sha256Hash: json['sha256Hash'] as String? ?? '',
    );
  }
}

class VaultSyncKycResult {
  final bool success;
  final String message;
  final int syncedCount;
  final List<VaultSyncKycItem> documents;

  const VaultSyncKycResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    this.documents = const [],
  });

  factory VaultSyncKycResult.fromJson(Map<String, dynamic> json) {
    final rawDocs = (json['data'] is Map<String, dynamic>)
        ? (json['data']['documents'] as List<dynamic>? ?? [])
        : [];
    final docList = rawDocs
        .whereType<Map<String, dynamic>>()
        .map((d) => VaultSyncKycItem.fromJson(d))
        .toList();

    final count = (json['data'] is Map<String, dynamic>)
        ? (json['data']['syncedCount'] as num?)?.toInt() ?? docList.length
        : docList.length;

    return VaultSyncKycResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      syncedCount: count,
      documents: docList,
    );
  }
}

class VaultSharedDocumentInfo {
  final String shareUrl;
  final String token;
  final String documentId;
  final String documentName;
  final String expiresAt;
  final int maxAccess;
  final int accessCount;

  const VaultSharedDocumentInfo({
    required this.shareUrl,
    required this.token,
    required this.documentId,
    required this.documentName,
    required this.expiresAt,
    required this.maxAccess,
    this.accessCount = 0,
  });

  factory VaultSharedDocumentInfo.fromJson(Map<String, dynamic> json) {
    return VaultSharedDocumentInfo(
      shareUrl: json['shareUrl'] as String? ?? '',
      token: json['token'] as String? ?? '',
      documentId: json['documentId'] as String? ?? '',
      documentName: json['documentName'] as String? ?? '',
      expiresAt: json['expiresAt'] as String? ?? '',
      maxAccess: (json['maxAccess'] as num?)?.toInt() ?? 10,
      accessCount: (json['accessCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareUrl': shareUrl,
      'token': token,
      'documentId': documentId,
      'documentName': documentName,
      'expiresAt': expiresAt,
      'maxAccess': maxAccess,
      'accessCount': accessCount,
    };
  }
}

class DocumentVaultState {
  final List<VaultDocument> documents;
  final String searchQuery;
  final String selectedCategoryFilter;
  final double storageUsedGB;
  final double storageLimitGB;
  final VaultStorageSummary? storageSummary;
  final VaultCrossModuleSummary? crossModuleSummary;
  final VaultSharedDocumentInfo? lastSharedDocument;
  final bool isLoading;
  final bool isSyncing;
  final String? errorMessage;
  final String? successMessage;
  final int totalCount;
  final int currentPage;

  const DocumentVaultState({
    required this.documents,
    this.searchQuery = '',
    this.selectedCategoryFilter = 'All',
    this.storageUsedGB = 0.02,
    this.storageLimitGB = 10.0,
    this.storageSummary,
    this.crossModuleSummary,
    this.lastSharedDocument,
    this.isLoading = false,
    this.isSyncing = false,
    this.errorMessage,
    this.successMessage,
    this.totalCount = 0,
    this.currentPage = 1,
  });

  int get totalDocuments => documents.length;
  double get storagePercentage => storageSummary != null
      ? storageSummary!.usagePercentage
      : ((storageUsedGB / storageLimitGB).clamp(0.0, 1.0) * 100);

  DocumentVaultState copyWith({
    List<VaultDocument>? documents,
    String? searchQuery,
    String? selectedCategoryFilter,
    double? storageUsedGB,
    double? storageLimitGB,
    VaultStorageSummary? storageSummary,
    VaultCrossModuleSummary? crossModuleSummary,
    VaultSharedDocumentInfo? lastSharedDocument,
    bool? isLoading,
    bool? isSyncing,
    String? errorMessage,
    String? successMessage,
    int? totalCount,
    int? currentPage,
  }) {
    return DocumentVaultState(
      documents: documents ?? this.documents,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryFilter: selectedCategoryFilter ?? this.selectedCategoryFilter,
      storageUsedGB: storageUsedGB ?? this.storageUsedGB,
      storageLimitGB: storageLimitGB ?? this.storageLimitGB,
      storageSummary: storageSummary ?? this.storageSummary,
      crossModuleSummary: crossModuleSummary ?? this.crossModuleSummary,
      lastSharedDocument: lastSharedDocument ?? this.lastSharedDocument,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage,
      successMessage: successMessage,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
