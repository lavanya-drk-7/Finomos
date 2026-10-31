import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/expense_models.dart';
import '../services/expense_api_service.dart';

class ExpenseNotifier extends Notifier<ExpenseState> {
  final ExpenseApiService _apiService = ExpenseApiService();

  @override
  ExpenseState build() {
    // Schedule background fetch from live backend API
    Future.microtask(() => loadLiveExpenses());

    return const ExpenseState(
      expenses: [],
      isLoading: true,
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

      final entriesRes = results[0] as ExpenseEntriesResponse?;
      final summary = results[1] as ExpenseSummaryData?;
      final categories = results[2] as List<ExpenseCategoryBreakdown>?;
      final priorities = results[3] as ExpensePriorityBreakdown?;
      final detected = results[4] as List<DetectedExpense>?;

      state = state.copyWith(
        expenses: entriesRes != null ? entriesRes.expenses : state.expenses,
        pagination: entriesRes?.pagination ?? state.pagination,
        summaryData: summary ?? state.summaryData,
        categoryBreakdowns: categories ?? state.categoryBreakdowns,
        priorityBreakdown: priorities ?? state.priorityBreakdown,
        detectedExpenses: detected ?? state.detectedExpenses,
        isLoading: false,
        isSyncing: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isSyncing: false, errorMessage: e.toString());
    }
  }

  Future<void> setPage(int page) async {
    await loadLiveExpenses(page: page);
  }

  Future<void> addExpense(ExpenseEntry entry) async {
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

  Future<void> deleteExpense(String id) async {
    state = state.copyWith(
      expenses: state.expenses.where((e) => e.id != id).toList(),
      isSyncing: true,
    );
    try {
      await _apiService.deleteExpense(id);
      loadLiveExpenses();
    } catch (_) {}
    state = state.copyWith(isSyncing: false);
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
  Future<void> confirmDetectedExpense(String detectionId) async {
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

    state = state.copyWith(
      detectedExpenses: state.detectedExpenses.where((e) => e.detectionId != detectionId).toList(),
      isSyncing: true,
    );

    try {
      final confirmed = await _apiService.confirmDetectedExpense(detectionId);
      if (confirmed != null) {
        state = state.copyWith(
          expenses: [confirmed, ...state.expenses],
          isSyncing: false,
        );
        loadLiveExpenses();
        return;
      }
    } catch (_) {}

    if (itemToConfirm.detectionId.isNotEmpty) {
      final fallbackEntry = ExpenseEntry(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        description: itemToConfirm.description,
        category: itemToConfirm.suggestedCategory,
        priority: itemToConfirm.suggestedPriority,
        amount: itemToConfirm.amount,
        date: itemToConfirm.date,
        paymentMode: itemToConfirm.paymentMode,
        bankAccount: itemToConfirm.bankAccount,
        merchant: itemToConfirm.merchant,
      );
      state = state.copyWith(
        expenses: [fallbackEntry, ...state.expenses],
        isSyncing: false,
      );
    } else {
      state = state.copyWith(isSyncing: false);
    }
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
