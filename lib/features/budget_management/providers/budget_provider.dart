import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/budget_models.dart';
import '../services/budget_api_service.dart';
import '../../expense_tracking/domain/expense_models.dart';

class BudgetNotifier extends Notifier<BudgetState> {
  final BudgetApiService _apiService = BudgetApiService();

  @override
  BudgetState build() {
    // Schedule background fetch from live backend API
    Future.microtask(() => loadLiveBudgets());

    return const BudgetState(
      budgets: [
        BudgetItem(
          id: 'b_food',
          name: 'Food & Dining',
          type: 'Category-wise Budget',
          category: 'Food & Dining',
          amount: 10000.0,
          spent: 0.0,
          startDate: '01/10/2026',
          endDate: '31/10/2026',
          period: 'October 2026',
        ),
        BudgetItem(
          id: 'b_groceries',
          name: 'Groceries',
          type: 'Category-wise Budget',
          category: 'Groceries',
          amount: 8000.0,
          spent: 0.0,
          startDate: '01/10/2026',
          endDate: '31/10/2026',
          period: 'October 2026',
        ),
        BudgetItem(
          id: 'b_travel',
          name: 'Transportation & Travel',
          type: 'Category-wise Budget',
          category: 'Transportation',
          amount: 5000.0,
          spent: 2000.0,
          startDate: '01/10/2026',
          endDate: '31/10/2026',
          period: 'October 2026',
        ),
        BudgetItem(
          id: 'b_shopping',
          name: 'Shopping & Retail',
          type: 'Category-wise Budget',
          category: 'Shopping',
          amount: 6000.0,
          spent: 3450.0,
          startDate: '01/10/2026',
          endDate: '31/10/2026',
          period: 'October 2026',
        ),
        BudgetItem(
          id: 'b_utilities',
          name: 'Utilities & Bills',
          type: 'Category-wise Budget',
          category: 'Utilities',
          amount: 4000.0,
          spent: 2350.0,
          startDate: '01/10/2026',
          endDate: '31/10/2026',
          period: 'October 2026',
        ),
        BudgetItem(
          id: 'b_ent',
          name: 'Entertainment',
          type: 'Category-wise Budget',
          category: 'Entertainment',
          amount: 3000.0,
          spent: 1199.0,
          startDate: '01/10/2026',
          endDate: '31/10/2026',
          period: 'October 2026',
        ),
      ],
      alertEnabled: true,
    );
  }

