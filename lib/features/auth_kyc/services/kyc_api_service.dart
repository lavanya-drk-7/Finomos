import 'dart:convert';
import 'dart:io';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/cache_service.dart';
import '../domain/kyc_models.dart';

class KycApiService {
  final ApiClient _client = ApiClient();

  /// Fetch live KYC verification status and timeline
  /// GET /api/v1/kyc/status
  Future<KycStatusResponse?> getKycStatus() async {
    try {
      final response = await _client.get(ApiConstants.kycStatus);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          final data = body['data'] as Map<String, dynamic>;
          LocalCacheService().save('kyc_status', data);
          return KycStatusResponse.fromJson(data);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Retrieve cached KYC status for instant 0ms rendering
  KycStatusResponse? getCachedStatus() {
    final cached = LocalCacheService().get('kyc_status');
    if (cached is Map) {
      return KycStatusResponse.fromJson(Map<String, dynamic>.from(cached));
    }
    return null;
  }

  /// Fetch all submitted KYC documents and their Section 65B verification states
  /// GET /api/v1/kyc/documents
  Future<List<KycDocumentItem>?> getKycDocuments() async {
    try {
      final response = await _client.get(ApiConstants.kycDocuments);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          final rawList = body['data'] as List;
          LocalCacheService().save('kyc_documents', rawList);
          return rawList
              .whereType<Map>()
              .map((d) => KycDocumentItem.fromJson(Map<String, dynamic>.from(d)))
              .toList();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Retrieve cached KYC documents for instant 0ms rendering
  List<KycDocumentItem>? getCachedDocuments() {
    final cached = LocalCacheService().get('kyc_documents');
    if (cached is List) {
      return cached
          .whereType<Map>()
          .map((d) => KycDocumentItem.fromJson(Map<String, dynamic>.from(d)))
          .toList();
    }
    return null;
  }

  /// Upload a KYC identity proof document (PAN, Aadhaar, Passport)
  /// POST /api/v1/kyc/upload
  Future<KycUploadResult?> uploadKycDocument({
    required File file,
    required String documentType,
    required String idNumber,
  }) async {
    try {
      final response = await _client.multipartPost(
        ApiConstants.kycUpload,
        file: file,
        fileFieldName: 'file',
        fields: {
          'documentType': documentType,
          'idNumber': idNumber,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          // Re-sync KYC status and documents in background
          getKycStatus();
          getKycDocuments();
          return KycUploadResult.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Re-verify a previously submitted KYC document
  /// POST /api/v1/kyc/re-verify
  Future<KycReVerifyResult?> reVerifyDocument(String documentType) async {
    try {
      final response = await _client.post(
        ApiConstants.kycReVerify,
        body: {'documentType': documentType},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          // Re-sync KYC status and documents in background
          getKycStatus();
          getKycDocuments();
          return KycReVerifyResult.fromJson(
              body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }
}

