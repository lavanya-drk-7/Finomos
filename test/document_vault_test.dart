import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/auth_kyc/domain/kyc_models.dart';
import 'package:finomos/features/auth_kyc/providers/auth_kyc_provider.dart';
import 'package:finomos/features/document_vault/presentation/document_vault_screen.dart';
import 'package:finomos/features/document_vault/providers/document_provider.dart';
import 'package:finomos/features/auth_kyc/presentation/kyc_details_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DocumentVaultScreen renders properly and displays uploaded KYC docs with distinct delete actions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(documentVaultProvider.notifier).syncKycDocuments([
      const KycDocumentRecord(
        id: 'doc_1',
        idType: 'PAN Card',
        idNumber: 'ABCDE1234F',
        fileName: 'PAN_Card_Sireesha.pdf',
        fileSize: '1.8 MB',
        isUploaded: true,
      ),
      const KycDocumentRecord(
        id: 'doc_2',
        idType: 'Aadhaar Card',
        idNumber: '•••• •••• 9110',
        fileName: 'Aadhaar_Card_Sireesha.pdf',
        fileSize: '2.1 MB',
        isUploaded: true,
      ),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: DocumentVaultScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title Header and Encryption status
    expect(find.text('Document Vault'), findsOneWidget);
    expect(find.text('AES-256 Safe'), findsOneWidget);

    // Verify KYC uploaded documents are present
    expect(find.text('PAN_Card_Sireesha.pdf', skipOffstage: false), findsAtLeastNWidgets(1));
    expect(find.text('Aadhaar_Card_Sireesha.pdf', skipOffstage: false), findsAtLeastNWidgets(1));

    // Verify ID Document numbering and Uploaded badges
    expect(find.text('ID Document #1', skipOffstage: false), findsOneWidget);
    expect(find.text('Uploaded', skipOffstage: false), findsAtLeastNWidgets(1));

    // Verify Action Buttons on cards: Replace Document, View Document, Delete
    expect(find.text('Replace Document', skipOffstage: false), findsAtLeastNWidgets(1));
    expect(find.text('View Document', skipOffstage: false), findsAtLeastNWidgets(1));
    expect(find.text('Delete', skipOffstage: false), findsAtLeastNWidgets(1));

    // Verify "+ Add Another ID Document" button exists
    expect(find.text('+ Add Another ID Document', skipOffstage: false), findsOneWidget);

    // Test tapping AppBar add/upload icon opens Add Document Sheet
    await tester.tap(find.byIcon(Icons.cloud_upload_outlined));
    await tester.pumpAndSettle();

    // Verify Add Sheet opened with ID type and Upload button
    expect(find.text('Add ID / Financial Document'), findsOneWidget);
    expect(find.text('Upload & Save to Vault'), findsOneWidget);

    // Close the sheet
    Navigator.of(tester.element(find.text('Add ID / Financial Document'))).pop();
    await tester.pumpAndSettle();

    // Test tapping Delete opens Confirmation Dialog with document name
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    // Verify Dialog opened with clear warning & Delete button
    expect(find.text('Delete Uploaded Document?'), findsOneWidget);
    expect(find.textContaining('Are you sure you want to delete only the uploaded file'), findsOneWidget);
    expect(find.text('Remove File'), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.text('Remove File'));
    await tester.pumpAndSettle();

    // Document #1 deleted, only 1 document remaining
    expect(find.text('PAN_Card_Sireesha.pdf'), findsNothing);
    expect(find.text('Aadhaar_Card_Sireesha.pdf'), findsAtLeastNWidgets(1));
  });

  testWidgets('KycDetailsScreen renders upload box, Replace opens dedicated picker page, View, and distinct Delete options',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(authKycProvider.notifier).updateUserData(
      const UserRegistrationData(
        panNumber: 'ABCDE1234F',
        idProofFileName: 'PAN_Card_Sireesha.pdf',
        kycDocuments: [
          KycDocumentRecord(
            id: 'doc_1',
            idType: 'PAN Card',
            idNumber: 'ABCDE1234F',
            fileName: 'PAN_Card_Sireesha.pdf',
            fileSize: '1.8 MB',
            isUploaded: true,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: KycDetailsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify KYC screen elements
    expect(find.text('KYC Verification & ID Proof'), findsOneWidget);
    expect(find.text('ID Document #1'), findsOneWidget);
    expect(find.text('PAN_Card_Sireesha.pdf'), findsOneWidget);

    // Verify Replace Document, View Document, and Delete buttons exist
    expect(find.text('Replace Document'), findsAtLeastNWidgets(1));
    expect(find.text('View Document'), findsAtLeastNWidgets(1));
    expect(find.text('Delete'), findsAtLeastNWidgets(1));

    // Test tapping View Document opens Document Preview Dialog
    await tester.tap(find.text('View Document').first);
    await tester.pumpAndSettle();

    expect(find.text('Document Metadata & Security'), findsOneWidget);
    expect(find.text('PAN CARD'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Test tapping Replace Document opens Source Picker bottom sheet (Gallery, Documents, File Manager, Camera Scan)
    await tester.tap(find.text('Replace Document').first);
    await tester.pumpAndSettle();

    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('File Manager'), findsOneWidget);
    expect(find.text('Camera Scan'), findsOneWidget);

    // Close replace sheet
    Navigator.of(tester.element(find.text('Gallery'))).pop();
    await tester.pumpAndSettle();

    // Test tapping Delete button on card opens confirmation dialog
    await tester.ensureVisible(find.text('Delete').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Uploaded Document?'), findsOneWidget);
    expect(find.textContaining('Are you sure you want to delete only the uploaded file'), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.text('Remove File'));
    await tester.pumpAndSettle();

    // Verify document deleted, state cleared to default empty upload state
    expect(find.text('Upload PAN Card Document *'), findsOneWidget);
    expect(find.text('Upload Document'), findsAtLeastNWidgets(1));
  });
}
