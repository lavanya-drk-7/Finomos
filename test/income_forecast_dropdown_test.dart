import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/features/income_tracking/presentation/income_tracking_screen.dart';

void main() {
  testWidgets(
    'IncomeTrackingScreen: Forecast Horizon dropdown works, updates projected inflow, and has no overflows',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IncomeTrackingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify "LIVE CONNECTED" is removed
      expect(find.text('LIVE CONNECTED'), findsNothing);

      // 2. Verify old horizontal button bar is removed
      expect(find.text('Forecast Horizon:'), findsNothing);

      // 3. Verify Dropdown is present and shows initial '30D Horizon'
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.text('30D Horizon'), findsOneWidget);

      // 4. Verify initial projected inflow text is present below main amount
      expect(find.textContaining('Projected Inflow (30D):'), findsOneWidget);

      // 5. Tap the dropdown and select 90 Days (90D)
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Verify dropdown items are displayed
      expect(find.text('30 Days (30D)'), findsWidgets);
      expect(find.text('90 Days (90D)'), findsWidgets);
      expect(find.text('1 Year (1Y)'), findsWidgets);
      expect(find.text('5 Years (5Y)'), findsWidgets);

      // Select '90 Days (90D)'
      await tester.tap(find.text('90 Days (90D)').last);
      await tester.pumpAndSettle();

      // 6. Verify selected horizon is now 90D and projected inflow updated
      expect(find.text('90D Horizon'), findsOneWidget);
      expect(find.textContaining('Projected Inflow (90D):'), findsOneWidget);
    },
  );
}
