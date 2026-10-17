import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../providers/profile_provider.dart';

class CommunicationPrefsSubScreen extends ConsumerStatefulWidget {
  const CommunicationPrefsSubScreen({super.key});

  @override
  ConsumerState<CommunicationPrefsSubScreen> createState() => _CommunicationPrefsSubScreenState();
}

class _CommunicationPrefsSubScreenState extends ConsumerState<CommunicationPrefsSubScreen> {
  String selectedFrequency = 'Real-time Instant';

  bool budgetAlerts = true;
  bool bankSyncAlerts = true;
  bool kycAlerts = true;
  bool cfoInsights = true;

  bool soundVibrationPref = true;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(profileProvider).communicationPrefs;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0066FF)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: const Text(
          'Communication & Alert Preferences',
          style: TextStyle(
            color: Color(0xFF0A2540),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 4),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          // Section 1: Notification Categories
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                const Text(
                  'Notification Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2540),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose which alert categories you wish to receive',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                _buildToggleRow(
                  Icons.pie_chart,
                  'Budget & Spending Alerts',
                  'High threshold & limit warning notifications',
                  budgetAlerts,
                  (val) => setState(() => budgetAlerts = val),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildToggleRow(
                  Icons.account_balance,
                  'Bank & Transaction Sync',
                  'Account Aggregator & deposit alerts',
                  bankSyncAlerts,
                  (val) => setState(() => bankSyncAlerts = val),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildToggleRow(
                  Icons.verified_user,
                  'KYC & Compliance Status',
                  'Verification status updates & documents',
                  kycAlerts,
                  (val) => setState(() => kycAlerts = val),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildToggleRow(
                  Icons.psychology,
                  'AI CFO Smart Insights',
                  'Predictive runway & financial health advice',
                  cfoInsights,
                  (val) => setState(() => cfoInsights = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Delivery Preferences (Consolidated & Non-Duplicate)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                const Text(
                  'Delivery Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2540),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage alert delivery modes and sound feedback',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                _buildToggleRow(
                  Icons.notifications_active,
                  'Push Notifications',
                  'Receive instant alerts on your device screen',
                  prefs.pushNotifications,
                  (val) {
                    ref.read(profileProvider.notifier).updateCommunicationPrefs(
                          prefs.copyWith(pushNotifications: val),
                        );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildToggleRow(
                  Icons.email,
                  'Email Digests',
                  'Receive weekly summary report via email',
                  prefs.emailNotifications,
                  (val) {
                    ref.read(profileProvider.notifier).updateCommunicationPrefs(
                          prefs.copyWith(emailNotifications: val),
                        );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildToggleRow(
                  Icons.sms,
                  'SMS Alerts',
                  'Critical security & transaction SMS',
                  prefs.smsNotifications,
                  (val) {
                    ref.read(profileProvider.notifier).updateCommunicationPrefs(
                          prefs.copyWith(smsNotifications: val),
                        );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildToggleRow(
                  Icons.volume_up,
                  'In-App Sound & Vibration',
                  'Play sound on receiving critical alerts',
                  soundVibrationPref,
                  (val) => setState(() => soundVibrationPref = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 3: Alert Frequency Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                const Text(
                  'Alert Frequency',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2540),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedFrequency,
                  decoration: const InputDecoration(
                    labelText: 'Notification Frequency',
                    prefixIcon: Icon(Icons.schedule),
                    border: OutlineInputBorder(),
                  ),
                  items: ['Real-time Instant', 'Daily Summary Digest', 'Weekly Digest Only']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedFrequency = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildToggleRow(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF0066FF).withOpacity(0.15),
            child: Icon(icon, size: 16, color: const Color(0xFF0066FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF0066FF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}


