import '../../auth_kyc/providers/auth_kyc_provider.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
import '../../income_tracking/providers/income_provider.dart';
import '../../expense_tracking/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cfo_models.dart';

class CfoState {
  final List<AiChatMessage> chatHistory;
  final List<AutopilotRule> autopilotRules;
  final double overallHealthScore;
  final List<FinancialHealthScoreComponent> healthComponents;
  final DigitalTwinState digitalTwin;
  final bool isThinking;

  CfoState({
    required this.chatHistory,
    required this.autopilotRules,
    required this.overallHealthScore,
    required this.healthComponents,
    required this.digitalTwin,
    required this.isThinking,
  });

  CfoState copyWith({
    List<AiChatMessage>? chatHistory,
    List<AutopilotRule>? autopilotRules,
    double? overallHealthScore,
    List<FinancialHealthScoreComponent>? healthComponents,
    DigitalTwinState? digitalTwin,
    bool? isThinking,
  }) {
    return CfoState(
      chatHistory: chatHistory ?? this.chatHistory,
      autopilotRules: autopilotRules ?? this.autopilotRules,
      overallHealthScore: overallHealthScore ?? this.overallHealthScore,
      healthComponents: healthComponents ?? this.healthComponents,
      digitalTwin: digitalTwin ?? this.digitalTwin,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}

class CfoNotifier extends Notifier<CfoState> {
  @override
  CfoState build() {
    final user = ref.watch(authKycProvider).user;
    final bankState = ref.watch(bankAggregationProvider);
    final incomeState = ref.watch(incomeProvider);
    final expenseState = ref.watch(expenseProvider);

    final double totalAssets = bankState.totalAssets;
    final double totalLiabilities = bankState.totalLiabilities;
    final double netWorth = bankState.netWorth;
    final double monthlyInflow = incomeState.summaryData?.totalMonthlyIncome ??
        incomeState.entries.fold(0.0, (s, e) => s + e.amount);
    final double monthlyOutflow = expenseState.summaryData?.totalMonthlyExpenses ??
        expenseState.expenses.fold(0.0, (s, e) => s + e.amount);
    final double runwayMonths = monthlyOutflow > 0
        ? ((bankState.totalBankCash + bankState.totalLiquidCash) / monthlyOutflow)
        : 0.0;
    final double fiRatio = monthlyOutflow > 0 && totalAssets > 0
        ? (totalAssets / (monthlyOutflow * 12 * 25))
        : 0.0;

    final name = user.fullName.isNotEmpty
        ? user.fullName
        : (user.email.isNotEmpty ? user.email.split('@').first : 'there');

    return CfoState(
      chatHistory: [
        AiChatMessage(
          id: '1',
          sender: 'cfo',
          text:
              'Hello $name! I am your AI Personal CFO. I monitor your 7 Financial Pillars 24/7. How can I assist your financial life today?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          actionButtons: [
            'Can I buy a car worth ₹12L?',
            'Can I afford a house loan?',
            'Optimize my subscriptions',
            'Run stress test simulation',
          ],
        ),
      ],
      autopilotRules: [
        AutopilotRule(
          id: 'r1',
          name: 'Never Miss EMI',
          description:
              'Auto-reserve money in high-yield account 3 days before any loan EMI due date.',
          trigger: '3 Days Before Due Date',
          action: 'Transfer EMI Amount to Primary Bank Account',
          isActive: true,
          priority: 'P3 - Obligations',
        ),
        AutopilotRule(
          id: 'r2',
          name: 'Impulse Buy Cooling Off',
          description:
              'Hold any non-essential purchase exceeding ₹5,000 for 48 hours to evaluate impulse urge.',
          trigger: 'Debit > ₹5,000 on Discretionary Category',
          action: 'Prompt 48h Cooling Notification',
          isActive: true,
          priority: 'P1 - Survival',
        ),
        AutopilotRule(
          id: 'r3',
          name: 'Wealth Building Step-Up',
          description: 'Auto-allocate 15% of any salary increment to SIPs.',
          trigger: 'Income Growth Detected',
          action: 'Increase Mutual Fund SIPs by 15%',
          isActive: true,
          priority: 'P4 - Wealth',
        ),
      ],
      overallHealthScore: totalAssets > 0 ? 88.0 : 0.0,
      healthComponents: [
        FinancialHealthScoreComponent(
          category: 'Cash Flow',
          score: monthlyInflow > 0 ? 92 : 0,
          status: monthlyInflow > 0 ? 'Excellent' : 'Not Configured',
          icon: Icons.waterfall_chart,
          color: const Color(0xFF10B981),
        ),
        FinancialHealthScoreComponent(
          category: 'Emergency Reserve',
          score: runwayMonths >= 6 ? 85 : (runwayMonths > 0 ? 50 : 0),
          status: runwayMonths >= 6 ? 'Healthy' : (runwayMonths > 0 ? 'Building' : 'Empty'),
          icon: Icons.security,
          color: const Color(0xFF0066FF),
        ),
        FinancialHealthScoreComponent(
          category: 'Insurance Protection',
          score: bankState.insurancePolicies.isNotEmpty ? 78 : 0,
          status: bankState.insurancePolicies.isNotEmpty ? 'Active' : 'No Cover',
          icon: Icons.health_and_safety,
          color: const Color(0xFFF59E0B),
        ),
        FinancialHealthScoreComponent(
          category: 'Debt Compliance',
          score: totalLiabilities > 0 ? 94 : 100,
          status: totalLiabilities > 0 ? 'Optimal' : 'Debt Free',
          icon: Icons.credit_score,
          color: const Color(0xFF10B981),
        ),
        FinancialHealthScoreComponent(
          category: 'Investments & Wealth',
          score: bankState.investments.isNotEmpty ? 90 : 0,
          status: bankState.investments.isNotEmpty ? 'On Track' : 'Not Started',
          icon: Icons.trending_up,
          color: const Color(0xFF10B981),
        ),
        FinancialHealthScoreComponent(
          category: 'Retirement Readiness',
          score: fiRatio > 0 ? 82 : 0,
          status: fiRatio > 0 ? 'Good' : 'Not Configured',
          icon: Icons.beach_access,
          color: const Color(0xFF0066FF),
        ),
        FinancialHealthScoreComponent(
          category: 'Tax Compliance',
          score: monthlyInflow > 0 ? 95 : 0,
          status: monthlyInflow > 0 ? 'File Ready' : 'N/A',
          icon: Icons.assignment_turned_in,
          color: const Color(0xFF10B981),
        ),
      ],
      digitalTwin: DigitalTwinState(
        totalAssets: totalAssets,
        totalLiabilities: totalLiabilities,
        monthlyInflow: monthlyInflow,
        monthlyOutflow: monthlyOutflow,
        emergencyRunwayMonths: runwayMonths,
        financialIndependenceRatio: fiRatio,
        netWorth: netWorth,
      ),
      isThinking: false,
    );
  }

  void sendMessage(String text) {
    final userMsg = AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: text,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      chatHistory: [...state.chatHistory, userMsg],
      isThinking: true,
    );

    // Simulate AI CFO Response
    Future.delayed(const Duration(milliseconds: 900), () {
      String replyText = '';
      List<String>? options;

      if (text.toLowerCase().contains('car')) {
        replyText =
            '🚘 **Car Purchase Analysis (₹12 Lakhs):**\n\n'
            '• **Down Payment:** ₹2.4L (Can be funded from Surplus Cash without touching Emergency Fund).\n'
            '• **Monthly EMI:** ₹18,500 at 8.7% interest for 5 years.\n'
            '• **Impact on Cash Flow:** Your EMI ratio will increase from 16% to 28% (Well within safe threshold < 40%).\n'
            '• **Recommendation:** Approved by AI CFO! Your retirement goal timeline will be delayed by only 4 months.';
        options = [
          'Simulate Loan Options',
          'Set Car Purchase Goal',
          'Rebalance Budget',
        ];
      } else if (text.toLowerCase().contains('house')) {
        replyText =
            '🏡 **Home Loan Affordability Analysis:**\n\n'
            '• **Max Safe Loan:** ₹65 Lakhs at ₹52,000/month EMI.\n'
            '• **Down Payment Needed:** ₹15 Lakhs (Current liquid assets: ₹18.5L).\n'
            '• **AI CFO Advice:** Keep ₹5L emergency fund untouched before committing down payment.';
        options = ['Explore Home Loans', 'Talk to Financial Advisor'];
      } else if (text.toLowerCase().contains('subscription')) {
        replyText =
            '⚡ **Subscription Leakage Detected:**\n\n'
            '• Found 2 unused subscriptions (Adobe Creative Cloud & Gym membership).\n'
            '• Cancelling them saves **₹3,200/month** (₹38,400/year).\n'
            '• Auto-paused unnecessary memberships for next month.';
        options = ['Cancel Unused Apps', 'View Active Subscriptions'];
      } else {
        replyText =
            '📊 Based on your Financial Digital Twin, your net worth grew by +4.2% this quarter! All P1 survival and P2 protection layers are 100% secured.';
        options = [
          'View Digital Twin',
          'Check Health Score',
          'Modify Autopilot Rules',
        ];
      }

      final aiMsg = AiChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        sender: 'cfo',
        text: replyText,
        timestamp: DateTime.now(),
        actionButtons: options,
      );

      state = state.copyWith(
        chatHistory: [...state.chatHistory, aiMsg],
        isThinking: false,
      );
    });
  }

  void toggleRule(String ruleId) {
    final updated = state.autopilotRules.map((r) {
      if (r.id == ruleId) {
        return AutopilotRule(
          id: r.id,
          name: r.name,
          description: r.description,
          trigger: r.trigger,
          action: r.action,
          isActive: !r.isActive,
          priority: r.priority,
        );
      }
      return r;
    }).toList();
    state = state.copyWith(autopilotRules: updated);
  }
}

final cfoProvider = NotifierProvider<CfoNotifier, CfoState>(() {
  return CfoNotifier();
});
