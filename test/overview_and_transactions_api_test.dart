import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/core/constants/api_constants.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';
import 'package:finomos/features/dashboard/domain/overview_and_transaction_models.dart';

void main() {
  group('Overview & Unified Transactions API Model Tests', () {
    test('ApiConstants contains transactions and overview endpoints', () {
      expect(ApiConstants.transactions, '/api/transactions');
      expect(ApiConstants.overview, '/api/overview');
      expect(ApiConstants.directExpense, '/api/expense');
    });

    test(
      'ExpenseEntry parses direct /api/expense response with nested account object',
      () {
        const jsonStr = '''
      [
        {
          "id": "cmvupnoxm0003c1hroh6nj9w8",
          "userId": "cmuzhxi5a000asr4p9f6jcndp",
          "amount": 850,
          "date": "27 Oct 2026",
          "category": "Transportation",
          "description": "Uber Ride Indiranagar to Airport",
          "paymentMode": "UPI",
          "receiptUrl": "//opt/render/project/src/backend/uploads/1793349618863-636674033-rent_agreement_koramangala_1793348664941.pdf",
          "accountId": "cmv6b7bvc00012ak0sy594x7q",
          "accountNumber": "**** 4587",
          "balanceAfter": 27000,
          "transactionStatus": "Completed",
          "remainingBalanceOrCredit": 27000,
          "invoiceNumber": "INV-EXP-2026-EXP007",
          "priority": "P1 - Survival",
          "isRecurring": false,
          "merchant": "Uber India",
          "notes": "",
          "bankAccount": "Axis Bank ••••3301",
          "isVerified": true,
          "createdAt": "2026-10-30T08:29:03.611Z",
          "account": {
            "id": "cmv6b7bvc00012ak0sy594x7q",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "name": "State Bank of India",
            "accountNumber": "**** 4587",
            "rawAccountNumber": "1100224587",
            "ifsc": "SBIN0001234",
            "accountType": "Savings Account",
            "upiId": "sireesha@oksbi",
            "bankBalance": 45250,
            "internalBalance": 27000,
            "openingBalance": 0,
            "isAggregated": true,
            "consentId": "AA-CONSENT-SBIN-8891",
            "logo": "SBI",
            "color": "#1E3A8A",
            "status": "ACTIVE"
          }
        }
      ]
      ''';

        final list = jsonDecode(jsonStr) as List;
        final expense = ExpenseEntry.fromJson(list[0] as Map<String, dynamic>);

        expect(expense.id, 'cmvupnoxm0003c1hroh6nj9w8');
        expect(expense.amount, 850.0);
        expect(expense.category, 'Transportation');
        expect(expense.invoiceNumber, 'INV-EXP-2026-EXP007');
        expect(expense.accountId, 'cmv6b7bvc00012ak0sy594x7q');
        expect(expense.balanceAfter, 27000.0);
        expect(expense.remainingBalanceOrCredit, 27000.0);
        expect(expense.account, isNotNull);
        expect(expense.account!.name, 'State Bank of India');
        expect(expense.account!.bankBalance, 45250.0);
        expect(expense.account!.internalBalance, 27000.0);
        expect(expense.account!.isAggregated, isTrue);
        expect(expense.account!.logo, 'SBI');
        expect(expense.account!.color, '#1E3A8A');
      },
    );

    test(
      'UnifiedTransactionItem parses unified transactions (Income & Expense)',
      () {
        const jsonStr = '''
      [
        {
          "id": "cmvupnoxm0003c1hroh6nj9w8",
          "txnId": "TXN-EXP-6NJ9W8",
          "date": "27 Oct 2026",
          "bankName": "Axis Bank ••••3301",
          "accountNumber": "**** 4587",
          "accountId": "cmv6b7bvc00012ak0sy594x7q",
          "paymentMethod": "UPI",
          "type": "Expense",
          "category": "Transportation",
          "description": "Uber Ride Indiranagar to Airport",
          "amount": 850,
          "balanceAfter": 27000,
          "remainingBalanceOrCredit": 27000,
          "transactionStatus": "Completed",
          "isAggregated": true,
          "sourceType": "EXPENSE",
          "isNegative": true
        },
        {
          "id": "cmvujk2t70003dy923zw1mage",
          "txnId": "TXN-INC-W1MAGE",
          "date": "25 Aug 2025",
          "bankName": "HDFC Bank ••••4587",
          "paymentMethod": "Bank Transfer",
          "type": "Income",
          "category": "Freelance",
          "description": "Freelance UI/UX Project",
          "amount": 28096,
          "transactionStatus": "Completed",
          "isAggregated": false,
          "sourceType": "INCOME",
          "isNegative": false
        }
      ]
      ''';

        final list = (jsonDecode(jsonStr) as List)
            .map(
              (item) =>
                  UnifiedTransactionItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        expect(list.length, 2);

        // Expense
        expect(list[0].id, 'cmvupnoxm0003c1hroh6nj9w8');
        expect(list[0].txnId, 'TXN-EXP-6NJ9W8');
        expect(list[0].isExpense, isTrue);
        expect(list[0].isIncome, isFalse);
        expect(list[0].amount, 850.0);
        expect(list[0].balanceAfter, 27000.0);
        expect(list[0].sourceType, 'EXPENSE');

        // Income
        expect(list[1].id, 'cmvujk2t70003dy923zw1mage');
        expect(list[1].txnId, 'TXN-INC-W1MAGE');
        expect(list[1].isIncome, isTrue);
        expect(list[1].isExpense, isFalse);
        expect(list[1].amount, 28096.0);
        expect(list[1].sourceType, 'INCOME');
      },
    );

    test(
      'DashboardOverviewData parses /api/overview response with accounts array',
      () {
        const jsonStr = '''
      {
        "success": true,
        "data": {
          "totalBalance": 99311,
          "totalBankVerifiedBalance": 127781,
          "totalIncome": 170796,
          "totalExpense": 38270,
          "totalSavings": 132526,
          "totalCreditLimit": 0,
          "totalCreditOutstanding": 0,
          "totalCreditAvailable": 0,
          "debitCardsCount": 0,
          "creditCardsCount": 0,
          "accounts": [
            {
              "id": "cmv6b7bvc00012ak0sy594x7q",
              "name": "State Bank of India",
              "accountNumber": "**** 4587",
              "accountType": "Savings Account",
              "bankBalance": 45250,
              "internalBalance": 27000,
              "isAggregated": true,
              "logo": "SBI",
              "color": "#1E3A8A",
              "status": "ACTIVE"
            },
            {
              "id": "cmv6b96j300032ak0d0o7eoc5",
              "name": "HDFC Bank",
              "accountNumber": "**** 9012",
              "accountType": "Salary Account",
              "bankBalance": 82531,
              "internalBalance": 72311,
              "isAggregated": true,
              "logo": "HDFC",
              "color": "#004C8F",
              "status": "ACTIVE"
            }
          ]
        }
      }
      ''';

        final overview = DashboardOverviewData.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>,
        );

        expect(overview.totalBalance, 99311.0);
        expect(overview.totalBankVerifiedBalance, 127781.0);
        expect(overview.totalIncome, 170796.0);
        expect(overview.totalExpense, 38270.0);
        expect(overview.totalSavings, 132526.0);
        expect(overview.accounts.length, 2);

        final sbi = overview.accounts[0];
        expect(sbi.name, 'State Bank of India');
        expect(sbi.bankBalance, 45250.0);
        expect(sbi.internalBalance, 27000.0);
        expect(sbi.isAggregated, isTrue);

        final hdfc = overview.accounts[1];
        expect(hdfc.name, 'HDFC Bank');
        expect(hdfc.bankBalance, 82531.0);
        expect(hdfc.internalBalance, 72311.0);
      },
    );
  });
}
