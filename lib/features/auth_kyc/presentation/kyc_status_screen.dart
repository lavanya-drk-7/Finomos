import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../domain/kyc_models.dart';
import '../providers/auth_kyc_provider.dart';
import 'flow_header.dart';

class KycStatusScreen extends ConsumerWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isTestEnv = false;
    try {
      isTestEnv = Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {}

    final kycState = ref.watch(authKycProvider);
    final status = kycState.kycStatus;
    final liveStatus = kycState.liveStatus;
    final liveDocuments = kycState.liveDocuments;

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
              child: RefreshIndicator(
                color: const Color(0xFF0066FF),
                onRefresh: () =>
                    ref.read(authKycProvider.notifier).loadLiveKycData(force: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            if (kycState.isSyncing) ...[
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0066FF),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),

                        // KYC Status Banner Card
                        _buildStatusBanner(status),
                        const SizedBox(height: 24),

                        // Summary Metrics Cards (From GET /api/v1/kyc/status summary)
                        if (liveStatus?.summary != null) ...[
                          _buildSummaryCards(liveStatus!.summary),
                          const SizedBox(height: 24),
                        ],

                        // Timeline Stepper Header
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Verification Progress Timeline',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A2540),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (liveStatus != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${liveStatus.currentStep} of ${liveStatus.totalSteps} Complete',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dynamic Timeline (or Fallback Stepper)
                        if (liveStatus != null &&
                            liveStatus.timeline.isNotEmpty) ...[
                          for (int i = 0; i < liveStatus.timeline.length; i++)
                            _buildTimelineItem(
                              title:
                                  'Step ${liveStatus.timeline[i].step}: ${liveStatus.timeline[i].title}',
                              subtitle: liveStatus.timeline[i].description +
                                  (liveStatus.timeline[i].documentsCount != null
                                      ? ' (${liveStatus.timeline[i].documentsCount} documents verified)'
                                      : ''),
                              isCompleted: liveStatus.timeline[i].isCompleted,
                              isInProgress:
                                  liveStatus.timeline[i].status.toUpperCase() ==
                                      'IN_PROGRESS',
                              isFailed:
                                  liveStatus.timeline[i].status.toUpperCase() ==
                                      'FAILED',
                              isLast: i == liveStatus.timeline.length - 1,
                            ),
                        ] else ...[
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
                        ],
                        const SizedBox(height: 24),

                        // Section 65B Identity Documents List
                        if (liveDocuments.isNotEmpty) ...[
                          _buildDocumentsList(context, ref, liveDocuments),
                          const SizedBox(height: 24),
                        ],

                        // Re-Verify Action Button (POST /api/v1/kyc/re-verify)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: kycState.isSyncing
                                ? null
                                : () async {
                                    final res = await ref
                                        .read(authKycProvider.notifier)
                                        .reVerifyDocument('PAN');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            res != null
                                                ? 'PAN successfully re-verified under Section 65B'
                                                : 'Re-verification request completed',
                                          ),
                                          backgroundColor:
                                              const Color(0xFF10B981),
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.verified,
                                size: 18, color: Color(0xFF0066FF)),
                            label: const Text(
                              'Re-Verify PAN Under Section 65B',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0066FF),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF0066FF)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        if (kDebugMode || isTestEnv) ...[
                          const SizedBox(height: 24),
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
                                  children: [
                                    Expanded(
                                      child: _buildStatusButton(
                                        ref: ref,
                                        targetStatus: KycStatus.pending,
                                        currentStatus: status,
                                        label: 'Pending',
                                        color: const Color(0xFFF59E0B),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _buildStatusButton(
                                        ref: ref,
                                        targetStatus: KycStatus.verified,
                                        currentStatus: status,
                                        label: 'Verified',
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _buildStatusButton(
                                        ref: ref,
                                        targetStatus: KycStatus.rejected,
                                        currentStatus: status,
                                        label: 'Rejected',
                                        color: const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Action Buttons Row: Previous & Go to Home Dashboard
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(authKycProvider.notifier)
                                        .updateStep(5);
                                    context.go('/privacy');
                                  },
                                  icon: const Icon(Icons.arrow_back, size: 18),
                                  label: const Text('Previous'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF475569),
                                    side: const BorderSide(
                                        color: Color(0xFFCBD5E1)),
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
                                    final activeMobile = PhoneUtils.sanitize(
                                      ref.read(authKycProvider).user.mobileNumber.isNotEmpty
                                          ? ref.read(authKycProvider).user.mobileNumber
                                          : (LocalCacheService().get('user_mobile_number')?.toString() ?? ''),
                                    );
                                    final bool isSmsAllowed = LocalCacheService().get('sms_allowed_$activeMobile') == true;
                                    if (!isSmsAllowed) {
                                      context.go('/allow-sms');
                                    } else {
                                      context.go('/dashboard');
                                    }
                                  },
                                  icon: const Icon(Icons.home, size: 20),
                                  label: const Text('Home Dashboard',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(KycSummary summary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryMetric(
              label: 'PAN Number',
              value: summary.panNumber,
              icon: Icons.credit_card,
              color: const Color(0xFF0066FF),
            ),
          ),
          Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
          Expanded(
            child: _buildSummaryMetric(
              label: 'Documents',
              value: '${summary.documentsSubmitted}',
              icon: Icons.description,
              color: const Color(0xFF10B981),
            ),
          ),
          Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
          Expanded(
            child: _buildSummaryMetric(
              label: 'Consents',
              value: '${summary.consentsAccepted}',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2540),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDocumentsList(
      BuildContext context, WidgetRef ref, List<KycDocumentItem> docs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Submitted Proofs (${docs.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2540),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Section 65B Certified',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final doc in docs.take(4))
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fingerprint,
                        size: 20, color: Color(0xFF0066FF)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                doc.displayType,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A2540),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                doc.idNumber,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${doc.fileName} • ${doc.formattedFileSize}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (doc.sha256Hash.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'SHA256: ${doc.sha256Hash.substring(0, doc.sha256Hash.length > 20 ? 20 : doc.sha256Hash.length)}...',
                            style: const TextStyle(
                              fontSize: 9,
                              fontFamily: 'monospace',
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: doc.isVerified
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      doc.status,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: doc.isVerified
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
        subtitle =
            'Your KYC is under review.\nYou will be notified once it is completed.';
        break;
      case KycStatus.verified:
        bg = const Color(0xFFECFDF5);
        border = const Color(0xFF6EE7B7);
        icon = Icons.verified_user_rounded;
        title = 'KYC Verified';
        subtitle =
            'Your KYC identity has been successfully verified.\nYour account is fully active.';
        break;
      case KycStatus.rejected:
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFCA5A5);
        icon = Icons.gpp_bad_rounded;
        title = 'KYC Rejected';
        subtitle =
            'Your KYC verification was not approved.\nPlease review your documents and resubmit.';
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
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFE2E8F0),
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
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
