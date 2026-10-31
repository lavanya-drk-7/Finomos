import 'dart:io';
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../domain/expense_models.dart';

class ExpenseApiService {
  final ApiClient _client = ApiClient();

  /// Fetch expense entries with search, filters & pagination
  /// GET /api/v1/expenses/entries?search=&category=&priority=&bankAccount=&dateFilter=&page=1&limit=20
  Future<ExpenseEntriesResponse?> getEntries({
    String? search,
    String? category,
    String? priority,
    String? bankAccount,
    String? dateFilter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final endpoint = ApiConstants.expenseEntriesQuery(
        search: search,
        category: category,
        priority: priority,
        bankAccount: bankAccount,
        dateFilter: dateFilter,
        page: page,
        limit: limit,
      );
      final response = await _client.get(endpoint);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          return ExpenseEntriesResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch expense list from live backend GET /api/v1/expenses/entries or /api/expense
  Future<List<ExpenseEntry>?> getExpenses() async {
    final entriesRes = await getEntries();
    if (entriesRes != null && entriesRes.expenses.isNotEmpty) {
      return entriesRes.expenses;
    }

    try {
      final response = await _client.get(ApiConstants.directExpense);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic body = jsonDecode(response.body);
        if (body is List) {
          return body.map((e) => ExpenseEntry.fromJson(e as Map<String, dynamic>)).toList();
        } else if (body is Map && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => ExpenseEntry.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}

    return null;
  }

  /// Fetch a single expense entry by ID
  /// GET /api/v1/expenses/entries/:id
  Future<ExpenseEntry?> getExpenseById(String id) async {
    try {
      final response = await _client.get(ApiConstants.expenseEntryById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return ExpenseEntry.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Create new expense outflow on live backend
  /// POST /api/v1/expenses/entries
  Future<ExpenseEntry?> createExpense(ExpenseEntry entry) async {
    try {
      final response = await _client.post(
        ApiConstants.expenseEntries,
        body: entry.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return ExpenseEntry.fromJson(body['data'] as Map<String, dynamic>);
        } else if (body['data'] != null) {
          return ExpenseEntry.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Update existing expense entry on live backend
  /// PUT /api/v1/expenses/entries/:id
  Future<ExpenseEntry?> updateExpense(String id, ExpenseEntry entry) async {
    try {
      final response = await _client.put(
        ApiConstants.expenseEntryById(id),
        body: entry.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return ExpenseEntry.fromJson(body['data'] as Map<String, dynamic>);
        } else if (body['data'] != null) {
          return ExpenseEntry.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Delete expense outflow on live backend
  /// DELETE /api/v1/expenses/entries/:id
  Future<bool> deleteExpense(String id) async {
    try {
      final response = await _client.delete(ApiConstants.expenseEntryById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  /// Fetch monthly summary from live backend
  /// GET /api/v1/expenses/summary?month=YYYY-MM
  Future<ExpenseSummaryData?> getSummary({String? month}) async {
    try {
      final endpoint = month != null && month.isNotEmpty
          ? ApiConstants.expenseSummaryWithMonth(month)
          : ApiConstants.expenseSummary;
      final response = await _client.get(endpoint);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return ExpenseSummaryData.fromJson(body['data'] as Map<String, dynamic>);
        } else if (body['data'] != null) {
          return ExpenseSummaryData.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch category breakdown from live backend
  /// GET /api/v1/expenses/breakdown/category
  Future<List<ExpenseCategoryBreakdown>> getCategoryBreakdown() async {
    try {
      final response = await _client.get(ApiConstants.expenseCategoryBreakdown);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic body = jsonDecode(response.body);
        if (body is Map && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => ExpenseCategoryBreakdown.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (body is List) {
          return body
              .map((e) => ExpenseCategoryBreakdown.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return const [];
  }

  /// Fetch priority breakdown from live backend
  /// GET /api/v1/expenses/breakdown/priority
  Future<ExpensePriorityBreakdown?> getPriorityBreakdown() async {
    try {
      final response = await _client.get(ApiConstants.expensePriorityBreakdown);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic body = jsonDecode(response.body);
        if (body is Map && body['data'] is Map<String, dynamic>) {
          return ExpensePriorityBreakdown.fromJson(body['data'] as Map<String, dynamic>);
        } else if (body is Map<String, dynamic>) {
          return ExpensePriorityBreakdown.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch unconfirmed detected expenses from live backend
  /// GET /api/v1/expenses/detected
  Future<List<DetectedExpense>> getDetectedExpenses() async {
    try {
      final response = await _client.get(ApiConstants.expenseDetected);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic body = jsonDecode(response.body);
        if (body is Map && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => DetectedExpense.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (body is List) {
          return body
              .map((e) => DetectedExpense.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return const [];
  }

  /// Confirm a detected expense on live backend
  /// POST /api/v1/expenses/detected/:detectionId/confirm
  Future<ExpenseEntry?> confirmDetectedExpense(String detectionId) async {
    try {
      final response = await _client.post(ApiConstants.expenseConfirmDetected(detectionId));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return ExpenseEntry.fromJson(body['data'] as Map<String, dynamic>);
        } else if (body['data'] != null) {
          return ExpenseEntry.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Upload expense receipt proof file
  /// POST /api/v1/expenses/receipt-upload
  Future<ExpenseReceiptUploadResult?> uploadReceipt(File file) async {
    try {
      final response = await _client.multipartPost(
        ApiConstants.expenseReceiptUpload,
        file: file,
        fileFieldName: 'file',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return ExpenseReceiptUploadResult.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch full expense invoice details from live backend
  /// GET /api/v1/expenses/entries/:id/invoice
  Future<ExpenseInvoiceDetails?> getInvoice(String id) async {
    try {
      final response = await _client.get(ApiConstants.expenseInvoiceById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return ExpenseInvoiceDetails.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }
}