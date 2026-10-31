import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/income_models.dart';
import '../services/income_api_service.dart';

class IncomeNotifier extends Notifier<IncomeState> {
  final IncomeApiService _apiService = IncomeApiService();

  @override
  IncomeState build() {
    // Schedule background initial fetch from the live backend API
    Future.microtask(() => loadLiveIncomeData());

    return const IncomeState(
      entries: [],
      isLoading: true,
    );
  }

/// Fetch live data from backend API (summary + entries + forecast)
  Future<void> loadLiveIncomeData({int? page, int? limit}) async {
    final targetPage = page ?? state.currentPage;
    final targetLimit = limit ?? state.pagination?.perPage ?? 20;

    state = state.copyWith(
      isSyncing: true,
      isLoading: state.entries.isEmpty,
      errorMessage: null,
      currentPage: targetPage,
    );

    try {
      final summaryFuture = _apiService.getSummary(horizon: state.forecastHorizon);
      final entriesFuture = _apiService.getEntries(
        category: state.selectedCategoryFilter != 'All' ? state.selectedCategoryFilter : null,
        type: state.selectedTypeFilter != 'All' ? state.selectedTypeFilter : null,
        bankAccount: state.selectedBankAccountFilter != 'All' ? state.selectedBankAccountFilter : null,
        dateFilter: state.selectedDateFilter != 'All' ? state.selectedDateFilter : null,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        page: targetPage,
        limit: targetLimit,
      );
      final forecastFuture = _apiService.getForecast(horizon: state.forecastHorizon);
      final detectedFuture = _apiService.getDetectedInflows();

      final results = await Future.wait([summaryFuture, entriesFuture, forecastFuture, detectedFuture]);
      final summary = results[0] as IncomeSummaryData?;
      final entriesResponse = results[1] as IncomeEntriesResponse?;
      final forecast = results[2] as IncomeForecastData?;
      final detectedInflows = results[3] as List<DetectedInflow>?;

      if (entriesResponse != null) {
        state = state.copyWith(
          entries: entriesResponse.entries,
          pagination: entriesResponse.pagination,
          summaryData: summary ?? state.summaryData,
          forecastData: forecast ?? state.forecastData,
          detectedInflows: detectedInflows ?? state.detectedInflows,
          autoTrackingEnabled: summary?.autoTrackingEnabled ?? state.autoTrackingEnabled,
          isLoading: false,
          isSyncing: false,
        );
      } else if (summary != null) {
        state = state.copyWith(
          summaryData: summary,
          forecastData: forecast ?? state.forecastData,
          detectedInflows: detectedInflows ?? state.detectedInflows,
          autoTrackingEnabled: summary.autoTrackingEnabled,
          isLoading: false,
          isSyncing: false,
        );
      } else {
        state = state.copyWith(isLoading: false, isSyncing: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSyncing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Create new income entry on live backend and update state
  Future<void> addIncome(IncomeEntry entry) async {
    // Optimistic local update
    state = state.copyWith(
      entries: [entry, ...state.entries],
      selectedCategoryFilter: 'All',
      selectedTypeFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
      isSyncing: true,
    );

    try {
      final created = await _apiService.createEntry(entry);
      if (created != null) {
        final updatedList = state.entries.map((e) => e.id == entry.id ? created : e).toList();
        final summary = await _apiService.getSummary(horizon: state.forecastHorizon);
        state = state.copyWith(
          entries: updatedList,
          summaryData: summary ?? state.summaryData,
          isSyncing: false,
        );
        return;
      }
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

  /// Update an existing income stream on live backend
  Future<void> updateIncome(IncomeEntry entry) async {
    final updated = state.entries.map((e) => e.id == entry.id ? entry : e).toList();
    state = state.copyWith(
      entries: updated,
      selectedCategoryFilter: 'All',
      selectedTypeFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
      isSyncing: true,
    );

    try {
      final remoteUpdated = await _apiService.updateEntry(entry);
      final summary = await _apiService.getSummary(horizon: state.forecastHorizon);
      if (remoteUpdated != null) {
        final syncedList = state.entries.map((e) => e.id == entry.id ? remoteUpdated : e).toList();
        state = state.copyWith(
          entries: syncedList,
          summaryData: summary ?? state.summaryData,
          isSyncing: false,
        );
        return;
      }
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

  /// Delete income stream on live backend
  Future<void> deleteIncome(String id) async {
    state = state.copyWith(
      entries: state.entries.where((e) => e.id != id).toList(),
      isSyncing: true,
    );

    try {
      final success = await _apiService.deleteEntry(id);
      if (success) {
        final summary = await _apiService.getSummary(horizon: state.forecastHorizon);
        state = state.copyWith(
          summaryData: summary ?? state.summaryData,
          isSyncing: false,
        );
        return;
      }
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

/// Reset all UI filter selections
  void resetFilters() {
    state = state.copyWith(
      selectedCategoryFilter: 'All',
      selectedTypeFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
      currentPage: 1,
    );
    loadLiveIncomeData();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
    loadLiveIncomeData();
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategoryFilter: category, currentPage: 1);
    loadLiveIncomeData();
  }

  void setTypeFilter(String type) {
    state = state.copyWith(selectedTypeFilter: type, currentPage: 1);
    loadLiveIncomeData();
  }

  void setBankAccountFilter(String bank) {
    state = state.copyWith(selectedBankAccountFilter: bank, currentPage: 1);
    loadLiveIncomeData();
  }

  void setDateFilter(String dateStr) {
    state = state.copyWith(selectedDateFilter: dateStr, currentPage: 1);
    loadLiveIncomeData();
  }

  void setPage(int page) {
    if (page == state.currentPage) return;
    loadLiveIncomeData(page: page);
  }


  /// Update forecast horizon (30D, 90D, 1Y, 5Y) and fetch live server projection
  Future<void> setForecastHorizon(String horizon) async {
    state = state.copyWith(forecastHorizon: horizon);
    try {
      final summaryFuture = _apiService.getSummary(horizon: horizon);
      final forecastFuture = _apiService.getForecast(horizon: horizon);
      final results = await Future.wait([summaryFuture, forecastFuture]);
      final summary = results[0] as IncomeSummaryData?;
      final forecast = results[1] as IncomeForecastData?;
      if (summary != null || forecast != null) {
        state = state.copyWith(
          summaryData: summary ?? state.summaryData,
          forecastData: forecast ?? state.forecastData,
        );
      }
    } catch (_) {}
  }

  /// Toggle automated SMS & bank account auto tracking on live server
  Future<void> toggleAutoTracking() async {
    final newSetting = !state.autoTrackingEnabled;
    state = state.copyWith(autoTrackingEnabled: newSetting);
    try {
      await _apiService.updateAutoTracking(newSetting);
    } catch (_) {}
  }

  /// Upload proof document to live encrypted cloud vault
  Future<IncomeProofUploadResult?> uploadProof(File file, {String? entryId, String? linkedEntryId}) async {
    return await _apiService.uploadProofDocument(
      file,
      entryId: entryId,
      linkedEntryId: linkedEntryId,
    );
  }

  /// Fetch official Section 65B voucher data for a transaction
  Future<IncomeVoucherData?> fetchVoucherDetails(String entryId) async {
    return await _apiService.getVoucherDetails(entryId);
  }

  /// Download official Section 65B voucher PDF bytes from server
  Future<Uint8List?> downloadVoucherPdf(String voucherNumberOrUrl) async {
    return await _apiService.downloadVoucherPdf(voucherNumberOrUrl);
  }

  /// Fetch a single income stream record by ID from live backend
  Future<IncomeEntry?> fetchSingleEntry(String id) async {
    return await _apiService.getSingleEntry(id);
  }

  /// Sync Account Aggregator feeds & retrieve detected inflows
  Future<IncomeSyncResult?> syncAccountAggregator() async {
    state = state.copyWith(isSyncing: true, errorMessage: null);
    try {
      final syncResult = await _apiService.syncFeeds(source: 'ALL');
      final detected = await _apiService.getDetectedInflows();
      await loadLiveIncomeData();
      state = state.copyWith(
        lastSyncResult: syncResult,
        detectedInflows: detected ?? state.detectedInflows,
        isSyncing: false,
      );
      return syncResult;
    } catch (e) {
      state = state.copyWith(isSyncing: false, errorMessage: 'Sync failed: $e');
    }
    return null;
  }

  /// Fetch detected inflows from live Account Aggregator
  Future<void> fetchDetectedInflows() async {
    try {
      final detected = await _apiService.getDetectedInflows();
      if (detected != null) {
        state = state.copyWith(detectedInflows: detected);
      }
    } catch (_) {}
  }

  /// Confirm a detected inflow stream and add to active streams
  Future<IncomeEntry?> confirmDetectedInflow(
    String detectedId, {
    required String category,
    required String frequency,
  }) async {
    state = state.copyWith(isSyncing: true);
    try {
      final created = await _apiService.confirmDetectedInflow(
        detectedId,
        category: category,
        frequency: frequency,
      );
      if (created != null) {
        final updatedDetected = state.detectedInflows.where((d) => d.detectedId != detectedId).toList();
        state = state.copyWith(
          entries: [created, ...state.entries],
          detectedInflows: updatedDetected,
          isSyncing: false,
        );
        final summary = await _apiService.getSummary(horizon: state.forecastHorizon);
        if (summary != null) {
          state = state.copyWith(summaryData: summary);
        }
        return created;
      }
    } catch (_) {}
    state = state.copyWith(isSyncing: false);
    return null;
  }

  /// Trigger Financial Autopilot (FAP) salary allocation rules
  Future<SalaryAllocationResult?> triggerSalaryAllocation({
    required String entryId,
    required double amount,
    required String salarySource,
    int emergencyFund = 20,
    int investments = 30,
    int fixedExpenses = 40,
    int discretionary = 10,
  }) async {
    return await _apiService.triggerSalaryAllocation(
      entryId: entryId,
      amount: amount,
      salarySource: salarySource,
      emergencyFund: emergencyFund,
      investments: investments,
      fixedExpenses: fixedExpenses,
      discretionary: discretionary,
    );
  }
}

final incomeProvider = NotifierProvider<IncomeNotifier, IncomeState>(() {
  return IncomeNotifier();
});
