import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/core/router/app_router.dart';
import 'package:finomos/main.dart';

void main() {
  testWidgets('Test navigating to /bank-aggregation via appRouter in FinomosApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FinomosApp(),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/bank-aggregation');
    await tester.pumpAndSettle();

    expect(find.text('Bank & Aggregation'), findsOneWidget);
    expect(find.text('CONSOLIDATED FINANCIAL NET WORTH'), findsOneWidget);
    expect(find.text('Connected Accounts'), findsOneWidget);
  });
}
