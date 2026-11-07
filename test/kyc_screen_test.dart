import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/auth_kyc/domain/kyc_models.dart';
import 'package:finomos/features/auth_kyc/presentation/kyc_details_screen.dart';
import 'package:finomos/features/auth_kyc/providers/auth_kyc_provider.dart';

void main() {
  group('KycDetailsScreen (Step 3) Rendering & ID Normalization Tests', () {
    testWidgets('renders properly with backend idType PAN without blank screen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final user = container.read(authKycProvider).user;
      container.read(authKycProvider.notifier).updateUserData(
        user.copyWith(
          kycDocuments: [
            const KycDocumentRecord(
              id: 'doc1',
              idType: 'PAN',
              idNumber: 'ABCDE1234F',
              fileName: 'pan.pdf',
              uploadDate: 'Today',
              fileSize: '1.2 MB',
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

      expect(find.text('KYC Verification & ID Proof'), findsOneWidget);
      expect(find.text('ID Document #1'), findsOneWidget);
      expect(find.text('PAN Card'), findsWidgets);
    });

    testWidgets('renders properly with backend idType Masked Aadhaar Card without blank screen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final user = container.read(authKycProvider).user;
      container.read(authKycProvider.notifier).updateUserData(
        user.copyWith(
          kycDocuments: [
            const KycDocumentRecord(
              id: 'doc1',
              idType: 'Masked Aadhaar Card',
              idNumber: '9110',
              fileName: 'Masked_Aadhaar.pdf',
              uploadDate: 'Today',
              fileSize: '1.2 MB',
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

      expect(find.text('KYC Verification & ID Proof'), findsOneWidget);
      expect(find.text('ID Document #1'), findsOneWidget);
      expect(find.text('Aadhaar Card'), findsWidgets);
    });

    testWidgets('renders properly with multiple backend KYC documents', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final user = container.read(authKycProvider).user;
      container.read(authKycProvider.notifier).updateUserData(
        user.copyWith(
          kycDocuments: [
            const KycDocumentRecord(
              id: 'doc1',
              idType: 'PAN',
              idNumber: 'ABCDE1234F',
              fileName: 'PAN_Card.pdf',
              uploadDate: 'Today',
              fileSize: '1.2 MB',
              isUploaded: true,
            ),
            const KycDocumentRecord(
              id: 'doc2',
              idType: 'AADHAAR',
              idNumber: '9110',
              fileName: 'Masked_Aadhaar.pdf',
              uploadDate: 'Today',
              fileSize: '2.1 MB',
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

      expect(find.text('KYC Verification & ID Proof'), findsOneWidget);
      expect(find.text('ID Document #1'), findsOneWidget);
      expect(find.text('ID Document #2'), findsOneWidget);
    });

    testWidgets('renders properly when kycDocuments is empty', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final user = container.read(authKycProvider).user;
      container.read(authKycProvider.notifier).updateUserData(
        user.copyWith(kycDocuments: const []),
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

      expect(find.text('KYC Verification & ID Proof'), findsOneWidget);
      expect(find.text('ID Document #1'), findsOneWidget);
    });
  });
}
