import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../../core/widgets/finmos_user_avatar.dart';
import '../../../core/widgets/finmos_kyc_badge.dart';
import '../domain/kyc_models.dart';
import '../providers/auth_kyc_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycState = ref.watch(authKycProvider);
    final user = kycState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation: 0,
        title: const FinmosLogo(size: 26, showTagline: false, isHorizontal: true),
      ),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 4),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Card with Centered Profile Photo, Camera Icon Badge & Name/Email below
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile Avatar with Camera Icon Overlay at Bottom Right
                      const Center(
                        child: FinmosUserAvatar(
                          radius: 44,
                          showCameraBadge: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User Name under Profile Photo
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : 'Sireesha',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2540),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // User Email ID under Name
                      Text(
                        user.email.isNotEmpty ? user.email : 'sireesha@gmail.com',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // KYC Update Status Badge (Synchronized across all screens)
                      const FinmosKycBadge(prefixText: 'KYC Status: '),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                _buildMenuSectionHeader('PROFILE MODULES'),
                _buildMenuOption(
                  icon: Icons.badge_outlined,
                  title: 'Personal Information & Identity',
                  subtitle: 'Full name, DOB, PAN, Aadhaar & Photo',
                  onTap: () => context.push('/profile/personal'),
                ),
                _buildMenuOption(
                  icon: Icons.home_outlined,
                  title: 'Address & Residence',
                  subtitle: 'Current residential and permanent address',
                  onTap: () => context.push('/profile/address'),
                ),
                _buildMenuOption(
                  icon: Icons.work_outline,
                  title: 'Employment & Income Details',
                  subtitle: 'Job details, designation, annual income',
                  onTap: () => context.push('/profile/employment'),
                ),
                _buildMenuOption(
                  icon: Icons.family_restroom_outlined,
                  title: 'Family & Household Management',
                  subtitle: 'Spouse, dependents, joint family finances',
                  onTap: () => context.push('/profile/family'),
                ),
                _buildMenuOption(
                  icon: Icons.security_outlined,
                  title: 'Security & Login Settings',
                  subtitle: 'Password, 2FA, Biometrics & Active Sessions',
                  onTap: () => context.push('/profile/security'),
                ),
                _buildMenuOption(
                  icon: Icons.notifications_none_outlined,
                  title: 'Communication & Alert Preferences',
                  subtitle: 'SMS, Email, Push Notifications & Frequency',
                  onTap: () => context.push('/profile/preferences'),
                ),

                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildMenuSectionHeader('ACCOUNT & SYSTEM'),

                _buildMenuOption(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Full Profile Dashboard',
                  subtitle: 'Consolidated profile management view',
                  onTap: () => context.push('/profile-management'),
                ),
                _buildMenuOption(
                  icon: Icons.verified_user_outlined,
                  title: 'KYC Status & Verification',
                  badgeText: kycState.kycStatus == KycStatus.pending
                      ? 'Pending'
                      : kycState.kycStatus == KycStatus.verified
                          ? 'Verified'
                          : 'Rejected',
                  badgeColor: kycState.kycStatus == KycStatus.pending
                      ? const Color(0xFFF59E0B)
                      : kycState.kycStatus == KycStatus.verified
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                  onTap: () {
                    ref.read(authKycProvider.notifier).updateStep(11);
                    context.push('/kyc-status');
                  },
                ),
                _buildMenuOption(
                  icon: Icons.folder_open_outlined,
                  title: 'Document Vault',
                  subtitle: 'Tax, Identity & Financial Documents',
                  onTap: () => context.push('/document-vault'),
                ),
                _buildMenuOption(
                  icon: Icons.account_balance_outlined,
                  title: 'Bank Accounts & Aggregation',
                  subtitle: 'Linked bank accounts & mandates',
                  onTap: () => context.push('/bank-aggregation'),
                ),
                _buildMenuOption(
                  icon: Icons.settings_outlined,
                  title: 'App Settings',
                  onTap: () => context.push('/settings'),
                ),
                _buildMenuOption(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => context.push('/help-support'),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      ref.read(authKycProvider.notifier).reset();
                      ref.read(authKycProvider.notifier).updateStep(2);
                      context.go('/login');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0066FF), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A2540),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? const Color(0xFF0066FF)).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor ?? const Color(0xFF0066FF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
