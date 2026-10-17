import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = false;
  bool _biometricLock = true;
  bool _autoSync = true;
  bool _pushNotifs = true;
  bool _emailAlerts = true;
  String _selectedCurrency = 'INR (₹)';
  String _selectedLanguage = 'English';

  void _showChangePasswordDialog() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
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
                  'Change Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: currentPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (newPassCtrl.text.isEmpty || newPassCtrl.text != confirmPassCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match or field is empty!')),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password updated successfully!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    child: const Text('Update Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 8),
            Text('Delete Account?', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? All your financial data, linked accounts, and custom budgets will be permanently deleted.',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/signup');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion request submitted.')),
              );
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation: 1,
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
        title: const FinmosLogo(size: 24, showTagline: false, isHorizontal: true),
      ),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 4),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Header Title
          const Text(
            'Settings & Preferences',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
          ),
          const Text(
            'Manage app behavior, security, currency, and data privacy.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

              // Section 1: Security & Authentication
              _buildSectionCard(
                title: 'Security & Privacy',
                icon: Icons.shield_outlined,
                child: Column(
                  children: [
                    _buildTileWithAction(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      trailing: OutlinedButton(
                        onPressed: _showChangePasswordDialog,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          side: const BorderSide(color: Color(0xFF0066FF)),
                        ),
                        child: const Text('Change', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildSwitchTile(
                      icon: Icons.fingerprint,
                      title: 'Biometric App Lock',
                      subtitle: 'Require Fingerprint / Face ID to open app',
                      value: _biometricLock,
                      onChanged: (val) => setState(() => _biometricLock = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildTileWithAction(
                      icon: Icons.security,
                      title: 'Two-Factor Authentication (2FA)',
                      subtitle: 'SMS & OTP security verification',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 2: Regional & App Preferences
              _buildSectionCard(
                title: 'App Preferences',
                icon: Icons.tune,
                child: Column(
                  children: [
                    _buildDropdownTile(
                      icon: Icons.currency_rupee,
                      title: 'Default Currency',
                      value: _selectedCurrency,
                      items: ['INR (₹)', 'USD (\$)', 'EUR (€)', 'GBP (£)'],
                      onChanged: (val) => setState(() => _selectedCurrency = val!),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildDropdownTile(
                      icon: Icons.language,
                      title: 'App Language',
                      value: _selectedLanguage,
                      items: ['English', 'Hindi', 'Telugu', 'Tamil'],
                      onChanged: (val) => setState(() => _selectedLanguage = val!),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark themes',
                      value: _darkMode,
                      onChanged: (val) => setState(() => _darkMode = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 3: Data & Sync
              _buildSectionCard(
                title: 'Data & Sync',
                icon: Icons.cloud_sync_outlined,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.sync,
                      title: 'Automatic Account Sync',
                      subtitle: 'Sync bank transactions every 24 hours',
                      value: _autoSync,
                      onChanged: (val) => setState(() => _autoSync = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildTileWithAction(
                      icon: Icons.cleaning_services_outlined,
                      title: 'Clear Cache & Temp Data',
                      subtitle: 'Free up local device storage (4.2 MB)',
                      trailing: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Local cache cleared!'), backgroundColor: Color(0xFF10B981)),
                          );
                        },
                        child: const Text('Clear', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildTileWithAction(
                      icon: Icons.download_outlined,
                      title: 'Export My Financial Data',
                      subtitle: 'Download complete report in CSV/PDF format',
                      trailing: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Financial summary report generated and saved!')),
                          );
                        },
                        icon: const Icon(Icons.file_download, size: 14),
                        label: const Text('Export', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 4: Notifications
              _buildSectionCard(
                title: 'Notification Settings',
                icon: Icons.notifications_none,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Alerts for budgets, income & expenses',
                      value: _pushNotifs,
                      onChanged: (val) => setState(() => _pushNotifs = val),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildSwitchTile(
                      icon: Icons.email_outlined,
                      title: 'Email Summary Alerts',
                      subtitle: 'Weekly financial overview & tips via email',
                      value: _emailAlerts,
                      onChanged: (val) => setState(() => _emailAlerts = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Danger Zone Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Danger Zone',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF991B1B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Permanently remove your profile, data, and access from FINOMOS platform.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF7F1D1D)),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showDeleteAccountDialog,
                        icon: const Icon(Icons.delete_forever, size: 16, color: Colors.white),
                        label: const Text('Delete Account & Data', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0066FF), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF0066FF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTileWithAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
          ),
          DropdownButton<String>(
            value: items.contains(value) ? value : (items.isNotEmpty ? items.first : null),
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0066FF))),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
