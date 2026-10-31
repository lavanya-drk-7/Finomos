import 'package:flutter_test/flutter_test.dart';
import 'package:finomos/core/services/invoice_pdf_service.dart';
import 'package:finomos/features/expense_tracking/domain/expense_models.dart';
import 'package:finomos/features/income_tracking/domain/income_models.dart';

void main() {
  group('InvoicePdfService Tests', () {
    test('generateExpenseInvoiceBytes creates a valid PDF byte sequence', () {
      const expense = ExpenseEntry(
        id: 'exp-test-001',
        description: 'House Rent koramangala',
        category: 'Housing',
        amount: 22000.0,
        date: '24 Oct 2026',
        paymentMode: 'UPI',
        priority: 'P1 - Survival',
        isRecurring: true,
        merchant: 'Landlord Corp',
        notes: 'Monthly Koramangala rent',
        bankAccount: 'HDFC Bank ••••4587',
      );

      final bytes = InvoicePdfService.generateExpenseInvoiceBytes(expense);
      expect(bytes.isNotEmpty, isTrue);

      final str = String.fromCharCodes(bytes);
      expect(str.startsWith('%PDF-1.4'), isTrue);
      expect(str.contains('%%EOF'), isTrue);
      expect(str.contains('FINOMOS'), isTrue);
      final expectedInv = InvoicePdfService.generateInvoiceNumber(isExpense: true, id: expense.id);
      expect(str.contains(expectedInv), isTrue);
    });

    test('generateIncomeInvoiceBytes creates a valid PDF byte sequence', () {
      const income = IncomeEntry(
        id: 'inc-test-002',
        source: 'Senior Tech Consultant Salary',
        category: 'Salary',
        type: 'Active',
        amount: 85000.0,
        date: '22 Oct 2026',
        frequency: 'Monthly',
        bankAccount: 'HDFC Bank ••••4587',
        notes: 'Monthly tech retainer',
      );

      final bytes = InvoicePdfService.generateIncomeInvoiceBytes(income);
      expect(bytes.isNotEmpty, isTrue);

      final str = String.fromCharCodes(bytes);
      expect(str.startsWith('%PDF-1.4'), isTrue);
      expect(str.contains('%%EOF'), isTrue);
      expect(str.contains('FINOMOS'), isTrue);
      expect(str.contains('Senior Tech Consultant Salary'), isTrue);
      final expectedIncInv = InvoicePdfService.generateInvoiceNumber(isExpense: false, id: income.id);
      expect(str.contains(expectedIncInv), isTrue);
    });

    test('numberToWords correctly translates currency amounts', () {
      expect(InvoicePdfService.numberToWords(22000), 'Twenty Two Thousand');
      expect(InvoicePdfService.numberToWords(85000), 'Eighty Five Thousand');
      expect(InvoicePdfService.numberToWords(100000), 'One Lakh');
      expect(InvoicePdfService.numberToWords(1500), 'One Thousand Five Hundred');
    });
  });
}
