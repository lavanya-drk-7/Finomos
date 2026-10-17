import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../../core/widgets/finmos_user_avatar.dart';
import 'widgets/profile_options_drawer.dart';
import '../../income_tracking/providers/income_provider.dart';
import '../../expense_tracking/providers/expense_provider.dart';
import '../../protect/providers/protect_provider.dart';
import '../../borrow/providers/borrow_provider.dart';
import '../../grow/providers/grow_provider.dart';
import '../../plan/providers/plan_provider.dart';
import '../../comply/providers/comply_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeState = ref.watch(incomeProvider);
    final expenseState = ref.watch(expenseProvider);
    final protectState = ref.watch(protectProvider);
    final borrowState = ref.watch(borrowProvider);
    final growState = ref.watch(growProvider);
    final planState = ref.watch(planProvider);
    final complyState = ref.watch(complyProvider);

    final totalEarn = incomeState.totalMonthlyIncome > 0
        ? incomeState.totalMonthlyIncome
        : incomeState.entries.fold(0.0, (sum, e) => sum + e.amount);
    final totalSpend = expenseState.totalExpenses;
    final spendRatio = totalEarn > 0 ? ((totalSpend / totalEarn) * 100).toStringAsFixed(1) : '39.9';
    final borrowDti = totalEarn > 0
        ? ((borrowState.totalMonthlyEmi / totalEarn) * 100).toStringAsFixed(1)
        : '18.9';
    final planGoalsTotal = planState.goals.fold(0.0, (s, g) => s + g.currentCorpus);
    final complyDeductions = complyState.deductions.fold(0.0, (s, d) => s + d.utilized);

    return Scaffold(
      endDrawerEnableOpenDragGesture: false,
      endDrawer: const ProfileOptionsDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
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
        title: const FinmosLogo(size: 26, showTagline: false, isHorizontal: true),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF0066FF)),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
          Builder(
            builder: (appBarContext) => IconButton(
              icon: const FinmosUserAvatar(radius: 14),
              tooltip: 'Profile & Settings',
              onPressed: () => Scaffold.of(appBarContext).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title
              const Text('Finomos Financial OS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
              const Text('AI Personal CFO Platform & 7 Financial Pillars Hub.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 16),

              // AI Personal CFO Banner Card
              InkWell(
                onTap: () => context.go('/cfo-ai'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A2540), Color(0xFF0066FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.psychology, color: Color(0xFF10B981), size: 26),
                              SizedBox(width: 8),
                              Text('AI PERSONAL CFO', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('HEALTH: 88/100', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Virtual Digital Twin & Autopilot Active', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text(
                        'Net Worth: ₹33.4L  |  Runway: 8.5 Mos  |  FIRE Freedom: 1.15x',
                        style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Text('Launch AI CFO Copilot', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 7 Financial Pillars Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('7 Financial Pillars', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                  Text('Enterprise PFOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.30,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildPillarTile(
                    context,
                    title: '1. INCOME',
                    subtitle: '',
                    icon: Icons.trending_up,
                    color: const Color(0xFF10B981),
                    route: '/income-tracking',
                    amount: _formatRupees(totalEarn),
                    percentage: '+12.4%',
                    badgeColor: const Color(0xFF10B981),
                    percentageIcon: Icons.trending_up,
                  ),
                  _buildPillarTile(
                    context,
                    title: '2. EXPENSE',
                    subtitle: '',
                    icon: Icons.trending_down,
                    color: const Color(0xFFEF4444),
                    route: '/expense-tracking',
                    amount: _formatRupees(totalSpend),
                    percentage: '$spendRatio%',
                    badgeColor: const Color(0xFFEF4444),
                    percentageIcon: Icons.trending_down,
                    isPositiveTrend: false,
                  ),
                  _buildPillarTile(
                    context,
                    title: '3. PROTECT',
                    subtitle: 'Emergency & Insurance',
                    icon: Icons.security,
                    color: const Color(0xFF0066FF),
                    route: '/protect',
                    amount: _formatRupees(protectState.emergencyFund.currentAmount),
                    percentage: '${protectState.emergencyFund.readinessScore.toStringAsFixed(0)}%',
                    badgeColor: const Color(0xFF0066FF),
                    percentageIcon: Icons.shield,
                  ),
                  _buildPillarTile(
                    context,
                    title: '4. BORROW',
                    subtitle: 'Debt & Repayment',
                    icon: Icons.credit_score,
                    color: const Color(0xFFF59E0B),
                    route: '/borrow',
                    amount: _formatRupees(borrowState.totalDebtOutstanding),
                    percentage: '$borrowDti%',
                    badgeColor: const Color(0xFFF59E0B),
                    percentageIcon: Icons.percent,
                  ),
                  _buildPillarTile(
                    context,
                    title: '5. GROW',
                    subtitle: 'Investments & Wealth',
                    icon: Icons.auto_graph,
                    color: const Color(0xFF8B5CF6),
                    route: '/grow',
                    amount: _formatRupees(growState.portfolioValue),
                    percentage: '+${growState.xirr.toStringAsFixed(1)}%',
                    badgeColor: const Color(0xFF8B5CF6),
                    percentageIcon: Icons.auto_graph,
                  ),
                  _buildPillarTile(
                    context,
                    title: '6. PLAN',
                    subtitle: 'Goals & FIRE Calculator',
                    icon: Icons.flag,
                    color: const Color(0xFFEC4899),
                    route: '/plan',
                    amount: _formatRupees(planGoalsTotal),
                    percentage: '${planState.retirementPlan.fireReadinessScore.toStringAsFixed(0)}%',
                    badgeColor: const Color(0xFFEC4899),
                    percentageIcon: Icons.flag,
                  ),
                  _buildPillarTile(
                    context,
                    title: '7. COMPLY',
                    subtitle: 'Tax & ITR Preparation',
                    icon: Icons.assignment_turned_in,
                    color: const Color(0xFF0A2540),
                    route: '/comply',
                    amount: _formatRupees(complyDeductions),
                    percentage: '${complyState.itrReadinessScore.toStringAsFixed(0)}%',
                    badgeColor: const Color(0xFF0A2540),
                    percentageIcon: Icons.verified,
                  ),
                  _buildPillarTile(
                    context,
                    title: 'ADVISORS',
                    subtitle: 'CA & Expert Network',
                    icon: Icons.handshake,
                    color: const Color(0xFF0284C7),
                    route: '/advisor-ecosystem',
                    amount: '50+ Experts',
                    percentage: '98.5%',
                    badgeColor: const Color(0xFF0284C7),
                    percentageIcon: Icons.star,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Platform Operations & Admin Section
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
                    const Text('Platform Governance & System Tools', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _buildNavModule(context, Icons.account_balance, 'Bank Aggregation', '/bank-aggregation', const Color(0xFF0066FF)),
                        _buildNavModule(context, Icons.pie_chart, 'Budget Engine', '/budget-management', const Color(0xFFF59E0B)),
                        _buildNavModule(context, Icons.folder_special, 'Document Vault', '/document-vault', const Color(0xFF8B5CF6)),
                        _buildNavModule(context, Icons.help_outline, 'Help & Support', '/help-support', const Color(0xFF0284C7)),
                      ],
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

  String _formatRupees(double amount) {
    if (amount.isNaN || amount.isInfinite || amount < 0) return '₹0';
    final int val = amount.round();
    final str = val.toString();
    if (str.length <= 3) return '₹$str';
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if ((rest.length - i) % 2 == 0 && i != 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    return '₹${buffer.toString()},$lastThree';
  }

  Widget _buildPillarTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
    required String amount,
    required String percentage,
    IconData? percentageIcon,
    Color? badgeColor,
    bool isPositiveTrend = true,
  }) {
    final effectiveBadgeColor = badgeColor ?? (isPositiveTrend ? const Color(0xFF10B981) : const Color(0xFFEF4444));
    final effectivePercentageIcon = percentageIcon ?? (isPositiveTrend ? Icons.trending_up : Icons.trending_down);

    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.18), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Top Section: Title & Subtitle (category icon removed)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),

            // 2. Middle Section: Amount (Total Amount label removed, increased amount size)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: const TextStyle(
                  fontSize: 19.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0A2540),
                  letterSpacing: -0.4,
                ),
              ),
            ),

            // 3. Bottom Section: Percentage
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
              decoration: BoxDecoration(
                color: effectiveBadgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: effectiveBadgeColor.withOpacity(0.25), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    effectivePercentageIcon,
                    size: 10,
                    color: effectiveBadgeColor,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    percentage,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: effectiveBadgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavModule(BuildContext context, IconData icon, String label, String route, Color color) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
