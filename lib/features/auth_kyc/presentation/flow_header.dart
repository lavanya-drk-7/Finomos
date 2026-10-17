import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../providers/auth_kyc_provider.dart';

class FlowHeader extends ConsumerWidget {
  final int activeStep;
  final String? customTitle;
  final VoidCallback? onBackTap;

  const FlowHeader({
    super.key,
    required this.activeStep,
    this.customTitle,
    this.onBackTap,
  });

  static const List<Map<String, String>> loginSteps = [
    {'number': '1', 'name': 'Welcome Back', 'route': '/login'},
  ];

  static const List<Map<String, String>> registrationSteps = [
    {'number': '1', 'name': 'Sign Up', 'route': '/signup'},
    {'number': '2', 'name': 'User Details', 'route': '/user-details'},
    {'number': '3', 'name': 'KYC Form', 'route': '/kyc-details'},
    {'number': '4', 'name': 'Terms & Consent', 'route': '/consent'},
    {'number': '5', 'name': 'Privacy Policy', 'route': '/privacy'},
    {'number': '6', 'name': 'KYC Status', 'route': '/kyc-status'},
  ];

  void _handlePrevious(BuildContext context, WidgetRef ref) {
    if (onBackTap != null) {
      onBackTap!();
      return;
    }
    final isExistingUser = ref.read(authKycProvider).isExistingUser;
    if (isExistingUser) {
      if (activeStep >= 3) {
        ref.read(authKycProvider.notifier).updateStep(2);
        context.go('/login');
      } else {
        context.go('/splash');
      }
    } else {
      if (activeStep > 1) {
        final prevIndex = activeStep - 2; // activeStep is 1-indexed
        final prevRoute = registrationSteps[prevIndex]['route']!;
        ref.read(authKycProvider.notifier).updateStep(activeStep - 1);
        context.go(prevRoute);
      } else {
        context.go('/splash');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExistingUser = ref.watch(authKycProvider).isExistingUser;
    final activeList = isExistingUser ? loginSteps : registrationSteps;
    final int currentDisplayStep = isExistingUser
        ? ((activeStep >= 3) ? 2 : 1)
        : activeStep.clamp(1, registrationSteps.length);
    final double progress = currentDisplayStep / activeList.length;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App Bar Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Back / Previous Button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0066FF)),
                  tooltip: 'Previous Step',
                  onPressed: () => _handlePrevious(context, ref),
                ),
                const SizedBox(width: 4),
                const FinmosLogo(
                  size: 26,
                  showTagline: false,
                  isHorizontal: true,
                ),
                const Spacer(),
                // Step Pill indicator
                GestureDetector(
                  onTap: () => _showStepSheet(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Step $currentDisplayStep/${activeList.length}',
                          style: const TextStyle(
                            color: Color(0xFF0066FF),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF0066FF)),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),

          // Progress Bar
          Stack(
            children: [
              Container(
                height: 3,
                width: double.infinity,
                color: const Color(0xFFE2E8F0),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                width: MediaQuery.of(context).size.width * progress,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF10B981)],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStepSheet(BuildContext context, WidgetRef ref) {
    final isExistingUser = ref.read(authKycProvider).isExistingUser;
    final activeList = isExistingUser ? loginSteps : registrationSteps;
    final int currentDisplayStep = isExistingUser
        ? ((activeStep >= 3) ? 2 : 1)
        : activeStep.clamp(1, registrationSteps.length);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Navigate Steps',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: activeList.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final stepNum = index + 1;
                    final isActive = stepNum == currentDisplayStep;
                    final stepInfo = activeList[index];

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: isActive ? const Color(0xFF0066FF) : const Color(0xFFE2E8F0),
                        child: Text(
                          stepInfo['number']!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      title: Text(
                        stepInfo['name']!,
                        style: TextStyle(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? const Color(0xFF0066FF) : const Color(0xFF0A2540),
                        ),
                      ),
                      trailing: isActive
                          ? const Icon(Icons.check_circle, color: Color(0xFF0066FF), size: 18)
                          : const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (!isExistingUser) {
                          ref.read(authKycProvider.notifier).updateStep(stepNum);
                        }
                        context.go(stepInfo['route']!);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
