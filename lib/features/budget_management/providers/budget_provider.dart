import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/cache_service.dart';
import '../domain/budget_models.dart';
import '../services/budget_api_service.dart';
import '../../expense_tracking/domain/expense_models.dart';

class BudgetNotifier extends Notifier<BudgetState> {
  final BudgetApiService _apiService = BudgetApiService();
  Future<void>? _inFlightFetch;

  @override
  BudgetState build() {
    // Schedule background fetch from live backend API
    Future.microtask(() => loadLiveBudgets());

    final cachedSummary = _apiService.getCachedSummary();
    final cachedBudgets = _apiService.getCachedBudgets();
    final cachedGuardrails = _apiService.getCachedGuardrails();

    final deleted = LocalCacheService().get('deleted_budget_ids');
    final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];
    final activeBudgets = (cachedBudgets ?? const <BudgetItem>[])
        .where((b) => !deletedIds.contains(b.id))
        .toList();

    return BudgetState(
      budgets: activeBudgets,
      summary: cachedSummary,
      guardrails: cachedGuardrails ?? const GuardrailSettings(),
      isLoading: false,
      isSyncing: true,
      alertEnabled: true,
    );
  }

  /// Helper for unit testing or seeding budgets directly
  void seedBudgets(List<BudgetItem> items) {
    state = state.copyWith(budgets: items, isLoading: false);
  }

  /// Load live budget summary, list, analytics, active alerts & guardrail settings
  Future<void> loadLiveBudgets() async {
    if (_inFlightFetch != null) return _inFlightFetch!;

    state = state.copyWith(
      isSyncing: true,
      isLoading: state.budgets.isEmpty && state.summary == null,
    );

    _inFlightFetch = () async {
      try {
        final summaryFuture = _apiService.getSummary().then((summary) {
          if (!ref.mounted) return null;
          if (summary != null) {
            state = state.copyWith(summary: summary);
          }
          return summary;
        });

        final deleted = LocalCacheService().get('deleted_budget_ids');
        final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];

        final budgetsFuture = _apiService.getBudgets().then((budgets) {
          if (!ref.mounted) return null;
          if (budgets != null) {
            final activeServer = budgets.where((b) => !deletedIds.contains(b.id)).toList();
            final Map<String, BudgetItem> merged = {};
            for (final loc in state.budgets) {
              if (!deletedIds.contains(loc.id)) {
                merged[loc.id] = loc;
              }
            }
            for (final s in activeServer) {
              merged[s.id] = s;
            }
            final finalBudgets = merged.values.toList();
            state = state.copyWith(budgets: finalBudgets);
            LocalCacheService().save(
              'budgets_list',
              finalBudgets.map((b) => b.toJson()).toList(),
            );
          }
          return budgets;
        });

        final alertsFuture = _apiService.getActiveAlerts().then((alerts) {
          if (!ref.mounted) return null;
          if (alerts != null) {
            state = state.copyWith(activeAlerts: alerts);
          }
          return alerts;
        });

        final analyticsFuture = _apiService.getUtilizationAnalytics().then((analytics) {
          if (!ref.mounted) return null;
          if (analytics != null) {
            state = state.copyWith(analytics: analytics);
          }
          return analytics;
        });

        final guardrailsFuture = _apiService.getGuardrailSettings().then((guardrails) {
          if (!ref.mounted) return null;
          if (guardrails != null) {
            state = state.copyWith(guardrails: guardrails);
          }
          return guardrails;
        });

        await Future.wait([
          summaryFuture,
          budgetsFuture,
          alertsFuture,
          analyticsFuture,
          guardrailsFuture,
        ]);

        if (!ref.mounted) return;

        state = state.copyWith(
          isLoading: false,
          isSyncing: false,
        );
      } catch (e) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          isSyncing: false,
          error: e.toString(),
        );
      } finally {
        _inFlightFetch = null;
      }
    }();

    return _inFlightFetch!;
  }

  /// Create a budget locally and sync to live backend
  Future<void> addBudget(BudgetItem item) async {
    final updated = [...state.budgets, item];
    state = state.copyWith(budgets: updated, isSyncing: true);
    LocalCacheService().save(
      'budgets_list',
      updated.map((b) => b.toJson()).toList(),
    );

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
        LocalCacheService().save(
          'budgets_list',
          updatedBudgets.map((b) => b.toJson()).toList(),
        );
        if (ref.mounted) loadLiveBudgets();
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
    LocalCacheService().save(
      'budgets_list',
      updated.map((b) => b.toJson()).toList(),
    );

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
        LocalCacheService().save(
          'budgets_list',
          list.map((b) => b.toJson()).toList(),
        );
        if (ref.mounted) loadLiveBudgets();
        return;
      }
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

  /// Delete a budget locally and sync to live backend
  Future<void> deleteBudget(String id) async {
    final deleted = LocalCacheService().get('deleted_budget_ids');
    final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];
    if (!deletedIds.contains(id)) {
      deletedIds.add(id);
      LocalCacheService().save('deleted_budget_ids', deletedIds);
    }
    final updated = state.budgets.where((b) => b.id != id).toList();
    state = state.copyWith(
      budgets: updated,
      isSyncing: true,
    );
    LocalCacheService().save(
      'budgets_list',
      updated.map((b) => b.toJson()).toList(),
    );

    try {
      await _apiService.deleteBudget(id);
      if (ref.mounted) await loadLiveBudgets();
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
    String? budgetId,
    required String category,
    required double amount,
    String description = '',
  }) {
    if (amount <= 0) return null;

    BudgetAlertEvent? triggeredAlert;
    final updatedBudgets = <BudgetItem>[];

    for (final budget in state.budgets) {
      final isTarget = (budgetId != null && budget.id == budgetId) ||
          (budgetId == null && _isCategoryMatch(budget.category, category));
      if (isTarget) {
        final newSpent = budget.spent + amount;

        // Determine expense date clamped within the budget's cycle range so backend persists it
        String expenseDate = DateTime.now().toIso8601String().split('T').first;
        if (budget.startDate.isNotEmpty && budget.endDate.isNotEmpty) {
          if (expenseDate.compareTo(budget.startDate) < 0) {
            expenseDate = budget.startDate;
          } else if (expenseDate.compareTo(budget.endDate) > 0) {
            expenseDate = budget.endDate;
          }
        }

        final newTx = EligibleBudgetTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          amount: amount,
          date: expenseDate,
          category: budget.category,
          description: description.isNotEmpty ? description : budget.category,
          paymentMode: 'UPI',
        );
        final updatedTxs = [newTx, ...budget.eligibleTransactions];

        final updatedBudget = budget.copyWith(
          spent: newSpent,
          eligibleTransactions: updatedTxs,
          recentTransactionsCount: updatedTxs.length,
        );

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
                date: expenseDate,
                paymentMode: 'UPI',
              )
              .then((_) { if (ref.mounted) loadLiveBudgets(); })
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
    LocalCacheService().save(
      'budgets_list',
      updatedBudgets.map((b) => b.toJson()).toList(),
    );

    return triggeredAlert;
  }

  /// Reverts/deducts an expense from relevant budgets when an expense is deleted or reduced.
  void revertExpense({
    String? budgetId,
    required String category,
    required double amount,
  }) {
    if (amount <= 0) return;

    final updatedBudgets = <BudgetItem>[];

    for (final budget in state.budgets) {
      final isTarget = (budgetId != null && budget.id == budgetId) ||
          (budgetId == null && _isCategoryMatch(budget.category, category));
      if (isTarget) {
        final newSpent = (budget.spent - amount).clamp(0.0, double.infinity);
        final updatedBudget = budget.copyWith(
          spent: newSpent,
        );
        updatedBudgets.add(updatedBudget);
      } else {
        updatedBudgets.add(budget);
      }
    }

    state = state.copyWith(budgets: updatedBudgets);
    LocalCacheService().save(
      'budgets_list',
      updatedBudgets.map((b) => b.toJson()).toList(),
    );
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
    LocalCacheService().save(
      'budgets_list',
      updatedBudgets.map((b) => b.toJson()).toList(),
    );
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
