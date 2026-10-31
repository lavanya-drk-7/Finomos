import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../domain/budget_models.dart';

class BudgetApiService {
  final ApiClient _client = ApiClient();

  /// Fetch overview metrics: total budget, spent, remaining, AI CFO insight
  /// GET /api/v1/budgets/summary
  Future<BudgetSummaryData?> getSummary() async {
    try {
      final response = await _client.get(ApiConstants.budgetSummary);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return BudgetSummaryData.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch budget list with filters, sorting & pagination
  /// GET /api/v1/budgets?period=Monthly&category=all&status=all&page=1&limit=20
  Future<List<BudgetItem>?> getBudgets({
    String period = 'Monthly',
    String category = 'all',
    String status = 'all',
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final url = ApiConstants.budgetsQuery(
        period: period,
        category: category,
        status: status,
        page: page,
        limit: limit,
      );
      final response = await _client.get(url);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          final rawBudgets = body['data']['budgets'];
          if (rawBudgets is List) {
            return rawBudgets
                .whereType<Map<String, dynamic>>()
                .map((b) => BudgetItem.fromJson(b))
                .toList();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch single budget by id with detailed analytics & transactions
  /// GET /api/v1/budgets/:id
  Future<BudgetItem?> getBudgetById(String id) async {
    try {
      final response = await _client.get(ApiConstants.budgetById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return BudgetItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Create a new budget
  /// POST /api/v1/budgets
  Future<BudgetItem?> createBudget({
    required String name,
    required String category,
    required String type,
    required double amount,
    String period = 'Monthly',
    double alertThreshold = 80.0,
    bool alertsEnabled = true,
  }) async {
    try {
      final payload = {
        'name': name.trim(),
        'category': category.trim(),
        'type': type.trim(),
        'amount': amount,
        'period': period.trim(),
        'alertThreshold': alertThreshold,
        'alertsEnabled': alertsEnabled,
      };

      final response = await _client.post(
        ApiConstants.budgets,
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return BudgetItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Update an existing budget
  /// PUT /api/v1/budgets/:id
  Future<BudgetItem?> updateBudget({
    required String id,
    double? amount,
    double? alertThreshold,
    String? name,
    String? category,
    String? period,
    bool? alertsEnabled,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (amount != null) payload['amount'] = amount;
      if (alertThreshold != null) payload['alertThreshold'] = alertThreshold;
      if (name != null) payload['name'] = name.trim();
      if (category != null) payload['category'] = category.trim();
      if (period != null) payload['period'] = period.trim();
      if (alertsEnabled != null) payload['alertsEnabled'] = alertsEnabled;

      final response = await _client.put(
        ApiConstants.budgetById(id),
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return BudgetItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Deduct an expense from a budget
  /// POST /api/v1/budgets/:id/expenses
  Future<Map<String, dynamic>?> deductExpense({
    required String budgetId,
    required double amount,
    required String description,
    required String category,
    required String date,
    required String paymentMode,
    String? merchant,
  }) async {
    try {
      final payload = {
        'amount': amount,
        'description': description.trim(),
        'category': category.trim(),
        'date': date.trim(),
        'paymentMode': paymentMode.trim(),
        if (merchant != null && merchant.isNotEmpty) 'merchant': merchant.trim(),
      };

      final response = await _client.post(
        ApiConstants.budgetExpenses(budgetId),
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return body['data'] as Map<String, dynamic>;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Recalculate all budgets from live expenses
  /// POST /api/v1/budgets/recalculate
  Future<List<BudgetItem>?> recalculateBudgets() async {
    try {
      final response = await _client.post(ApiConstants.budgetRecalculate);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          final rawBudgets = body['data']['budgets'];
          if (rawBudgets is List) {
            return rawBudgets
                .whereType<Map<String, dynamic>>()
                .map((b) => BudgetItem.fromJson(b))
                .toList();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch category utilization analytics
  /// GET /api/v1/budgets/analytics/utilization
  Future<BudgetAnalyticsResponse?> getUtilizationAnalytics() async {
    try {
      final response = await _client.get(ApiConstants.budgetUtilizationAnalytics);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return BudgetAnalyticsResponse.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetch active alerts
  /// GET /api/v1/budgets/alerts/active
  Future<List<ActiveBudgetAlert>?> getActiveAlerts() async {
    try {
      final response = await _client.get(ApiConstants.budgetActiveAlerts);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          final rawAlerts = body['data']['alerts'];
          if (rawAlerts is List) {
            return rawAlerts
                .whereType<Map<String, dynamic>>()
                .map((a) => ActiveBudgetAlert.fromJson(a))
                .toList();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Dismiss an active alert banner
  /// PATCH /api/v1/budgets/alerts/:alertId/dismiss
  Future<bool> dismissAlert(String alertId) async {
    try {
      final response = await _client.patch(ApiConstants.budgetDismissAlert(alertId));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  /// Fetch smart guardrail settings
  /// GET /api/v1/budgets/settings/guardrails
  Future<GuardrailSettings?> getGuardrailSettings() async {
    try {
      final response = await _client.get(ApiConstants.budgetGuardrailSettings);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return GuardrailSettings.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Update smart guardrail settings
  /// PATCH /api/v1/budgets/settings/guardrails
  Future<GuardrailSettings?> updateGuardrailSettings(GuardrailSettings settings) async {
    try {
      final response = await _client.patch(
        ApiConstants.budgetGuardrailSettings,
        body: settings.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return GuardrailSettings.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Rollover budgets to next period
  /// POST /api/v1/budgets/rollover
  Future<List<BudgetItem>?> rolloverBudgets({
    required String fromMonth,
    required String toMonth,
    bool rolloverSurplus = true,
  }) async {
    try {
      final payload = {
        'fromMonth': fromMonth,
        'toMonth': toMonth,
        'rolloverSurplus': rolloverSurplus,
      };

      final response = await _client.post(
        ApiConstants.budgetRollover,
        body: payload,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          final rawBudgets = body['data']['budgets'];
          if (rawBudgets is List) {
            return rawBudgets
                .whereType<Map<String, dynamic>>()
                .map((b) => BudgetItem.fromJson(b))
                .toList();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Delete a budget
  /// DELETE /api/v1/budgets/:id
  Future<bool> deleteBudget(String id) async {
    try {
      final response = await _client.delete(ApiConstants.budgetById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }
}

