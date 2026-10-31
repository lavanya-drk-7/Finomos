import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../domain/overview_and_transaction_models.dart';

class DashboardApiService {
  final ApiClient _client;

  DashboardApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Fetches executive financial overview: GET /api/overview
  Future<DashboardOverviewData?> getOverview() async {
    try {
      final response = await _client.get(ApiConstants.overview);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          return DashboardOverviewData.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fetches unified transactions timeline (Income + Expense): GET /api/transactions
  Future<List<UnifiedTransactionItem>> getTransactions() async {
    try {
      final response = await _client.get(ApiConstants.transactions);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic body = jsonDecode(response.body);
        if (body is List) {
          return body
              .map((item) => UnifiedTransactionItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        if (body is Map<String, dynamic> && body['data'] is List) {
          return (body['data'] as List)
              .map((item) => UnifiedTransactionItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }
}
