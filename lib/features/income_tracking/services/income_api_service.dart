import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/cache_service.dart';
import '../domain/income_models.dart';

class IncomeApiService {
  final ApiClient _client = ApiClient();

  /// Fetch income summary aggregated analytics and CFO insight
  Future<IncomeSummaryData?> getSummary({String horizon = '30D'}) async {
    try {
      final response = await _client.get(
        ApiConstants.incomeSummary,
        queryParams: {'horizon': horizon},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'] as Map<String, dynamic>;
          LocalCacheService().save('income_summary', data);
          return IncomeSummaryData.fromJson(data);
        }
      }
    } catch (e) {
      // Return null on failure; caller falls back gracefully
    }
    return null;
  }

  /// Fetch entries list with multi-criteria filtering, type filter, pagination, and text search
  Future<IncomeEntriesResponse?> getEntries({
    String? category,
    String? type,
    String? bankAccount,
    String? dateFilter,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }
      if (type != null && type.isNotEmpty && type != 'All') {
        queryParams['type'] = type;
      }
      if (bankAccount != null && bankAccount.isNotEmpty && bankAccount != 'All') {
        queryParams['bankAccount'] = bankAccount;
      }
      if (dateFilter != null && dateFilter.isNotEmpty && dateFilter != 'All') {
        queryParams['dateFilter'] = dateFilter;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _client.get(
        ApiConstants.incomeEntries,
        queryParams: queryParams,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final entriesJson = body['data']['entries'] as List<dynamic>? ?? [];
          final entries = entriesJson
              .map((item) => IncomeEntry.fromJson(item as Map<String, dynamic>))
              .toList();

          final paginationJson = body['data']['pagination'] as Map<String, dynamic>?;
          final pagination = paginationJson != null
              ? IncomePaginationData.fromJson(paginationJson)
              : IncomePaginationData(
                  currentPage: page,
                  perPage: limit,
                  totalRecords: entries.length,
                  totalPages: (entries.length / limit).ceil().clamp(1, 9999),
                );

          if (page == 1 && search == null && category == null && type == null) {
            LocalCacheService().save('income_entries', body['data']);
          }

          return IncomeEntriesResponse(
            entries: entries,
            pagination: pagination,
          );
        }
      }
    } catch (e) {
      // Fallback
    }
    return null;
  }

  /// Get a single income stream by its unique ID
  Future<IncomeEntry?> getSingleEntry(String id) async {
    try {
      final response = await _client.get(ApiConstants.incomeEntryById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return IncomeEntry.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Create a new income stream record
  Future<IncomeEntry?> createEntry(IncomeEntry entry) async {
    try {
      final response = await _client.post(
        ApiConstants.incomeEntries,
        body: entry.toJson(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return IncomeEntry.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Update an existing income stream record
  Future<IncomeEntry?> updateEntry(IncomeEntry entry) async {
    try {
      final response = await _client.put(
        ApiConstants.incomeEntryById(entry.id),
        body: entry.toJson(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return IncomeEntry.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Permanently delete an income stream record
  Future<bool> deleteEntry(String id) async {
    try {
      final response = await _client.delete(ApiConstants.incomeEntryById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  /// Upload proof document (salary slip, invoice, contract PDF/JPG/PNG)
  Future<IncomeProofUploadResult?> uploadProofDocument(
    File file, {
    String purpose = 'income_proof',
    String? entryId,
    String? linkedEntryId,
  }) async {
    try {
      final fields = <String, String>{'purpose': purpose};
      final targetId = linkedEntryId ?? entryId;
      if (targetId != null && targetId.isNotEmpty) {
        fields['linkedEntryId'] = targetId;
        fields['entryId'] = targetId;
      }

      final response = await _client.multipartPost(
        ApiConstants.incomeProofUpload,
        file: file,
        fileFieldName: 'file',
        fields: fields,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return IncomeProofUploadResult.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch Section 65B official receipt voucher details
  Future<IncomeVoucherData?> getVoucherDetails(String entryId) async {
    try {
      final response = await _client.get(ApiConstants.incomeVoucherById(entryId));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return IncomeVoucherData.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Download official Section 65B voucher PDF bytes from server
  Future<Uint8List?> downloadVoucherPdf(String voucherNumberOrUrl) async {
    try {
      final endpointOrUrl = voucherNumberOrUrl.startsWith('http://') || voucherNumberOrUrl.startsWith('https://')
          ? voucherNumberOrUrl
          : ApiConstants.incomeVoucherPdf(voucherNumberOrUrl);
      return await _client.getBytes(endpointOrUrl);
    } catch (_) {}
    return null;
  }

  /// Toggle automated SMS & Account Aggregator tracking
  Future<bool> updateAutoTracking(bool enabled) async {
    try {
      final response = await _client.patch(
        ApiConstants.incomeAutoTracking,
        body: {'enabled': enabled},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  /// Fetch forecasting model breakdown for a given horizon (30D, 90D, 1Y, 5Y)
  Future<IncomeForecastData?> getForecast({String horizon = '30D'}) async {
    try {
      final response = await _client.get(
        ApiConstants.incomeForecast,
        queryParams: {'horizon': horizon},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return IncomeForecastData.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Trigger real-time bank feeds and Account Aggregator sync
  Future<IncomeSyncResult?> syncFeeds({String source = 'ALL'}) async {
    try {
      final response = await _client.post(
        ApiConstants.incomeSync,
        body: {'source': source},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return IncomeSyncResult.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch automated inflows detected by Account Aggregator & SMS parser
  Future<List<DetectedInflow>?> getDetectedInflows() async {
    try {
      final response = await _client.get(ApiConstants.incomeDetectedInflows);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final list = body['data'] as List<dynamic>;
          return list.map((e) => DetectedInflow.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Confirm a detected inflow and record it as a digitally verified stream
  /// POST /api/v1/income/detected-inflows/:detectedId/confirm
  /// Body: { "category": category, "frequency": frequency }
  Future<IncomeEntry?> confirmDetectedInflow(
    String detectedId, {
    required String category,
    required String frequency,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.incomeConfirmDetectedInflow(detectedId),
        body: {
          'category': category,
          'frequency': frequency,
        },
      );
      if ((response.statusCode >= 200 && response.statusCode < 300) ||
          response.statusCode == 400 ||
          response.statusCode == 409) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['data'] != null && body['data'] is Map<String, dynamic>) {
          return IncomeEntry.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Dismiss / Delete a detected inflow
  /// DELETE /api/v1/income/detected-inflows/:detectedId
  Future<bool> dismissDetectedInflow(String detectedId) async {
    try {
      final response = await _client.delete(
        ApiConstants.incomeDismissDetectedInflow(detectedId),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
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
    try {
      final response = await _client.post(
        ApiConstants.salaryAllocation,
        body: {
          'entryId': entryId,
          'amount': amount,
          'salarySource': salarySource,
          'allocationRules': {
            'emergencyFund': emergencyFund,
            'investments': investments,
            'fixedExpenses': fixedExpenses,
            'discretionary': discretionary,
          },
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return SalaryAllocationResult.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch all income records from direct endpoint GET /api/income
  Future<List<IncomeEntry>?> getDirectIncomeList() async {
    try {
      final response = await _client.get(ApiConstants.directIncome);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic body = jsonDecode(response.body);
        if (body is List) {
          return body.map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>)).toList();
        } else if (body is Map && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Create income record via direct endpoint POST /api/income
  Future<IncomeEntry?> createDirectIncome({
    required double amount,
    required String date,
    required String category,
    required String source,
    required String frequency,
    String notes = '',
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.directIncome,
        body: {
          'amount': amount,
          'date': date,
          'category': category,
          'source': source,
          'frequency': frequency,
          'notes': notes,
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final entryJson = body['data'] != null ? body['data'] as Map<String, dynamic> : body;
        return IncomeEntry.fromJson(entryJson);
      }
    } catch (_) {}
    return null;
  }

  IncomeSummaryData? getCachedSummary() {
    final cached = LocalCacheService().get('income_summary');
    if (cached is Map<String, dynamic>) {
      return IncomeSummaryData.fromJson(cached);
    }
    return null;
  }

  IncomeEntriesResponse? getCachedEntries() {
    final cached = LocalCacheService().get('income_entries');
    if (cached is Map<String, dynamic>) {
      final entriesJson = cached['entries'] as List<dynamic>? ?? [];
      final entries = entriesJson
          .whereType<Map<String, dynamic>>()
          .map((item) => IncomeEntry.fromJson(item))
          .toList();
      return IncomeEntriesResponse(
        entries: entries,
        pagination: IncomePaginationData(
          currentPage: 1,
          perPage: 20,
          totalRecords: entries.length,
          totalPages: 1,
        ),
      );
    }
    return null;
  }
}
