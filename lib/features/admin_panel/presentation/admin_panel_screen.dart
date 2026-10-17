import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../providers/admin_provider.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);

    final filteredUsers = state.users.where((u) {
      return u.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(state.searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0066FF)),
          onPressed: () {
            context.go('/profile');
          },
        ),
        title: const FinmosLogo(size: 26, showTagline: false, isHorizontal: true),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF0066FF)),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text('Admin Panel Foundation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
              const Text('Monitor and manage your FINMOS platform.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 16),

              // 5 Metric Stat Grid Cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildAdminMetricCard('Total Users', '${state.totalUsers}', '+12% vs last month', const Color(0xFF0066FF), Icons.people_outline),
                    const SizedBox(width: 10),
                    _buildAdminMetricCard('KYC Completed', '${state.kycCompleted}', '+15% vs last month', const Color(0xFF10B981), Icons.verified_user_outlined),
                    const SizedBox(width: 10),
                    _buildAdminMetricCard('Connected Accs', '${state.connectedAccounts}', '+10% vs last month', const Color(0xFF6366F1), Icons.account_balance_outlined),
                    const SizedBox(width: 10),
                    _buildAdminMetricCard('Transactions', '${state.totalTransactions}', '+22% vs last month', const Color(0xFF8B5CF6), Icons.swap_horiz_outlined),
                    const SizedBox(width: 10),
                    _buildAdminMetricCard('Pending KYC', '${state.pendingKyc}', '-8% vs last month', const Color(0xFFEF4444), Icons.hourglass_top_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Actions & Governance Card (Image 8 matching)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Platform Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.gavel_outlined, size: 16, color: Color(0xFF0066FF)),
                          label: const Text('FPMS Governance (Module 1)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () => context.go('/fpms-admin'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.people_outline, size: 16, color: Color(0xFF10B981)),
                          label: const Text('Advisor Ecosystem', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () => context.go('/advisor-ecosystem'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.folder_open_outlined, size: 16, color: Color(0xFF6366F1)),
                          label: const Text('Document Vault', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () => context.go('/document-vault'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFFF59E0B)),
                          label: const Text('KYC Management', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () => context.go('/kyc-status'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // User Management Section Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('User Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => ref.read(adminProvider.notifier).setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search user by name or email...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (ctx, idx) {
                        final u = filteredUsers[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF0066FF).withOpacity(0.15),
                                child: Text(u.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                                    Text('${u.email} • Joined ${u.joinedOn}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              Switch(
                                value: u.isActive,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (_) => ref.read(adminProvider.notifier).toggleUserStatus(u.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminMetricCard(String title, String count, String sub, Color color, IconData icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 14, backgroundColor: color.withOpacity(0.15), child: Icon(icon, size: 14, color: color)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
