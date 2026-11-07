import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../domain/document_models.dart';

class VaultApiService {
  final ApiClient _client = ApiClient();

  /// 1. Get Storage Summary & Category Breakdown
  /// GET /api/v1/vault/storage-summary
  Future<VaultStorageSummary?> getStorageSummary() async {
    try {
      final response = await _client.get(ApiConstants.vaultStorageSummary);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return VaultStorageSummary.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 2. Get Paginated Documents List with Category and Search filtering
  /// GET /api/v1/vault/documents
  Future<List<VaultDocument>?> getDocuments({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final endpoint = ApiConstants.vaultDocumentsQuery(
        category: category,
        search: search,
        page: page,
        limit: limit,
      );
      final response = await _client.get(endpoint);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          final list = body['data'] as List<dynamic>;
          return list
              .whereType<Map<String, dynamic>>()
              .map((d) => VaultDocument.fromJson(d))
              .toList();
        }
      }
    } catch (_) {}
    return null;
  }

  /// 3. Get Single Document with Audit Logs & Versions
  /// GET /api/v1/vault/documents/:id
  Future<VaultDocument?> getDocumentById(String id) async {
    try {
      final response = await _client.get(ApiConstants.vaultDocumentById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return VaultDocument.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 4. Upload Document with Section 65B tamper-evident hash
  /// POST /api/v1/vault/documents/upload
  Future<VaultDocument?> uploadDocument({
    required File file,
    required String name,
    required String category,
    required String idType,
    String? docNumber,
  }) async {
    try {
      final response = await _client.multipartPost(
        ApiConstants.vaultUpload,
        file: file,
        fileFieldName: 'file',
        fields: {
          'name': name.trim(),
          'category': category.trim(),
          'idType': idType.trim(),
          if (docNumber != null && docNumber.trim().isNotEmpty)
            'docNumber': docNumber.trim().toUpperCase(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return VaultDocument.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 5. Update Document Metadata (Name, docNumber, category, idType)
  /// PUT /api/v1/vault/documents/:id
  Future<VaultDocument?> updateDocumentMetadata({
    required String id,
    required String name,
    required String category,
    required String idType,
    String? docNumber,
  }) async {
    try {
      final response = await _client.put(
        ApiConstants.vaultDocumentById(id),
        body: {
          'name': name.trim(),
          'category': category.trim(),
          'idType': idType.trim(),
          if (docNumber != null) 'docNumber': docNumber.trim().toUpperCase(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return VaultDocument.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 6. Replace Document File (Version Upgrade)
  /// PUT /api/v1/vault/documents/:id/replace
  Future<VaultDocument?> replaceDocumentFile({
    required String id,
    required File file,
  }) async {
    try {
      final response = await _client.multipartPut(
        ApiConstants.vaultDocumentReplace(id),
        file: file,
        fileFieldName: 'file',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return VaultDocument.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 7. Delete Binary Only to Recover Quota (Card preserved as un-uploaded)
  /// DELETE /api/v1/vault/documents/:id/file
  Future<VaultDocument?> deleteDocumentFileOnly(String id) async {
    try {
      final response = await _client.delete(ApiConstants.vaultDocumentFile(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return VaultDocument.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 8. Permanently Delete Entire Document Card and Storage Quota
  /// DELETE /api/v1/vault/documents/:id
  Future<bool> deleteDocument(String id) async {
    try {
      final response = await _client.delete(ApiConstants.vaultDocumentById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// 9. Sync KYC identity documents with encrypted locker
  /// POST /api/v1/vault/sync/kyc
  Future<VaultSyncKycResult?> syncKycDocuments() async {
    try {
      final response = await _client.post(ApiConstants.vaultSyncKyc, body: {});
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return VaultSyncKycResult.fromJson(body);
      }
    } catch (_) {}
    return null;
  }

  /// 10. Cross-Module Summary: Digital Locker, Expense Receipts, Income Vouchers
  /// GET /api/v1/vault/cross-module/summary
  Future<VaultCrossModuleSummary?> getCrossModuleSummary() async {
    try {
      final response = await _client.get(ApiConstants.vaultCrossModuleSummary);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return VaultCrossModuleSummary.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 11. Download Document PDF/Binary Bytes
  /// GET /api/v1/vault/documents/:id/download
  Future<Uint8List?> downloadDocument(String id) async {
    return await _client.getBytes(ApiConstants.vaultDocumentDownload(id));
  }

  /// 12. Preview Document PDF/Binary Bytes
  /// GET /api/v1/vault/documents/:id/preview
  Future<Uint8List?> previewDocument(String id) async {
    return await _client.getBytes(ApiConstants.vaultDocumentPreview(id));
  }

  /// 13. Create Secure Section 65B Share Link
  /// POST /api/v1/vault/documents/:id/share
  Future<VaultSharedDocumentInfo?> shareDocument({
    required String id,
    int expiresInHours = 24,
    int maxAccess = 10,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.vaultDocumentShare(id),
        body: {
          'expiresInHours': expiresInHours,
          'maxAccess': maxAccess,
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return VaultSharedDocumentInfo.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 14. Access and Download Shared Document by Token
  /// GET /api/v1/vault/shared/:token
  Future<Uint8List?> getSharedDocument(String token) async {
    return await _client.getBytes(ApiConstants.vaultSharedDocument(token));
  }

  /// Download Document Bytes from arbitrary URL
  Future<Uint8List?> downloadDocumentBytes(String downloadUrl) async {
    return await _client.getBytes(downloadUrl);
  }
}
