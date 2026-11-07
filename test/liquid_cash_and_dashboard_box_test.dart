import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/services/cache_service.dart';
import 'package:finomos/features/dashboard/presentation/dashboard_screen.dart';
import 'package:finomos/features/bank_aggregation/presentation/bank_aggregation_screen.dart';
import 'package:finomos/features/bank_aggregation/providers/bank_aggregation_provider.dart';

void main() {
  setUp(() {
    LocalCacheService().remove('user_liquid_cash_entries');
    LocalCacheService().remove('user_liquid_cash_amount');
  });

  tearDown(() {
    LocalCacheService().remove('user_liquid_cash_entries');
    LocalCacheService().remove('user_liquid_cash_amount');
  });

  group('DashboardScreen Non-Clickable Balance Showcase Box Tests', () {
    testWidgets('Dashboard showcase box with Total Available Balance and Liquid Cash Balance is not clickable', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Total Available Balance and Liquid Cash Balance labels
      final availableFinder = find.text('Total Available Balance');
      final liquidFinder = find.text('Liquid Cash Balance');
      expect(availableFinder, findsOneWidget);
      expect(liquidFinder, findsOneWidget);

      // Verify that the showcase card does NOT have an InkWell with an onTap handler
      // Searching for InkWell ancestor directly above Total Available Balance
      final inkWellAncestor = find.ancestor(
        of: availableFinder,
        matching: find.byType(InkWell),
      );
      expect(inkWellAncestor, findsNothing);

      // Tapping the balance area should not trigger navigation or error
      await tester.tap(availableFinder);
      await tester.pumpAndSettle();

      // We should still be on DashboardScreen
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Finomos Financial OS'), findsOneWidget);
    });
  });

  group('BankAggregationScreen Add Cash & Liquid Cash Section Tests', () {
    testWidgets('BankAggregationScreen renders Link Bank and Add Card buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BankAggregationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check +Link Bank button exists
      expect(find.text('Link Bank'), findsOneWidget);

      // Check +Add Card button exists
      expect(find.text('Add Card'), findsOneWidget);
    });

    testWidgets('BankAggregationNotifier adds, updates and deletes liquid cash dynamically without static 3000', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(bankAggregationProvider.notifier);
      await tester.pump(const Duration(milliseconds: 50));
      final initialState = container.read(bankAggregationProvider);

      // Initial state has no static 3000 liquid cash
      expect(initialState.totalLiquidCash, 0.0);
      expect(initialState.cashEntries.isEmpty, true);

      // Add ₹5,000 Liquid Cash
      await notifier.addLiquidCash(
        title: 'Physical Cash in Hand',
        amount: 5000.0,
        notes: 'Personal Wallet',
      );

      var state = container.read(bankAggregationProvider);
      expect(state.totalLiquidCash, 5000.0);
      expect(state.cashEntries.length, 1);
      expect(state.cashEntries.first.title, 'Physical Cash in Hand');
      expect(state.cashEntries.first.amount, 5000.0);

      // Add second liquid cash reserve of ₹2,500
      await notifier.addLiquidCash(
        title: 'Emergency Drawer',
        amount: 2500.0,
      );

      state = container.read(bankAggregationProvider);
      expect(state.totalLiquidCash, 7500.0);
      expect(state.cashEntries.length, 2);

      // Update first entry to ₹6,000
      final firstId = state.cashEntries.last.id;
      await notifier.updateLiquidCash(
        firstId,
        title: 'Physical Cash in Hand (Updated)',
        amount: 6000.0,
      );

      state = container.read(bankAggregationProvider);
      expect(state.totalLiquidCash, 8500.0);

      // Delete entry
      await notifier.deleteLiquidCash(firstId);
      state = container.read(bankAggregationProvider);
      expect(state.totalLiquidCash, 2500.0);
      expect(state.cashEntries.length, 1);
    });
  });
}
