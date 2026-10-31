import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/core/constants/api_constants.dart';
import 'package:finomos/features/budget_management/domain/budget_models.dart';

void main() {
  group('Budget Module API Payloads & Model Integration Tests', () {
    test('1. Budget Summary API: /api/v1/budgets/summary maps correctly', () {
      const jsonStr = '''{
        "success": true,
        "data": {
            "totalBudget": 269590,
            "totalSpent": 8020,
            "remaining": 261570,
            "overspent": 0,
            "overallUsage": 3,
            "activeCategoriesCount": 5,
            "totalBudgetsCount": 15,
            "exceededCount": 0,
            "warningCount": 0,
            "onTrackCount": 15,
            "aiCfoInsight": "AI CFO Insight: Overall budget utilization is at 3.0%. Your spending is well within guardrails. ₹2,61,570 remaining for this cycle."
        }
      }''';

      final Map<String, dynamic> body = jsonDecode(jsonStr);
      final summary = BudgetSummaryData.fromJson(body['data'] as Map<String, dynamic>);

      expect(summary.totalBudget, 269590.0);
      expect(summary.totalSpent, 8020.0);
      expect(summary.remaining, 261570.0);
      expect(summary.overspent, 0.0);
      expect(summary.overallUsage, 3.0);
      expect(summary.activeCategoriesCount, 5);
      expect(summary.totalBudgetsCount, 15);
      expect(summary.exceededCount, 0);
      expect(summary.warningCount, 0);
      expect(summary.onTrackCount, 15);
      expect(summary.aiCfoInsight, contains('Overall budget utilization is at 3.0%'));
    });

    test('2. Budget List API: /api/v1/budgets maps with eligibleTransactions', () {
      const jsonStr = '''{
        "success": true,
        "data": {
            "budgets": [
                {
                    "id": "cmvuk3yrn0005dy92tfisctfk",
                    "name": "Transportation Budget",
                    "category": "Transportation",
                    "type": "Category-wise Budget",
                    "period": "Monthly",
                    "amount": 6000,
                    "spent": 850,
                    "remaining": 5150,
                    "overspent": 0,
                    "utilizationPercentage": 14.2,
                    "status": "none",
                    "threshold": "none",
                    "alertThreshold": 80,
                    "alertsEnabled": true,
                    "startDate": "2026-10-01",
                    "endDate": "2026-10-31",
                    "recentTransactionsCount": 1,
                    "eligibleTransactions": [
                        {
                            "id": "cmvupnoxm0003c1hroh6nj9w8",
                            "userId": "cmuzhxi5a000asr4p9f6jcndp",
                            "amount": 850,
                            "date": "27 Oct 2026",
                            "category": "Transportation",
                            "description": "Uber Ride Indiranagar to Airport",
                            "paymentMode": "UPI",
                            "merchant": "Uber India",
                            "bankAccount": "Axis Bank ••••3301",
                            "isVerified": true
                        }
                    ],
                    "createdAt": "2026-10-30T05:53:45.155Z",
                    "updatedAt": "2026-10-30T08:29:06.234Z"
                }
            ],
            "pagination": {
                "currentPage": 1,
                "perPage": 20,
                "totalRecords": 1,
                "totalPages": 1
            }
        }
      }''';

      final Map<String, dynamic> body = jsonDecode(jsonStr);
      final rawList = body['data']['budgets'] as List;
      final budgets = rawList.map((b) => BudgetItem.fromJson(b as Map<String, dynamic>)).toList();

      expect(budgets.length, 1);
      final budget = budgets.first;
      expect(budget.id, 'cmvuk3yrn0005dy92tfisctfk');
      expect(budget.name, 'Transportation Budget');
      expect(budget.category, 'Transportation');
      expect(budget.amount, 6000.0);
      expect(budget.spent, 850.0);
      expect(budget.remaining, 5150.0);
      expect(budget.overspentAmount, 0.0);
      expect(budget.utilizationPercentage, 14.166666666666666);
      expect(budget.alertThreshold, 80.0);
      expect(budget.alertsEnabled, isTrue);
      expect(budget.recentTransactionsCount, 1);
      expect(budget.eligibleTransactions.length, 1);

      final tx = budget.eligibleTransactions.first;
      expect(tx.id, 'cmvupnoxm0003c1hroh6nj9w8');
      expect(tx.amount, 850.0);
      expect(tx.description, 'Uber Ride Indiranagar to Airport');
      expect(tx.merchant, 'Uber India');
      expect(tx.bankAccount, 'Axis Bank ••••3301');
      expect(tx.isVerified, isTrue);
    });

    test('3. Single Budget Detail API: /api/v1/budgets/:id maps analytics fields', () {
      const jsonStr = '''{
        "success": true,
        "data": {
            "id": "cmvuslah8000vc1hrei2z71pa",
            "name": "Food & Dining Budget",
            "category": "Food & Dining",
            "type": "Category-wise Budget",
            "period": "Monthly",
            "amount": 18830,
            "spent": 0,
            "remaining": 18830,
            "overspent": 0,
            "utilizationPercentage": 0,
            "status": "none",
            "threshold": "none",
            "alertThreshold": 80,
            "alertsEnabled": true,
            "startDate": "2026-11-01",
            "endDate": "2026-11-30",
            "dailyBurnRate": 0,
            "projectedMonthEndSpent": 0,
            "projectedVariance": -18830,
            "transactions": []
        }
      }''';

      final Map<String, dynamic> body = jsonDecode(jsonStr);
      final budget = BudgetItem.fromJson(body['data'] as Map<String, dynamic>);

      expect(budget.id, 'cmvuslah8000vc1hrei2z71pa');
      expect(budget.amount, 18830.0);
      expect(budget.spent, 0.0);
      expect(budget.dailyBurnRate, 0.0);
      expect(budget.projectedMonthEndSpent, 0.0);
      expect(budget.projectedVariance, -18830.0);
    });

    test('4. Deduct Expense & Recalculate API responses match models', () {
      const deductJson = '''{
        "success": true,
        "message": "Expense deducted from budget successfully",
        "data": {
            "budgetId": "cmvvy03z00009pyagkyqyey3u",
            "expenseId": "cmvvy411f000bpyag5p9s0vwo",
            "allocatedAmount": 6500,
            "previousSpent": 3800,
            "newSpent": 9000,
            "remaining": 0,
            "utilizationPercentage": 138.5,
            "thresholdCrossed": "exceeded",
            "alertEvent": {
                "type": "CRITICAL",
                "title": "Budget Exceeded: Entertainment",
                "message": "Exceeded! Spending has reached ₹9,000 (138.5% of ₹6,500).",
                "severity": "CRITICAL"
            }
        }
      }''';

      final Map<String, dynamic> body = jsonDecode(deductJson);
      final data = body['data'] as Map<String, dynamic>;

      expect(data['budgetId'], 'cmvvy03z00009pyagkyqyey3u');
      expect(data['newSpent'], 9000);
      expect(data['thresholdCrossed'], 'exceeded');
      expect(data['alertEvent']['severity'], 'CRITICAL');
    });

    test('5. Utilization Analytics API: /api/v1/budgets/analytics/utilization maps correctly', () {
      const jsonStr = '''{
        "success": true,
        "data": {
            "categories": [
                {
                    "category": "Entertainment",
                    "budgetId": "cmvvy03z00009pyagkyqyey3u",
                    "budgeted": 6500,
                    "spent": 9000,
                    "remaining": 0,
                    "utilizationPercentage": 138.5,
                    "status": "exceeded",
                    "daysInPeriod": 31,
                    "daysElapsed": 31,
                    "dailyBurnRate": 290.32,
                    "projectedMonthEndSpent": 8999.92,
                    "projectedVariance": 2499.92
                }
            ],
            "highestUtilizedCategory": "Entertainment",
            "totalDailyBurnRate": 549.03,
            "projectedTotalOutflow": 17019.93
        }
      }''';

      final Map<String, dynamic> body = jsonDecode(jsonStr);
      final analytics = BudgetAnalyticsResponse.fromJson(body['data'] as Map<String, dynamic>);

      expect(analytics.highestUtilizedCategory, 'Entertainment');
      expect(analytics.totalDailyBurnRate, 549.03);
      expect(analytics.projectedTotalOutflow, 17019.93);
      expect(analytics.categories.length, 1);
      final cat = analytics.categories.first;
      expect(cat.category, 'Entertainment');
      expect(cat.dailyBurnRate, 290.32);
      expect(cat.projectedVariance, 2499.92);
    });

    test('6. Active Alerts API: /api/v1/budgets/alerts/active maps correctly', () {
      const jsonStr = '''{
        "success": true,
        "data": {
            "alerts": [
                {
                    "alertId": "alert_cmvvy03z00009pyagkyqyey3u_exceeded",
                    "budgetId": "cmvvy03z00009pyagkyqyey3u",
                    "category": "Entertainment",
                    "threshold": "exceeded",
                    "severity": "CRITICAL",
                    "title": "Budget Exceeded: Entertainment",
                    "message": "High Alert: You have exceeded your Entertainment budget by ₹2,500. Spent: ₹9,000 / ₹6,500.",
                    "utilizationPercentage": 138.5,
                    "isDismissed": false,
                    "createdAt": "2026-10-31T05:13:31.468Z"
                }
            ],
            "activeCount": 1
        }
      }''';

      final Map<String, dynamic> body = jsonDecode(jsonStr);
      final rawAlerts = body['data']['alerts'] as List;
      final alerts = rawAlerts.map((a) => ActiveBudgetAlert.fromJson(a as Map<String, dynamic>)).toList();

      expect(alerts.length, 1);
      final alert = alerts.first;
      expect(alert.alertId, 'alert_cmvvy03z00009pyagkyqyey3u_exceeded');
      expect(alert.severity, 'CRITICAL');
      expect(alert.isDismissed, isFalse);
      expect(alert.utilizationPercentage, 138.5);
    });

    test('7. Guardrails Settings API: /api/v1/budgets/settings/guardrails maps correctly', () {
      const jsonStr = '''{
        "success": true,
        "data": {
            "autoSmsDeduction": true,
            "warning80Alerts": true,
            "overspendingBanners": true,
            "thresholdPercent": 80,
            "enableOverspendPush": true,
            "updatedAt": "2026-10-31T05:29:20.996Z"
        }
      }''';

      final Map<String, dynamic> body = jsonDecode(jsonStr);
      final guardrails = GuardrailSettings.fromJson(body['data'] as Map<String, dynamic>);

      expect(guardrails.autoSmsDeduction, isTrue);
      expect(guardrails.warning80Alerts, isTrue);
      expect(guardrails.overspendingBanners, isTrue);
      expect(guardrails.thresholdPercent, 80.0);
      expect(guardrails.enableOverspendPush, isTrue);
      expect(guardrails.updatedAt, '2026-10-31T05:29:20.996Z');
    });

    test('8. ApiConstants URLs match live endpoints', () {
      expect(ApiConstants.budgetSummary, '/api/v1/budgets/summary');
      expect(ApiConstants.budgets, '/api/v1/budgets');
      expect(ApiConstants.budgetById('b123'), '/api/v1/budgets/b123');
      expect(ApiConstants.budgetExpenses('b123'), '/api/v1/budgets/b123/expenses');
      expect(ApiConstants.budgetRecalculate, '/api/v1/budgets/recalculate');
      expect(ApiConstants.budgetUtilizationAnalytics, '/api/v1/budgets/analytics/utilization');
      expect(ApiConstants.budgetActiveAlerts, '/api/v1/budgets/alerts/active');
      expect(ApiConstants.budgetDismissAlert('a1'), '/api/v1/budgets/alerts/a1/dismiss');
      expect(ApiConstants.budgetGuardrailSettings, '/api/v1/budgets/settings/guardrails');
      expect(ApiConstants.budgetRollover, '/api/v1/budgets/rollover');
    });
  });
}

