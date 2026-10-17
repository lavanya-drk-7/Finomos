import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/document_vault/presentation/document_vault_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/kyc_details_screen.dart';

void main() {
  testWidgets('DocumentVaultScreen renders properly and displays uploaded KYC docs with distinct delete actions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
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

    // Close sheet
    Navigator.of(tester.element(find.text('Add ID / Financial Document'))).pop();
    await tester.pumpAndSettle();

    // Verify back on Document Vault
    expect(find.text('Document Vault'), findsOneWidget);

    // Test bottom delete button on ID Document #1 (removes only uploaded file)
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Uploaded Document?'), findsOneWidget);
    await tester.tap(find.text('Remove File'));
    await tester.pumpAndSettle();

    // The field ID Document #1 still exists, but the document is removed and shows Upload Document dropzone
    expect(find.text('ID Document #1', skipOffstage: false), findsOneWidget);
    expect(find.text('Upload PAN Card Document', skipOffstage: false), findsOneWidget);

    // Test top delete button (removes entire field)
    await tester.tap(find.byTooltip('Delete Entire Field').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Entire ID Document #1?'), findsOneWidget);
    await tester.tap(find.text('Delete Field'));
    await tester.pumpAndSettle();

    // ID Document #1 has been deleted from vault
    expect(find.text('ID Document #1', skipOffstage: false), findsOneWidget); // ID #2 is now #1
  });

  testWidgets('KycDetailsScreen renders upload box, Replace opens dedicated picker page, View, and distinct Delete options', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
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

    // Select Documents option -> opens dedicated Documents Explorer page
    await tester.tap(find.text('Documents'));
    await tester.pumpAndSettle();

    expect(find.text('Documents Explorer'), findsOneWidget);
    expect(find.text('Select'), findsAtLeastNWidgets(1));

    // Select the first document in the explorer
    await tester.tap(find.text('Select').first);
    await tester.pumpAndSettle();

    // Verify document was replaced and is displayed
    expect(find.text('PAN_Card_Sireesha.pdf'), findsAtLeastNWidgets(1));

    // Test bottom Delete button (beside View Document) deletes ONLY the uploaded document
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Uploaded Document?'), findsOneWidget);
    await tester.tap(find.text('Remove File'));
    await tester.pumpAndSettle();

    // Uploaded document is removed, but ID Document #1 field and PAN Number remain!
    expect(find.text('ID Document #1'), findsOneWidget);
    expect(find.text('ABCDE1234F'), findsOneWidget);
    expect(find.text('Upload Document'), findsAtLeastNWidgets(1));

    // Test top Delete button (in header) deletes entire ID Document #1 field
    await tester.tap(find.byTooltip('Delete Entire Field').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Entire ID Document #1?'), findsOneWidget);
    await tester.tap(find.text('Delete Field'));
    await tester.pumpAndSettle();

    // Entire field was reset/cleared
    expect(find.text('ABCDE1234F'), findsNothing);
  });
}
