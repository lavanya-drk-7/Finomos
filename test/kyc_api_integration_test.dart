import 'package:finomos/core/services/cache_service.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/core/constants/api_constants.dart';
import 'package:finomos/features/auth_kyc/domain/kyc_models.dart';
import 'package:finomos/features/auth_kyc/presentation/kyc_status_screen.dart';
import 'package:finomos/features/auth_kyc/services/kyc_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KYC Domain Models & Serialization Tests', () {
    test('KycStatusResponse parses exact backend JSON response', () {
      final jsonStr = '''{
        "userId": "cmuzhxi5a000asr4p9f6jcndp",
        "kycStatus": "VERIFIED",
        "isVerified": true,
        "redirectRoute": "/dashboard",
        "currentStep": 6,
        "totalSteps": 6,
        "timeline": [
          {
            "step": 1,
            "title": "Account Registration",
            "description": "Mobile OTP & Email credentials verified",
            "status": "COMPLETED",
            "completedAt": "2026-10-08T12:11:52.991Z"
          },
          {
            "step": 2,
            "title": "Personal & Residential Details",
            "description": "DOB, gender, address, and city submitted",
            "status": "COMPLETED",
            "completedAt": "2026-11-02T06:38:28.064Z"
          },
          {
            "step": 3,
            "title": "KYC Identity Proofs",
            "description": "PAN & Masked Aadhaar uploaded and hashed under Section 65B",
            "status": "COMPLETED",
            "documentsCount": 10,
            "completedAt": "2026-10-31T06:56:12.349Z"
          },
          {
            "step": 4,
            "title": "Statutory DPDP & AA Consents",
            "description": "Data processing, account aggregator & legal policy acceptance",
            "status": "COMPLETED",
            "completedAt": "2026-10-31T06:56:15.273Z"
          },
          {
            "step": 5,
            "title": "CFO Locker & Live Sync",
            "description": "Encrypted document vault activated for dashboard access",
            "status": "COMPLETED",
            "completedAt": "2026-10-31T06:56:15.273Z"
          }
        ],
        "summary": {
          "panNumber": "ABCDE1234F",
          "documentsSubmitted": 10,
          "consentsAccepted": 12
        }
      }''';

      final Map<String, dynamic> data = jsonDecode(jsonStr);
      final response = KycStatusResponse.fromJson(data);

      expect(response.userId, 'cmuzhxi5a000asr4p9f6jcndp');
      expect(response.kycStatus, 'VERIFIED');
      expect(response.isVerified, true);
      expect(response.redirectRoute, '/dashboard');
      expect(response.currentStep, 6);
      expect(response.totalSteps, 6);
      expect(response.timeline.length, 5);

      final step1 = response.timeline[0];
      expect(step1.step, 1);
      expect(step1.title, 'Account Registration');
      expect(step1.isCompleted, true);

      final step3 = response.timeline[2];
      expect(step3.step, 3);
      expect(step3.title, 'KYC Identity Proofs');
      expect(step3.documentsCount, 10);

      expect(response.summary.panNumber, 'ABCDE1234F');
      expect(response.summary.documentsSubmitted, 10);
      expect(response.summary.consentsAccepted, 12);
    });

    test('KycDocumentItem parses documents and helper getters', () {
      final docJson = {
        'id': 'cmvyv8o08000o67ejfalllh4b',
        'documentType': 'PAN',
        'idNumber': 'ABCDE1234F',
        'fileName': 'INV-INC-2026-INC1XX_1793435500127.pdf',
        'fileSize': 9096,
        'mimeType': 'application/pdf',
        'sha256Hash':
            'de05c6032bbe0bbb4c4861864e657e5e06d37e003cef8219dbfce187ecb0f2d6',
        'status': 'VERIFIED',
        'rejectionReason': null,
        'verifiedAt': '2026-11-02T06:16:24.967Z',
        'createdAt': '2026-11-02T06:16:24.968Z',
        'downloadUrl':
            '/uploads/1793600184086-595093754-INV-INC-2026-INC1XX_1793435500127.pdf'
      };

      final doc = KycDocumentItem.fromJson(docJson);

      expect(doc.id, 'cmvyv8o08000o67ejfalllh4b');
      expect(doc.documentType, 'PAN');
      expect(doc.displayType, 'PAN Card');
      expect(doc.isVerified, true);
      expect(doc.isPending, false);
      expect(doc.formattedFileSize, '8.9 KB');
      expect(doc.sha256Hash.startsWith('de05c603'), true);
      expect(doc.downloadUrl, isNotNull);
    });

    test('KycUploadResult and KycReVerifyResult deserialize accurately', () {
      final uploadJson = {
        'id': 'cmvyy6gcb0000rxf684t18vfa',
        'documentType': 'PAN',
        'idNumber': 'ABCDE1234F',
        'fileName': 'INV-INC-2026-INC1XX_1793435500127.pdf',
        'sha256Hash':
            'de05c6032bbe0bbb4c4861864e657e5e06d37e003cef8219dbfce187ecb0f2d6',
        'status': 'VERIFIED',
        'verifiedAt': '2026-11-02T06:55:40.526Z'
      };

      final uploadResult = KycUploadResult.fromJson(uploadJson);
      expect(uploadResult.id, 'cmvyy6gcb0000rxf684t18vfa');
      expect(uploadResult.documentType, 'PAN');
      expect(uploadResult.status, 'VERIFIED');
      expect(uploadResult.sha256Hash.isNotEmpty, true);

      final reVerifyJson = {
        'id': 'cmvw597bv00023df680fnns7k',
        'userId': 'cmuzhxi5a000asr4p9f6jcndp',
        'documentType': 'PAN',
        'idNumber': 'ABCDE1234F',
        'filePath': null,
        'fileName': 'PAN_Card.pdf',
        'fileSize': 1420500,
        'mimeType': 'application/pdf',
        'sha256Hash':
            'd56343d325cc132be5fe86f47ec9e1cc340067d86b84829a2dc54b3461f28b45',
        'status': 'VERIFIED',
        'rejectionReason': null,
        'verifiedAt': '2026-11-02T06:16:33.330Z',
        'createdAt': '2026-10-31T08:33:27.644Z',
        'updatedAt': '2026-11-02T06:16:33.331Z'
      };

      final reVerifyResult = KycReVerifyResult.fromJson(reVerifyJson);
      expect(reVerifyResult.id, 'cmvw597bv00023df680fnns7k');
      expect(reVerifyResult.documentType, 'PAN');
      expect(reVerifyResult.status, 'VERIFIED');
    });

    test('ApiConstants contains all 4 KYC backend routes', () {
      expect(ApiConstants.kycStatus, contains('/api/v1/kyc/status'));
      expect(ApiConstants.kycDocuments, contains('/api/v1/kyc/documents'));
      expect(ApiConstants.kycUpload, contains('/api/v1/kyc/upload'));
      expect(ApiConstants.kycReVerify, contains('/api/v1/kyc/re-verify'));
    });
  });

  group('KycApiService Fast-Cache Tests', () {
    test('KycApiService retrieves pre-seeded cached status and documents', () {
      LocalCacheService().save('kyc_documents', [
        {
          'id': 'doc_1',
          'documentType': 'PAN',
          'documentNumber': 'ABCDE1234F',
          'fileName': 'PAN_Card.pdf',
          'fileSize': '1.8 MB',
          'isVerified': true,
        },
        {
          'id': 'doc_2',
          'documentType': 'AADHAAR',
          'documentNumber': '•••• •••• 9110',
          'fileName': 'Masked_Aadhaar.pdf',
          'fileSize': '2.1 MB',
          'isVerified': true,
        },
      ]);
      final service = KycApiService();
      final cachedStatus = service.getCachedStatus();
      expect(cachedStatus, isNotNull);
      expect(cachedStatus!.kycStatus, 'VERIFIED');
      expect(cachedStatus.timeline.length, 5);

      final cachedDocs = service.getCachedDocuments();
      expect(cachedDocs, isNotNull);
      expect(cachedDocs!.length, greaterThanOrEqualTo(2));
      expect(cachedDocs.first.documentType, 'PAN');
    });
  });

  group('KycStatusScreen Widget Tests', () {
    testWidgets('KycStatusScreen renders live KYC status, timeline, and summary cards',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      LocalCacheService().save('kyc_summary', {
        'panNumber': 'ABCDE1234F',
        'aadhaarNumber': '•••• •••• 9110',
        'kycStatus': 'VERIFIED',
        'verifiedAt': '2026-10-15',
        'verificationMethod': 'DIGILOCKER_OFFLINE',
        'documentCounts': {'total': 2, 'verified': 2, 'pending': 0},
        'consentStatus': {'active': 3, 'expired': 0, 'pending': 0},
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: KycStatusScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top title and Status banner
      expect(find.text('KYC Status'), findsOneWidget);
      expect(find.text('KYC Verified'), findsOneWidget);

      // Summary metrics from GET /api/v1/kyc/status
      expect(find.text('ABCDE1234F'), findsWidgets);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Consents'), findsOneWidget);

      // Verification Progress Timeline header
      expect(find.text('Verification Progress Timeline'), findsOneWidget);

      // Timeline Steps rendered
      expect(find.textContaining('Step 1: Account Registration'), findsOneWidget);
      expect(find.textContaining('Step 2: Personal & Residential Details'),
          findsOneWidget);
      expect(find.textContaining('Step 3: KYC Identity Proofs'), findsOneWidget);
      expect(find.textContaining('Step 4: Statutory DPDP & AA Consents'),
          findsOneWidget);
      expect(find.textContaining('Step 5: CFO Locker & Live Sync'),
          findsOneWidget);

      // Submitted Proofs section
      expect(find.textContaining('Submitted Proofs'), findsOneWidget);
      expect(find.text('Section 65B Certified'), findsOneWidget);

      // Re-verify button
      expect(find.text('Re-Verify PAN Under Section 65B'), findsOneWidget);

      // Interactive switcher and navigation buttons
      expect(find.text('Interactive Status Switcher (Demo):'), findsOneWidget);
      expect(find.text('Home Dashboard'), findsOneWidget);
    });
  });
}