  /// Load live budget summary, list, analytics, active alerts & guardrail settings
  Future<void> loadLiveBudgets() async {
    state = state.copyWith(isLoading: true);
    try {
      final summaryFuture = _apiService.getSummary();
      final budgetsFuture = _apiService.getBudgets();
      final alertsFuture = _apiService.getActiveAlerts();
      final analyticsFuture = _apiService.getUtilizationAnalytics();
      final guardrailsFuture = _apiService.getGuardrailSettings();

      final results = await Future.wait([
        summaryFuture,
        budgetsFuture,
        alertsFuture,
        analyticsFuture,
        guardrailsFuture,
      ]);

      final summary = results[0] as BudgetSummaryData?;
      final liveBudgets = results[1] as List<BudgetItem>?;
      final activeAlerts = results[2] as List<ActiveBudgetAlert>?;
      final analytics = results[3] as BudgetAnalyticsResponse?;
      final guardrails = results[4] as GuardrailSettings?;

      state = state.copyWith(
        budgets: (liveBudgets != null && liveBudgets.isNotEmpty)
            ? liveBudgets
            : state.budgets,
        summary: summary ?? state.summary,
        activeAlerts: activeAlerts ?? state.activeAlerts,
        analytics: analytics ?? state.analytics,
        guardrails: guardrails ?? state.guardrails,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a budget locally and sync to live backend
  Future<void> addBudget(BudgetItem item) async {
    state = state.copyWith(budgets: [...state.budgets, item], isSyncing: true);

    try {
      final created = await _apiService.createBudget(
        name: item.name,
        category: item.category,
        type: item.type,
        amount: item.amount,
        period: item.period,
        alertThreshold: item.alertThreshold,
        alertsEnabled: item.alertsEnabled,
      );

      if (created != null) {
        final updatedBudgets = state.budgets
            .map((b) => b.id == item.id ? created : b)
            .toList();
        state = state.copyWith(budgets: updatedBudgets, isSyncing: false);
        loadLiveBudgets();
        return;
      }
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

  /// Update a budget locally and sync to live backend
  Future<void> updateBudget(BudgetItem item) async {
    final updated = state.budgets
        .map((b) => b.id == item.id ? item : b)
        .toList();
    state = state.copyWith(budgets: updated, isSyncing: true);

    try {
      final res = await _apiService.updateBudget(
        id: item.id,
        name: item.name,
        category: item.category,
        amount: item.amount,
        period: item.period,
        alertThreshold: item.alertThreshold,
        alertsEnabled: item.alertsEnabled,
      );

      if (res != null) {
        final list = state.budgets
            .map((b) => b.id == item.id ? res : b)
            .toList();
        state = state.copyWith(budgets: list, isSyncing: false);
        loadLiveBudgets();
        return;
      }
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

  /// Delete a budget locally and sync to live backend
  Future<void> deleteBudget(String id) async {
    state = state.copyWith(
      budgets: state.budgets.where((b) => b.id != id).toList(),
      isSyncing: true,
    );

    try {
      await _apiService.deleteBudget(id);
      loadLiveBudgets();
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

  void toggleAlert(bool val) {
    state = state.copyWith(alertEnabled: val);
  }

  void dismissBannerAlert() {
    state = state.copyWith(clearActiveBanner: true);
  }

  /// Dismiss an active live alert from server
  Future<void> dismissLiveAlert(String alertId) async {
    final updatedAlerts = state.activeAlerts.map((a) {
      if (a.alertId == alertId) return a.copyWith(isDismissed: true);
      return a;
    }).toList();

    state = state.copyWith(activeAlerts: updatedAlerts);
    try {
      await _apiService.dismissAlert(alertId);
    } catch (_) {}
  }

  /// Update live guardrail settings
  Future<void> updateGuardrails(GuardrailSettings settings) async {
    state = state.copyWith(guardrails: settings);
    try {
      final updated = await _apiService.updateGuardrailSettings(settings);
      if (updated != null) {
        state = state.copyWith(guardrails: updated);
      }
    } catch (_) {}
  }

  /// Trigger recalculate all budgets on backend
  Future<void> triggerRecalculate() async {
    state = state.copyWith(isSyncing: true);
    try {
      final liveBudgets = await _apiService.recalculateBudgets();
      if (liveBudgets != null && liveBudgets.isNotEmpty) {
        state = state.copyWith(budgets: liveBudgets);
      }
      loadLiveBudgets();
    } catch (_) {}
    state = state.copyWith(isSyncing: false);
  }

  /// Trigger period rollover on backend
  Future<void> triggerRollover({
    required String fromMonth,
    required String toMonth,
    bool rolloverSurplus = true,
  }) async {
    state = state.copyWith(isSyncing: true);
    try {
      final liveBudgets = await _apiService.rolloverBudgets(
        fromMonth: fromMonth,
        toMonth: toMonth,
        rolloverSurplus: rolloverSurplus,
      );
      if (liveBudgets != null && liveBudgets.isNotEmpty) {
        state = state.copyWith(budgets: liveBudgets);
      }
      loadLiveBudgets();
    } catch (_) {}
    state = state.copyWith(isSyncing: false);
  }

  /// Evaluates an expense against all relevant budgets.
  /// Deducts eligible amounts and triggers budget alerts if thresholds (80%, 100%, >100%) are crossed.
  BudgetAlertEvent? applyExpense({
    required String category,
    required double amount,
    String description = '',
  }) {
    if (amount <= 0) return null;

    BudgetAlertEvent? triggeredAlert;
    final updatedBudgets = <BudgetItem>[];

    for (final budget in state.budgets) {
      if (_isCategoryMatch(budget.category, category)) {
        final newSpent = budget.spent + amount;
        final updatedBudget = budget.copyWith(spent: newSpent);

        // Check threshold crossing
        final oldLevel = budget.currentAlertLevel;
        final newLevel = updatedBudget.currentAlertLevel;

        if (state.alertEnabled &&
            newLevel != oldLevel &&
            newLevel != BudgetAlertLevel.none) {
          if (newLevel == BudgetAlertLevel.exceeded) {
            final overspent = updatedBudget.overspentAmount;
            final util = updatedBudget.utilizationPercentage;
            triggeredAlert = BudgetAlertEvent(
              budget: updatedBudget,
              level: BudgetAlertLevel.exceeded,
              title: 'Budget Exceeded!',
              message:
                  'You have spent ₹${newSpent.toStringAsFixed(0)} on ${budget.category} against your monthly budget of ₹${budget.amount.toStringAsFixed(0)}. You exceeded your budget by ₹${overspent.toStringAsFixed(0)}.',
              overspentAmount: overspent,
              utilizationPercentage: util,
            );
          } else if (newLevel == BudgetAlertLevel.limitReached100) {
            triggeredAlert = BudgetAlertEvent(
              budget: updatedBudget,
              level: BudgetAlertLevel.limitReached100,
              title: 'Budget Limit Reached',
              message:
                  '100% of your ${budget.category} budget (₹${budget.amount.toStringAsFixed(0)}) has been utilized.',
              overspentAmount: 0.0,
              utilizationPercentage: 100.0,
            );
          } else if (newLevel == BudgetAlertLevel.approaching80) {
            triggeredAlert = BudgetAlertEvent(
              budget: updatedBudget,
              level: BudgetAlertLevel.approaching80,
              title: 'Budget Warning: 80% Used',
              message:
                  'You have utilized ${updatedBudget.utilizationPercentage.toStringAsFixed(0)}% of your ${budget.category} budget (₹${newSpent.toStringAsFixed(0)} of ₹${budget.amount.toStringAsFixed(0)}).',
              overspentAmount: 0.0,
              utilizationPercentage: updatedBudget.utilizationPercentage,
            );
          }
        }

        updatedBudgets.add(
          updatedBudget.copyWith(lastAlertTriggered: newLevel),
        );

        // Deduct from live backend asynchronously if budget has a live id
        if (!budget.id.startsWith('b_') && !budget.id.startsWith('budget_')) {
          _apiService
              .deductExpense(
                budgetId: budget.id,
                amount: amount,
                description: description.isNotEmpty
                    ? description
                    : 'Expense on ${budget.category}',
                category: category,
                date: DateTime.now().toIso8601String().split('T').first,
                paymentMode: 'UPI',
              )
              .then((_) => loadLiveBudgets())
              .catchError((_) {});
        }
      } else {
        updatedBudgets.add(budget);
      }
    }

    state = state.copyWith(
      budgets: updatedBudgets,
      activeBannerAlert: triggeredAlert ?? state.activeBannerAlert,
    );

    return triggeredAlert;
  }

  /// Recalculates all budget category totals directly from confirmed expenses list.
  void recalculateFromExpenses(List<ExpenseEntry> expenses) {
    final updatedBudgets = state.budgets.map((budget) {
      final totalEligible = expenses
          .where((e) => _isCategoryMatch(budget.category, e.category))
          .fold(0.0, (sum, e) => sum + e.amount);

      return budget.copyWith(spent: totalEligible);
    }).toList();

    state = state.copyWith(budgets: updatedBudgets);
  }

  /// Flexible category matcher (e.g. 'Food & Dining' matches 'Food', 'Groceries' matches 'Groceries')
  bool _isCategoryMatch(String budgetCategory, String expenseCategory) {
    final b = budgetCategory.toLowerCase().trim();
    final e = expenseCategory.toLowerCase().trim();

    if (b == e) return true;
    if (b.contains('food') && e == 'food') return true;
    if (b == 'food' && e.contains('food')) return true;
    if (b.contains('travel') && e.contains('transport')) return true;
    if (b.contains('transport') && e.contains('travel')) return true;
    if (b.contains('utilit') && e.contains('bill')) return true;
    if (b.contains('bill') && e.contains('utilit')) return true;
    if (b.contains('housing') && e.contains('rent')) return true;
    if (b.contains('rent') && e.contains('housing')) return true;

    return false;
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(() {
  return BudgetNotifier();
});
