import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../domain/kyc_models.dart';
import '../providers/auth_kyc_provider.dart';
import 'flow_header.dart';

class KycStatusScreen extends ConsumerWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycState = ref.watch(authKycProvider);
    final status = kycState.kycStatus;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            FlowHeader(
              activeStep: 6,
              onBackTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  ref.read(authKycProvider.notifier).updateStep(5);
                  context.go('/privacy');
                }
              },
            ),
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
                      children: [
                        const Text(
                          'KYC Status',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2540),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // KYC Status Banner Card
                        _buildStatusBanner(status),
                        const SizedBox(height: 28),

                        // Timeline Stepper
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Verification Progress Timeline',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTimelineItem(
                          title: 'Registration Completed',
                          subtitle: kycState.registrationCompletedTime,
                          isCompleted: true,
                          isLast: false,
                        ),
                        _buildTimelineItem(
                          title: 'KYC Submitted',
                          subtitle: kycState.kycSubmittedTime,
                          isCompleted: true,
                          isLast: false,
                        ),
                        _buildTimelineItem(
                          title: 'KYC Verification',
                          subtitle: status == KycStatus.pending
                              ? 'In Progress'
                              : status == KycStatus.verified
                                  ? 'Completed Successfully'
                                  : 'Verification Failed',
                          isCompleted: status == KycStatus.verified,
                          isInProgress: status == KycStatus.pending,
                          isFailed: status == KycStatus.rejected,
                          isLast: false,
                        ),
                        _buildTimelineItem(
                          title: 'Final Status',
                          subtitle: status == KycStatus.pending
                              ? 'Pending Review'
                              : status == KycStatus.verified
                                  ? 'Verified'
                                  : 'Rejected',
                          isCompleted: status == KycStatus.verified,
                          isInProgress: status == KycStatus.pending,
                          isFailed: status == KycStatus.rejected,
                          isLast: true,
                        ),
                        const SizedBox(height: 28),

                        // Status Switcher Control Bar for Demo/Testing
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Interactive Status Switcher (Demo):',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatusButton(
                                    ref: ref,
                                    targetStatus: KycStatus.pending,
                                    currentStatus: status,
                                    label: 'Pending',
                                    color: const Color(0xFFF59E0B),
                                  ),
                                  _buildStatusButton(
                                    ref: ref,
                                    targetStatus: KycStatus.verified,
                                    currentStatus: status,
                                    label: 'Verified',
                                    color: const Color(0xFF10B981),
                                  ),
                                  _buildStatusButton(
                                    ref: ref,
                                    targetStatus: KycStatus.rejected,
                                    currentStatus: status,
                                    label: 'Rejected',
                                    color: const Color(0xFFEF4444),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons Row: Previous & Go to Home Dashboard
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ref.read(authKycProvider.notifier).updateStep(5);
                                    context.go('/privacy');
                                  },
                                  icon: const Icon(Icons.arrow_back, size: 18),
                                  label: const Text('Previous'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF475569),
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.go('/dashboard');
                                  },
                                  icon: const Icon(Icons.home, size: 20),
                                  label: const Text('Home Dashboard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
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

  Widget _buildStatusBanner(KycStatus status) {
    Color bg;
    Color border;
    IconData icon;
    String title;
    String subtitle;

    switch (status) {
      case KycStatus.pending:
        bg = const Color(0xFFFFFBEB);
        border = const Color(0xFFFCD34D);
        icon = Icons.hourglass_top_rounded;
        title = 'KYC Pending';
        subtitle = 'Your KYC is under review.\nYou will be notified once it is completed.';
        break;
      case KycStatus.verified:
        bg = const Color(0xFFECFDF5);
        border = const Color(0xFF6EE7B7);
        icon = Icons.verified_user_rounded;
        title = 'KYC Verified';
        subtitle = 'Your KYC identity has been successfully verified.\nYour account is fully active.';
        break;
      case KycStatus.rejected:
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFCA5A5);
        icon = Icons.gpp_bad_rounded;
        title = 'KYC Rejected';
        subtitle = 'Your KYC verification was not approved.\nPlease review your documents and resubmit.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: border,
            child: Icon(
              icon,
              size: 30,
              color: status == KycStatus.pending
                  ? const Color(0xFFD97706)
                  : status == KycStatus.verified
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: status == KycStatus.pending
                  ? const Color(0xFF92400E)
                  : status == KycStatus.verified
                      ? const Color(0xFF065F46)
                      : const Color(0xFF991B1B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: status == KycStatus.pending
                  ? const Color(0xFFB45309)
                  : status == KycStatus.verified
                      ? const Color(0xFF047857)
                      : const Color(0xFFB91C1C),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isInProgress = false,
    bool isFailed = false,
    required bool isLast,
  }) {
    Color iconBg = isCompleted
        ? const Color(0xFF10B981)
        : isInProgress
            ? const Color(0xFFF59E0B)
            : isFailed
                ? const Color(0xFFEF4444)
                : const Color(0xFFCBD5E1);

    IconData icon = isCompleted
        ? Icons.check
        : isInProgress
            ? Icons.sync
            : isFailed
                ? Icons.close
                : Icons.circle_outlined;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: iconBg,
              child: Icon(icon, size: 14, color: Colors.white),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2540),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton({
    required WidgetRef ref,
    required KycStatus targetStatus,
    required KycStatus currentStatus,
    required String label,
    required Color color,
  }) {
    final isSelected = targetStatus == currentStatus;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        foregroundColor: isSelected ? Colors.white : color,
        elevation: isSelected ? 2 : 0,
        minimumSize: const Size(90, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color, width: 1.5),
        ),
      ),
      onPressed: () {
        ref.read(authKycProvider.notifier).setKycStatus(targetStatus);
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
