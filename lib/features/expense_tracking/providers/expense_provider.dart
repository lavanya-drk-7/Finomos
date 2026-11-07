import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/cache_service.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
import '../../budget_management/providers/budget_provider.dart';
import '../domain/expense_models.dart';
import '../services/expense_api_service.dart';

class ExpenseNotifier extends Notifier<ExpenseState> {
  final ExpenseApiService _apiService = ExpenseApiService();

  @override
  ExpenseState build() {
    Future.microtask(() => loadLiveExpenses());

    final deleted = LocalCacheService().get('deleted_expense_ids');
    final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];

    final cached = LocalCacheService().get('expenses_entries');
    List<ExpenseEntry>? cachedEntries;
    if (cached is Map && cached['entries'] is List) {
      cachedEntries = (cached['entries'] as List)
          .whereType<Map>()
          .map((e) => ExpenseEntry.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => !deletedIds.contains(e.id))
          .toList();
    } else if (cached is List) {
      cachedEntries = cached
          .whereType<Map>()
          .map((e) => ExpenseEntry.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => !deletedIds.contains(e.id))
          .toList();
    }

    return ExpenseState(
      expenses: cachedEntries ?? const [],
      isLoading: false,
    );
  }

  /// Fetch live expenses and analytics from live backend APIs
  Future<void> loadLiveExpenses({
    int page = 1,
    String? search,
    String? category,
    String? priority,
    String? bankAccount,
    String? dateFilter,
    String? month,
  }) async {
    if (!ref.mounted) return;
    state = state.copyWith(isSyncing: true, isLoading: state.expenses.isEmpty);
    try {
      final results = await Future.wait([
        _apiService.getEntries(
          search: search ?? (state.searchQuery.isNotEmpty ? state.searchQuery : null),
          category: category ?? state.selectedCategoryFilter,
          priority: priority ?? state.selectedPriorityFilter,
          bankAccount: bankAccount ?? state.selectedBankAccountFilter,
          dateFilter: dateFilter ?? state.selectedDateFilter,
          page: page,
        ),
        _apiService.getSummary(month: month),
        _apiService.getCategoryBreakdown(),
        _apiService.getPriorityBreakdown(),
        _apiService.getDetectedExpenses(),
      ]);

      if (!ref.mounted) return;

      final entriesRes = results[0] as ExpenseEntriesResponse?;
      final summary = results[1] as ExpenseSummaryData?;
      final categories = results[2] as List<ExpenseCategoryBreakdown>?;
      final priorities = results[3] as ExpensePriorityBreakdown?;
      final detected = results[4] as List<DetectedExpense>?;

      final deleted = LocalCacheService().get('deleted_expense_ids');
      final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];
      final activeExpenses = (entriesRes != null ? entriesRes.expenses : state.expenses)
          .where((e) => !deletedIds.contains(e.id))
          .toList();

      state = state.copyWith(
        expenses: activeExpenses,
        pagination: entriesRes?.pagination ?? state.pagination,
        summaryData: summary ?? state.summaryData,
        categoryBreakdowns: categories ?? state.categoryBreakdowns,
        priorityBreakdown: priorities ?? state.priorityBreakdown,
        detectedExpenses: detected ?? state.detectedExpenses,
        isLoading: false,
        isSyncing: false,
      );
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false, isSyncing: false, errorMessage: e.toString());
      }
    }
  }

  Future<void> setPage(int page) async {
    await loadLiveExpenses(page: page);
  }

  Future<void> addExpense(ExpenseEntry entry, {bool applyToBudget = true}) async {
    try {
      ref.read(bankAggregationProvider.notifier).adjustAccountBalance(
        bankAccount: entry.bankAccount,
        delta: -entry.amount,
      );
    } catch (_) {}
    if (applyToBudget) {
      try {
        ref.read(budgetProvider.notifier).applyExpense(
          category: entry.category,
          amount: entry.amount,
          description: entry.description,
        );
      } catch (_) {}
    }

    final deleted = LocalCacheService().get('deleted_expense_ids');
    final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];
    if (deletedIds.contains(entry.id)) {
      deletedIds.remove(entry.id);
      LocalCacheService().save('deleted_expense_ids', deletedIds);
    }

    state = state.copyWith(
      expenses: [entry, ...state.expenses],
      selectedCategoryFilter: 'All',
      selectedPriorityFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
      isSyncing: true,
    );

    try {
      final created = await _apiService.createExpense(entry);
      if (created != null) {
        final updatedList = state.expenses.map((e) => e.id == entry.id ? created : e).toList();
        state = state.copyWith(
          expenses: updatedList,
          isSyncing: false,
        );
        loadLiveExpenses();
        return;
      }
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

  Future<void> updateExpense(ExpenseEntry entry) async {
    final updated = state.expenses.map((e) => e.id == entry.id ? entry : e).toList();
    state = state.copyWith(
      expenses: updated,
      isSyncing: true,
    );

    try {
      final updatedFromBackend = await _apiService.updateExpense(entry.id, entry);
      if (updatedFromBackend != null) {
        state = state.copyWith(
          expenses: state.expenses.map((e) => e.id == entry.id ? updatedFromBackend : e).toList(),
          isSyncing: false,
        );
        loadLiveExpenses();
        return;
      }
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

  Future<void> deleteExpense(String id, {bool revertFromBudget = true}) async {
    final entry = state.expenses.firstWhere(
      (e) => e.id == id,
      orElse: () => const ExpenseEntry(id: '', description: '', category: '', amount: 0, date: '', paymentMode: ''),
    );
    if (entry.amount > 0) {
      try {
        ref.read(bankAggregationProvider.notifier).adjustAccountBalance(
          bankAccount: entry.bankAccount,
          delta: entry.amount,
        );
      } catch (_) {}
      if (revertFromBudget) {
        try {
          ref.read(budgetProvider.notifier).revertExpense(
            category: entry.category,
            amount: entry.amount,
          );
        } catch (_) {}
      }
    }
    final deleted = LocalCacheService().get('deleted_expense_ids');
    final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];
    if (!deletedIds.contains(id)) {
      deletedIds.add(id);
      LocalCacheService().save('deleted_expense_ids', deletedIds);
    }

    state = state.copyWith(
      expenses: state.expenses.where((e) => e.id != id).toList(),
      isSyncing: true,
    );
    try {
      await _apiService.deleteExpense(id);
      if (ref.mounted) loadLiveExpenses();
    } catch (_) {}
    if (ref.mounted) state = state.copyWith(isSyncing: false);
  }

  Future<void> updateExpensePaymentStatus(String id, String status) async {
    final updated = state.expenses.map((e) {
      if (e.id == id) {
        return e.copyWith(paymentStatus: status);
      }
      return e;
    }).toList();
    state = state.copyWith(expenses: updated);
    try {
      await _apiService.updateExpense(id, ExpenseEntry(
        id: id,
        description: '',
        category: '',
        amount: 0,
        date: '',
        paymentMode: '',
        paymentStatus: status,
      ));
    } catch (_) {}
  }

  void resetFilters() {
    state = state.copyWith(
      selectedCategoryFilter: 'All',
      selectedPriorityFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategoryFilter: category);
  }

  void setPriorityFilter(String priority) {
    state = state.copyWith(selectedPriorityFilter: priority);
  }

  void setBankAccountFilter(String bank) {
    state = state.copyWith(selectedBankAccountFilter: bank);
  }

  void setDateFilter(String dateStr) {
    state = state.copyWith(selectedDateFilter: dateStr);
  }

  /// Confirm an auto-detected expense from live backend feed
  Future<ExpenseEntry?> confirmDetectedExpense(String detectionId, {String? category, String? priority}) async {
    final itemToConfirm = state.detectedExpenses.firstWhere(
      (e) => e.detectionId == detectionId,
      orElse: () => const DetectedExpense(
        detectionId: '',
        description: '',
        suggestedCategory: 'Other',
        suggestedPriority: 'P1 - Survival',
        amount: 0,
        date: '',
      ),
    );

    final effCat = (category != null && category.isNotEmpty)
        ? category
        : (itemToConfirm.suggestedCategory.isNotEmpty ? itemToConfirm.suggestedCategory : 'Food & Dining');
    final effPri = (priority != null && priority.isNotEmpty)
        ? priority
        : (itemToConfirm.suggestedPriority.isNotEmpty ? itemToConfirm.suggestedPriority : 'P4 - Discretionary');

    state = state.copyWith(
      detectedExpenses: state.detectedExpenses.where((e) => e.detectionId != detectionId).toList(),
      isSyncing: true,
    );

    try {
      final confirmed = await _apiService.confirmDetectedExpense(detectionId);
      if (confirmed != null) {
        try {
          ref.read(bankAggregationProvider.notifier).adjustAccountBalance(
            bankAccount: confirmed.bankAccount,
            delta: -confirmed.amount,
          );
        } catch (_) {}
        try {
          ref.read(budgetProvider.notifier).applyExpense(
            category: confirmed.category,
            amount: confirmed.amount,
            description: confirmed.description,
          );
        } catch (_) {}
        state = state.copyWith(
          expenses: [confirmed, ...state.expenses.where((e) => e.id != confirmed.id)],
          isSyncing: false,
        );
        loadLiveExpenses();
        return confirmed;
      }
    } catch (_) {}

    if (itemToConfirm.detectionId.isNotEmpty) {
      final fallbackEntry = ExpenseEntry(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        description: itemToConfirm.description.isNotEmpty
            ? itemToConfirm.description
            : (itemToConfirm.merchant.isNotEmpty ? itemToConfirm.merchant : 'Expense'),
        category: effCat,
        priority: effPri,
        amount: itemToConfirm.amount,
        date: itemToConfirm.date.isNotEmpty ? itemToConfirm.date : 'Today',
        paymentMode: itemToConfirm.paymentMode.isNotEmpty ? itemToConfirm.paymentMode : 'UPI',
        bankAccount: itemToConfirm.bankAccount.isNotEmpty ? itemToConfirm.bankAccount : 'Other / Cash',
        merchant: itemToConfirm.merchant,
      );
      try {
        ref.read(bankAggregationProvider.notifier).adjustAccountBalance(
          bankAccount: fallbackEntry.bankAccount,
          delta: -fallbackEntry.amount,
        );
      } catch (_) {}
      try {
        ref.read(budgetProvider.notifier).applyExpense(
          category: fallbackEntry.category,
          amount: fallbackEntry.amount,
          description: fallbackEntry.description,
        );
      } catch (_) {}
      state = state.copyWith(
        expenses: [fallbackEntry, ...state.expenses.where((e) => e.id != fallbackEntry.id)],
        isSyncing: false,
      );
      return fallbackEntry;
    } else {
      state = state.copyWith(isSyncing: false);
      return null;
    }
  }

  /// Prepend an auto-detected or SMS-detected expense to the pending banner
  void addDetectedExpense(DetectedExpense exp) {
    final exists = state.detectedExpenses.any(
      (e) => e.detectionId == exp.detectionId,
    );
    if (!exists) {
      state = state.copyWith(
        detectedExpenses: [exp, ...state.detectedExpenses],
      );
    }
  }

  /// Dismiss / Delete a detected expense from the banner without adding to expenses
  void dismissDetectedExpense(String detectionId) {
    final cleanId = detectionId.trim();
    final updated = state.detectedExpenses
        .where((e) => e.detectionId.trim() != cleanId)
        .toList();
    state = state.copyWith(detectedExpenses: updated);
    _apiService.dismissDetectedExpense(cleanId);
  }

  /// Directly approve and convert a detected expense into an active expense record
  Future<ExpenseEntry?> approveDetectedExpense(
    DetectedExpense exp, {
    String? category,
    String? priority,
  }) async {
    final effectiveCategory = (category != null && category.isNotEmpty)
        ? category
        : (exp.suggestedCategory.isNotEmpty ? exp.suggestedCategory : 'Food & Dining');
    final effectivePriority = (priority != null && priority.isNotEmpty)
        ? priority
        : (exp.suggestedPriority.isNotEmpty ? exp.suggestedPriority : 'P4 - Discretionary');

    return await confirmDetectedExpense(
      exp.detectionId,
      category: effectiveCategory,
      priority: effectivePriority,
    );
  }

  /// Upload receipt proof file to live backend
  /// POST /api/v1/expenses/receipt-upload
  Future<ExpenseReceiptUploadResult?> uploadReceipt(File file) async {
    return await _apiService.uploadReceipt(file);
  }

  /// Fetch full expense invoice details from live backend
  /// GET /api/v1/expenses/entries/:id/invoice
  Future<ExpenseInvoiceDetails?> getInvoice(String id) async {
    return await _apiService.getInvoice(id);
  }
}

final expenseProvider = NotifierProvider<ExpenseNotifier, ExpenseState>(() {
  return ExpenseNotifier();
});
