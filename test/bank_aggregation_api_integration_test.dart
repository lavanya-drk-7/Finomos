import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/core/constants/api_constants.dart';
import 'package:finomos/features/bank_aggregation/domain/bank_aggregation_models.dart';

void main() {
  group('Bank Aggregation API Contracts & Serialization Tests', () {
    test('1. ApiConstants defines all Bank Aggregation endpoints & URL builders', () {
      expect(ApiConstants.bankAggregationSummary, '/api/v1/bank-aggregation/summary');
      expect(ApiConstants.bankAggregationSyncAll, '/api/v1/bank-aggregation/sync-all');
      expect(ApiConstants.bankAggregationAccounts, '/api/v1/bank-aggregation/accounts');
      expect(
        ApiConstants.bankAggregationLookupIfsc('HDFC0000128'),
        '/api/v1/bank-aggregation/lookup/ifsc/HDFC0000128',
      );
      expect(
        ApiConstants.bankAggregationAccountById('cmvw23qte000714310s2g9e3w'),
        '/api/v1/bank-aggregation/accounts/cmvw23qte000714310s2g9e3w',
      );
      expect(
        ApiConstants.bankAggregationAccountSync('cmvw23qte000714310s2g9e3w'),
        '/api/v1/bank-aggregation/accounts/cmvw23qte000714310s2g9e3w/sync',
      );
      expect(
        ApiConstants.bankAggregationAccountsQuery(type: 'all'),
        '/api/v1/bank-aggregation/accounts?type=all',
      );
    });

    test('2. GET /api/v1/bank-aggregation/summary response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "message": "Consolidated Bank Aggregation Summary retrieved successfully",
        "data": {
          "financialPositions": {
            "totalCash": 110000,
            "bankAccountsCash": 110000,
            "walletsCash": 0,
            "totalInvestments": 252300,
            "totalInvestedPrincipal": 180750,
            "totalInvestmentReturns": 71550,
            "totalDebt": 4455000,
            "creditCardsDebt": 15000,
            "loansDebt": 4440000,
            "netWorth": -4092700,
            "creditUtilizationPercentage": 5,
            "monthlyEmiOutflow": 86400,
            "totalInsuranceCover": 0
          },
          "pillarCounts": {
            "bankAccounts": 2,
            "creditCards": 1,
            "debitCards": 0,
            "totalCards": 1,
            "loans": 2,
            "investments": 1,
            "insurancePolicies": 0,
            "upiAccounts": 0,
            "digitalWallets": 0,
            "activeAaConsents": 0
          },
          "insights": {
            "debtToAssetRatio": 12.3,
            "creditHealthStatus": "HEALTHY",
            "emergencyFundRunwayMonths": 1,
            "aiRecommendation": "Your finances are in excellent standing. Net worth stands at ₹-40,92,700."
          },
          "recentTransactions": [],
          "lastSyncedAt": "2026-11-03T05:01:25.998Z"
        }
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final summary = BankAggregationSummary.fromJson(decoded['data']);

      expect(summary.financialPositions.totalCash, 110000.0);
      expect(summary.financialPositions.bankAccountsCash, 110000.0);
      expect(summary.financialPositions.totalInvestments, 252300.0);
      expect(summary.financialPositions.totalDebt, 4455000.0);
      expect(summary.financialPositions.netWorth, -4092700.0);
      expect(summary.financialPositions.creditUtilizationPercentage, 5.0);
      expect(summary.financialPositions.monthlyEmiOutflow, 86400.0);

      expect(summary.pillarCounts.bankAccounts, 2);
      expect(summary.pillarCounts.creditCards, 1);
      expect(summary.pillarCounts.loans, 2);
      expect(summary.pillarCounts.investments, 1);

      expect(summary.insights.debtToAssetRatio, 12.3);
      expect(summary.insights.creditHealthStatus, 'HEALTHY');
      expect(summary.insights.emergencyFundRunwayMonths, 1);
      expect(summary.insights.aiRecommendation, contains('Net worth stands at'));

      expect(summary.lastSyncedAt, '2026-11-03T05:01:25.998Z');
    });

    test('3. POST /api/v1/bank-aggregation/sync-all response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "message": "Real-time Account Aggregator refresh completed successfully across all 5 financial pillars",
        "data": {
          "syncedAt": "2026-11-03T05:06:31.230Z",
          "refreshedPillars": [
            "Pillar 1: Bank Accounts & Verified Balances",
            "Pillar 2: Credit & Debit Card Limits & Statements",
            "Pillar 3: Active Loans & Monthly EMI Schedules",
            "Pillar 4: Mutual Funds, Equities & EPFO Holdings",
            "Pillar 5: Health & Life Insurance Policies"
          ],
          "syncStatus": "SUCCESS"
        }
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final result = SyncAllPillarsResult.fromJson(decoded['data']);

      expect(result.syncStatus, 'SUCCESS');
      expect(result.syncedAt, '2026-11-03T05:06:31.230Z');
      expect(result.refreshedPillars.length, 5);
      expect(result.refreshedPillars.first, contains('Pillar 1: Bank Accounts'));
    });

    test('4. GET /api/v1/bank-aggregation/lookup/ifsc/:ifsc response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "message": "IFSC resolution successful",
        "data": {
          "ifsc": "HDFC0000128",
          "bank": "HDFC BANK",
          "bankName": "HDFC Bank",
          "bankCode": "HDFC",
          "branch": "CONNAUGHT PLACE",
          "address": "CONNAUGHT PLACE, NEW DELHI - 110001",
          "city": "NEW DELHI",
          "district": "NEW DELHI",
          "state": "DELHI",
          "contact": "011-49400000",
          "micr": "110240001",
          "rtgs": true,
          "neft": true,
          "imps": true,
          "upi": true
        }
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final ifsc = IfscBranchDetails.fromJson(decoded['data']);

      expect(ifsc.ifsc, 'HDFC0000128');
      expect(ifsc.bankName, 'HDFC Bank');
      expect(ifsc.branch, 'CONNAUGHT PLACE');
      expect(ifsc.city, 'NEW DELHI');
      expect(ifsc.state, 'DELHI');
      expect(ifsc.micr, '110240001');
      expect(ifsc.rtgs, isTrue);
      expect(ifsc.neft, isTrue);
      expect(ifsc.imps, isTrue);
      expect(ifsc.upi, isTrue);
    });

    test('5. GET /api/v1/bank-aggregation/accounts response parsing (user contract)', () {
      const jsonStr = '''
      {
        "id": "cmvw23qte000714310s2g9e3w",
        "userId": "cmuzhxi5a000asr4p9f6jcndp",
        "bankName": "HDFC Bank",
        "accountNumber": "••••••••0002",
        "rawAccountNumber": "9876543210002",
        "accountType": "SAVINGS",
        "ifsc": "HDFC0000128",
        "branch": "CONNAUGHT PLACE",
        "openingBalance": 75000,
        "currentBalance": 75000,
        "holderName": "Sireesha Podalakuru",
        "nickname": "Primary HDFC Savings",
        "verificationStatus": "VERIFIED",
        "status": "ACTIVE",
        "lastSyncedAt": "2026-11-03T05:01:25.998Z",
        "createdAt": "2026-11-03T04:30:56.690Z",
        "updatedAt": "2026-11-03T05:01:25.998Z"
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final acc = BankAccountItem.fromJson(decoded);

      expect(acc.id, 'cmvw23qte000714310s2g9e3w');
      expect(acc.bankName, 'HDFC Bank');
      expect(acc.accountHolder, 'Sireesha Podalakuru');
      expect(acc.maskedAccountNumber, '••••••••0002');
      expect(acc.rawAccountNumber, '9876543210002');
      expect(acc.accountType, 'Savings Account');
      expect(acc.ifscCode, 'HDFC0000128');
      expect(acc.branch, 'CONNAUGHT PLACE');
      expect(acc.currentBalance, 75000.0);
      expect(acc.availableBalance, 75000.0);
      expect(acc.verificationStatus, 'VERIFIED');
      expect(acc.status, 'ACTIVE');
      expect(acc.isConnected, isTrue);
    });

    test('6. GET /api/v1/bank-aggregation/accounts (live server format with name & bankBalance)', () {
      const jsonStr = '''
      {
        "id": "cmw07rb9l000goptawdh4r599",
        "userId": "cmuzhxi5a000asr4p9f6jcndp",
        "name": "HDFC Bank",
        "holderName": "Sireesha Podalakuru",
        "nickname": "HDFC Primary Account",
        "accountNumber": "          0483",
        "rawAccountNumber": "50100492810483",
        "ifsc": "HDFC0000128",
        "branch": "CHENNAI - CREDIT CARD OPERATIONS",
        "city": "CHENNAI",
        "state": "TAMIL NADU",
        "accountType": "Savings Account",
        "bankBalance": 65000,
        "internalBalance": 64500,
        "openingBalance": 65000,
        "isAggregated": true,
        "verificationStatus": "Verified",
        "status": "ACTIVE",
        "lastSyncedAt": "2026-11-03T05:16:40.949Z"
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final acc = BankAccountItem.fromJson(decoded);

      expect(acc.id, 'cmw07rb9l000goptawdh4r599');
      expect(acc.bankName, 'HDFC Bank');
      expect(acc.currentBalance, 65000.0);
      expect(acc.availableBalance, 64500.0);
      expect(acc.branch, 'CHENNAI - CREDIT CARD OPERATIONS');
      expect(acc.city, 'CHENNAI');
      expect(acc.state, 'TAMIL NADU');
      expect(acc.isConnected, isTrue);
    });

    test('7. POST /api/v1/bank-aggregation/accounts Link Request serialization', () {
      const req = LinkBankAccountRequest(
        accountNumber: '12345678901234',
        confirmAccountNumber: '12345678901234',
        ifsc: 'HDFC0000128',
        accountType: 'SAVINGS',
        openingBalance: 50000.0,
        holderName: 'Sireesha Podalakuru',
        nickname: 'Personal Savings',
      );

      final map = req.toJson();
      expect(map['accountNumber'], '12345678901234');
      expect(map['confirmAccountNumber'], '12345678901234');
      expect(map['ifsc'], 'HDFC0000128');
      expect(map['accountType'], 'SAVINGS');
      expect(map['openingBalance'], 50000.0);
      expect(map['holderName'], 'Sireesha Podalakuru');
      expect(map['nickname'], 'Personal Savings');
    });

    test('8. PUT /api/v1/bank-aggregation/accounts/:id Update Request serialization', () {
      const req = UpdateBankAccountRequest(
        nickname: 'Primary HDFC Salary Account',
        accountType: 'SALARY',
      );

      final map = req.toJson();
      expect(map['nickname'], 'Primary HDFC Salary Account');
      expect(map['accountType'], 'SALARY');
    });

    test('9. POST /api/v1/bank-aggregation/accounts/:id/sync response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "message": "Bank account balance synced successfully",
        "data": {
          "accountId": "cmvw23qte000714310s2g9e3w",
          "currentBalance": 75000,
          "lastSyncedAt": "2026-11-03T07:00:15.123Z"
        }
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final syncRes = SyncAccountBalanceResult.fromJson(decoded['data']);

      expect(syncRes.accountId, 'cmvw23qte000714310s2g9e3w');
      expect(syncRes.currentBalance, 75000.0);
      expect(syncRes.lastSyncedAt, '2026-11-03T07:00:15.123Z');
    });

    test('10. GET /api/v1/bank-aggregation/accounts/:id with nested expenses parsing', () {
      const jsonStr = '''
      {
        "id": "cmw07rb9l000goptawdh4r599",
        "name": "HDFC Bank",
        "accountType": "Savings Account",
        "rawAccountNumber": "50100492810483",
        "ifsc": "HDFC0000128",
        "currentBalance": 65000,
        "expenses": [
          {
            "id": "cmw08af2n0019optaldm2yl7z",
            "amount": 500,
            "date": "15 Oct 2026",
            "category": "Groceries",
            "description": "Manual Groceries",
            "paymentMode": "UPI",
            "invoiceNumber": "INV-EXP-2026-EXP049",
            "balanceAfter": 64500,
            "isVerified": true
          }
        ]
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final acc = BankAccountItem.fromJson(decoded);

      expect(acc.expenses, isNotNull);
      expect(acc.expenses!.length, 1);
      expect(acc.expenses!.first.category, 'Groceries');
      expect(acc.expenses!.first.amount, 500.0);
      expect(acc.expenses!.first.balanceAfter, 64500.0);
    });

    test('11. Cards API endpoints in ApiConstants', () {
      expect(ApiConstants.bankAggregationCards, '/api/v1/bank-aggregation/cards');
      expect(ApiConstants.bankAggregationCardsQuery(type: 'all'), '/api/v1/bank-aggregation/cards?type=all');
      expect(ApiConstants.bankAggregationCardById('cmw07t0yz000kopta6781dqwp'), '/api/v1/bank-aggregation/cards/cmw07t0yz000kopta6781dqwp');
    });

    test('12. GET /api/v1/bank-aggregation/cards?type=all response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "summary": {
          "totalCreditCards": 1,
          "totalDebitCards": 0,
          "totalCreditLimit": 300000,
          "totalOutstanding": 15000,
          "totalAvailableCredit": 285000,
          "totalRewardPoints": 8500,
          "utilizationPercentage": 5
        },
        "data": {
          "creditCards": [
            {
              "id": "cmw07t0yz000kopta6781dqwp",
              "userId": "cmuzhxi5a000asr4p9f6jcndp",
              "cardholderName": "SIREESHA PODALAKURU",
              "cardNickname": "Axis Magnus Metal",
              "issuingBank": "Axis Bank",
              "network": "Visa",
              "cardType": "Credit",
              "lastFourDigits": "8921",
              "creditLimit": 300000,
              "currentOutstanding": 15000,
              "availableCredit": 285000,
              "billingCycleDate": "20th of month",
              "paymentDueDate": "2026-12-10",
              "minimumDue": 1425,
              "rewardPoints": 8500,
              "totalCashLimit": 50000,
              "expiryMonth": "12",
              "expiryYear": "29",
              "status": "Active",
              "isAggregated": true,
              "verificationStatus": "AA Verified",
              "color": "#1B2559",
              "createdAt": "2026-11-03T04:55:56.460Z",
              "updatedAt": "2026-11-03T04:56:54.804Z"
            }
          ],
          "debitCards": []
        }
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final cardsRes = CardsApiResponse.fromJson(decoded);

      expect(cardsRes.summary.totalCreditCards, 1);
      expect(cardsRes.summary.totalCreditLimit, 300000.0);
      expect(cardsRes.summary.totalOutstanding, 15000.0);
      expect(cardsRes.summary.totalAvailableCredit, 285000.0);
      expect(cardsRes.summary.totalRewardPoints, 8500);
      expect(cardsRes.summary.utilizationPercentage, 5.0);

      expect(cardsRes.creditCards.length, 1);
      final card = cardsRes.creditCards.first;
      expect(card.id, 'cmw07t0yz000kopta6781dqwp');
      expect(card.cardHolderName, 'SIREESHA PODALAKURU');
      expect(card.cardName, 'Axis Magnus Metal');
      expect(card.issuedBank, 'Axis Bank');
      expect(card.cardType, 'Visa');
      expect(card.last4Digits, '8921');
      expect(card.creditLimit, 300000.0);
      expect(card.outstandingBalance, 15000.0);
      expect(card.availableCredit, 285000.0);
      expect(card.statementDueDate, '2026-12-10');
      expect(card.minimumDue, 1425.0);
      expect(card.rewardPoints, 8500);
      expect(card.isDebit, isFalse);
    });

    test('13. POST /api/v1/bank-aggregation/cards link request & response parsing', () {
      const req = LinkCreditCardRequest(
        cardType: 'Credit',
        issuingBank: 'Axis Bank',
        cardholderName: 'SIREESHA PODALAKURU',
        network: 'Visa',
        lastFourDigits: '8921',
        creditLimit: 250000,
        currentOutstanding: 28500,
        billingCycleDate: '20th of month',
        paymentDueDate: '2026-12-10',
        rewardPoints: 8500,
      );

      final map = req.toJson();
      expect(map['issuingBank'], 'Axis Bank');
      expect(map['lastFourDigits'], '8921');
      expect(map['creditLimit'], 250000);
      expect(map['currentOutstanding'], 28500);

      const resJson = '''
      {
        "id": "cmw08vlcs001vopta3n9l9abg",
        "userId": "cmuzhxi5a000asr4p9f6jcndp",
        "cardholderName": "SIREESHA PODALAKURU",
        "cardNickname": "Axis Bank Credit Card",
        "issuingBank": "Axis Bank",
        "network": "Visa",
        "cardType": "Credit",
        "lastFourDigits": "8921",
        "creditLimit": 250000,
        "currentOutstanding": 28500,
        "availableCredit": 221500,
        "billingCycleDate": "20th of month",
        "paymentDueDate": "2026-12-10",
        "minimumDue": 1425,
        "rewardPoints": 8500,
        "totalCashLimit": 50000,
        "expiryMonth": "12",
        "expiryYear": "29",
        "status": "Active"
      }
      ''';
      final card = CreditCardItem.fromJson(jsonDecode(resJson));
      expect(card.id, 'cmw08vlcs001vopta3n9l9abg');
      expect(card.cardName, 'Axis Bank Credit Card');
      expect(card.creditLimit, 250000.0);
      expect(card.availableCredit, 221500.0);
    });

    test('14. PUT /api/v1/bank-aggregation/cards/:id update request serialization', () {
      const updateReq = UpdateCreditCardRequest(
        creditLimit: 300000,
        currentOutstanding: 15000,
        cardNickname: 'Axis Magnus Metal',
      );
      final map = updateReq.toJson();
      expect(map['creditLimit'], 300000);
      expect(map['currentOutstanding'], 15000);
      expect(map['cardNickname'], 'Axis Magnus Metal');
    });

    test('15. Loans API endpoints in ApiConstants', () {
      expect(ApiConstants.bankAggregationLoans, '/api/v1/bank-aggregation/loans');
      expect(ApiConstants.bankAggregationLoanById('cmw07wbnb000roptaxnpdur4j'), '/api/v1/bank-aggregation/loans/cmw07wbnb000roptaxnpdur4j');
    });

    test('16. GET /api/v1/bank-aggregation/loans response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "count": 2,
        "summary": {
          "totalSanctionedAmount": 5600000,
          "totalOutstandingPrincipal": 4440000,
          "totalMonthlyEmiBurden": 86400
        },
        "data": [
          {
            "id": "cmw07wbnb000roptaxnpdur4j",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "lenderName": "HDFC Bank",
            "loanType": "Home Loan",
            "accountNumber": "HL-HDFC-948107",
            "sanctionedAmount": 600000,
            "outstandingPrincipal": 490000,
            "interestRate": 8.4,
            "monthlyEmi": 43200,
            "totalTenureMonths": 240,
            "remainingTenureMonths": 172,
            "startDate": "2026-11-03",
            "endDate": null,
            "nextEmiDate": "2026-12-05",
            "interestType": "Floating",
            "status": "ACTIVE",
            "isAggregated": true,
            "createdAt": "2026-11-03T04:58:30.263Z",
            "updatedAt": "2026-11-03T04:58:30.263Z"
          }
        ]
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final loansRes = LoansApiResponse.fromJson(decoded);

      expect(loansRes.count, 2);
      expect(loansRes.summary.totalSanctionedAmount, 5600000.0);
      expect(loansRes.summary.totalOutstandingPrincipal, 4440000.0);
      expect(loansRes.summary.totalMonthlyEmiBurden, 86400.0);

      expect(loansRes.loans.length, 1);
      final loan = loansRes.loans.first;
      expect(loan.id, 'cmw07wbnb000roptaxnpdur4j');
      expect(loan.lender, 'HDFC Bank');
      expect(loan.loanType, 'Home Loan');
      expect(loan.accountNumber, 'HL-HDFC-948107');
      expect(loan.sanctionedAmount, 600000.0);
      expect(loan.outstandingPrincipal, 490000.0);
      expect(loan.interestRate, 8.4);
      expect(loan.monthlyEmi, 43200.0);
      expect(loan.tenureRemainingMonths, 172);
      expect(loan.nextDueDate, '2026-12-05');
      expect(loan.interestType, 'Floating');
    });

    test('17. POST /api/v1/bank-aggregation/loans link request & response parsing', () {
      const req = LinkLoanRequest(
        lenderName: 'HDFC Bank',
        loanType: 'Home Loan',
        accountNumber: 'HL-HDFC-948102',
        sanctionedAmount: 5000000,
        outstandingPrincipal: 4100000,
        interestRate: 8.4,
        monthlyEmi: 43200,
        totalTenureMonths: 240,
        remainingTenureMonths: 172,
        nextEmiDate: '2026-12-05',
      );

      final map = req.toJson();
      expect(map['lenderName'], 'HDFC Bank');
      expect(map['sanctionedAmount'], 5000000);
      expect(map['monthlyEmi'], 43200);

      const resJson = '''
      {
        "id": "cmw08ldan001nopta0zvad81f",
        "userId": "cmuzhxi5a000asr4p9f6jcndp",
        "lenderName": "HDFC Bank",
        "loanType": "Home Loan",
        "accountNumber": "HL-HDFC-948102",
        "sanctionedAmount": 5000000,
        "outstandingPrincipal": 4100000,
        "interestRate": 8.4,
        "monthlyEmi": 43200,
        "totalTenureMonths": 240,
        "remainingTenureMonths": 172,
        "startDate": "2026-11-03",
        "nextEmiDate": "2026-12-05",
        "status": "ACTIVE"
      }
      ''';
      final loan = LoanAccountItem.fromJson(jsonDecode(resJson));
      expect(loan.id, 'cmw08ldan001nopta0zvad81f');
      expect(loan.outstandingPrincipal, 4100000.0);
      expect(loan.tenureRemainingMonths, 172);
    });

    test('18. PUT /api/v1/bank-aggregation/loans/:id update request serialization', () {
      const updateReq = UpdateLoanRequest(
        outstandingPrincipal: 3950000,
        remainingTenureMonths: 165,
      );
      final map = updateReq.toJson();
      expect(map['outstandingPrincipal'], 3950000);
      expect(map['remainingTenureMonths'], 165);
    });

    test('19. Investments API endpoints in ApiConstants', () {
      expect(ApiConstants.bankAggregationInvestments, '/api/v1/bank-aggregation/investments');
      expect(ApiConstants.bankAggregationInvestmentById('cmw07zilb000toptatyos652h'), '/api/v1/bank-aggregation/investments/cmw07zilb000toptatyos652h');
    });

    test('20. GET /api/v1/bank-aggregation/investments response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "count": 2,
        "portfolioSummary": {
          "totalInvestedAmount": 361500,
          "totalCurrentValue": 504600,
          "totalAbsoluteReturns": 143100,
          "overallReturnPercentage": 39.59,
          "assetAllocation": {
            "MUTUAL_FUNDS": {
              "count": 1,
              "currentValue": 252300,
              "investedAmount": 180750
            },
            "RENTS": {
              "count": 1,
              "currentValue": 252300,
              "investedAmount": 180750
            }
          }
        },
        "data": [
          {
            "id": "cmw07zilb000toptatyos652h",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "assetType": "MUTUAL_FUNDS",
            "name": "UTI Nifty 50 Index Fund Direct Growth",
            "symbolOrFolio": "UTI-N50-1092",
            "platform": "Groww",
            "quantity": 1500,
            "buyNavOrPrice": 120.5,
            "investedAmount": 180750,
            "currentNavOrPrice": 168.2,
            "currentValue": 252300,
            "absoluteReturn": 71550,
            "returnPercentage": 39.59,
            "xirr": 0,
            "asOfDate": "2026-11-03",
            "isAggregated": true,
            "createdAt": "2026-11-03T05:00:59.231Z",
            "updatedAt": "2026-11-03T05:00:59.231Z"
          }
        ]
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final invRes = InvestmentsApiResponse.fromJson(decoded);

      expect(invRes.count, 2);
      expect(invRes.portfolioSummary.totalInvestedAmount, 361500.0);
      expect(invRes.portfolioSummary.totalCurrentValue, 504600.0);
      expect(invRes.portfolioSummary.totalAbsoluteReturns, 143100.0);
      expect(invRes.portfolioSummary.overallReturnPercentage, 39.59);
      expect(invRes.portfolioSummary.assetAllocation.containsKey('MUTUAL_FUNDS'), isTrue);
      expect(invRes.portfolioSummary.assetAllocation['MUTUAL_FUNDS']?.currentValue, 252300.0);

      expect(invRes.investments.length, 1);
      final inv = invRes.investments.first;
      expect(inv.id, 'cmw07zilb000toptatyos652h');
      expect(inv.name, 'UTI Nifty 50 Index Fund Direct Growth');
      expect(inv.symbolOrFolio, 'UTI-N50-1092');
      expect(inv.platform, 'Groww');
      expect(inv.quantity, 1500.0);
      expect(inv.buyNavOrPrice, 120.5);
      expect(inv.investedValue, 180750.0);
      expect(inv.currentNavOrPrice, 168.2);
      expect(inv.currentValue, 252300.0);
      expect(inv.absoluteReturn, 71550.0);
      expect(inv.returnPercentage, 39.59);
      expect(inv.isPositive, isTrue);
    });

    test('21. POST /api/v1/bank-aggregation/investments link request & response parsing', () {
      const req = LinkInvestmentRequest(
        assetType: 'MUTUAL_FUNDS',
        name: 'UTI Nifty 50 Index Fund Direct Growth',
        symbolOrFolio: 'UTI-N50-1092',
        platform: 'Groww',
        quantity: 1500,
        buyNavOrPrice: 120.5,
        currentNavOrPrice: 168.2,
      );

      final map = req.toJson();
      expect(map['assetType'], 'MUTUAL_FUNDS');
      expect(map['name'], 'UTI Nifty 50 Index Fund Direct Growth');
      expect(map['quantity'], 1500);

      const resJson = '''
      {
        "id": "cmw09cm35001xopta819j80bh",
        "userId": "cmuzhxi5a000asr4p9f6jcndp",
        "assetType": "MUTUAL_FUNDS",
        "name": "UTI Nifty 50 Index Fund Direct Growth",
        "symbolOrFolio": "UTI-N50-1092",
        "platform": "Groww",
        "quantity": 1500,
        "buyNavOrPrice": 120.5,
        "investedAmount": 180750,
        "currentNavOrPrice": 168.2,
        "currentValue": 252300,
        "absoluteReturn": 71550,
        "returnPercentage": 39.59,
        "asOfDate": "2026-11-03"
      }
      ''';
      final inv = InvestmentHoldingItem.fromJson(jsonDecode(resJson));
      expect(inv.id, 'cmw09cm35001xopta819j80bh');
      expect(inv.currentValue, 252300.0);
      expect(inv.absoluteReturn, 71550.0);
    });

    test('22. PUT /api/v1/bank-aggregation/investments/:id update request serialization', () {
      const updateReq = UpdateInvestmentRequest(currentNavOrPrice: 174.5);
      final map = updateReq.toJson();
      expect(map['currentNavOrPrice'], 174.5);
    });
    test('23. Insurance API endpoints in ApiConstants', () {
      expect(ApiConstants.bankAggregationInsurance, '/api/v1/bank-aggregation/insurance');
      expect(
        ApiConstants.bankAggregationInsuranceById('ins_987'),
        '/api/v1/bank-aggregation/insurance/ins_987',
      );
    });

    test('24. GET /api/v1/bank-aggregation/insurance response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "count": 2,
        "summary": {
          "totalSumInsuredCoverage": 4500000,
          "totalAnnualPremiumOutflow": 55900,
          "activePoliciesCount": 2
        },
        "data": [
          {
            "id": "cmw08582c0013optasbpzb3lr",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "insuranceType": "HEALTH",
            "policyName": "Niva Bupa ReAssure 2.0 Titanium",
            "policyNumber": "POL-NIVA-491028",
            "providerName": "Niva Bupa Health Insurance",
            "sumInsured": 2000000,
            "annualPremium": 26400,
            "policyStartDate": "2026-11-03",
            "renewalDate": "2027-10-15",
            "paymentFrequency": "Annually",
            "nomineeName": "Sireesha Podalakuru",
            "nomineeRelation": "Self",
            "status": "ACTIVE",
            "documentPath": null,
            "isAggregated": true,
            "createdAt": "2026-11-03T05:05:25.524Z",
            "updatedAt": "2026-11-03T05:05:25.524Z"
          },
          {
            "id": "cmw088cv90015optar9wlgpmw",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "insuranceType": "CAR",
            "policyName": "Niva Bupa ReAssure 2.0 Titanium",
            "policyNumber": "POL-NIVA-491028",
            "providerName": "Niva Bupa Health Insurance",
            "sumInsured": 2500000,
            "annualPremium": 29500,
            "policyStartDate": "2026-11-03",
            "renewalDate": "2027-10-15",
            "paymentFrequency": "Annually",
            "nomineeName": "Sireesha Podalakuru",
            "nomineeRelation": "Self",
            "status": "ACTIVE",
            "documentPath": null,
            "isAggregated": true,
            "createdAt": "2026-11-03T05:07:51.718Z",
            "updatedAt": "2026-11-03T05:08:42.966Z"
          }
        ]
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final insRes = InsurancePoliciesApiResponse.fromJson(decoded);

      expect(insRes.success, isTrue);
      expect(insRes.count, 2);
      expect(insRes.summary.totalSumInsuredCoverage, 4500000.0);
      expect(insRes.summary.totalAnnualPremiumOutflow, 55900.0);
      expect(insRes.summary.activePoliciesCount, 2);

      expect(insRes.policies.length, 2);
      final p1 = insRes.policies.first;
      expect(p1.id, 'cmw08582c0013optasbpzb3lr');
      expect(p1.insuranceType, 'HEALTH');
      expect(p1.policyName, 'Niva Bupa ReAssure 2.0 Titanium');
      expect(p1.policyNumber, 'POL-NIVA-491028');
      expect(p1.providerName, 'Niva Bupa Health Insurance');
      expect(p1.sumInsured, 2000000.0);
      expect(p1.coverageAmount, 2000000.0);
      expect(p1.annualPremium, 26400.0);
      expect(p1.premiumAmount, 26400.0);
      expect(p1.nomineeName, 'Sireesha Podalakuru');
      expect(p1.nomineeRelation, 'Self');
      expect(p1.isAggregated, isTrue);
    });

    test('25. POST /api/v1/bank-aggregation/insurance link request & response parsing', () {
      const req = LinkInsurancePolicyRequest(
        insuranceType: 'HEALTH',
        policyName: 'Niva Bupa ReAssure 2.0 Titanium',
        policyNumber: 'POL-NIVA-491028',
        providerName: 'Niva Bupa Health Insurance',
        sumInsured: 2000000,
        annualPremium: 26400,
        renewalDate: '2027-10-15',
        nomineeName: 'Sireesha Podalakuru',
        nomineeRelation: 'Self',
      );

      final map = req.toJson();
      expect(map['insuranceType'], 'HEALTH');
      expect(map['policyName'], 'Niva Bupa ReAssure 2.0 Titanium');
      expect(map['sumInsured'], 2000000);
      expect(map['annualPremium'], 26400);

      const resJson = '''
      {
        "success": true,
        "message": "Insurance policy linked successfully",
        "data": {
          "id": "cmw09lwwm0023optabcr7hj55",
          "userId": "cmuzhxi5a000asr4p9f6jcndp",
          "insuranceType": "HEALTH",
          "policyName": "Niva Bupa ReAssure 2.0 Titanium",
          "policyNumber": "POL-NIVA-491028",
          "providerName": "Niva Bupa Health Insurance",
          "sumInsured": 2000000,
          "annualPremium": 26400,
          "policyStartDate": "2026-11-03",
          "renewalDate": "2027-10-15",
          "paymentFrequency": "Annually",
          "nomineeName": "Sireesha Podalakuru",
          "nomineeRelation": "Self",
          "status": "ACTIVE",
          "documentPath": null,
          "isAggregated": true,
          "createdAt": "2026-11-03T05:46:23.831Z",
          "updatedAt": "2026-11-03T05:46:23.831Z"
        }
      }
      ''';
      final Map<String, dynamic> decoded = jsonDecode(resJson);
      final pol = InsurancePolicyItem.fromJson(decoded['data']);
      expect(pol.id, 'cmw09lwwm0023optabcr7hj55');
      expect(pol.sumInsured, 2000000.0);
      expect(pol.annualPremium, 26400.0);
    });

    test('26. PUT /api/v1/bank-aggregation/insurance/:id update request & response parsing', () {
      const updateReq = UpdateInsurancePolicyRequest(
        sumInsured: 2500000,
        annualPremium: 29500,
      );
      final map = updateReq.toJson();
      expect(map['sumInsured'], 2500000);
      expect(map['annualPremium'], 29500);

      const resJson = '''
      {
        "success": true,
        "message": "Insurance policy updated successfully",
        "data": {
          "id": "cmw09lwwm0023optabcr7hj55",
          "userId": "cmuzhxi5a000asr4p9f6jcndp",
          "insuranceType": "HEALTH",
          "policyName": "Niva Bupa ReAssure 2.0 Titanium",
          "policyNumber": "POL-NIVA-491028",
          "providerName": "Niva Bupa Health Insurance",
          "sumInsured": 2500000,
          "annualPremium": 29500,
          "policyStartDate": "2026-11-03",
          "renewalDate": "2027-10-15",
          "paymentFrequency": "Annually",
          "nomineeName": "Sireesha Podalakuru",
          "nomineeRelation": "Self",
          "status": "ACTIVE",
          "documentPath": null,
          "isAggregated": true,
          "createdAt": "2026-11-03T05:46:23.831Z",
          "updatedAt": "2026-11-03T05:47:38.008Z"
        }
      }
      ''';
      final Map<String, dynamic> decoded = jsonDecode(resJson);
      final updatedPol = InsurancePolicyItem.fromJson(decoded['data']);
      expect(updatedPol.sumInsured, 2500000.0);
      expect(updatedPol.annualPremium, 29500.0);
    });

    test('27. DELETE /api/v1/bank-aggregation/insurance/:id response contract', () {
      const delJson = '''
      {
        "success": true,
        "message": "Insurance policy record removed successfully",
        "deletedPolicyId": "cmw09lwwm0023optabcr7hj55"
      }
      ''';
      final Map<String, dynamic> decoded = jsonDecode(delJson);
      expect(decoded['success'], isTrue);
      expect(decoded['deletedPolicyId'], 'cmw09lwwm0023optabcr7hj55');
    });

    test('28. UPI API endpoints in ApiConstants', () {
      expect(ApiConstants.bankAggregationUpiAccounts, '/api/v1/bank-aggregation/upi-accounts');
      expect(
        ApiConstants.bankAggregationUpiAccountById('upi_123'),
        '/api/v1/bank-aggregation/upi-accounts/upi_123',
      );
      expect(
        ApiConstants.bankAggregationUpiSetPrimary('upi_123'),
        '/api/v1/bank-aggregation/upi-accounts/upi_123/set-primary',
      );
    });

    test('29. GET /api/v1/bank-aggregation/upi-accounts response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "count": 2,
        "primaryVpa": "sireesha@okaxis",
        "data": [
          {
            "id": "cmw08d170001foptajnghhdkn",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "vpa": "sireesha@okaxis",
            "bankName": "Axis Bank",
            "bankAccountId": null,
            "appProvider": "phone pay",
            "isPrimary": true,
            "status": "ACTIVE",
            "createdAt": "2026-11-03T05:11:29.868Z",
            "updatedAt": "2026-11-03T05:12:53.398Z"
          },
          {
            "id": "cmw08bknz001doptatcn3exuv",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "vpa": "sireesha@okaxis",
            "bankName": "Axis Bank",
            "bankAccountId": null,
            "appProvider": "Google Pay",
            "isPrimary": false,
            "status": "ACTIVE",
            "createdAt": "2026-11-03T05:10:21.791Z",
            "updatedAt": "2026-11-03T05:12:52.684Z"
          }
        ]
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final upiRes = UpiAccountsApiResponse.fromJson(decoded);

      expect(upiRes.success, isTrue);
      expect(upiRes.count, 2);
      expect(upiRes.primaryVpa, 'sireesha@okaxis');
      expect(upiRes.accounts.length, 2);

      final a1 = upiRes.accounts.first;
      expect(a1.id, 'cmw08d170001foptajnghhdkn');
      expect(a1.vpa, 'sireesha@okaxis');
      expect(a1.bankName, 'Axis Bank');
      expect(a1.appProvider, 'phone pay');
      expect(a1.isPrimary, isTrue);
      expect(a1.status, 'ACTIVE');

      final a2 = upiRes.accounts[1];
      expect(a2.id, 'cmw08bknz001doptatcn3exuv');
      expect(a2.isPrimary, isFalse);
    });

    test('30. POST /api/v1/bank-aggregation/upi-accounts link request & response parsing', () {
      const req = LinkUpiAccountRequest(
        vpa: 'sireesha@okaxis',
        bankName: 'Axis Bank',
        appProvider: 'Google Pay',
        isPrimary: true,
      );

      final map = req.toJson();
      expect(map['vpa'], 'sireesha@okaxis');
      expect(map['bankName'], 'Axis Bank');
      expect(map['appProvider'], 'Google Pay');
      expect(map['isPrimary'], isTrue);

      const resJson = '''
      {
        "success": true,
        "message": "UPI ID linked successfully",
        "data": {
          "id": "cmw09sw4h0025optaoap0vsft",
          "userId": "cmuzhxi5a000asr4p9f6jcndp",
          "vpa": "sireesha@okaxis",
          "bankName": "Axis Bank",
          "bankAccountId": null,
          "appProvider": "Google Pay",
          "isPrimary": true,
          "status": "ACTIVE",
          "createdAt": "2026-11-03T05:51:49.409Z",
          "updatedAt": "2026-11-03T05:51:49.409Z"
        }
      }
      ''';
      final Map<String, dynamic> decoded = jsonDecode(resJson);
      final upi = UpiAccountItem.fromJson(decoded['data']);
      expect(upi.id, 'cmw09sw4h0025optaoap0vsft');
      expect(upi.vpa, 'sireesha@okaxis');
      expect(upi.isPrimary, isTrue);
    });

    test('31. PATCH set-primary and DELETE UPI responses', () {
      const patchJson = '''
      {
        "success": true,
        "message": "UPI ID sireesha@okaxis is now set as primary routing VPA",
        "data": {
          "id": "cmw09sw4h0025optaoap0vsft",
          "userId": "cmuzhxi5a000asr4p9f6jcndp",
          "vpa": "sireesha@okaxis",
          "bankName": "Axis Bank",
          "bankAccountId": null,
          "appProvider": "Google Pay",
          "isPrimary": true,
          "status": "ACTIVE"
        }
      }
      ''';
      final Map<String, dynamic> pDec = jsonDecode(patchJson);
      final primUpi = UpiAccountItem.fromJson(pDec['data']);
      expect(primUpi.isPrimary, isTrue);

      const delJson = '''
      {
        "success": true,
        "message": "UPI ID delinked successfully",
        "deletedUpiId": "cmw09sw4h0025optaoap0vsft"
      }
      ''';
      final Map<String, dynamic> dDec = jsonDecode(delJson);
      expect(dDec['success'], isTrue);
      expect(dDec['deletedUpiId'], 'cmw09sw4h0025optaoap0vsft');
    });

    test('32. Wallets API endpoints in ApiConstants & GET / POST response parsing', () {
      expect(ApiConstants.bankAggregationWallets, '/api/v1/bank-aggregation/wallets');
      expect(
        ApiConstants.bankAggregationWalletById('wal_123'),
        '/api/v1/bank-aggregation/wallets/wal_123',
      );

      const getJson = '''
      {
        "success": true,
        "count": 1,
        "totalWalletBalance": 1500,
        "data": [
          {
            "id": "cmw08fbya001hoptaxw39wo1v",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "walletName": "Mobikwik Wallet",
            "walletProvider": "Mobikwik",
            "balance": 1500,
            "linkedMobile": "9353546464",
            "isKycDone": true,
            "status": "ACTIVE",
            "createdAt": "2026-11-03T05:13:17.122Z",
            "updatedAt": "2026-11-03T05:13:17.122Z"
          }
        ]
      }
      ''';

      final Map<String, dynamic> gDec = jsonDecode(getJson);
      final walletsRes = WalletsApiResponse.fromJson(gDec);

      expect(walletsRes.success, isTrue);
      expect(walletsRes.count, 1);
      expect(walletsRes.totalWalletBalance, 1500.0);
      expect(walletsRes.wallets.length, 1);

      final w = walletsRes.wallets.first;
      expect(w.id, 'cmw08fbya001hoptaxw39wo1v');
      expect(w.walletName, 'Mobikwik Wallet');
      expect(w.walletProvider, 'Mobikwik');
      expect(w.balance, 1500.0);
      expect(w.linkedMobile, '9353546464');
      expect(w.isKycDone, isTrue);

      const postReq = LinkWalletRequest(
        walletName: 'Mobikwik Wallet',
        walletProvider: 'Mobikwik',
        balance: 1500,
        linkedMobile: '9353546464',
      );
      final reqMap = postReq.toJson();
      expect(reqMap['walletName'], 'Mobikwik Wallet');
      expect(reqMap['balance'], 1500);
      expect(reqMap['linkedMobile'], '9353546464');
    });
    test('33. Consents, Transactions & Institutions API endpoints in ApiConstants', () {
      expect(ApiConstants.bankAggregationConsents, '/api/v1/bank-aggregation/consents');
      expect(ApiConstants.bankAggregationConsentInitiate, '/api/v1/bank-aggregation/consents/initiate');
      expect(
        ApiConstants.bankAggregationConsentRevoke('consent_123'),
        '/api/v1/bank-aggregation/consents/consent_123/revoke',
      );
      expect(
        ApiConstants.bankAggregationConsentRenew('consent_123'),
        '/api/v1/bank-aggregation/consents/consent_123/renew',
      );
      expect(ApiConstants.bankAggregationTransactions, '/api/v1/bank-aggregation/transactions');
      expect(
        ApiConstants.bankAggregationTransactionsQuery(page: 1, limit: 20),
        '/api/v1/bank-aggregation/transactions?limit=20&page=1',
      );
      expect(ApiConstants.bankAggregationInstitutions, '/api/v1/bank-aggregation/institutions');
    });

    test('34. GET /api/v1/bank-aggregation/consents response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "count": 1,
        "activeConsentsCount": 1,
        "data": [
          {
            "id": "cmw08gqfx001jopta5jiavr1u",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "consentHandle": "AA-REQ-1793682862385-8565",
            "consentArtifactId": "ART-FIP-ICICI-01-1793682862385",
            "fipId": "FIP-ICICI-01",
            "fipName": "ICICI Bank Ltd",
            "fiTypes": "DEPOSIT,TERM_DEPOSIT,CREDIT_CARD",
            "consentMode": "VIEW",
            "fetchType": "PERIODIC",
            "dataFrequency": "DAILY",
            "status": "ACTIVE",
            "validFrom": "2026-11-03T05:14:22.385Z",
            "validTo": "2027-11-03T05:14:52.268Z",
            "lastSyncedAt": "2026-11-03T05:25:30.753Z",
            "createdAt": "2026-11-03T05:14:22.386Z",
            "updatedAt": "2026-11-03T05:25:30.754Z"
          }
        ]
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final consentsRes = ConsentsApiResponse.fromJson(decoded);

      expect(consentsRes.success, isTrue);
      expect(consentsRes.count, 1);
      expect(consentsRes.activeConsentsCount, 1);
      expect(consentsRes.consents.length, 1);

      final c = consentsRes.consents.first;
      expect(c.id, 'cmw08gqfx001jopta5jiavr1u');
      expect(c.consentHandle, 'AA-REQ-1793682862385-8565');
      expect(c.fipName, 'ICICI Bank Ltd');
      expect(c.fiTypes, 'DEPOSIT,TERM_DEPOSIT,CREDIT_CARD');
      expect(c.status, 'ACTIVE');
      expect(c.institution, 'ICICI Bank Ltd');
      expect(c.consentId, 'AA-REQ-1793682862385-8565');
    });

    test('35. POST /api/v1/bank-aggregation/consents/initiate request & response parsing', () {
      const req = InitiateConsentRequest(
        fipId: 'FIP-ICICI-01',
        fipName: 'ICICI Bank Ltd',
        fiTypes: 'DEPOSIT,TERM_DEPOSIT,CREDIT_CARD',
        validityDays: 365,
      );

      final map = req.toJson();
      expect(map['fipId'], 'FIP-ICICI-01');
      expect(map['fipName'], 'ICICI Bank Ltd');
      expect(map['fiTypes'], 'DEPOSIT,TERM_DEPOSIT,CREDIT_CARD');
      expect(map['validityDays'], 365);

      const resJson = '''
      {
        "success": true,
        "message": "RBI AA Consent artifact initiated successfully for ICICI Bank Ltd",
        "consentHandle": "AA-REQ-1793685542531-4720",
        "artifactUrl": "https://aa.finmos.app/consent/authorize/AA-REQ-1793685542531-4720",
        "data": {
          "id": "cmw0a26bq002doptaq9hm8yld",
          "userId": "cmuzhxi5a000asr4p9f6jcndp",
          "consentHandle": "AA-REQ-1793685542531-4720",
          "consentArtifactId": "ART-FIP-ICICI-01-1793685542531",
          "fipId": "FIP-ICICI-01",
          "fipName": "ICICI Bank Ltd",
          "fiTypes": "DEPOSIT,TERM_DEPOSIT,CREDIT_CARD",
          "consentMode": "VIEW",
          "fetchType": "PERIODIC",
          "dataFrequency": "DAILY",
          "status": "ACTIVE",
          "validFrom": "2026-11-03T05:59:02.531Z",
          "validTo": "2027-11-03T05:59:02.531Z",
          "lastSyncedAt": "2026-11-03T05:59:02.531Z",
          "createdAt": "2026-11-03T05:59:02.532Z",
          "updatedAt": "2026-11-03T05:59:02.532Z"
        }
      }
      ''';
      final Map<String, dynamic> decoded = jsonDecode(resJson);
      final initRes = InitiateConsentResponse.fromJson(decoded);

      expect(initRes.success, isTrue);
      expect(initRes.consentHandle, 'AA-REQ-1793685542531-4720');
      expect(initRes.artifactUrl, 'https://aa.finmos.app/consent/authorize/AA-REQ-1793685542531-4720');
      expect(initRes.data?.fipName, 'ICICI Bank Ltd');
      expect(initRes.data?.status, 'ACTIVE');
    });

    test('36. POST revoke & renew consent responses parsing', () {
      const revokeJson = '''
      {
        "success": true,
        "message": "AA Consent for ICICI Bank Ltd has been revoked immediately under DPDP Act 2023",
        "data": {
          "id": "cmw0a26bq002doptaq9hm8yld",
          "userId": "cmuzhxi5a000asr4p9f6jcndp",
          "consentHandle": "AA-REQ-1793685542531-4720",
          "fipName": "ICICI Bank Ltd",
          "fiTypes": "DEPOSIT,TERM_DEPOSIT,CREDIT_CARD",
          "status": "REVOKED"
        }
      }
      ''';
      final Map<String, dynamic> rDec = jsonDecode(revokeJson);
      final revokedConsent = AggregatorConsentItem.fromJson(rDec['data']);
      expect(revokedConsent.status, 'REVOKED');
      expect(revokedConsent.fipName, 'ICICI Bank Ltd');

      const renewJson = '''
      {
        "success": true,
        "message": "AA Consent for ICICI Bank Ltd renewed until 2027-11-03",
        "data": {
          "id": "cmw0a26bq002doptaq9hm8yld",
          "consentHandle": "AA-REQ-1793685542531-4720",
          "fipName": "ICICI Bank Ltd",
          "fiTypes": "DEPOSIT,TERM_DEPOSIT,CREDIT_CARD",
          "status": "ACTIVE",
          "validTo": "2027-11-03T06:01:30.887Z"
        }
      }
      ''';
      final Map<String, dynamic> rnDec = jsonDecode(renewJson);
      final renewedConsent = AggregatorConsentItem.fromJson(rnDec['data']);
      expect(renewedConsent.status, 'ACTIVE');
      expect(renewedConsent.validTo, '2027-11-03T06:01:30.887Z');
    });

    test('37. GET /api/v1/bank-aggregation/transactions?limit=20&page=1 response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "totalRecords": 0,
        "currentPage": 1,
        "totalPages": 0,
        "aggregates": {
          "totalDebits": 0,
          "totalCredits": 0
        },
        "data": []
      }
      ''';
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final txnRes = AggregatorTransactionsApiResponse.fromJson(decoded);

      expect(txnRes.success, isTrue);
      expect(txnRes.totalRecords, 0);
      expect(txnRes.currentPage, 1);
      expect(txnRes.aggregates.totalDebits, 0.0);
      expect(txnRes.aggregates.totalCredits, 0.0);
      expect(txnRes.transactions, isEmpty);
    });

    test('38. GET /api/v1/bank-aggregation/institutions response parsing', () {
      const jsonStr = '''
      {
        "success": true,
        "totalSupported": 4,
        "data": [
          {
            "fipId": "FIP-ICICI-01",
            "name": "ICICI Bank Ltd",
            "category": "BANK",
            "fiTypes": [
              "DEPOSIT",
              "TERM_DEPOSIT",
              "CREDIT_CARD"
            ],
            "liveStatus": "ONLINE"
          },
          {
            "fipId": "FIP-HDFC",
            "name": "HDFC Bank",
            "category": "BANK",
            "fiTypes": [
              "DEPOSIT",
              "TERM_DEPOSIT"
            ],
            "liveStatus": "ONLINE"
          },
          {
            "fipId": "FIP-AXISBANK",
            "name": "Axis Bank",
            "category": "BANK",
            "fiTypes": [
              "CREDIT_CARD"
            ],
            "liveStatus": "ONLINE"
          },
          {
            "fipId": "FIP-HDFCBANK",
            "name": "HDFC Bank",
            "category": "BANK",
            "fiTypes": [
              "LOAN"
            ],
            "liveStatus": "ONLINE"
          }
        ]
      }
      ''';
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final instRes = InstitutionDirectoryApiResponse.fromJson(decoded);

      expect(instRes.success, isTrue);
      expect(instRes.totalSupported, 4);
      expect(instRes.institutions.length, 4);

      final i1 = instRes.institutions.first;
      expect(i1.fipId, 'FIP-ICICI-01');
      expect(i1.name, 'ICICI Bank Ltd');
      expect(i1.category, 'BANK');
      expect(i1.fiTypes, contains('DEPOSIT'));
      expect(i1.liveStatus, 'ONLINE');
      expect(i1.logoText, 'ICICI');
    });
  });
}



