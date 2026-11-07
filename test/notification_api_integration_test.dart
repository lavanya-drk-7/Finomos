import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/features/notifications/domain/notification_models.dart';
import 'package:finomos/features/income_tracking/domain/income_models.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';

void main() {
  group('Backend Live API Schema & Model Mapping Tests', () {
    test('1. SMS Ingest Debit Response maps correctly to SmsIngestResult & AppNotification', () {
      final json = {
        "success": true,
        "alreadyIngested": true,
        "message": "SMS already ingested and processed for this reference ID (idempotent)",
        "data": {
          "notificationId": "cmw0kzpm70001ekofznhtumkx",
          "classification": "Debit",
          "entities": {
            "amount": 5420,
            "bankName": "HDFC Bank",
            "accountDigits": "••••4587",
            "merchantOrSource": "Swiggy",
            "suggestedCategory": "Food & Dining",
            "suggestedPriority": "P4 - Discretionary",
            "referenceId": "430892019283",
            "balance": 45000,
            "date": "03-Nov-26",
            "fdDetails": null
          },
          "redirection": {
            "route": "/expenses",
            "action": "DETECTED_OUTFLOW_SHORTBOX",
            "detectionId": "det_deb_mw0kzqqg_85in",
            "targetModule": "EXPENSE_TRACKING"
          }
        }
      };

      final result = SmsIngestResult.fromJson(json);
      expect(result.success, true);
      expect(result.alreadyIngested, true);
      expect(result.notificationId, "cmw0kzpm70001ekofznhtumkx");
      expect(result.classification, "Debit");
      expect(result.entities!['amount'], 5420);
      expect(result.entities!['bankName'], "HDFC Bank");
      expect(result.entities!['merchantOrSource'], "Swiggy");
      expect(result.redirection!.route, "/expenses");
      expect(result.redirection!.detectionId, "det_deb_mw0kzqqg_85in");
      expect(result.redirection!.action, "DETECTED_OUTFLOW_SHORTBOX");

      // AppNotification parsed from entities/data
      final data = json['data'] as Map<String, dynamic>;
      final notif = AppNotification.fromJson({
        "id": result.notificationId,
        "classification": result.classification,
        "entities": result.entities,
        "redirection": data['redirection'],
      });

      expect(notif.isDebitSms, true);
      expect(notif.isCreditSms, false);
      expect(notif.amount, 5420.0);
      expect(notif.balance, 45000.0);
      expect(notif.bankName, "HDFC Bank");
      expect(notif.merchantOrSource, "Swiggy");
      expect(notif.redirection!.targetId, "det_deb_mw0kzqqg_85in");
    });

    test('2. SMS Ingest Credit Response maps correctly to SmsIngestResult & AppNotification', () {
      final json = {
        "success": true,
        "alreadyIngested": true,
        "message": "SMS already ingested and processed for this reference ID (idempotent)",
        "data": {
          "notificationId": "cmw0kzwcc0006ekof8k2avhj4",
          "classification": "Credit",
          "entities": {
            "amount": 85000,
            "bankName": "State Bank of India",
            "accountDigits": "••••1123",
            "merchantOrSource": "Infosys Technologies Ltd",
            "suggestedCategory": "Salary",
            "suggestedPriority": "P1 - Essential",
            "referenceId": "9901823912",
            "balance": 145400,
            "date": "2026-11-03",
            "fdDetails": null
          },
          "redirection": {
            "route": "/income",
            "action": "DETECTED_INFLOW_SHORTBOX",
            "detectedId": "det_inf_mw0kzxgj_mf1f",
            "targetModule": "INCOME_TRACKING"
          }
        }
      };

      final result = SmsIngestResult.fromJson(json);
      expect(result.success, true);
      expect(result.classification, "Credit");
      expect(result.entities!['amount'], 85000);
      expect(result.redirection!.route, "/income");
      expect(result.redirection!.targetId, "det_inf_mw0kzxgj_mf1f");

      final data = json['data'] as Map<String, dynamic>;
      final notif = AppNotification.fromJson({
        "id": result.notificationId,
        "classification": result.classification,
        "entities": result.entities,
        "redirection": data['redirection'],
      });

      expect(notif.isCreditSms, true);
      expect(notif.isDebitSms, false);
      expect(notif.amount, 85000.0);
      expect(notif.merchantOrSource, "Infosys Technologies Ltd");
      expect(notif.redirection!.detectedId, "det_inf_mw0kzxgj_mf1f");
    });

    test('3. SMS Ingest Fixed Deposit Response maps correctly with fdDetails', () {
      final json = {
        "success": true,
        "alreadyIngested": true,
        "message": "SMS already ingested and processed for this reference ID (idempotent)",
        "data": {
          "notificationId": "cmw0l025l000aekofx99vv28u",
          "classification": "Fixed Deposit",
          "entities": {
            "amount": 100000,
            "bankName": "ICICI Bank",
            "accountDigits": "••••8891",
            "merchantOrSource": "ICICI Bank",
            "suggestedCategory": "Investment",
            "suggestedPriority": "P2 - Important",
            "referenceId": "FD492019",
            "balance": null,
            "date": "03-Nov-26",
            "fdDetails": {
              "principal": 100000,
              "tenure": "12 months",
              "interestRate": "7.10% p.a."
            }
          },
          "redirection": {
            "route": "/bank-aggregation",
            "action": "FIXED_DEPOSIT_MODAL",
            "fdDetails": {
              "principal": 100000,
              "tenure": "12 months",
              "interestRate": "7.10% p.a."
            },
            "targetModule": "BANK_AGGREGATION"
          }
        }
      };

      final data = json['data'] as Map<String, dynamic>;
      final notif = AppNotification.fromJson({
        "id": data['notificationId'],
        "classification": data['classification'],
        "entities": data['entities'],
        "redirection": data['redirection'],
      });

      expect(notif.isFixedDepositSms, true);
      expect(notif.amount, 100000.0);
      expect(notif.fdDetails, isNotNull);
      expect(notif.fdDetails!.principal, 100000.0);
      expect(notif.fdDetails!.tenure, "12 months");
      expect(notif.fdDetails!.interestRate, "7.10% p.a.");
      expect(notif.redirection!.action, "FIXED_DEPOSIT_MODAL");
    });

    test('4. SMS Ingest Promotion Offer Response maps correctly', () {
      final json = {
        "success": true,
        "alreadyIngested": true,
        "message": "SMS already ingested and processed for this reference ID (idempotent)",
        "data": {
          "notificationId": "cmw0l02h9000dekof4q4r2386",
          "classification": "Promotion",
          "entities": {
            "amount": null,
            "bankName": "HDFC Bank",
            "accountDigits": null,
            "merchantOrSource": "HDFC Bank Festive Offers",
            "suggestedCategory": "Promotion",
            "suggestedPriority": "P4 - Discretionary",
            "referenceId": null,
            "balance": null,
            "date": "2026-11-03",
            "fdDetails": null
          },
          "redirection": {
            "route": "/notifications",
            "action": "PROMOTION_OFFER",
            "targetModule": "NOTIFICATIONS"
          }
        }
      };

      final data = json['data'] as Map<String, dynamic>;
      final notif = AppNotification.fromJson({
        "id": data['notificationId'],
        "classification": data['classification'],
        "entities": data['entities'],
        "redirection": data['redirection'],
      });

      expect(notif.isPromotionSms, true);
      expect(notif.redirection!.action, "PROMOTION_OFFER");
    });

    test('5. Notifications List response with metadata and counts maps cleanly', () {
      final json = {
        "success": true,
        "data": {
          "notifications": [
            {
              "id": "cmw0l02h9000dekof4q4r2386",
              "userId": "cmuzhxi5a000asr4p9f6jcndp",
              "category": "Promotion",
              "title": "Diwali Offer! Get 10% instant cashback up to INR 1,500 on flights with your HDFC Bank Credit Card.",
              "message": "Diwali Offer! Get 10% instant cashback up to INR 1,500 on flights with your HDFC Bank Credit Card.",
              "isRead": false,
              "isSaved": false,
              "isSms": true,
              "smsSender": "VK-HDFCBK",
              "smsRaw": "Diwali Offer! Get 10% instant cashback...",
              "referenceId": null,
              "classification": "Promotion",
              "metadata": {
                "amount": null,
                "bankName": "HDFC Bank",
                "merchantOrSource": "HDFC Bank Festive Offers",
                "suggestedCategory": "Promotion",
                "suggestedPriority": "P4 - Discretionary",
                "referenceId": null,
                "balance": null,
                "date": "2026-11-03",
                "redirection": {
                  "route": "/notifications",
                  "action": "PROMOTION_OFFER",
                  "targetModule": "NOTIFICATIONS"
                }
              },
              "actionUrl": null,
              "type": "PROMOTION",
              "createdAt": "2026-11-03T11:44:40.413Z",
              "updatedAt": "2026-11-03T11:44:40.413Z"
            }
          ],
          "pagination": {
            "total": 35,
            "page": 1,
            "limit": 50,
            "totalPages": 1
          },
          "counts": {
            "all": 35,
            "unread": 34,
            "saved": 0,
            "sms": 7
          }
        }
      };

      final data = json['data'] as Map<String, dynamic>;
      final list = (data['notifications'] as List)
          .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
          .toList();
      final pagination = NotificationPagination.fromJson(data['pagination'] as Map<String, dynamic>?);
      final counts = NotificationCounts.fromJson(data['counts'] as Map<String, dynamic>?);

      expect(list.length, 1);
      expect(list.first.id, "cmw0l02h9000dekof4q4r2386");
      expect(list.first.isSms, true);
      expect(list.first.smsSender, "VK-HDFCBK");
      expect(list.first.isPromotionSms, true);
      expect(pagination.total, 35);
      expect(counts.all, 35);
      expect(counts.unread, 34);
      expect(counts.sms, 7);
    });

    test('6. Detected Inflow Live API response maps to DetectedInflow correctly', () {
      final json = {
        "id": "det_inf_mw0kzxgj_mf1f",
        "sourceName": "Infosys Technologies Ltd",
        "amount": 85000,
        "bankAccount": "State Bank of India (••••1123)",
        "date": "2026-11-03",
        "referenceId": "9901823912",
        "suggestedCategory": "Salary",
        "confidence": 0.95,
        "rawSms": "Dear SBI User, A/C ••••1123 credited by Rs 85,000.00 on 03Nov26 by transfer from Infosys Technologies Ltd. Bal Rs 1,45,400.00 - SBI Ref 9901823912",
        "status": "UNCONFIRMED"
      };

      final inflow = DetectedInflow.fromJson(json);
      expect(inflow.detectedId, "det_inf_mw0kzxgj_mf1f");
      expect(inflow.detectedSource, "Infosys Technologies Ltd");
      expect(inflow.amount, 85000.0);
      expect(inflow.bankAccount, "State Bank of India (••••1123)");
      expect(inflow.referenceId, "9901823912");
      expect(inflow.confidenceScore, 0.95);
      expect(inflow.status, "UNCONFIRMED");
    });

    test('7. Detected Expense Live API response maps to DetectedExpense correctly', () {
      final json = {
        "id": "det_deb_mw0kzqqg_85in",
        "merchant": "Swiggy",
        "amount": 5420,
        "bankAccount": "HDFC Bank (••••4587)",
        "category": "Food & Dining",
        "priority": "P4 - Discretionary",
        "date": "03-Nov-26",
        "referenceId": "430892019283",
        "rawSms": "Dear Customer, INR 5,420.00 debited from A/C ••••4587 on 03-Nov-26 via UPI/Swiggy. Ref 430892019283. Bal: INR 45,000.00",
        "status": "UNCONFIRMED"
      };

      final exp = DetectedExpense.fromJson(json);
      expect(exp.detectionId, "det_deb_mw0kzqqg_85in");
      expect(exp.description, "Swiggy");
      expect(exp.amount, 5420.0);
      expect(exp.bankAccount, "HDFC Bank (••••4587)");
      expect(exp.suggestedCategory, "Food & Dining");
      expect(exp.suggestedPriority, "P4 - Discretionary");
      expect(exp.referenceId, "430892019283");
      expect(exp.status, "UNCONFIRMED");
    });

    test('8. Batch SMS Live API response maps to SmsBatchSyncResult correctly', () {
      final json = {
        "success": true,
        "message": "Batch SMS processed successfully",
        "summary": {
          "totalReceived": 3,
          "ingested": 1,
          "duplicatesSkipped": 2,
          "creditsCount": 1,
          "debitsCount": 0,
          "fixedDepositsCount": 0
        },
        "data": [
          {
            "notificationId": "cmw35e5s5000e6tgutw9ftq1s",
            "classification": "Credit",
            "entities": {
              "amount": 85000,
              "bankName": "State Bank of India",
              "accountDigits": "••••1123",
              "merchantOrSource": "Infosys Technologies Ltd",
              "suggestedCategory": "Salary",
              "suggestedPriority": "P1 - Essential",
              "referenceId": "9901823912",
              "balance": 145400,
              "date": "2026-11-04",
              "fdDetails": null
            },
            "redirection": {
              "route": "/income",
              "action": "DETECTED_INFLOW_SHORTBOX",
              "detectedId": "det_inf_mw35e6c2_4e7z",
              "targetModule": "INCOME_TRACKING"
            }
          }
        ]
      };

      final batch = SmsBatchSyncResult.fromJson(json);
      expect(batch.success, true);
      expect(batch.message, "Batch SMS processed successfully");
      expect(batch.summary.totalReceived, 3);
      expect(batch.summary.ingested, 1);
      expect(batch.summary.duplicatesSkipped, 2);
      expect(batch.summary.creditsCount, 1);
      expect(batch.summary.debitsCount, 0);
      expect(batch.summary.fixedDepositsCount, 0);

      expect(batch.data.length, 1);
      final item = batch.data.first;
      expect(item.notificationId, "cmw35e5s5000e6tgutw9ftq1s");
      expect(item.classification, "Credit");
      expect(item.entities!['amount'], 85000);
      expect(item.entities!['bankName'], "State Bank of India");
      expect(item.redirection!.route, "/income");
      expect(item.redirection!.action, "DETECTED_INFLOW_SHORTBOX");
      expect(item.redirection!.detectedId, "det_inf_mw35e6c2_4e7z");
    });
  });
}
