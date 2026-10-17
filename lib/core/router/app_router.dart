import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth_kyc/presentation/sign_up_screen.dart';
import '../../features/auth_kyc/presentation/login_screen.dart';
import '../../features/auth_kyc/presentation/mobile_verification_screen.dart';
import '../../features/auth_kyc/presentation/otp_verification_screen.dart';
import '../../features/auth_kyc/presentation/user_details_screen.dart';
import '../../features/auth_kyc/presentation/kyc_details_screen.dart';
import '../../features/auth_kyc/presentation/consent_screen.dart';
import '../../features/auth_kyc/presentation/terms_screen.dart';
import '../../features/auth_kyc/presentation/privacy_policy_screen.dart';
import '../../features/auth_kyc/presentation/forgot_password_screen.dart';
import '../../features/auth_kyc/presentation/profile_screen.dart';
import '../../features/auth_kyc/presentation/kyc_status_screen.dart';
import '../../features/profile/presentation/profile_management_screen.dart';
import '../../features/profile/presentation/sub_screens/personal_info_sub_screen.dart';
import '../../features/profile/presentation/sub_screens/address_details_sub_screen.dart';
import '../../features/profile/presentation/sub_screens/employment_income_sub_screen.dart';
import '../../features/profile/presentation/sub_screens/family_household_sub_screen.dart';
import '../../features/profile/presentation/sub_screens/security_settings_sub_screen.dart';
import '../../features/profile/presentation/sub_screens/communication_prefs_sub_screen.dart';
import '../../features/bank_aggregation/presentation/bank_aggregation_screen.dart';
import '../../features/income_tracking/presentation/income_tracking_screen.dart';
import '../../features/expense_tracking/presentation/expense_tracking_screen.dart';
import '../../features/budget_management/presentation/budget_management_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/document_vault/presentation/document_vault_screen.dart';
import '../../features/admin_panel/presentation/admin_panel_screen.dart';
import '../../features/cfo_ai/presentation/cfo_ai_screen.dart';
import '../../features/protect/presentation/protect_screen.dart';
import '../../features/borrow/presentation/borrow_screen.dart';
import '../../features/grow/presentation/grow_screen.dart';
import '../../features/plan/presentation/plan_screen.dart';
import '../../features/comply/presentation/comply_screen.dart';
import '../../features/advisor_ecosystem/presentation/advisor_ecosystem_screen.dart';
import '../../features/advisor_ecosystem/presentation/book_consultation_screen.dart';
import '../../features/advisor_ecosystem/domain/advisor_models.dart';
import '../../features/fpms_admin/presentation/fpms_admin_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/help_support/presentation/help_support_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Navigation Error'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/profile'),
      ),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Text('Page not found: ${state.uri}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/profile'),
            child: const Text('Back to Profile'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (BuildContext context, GoRouterState state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/verify-mobile',
      builder: (BuildContext context, GoRouterState state) => const MobileVerificationScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (BuildContext context, GoRouterState state) => const OtpVerificationScreen(),
    ),
    GoRoute(
      path: '/user-details',
      builder: (BuildContext context, GoRouterState state) => const UserDetailsScreen(),
    ),
    GoRoute(
      path: '/kyc-details',
      builder: (BuildContext context, GoRouterState state) => const KycDetailsScreen(),
    ),
    GoRoute(
      path: '/consent',
      builder: (BuildContext context, GoRouterState state) => const ConsentScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (BuildContext context, GoRouterState state) => const TermsScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (BuildContext context, GoRouterState state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (BuildContext context, GoRouterState state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/kyc-status',
      builder: (BuildContext context, GoRouterState state) => const KycStatusScreen(),
    ),
    GoRoute(
      path: '/profile-management',
      builder: (BuildContext context, GoRouterState state) => const ProfileManagementScreen(),
    ),
    GoRoute(
      path: '/profile/personal',
      builder: (BuildContext context, GoRouterState state) => const PersonalInfoSubScreen(),
    ),
    GoRoute(
      path: '/profile/address',
      builder: (BuildContext context, GoRouterState state) => const AddressDetailsSubScreen(),
    ),
    GoRoute(
      path: '/profile/employment',
      builder: (BuildContext context, GoRouterState state) => const EmploymentIncomeSubScreen(),
    ),
    GoRoute(
      path: '/profile/family',
      builder: (BuildContext context, GoRouterState state) => const FamilyHouseholdSubScreen(),
    ),
    GoRoute(
      path: '/profile/security',
      builder: (BuildContext context, GoRouterState state) => const SecuritySettingsSubScreen(),
    ),
    GoRoute(
      path: '/profile/preferences',
      builder: (BuildContext context, GoRouterState state) => const CommunicationPrefsSubScreen(),
    ),
    GoRoute(
      path: '/bank-aggregation',
      builder: (BuildContext context, GoRouterState state) => const BankAggregationScreen(),
    ),
    GoRoute(
      path: '/income-tracking',
      builder: (BuildContext context, GoRouterState state) => const IncomeTrackingScreen(),
    ),
    GoRoute(
      path: '/expense-tracking',
      builder: (BuildContext context, GoRouterState state) => const ExpenseTrackingScreen(),
    ),
    GoRoute(
      path: '/budget-management',
      builder: (BuildContext context, GoRouterState state) => const BudgetManagementScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (BuildContext context, GoRouterState state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/document-vault',
      builder: (BuildContext context, GoRouterState state) => const DocumentVaultScreen(),
    ),
    GoRoute(
      path: '/admin-panel',
      builder: (BuildContext context, GoRouterState state) => const AdminPanelScreen(),
    ),
    GoRoute(
      path: '/cfo-ai',
      builder: (BuildContext context, GoRouterState state) => const CfoAiScreen(),
    ),
    GoRoute(
      path: '/protect',
      builder: (BuildContext context, GoRouterState state) => const ProtectScreen(),
    ),
    GoRoute(
      path: '/borrow',
      builder: (BuildContext context, GoRouterState state) => const BorrowScreen(),
    ),
    GoRoute(
      path: '/grow',
      builder: (BuildContext context, GoRouterState state) => const GrowScreen(),
    ),
    GoRoute(
      path: '/plan',
      builder: (BuildContext context, GoRouterState state) => const PlanScreen(),
    ),
    GoRoute(
      path: '/comply',
      builder: (BuildContext context, GoRouterState state) => const ComplyScreen(),
    ),
    GoRoute(
      path: '/advisor-ecosystem',
      builder: (BuildContext context, GoRouterState state) => const AdvisorEcosystemScreen(),
    ),
    GoRoute(
      path: '/book-consultation',
      builder: (BuildContext context, GoRouterState state) => BookConsultationScreen(
        advisor: state.extra as Advisor?,
      ),
    ),
    GoRoute(
      path: '/fpms-admin',
      builder: (BuildContext context, GoRouterState state) => const FpmsAdminScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (BuildContext context, GoRouterState state) => const HelpSupportScreen(),
    ),
  ],
);
