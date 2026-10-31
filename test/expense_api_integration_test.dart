import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';

void main() {
  group('Expense Live API Response Parsing Tests', () {
    test('parses GET /api/v1/expenses/summary response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": {
          "totalMonthlyExpenses": 10220,
          "monthlyAverage": 10220,
          "dailyAverage": 340.7,
          "monthlyInflow": 170796,
          "netCashFlow": 160576,
          "savingsRate": 94.02,
          "cashRunwayMonths": 29.35,
          "recurringExpenses": 0,
          "discretionaryExpenses": 10220,
          "priorityBreakdown": {
            "P1_Survival": 0,
            "P2_Protection": 0,
            "P3_Obligations": 0,
            "P4_Growth": 0,
            "P5_Lifestyle": 10220,
            "P6_Luxury": 0
          },
          "needsRatio": 0,
          "wantsRatio": 100,
          "expenseHealthScore": 95,
          "healthScoreRating": "Excellent Financial Health",
          "totalCount": 3,
          "aiCfoInsight":
              "AI Personal CFO: Expense Health Score is 95/100. Discretionary spending (100%) is above the 30% financial guardrail."
        }
      };

      final summary = ExpenseSummaryData.fromJson(
        jsonResponse['data'] as Map<String, dynamic>,
      );

      expect(summary.totalMonthlyExpenses, 10220.0);
      expect(summary.dailyAverage, 340.7);
      expect(summary.monthlyInflow, 170796.0);
      expect(summary.netCashFlow, 160576.0);
      expect(summary.savingsRate, 94.02);
      expect(summary.cashRunwayMonths, 29.35);
      expect(summary.discretionaryExpenses, 10220.0);
      expect(summary.expenseHealthScore, 95.0);
      expect(summary.healthScoreRating, 'Excellent Financial Health');
      expect(summary.priorityBreakdown['P5_Lifestyle'], 10220.0);
      expect(summary.aiCfoInsight, contains('Expense Health Score is 95/100'));

      const state = ExpenseState(expenses: [], summaryData: null);
      final updatedState = state.copyWith(summaryData: summary);

      expect(updatedState.totalExpenses, 10220.0);
      expect(updatedState.dailyAverage, 340.7);
      expect(updatedState.savingsRate, 94.02);
      expect(updatedState.netCashFlow, 160576.0);
      expect(updatedState.expenseHealthScore, 95.0);
      expect(updatedState.aiCfoInsightText, summary.aiCfoInsight);
    });

    test('parses GET /api/v1/expenses/breakdown/category response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": [
          {"category": "Housing", "totalAmount": 0, "percentage": 0, "count": 0},
          {"category": "Food", "totalAmount": 27620, "percentage": 73.81, "count": 4},
          {"category": "Utilities", "totalAmount": 0, "percentage": 0, "count": 0},
          {"category": "Bills", "totalAmount": 0, "percentage": 0, "count": 0},
          {"category": "Healthcare", "totalAmount": 0, "percentage": 0, "count": 0},
          {"category": "Transportation", "totalAmount": 0, "percentage": 0, "count": 0},
          {"category": "Subscriptions", "totalAmount": 0, "percentage": 0, "count": 0},
          {"category": "Shopping", "totalAmount": 6000, "percentage": 16.03, "count": 1},
          {"category": "Entertainment", "totalAmount": 3800, "percentage": 10.15, "count": 1},
          {"category": "Other", "totalAmount": 0, "percentage": 0, "count": 0}
        ]
      };

      final list = (jsonResponse['data'] as List)
          .map((e) => ExpenseCategoryBreakdown.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(list.length, 10);
      expect(list[1].category, 'Food');
      expect(list[1].totalAmount, 27620.0);
      expect(list[1].percentage, 73.81);
      expect(list[1].count, 4);

      expect(list[7].category, 'Shopping');
      expect(list[7].totalAmount, 6000.0);
      expect(list[7].percentage, 16.03);
      expect(list[7].count, 1);
    });

    test('parses GET /api/v1/expenses/breakdown/priority response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": {
          "P1_Survival": 27200,
          "P2_Protection": 0,
          "P3_Obligations": 0,
          "P4_Growth": 0,
          "P5_Lifestyle": 10220,
          "P6_Luxury": 0
        }
      };

      final pri = ExpensePriorityBreakdown.fromJson(
        jsonResponse['data'] as Map<String, dynamic>,
      );

      expect(pri.p1Survival, 27200.0);
      expect(pri.p2Protection, 0.0);
      expect(pri.p3Obligations, 0.0);
      expect(pri.p4Growth, 0.0);
      expect(pri.p5Lifestyle, 10220.0);
      expect(pri.p6Luxury, 0.0);
    });

    test('parses GET /api/v1/expenses/entries with pagination and full fields', () {
      final jsonResponse = {
        "success": true,
        "data": {
          "expenses": [
            {
              "id": "cmvuk4ro8000bdy92iilxtk2t",
              "invoiceNumber": "INV-EXP-2026-EXP001",
              "description": "Concert & Movie tickets",
              "category": "Entertainment",
              "amount": 3800,
              "date": "30 Oct 2026",
              "paymentMode": "UPI",
              "priority": "P5 - Lifestyle",
              "isRecurring": false,
              "merchant": "Concert & Movie tickets",
              "notes": "",
              "bankAccount": "UPI",
              "documentName": null,
              "documentPath": null,
              "isVerified": true,
              "rawDate": "30 Oct 2026",
              "createdAt": "2026-10-30T05:54:22.616Z"
            },
            {
              "id": "cmvuivhw60001om8hdkuxbtxd",
              "invoiceNumber": "INV-EXP-2025-EXP005",
              "description": "Supermarket Groceries & Provisions",
              "category": "Food",
              "amount": 9000,
              "date": "24 Aug 2025",
              "paymentMode": "UPI",
              "priority": "P1 - Survival",
              "isRecurring": false,
              "merchant": "Nature Basket",
              "notes": "Monthly household staples",
              "bankAccount": "Axis Bank ••••3301",
              "documentName": "1.onboard&Authentaction Screen.png",
              "documentPath":
                  "//opt/render/project/src/backend/uploads/1793337597530-948325580-1.onboard&Authentaction Screen.png",
              "isVerified": true,
              "rawDate": "24 Aug 2025",
              "createdAt": "2026-10-30T05:19:10.422Z"
            }
          ],
          "pagination": {
            "currentPage": 1,
            "perPage": 20,
            "totalRecords": 6,
            "totalPages": 1
          }
        }
      };

      final response = ExpenseEntriesResponse.fromJson(jsonResponse);
      expect(response.expenses.length, 2);
      expect(response.pagination.currentPage, 1);
      expect(response.pagination.totalRecords, 6);
      expect(response.pagination.totalPages, 1);

      final exp1 = response.expenses[0];
      expect(exp1.id, "cmvuk4ro8000bdy92iilxtk2t");
      expect(exp1.invoiceNumber, "INV-EXP-2026-EXP001");
      expect(exp1.category, "Entertainment");
      expect(exp1.amount, 3800.0);
      expect(exp1.paymentMode, "UPI");
      expect(exp1.priority, "P5 - Lifestyle");
      expect(exp1.isRecurring, false);

      final exp2 = response.expenses[1];
      expect(exp2.id, "cmvuivhw60001om8hdkuxbtxd");
      expect(exp2.amount, 9000.0);
      expect(exp2.documentName, "1.onboard&Authentaction Screen.png");
      expect(exp2.documentPath, contains("1.onboard&Authentaction Screen.png"));
    });

    test('verifies POST /api/v1/expenses/entries payload and response parsing', () {
      final postPayload = {
        "description": "Supermarket Groceries & Provisions",
        "category": "Food",
        "amount": 8400.0,
        "date": "24 Aug 2025",
        "paymentMode": "UPI",
        "priority": "P1 - Survival",
        "isRecurring": false,
        "merchant": "Nature Basket",
        "notes": "Monthly household staples",
        "bankAccount": "Axis Bank ••••3301"
      };

      final entry = ExpenseEntry(
        id: '',
        description: postPayload['description'] as String,
        category: postPayload['category'] as String,
        amount: postPayload['amount'] as double,
        date: postPayload['date'] as String,
        paymentMode: postPayload['paymentMode'] as String,
        priority: postPayload['priority'] as String,
        isRecurring: postPayload['isRecurring'] as bool,
        merchant: postPayload['merchant'] as String,
        notes: postPayload['notes'] as String,
        bankAccount: postPayload['bankAccount'] as String,
      );

      final json = entry.toJson();
      expect(json['description'], "Supermarket Groceries & Provisions");
      expect(json['category'], "Food");
      expect(json['amount'], 8400.0);
      expect(json['priority'], "P1 - Survival");
      expect(json['bankAccount'], "Axis Bank ••••3301");

      // Verify POST response parsing
      final postResponse = {
        "success": true,
        "message": "Expense recorded successfully",
        "data": {
          "id": "cmvuozyp40001c1hro8yeqtzh",
          "invoiceNumber": "INV-EXP-2025-EXP007",
          "description": "Supermarket Groceries & Provisions",
          "category": "Food",
          "amount": 8400,
          "date": "24 Aug 2025",
          "paymentMode": "UPI",
          "priority": "P1 - Survival",
          "isRecurring": false,
          "merchant": "Nature Basket",
          "notes": "Monthly household staples",
          "bankAccount": "Axis Bank ••••3301",
          "documentName": null,
          "documentPath": null,
          "budgetImpact": null,
          "createdAt": "2026-10-30T08:10:36.520Z"
        }
      };

      final created = ExpenseEntry.fromJson(postResponse['data'] as Map<String, dynamic>);
      expect(created.id, "cmvuozyp40001c1hro8yeqtzh");
      expect(created.invoiceNumber, "INV-EXP-2025-EXP007");
      expect(created.amount, 8400.0);
      expect(created.category, "Food");
    });

    test('verifies PUT /api/v1/expenses/entries/:id payload and response parsing', () {
      final putResponse = {
        "success": true,
        "message": "Expense updated successfully",
        "data": {
          "id": "cmvuozyp40001c1hro8yeqtzh",
          "invoiceNumber": "INV-EXP-2025-EXP007",
          "description": "Supermarket Groceries & Organic Provisions (Updated)",
          "category": "Food",
          "amount": 8900,
          "date": "24 Aug 2025",
          "paymentMode": "UPI",
          "priority": "P1 - Survival",
          "isRecurring": false,
          "merchant": "Nature Basket Premier",
          "notes": "Monthly household staples amended",
          "bankAccount": "Axis Bank ••••3301",
          "documentName": null,
          "documentPath": null,
          "isVerified": true,
          "rawDate": "24 Aug 2025",
          "createdAt": "2026-10-30T08:10:36.520Z"
        }
      };

      final updated = ExpenseEntry.fromJson(putResponse['data'] as Map<String, dynamic>);
      expect(updated.id, "cmvuozyp40001c1hro8yeqtzh");
      expect(updated.description, "Supermarket Groceries & Organic Provisions (Updated)");
      expect(updated.amount, 8900.0);
      expect(updated.merchant, "Nature Basket Premier");
      expect(updated.notes, "Monthly household staples amended");
    });

    test('verifies DELETE /api/v1/expenses/entries/:id response structure', () {
      final delResponse = {
        "success": true,
        "message": "Expense deleted successfully",
        "data": {
          "id": "cmvuozyp40001c1hro8yeqtzh",
          "deletedAt": "2026-10-30T08:14:53.927Z"
        }
      };

      expect(delResponse['success'], true);
      expect((delResponse['data'] as Map<String, dynamic>)['id'], "cmvuozyp40001c1hro8yeqtzh");
    });

    test('parses GET /api/v1/expenses/detected response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": [
          {
            "detectionId": "det_deb_502",
            "description": "Uber Ride Indiranagar to Airport",
            "suggestedCategory": "Transportation",
            "suggestedPriority": "P1 - Survival",
            "amount": 850,
            "date": "27 Oct 2026",
            "paymentMode": "UPI",
            "bankAccount": "Axis Bank ••••3301",
            "merchant": "Uber India",
            "isDebit": true,
            "confidenceScore": 0.94,
            "channel": "SMS_ALERT"
          }
        ]
      };

      final list = (jsonResponse['data'] as List)
          .map((e) => DetectedExpense.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(list.length, 1);
      final det = list.first;
      expect(det.detectionId, "det_deb_502");
      expect(det.description, "Uber Ride Indiranagar to Airport");
      expect(det.suggestedCategory, "Transportation");
      expect(det.suggestedPriority, "P1 - Survival");
      expect(det.amount, 850.0);
      expect(det.date, "27 Oct 2026");
      expect(det.bankAccount, "Axis Bank ••••3301");
      expect(det.merchant, "Uber India");
      expect(det.isDebit, true);
      expect(det.confidenceScore, 0.94);
      expect(det.channel, "SMS_ALERT");
    });

    test('parses POST /api/v1/expenses/detected/:id/confirm response correctly', () {
      final jsonResponse = {
        "success": true,
        "message": "Expense recorded successfully",
        "data": {
          "id": "cmvupnoxm0003c1hroh6nj9w8",
          "invoiceNumber": "INV-EXP-2026-EXP007",
          "description": "Uber Ride Indiranagar to Airport",
          "category": "Transportation",
          "amount": 850,
          "date": "27 Oct 2026",
          "paymentMode": "UPI",
          "priority": "P1 - Survival",
          "isRecurring": false,
          "merchant": "Uber India",
          "notes": "",
          "bankAccount": "Axis Bank ••••3301",
          "documentName": null,
          "documentPath": null,
          "budgetImpact": null,
          "createdAt": "2026-10-30T08:29:03.611Z"
        }
      };

      final created = ExpenseEntry.fromJson(jsonResponse['data'] as Map<String, dynamic>);
      expect(created.id, "cmvupnoxm0003c1hroh6nj9w8");
      expect(created.invoiceNumber, "INV-EXP-2026-EXP007");
      expect(created.description, "Uber Ride Indiranagar to Airport");
      expect(created.category, "Transportation");
      expect(created.amount, 850.0);
      expect(created.date, "27 Oct 2026");
      expect(created.merchant, "Uber India");
    });

    test('parses POST /api/v1/expenses/receipt-upload response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": {
          "documentName": "rent_agreement_koramangala_1793348664941.pdf",
          "documentPath":
              "//opt/render/project/src/backend/uploads/1793349618863-636674033-rent_agreement_koramangala_1793348664941.pdf",
          "fileSizeBytes": 280,
          "mimeType": "application/pdf",
          "uploadedAt": "2026-10-30T08:40:19.717Z"
        }
      };

      final result = ExpenseReceiptUploadResult.fromJson(
        jsonResponse['data'] as Map<String, dynamic>,
      );

      expect(result.documentName, "rent_agreement_koramangala_1793348664941.pdf");
      expect(result.documentPath, contains("rent_agreement_koramangala"));
      expect(result.fileSizeBytes, 280);
      expect(result.mimeType, "application/pdf");
      expect(result.uploadedAt, "2026-10-30T08:40:19.717Z");
    });

    test('parses GET /api/v1/expenses/entries/:id/invoice response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": {
          "invoiceNumber": "INV-EXP-2026-EXP007",
          "id": "cmvupnoxm0003c1hroh6nj9w8",
          "particularsTitle": "EXPENSE OUTFLOW DETAILS",
          "description": "Uber Ride Indiranagar to Airport",
          "category": "Transportation",
          "amount": 850,
          "amountInWords": "Eight Hundred Fifty Rupees Only",
          "date": "27 Oct 2026",
          "paymentMode": "UPI",
          "priority": "P1 - Survival",
          "isRecurring": false,
          "frequencyLabel": "One-time Discretionary Outflow",
          "merchant": "Uber India",
          "bankAccount": "Axis Bank ••••3301",
          "notes": "",
          "attachedDocumentUrl":
              "//opt/render/project/src/backend/uploads/1793349618863-636674033-rent_agreement_koramangala_1793348664941.pdf",
          "invoicePdfUrl":
              "/api/v1/expenses/entries/cmvupnoxm0003c1hroh6nj9w8/invoice/pdf",
          "complianceStandard":
              "RBI Account Aggregator & Section 65B Indian Evidence Act"
        }
      };

      final inv = ExpenseInvoiceDetails.fromJson(
        jsonResponse['data'] as Map<String, dynamic>,
      );

      expect(inv.invoiceNumber, "INV-EXP-2026-EXP007");
      expect(inv.id, "cmvupnoxm0003c1hroh6nj9w8");
      expect(inv.particularsTitle, "EXPENSE OUTFLOW DETAILS");
      expect(inv.description, "Uber Ride Indiranagar to Airport");
      expect(inv.category, "Transportation");
      expect(inv.amount, 850.0);
      expect(inv.amountInWords, "Eight Hundred Fifty Rupees Only");
      expect(inv.date, "27 Oct 2026");
      expect(inv.paymentMode, "UPI");
      expect(inv.priority, "P1 - Survival");
      expect(inv.isRecurring, false);
      expect(inv.frequencyLabel, "One-time Discretionary Outflow");
      expect(inv.merchant, "Uber India");
      expect(inv.bankAccount, "Axis Bank ••••3301");
      expect(inv.attachedDocumentUrl, contains("rent_agreement_koramangala"));
      expect(inv.invoicePdfUrl, contains("/invoice/pdf"));
      expect(inv.complianceStandard, contains("Section 65B"));
    });
  });
}
