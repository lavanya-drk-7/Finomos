import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth_kyc/domain/kyc_models.dart';
import '../../features/auth_kyc/providers/auth_kyc_provider.dart';

class FinmosKycBadge extends ConsumerWidget {
  final bool isCompact;
  final bool isInteractive;
  final String? prefixText;
  final VoidCallback? onTap;

  const FinmosKycBadge({
    super.key,
    this.isCompact = false,
    this.isInteractive = true,
    this.prefixText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authKycProvider).kycStatus;

    final Color color;
    final IconData icon;
    final String label;

    switch (status) {
      case KycStatus.verified:
        color = const Color(0xFF10B981);
        icon = Icons.verified;
        label = isCompact ? 'Verified' : 'Identity Verified (KYC Active)';
        break;
      case KycStatus.pending:
        color = const Color(0xFFF59E0B);
        icon = Icons.hourglass_top;
        label = isCompact ? 'Pending' : 'Identity Verification Pending';
        break;
      case KycStatus.rejected:
        color = const Color(0xFFEF4444);
        icon = Icons.cancel;
        label = isCompact ? 'Rejected' : 'Identity Verification Rejected';
        break;
    }

    final displayText = prefixText != null ? '$prefixText$label' : label;

    final badgeContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (isInteractive && !isCompact) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 12, color: color.withOpacity(0.8)),
          ],
        ],
      ),
    );

    if (!isInteractive) {
      return badgeContent;
    }

    return InkWell(
      onTap: onTap ??
          () {
            ref.read(authKycProvider.notifier).updateStep(11);
            context.push('/kyc-status');
          },
      borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
      child: badgeContent,
    );
  }
}
