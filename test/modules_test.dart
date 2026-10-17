import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finomos/features/bank_aggregation/presentation/bank_aggregation_screen.dart';
import 'package:finomos/features/income_tracking/presentation/income_tracking_screen.dart';
import 'package:finomos/features/expense_tracking/presentation/expense_tracking_screen.dart';
import 'package:finomos/features/budget_management/presentation/budget_management_screen.dart';
import 'package:finomos/features/dashboard/presentation/dashboard_screen.dart';
import 'package:finomos/features/notifications/presentation/notifications_screen.dart';
import 'package:finomos/features/document_vault/presentation/document_vault_screen.dart';
import 'package:finomos/features/admin_panel/presentation/admin_panel_screen.dart';
import 'package:finomos/features/cfo_ai/presentation/cfo_ai_screen.dart';
import 'package:finomos/features/protect/presentation/protect_screen.dart';
import 'package:finomos/features/borrow/presentation/borrow_screen.dart';
import 'package:finomos/features/grow/presentation/grow_screen.dart';
import 'package:finomos/features/plan/presentation/plan_screen.dart';
import 'package:finomos/features/comply/presentation/comply_screen.dart';
import 'package:finomos/features/advisor_ecosystem/presentation/advisor_ecosystem_screen.dart';
import 'package:finomos/features/fpms_admin/presentation/fpms_admin_screen.dart';

void main() {
  testWidgets('BankAggregationScreen renders properly with Module 2 FAA features', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: BankAggregationScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Bank Account Aggregation'), findsOneWidget);
    expect(find.text('CONSOLIDATED FINANCIAL NET WORTH', skipOffstage: false), findsOneWidget);
    expect(find.text('Connected Accounts', skipOffstage: false), findsOneWidget);
    expect(find.text('UPI Accounts & Mandates', skipOffstage: false), findsOneWidget);
    expect(find.text('Credit Cards & Limits', skipOffstage: false), findsOneWidget);
    expect(find.text('Loan Accounts & Liabilities', skipOffstage: false), findsOneWidget);
    expect(find.text('Consent Management (FAA-SEC-11)', skipOffstage: false), findsOneWidget);
  });

  testWidgets('IncomeTrackingScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: IncomeTrackingScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Income Tracking'), findsOneWidget);
    expect(find.text('Income History'), findsOneWidget);
  });

  testWidgets('ExpenseTrackingScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: ExpenseTrackingScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Expense Tracking'), findsOneWidget);
    expect(find.text('Expense List'), findsOneWidget);
  });

  testWidgets('ExpenseTrackingScreen adds expense and immediately displays it in Expense List', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: ExpenseTrackingScreen())));
    await tester.pumpAndSettle();

    // Tap AppBar Add Expense icon
    await tester.tap(find.byTooltip('Add Expense'));
    await tester.pumpAndSettle();

    // Enter amount and description
    final amountField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Expense Amount (₹)');
    final descField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Description / Purpose');
    await tester.enterText(amountField, '4500');
    await tester.enterText(descField, 'One Month Gym Membership');
    await tester.pumpAndSettle();

    // Tap Record Outflow
    await tester.ensureVisible(find.text('Record Outflow'));
    await tester.tap(find.text('Record Outflow'));
    await tester.pumpAndSettle();

    // Verify expense appears in list and shows JUST RECORDED badge
    expect(find.text('One Month Gym Membership'), findsOneWidget);
    expect(find.text('JUST RECORDED'), findsOneWidget);
  });

  testWidgets('BudgetManagementScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: BudgetManagementScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Budget Management'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DashboardScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Finomos Financial OS'), findsOneWidget);
    expect(find.text('1. INCOME'), findsOneWidget);
    expect(find.text('2. EXPENSE'), findsOneWidget);
    expect(find.text('3. PROTECT'), findsOneWidget);
    expect(find.text('4. BORROW'), findsOneWidget);
    expect(find.text('5. GROW'), findsOneWidget);
    expect(find.text('6. PLAN'), findsOneWidget);
    expect(find.text('7. COMPLY'), findsOneWidget);
    expect(find.text('ADVISORS'), findsOneWidget);
    expect(find.text('Emergency & Insurance'), findsOneWidget);
    expect(find.text('Debt & Repayment'), findsOneWidget);
    expect(find.text('Income & Forecasting'), findsNothing);
    expect(find.text('Expense & Cash Flow'), findsNothing);
    expect(find.text('Total Amount'), findsNothing);
    expect(find.text('₹1,32,500'), findsOneWidget);
    expect(find.text('+12.4%'), findsOneWidget);
    expect(find.text('₹52,899'), findsOneWidget);
    expect(find.text('39.9%'), findsOneWidget);
  });

  testWidgets('NotificationsScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: NotificationsScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Notifications & Alerts'), findsOneWidget);
  });

  testWidgets('DocumentVaultScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DocumentVaultScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Document Vault'), findsOneWidget);
  });

  testWidgets('AdminPanelScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AdminPanelScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Admin Panel Foundation'), findsOneWidget);
  });

  testWidgets('CfoAiScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: CfoAiScreen())));
    await tester.pumpAndSettle();
    expect(find.text('AI Personal CFO'), findsOneWidget);
  });



  testWidgets('ProtectScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: ProtectScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Protect Pillar'), findsOneWidget);
  });

  testWidgets('BorrowScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: BorrowScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Borrow Pillar'), findsOneWidget);
  });

  testWidgets('GrowScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: GrowScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Grow Pillar'), findsOneWidget);
  });

  testWidgets('PlanScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PlanScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Plan Pillar'), findsOneWidget);
  });

  testWidgets('ComplyScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: ComplyScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Comply Pillar'), findsOneWidget);
  });

  testWidgets('AdvisorEcosystemScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AdvisorEcosystemScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Advisor Ecosystem'), findsOneWidget);
  });

  testWidgets('FpmsAdminScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: FpmsAdminScreen())));
    await tester.pumpAndSettle();
    expect(find.text('FPMS Super Admin'), findsOneWidget);
  });
}
