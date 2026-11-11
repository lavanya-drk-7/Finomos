import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_kyc_provider.dart';
import '../domain/auth_onboarding_models.dart';
import 'flow_header.dart';

class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {
  bool _agreePrivacy = false;

  @override
  void initState() {
    super.initState();
    _agreePrivacy = ref.read(authKycProvider).user.agreePrivacy;
  }

  void _onPrevious() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ref.read(authKycProvider.notifier).updateStep(4);
    context.go('/consent');
  }

  void _onContinue() {
    if (!_agreePrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Privacy Policy to proceed.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    final user = ref.read(authKycProvider).user;
    ref.read(authKycProvider.notifier).updateUserData(user.copyWith(agreePrivacy: true));

    // Commit statutory consent and final privacy acceptance (POST /api/auth/onboarding/consent)
    ref.read(authKycProvider.notifier).recordOnboardingConsent(
          const OnboardingConsentRequest(
            consentTypes: [
              'ACCOUNT_AGGREGATOR',
              'DPDP_ACT_2023',
              'PRIVACY_POLICY',
            ],
            isAgreed: true,
            version: 'v2.1',
          ),
        );

    ref.read(authKycProvider.notifier).updateStep(8);
    context.go('/kyc-status');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const FlowHeader(activeStep: 5),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Container(
                  width: double.infinity,
                    padding: const EdgeInsets.all(24),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2540),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          '1. Information We Collect',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'We collect personal information you provide directly, including your name, email address, phone number, financial transaction records you enter or link, and KYC verification documents.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          '2. How We Use Your Information',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your data is used solely to deliver Personal CFO financial insights, expense & income tracking, budget management, account security, and statutory KYC verification.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          '3. Data Security & Encryption',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'We implement bank-grade security measures including TLS 1.3 encryption in transit and AES-256 encryption at rest to protect your sensitive financial records.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          '4. No Third-Party Data Selling',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Finomos does NOT sell, rent, or trade your personal or financial data to third-party advertisers or data brokers under any circumstances.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          '5. Data Retention & Account Deletion',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'You have full control over your data. You may permanently delete your account and all associated personal and financial data directly in the app via Settings > Security & Privacy > Delete Account, or by writing to support@finomos.com. Upon request, all data is permanently purged.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          '6. Compliance & Grievance Contact',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'We comply with applicable data protection laws including the Digital Personal Data Protection (DPDP) Act. For any privacy queries or grievance redressal, contact our Data Protection Officer at support@finomos.com.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                        ),
                        const SizedBox(height: 24),

                        InkWell(
                          onTap: () => setState(() => _agreePrivacy = !_agreePrivacy),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _agreePrivacy,
                                    activeColor: const Color(0xFF0066FF),
                                    onChanged: (val) => setState(() => _agreePrivacy = val ?? false),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'I agree to the Privacy Policy',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: _onPrevious,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF475569),
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_back, size: 18),
                                        SizedBox(width: 4),
                                        Text('Previous', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _onContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0066FF),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Submit KYC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 4),
                                        Icon(Icons.check_circle, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
}
