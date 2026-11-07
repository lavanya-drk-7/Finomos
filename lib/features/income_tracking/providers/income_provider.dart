import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/cache_service.dart';
import '../domain/income_models.dart';
import '../services/income_api_service.dart';

class IncomeNotifier extends Notifier<IncomeState> {
  final IncomeApiService _apiService = IncomeApiService();
  Future<void>? _inFlightFetch;

  @override
  IncomeState build() {
    final cachedSummary = _apiService.getCachedSummary();
    final cachedEntries = _apiService.getCachedEntries();

    // Schedule background initial fetch from the live backend API
    Future.microtask(() => loadLiveIncomeData());

    final deleted = LocalCacheService().get('deleted_income_ids');
    final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];
    final activeEntries = (cachedEntries?.entries ?? const <IncomeEntry>[])
        .where((e) => !deletedIds.contains(e.id))
        .toList();

    return IncomeState(
      entries: activeEntries,
      pagination: cachedEntries?.pagination,
      summaryData: cachedSummary,
      isLoading: false,
      isSyncing: true,
    );
  }

  /// Fetch live data from backend API with deduplication & progressive updates
  Future<void> loadLiveIncomeData({int? page, int? limit, bool force = false}) {
    if (!force && _inFlightFetch != null) return _inFlightFetch!;
    _inFlightFetch = _executeLoadLiveIncome(page: page, limit: limit)
        .whenComplete(() => _inFlightFetch = null);
    return _inFlightFetch!;
  }

  Future<void> _executeLoadLiveIncome({int? page, int? limit}) async {
    final targetPage = page ?? state.currentPage;
    final targetLimit = limit ?? state.pagination?.perPage ?? 20;

    state = state.copyWith(
      isSyncing: true,
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

      // Progressive update 1: as soon as summary arrives, update state instantly
      summaryFuture.then((summary) {
        if (!ref.mounted) return null;
        if (summary != null) {
          state = state.copyWith(
            summaryData: summary,
            autoTrackingEnabled: summary.autoTrackingEnabled,
          );
        }
      });

      // Progressive update 2: as soon as entries arrive, update state instantly
      final deleted = LocalCacheService().get('deleted_income_ids');
      final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];

      entriesFuture.then((entriesRes) {
        if (!ref.mounted) return null;
        if (entriesRes != null) {
          final serverList = entriesRes.entries.where((e) => !deletedIds.contains(e.id)).toList();
          final localUnsynced = state.entries.where((e) => e.id.startsWith('inc_') && !serverList.any((s) => s.id == e.id)).toList();
          final combined = [...localUnsynced, ...serverList];
          state = state.copyWith(
            entries: combined,
            pagination: entriesRes.pagination,
            isLoading: false,
          );
          LocalCacheService().save(
            'income_entries',
            {'entries': combined.map((e) => e.toJson()).toList()},
          );
        }
      });

      final results = await Future.wait([summaryFuture, entriesFuture, forecastFuture, detectedFuture]);
      if (!ref.mounted) return;
      final summary = results[0] as IncomeSummaryData?;
      final entriesResponse = results[1] as IncomeEntriesResponse?;
      final forecast = results[2] as IncomeForecastData?;
      final detectedInflows = results[3] as List<DetectedInflow>?;

      final activeInflows = detectedInflows ?? state.detectedInflows;

      final activeEntries = entriesResponse != null
          ? [
              ...state.entries.where((e) => e.id.startsWith('inc_') && !entriesResponse.entries.any((s) => s.id == e.id)),
              ...entriesResponse.entries.where((e) => !deletedIds.contains(e.id)),
            ]
          : state.entries;

      state = state.copyWith(
        entries: activeEntries,
        pagination: entriesResponse?.pagination ?? state.pagination,
        summaryData: summary ?? state.summaryData,
        forecastData: forecast ?? state.forecastData,
        detectedInflows: activeInflows,
        autoTrackingEnabled: summary?.autoTrackingEnabled ?? state.autoTrackingEnabled,
        isLoading: false,
        isSyncing: false,
      );

      if (entriesResponse != null) {
        LocalCacheService().save('income_entries', {
          'entries': activeEntries.map((e) => e.toJson()).toList(),
          'pagination': entriesResponse.pagination.toJson(),
        });
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        isSyncing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Create new income entry on live backend and update state
  Future<void> addIncome(IncomeEntry entry) async {
    try {
      ref.read(bankAggregationProvider.notifier).adjustAccountBalance(
        bankAccount: entry.bankAccount,
        delta: entry.amount,
      );
    } catch (_) {}

    final deleted = LocalCacheService().get('deleted_income_ids');
    final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];
    if (deletedIds.contains(entry.id)) {
      deletedIds.remove(entry.id);
      LocalCacheService().save('deleted_income_ids', deletedIds);
    }
    // Optimistic local update
    final updated = [entry, ...state.entries];
    state = state.copyWith(
      entries: updated,
      selectedCategoryFilter: 'All',
      selectedTypeFilter: 'All',
      selectedBankAccountFilter: 'All',
      selectedDateFilter: 'All',
      searchQuery: '',
      isSyncing: true,
    );
    LocalCacheService().save('income_entries', {
      'entries': updated.map((e) => e.toJson()).toList(),
      if (state.pagination != null) 'pagination': state.pagination!.toJson(),
    });

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
        LocalCacheService().save('income_entries', {
          'entries': updatedList.map((e) => e.toJson()).toList(),
          if (state.pagination != null) 'pagination': state.pagination!.toJson(),
        });
        return;
      }
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

  /// Update an existing income stream on live backend
  Future<void> updateIncome(IncomeEntry entry) async {
    final oldEntry = state.entries.firstWhere(
      (e) => e.id == entry.id,
      orElse: () => const IncomeEntry(id: '', source: '', category: '', amount: 0, date: '', frequency: 'Monthly'),
    );
    final diff = entry.amount - oldEntry.amount;
    if (diff != 0) {
      try {
        ref.read(bankAggregationProvider.notifier).adjustAccountBalance(
          bankAccount: entry.bankAccount,
          delta: diff,
        );
      } catch (_) {}
    }

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
    LocalCacheService().save('income_entries', {
      'entries': updated.map((e) => e.toJson()).toList(),
      if (state.pagination != null) 'pagination': state.pagination!.toJson(),
    });

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
        LocalCacheService().save('income_entries', {
          'entries': syncedList.map((e) => e.toJson()).toList(),
          if (state.pagination != null) 'pagination': state.pagination!.toJson(),
        });
        return;
      }
    } catch (_) {}

    state = state.copyWith(isSyncing: false);
  }

  /// Delete income stream on live backend
  Future<void> deleteIncome(String id) async {
    final entryToDelete = state.entries.firstWhere(
      (e) => e.id == id,
      orElse: () => const IncomeEntry(id: '', source: '', category: '', amount: 0, date: '', frequency: 'Monthly'),
    );
    if (entryToDelete.amount > 0) {
      try {
        ref.read(bankAggregationProvider.notifier).adjustAccountBalance(
          bankAccount: entryToDelete.bankAccount,
          delta: -entryToDelete.amount,
        );
      } catch (_) {}
    }

    final deleted = LocalCacheService().get('deleted_income_ids');
    final deletedIds = deleted is List ? deleted.cast<String>() : <String>[];
    if (!deletedIds.contains(id)) {
      deletedIds.add(id);
      LocalCacheService().save('deleted_income_ids', deletedIds);
    }

    final updatedEntries = state.entries.where((e) => e.id != id).toList();
    state = state.copyWith(
      entries: updatedEntries,
      isSyncing: true,
    );
    LocalCacheService().save('income_entries', {
      'entries': updatedEntries.map((e) => e.toJson()).toList(),
      if (state.pagination != null) 'pagination': state.pagination!.toJson(),
    });

    try {
      await _apiService.deleteEntry(id);
      if (!ref.mounted) return;
      final summary = await _apiService.getSummary(horizon: state.forecastHorizon);
      state = state.copyWith(
        summaryData: summary ?? state.summaryData,
        isSyncing: false,
      );
      loadLiveIncomeData(force: true);
      return;
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
      if (!ref.mounted) return null;
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

  /// Confirm a detected inflow stream and add to active streams via live backend API:
  /// POST /api/v1/income/detected-inflows/:detectedId/confirm
  /// Body: { "category": category, "frequency": frequency }
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
        final filteredEntries = state.entries.where((e) => e.id != created.id).toList();
        final updatedEntries = [created, ...filteredEntries];
        try {
          ref.read(bankAggregationProvider.notifier).adjustAccountBalance(
            bankAccount: created.bankAccount,
            delta: created.amount,
          );
        } catch (_) {}

        state = state.copyWith(
          entries: updatedEntries,
          detectedInflows: updatedDetected,
          isSyncing: false,
        );
        try {
          LocalCacheService().save('income_entries', {
            'entries': updatedEntries.map((e) => e.toJson()).toList(),
          });
        } catch (_) {}
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

  /// Prepend an auto-detected or SMS-detected inflow to the pending banner
  void addDetectedInflow(DetectedInflow inflow) {
    final exists = state.detectedInflows.any((d) => d.detectedId == inflow.detectedId);
    if (!exists) {
      state = state.copyWith(
        detectedInflows: [inflow, ...state.detectedInflows],
      );
    }
  }

  /// Dismiss / Delete a detected inflow from the banner without adding to streams
  void dismissDetectedInflow(String detectedId) {
    final updated = state.detectedInflows.where((d) => d.detectedId != detectedId).toList();
    state = state.copyWith(detectedInflows: updated);
    _apiService.dismissDetectedInflow(detectedId);
  }

  /// Directly approve and convert a detected inflow into an active income stream
  /// Connects to POST /api/v1/income/detected-inflows/:detectedId/confirm
  Future<IncomeEntry?> approveDetectedInflow(
    DetectedInflow inflow, {
    String? category,
    String? frequency,
  }) async {
    final effectiveCategory = (category != null && category.isNotEmpty)
        ? category
        : (inflow.suggestedCategory.isNotEmpty ? inflow.suggestedCategory : 'Salary');
    final effectiveFrequency = (frequency != null && frequency.isNotEmpty)
        ? frequency
        : 'Monthly';

    // 1. Call live backend confirmation API: POST /api/v1/income/detected-inflows/:detectedId/confirm
    final confirmed = await confirmDetectedInflow(
      inflow.detectedId,
      category: effectiveCategory,
      frequency: effectiveFrequency,
    );

    if (confirmed != null) {
      return confirmed;
    }

    // 2. Resilient fallback if offline or mock endpoint
    final fallbackEntry = IncomeEntry(
      id: 'inc_${DateTime.now().millisecondsSinceEpoch}',
      source: inflow.detectedSource,
      category: effectiveCategory,
      amount: inflow.amount,
      date: inflow.date.isNotEmpty ? inflow.date : 'Today',
      bankAccount: inflow.bankAccount.isNotEmpty
          ? inflow.bankAccount
          : (ref.read(bankAggregationProvider).bankAccounts.isNotEmpty
              ? '${ref.read(bankAggregationProvider).bankAccounts.first.bankName} ••••${ref.read(bankAggregationProvider).bankAccounts.first.maskedAccountNumber.replaceAll(RegExp(r'[^0-9]'), '')}'
              : 'Primary Account'),
      paymentMode: inflow.bankAccount.isNotEmpty
          ? inflow.bankAccount
          : (ref.read(bankAggregationProvider).bankAccounts.isNotEmpty
              ? '${ref.read(bankAggregationProvider).bankAccounts.first.bankName} ••••${ref.read(bankAggregationProvider).bankAccounts.first.maskedAccountNumber.replaceAll(RegExp(r'[^0-9]'), '')}'
              : 'Primary Account'),
      type: 'Active',
      frequency: effectiveFrequency,
      notes: 'Confirmed via SMS_ALERT (Ref: ${inflow.referenceId ?? "N/A"})',
      accountNumber: inflow.bankAccount.contains('••••')
          ? '••••${inflow.bankAccount.split('••••').last.trim()}'
          : null,
      isVerified: true,
      verificationType: 'Digitally Verified Inflow',
      createdAt: DateTime.now().toIso8601String(),
    );

    dismissDetectedInflow(inflow.detectedId);
    await addIncome(fallbackEntry);
    return fallbackEntry;
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
