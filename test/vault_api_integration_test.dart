import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/constants/api_constants.dart';
import 'package:finomos/features/document_vault/domain/document_models.dart';
import 'package:finomos/features/document_vault/providers/document_provider.dart';

void main() {
  group('Document Vault Models & API Serialization Tests', () {
    test('VaultStorageSummary parses exact API response correctly', () {
      final jsonStr = '''{
        "storageUsedGB": 0.021,
        "storageLimitGB": 10,
        "storageUsedBytes": 22583621,
        "storageLimitBytes": 10737418240,
        "usagePercentage": 0.21,
        "totalDocuments": 15,
        "verifiedDocuments": 15,
        "pendingDocuments": 0,
        "categories": [
            {
                "category": "KYC & Identity",
                "count": 11,
                "sizeBytes": 8133621,
                "usagePercentage": 0.08
            },
            {
                "category": "Financial & Bank",
                "count": 1,
                "sizeBytes": 4500000,
                "usagePercentage": 0.04
            },
            {
                "category": "Tax & Compliance",
                "count": 1,
                "sizeBytes": 3850000,
                "usagePercentage": 0.04
            },
            {
                "category": "Insurance & Health",
                "count": 1,
                "sizeBytes": 2900000,
                "usagePercentage": 0.03
            },
            {
                "category": "Investment & Wealth",
                "count": 1,
                "sizeBytes": 3200000,
                "usagePercentage": 0.03
            },
            {
                "category": "Other",
                "count": 0,
                "sizeBytes": 0,
                "usagePercentage": 0
            }
        ]
      }''';

      final Map<String, dynamic> data = jsonDecode(jsonStr);
      final summary = VaultStorageSummary.fromJson(data);

      expect(summary.storageUsedGB, 0.021);
      expect(summary.storageLimitGB, 10);
      expect(summary.storageUsedBytes, 22583621);
      expect(summary.totalDocuments, 15);
      expect(summary.verifiedDocuments, 15);
      expect(summary.pendingDocuments, 0);
      expect(summary.categories.length, 6);
      expect(summary.categories[0].category, 'KYC & Identity');
      expect(summary.categories[0].count, 11);
      expect(summary.categories[1].category, 'Financial & Bank');
      expect(summary.categories[1].count, 1);
    });

    test('VaultDocument parses live paginated document with Section 65B hash and metadata', () {
      final docJson = '''{
        "id": "cmvz1e7i30019thzqoeng7ssk",
        "name": "Passport Front & Back",
        "category": "KYC & Identity",
        "idType": "Passport",
        "docNumber": "Z8765432",
        "mimeType": "image/png",
        "size": 1053417,
        "sizeFormatted": "1028.7 KB",
        "sha256Hash": "2db2efed7527eff1bf1059b05f0a85661673d624631e791995cd06c32ca2c347",
        "version": 1,
        "isUploaded": true,
        "isVerified": true,
        "sourceModule": "VAULT",
        "createdAt": "2026-11-01T15:30:00.000Z",
        "downloadUrl": "https://finmos-user.onrender.com/api/v1/vault/documents/cmvz1e7i30019thzqoeng7ssk/download",
        "previewUrl": "https://finmos-user.onrender.com/api/v1/vault/documents/cmvz1e7i30019thzqoeng7ssk/preview",
        "versions": [],
        "auditLogs": [
            {
                "id": "audit_1",
                "documentId": "cmvz1e7i30019thzqoeng7ssk",
                "userId": "cmuzhxi5a000asr4p9f6jcndp",
                "action": "UPLOAD",
                "createdAt": "2026-11-01T15:30:00.000Z"
            }
        ]
      }''';

      final Map<String, dynamic> data = jsonDecode(docJson);
      final doc = VaultDocument.fromJson(data);

      expect(doc.id, 'cmvz1e7i30019thzqoeng7ssk');
      expect(doc.name, 'Passport Front & Back');
      expect(doc.category, 'KYC & Identity');
      expect(doc.idType, 'Passport');
      expect(doc.docNumber, 'Z8765432');
      expect(doc.sizeFormatted, '1028.7 KB');
      expect(doc.sha256Hash, '2db2efed7527eff1bf1059b05f0a85661673d624631e791995cd06c32ca2c347');
      expect(doc.version, 1);
      expect(doc.sourceModule, 'VAULT');
      expect(doc.downloadUrl, contains('/download'));
      expect(doc.previewUrl, contains('/preview'));
      expect(doc.auditLogs.length, 1);
      expect(doc.auditLogs.first.action, 'UPLOAD');
    });

    test('VaultCrossModuleSummary parses cross-module response correctly', () {
      final crossJson = '''{
        "digitalLockerDocuments": 16,
        "expenseReceiptsCount": 8,
        "incomeVouchersCount": 9,
        "totalFinancialProofs": 33,
        "recentExpenseReceipts": [
            {
                "id": "exp_1",
                "description": "Starbucks Coffee",
                "amount": 450,
                "date": "2026-11-01",
                "receiptUrl": "/receipts/starbucks.png"
            }
        ],
        "recentIncomeVouchers": [
            {
                "id": "inc_1",
                "source": "Salary October",
                "amount": 125000,
                "date": "2026-10-31",
                "voucherNumber": "VOUCH-1002"
            }
        ]
      }''';

      final Map<String, dynamic> data = jsonDecode(crossJson);
      final cross = VaultCrossModuleSummary.fromJson(data);

      expect(cross.digitalLockerDocuments, 16);
      expect(cross.expenseReceiptsCount, 8);
      expect(cross.incomeVouchersCount, 9);
      expect(cross.totalFinancialProofs, 33);
      expect(cross.recentExpenseReceipts.length, 1);
      expect(cross.recentExpenseReceipts[0].description, 'Starbucks Coffee');
      expect(cross.recentIncomeVouchers.length, 1);
      expect(cross.recentIncomeVouchers[0].source, 'Salary October');
    });

    test('VaultSyncKycResult parses sync response correctly', () {
      final syncJson = '''{
        "success": true,
        "message": "10 KYC identity documents synced with encrypted locker",
        "data": {
            "syncedCount": 10,
            "documents": [
                {
                    "id": "doc_1",
                    "name": "PAN_Card.png",
                    "idType": "PAN",
                    "docNumber": "ABCDE1234F",
                    "isVerified": true,
                    "sha256Hash": "f3b2e..."
                }
            ]
        }
      }''';

      final Map<String, dynamic> data = jsonDecode(syncJson);
      final syncResult = VaultSyncKycResult.fromJson(data);

      expect(syncResult.success, true);
      expect(syncResult.syncedCount, 10);
      expect(syncResult.documents.length, 1);
      expect(syncResult.documents.first.idType, 'PAN');
    });

    test('VaultSharedDocumentInfo parses live share endpoint response correctly', () {
      final shareJson = '''{
        "shareUrl": "http://finmos-user.onrender.com/api/v1/vault/shared/fe80500a236f3fd04459223f2ab10cf312dc121aeed6aebf",
        "token": "fe80500a236f3fd04459223f2ab10cf312dc121aeed6aebf",
        "documentId": "cmvw23quq000n1431ewte7jaw",
        "documentName": "PASSPORT - passport_sample.pdf",
        "expiresAt": "2026-11-04T04:28:37.150Z",
        "maxAccess": 10,
        "accessCount": 0
      }''';

      final Map<String, dynamic> data = jsonDecode(shareJson);
      final sharedInfo = VaultSharedDocumentInfo.fromJson(data);

      expect(sharedInfo.shareUrl, contains('/vault/shared/'));
      expect(sharedInfo.token, 'fe80500a236f3fd04459223f2ab10cf312dc121aeed6aebf');
      expect(sharedInfo.documentId, 'cmvw23quq000n1431ewte7jaw');
      expect(sharedInfo.documentName, 'PASSPORT - passport_sample.pdf');
      expect(sharedInfo.expiresAt, '2026-11-04T04:28:37.150Z');
      expect(sharedInfo.maxAccess, 10);
      expect(sharedInfo.accessCount, 0);
    });

    test('ApiConstants contains download, preview, share, and shared endpoints', () {
      const docId = 'cmvw23quq000n1431ewte7jaw';
      const token = 'fe80500a236f3fd04459223f2ab10cf312dc121aeed6aebf';

      expect(ApiConstants.vaultDocumentDownload(docId), '/api/v1/vault/documents/$docId/download');
      expect(ApiConstants.vaultDocumentPreview(docId), '/api/v1/vault/documents/$docId/preview');
      expect(ApiConstants.vaultDocumentShare(docId), '/api/v1/vault/documents/$docId/share');
      expect(ApiConstants.vaultSharedDocument(token), '/api/v1/vault/shared/$token');
    });
  });

  group('DocumentVaultNotifier State Tests', () {
    test('Notifier initializes with dynamic documents state and storage limit', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(documentVaultProvider);
      expect(state.documents, isA<List<VaultDocument>>());
      expect(state.storageLimitGB, 10.0);
      expect(state.selectedCategoryFilter, 'All');
      expect(state.searchQuery, '');
    });

    test('Notifier handles upload, replace, and delete locally', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(documentVaultProvider.notifier);

      final testDoc = VaultDocument(
        id: 'test_doc_101',
        name: 'Investment_Certificate.pdf',
        category: 'Investment & Wealth',
        idType: 'Mutual Fund CAS',
        documentNumber: 'MF-778899',
        fileSize: '1.5 MB',
        uploadDate: 'Today',
        isUploaded: true,
        isVerified: true,
        sha256Hash: 'dummy_hash_101',
      );

      notifier.uploadDocument(testDoc);
      var state = container.read(documentVaultProvider);
      expect(state.documents.any((d) => d.id == 'test_doc_101'), true);

      notifier.replaceDocument('test_doc_101', 'Updated_Certificate.pdf', '2.0 MB');
      state = container.read(documentVaultProvider);
      final updated = state.documents.firstWhere((d) => d.id == 'test_doc_101');
      expect(updated.name, 'Updated_Certificate.pdf');
      expect(updated.fileSize, '2.0 MB');

      notifier.deleteUploadedFileOnly('test_doc_101');
      state = container.read(documentVaultProvider);
      final fileDeleted = state.documents.firstWhere((d) => d.id == 'test_doc_101');
      expect(fileDeleted.isUploaded, false);

      notifier.deleteDocument('test_doc_101');
      state = container.read(documentVaultProvider);
      expect(state.documents.any((d) => d.id == 'test_doc_101'), false);
    });

    test('Notifier handles category filters and search queries', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(documentVaultProvider.notifier);

      notifier.setCategoryFilter('Financial & Bank');
      var state = container.read(documentVaultProvider);
      expect(state.selectedCategoryFilter, 'Financial & Bank');

      notifier.setSearchQuery('PAN');
      state = container.read(documentVaultProvider);
      expect(state.searchQuery, 'PAN');
    });
  });
}
