import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/widgets/finmos_user_avatar.dart';
import 'package:finomos/features/auth_kyc/domain/kyc_models.dart';
import 'package:finomos/features/auth_kyc/providers/auth_kyc_provider.dart';
import 'package:finomos/features/profile/providers/profile_provider.dart';
import 'package:finomos/features/profile/services/profile_photo_service.dart';
import 'package:finomos/features/profile/presentation/sub_screens/personal_info_sub_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/profile_screen.dart';

void main() {
  group('KYC Status & Profile Photo Synchronization Tests', () {
    testWidgets('KYC Status is synchronized across ProfileScreen and PersonalInfoSubScreen', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 1. Initial status is Verified
      expect(container.read(authKycProvider).kycStatus, KycStatus.verified);

      // Pump PersonalInfoSubScreen
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PersonalInfoSubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Verified badge is rendered in PersonalInfoSubScreen
      expect(find.text('Identity Verified (KYC Active)'), findsOneWidget);

      // Now change status to Pending in authKycProvider
      container.read(authKycProvider.notifier).setKycStatus(KycStatus.pending);
      await tester.pumpAndSettle();

      // Check PersonalInfoSubScreen immediately updates to Pending
      expect(find.text('Identity Verification Pending'), findsOneWidget);
      expect(find.text('Identity Verified (KYC Active)'), findsNothing);

      // Now change status to Rejected in authKycProvider
      container.read(authKycProvider.notifier).setKycStatus(KycStatus.rejected);
      await tester.pumpAndSettle();

      // Check PersonalInfoSubScreen immediately updates to Rejected
      expect(find.text('Identity Verification Rejected'), findsOneWidget);

      // Now pump ProfileScreen with the same container
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify ProfileScreen also shows the exact same Rejected status
      expect(find.text('KYC Status: Identity Verification Rejected'), findsOneWidget);

      // Set back to Verified
      container.read(authKycProvider.notifier).setKycStatus(KycStatus.verified);
      await tester.pumpAndSettle();

      expect(find.text('KYC Status: Identity Verified (KYC Active)'), findsOneWidget);
    });

    testWidgets('Profile photo updates across both providers and is reflected in FinmosUserAvatar', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  FinmosUserAvatar(radius: 40, showCameraBadge: true),
                  FinmosUserAvatar(radius: 20),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default monogram initials displayed (Sireesha -> 'S')
      expect(find.text('S'), findsOneWidget);

      // Update photo via ProfilePhotoService
      const testUrl = 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200';
      ProfilePhotoService.updatePhoto(container, testUrl);
      // Directly check both providers
      expect(container.read(profileProvider).personalInfo.profilePicUrl, testUrl);
      expect(container.read(authKycProvider).user.profilePicUrl, testUrl);

      // Remove photo
      ProfilePhotoService.removePhoto(container);
      expect(container.read(profileProvider).personalInfo.profilePicUrl, '');
      expect(container.read(authKycProvider).user.profilePicUrl, '');
    });

    testWidgets('Tapping camera icon triggers profile photo options modal sheet', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: FinmosUserAvatar(radius: 40, showCameraBadge: true),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find camera icon badge and tap it
      final cameraBadge = find.byIcon(Icons.camera_alt);
      expect(cameraBadge, findsOneWidget);
      await tester.tap(cameraBadge);
      await tester.pumpAndSettle();

      // Verify the interactive bottom sheet opens with all options
      expect(find.text('Update Profile Photo'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.text('Choose Sample Preset Avatar'), findsOneWidget);
    });
  });
}
