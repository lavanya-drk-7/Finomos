import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/constants/api_constants.dart';
import 'package:finomos/core/services/cache_service.dart';
import 'package:finomos/features/income_tracking/domain/income_models.dart';
import 'package:finomos/features/income_tracking/providers/income_provider.dart';
import 'package:finomos/features/income_tracking/presentation/income_tracking_screen.dart';

void main() {
  setUp(() {
    LocalCacheService().remove('user_liquid_cash_entries');
    LocalCacheService().remove('user_liquid_cash_amount');
  });

  tearDown(() {
    LocalCacheService().remove('user_liquid_cash_entries');
    LocalCacheService().remove('user_liquid_cash_amount');
    LocalCacheService().remove('income_entries');
    LocalCacheService().remove('deleted_income_ids');
  });

  group('Income Confirm Detected Inflow API & Serialization Tests', () {
    test('1. ApiConstants builder matches exact backend URL', () {
      const detectedId = 'cmvrxpa5b0003ougit0s0ig69';
      final path = ApiConstants.incomeConfirmDetectedInflow(detectedId);
      expect(path, '/api/v1/income/detected-inflows/cmvrxpa5b0003ougit0s0ig69/confirm');
    });

    test('2. IncomeEntry parses exact API payload correctly', () {
      const rawJson = '''
      {
        "success": true,
        "message": "Detected inflow already confirmed and added to active income streams",
        "data": {
            "id": "inc_mw1mirldy64a",
            "userId": "cmuzhxi5a000asr4p9f6jcndp",
            "amount": 85000,
            "date": "04 Nov 2026",
            "category": "Salary",
            "source": "Infosys Technologies Ltd",
            "paymentMode": "State Bank of India ••••1123",
            "frequency": "Monthly",
            "notes": "Confirmed via SMS_ALERT (Ref: N/A)",
            "accountId": null,
            "accountNumber": "••••1123",
            "balanceAfter": null,
            "voucherNumber": "FIN-INC-202611-00002",
            "documentName": null,
            "documentPath": null,
            "receiptUrl": null,
            "isVerified": true,
            "verificationType": "Digitally Verified Inflow",
            "createdAt": "2026-11-04T04:35:38.162Z"
        }
      }
      ''';

      final Map<String, dynamic> body = jsonDecode(rawJson);
      expect(body['success'], true);
      expect(body['message'], contains('already confirmed'));

      final data = body['data'] as Map<String, dynamic>;
      final entry = IncomeEntry.fromJson(data);

      expect(entry.id, 'inc_mw1mirldy64a');
      expect(entry.userId, 'cmuzhxi5a000asr4p9f6jcndp');
      expect(entry.amount, 85000.0);
      expect(entry.date, '04 Nov 2026');
      expect(entry.category, 'Salary');
      expect(entry.source, 'Infosys Technologies Ltd');
      expect(entry.paymentMode, 'State Bank of India ••••1123');
      expect(entry.bankAccount, 'State Bank of India ••••1123');
      expect(entry.frequency, 'Monthly');
      expect(entry.notes, 'Confirmed via SMS_ALERT (Ref: N/A)');
      expect(entry.accountId, isNull);
      expect(entry.accountNumber, '••••1123');
      expect(entry.voucherNumber, 'FIN-INC-202611-00002');
      expect(entry.isVerified, true);
      expect(entry.verificationType, 'Digitally Verified Inflow');
      expect(entry.createdAt, '2026-11-04T04:35:38.162Z');

      // Test serialization back to JSON
      final jsonMap = entry.toJson();
      expect(jsonMap['amount'], 85000.0);
      expect(jsonMap['source'], 'Infosys Technologies Ltd');
      expect(jsonMap['category'], 'Salary');
      expect(jsonMap['voucherNumber'], 'FIN-INC-202611-00002');
      expect(jsonMap['verificationType'], 'Digitally Verified Inflow');
    });

    test('3. DetectedInflow parses SMS ingest entities and redirection info', () {
      final inflow = DetectedInflow(
        detectedId: 'cmvrxpa5b0003ougit0s0ig69',
        detectedSource: 'Infosys Technologies Ltd',
        suggestedCategory: 'Salary',
        amount: 85000.0,
        date: '04 Nov 2026',
        bankAccount: 'State Bank of India ••••1123',
        confidenceScore: 0.98,
        detectionChannel: 'SMS Alert',
        rawSms: 'Dear SBI User, A/C ••••1123 credited by Rs 85,000.00 on 03Nov26 by transfer from Infosys Technologies Ltd.',
        referenceId: '9901823912',
      );

      expect(inflow.detectedId, 'cmvrxpa5b0003ougit0s0ig69');
      expect(inflow.suggestedCategory, 'Salary');
      expect(inflow.amount, 85000.0);
    });
  });

  group('IncomeTrackingScreen Short Box Widget Tests', () {
    testWidgets('Displays Detected Inflow Short Box with Category, Frequency, Delete and Approve options', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const testInflow = DetectedInflow(
        detectedId: 'cmvrxpa5b0003ougit0s0ig69',
        detectedSource: 'Infosys Technologies Ltd',
        suggestedCategory: 'Salary',
        amount: 85000.0,
        date: '04 Nov 2026',
        bankAccount: 'State Bank of India ••••1123',
        confidenceScore: 0.98,
        detectionChannel: 'SMS Alert',
        referenceId: '9901823912',
      );

      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      // Add detected inflow to state
      container.read(incomeProvider.notifier).addDetectedInflow(testInflow);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: IncomeTrackingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for Short Box elements
      expect(find.text('Infosys Technologies Ltd'), findsWidgets);
      expect(find.textContaining('85,000'), findsWidgets);
      expect(find.text('Salary'), findsWidgets);
      expect(find.text('Monthly'), findsWidgets);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);

      // Tap Approve button
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();

      // Check SnackBar appeared
      expect(find.textContaining('approved & added to active streams'), findsOneWidget);

      // Verify that the detected inflow box is removed from pending list
      expect(container.read(incomeProvider).detectedInflows, isEmpty);
      // Verify that the approved entry is added to active entries
      expect(container.read(incomeProvider).entries.any((e) => e.source == 'Infosys Technologies Ltd'), isTrue);
    });
  });
}

