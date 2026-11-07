import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finomos/features/splash/presentation/splash_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/sign_up_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/login_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/mobile_verification_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/otp_verification_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/user_details_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/kyc_details_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/consent_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/terms_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/privacy_policy_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/forgot_password_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/profile_screen.dart';
import 'package:finomos/features/auth_kyc/presentation/kyc_status_screen.dart';
import 'package:finomos/features/profile/presentation/profile_management_screen.dart';
import 'package:finomos/features/profile/presentation/sub_screens/personal_info_sub_screen.dart';
import 'package:finomos/features/profile/presentation/sub_screens/address_details_sub_screen.dart';
import 'package:finomos/features/profile/presentation/sub_screens/employment_income_sub_screen.dart';
import 'package:finomos/features/profile/presentation/sub_screens/family_household_sub_screen.dart';
import 'package:finomos/features/profile/presentation/sub_screens/security_settings_sub_screen.dart';
import 'package:finomos/features/profile/presentation/sub_screens/communication_prefs_sub_screen.dart';
import 'package:finomos/features/bank_aggregation/presentation/bank_aggregation_screen.dart';
import 'package:finomos/features/income_tracking/presentation/income_tracking_screen.dart';
import 'package:finomos/features/expense_tracking/presentation/expense_tracking_screen.dart';
import 'package:finomos/features/budget_management/presentation/budget_management_screen.dart';
import 'package:finomos/features/dashboard/presentation/dashboard_screen.dart';
import 'package:finomos/features/notifications/presentation/notifications_screen.dart';
import 'package:finomos/features/document_vault/presentation/document_vault_screen.dart';
import 'package:finomos/features/admin_panel/presentation/admin_panel_screen.dart';
import 'package:finomos/features/cfo_ai/presentation/cfo_ai_screen.dart';
import 'package:finomos/features/protect/presentation/protect_screen.dart';
import 'package:finomos/features/borrow/presentation/borrow_screen.dart';
import 'package:finomos/features/grow/presentation/grow_screen.dart';
import 'package:finomos/features/plan/presentation/plan_screen.dart';
import 'package:finomos/features/comply/presentation/comply_screen.dart';
import 'package:finomos/features/advisor_ecosystem/presentation/advisor_ecosystem_screen.dart';
import 'package:finomos/features/fpms_admin/presentation/fpms_admin_screen.dart';
import 'package:finomos/features/settings/presentation/settings_screen.dart';
import 'package:finomos/features/help_support/presentation/help_support_screen.dart';

Widget wrapWithGlobalSafeArea(Widget screen) {
  return ProviderScope(
    child: MaterialApp(
      builder: (context, child) {
        return Container(
          color: Colors.white,
          child: SafeArea(
            top: true,
            bottom: true,
            left: true,
            right: true,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: screen,
    ),
  );
}

void main() {
  final Map<String, Widget Function()> screens = {
    'SignUpScreen': () => const SignUpScreen(),
    'LoginScreen': () => const LoginScreen(),
    'MobileVerificationScreen': () => const MobileVerificationScreen(),
    'OtpVerificationScreen': () => const OtpVerificationScreen(),
    'UserDetailsScreen': () => const UserDetailsScreen(),
    'KycDetailsScreen': () => const KycDetailsScreen(),
    'ConsentScreen': () => const ConsentScreen(),
    'TermsScreen': () => const TermsScreen(),
    'PrivacyPolicyScreen': () => const PrivacyPolicyScreen(),
    'ForgotPasswordScreen': () => const ForgotPasswordScreen(),
    'ProfileScreen': () => const ProfileScreen(),
    'KycStatusScreen': () => const KycStatusScreen(),
    'ProfileManagementScreen': () => const ProfileManagementScreen(),
    'PersonalInfoSubScreen': () => const PersonalInfoSubScreen(),
    'AddressDetailsSubScreen': () => const AddressDetailsSubScreen(),
    'EmploymentIncomeSubScreen': () => const EmploymentIncomeSubScreen(),
    'FamilyHouseholdSubScreen': () => const FamilyHouseholdSubScreen(),
    'SecuritySettingsSubScreen': () => const SecuritySettingsSubScreen(),
    'CommunicationPrefsSubScreen': () => const CommunicationPrefsSubScreen(),
    'BankAggregationScreen': () => const BankAggregationScreen(),
    'IncomeTrackingScreen': () => const IncomeTrackingScreen(),
    'ExpenseTrackingScreen': () => const ExpenseTrackingScreen(),
    'BudgetManagementScreen': () => const BudgetManagementScreen(),
    'DashboardScreen': () => const DashboardScreen(),
    'NotificationsScreen': () => const NotificationsScreen(),
    'DocumentVaultScreen': () => const DocumentVaultScreen(),
    'AdminPanelScreen': () => const AdminPanelScreen(),
    'CfoAiScreen': () => const CfoAiScreen(),
    'ProtectScreen': () => const ProtectScreen(),
    'BorrowScreen': () => const BorrowScreen(),
    'GrowScreen': () => const GrowScreen(),
    'PlanScreen': () => const PlanScreen(),
    'ComplyScreen': () => const ComplyScreen(),
    'AdvisorEcosystemScreen': () => const AdvisorEcosystemScreen(),
    'FpmsAdminScreen': () => const FpmsAdminScreen(),
    'SettingsScreen': () => const SettingsScreen(),
    'HelpSupportScreen': () => const HelpSupportScreen(),
  };

  testWidgets('Verify 0 overflow: SplashScreen at 360x640 with safe area', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(top: 48, bottom: 34, left: 0, right: 0);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(wrapWithGlobalSafeArea(const SplashScreen()));
    await tester.pump(const Duration(milliseconds: 500));
  });

  for (final entry in screens.entries) {
    testWidgets('Verify 0 overflow: ${entry.key} at 360x640 with safe area', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 48, bottom: 34, left: 0, right: 0);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetPadding();
      });

      await tester.pumpWidget(wrapWithGlobalSafeArea(entry.value()));
      await tester.pumpAndSettle();
    });
  }
}
