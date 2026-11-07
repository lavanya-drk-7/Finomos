import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/cache_service.dart';
import '../../auth_kyc/domain/kyc_models.dart';
import '../domain/document_models.dart';
import '../services/vault_api_service.dart';

class DocumentVaultNotifier extends Notifier<DocumentVaultState> {
  final VaultApiService _vaultApiService = VaultApiService();

  @override
  DocumentVaultState build() {
    final rawDeleted = LocalCacheService().get('deleted_vault_document_ids');
    final deletedIds = (rawDeleted is List) ? Set<String>.from(rawDeleted) : <String>{};

    final cached = LocalCacheService().get('vault_documents');
    List<VaultDocument>? cachedDocs;
    if (cached is List) {
      cachedDocs = cached
          .whereType<Map>()
          .map((d) => VaultDocument.fromJson(Map<String, dynamic>.from(d)))
          .where((d) => !deletedIds.contains(d.id))
          .toList();
    }

    Future.microtask(() => loadLiveVaultData());

    return DocumentVaultState(
      documents: cachedDocs ?? const [],
      storageUsedGB: cachedDocs != null && cachedDocs.isNotEmpty ? 0.2 * cachedDocs.length : 0.0,
      storageLimitGB: 10.0,
    );
  }

  /// Load live vault data: storage-summary, cross-module summary, and documents
  Future<void> loadLiveVaultData({bool force = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final categoryParam = (state.selectedCategoryFilter == 'All' || state.selectedCategoryFilter.isEmpty)
          ? null
          : state.selectedCategoryFilter;
      final searchParam = state.searchQuery.trim().isNotEmpty ? state.searchQuery.trim() : null;

      final results = await Future.wait([
        _vaultApiService.getStorageSummary(),
        _vaultApiService.getCrossModuleSummary(),
        _vaultApiService.getDocuments(
          category: categoryParam,
          search: searchParam,
          page: 1,
          limit: 50,
        ),
      ]);

      final VaultStorageSummary? summary = results[0] as VaultStorageSummary?;
      final VaultCrossModuleSummary? crossModule = results[1] as VaultCrossModuleSummary?;
      final List<VaultDocument>? liveDocs = results[2] as List<VaultDocument>?;

      List<VaultDocument> finalDocs = state.documents;
      if (liveDocs != null) {
        final rawDeleted = LocalCacheService().get('deleted_vault_document_ids');
        final deletedIds = (rawDeleted is List) ? Set<String>.from(rawDeleted) : <String>{};

        finalDocs = liveDocs
            .where((d) => !deletedIds.contains(d.id))
            .toList();
        LocalCacheService().save(
          'vault_documents',
          finalDocs.map((d) => d.toJson()).toList(),
        );
      }

      final updatedStorageUsed = summary?.storageUsedGB ?? (finalDocs.isEmpty ? 0.0 : state.storageUsedGB);
      final updatedStorageLimit = summary?.storageLimitGB.toDouble() ?? state.storageLimitGB;

      state = state.copyWith(
        documents: finalDocs,
        storageSummary: summary ?? state.storageSummary,
        crossModuleSummary: crossModule ?? state.crossModuleSummary,
        storageUsedGB: updatedStorageUsed,
        storageLimitGB: updatedStorageLimit,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error loading live vault data: $e');
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to refresh vault data');
    }
  }

  /// Live Upload Document with Section 65B tamper-evident hash
  Future<VaultDocument?> uploadDocumentLive({
    required File file,
    required String name,
    required String category,
    required String idType,
    String? docNumber,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final newDoc = await _vaultApiService.uploadDocument(
        file: file,
        name: name,
        category: category,
        idType: idType,
        docNumber: docNumber,
      );

      if (newDoc != null) {
        final updated = [newDoc, ...state.documents];
        state = state.copyWith(
          documents: updated,
          isLoading: false,
          successMessage: 'Document uploaded successfully with Section 65B hash',
        );
        LocalCacheService().save(
          'vault_documents',
          updated.map((d) => d.toJson()).toList(),
        );
        // Refresh storage summary in the background
        _vaultApiService.getStorageSummary().then((summary) {
          if (summary != null) {
            state = state.copyWith(
              storageSummary: summary,
              storageUsedGB: summary.storageUsedGB,
              storageLimitGB: summary.storageLimitGB.toDouble(),
            );
          }
        });
        return newDoc;
      }
    } catch (e) {
      debugPrint('Error uploading live document: $e');
    }
    state = state.copyWith(isLoading: false);
    return null;
  }

  /// Live Replace Document File (version upgrade)
  Future<VaultDocument?> replaceDocumentLive({
    required String id,
    required File file,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedDoc = await _vaultApiService.replaceDocumentFile(id: id, file: file);
      if (updatedDoc != null) {
        final updatedList = state.documents.map((d) => d.id == id ? updatedDoc : d).toList();
        state = state.copyWith(
          documents: updatedList,
          isLoading: false,
          successMessage: 'Document replaced successfully',
        );
        // Refresh summary
        _vaultApiService.getStorageSummary().then((summary) {
          if (summary != null) {
            state = state.copyWith(
              storageSummary: summary,
              storageUsedGB: summary.storageUsedGB,
              storageLimitGB: summary.storageLimitGB.toDouble(),
            );
          }
        });
        return updatedDoc;
      }
    } catch (e) {
      debugPrint('Error replacing live document: $e');
    }
    state = state.copyWith(isLoading: false);
    return null;
  }

  /// Live Update Document Metadata (name, docNumber, category, idType)
  Future<VaultDocument?> updateDocumentMetadataLive({
    required String id,
    required String name,
    required String category,
    required String idType,
    String? docNumber,
  }) async {
    try {
      final updatedDoc = await _vaultApiService.updateDocumentMetadata(
        id: id,
        name: name,
        category: category,
        idType: idType,
        docNumber: docNumber,
      );
      if (updatedDoc != null) {
        final updatedList = state.documents.map((d) => d.id == id ? updatedDoc : d).toList();
        state = state.copyWith(documents: updatedList);
        return updatedDoc;
      }
    } catch (e) {
      debugPrint('Error updating document metadata: $e');
    }
    return null;
  }

  /// Live Delete File Only (binary quota recovery)
  Future<bool> deleteDocumentFileOnlyLive(String id) async {
    try {
      final updatedDoc = await _vaultApiService.deleteDocumentFileOnly(id);
      if (updatedDoc != null) {
        final updatedList = state.documents.map((d) => d.id == id ? updatedDoc : d).toList();
        state = state.copyWith(documents: updatedList);
        // Refresh storage summary
        _vaultApiService.getStorageSummary().then((summary) {
          if (summary != null) {
            state = state.copyWith(
              storageSummary: summary,
              storageUsedGB: summary.storageUsedGB,
              storageLimitGB: summary.storageLimitGB.toDouble(),
            );
          }
        });
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting document file only: $e');
    }
    // Fallback locally
    deleteUploadedFileOnly(id);
    return true;
  }

  /// Live Permanently Delete Document
  Future<bool> deleteDocumentLive(String id) async {
    try {
      final ok = await _vaultApiService.deleteDocument(id);
      if (ok) {
        final updated = state.documents.where((d) => d.id != id).toList();
        state = state.copyWith(
          documents: updated,
        );
        LocalCacheService().save(
          'vault_documents',
          updated.map((d) => d.toJson()).toList(),
        );
        // Refresh storage summary
        _vaultApiService.getStorageSummary().then((summary) {
          if (summary != null) {
            state = state.copyWith(
              storageSummary: summary,
              storageUsedGB: summary.storageUsedGB,
              storageLimitGB: summary.storageLimitGB.toDouble(),
            );
          }
        });
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting document permanently: $e');
    }
    // Fallback locally
    deleteDocument(id);
    return true;
  }

  /// Live Sync KYC documents to digital locker
  Future<VaultSyncKycResult?> syncKycWithLocker() async {
    state = state.copyWith(isSyncing: true);
    try {
      final result = await _vaultApiService.syncKycDocuments();
      if (result != null && result.success) {
        // Re-fetch all documents and storage summary from backend
        await loadLiveVaultData(force: true);
        state = state.copyWith(
          isSyncing: false,
          successMessage: 'Successfully synced ${result.syncedCount} KYC proofs into locker',
        );
        return result;
      }
    } catch (e) {
      debugPrint('Error syncing KYC documents: $e');
    }
    state = state.copyWith(isSyncing: false);
    return null;
  }

  /// Fetch full document details with audit logs
  Future<VaultDocument?> fetchDocumentDetails(String id) async {
    try {
      final doc = await _vaultApiService.getDocumentById(id);
      if (doc != null) {
        final updatedList = state.documents.map((d) => d.id == id ? doc : d).toList();
        state = state.copyWith(documents: updatedList);
        return doc;
      }
    } catch (e) {
      debugPrint('Error fetching document details: $e');
    }
    return null;
  }

  /// 11. Download Document PDF/Binary Bytes
  Future<Uint8List?> downloadDocumentLive(String id) async {
    return await _vaultApiService.downloadDocument(id);
  }

  /// 12. Preview Document PDF/Binary Bytes
  Future<Uint8List?> previewDocumentLive(String id) async {
    return await _vaultApiService.previewDocument(id);
  }

  /// 13. Create Secure Section 65B Share Link
  Future<VaultSharedDocumentInfo?> shareDocumentLive({
    required String id,
    int expiresInHours = 24,
    int maxAccess = 10,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final sharedInfo = await _vaultApiService.shareDocument(
        id: id,
        expiresInHours: expiresInHours,
        maxAccess: maxAccess,
      );
      if (sharedInfo != null) {
        state = state.copyWith(
          isLoading: false,
          lastSharedDocument: sharedInfo,
          successMessage: 'Share link generated successfully',
        );
        return sharedInfo;
      }
    } catch (e) {
      debugPrint('Error sharing document: $e');
    }
    state = state.copyWith(isLoading: false);
    return null;
  }

  /// 14. Access and Download Shared Document by Token
  Future<Uint8List?> getSharedDocumentLive(String token) async {
    return await _vaultApiService.getSharedDocument(token);
  }

  // --------------------------------------------------------------------------
  // SYNCHRONOUS / LOCAL METHODS (Preserves full backward compatibility)
  // --------------------------------------------------------------------------

  void syncKycDocuments(List<KycDocumentRecord> kycDocs) {
    if (kycDocs.isEmpty) return;
    final nonKycDocs = state.documents.where((d) => !d.isFromKyc).toList();

    final rawDeleted = LocalCacheService().get('deleted_vault_document_ids');
    final deletedIds = (rawDeleted is List) ? Set<String>.from(rawDeleted) : <String>{};

    final kycVaultDocs = kycDocs
        .where((k) => k.isUploaded && k.fileName.trim().isNotEmpty)
        .map((kyc) {
      final docId = 'kyc_doc_${kyc.idType.toLowerCase().replaceAll(' ', '_')}';
      return VaultDocument(
        id: docId,
        name: kyc.fileName,
        category: 'KYC & ID Proof',
        idType: kyc.idType,
        documentNumber: kyc.idNumber,
        fileSize: kyc.fileSize.isNotEmpty ? kyc.fileSize : '1.8 MB',
        fileUrl: kyc.fileUrl,
        uploadDate: kyc.uploadDate.isNotEmpty ? kyc.uploadDate : 'Today',
        isUploaded: kyc.isUploaded,
        isVerified: kyc.isUploaded,
        isFromKyc: true,
        sourceModule: 'KYC',
      );
    }).where((d) => !deletedIds.contains(d.id)).toList();

    state = state.copyWith(
      documents: [...kycVaultDocs, ...nonKycDocs],
    );
  }

  void uploadDocument(VaultDocument doc) {
    state = state.copyWith(
      documents: [doc, ...state.documents],
      storageUsedGB: (state.storageUsedGB + 0.2).clamp(0.0, state.storageLimitGB),
    );
  }

  void replaceDocument(String id, String newFileName, String newFileSize, [String newFileUrl = '']) {
    final updated = state.documents.map((d) {
      if (d.id == id) {
        return d.copyWith(
          name: newFileName,
          fileSize: newFileSize,
          fileUrl: newFileUrl.isNotEmpty ? newFileUrl : d.fileUrl,
          uploadDate: 'Today',
          isUploaded: true,
        );
      }
      return d;
    }).toList();
    state = state.copyWith(documents: updated);
  }

  void renameDocument(String id, String newName) {
    final updated = state.documents.map((d) => d.id == id ? d.copyWith(name: newName) : d).toList();
    state = state.copyWith(documents: updated);
  }

  void deleteDocument(String id) {
    final rawDeleted = LocalCacheService().get('deleted_vault_document_ids');
    final deletedList = (rawDeleted is List) ? List<String>.from(rawDeleted) : <String>[];
    if (!deletedList.contains(id)) {
      deletedList.add(id);
      LocalCacheService().save('deleted_vault_document_ids', deletedList);
    }

    final updated = state.documents.where((d) => d.id != id).toList();
    state = state.copyWith(
      documents: updated,
      storageUsedGB: (state.storageUsedGB - 0.2).clamp(0.0, state.storageLimitGB),
    );
    LocalCacheService().save(
      'vault_documents',
      updated.map((d) => d.toJson()).toList(),
    );
    _vaultApiService.deleteDocument(id).catchError((_) => false);
  }

  void deleteUploadedFileOnly(String id) {
    final updated = state.documents.map((d) {
      if (d.id == id) {
        return d.copyWith(
          isUploaded: false,
          name: '',
          fileSize: '',
          fileUrl: '',
        );
      }
      return d;
    }).toList();
    state = state.copyWith(documents: updated);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategoryFilter: category);
  }
}

final documentVaultProvider = NotifierProvider<DocumentVaultNotifier, DocumentVaultState>(() {
  return DocumentVaultNotifier();
});
