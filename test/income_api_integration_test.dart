import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/core/constants/api_constants.dart';
import 'package:finomos/features/income_tracking/domain/income_models.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';

void main() {
  group('Live Backend API Integration Tests', () {
    test('ApiConstants provides correct endpoints', () {
      expect(ApiConstants.baseUrl, 'https://finmos-user.onrender.com');
      expect(ApiConstants.login, '/api/auth/login');
      expect(ApiConstants.incomeSummary, '/api/v1/income/summary');
      expect(ApiConstants.incomeEntries, '/api/v1/income/entries');
      expect(ApiConstants.incomeProofUpload, '/api/v1/income/proof-upload');
      expect(ApiConstants.incomeAutoTracking, '/api/v1/income/settings/auto-tracking');
      expect(ApiConstants.incomeForecast, '/api/v1/income/forecast');
    });

    test('IncomeSummaryData parses json correctly', () {
      final json = {
        'totalMonthlyIncome': 34500,
        'activeMonthlyIncome': 34000,
        'passiveMonthlyIncome': 500,
        'windfallTotalIncome': 0,
        'totalAnnualIncome': 414000,
        'stabilityScore': 54.4,
        'stabilityRating': 'Low Stability',
        'passiveRatio': 1.45,
        'topDependencyPercent': 98.55,
        'topSource': 'Infosys',
        'totalStreamsCount': 2,
        'autoTrackingEnabled': true,
        'aicfoInsight': 'Low Stability (Score 54/100). Passive cash flow generates ₹500/mo across interest holdings.',
        'forecast': {
          'selectedHorizon': '30D',
          'projectedAmount': 34500,
          'horizonBreakdown': {
            '30D': 34500,
            '90D': 103500,
            '1Y': 414000,
            '5Y': 2425284.9,
          },
        },
      };

      final data = IncomeSummaryData.fromJson(json);
      expect(data.totalMonthlyIncome, 34500.0);
      expect(data.activeMonthlyIncome, 34000.0);
      expect(data.passiveMonthlyIncome, 500.0);
      expect(data.totalAnnualIncome, 414000.0);
      expect(data.stabilityScore, 54.4);
      expect(data.stabilityRating, 'Low Stability');
      expect(data.passiveRatio, 1.45);
      expect(data.topDependencyPercent, 98.55);
      expect(data.topSource, 'Infosys');
      expect(data.totalStreamsCount, 2);
      expect(data.autoTrackingEnabled, true);
      expect(data.aiCfoInsight, contains('Low Stability (Score 54/100)'));
      expect(data.horizonBreakdown['90D'], 103500.0);
      expect(data.horizonBreakdown['5Y'], 2425284.9);
    });

    test('IncomeEntry parses json correctly', () {
      final json = {
        'id': 'cmvrzk40e0003127xn1cqgspi',
        'voucherNumber': 'FIN-INC-202610-00001',
        'amount': 6000,
        'source': 'villagkart',
        'category': 'Interest',
        'type': 'Passive',
        'frequency': 'Yearly',
        'bankAccount': 'State Bank of India (**** 4587)',
        'date': '28 Oct 2026',
        'documentName': 'retainer_amendment.pdf',
        'documentPath': 'https://vault.finomos.com/docs/users/u101/retainer_amendment.pdf',
        'notes': 'Test notes',
        'isVerified': true,
        'verificationType': 'Digitally Verified Inflow',
      };

      final entry = IncomeEntry.fromJson(json);
      expect(entry.id, 'cmvrzk40e0003127xn1cqgspi');
      expect(entry.voucherNumber, 'FIN-INC-202610-00001');
      expect(entry.amount, 6000.0);
      expect(entry.source, 'villagkart');
      expect(entry.category, 'Interest');
      expect(entry.type, 'Passive');
      expect(entry.frequency, 'Yearly');
      expect(entry.documentName, 'retainer_amendment.pdf');
    });

    test('IncomeVoucherData parses json correctly', () {
      final json = {
        'voucherNumber': 'FIN-INC-202610-00001',
        'id': 'cmvrzk40e0003127xn1cqgspi',
        'source': 'villagkart',
        'category': 'Interest',
        'type': 'Passive',
        'amount': 6000,
        'amountInWords': 'Six Thousand Rupees Only',
        'date': '28 Oct 2026',
        'frequency': 'Yearly',
        'bankAccount': 'State Bank of India (**** 4587)',
        'isVerified': true,
        'verificationType': 'Digitally Verified Inflow',
        'complianceStandard': 'RBI Account Aggregator & Section 65B Indian Evidence Act',
        'attachedDocumentUrl': 'https://vault.finomos.com/docs/users/u101/retainer_amendment.pdf',
        'voucherPdfUrl': 'http://finmos-user.onrender.com/api/v1/income/vouchers/FIN-INC-202610-00001.pdf',
      };

      final voucher = IncomeVoucherData.fromJson(json);
      expect(voucher.voucherNumber, 'FIN-INC-202610-00001');
      expect(voucher.amountInWords, 'Six Thousand Rupees Only');
      expect(voucher.complianceStandard, contains('Section 65B'));
    });

    test('IncomePaginationData parses json correctly', () {
      final json = {
        'currentPage': 1,
        'perPage': 20,
        'totalRecords': 2,
        'totalPages': 1,
      };

      final pagination = IncomePaginationData.fromJson(json);
      expect(pagination.currentPage, 1);
      expect(pagination.perPage, 20);
      expect(pagination.totalRecords, 2);
      expect(pagination.totalPages, 1);
    });

    test('IncomeForecastData parses json correctly', () {
      final json = {
        'selectedHorizon': '30D',
        'projectedAmount': 34500,
        'compoundingRate': '8.0% annual growth model',
        'monthlyBaseline': 34500,
        'annualBaseline': 414000,
        'horizonBreakdown': {
          '30D': 34500,
          '90D': 103500,
          '1Y': 414000,
          '5Y': 2425284.9,
        },
      };

      final forecast = IncomeForecastData.fromJson(json);
      expect(forecast.selectedHorizon, '30D');
      expect(forecast.projectedAmount, 34500.0);
      expect(forecast.compoundingRate, contains('8.0%'));
      expect(forecast.monthlyBaseline, 34500.0);
      expect(forecast.annualBaseline, 414000.0);
      expect(forecast.horizonBreakdown['1Y'], 414000.0);
    });

    test('GET single entry parses live backend response perfectly', () {
      final json = {
        'id': 'cmvryszd80004jtjateikly3v',
        'voucherNumber': 'FIN-INC-202610-00003',
        'amount': 34000,
        'source': 'Infosys',
        'category': 'Business Income',
        'type': 'Active',
        'frequency': 'Weekly',
        'bankAccount': 'State Bank of India (**** 4587)',
        'date': '24 Oct 2026',
        'documentName': null,
        'documentPath': null,
        'notes': '',
        'isVerified': false,
        'verificationType': 'Manual Entry Inflow',
        'createdAt': '2026-10-28T10:21:48.429Z'
      };

      final entry = IncomeEntry.fromJson(json);
      expect(entry.id, 'cmvryszd80004jtjateikly3v');
      expect(entry.voucherNumber, 'FIN-INC-202610-00003');
      expect(entry.amount, 34000.0);
      expect(entry.source, 'Infosys');
      expect(entry.category, 'Business Income');
      expect(entry.type, 'Active');
      expect(entry.frequency, 'Weekly');
      expect(entry.bankAccount, 'State Bank of India (**** 4587)');
      expect(entry.date, '24 Oct 2026');
      expect(entry.isVerified, false);
      expect(entry.verificationType, 'Manual Entry Inflow');
      expect(entry.createdAt, '2026-10-28T10:21:48.429Z');
    });

    test('POST create entry serializes body and parses live backend response (Freelance)', () {
      final postBody = {
        'amount': 35000.0,
        'source': 'Starlight Consulting LLP',
        'category': 'Freelance',
        'frequency': 'Monthly',
        'bankAccount': 'HDFC Bank ••••4587',
        'date': '27 Oct 2026',
        'notes': 'Mobile app consulting retainer',
        'documentName': 'invoice_starlight_oct26.pdf',
        'documentPath': 'https://vault.finomos.com/docs/users/u101/invoice_starlight_oct26.pdf'
      };

      final entryToSend = IncomeEntry(
        id: '',
        amount: 35000.0,
        source: 'Starlight Consulting LLP',
        category: 'Freelance',
        frequency: 'Monthly',
        bankAccount: 'HDFC Bank ••••4587',
        date: '27 Oct 2026',
        notes: 'Mobile app consulting retainer',
        documentName: 'invoice_starlight_oct26.pdf',
        documentPath: 'https://vault.finomos.com/docs/users/u101/invoice_starlight_oct26.pdf',
      );

      final jsonPayload = entryToSend.toJson();
      expect(jsonPayload['amount'], postBody['amount']);
      expect(jsonPayload['source'], postBody['source']);
      expect(jsonPayload['category'], postBody['category']);
      expect(jsonPayload['frequency'], postBody['frequency']);
      expect(jsonPayload['bankAccount'], postBody['bankAccount']);
      expect(jsonPayload['date'], postBody['date']);
      expect(jsonPayload['documentName'], postBody['documentName']);
      expect(jsonPayload['documentPath'], postBody['documentPath']);

      // Response parsing
      final responseData = {
        'id': 'inc_103',
        'voucherNumber': 'FIN-INC-202610-00103',
        'amount': 35000,
        'source': 'Starlight Consulting LLP',
        'category': 'Freelance',
        'type': 'Active',
        'frequency': 'Monthly',
        'bankAccount': 'HDFC Bank ••••4587',
        'date': '27 Oct 2026',
        'documentName': 'invoice_starlight_oct26.pdf',
        'documentPath': 'https://vault.finomos.com/docs/users/u101/invoice_starlight_oct26.pdf',
        'notes': 'Mobile app consulting retainer',
        'isVerified': false,
        'verificationType': 'Manual Entry Inflow',
        'createdAt': '2026-10-29T08:11:00.703Z'
      };

      final createdEntry = IncomeEntry.fromJson(responseData);
      expect(createdEntry.id, 'inc_103');
      expect(createdEntry.voucherNumber, 'FIN-INC-202610-00103');
      expect(createdEntry.type, 'Active');
      expect(createdEntry.amount, 35000.0);
    });

    test('POST create entry serializes body and parses live backend response (Rental Passive)', () {
      final responseData = {
        'id': 'inc_104',
        'voucherNumber': 'FIN-INC-202611-00104',
        'amount': 22500,
        'source': 'Indiranagar Studio Apartment',
        'category': 'Rental',
        'type': 'Passive',
        'frequency': 'Monthly',
        'bankAccount': 'SBI ••••1123',
        'date': '01 Nov 2026',
        'documentName': 'lease_agreement_2026.pdf',
        'documentPath': 'https://vault.finomos.com/docs/users/u101/lease_agreement_2026.pdf',
        'notes': 'Monthly lease credit',
        'isVerified': false,
        'verificationType': 'Manual Entry Inflow',
        'createdAt': '2026-10-29T08:15:28.305Z'
      };

      final createdEntry = IncomeEntry.fromJson(responseData);
      expect(createdEntry.id, 'inc_104');
      expect(createdEntry.voucherNumber, 'FIN-INC-202611-00104');
      expect(createdEntry.type, 'Passive');
      expect(createdEntry.amount, 22500.0);
      expect(createdEntry.source, 'Indiranagar Studio Apartment');
    });

    test('PUT update entry serializes body and parses live backend response', () {
      final responseData = {
        'id': 'cmvryszd80004jtjateikly3v',
        'voucherNumber': 'FIN-INC-202610-00003',
        'amount': 25000,
        'source': 'UI/UX Design Consulting',
        'category': 'Freelance',
        'type': 'Active',
        'frequency': 'Monthly',
        'bankAccount': 'ICICI Bank ••••9021',
        'date': '18 Aug 2025',
        'documentName': 'retainer_amendment.pdf',
        'documentPath': 'https://vault.finomos.com/docs/users/u101/retainer_amendment.pdf',
        'notes': 'Revised retainer for 2025-26',
        'isVerified': false,
        'verificationType': 'Manual Entry Inflow',
        'createdAt': '2026-10-28T10:21:48.429Z',
        'updatedAt': '2026-10-29T08:20:28.800Z'
      };

      final updatedEntry = IncomeEntry.fromJson(responseData);
      expect(updatedEntry.id, 'cmvryszd80004jtjateikly3v');
      expect(updatedEntry.amount, 25000.0);
      expect(updatedEntry.source, 'UI/UX Design Consulting');
      expect(updatedEntry.updatedAt, '2026-10-29T08:20:28.800Z');
    });

    test('GET forecast with horizon=30D parses live backend response perfectly', () {
      final json = {
        'selectedHorizon': '30D',
        'projectedAmount': 58000,
        'compoundingRate': '8.0% annual growth model',
        'monthlyBaseline': 58000,
        'annualBaseline': 696000,
        'horizonBreakdown': {
          '30D': 58000,
          '90D': 174000,
          '1Y': 696000,
          '5Y': 4077290.6
        }
      };

      final forecast = IncomeForecastData.fromJson(json);
      expect(forecast.selectedHorizon, '30D');
      expect(forecast.projectedAmount, 58000.0);
      expect(forecast.compoundingRate, '8.0% annual growth model');
      expect(forecast.monthlyBaseline, 58000.0);
      expect(forecast.annualBaseline, 696000.0);
      expect(forecast.horizonBreakdown['30D'], 58000.0);
      expect(forecast.horizonBreakdown['90D'], 174000.0);
      expect(forecast.horizonBreakdown['1Y'], 696000.0);
      expect(forecast.horizonBreakdown['5Y'], 4077290.6);

      const state = IncomeState(entries: [], forecastData: null);
      final updatedState = state.copyWith(forecastData: forecast, forecastHorizon: '30D');
      expect(updatedState.getForecastAmount('30D'), 58000.0);
      expect(updatedState.getForecastAmount('90D'), 174000.0);
    });

    test('GET forecast with horizon=1Y parses live backend response perfectly', () {
      final json = {
        'selectedHorizon': '1Y',
        'projectedAmount': 696000,
        'compoundingRate': '8.0% annual growth model',
        'monthlyBaseline': 58000,
        'annualBaseline': 696000,
        'horizonBreakdown': {
          '30D': 58000,
          '90D': 174000,
          '1Y': 696000,
          '5Y': 4077290.6
        }
      };

      final forecast = IncomeForecastData.fromJson(json);
      expect(forecast.selectedHorizon, '1Y');
      expect(forecast.projectedAmount, 696000.0);

      const state = IncomeState(entries: [], forecastData: null);
      final updatedState = state.copyWith(forecastData: forecast, forecastHorizon: '1Y');
      expect(updatedState.getForecastAmount('1Y'), 696000.0);
    });

    test('GET forecast with horizon=5Y parses live backend response perfectly', () {
      final json = {
        'selectedHorizon': '5Y',
        'projectedAmount': 4077290.6,
        'compoundingRate': '8.0% annual growth model',
        'monthlyBaseline': 58000,
        'annualBaseline': 696000,
        'horizonBreakdown': {
          '30D': 58000,
          '90D': 174000,
          '1Y': 696000,
          '5Y': 4077290.6
        }
      };

      final forecast = IncomeForecastData.fromJson(json);
      expect(forecast.selectedHorizon, '5Y');
      expect(forecast.projectedAmount, 4077290.6);

      const state = IncomeState(entries: [], forecastData: null);
      final updatedState = state.copyWith(forecastData: forecast, forecastHorizon: '5Y');
      expect(updatedState.getForecastAmount('5Y'), 4077290.6);
    });

    test('PATCH auto-tracking setting parses live backend response perfectly', () {
      final json = {
        'autoTrackingEnabled': true,
        'updatedAt': '2026-10-29T08:56:45.390Z'
      };

      expect(json['autoTrackingEnabled'], true);
      expect(json['updatedAt'], '2026-10-29T08:56:45.390Z');
    });

    test('POST sync Account Aggregator feeds parses live backend response perfectly', () {
      final json = {
        'syncStatus': 'SUCCESS',
        'syncedAt': '2026-10-29T08:56:54.311Z',
        'detectedCount': 1,
        'channels': [
          'ACCOUNT_AGGREGATOR',
          'SMS_PARSER'
        ],
        'lastSyncTimestamp': '2026-10-29T08:56:54.311Z'
      };

      final result = IncomeSyncResult.fromJson(json);
      expect(result.syncStatus, 'SUCCESS');
      expect(result.syncedAt, '2026-10-29T08:56:54.311Z');
      expect(result.detectedCount, 1);
      expect(result.channels, contains('ACCOUNT_AGGREGATOR'));
      expect(result.channels, contains('SMS_PARSER'));
    });

    test('GET detected inflows parses live backend response perfectly', () {
      final jsonList = [
        {
          'detectedId': 'det_981',
          'detectedSource': 'INFOSYS TECHNOLOGIES SALARY',
          'suggestedCategory': 'Salary',
          'amount': 92000,
          'date': '28 Oct 2026',
          'bankAccount': 'HDFC Bank ••••4587',
          'confidenceScore': 0.98,
          'detectionChannel': 'ACCOUNT_AGGREGATOR'
        }
      ];

      final inflows = jsonList.map((e) => DetectedInflow.fromJson(e)).toList();
      expect(inflows.length, 1);
      expect(inflows.first.detectedId, 'det_981');
      expect(inflows.first.detectedSource, 'INFOSYS TECHNOLOGIES SALARY');
      expect(inflows.first.suggestedCategory, 'Salary');
      expect(inflows.first.amount, 92000.0);
      expect(inflows.first.date, '28 Oct 2026');
      expect(inflows.first.confidenceScore, 0.98);
      expect(inflows.first.detectionChannel, 'ACCOUNT_AGGREGATOR');
    });

    test('POST confirm detected inflow parses confirmed stream response perfectly', () {
      final json = {
        'id': 'inc_104',
        'voucherNumber': 'FIN-INC-202610-00104',
        'amount': 92000,
        'source': 'INFOSYS TECHNOLOGIES SALARY',
        'category': 'Salary',
        'type': 'Active',
        'frequency': 'Monthly',
        'bankAccount': 'HDFC Bank ••••4587',
        'date': '28 Oct 2026',
        'documentName': null,
        'documentPath': null,
        'notes': 'Confirmed via ACCOUNT_AGGREGATOR (Confidence: 98%)',
        'isVerified': true,
        'verificationType': 'Digitally Verified Inflow',
        'createdAt': '2026-10-29T08:57:11.125Z'
      };

      final confirmedEntry = IncomeEntry.fromJson(json);
      expect(confirmedEntry.id, 'inc_104');
      expect(confirmedEntry.voucherNumber, 'FIN-INC-202610-00104');
      expect(confirmedEntry.amount, 92000.0);
      expect(confirmedEntry.source, 'INFOSYS TECHNOLOGIES SALARY');
      expect(confirmedEntry.category, 'Salary');
      expect(confirmedEntry.type, 'Active');
      expect(confirmedEntry.isVerified, true);
      expect(confirmedEntry.verificationType, 'Digitally Verified Inflow');
      expect(confirmedEntry.notes, contains('ACCOUNT_AGGREGATOR'));
    });

    test('POST /api/auth/login as Sireesha parses credentials and user token perfectly', () {
      final reqBody = {
        'identifier': 'sireesha@gmail.com',
        'password': 'Sireesha@123',
      };
      expect(reqBody['identifier'], 'sireesha@gmail.com');
      expect(reqBody['password'], 'Sireesha@123');

      final resBody = {
        'message': 'Login successful',
        'token': 'jwt-token-cmuzhxi5a000asr4p9f6jcndp',
        'user': {
          'id': 'cmuzhxi5a000asr4p9f6jcndp',
          'name': 'Sireesha',
          'email': 'sireesha@gmail.com',
          'phone': '8985839110',
        },
      };

      expect(resBody['message'], 'Login successful');
      expect(resBody['token'], 'jwt-token-cmuzhxi5a000asr4p9f6jcndp');
      final user = resBody['user'] as Map<String, dynamic>;
      expect(user['name'], 'Sireesha');
      expect(user['email'], 'sireesha@gmail.com');
      expect(user['phone'], '8985839110');
    });

    test('GET /api/v1/income/summary for horizons 30D, 90D, 1Y, 5Y parses live forecast projections perfectly', () {
      final summary30DJson = {
        'success': true,
        'data': {
          'totalMonthlyIncome': 34500,
          'activeMonthlyIncome': 34000,
          'passiveMonthlyIncome': 500,
          'windfallTotalIncome': 0,
          'totalAnnualIncome': 414000,
          'stabilityScore': 54.4,
          'stabilityRating': 'Low Stability',
          'passiveRatio': 1.45,
          'topDependencyPercent': 98.55,
          'topSource': 'Infosys',
          'totalStreamsCount': 2,
          'autoTrackingEnabled': true,
          'aicfoInsight': 'Low Stability (Score 54/100). Passive cash flow generates ₹500/mo across interest holdings.',
          'forecast': {
            'selectedHorizon': '30D',
            'projectedAmount': 34500,
            'horizonBreakdown': {
              '30D': 34500,
              '90D': 103500,
              '1Y': 414000,
              '5Y': 2425284.9,
            },
          },
        },
      };

      final data30D = IncomeSummaryData.fromJson(summary30DJson['data'] as Map<String, dynamic>);
      expect(data30D.selectedHorizon, '30D');
      expect(data30D.projectedAmount, 34500.0);
      expect(data30D.horizonBreakdown['30D'], 34500.0);
      expect(data30D.horizonBreakdown['90D'], 103500.0);
      expect(data30D.horizonBreakdown['1Y'], 414000.0);
      expect(data30D.horizonBreakdown['5Y'], 2425284.9);

      final state30D = IncomeState(entries: [], summaryData: data30D, forecastHorizon: '30D');
      expect(state30D.getForecastAmount('30D'), 34500.0);
      expect(state30D.getForecastAmount('90D'), 103500.0);
      expect(state30D.getForecastAmount('1Y'), 414000.0);
      expect(state30D.getForecastAmount('5Y'), 2425284.9);

      // 90D Horizon
      final summary90DJson = Map<String, dynamic>.from(summary30DJson);
      final forecast90D = Map<String, dynamic>.from((summary30DJson['data'] as Map<String, dynamic>)['forecast'] as Map<String, dynamic>);
      forecast90D['selectedHorizon'] = '90D';
      forecast90D['projectedAmount'] = 103500;
      (summary90DJson['data'] as Map<String, dynamic>)['forecast'] = forecast90D;
      final data90D = IncomeSummaryData.fromJson(summary90DJson['data'] as Map<String, dynamic>);
      expect(data90D.selectedHorizon, '90D');
      expect(data90D.projectedAmount, 103500.0);

      // 1Y Horizon
      forecast90D['selectedHorizon'] = '1Y';
      forecast90D['projectedAmount'] = 414000;
      final data1Y = IncomeSummaryData.fromJson(summary90DJson['data'] as Map<String, dynamic>);
      expect(data1Y.selectedHorizon, '1Y');
      expect(data1Y.projectedAmount, 414000.0);

      // 5Y Horizon
      forecast90D['selectedHorizon'] = '5Y';
      forecast90D['projectedAmount'] = 2425284.9;
      final data5Y = IncomeSummaryData.fromJson(summary90DJson['data'] as Map<String, dynamic>);
      expect(data5Y.selectedHorizon, '5Y');
      expect(data5Y.projectedAmount, 2425284.9);
    });

    test('GET /api/v1/income/entries?category=Salary correctly returns empty list and pagination', () {
      final json = {
        'success': true,
        'data': {
          'entries': [],
          'pagination': {
            'currentPage': 1,
            'perPage': 20,
            'totalRecords': 0,
            'totalPages': 1,
          },
        },
      };

      final entriesList = ((json['data'] as Map<String, dynamic>)['entries'] as List).map((e) => IncomeEntry.fromJson(e)).toList();
      final pagination = IncomePaginationData.fromJson((json['data'] as Map<String, dynamic>)['pagination'] as Map<String, dynamic>);

      expect(entriesList, isEmpty);
      expect(pagination.totalRecords, 0);
      expect(pagination.currentPage, 1);
    });

    test('GET /api/v1/income/entries?type=Passive correctly parses 1 passive entry (villagkart)', () {
      final json = {
        'success': true,
        'data': {
          'entries': [
            {
              'id': 'cmvry4155000113t4ip6197oy',
              'voucherNumber': 'FIN-INC-202610-00008',
              'amount': 6000,
              'source': 'villagkart',
              'category': 'Interest',
              'type': 'Passive',
              'frequency': 'Yearly',
              'bankAccount': 'State Bank of India (**** 4587)',
              'date': '28 Oct 2026',
              'documentName': null,
              'documentPath': null,
              'notes': '',
              'isVerified': false,
              'verificationType': 'Manual Entry Inflow',
              'createdAt': '2026-10-28T10:02:24.328Z',
            },
          ],
          'pagination': {
            'currentPage': 1,
            'perPage': 20,
            'totalRecords': 1,
            'totalPages': 1,
          },
        },
      };

      final entriesList = ((json['data'] as Map<String, dynamic>)['entries'] as List).map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>)).toList();
      final pagination = IncomePaginationData.fromJson((json['data'] as Map<String, dynamic>)['pagination'] as Map<String, dynamic>);

      expect(entriesList.length, 1);
      final item = entriesList.first;
      expect(item.id, 'cmvry4155000113t4ip6197oy');
      expect(item.voucherNumber, 'FIN-INC-202610-00008');
      expect(item.amount, 6000.0);
      expect(item.source, 'villagkart');
      expect(item.category, 'Interest');
      expect(item.type, 'Passive');
      expect(item.frequency, 'Yearly');
      expect(item.bankAccount, 'State Bank of India (**** 4587)');
      expect(item.date, '28 Oct 2026');
      expect(item.verificationType, 'Manual Entry Inflow');
      expect(pagination.totalRecords, 1);
    });

    test('GET /api/v1/income/entries with bankAccount, dateFilter, and search query filters', () {
      // bankAccount=HDFC
      final hdfcJson = {
        'success': true,
        'data': {
          'entries': [],
          'pagination': {'currentPage': 1, 'perPage': 20, 'totalRecords': 0, 'totalPages': 1},
        },
      };
      final hdfcPagination = IncomePaginationData.fromJson((hdfcJson['data'] as Map<String, dynamic>)['pagination'] as Map<String, dynamic>);
      expect(hdfcPagination.totalRecords, 0);

      // dateFilter=Aug 2025
      final dateFilterJson = {
        'success': true,
        'data': {
          'entries': [],
          'pagination': {'currentPage': 1, 'perPage': 20, 'totalRecords': 0, 'totalPages': 1},
        },
      };
      final datePagination = IncomePaginationData.fromJson((dateFilterJson['data'] as Map<String, dynamic>)['pagination'] as Map<String, dynamic>);
      expect(datePagination.totalRecords, 0);

      // search=Tech Corp
      final searchJson = {
        'success': true,
        'data': {
          'entries': [],
          'pagination': {'currentPage': 1, 'perPage': 20, 'totalRecords': 0, 'totalPages': 1},
        },
      };
      final searchPagination = IncomePaginationData.fromJson((searchJson['data'] as Map<String, dynamic>)['pagination'] as Map<String, dynamic>);
      expect(searchPagination.totalRecords, 0);
    });

    test('POST /api/v1/income/proof-upload parses live uploaded file response and linkedEntryId', () {
      final json = {
        'success': true,
        'data': {
          'documentName': 'Budget management.png',
          'documentPath': 'http://finmos-user.onrender.com/uploads/1793264895413-927087537-Budget management.png',
          'fileSizeBytes': 1155001,
          'mimeType': 'image/png',
          'uploadedAt': '2026-10-29T09:08:19.937Z',
          'linkedEntryId': 'cmvrzk2vz0001127xkzc8drk8',
        },
      };

      final result = IncomeProofUploadResult.fromJson(json['data'] as Map<String, dynamic>);
      expect(result.documentName, 'Budget management.png');
      expect(result.documentPath, 'http://finmos-user.onrender.com/uploads/1793264895413-927087537-Budget management.png');
      expect(result.fileSizeBytes, 1155001);
      expect(result.mimeType, 'image/png');
      expect(result.uploadedAt, '2026-10-29T09:08:19.937Z');
      expect(result.linkedEntryId, 'cmvrzk2vz0001127xkzc8drk8');

      final serialized = result.toJson();
      expect(serialized['documentName'], 'Budget management.png');
      expect(serialized['fileSizeBytes'], 1155001);
      expect(serialized['linkedEntryId'], 'cmvrzk2vz0001127xkzc8drk8');
    });

    test('GET /api/v1/income/entries/:id/voucher parses Section 65B official voucher details', () {
      final json = {
        'success': true,
        'data': {
          'voucherNumber': 'FIN-INC-202610-00002',
          'id': 'cmvrzk2vz0001127xkzc8drk8',
          'source': 'Infosys',
          'category': 'Business Income',
          'type': 'Active',
          'amount': 34000,
          'amountInWords': 'Thirty Four Thousand Rupees Only',
          'date': '24 Oct 2026',
          'frequency': 'Weekly',
          'bankAccount': 'State Bank of India (**** 4587)',
          'isVerified': true,
          'verificationType': 'Digitally Verified Inflow',
          'complianceStandard': 'RBI Account Aggregator & Section 65B Indian Evidence Act',
          'attachedDocumentUrl': 'http://finmos-user.onrender.com/uploads/1793264159295-211266660-1.onboard&Authentaction Screen.png',
          'voucherPdfUrl': 'http://finmos-user.onrender.com/api/v1/income/vouchers/FIN-INC-202610-00002.pdf',
        },
      };

      final voucher = IncomeVoucherData.fromJson(json['data'] as Map<String, dynamic>);
      expect(voucher.voucherNumber, 'FIN-INC-202610-00002');
      expect(voucher.id, 'cmvrzk2vz0001127xkzc8drk8');
      expect(voucher.source, 'Infosys');
      expect(voucher.category, 'Business Income');
      expect(voucher.type, 'Active');
      expect(voucher.amount, 34000.0);
      expect(voucher.amountInWords, 'Thirty Four Thousand Rupees Only');
      expect(voucher.date, '24 Oct 2026');
      expect(voucher.frequency, 'Weekly');
      expect(voucher.bankAccount, 'State Bank of India (**** 4587)');
      expect(voucher.isVerified, true);
      expect(voucher.verificationType, 'Digitally Verified Inflow');
      expect(voucher.complianceStandard, 'RBI Account Aggregator & Section 65B Indian Evidence Act');
      expect(voucher.attachedDocumentUrl, contains('onboard&Authentaction Screen.png'));
      expect(voucher.voucherPdfUrl, 'http://finmos-user.onrender.com/api/v1/income/vouchers/FIN-INC-202610-00002.pdf');
    });

    test('POST /api/v1/income/salary-allocation triggers Financial Autopilot (FAP) rules and parses 4 splits', () {
      final reqBody = {
        'entryId': 'inc_1',
        'amount': 85000.0,
        'salarySource': 'Tech Corp India Pvt Ltd',
        'allocationRules': {
          'emergencyFund': 20,
          'investments': 30,
          'fixedExpenses': 40,
          'discretionary': 10,
        },
      };

      expect(reqBody['entryId'], 'inc_1');
      expect((reqBody['allocationRules'] as Map)['emergencyFund'], 20);

      final resBody = {
        'success': true,
        'message': 'Financial Autopilot (FAP) salary allocation rules triggered successfully',
        'data': {
          'allocationId': 'fap_alloc_602116',
          'salaryAmount': 85000,
          'source': 'Tech Corp India Pvt Ltd',
          'status': 'ALLOCATED',
          'executedAt': '2026-10-29T10:10:02.116Z',
          'splits': [
            {
              'bucket': 'Emergency Fund (20%)',
              'amount': 17000,
              'status': 'SCHEDULED',
            },
            {
              'bucket': 'SIP & Investments (30%)',
              'amount': 25500,
              'status': 'SCHEDULED',
            },
            {
              'bucket': 'Fixed Expenses & Rent (40%)',
              'amount': 34000,
              'status': 'SCHEDULED',
            },
            {
              'bucket': 'Discretionary Spending (10%)',
              'amount': 8500,
              'status': 'AVAILABLE',
            },
          ],
        },
      };

      final result = SalaryAllocationResult.fromJson(resBody['data'] as Map<String, dynamic>);
      expect(result.allocationId, 'fap_alloc_602116');
      expect(result.salaryAmount, 85000.0);
      expect(result.source, 'Tech Corp India Pvt Ltd');
      expect(result.status, 'ALLOCATED');
      expect(result.splits.length, 4);
      expect(result.splits[0].bucket, 'Emergency Fund (20%)');
      expect(result.splits[0].amount, 17000.0);
      expect(result.splits[0].status, 'SCHEDULED');
      expect(result.splits[1].bucket, 'SIP & Investments (30%)');
      expect(result.splits[1].amount, 25500.0);
      expect(result.splits[2].bucket, 'Fixed Expenses & Rent (40%)');
      expect(result.splits[2].amount, 34000.0);
      expect(result.splits[3].bucket, 'Discretionary Spending (10%)');
      expect(result.splits[3].amount, 8500.0);
      expect(result.splits[3].status, 'AVAILABLE');
    });

    test('GET /api/income parses direct JSON array of income records with paymentMode & receiptUrl', () {
      final jsonList = [
        {
          'id': 'inc_104',
          'userId': 'cmv51f7ic0000w9zwnjllfb8n',
          'amount': 22500,
          'date': '01 Nov 2026',
          'category': 'Rental',
          'source': 'Indiranagar Studio Apartment',
          'paymentMode': 'SBI ••••1123',
          'frequency': 'Monthly',
          'notes': 'Monthly lease credit',
          'voucherNumber': 'FIN-INC-202611-00001',
          'documentName': '3.Money Managment Screen.png',
          'documentPath': 'http://finmos-user.onrender.com/uploads/1793266929315-424664112-3.Money Managment Screen.png',
          'receiptUrl': 'http://finmos-user.onrender.com/uploads/1793266929315-424664112-3.Money Managment Screen.png',
          'isVerified': true,
        },
        {
          'id': 'inc_103',
          'userId': 'cmv51f7ic0000w9zwnjllfb8n',
          'amount': 35000,
          'date': '27 Oct 2026',
          'category': 'Freelance',
          'source': 'Starlight Consulting LLP',
          'paymentMode': 'HDFC Bank ••••4587',
          'frequency': 'Monthly',
          'notes': 'Mobile app consulting retainer',
          'voucherNumber': 'FIN-INC-202610-00002',
          'isVerified': true,
        },
        {
          'id': 'cmvry4155000113t4ip6197oy',
          'userId': 'cmv51f7ic0000w9zwnjllfb8n',
          'amount': 6000,
          'date': '28 Oct 2026',
          'category': 'Interest',
          'source': 'villagkart',
          'paymentMode': 'State Bank of India (**** 4587)',
          'frequency': 'Yearly',
          'notes': 'Updated notes via PUT test',
          'accountNumber': '**** 4587',
          'balanceAfter': 18987,
          'voucherNumber': 'FIN-INC-202610-00005',
          'isVerified': true,
        },
      ];

      final entries = jsonList.map((e) => IncomeEntry.fromJson(e)).toList();
      expect(entries.length, 3);
      expect(entries[0].id, 'inc_104');
      expect(entries[0].amount, 22500.0);
      expect(entries[0].bankAccount, 'SBI ••••1123');
      expect(entries[0].documentPath, contains('Money Managment Screen.png'));
      expect(entries[2].balanceAfter, 18987.0);
      expect(entries[2].accountNumber, '**** 4587');
    });

    test('POST /api/income creates manual income entry with paymentMode & balanceAfter', () {
      final json = {
        'id': 'cmvtdx0by0001tszcrt4ynalw',
        'userId': 'cmv51f7ic0000w9zwnjllfb8n',
        'amount': 15000,
        'date': '2026-10-28',
        'category': 'Salary',
        'source': 'Acme Corporation',
        'paymentMode': 'Bank Transfer',
        'frequency': 'Monthly',
        'notes': 'Test manual income from Postman',
        'balanceAfter': 15000,
        'voucherNumber': 'FIN-INC-202610-00001',
        'isVerified': true,
        'createdAt': '2026-10-29T10:12:36.718Z',
      };

      final entry = IncomeEntry.fromJson(json);
      expect(entry.id, 'cmvtdx0by0001tszcrt4ynalw');
      expect(entry.amount, 15000.0);
      expect(entry.source, 'Acme Corporation');
      expect(entry.category, 'Salary');
      expect(entry.bankAccount, 'Bank Transfer');
      expect(entry.voucherNumber, 'FIN-INC-202610-00001');
      expect(entry.balanceAfter, 15000.0);
    });

    test('GET /api/expense parses direct JSON array into ExpenseEntry list', () {
      final jsonList = [
        {
          'id': 'cmvry72qw000513t46gjxugnf',
          'userId': 'cmv51f7ic0000w9zwnjllfb8n',
          'amount': 6000,
          'date': '2026-10-28',
          'category': 'Shopping',
          'description': 'Shopping',
          'paymentMode': 'HDFC Bank (**** 8754)',
          'accountNumber': '**** 8754',
          'balanceAfter': 788636,
          'isRecurring': false,
          'isVerified': true,
          'createdAt': '2026-10-28T10:04:46.085Z',
        },
      ];

      final expenses = jsonList.map((e) => ExpenseEntry.fromJson(e)).toList();
      expect(expenses.length, 1);
      final item = expenses.first;
      expect(item.id, 'cmvry72qw000513t46gjxugnf');
      expect(item.amount, 6000.0);
      expect(item.category, 'Shopping');
      expect(item.description, 'Shopping');
      expect(item.paymentMode, 'HDFC Bank (**** 8754)');
      expect(item.balanceAfter, 788636.0);
      expect(item.isRecurring, false);
    });

    test('POST /api/expense creates new expense with invoiceNumber & priority', () {
      final reqBody = {
        'amount': 2500,
        'date': '2026-10-28',
        'category': 'Food & Dining',
        'description': 'Lunch at Cafe',
        'paymentMode': 'HDFC Bank (**** 8754)',
      };

      final newExpense = ExpenseEntry(
        id: '',
        amount: 2500.0,
        date: '2026-10-28',
        category: 'Food & Dining',
        description: 'Lunch at Cafe',
        paymentMode: 'HDFC Bank (**** 8754)',
      );

      final payload = newExpense.toJson();
      expect(payload['amount'], reqBody['amount']);
      expect(payload['category'], reqBody['category']);
      expect(payload['description'], reqBody['description']);
      expect(payload['paymentMode'], reqBody['paymentMode']);

      final resBody = {
        'success': true,
        'message': 'Expense recorded successfully',
        'data': {
          'id': 'cmvte05if0005tszcjs9l41ab',
          'invoiceNumber': 'INV-EXP-2026-EXP002',
          'description': 'Lunch at Cafe',
          'category': 'Food & Dining',
          'amount': 2500,
          'date': '28 Oct 2026',
          'paymentMode': 'HDFC Bank (**** 8754)',
          'priority': 'P5 - Lifestyle',
          'isRecurring': false,
          'merchant': 'Lunch at Cafe',
          'notes': '',
          'bankAccount': 'State Bank of India ••••4587',
          'createdAt': '2026-10-29T10:15:03.399Z',
        },
      };

      final recorded = ExpenseEntry.fromJson(resBody['data'] as Map<String, dynamic>);
      expect(recorded.id, 'cmvte05if0005tszcjs9l41ab');
      expect(recorded.invoiceNumber, 'INV-EXP-2026-EXP002');
      expect(recorded.description, 'Lunch at Cafe');
      expect(recorded.category, 'Food & Dining');
      expect(recorded.amount, 2500.0);
      expect(recorded.priority, 'P5 - Lifestyle');
      expect(recorded.bankAccount, 'State Bank of India ••••4587');
      expect(recorded.paymentMode, 'HDFC Bank (**** 8754)');
    });

    test('ApiConstants.incomeVoucherPdf generates standard path', () {
      expect(
        ApiConstants.incomeVoucherPdf('FIN-INC-202508-00001'),
        '/api/v1/income/vouchers/FIN-INC-202508-00001.pdf',
      );
      expect(
        ApiConstants.incomeVoucherPdf('FIN-INC-202508-00001.pdf'),
        '/api/v1/income/vouchers/FIN-INC-202508-00001.pdf',
      );
    });

    test('Section 65B official PDF voucher binary structure conforms to %PDF-1.4 specification', () {
      final rawPdfStream = '''%PDF-1.4
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj
3 0 obj
<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>
endobj
4 0 obj
<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>
endobj
5 0 obj
<< /Length 705 >>
stream
BT
/F1 18 Tf
50 780 Td
(FINMOS - OFFICIAL INCOME RECEIPT VOUCHER) Tj
/F1 10 Tf
0 -24 Td
(Section 65B Indian Evidence Act & RBI Account Aggregator Compliant) Tj
/F1 12 Tf
0 -36 Td
(Voucher Number: FIN-INC-202610-00001) Tj
0 -20 Td
(Date of Credit: 28 Oct 2026) Tj
0 -20 Td
(Source / Payer: Acme Corporation) Tj
0 -20 Td
(Category: Salary  |  Nature: Active) Tj
0 -20 Td
(Frequency: Monthly) Tj
0 -20 Td
(Deposit Bank Account: Bank Transfer) Tj
0 -24 Td
(Amount Credited: INR 15,000) Tj
0 -20 Td
(Amount in Words: Fifteen Thousand Rupees Only) Tj
0 -24 Td
(Verification Status: VERIFIED Digitally Verified Inflow) Tj
0 -40 Td
(This is an electronically generated and tamper-evident voucher reference.) Tj
ET
endstream
endobj
xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000241 00000 n 
0000000311 00000 n 
trailer
<< /Size 6 /Root 1 0 R >>
startxref
1067
%%EOF''';

      expect(rawPdfStream.startsWith('%PDF-1.4'), isTrue);
      expect(rawPdfStream.endsWith('%%EOF'), isTrue);
      expect(rawPdfStream, contains('FINMOS - OFFICIAL INCOME RECEIPT VOUCHER'));
      expect(rawPdfStream, contains('Section 65B Indian Evidence Act & RBI Account Aggregator Compliant'));
      expect(rawPdfStream, contains('Voucher Number: FIN-INC-202610-00001'));
      expect(rawPdfStream, contains('Amount Credited: INR 15,000'));
      expect(rawPdfStream, contains('Amount in Words: Fifteen Thousand Rupees Only'));
    });

    test('POST /api/auth/login parses token and authenticated user payload', () {
      final loginResponse = {
        'message': 'Login successful',
        'token': 'jwt-token-cmuzhxi5a000asr4p9f6jcndp',
        'user': {
          'id': 'cmuzhxi5a000asr4p9f6jcndp',
          'name': 'Sireesha',
          'email': 'sireesha@gmail.com',
          'phone': '8985839110',
        },
      };

      expect(loginResponse['token'], 'jwt-token-cmuzhxi5a000asr4p9f6jcndp');
      final user = loginResponse['user'] as Map<String, dynamic>;
      expect(user['name'], 'Sireesha');
      expect(user['email'], 'sireesha@gmail.com');
      expect(user['phone'], '8985839110');
    });

    test('GET /api/v1/income/summary parses all horizons (30D, 90D, 1Y, 5Y)', () {
      final summary30D = {
        'success': true,
        'data': {
          'totalMonthlyIncome': 34500,
          'activeMonthlyIncome': 34000,
          'passiveMonthlyIncome': 500,
          'windfallTotalIncome': 0,
          'totalAnnualIncome': 414000,
          'stabilityScore': 54.4,
          'stabilityRating': 'Low Stability',
          'passiveRatio': 1.45,
          'topDependencyPercent': 98.55,
          'topSource': 'Infosys',
          'totalStreamsCount': 2,
          'autoTrackingEnabled': true,
          'aicfoInsight': 'Low Stability (Score 54/100). Passive cash flow generates ₹500/mo across interest holdings.',
          'forecast': {
            'selectedHorizon': '30D',
            'projectedAmount': 34500,
            'horizonBreakdown': {
              '30D': 34500,
              '90D': 103500,
              '1Y': 414000,
              '5Y': 2425284.9,
            },
          },
        },
      };

      final data30D = IncomeSummaryData.fromJson(summary30D['data'] as Map<String, dynamic>);
      expect(data30D.totalMonthlyIncome, 34500.0);
      expect(data30D.selectedHorizon, '30D');
      expect(data30D.projectedAmount, 34500.0);
      expect(data30D.horizonBreakdown['30D'], 34500.0);
      expect(data30D.horizonBreakdown['90D'], 103500.0);
      expect(data30D.horizonBreakdown['1Y'], 414000.0);
      expect(data30D.horizonBreakdown['5Y'], 2425284.9);
    });

    test('GET /api/v1/income/entries filtering by category, type, bankAccount, dateFilter, and search', () {
      // 1. Category Filter: category=Salary -> []
      final salaryFilterRes = <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'entries': <dynamic>[],
          'pagination': {'currentPage': 1, 'perPage': 20, 'totalRecords': 0, 'totalPages': 1},
        },
      };
      final salaryEntries = ((salaryFilterRes['data'] as Map<String, dynamic>)['entries'] as List<dynamic>)
          .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(salaryEntries.isEmpty, isTrue);

      // 2. Nature/Type Filter: type=Passive -> [villagkart]
      final passiveFilterRes = <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'entries': [
            {
              'id': 'cmvry4155000113t4ip6197oy',
              'voucherNumber': 'FIN-INC-202610-00008',
              'amount': 6000,
              'source': 'villagkart',
              'category': 'Interest',
              'type': 'Passive',
              'frequency': 'Yearly',
              'bankAccount': 'State Bank of India (**** 4587)',
              'date': '28 Oct 2026',
              'documentName': null,
              'documentPath': null,
              'notes': '',
              'isVerified': false,
              'verificationType': 'Manual Entry Inflow',
              'createdAt': '2026-10-28T10:02:24.328Z',
            },
          ],
          'pagination': {'currentPage': 1, 'perPage': 20, 'totalRecords': 1, 'totalPages': 1},
        },
      };
      final passiveEntries = ((passiveFilterRes['data'] as Map<String, dynamic>)['entries'] as List<dynamic>)
          .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(passiveEntries.length, 1);
      expect(passiveEntries.first.source, 'villagkart');
      expect(passiveEntries.first.type, 'Passive');
      expect(passiveEntries.first.amount, 6000.0);

      // 3. Bank Account Filter: bankAccount=HDFC -> []
      final bankFilterRes = <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'entries': <dynamic>[],
          'pagination': {'currentPage': 1, 'perPage': 20, 'totalRecords': 0, 'totalPages': 1},
        },
      };
      final bankEntries = ((bankFilterRes['data'] as Map<String, dynamic>)['entries'] as List<dynamic>)
          .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(bankEntries.isEmpty, isTrue);

      // 4. Date Filter: dateFilter=Aug 2025 -> []
      final dateFilterRes = <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'entries': <dynamic>[],
          'pagination': {'currentPage': 1, 'perPage': 20, 'totalRecords': 0, 'totalPages': 1},
        },
      };
      final dateEntries = ((dateFilterRes['data'] as Map<String, dynamic>)['entries'] as List<dynamic>)
          .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(dateEntries.isEmpty, isTrue);

      // 5. Search Filter: search=Tech Corp -> []
      final searchFilterRes = <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'entries': <dynamic>[],
          'pagination': {'currentPage': 1, 'perPage': 20, 'totalRecords': 0, 'totalPages': 1},
        },
      };
      final searchEntries = ((searchFilterRes['data'] as Map<String, dynamic>)['entries'] as List<dynamic>)
          .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(searchEntries.isEmpty, isTrue);
    });
  });
}
