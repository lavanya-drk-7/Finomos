import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_kyc_provider.dart';
import 'flow_header.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _c1 = false;
  bool _c2 = false;
  bool _c3 = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authKycProvider).user;
    _c1 = user.consentProcessing;
    _c2 = user.consentSharing;
    _c3 = user.consentTermsPrivacy;
  }

  bool get _allConsentsAccepted => _c1 && _c2 && _c3;

  void _toggleAllConsents() {
    setState(() {
      final selectAll = !_allConsentsAccepted;
      _c1 = selectAll;
      _c2 = selectAll;
      _c3 = selectAll;
    });
  }

  void _onPrevious() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ref.read(authKycProvider.notifier).updateStep(3);
    context.go('/kyc-details');
  }

  void _onContinue() {
    if (!_c1 || !_c2 || !_c3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept all consent checkboxes to proceed.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    final user = ref.read(authKycProvider).user;
    final updated = user.copyWith(
      consentProcessing: _c1,
      consentSharing: _c2,
      consentTermsPrivacy: _c3,
      agreeTerms: true,
    );
    ref.read(authKycProvider.notifier).updateUserData(updated);
    ref.read(authKycProvider.notifier).updateStep(5);
    context.go('/privacy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const FlowHeader(activeStep: 4),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Terms, Conditions & Consent',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2540),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Please review the terms and provide your consent to proceed with KYC verification',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 20),

                      // Card 1: Terms & Conditions Content
                      Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0066FF).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.description_outlined, size: 20, color: Color(0xFF0066FF)),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Terms & Conditions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A2540),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              '1. Acceptance of Terms',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'By creating an account with FINMOS, you agree to be bound by these Terms & Conditions.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                            ),
                            const SizedBox(height: 14),

                            const Text(
                              '2. Use of Services',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'You agree to use our services only for lawful purposes and in accordance with applicable laws and regulations.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                            ),
                            const SizedBox(height: 14),

                            const Text(
                              '3. User Responsibilities',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'You are responsible for maintaining the confidentiality of your account credentials.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Card 2: Consent Acceptance Checkboxes
                      Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: _toggleAllConsents,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF10B981).withOpacity(_allConsentsAccepted ? 0.6 : 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        _allConsentsAccepted ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                                        size: 20,
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Consent Acceptance',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A2540),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildConsentTile(
                              value: _c1,
                              text: 'I agree to the collection, use and processing of my personal data for KYC verification.',
                              onChanged: (val) => setState(() => _c1 = val ?? false),
                            ),
                            const SizedBox(height: 14),

                            _buildConsentTile(
                              value: _c2,
                              text: 'I consent to share my information with authorized partners for verification purposes.',
                              onChanged: (val) => setState(() => _c2 = val ?? false),
                            ),
                            const SizedBox(height: 14),

                            _buildConsentTile(
                              value: _c3,
                              textWidget: Text.rich(
                                TextSpan(
                                  text: 'I have read and understood the ',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                                  children: [
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: const TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy.',
                                      style: const TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              onChanged: (val) => setState(() => _c3 = val ?? false),
                            ),
                            const SizedBox(height: 28),

                            // Action Buttons Row: Previous & Continue
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
                                            Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                            SizedBox(width: 4),
                                            Icon(Icons.arrow_forward, size: 18),
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

  Widget _buildConsentTile({
    required bool value,
    String? text,
    Widget? textWidget,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? const Color(0xFF0066FF) : const Color(0xFFE2E8F0),
          width: value ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              activeColor: const Color(0xFF0066FF),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: textWidget ??
                Text(
                  text!,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                ),
          ),
        ],
      ),
    );
  }
}
