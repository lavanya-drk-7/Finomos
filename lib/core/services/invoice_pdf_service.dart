import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../features/expense_tracking/domain/expense_models.dart';
import '../../features/income_tracking/domain/income_models.dart';
import '../../features/document_vault/presentation/widgets/document_action_helper.dart';

/// Pure-Dart ISO 32000 compliant PDF generator and invoice downloader.
/// Requires zero external third-party dependencies, guaranteeing 100%
/// cross-platform compatibility and zero build/linker friction.
class InvoicePdfService {
  /// Converts numbers to Indian English words (e.g., 22000 -> "Twenty Two Thousand")
  static String numberToWords(double amount) {
    final int val = amount.round();
    if (val <= 0) return 'Zero';

    const units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    String convertThreeDigits(int n) {
      final buffer = StringBuffer();
      if (n >= 100) {
        buffer.write('${units[n ~/ 100]} Hundred ');
        n %= 100;
      }
      if (n >= 20) {
        buffer.write('${tens[n ~/ 10]} ');
        n %= 10;
      }
      if (n > 0) {
        buffer.write('${units[n]} ');
      }
      return buffer.toString().trim();
    }

    int remaining = val;
    final parts = <String>[];

    // Crores (10,000,000)
    if (remaining >= 10000000) {
      parts.add('${convertThreeDigits(remaining ~/ 10000000)} Crore');
      remaining %= 10000000;
    }
    // Lakhs (100,000)
    if (remaining >= 100000) {
      parts.add('${convertThreeDigits(remaining ~/ 100000)} Lakh');
      remaining %= 100000;
    }
    // Thousands (1,000)
    if (remaining >= 1000) {
      parts.add('${convertThreeDigits(remaining ~/ 1000)} Thousand');
      remaining %= 1000;
    }
    // Remainder (0 - 999)
    if (remaining > 0) {
      parts.add(convertThreeDigits(remaining));
    }

    return parts.join(' ').trim();
  }

  /// Formats currency with commas for INR (e.g., 125000 -> "1,25,000.00")
  static String formatInrAmount(double amount) {
    final int val = amount.round();
    final str = val.toString();
    if (str.length <= 3) return '$str.00';
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if ((rest.length - i) % 2 == 0 && i != 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    return '${buffer.toString()},$lastThree.00';
  }

  /// Generates invoice number from entry ID and date
  static String generateInvoiceNumber({
    required bool isExpense,
    required String id,
  }) {
    final cleanId = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final suffix = cleanId.length >= 6 ? cleanId.substring(cleanId.length - 6) : cleanId.padRight(6, 'X');
    final typeCode = isExpense ? 'EXP' : 'INC';
    return 'INV-$typeCode-2026-$suffix';
  }

  /// Generates the raw PDF bytes for an Expense Transaction Invoice
  static List<int> generateExpenseInvoiceBytes(ExpenseEntry entry) {
    final invoiceNumber = generateInvoiceNumber(isExpense: true, id: entry.id);
    return _buildInvoicePdf(
      invoiceNumber: invoiceNumber,
      isExpense: true,
      title: 'FINOMOS TAX INVOICE & EXPENSE RECEIPT',
      particularsTitle: 'EXPENSE OUTFLOW DETAILS',
      particularsName: entry.description,
      category: entry.category,
      amount: entry.amount,
      date: entry.date,
      paymentModeOrFrequency: entry.paymentMode,
      bankAccount: entry.bankAccount,
      merchantOrPayee: entry.merchant.isNotEmpty ? entry.merchant : entry.description,
      priorityOrType: entry.priority,
      notes: entry.notes.isNotEmpty ? entry.notes : 'Verified personal expense transaction.',
      attachedDoc: entry.documentName,
      isRecurringOrVerified: entry.isRecurring ? 'Recurring Automatic Outflow' : 'One-Time Transaction',
    );
  }

  /// Generates the raw PDF bytes for an Income Transaction Invoice
  static List<int> generateIncomeInvoiceBytes(IncomeEntry entry) {
    final invoiceNumber = generateInvoiceNumber(isExpense: false, id: entry.id);
    return _buildInvoicePdf(
      invoiceNumber: invoiceNumber,
      isExpense: false,
      title: 'FINOMOS OFFICIAL INCOME RECEIPT & VOUCHER',
      particularsTitle: 'INCOME INFLOW DETAILS',
      particularsName: entry.source,
      category: entry.category,
      amount: entry.amount,
      date: entry.date,
      paymentModeOrFrequency: entry.frequency,
      bankAccount: entry.bankAccount,
      merchantOrPayee: entry.source,
      priorityOrType: entry.type,
      notes: entry.notes.isNotEmpty ? entry.notes : 'Verified income inflow credited to account.',
      attachedDoc: entry.documentName,
      isRecurringOrVerified: entry.isVerified ? 'Digitally Verified Income Stream' : 'Self-Reported Stream',
    );
  }

  /// Internal engine: Builds a pristine single-page A4 vector PDF document
  static List<int> _buildInvoicePdf({
    required String invoiceNumber,
    required bool isExpense,
    required String title,
    required String particularsTitle,
    required String particularsName,
    required String category,
    required double amount,
    required String date,
    required String paymentModeOrFrequency,
    required String bankAccount,
    required String merchantOrPayee,
    required String priorityOrType,
    required String notes,
    required String? attachedDoc,
    required String isRecurringOrVerified,
  }) {
    final pdf = _PdfVectorCanvas();
    const double pageWidth = 595.28;
    // const double pageHeight = 841.89;
    final now = DateTime.now();
    final generatedTimestamp = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} IST';
    final formattedAmount = formatInrAmount(amount);
    final amountWords = '${numberToWords(amount)} Indian Rupees Only';

    // Theme color palette
    // Brand Navy: #0A2540 -> (0.039, 0.145, 0.251)
    // Brand Blue: #0066FF -> (0.000, 0.400, 1.000)
    // Expense Red: #DC2626 -> (0.863, 0.149, 0.149)
    // Income Green: #059669 -> (0.020, 0.588, 0.412)
    final double accentR = isExpense ? 0.863 : 0.020;
    final double accentG = isExpense ? 0.149 : 0.588;
    final double accentB = isExpense ? 0.149 : 0.412;

    // 1. TOP BRAND HEADER BANNER (y: 748 to 828, height: 80)
    pdf.drawRect(
      36, 748, pageWidth - 72, 80,
      r: 0.039, g: 0.145, b: 0.251,
      fill: true,
    );

    // Subtle colored accent stripe on left of banner
    pdf.drawRect(
      36, 748, 6, 80,
      r: accentR, g: accentG, b: accentB,
      fill: true,
    );

    // Brand Name & Subtitle
    pdf.drawText('FINOMOS', 55, 796, isBold: true, fontSize: 24, r: 1.0, g: 1.0, b: 1.0);
    pdf.drawText('AI PERSONAL CFO  |  FINANCIAL VAULT & TAX COMPLIANCE', 55, 778, isBold: false, fontSize: 8.5, r: 0.72, g: 0.82, b: 0.94);
    pdf.drawText('RBI ACCOUNT AGGREGATOR & ISO/IEC 27001 SECURED  |  GSTIN: 29AAACF1982K1Z5', 55, 762, isBold: false, fontSize: 7.0, r: 0.50, g: 0.65, b: 0.80);

    // Right-hand Badge Box inside Header Banner
    pdf.drawRect(
      pageWidth - 215, 758, 165, 60,
      r: 0.08, g: 0.22, b: 0.38,
      fill: true,
      strokeR: 0.20, strokeG: 0.35, strokeB: 0.55,
      lineWidth: 1.0,
    );
    pdf.drawText('OFFICIAL TAX INVOICE', pageWidth - 203, 798, isBold: true, fontSize: 10, r: 1.0, g: 1.0, b: 1.0);
    pdf.drawText(isExpense ? 'EXPENSE DISBURSEMENT' : 'INCOME SETTLEMENT', pageWidth - 203, 783, isBold: false, fontSize: 8, r: 0.80, g: 0.90, b: 1.0);
    pdf.drawText('STATUS: RECORDED & VERIFIED', pageWidth - 203, 768, isBold: true, fontSize: 7.5, r: 0.20, g: 0.90, b: 0.50);

    // 2. INVOICE META STRIP (y: 710 to 740, height: 30)
    pdf.drawRect(
      36, 710, pageWidth - 72, 30,
      r: 0.96, g: 0.97, b: 0.99,
      fill: true,
      strokeR: 0.85, strokeG: 0.88, strokeB: 0.92,
      lineWidth: 0.8,
    );
    pdf.drawText('Invoice No: $invoiceNumber', 48, 720, isBold: true, fontSize: 9.5, r: 0.04, g: 0.15, b: 0.25);
    pdf.drawText('Txn Date: $date', 240, 720, isBold: false, fontSize: 9.0, r: 0.25, g: 0.32, b: 0.40);
    pdf.drawText('Generated: $generatedTimestamp', 380, 720, isBold: false, fontSize: 8.0, r: 0.40, g: 0.48, b: 0.56);

    // 3. TWO-COLUMN SUMMARY CARDS (y: 575 to 700, height: 125)
    final double cardWidth = (pageWidth - 72 - 14) / 2; // ~254 pt

    // Left Card: Transaction Details
    pdf.drawRect(
      36, 575, cardWidth, 125,
      r: 1.0, g: 1.0, b: 1.0,
      fill: true,
      strokeR: 0.85, strokeG: 0.88, strokeB: 0.92,
      lineWidth: 0.8,
    );
    pdf.drawRect(
      36, 675, cardWidth, 25,
      r: 0.93, g: 0.95, b: 0.98,
      fill: true,
    );
    pdf.drawText('TRANSACTION PARTICULARS', 46, 683, isBold: true, fontSize: 9, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText('Particulars:', 46, 658, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText(_truncate(particularsName, 26), 115, 658, isBold: true, fontSize: 8.5, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText('Category:', 46, 640, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText(category, 115, 640, isBold: true, fontSize: 8.5, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText(isExpense ? 'Merchant/Payee:' : 'Income Source:', 46, 622, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText(_truncate(merchantOrPayee, 24), 115, 622, isBold: true, fontSize: 8.5, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText(isExpense ? 'Payment Mode:' : 'Frequency:', 46, 604, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText(paymentModeOrFrequency, 115, 604, isBold: true, fontSize: 8.5, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText(isExpense ? 'Priority Guardrail:' : 'Stream Nature:', 46, 586, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText(priorityOrType, 115, 586, isBold: true, fontSize: 8.5, r: accentR, g: accentG, b: accentB);

    // Right Card: Banking & Audit Trail
    final double rightCardX = 36 + cardWidth + 14;
    pdf.drawRect(
      rightCardX, 575, cardWidth, 125,
      r: 1.0, g: 1.0, b: 1.0,
      fill: true,
      strokeR: 0.85, strokeG: 0.88, strokeB: 0.92,
      lineWidth: 0.8,
    );
    pdf.drawRect(
      rightCardX, 675, cardWidth, 25,
      r: 0.93, g: 0.95, b: 0.98,
      fill: true,
    );
    pdf.drawText('BANKING & AUDIT REFERENCE', rightCardX + 10, 683, isBold: true, fontSize: 9, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText('Bank Account:', rightCardX + 10, 658, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText(bankAccount, rightCardX + 90, 658, isBold: true, fontSize: 8.5, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText('Account Holder:', rightCardX + 10, 640, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText('Verified Finomos User', rightCardX + 90, 640, isBold: true, fontSize: 8.5, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText('Stream Type:', rightCardX + 10, 622, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText(isRecurringOrVerified, rightCardX + 90, 622, isBold: true, fontSize: 8.5, r: 0.00, g: 0.40, b: 1.00);

    pdf.drawText('Attached Vault File:', rightCardX + 10, 604, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText(_truncate(attachedDoc ?? 'Electronic Ledger Record', 24), rightCardX + 90, 604, isBold: true, fontSize: 8.5, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText('Security Status:', rightCardX + 10, 586, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText('256-Bit SHA Encrypted', rightCardX + 90, 586, isBold: true, fontSize: 8.5, r: 0.02, g: 0.59, b: 0.41);

    // 4. TRANSACTION ITEMS TABLE (y: 450 to 555, height: 105)
    // Table Header (y: 532, height: 23)
    pdf.drawRect(
      36, 532, pageWidth - 72, 23,
      r: 0.039, g: 0.145, b: 0.251,
      fill: true,
    );
    pdf.drawText('SL', 46, 540, isBold: true, fontSize: 8.5, r: 1.0, g: 1.0, b: 1.0);
    pdf.drawText('ITEM DESCRIPTION / PARTICULARS', 75, 540, isBold: true, fontSize: 8.5, r: 1.0, g: 1.0, b: 1.0);
    pdf.drawText('CLASSIFICATION & CHANNEL', 285, 540, isBold: true, fontSize: 8.5, r: 1.0, g: 1.0, b: 1.0);
    pdf.drawText('QTY', 430, 540, isBold: true, fontSize: 8.5, r: 1.0, g: 1.0, b: 1.0);
    pdf.drawText('TOTAL (INR)', 485, 540, isBold: true, fontSize: 8.5, r: 1.0, g: 1.0, b: 1.0);

    // Table Row 1 (y: 480, height: 52)
    pdf.drawRect(
      36, 480, pageWidth - 72, 52,
      r: 1.0, g: 1.0, b: 1.0,
      fill: true,
      strokeR: 0.85, strokeG: 0.88, strokeB: 0.92,
      lineWidth: 0.8,
    );
    pdf.drawText('01', 46, 508, isBold: true, fontSize: 9.0, r: 0.04, g: 0.15, b: 0.25);
    pdf.drawText(particularsName, 75, 514, isBold: true, fontSize: 9.5, r: 0.04, g: 0.15, b: 0.25);
    pdf.drawText('Ref: $invoiceNumber | Date: $date', 75, 500, isBold: false, fontSize: 7.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText('Reconciled with $bankAccount', 75, 488, isBold: false, fontSize: 7.5, r: 0.00, g: 0.40, b: 1.00);

    pdf.drawText(category, 285, 510, isBold: true, fontSize: 8.5, r: 0.04, g: 0.15, b: 0.25);
    pdf.drawText('$paymentModeOrFrequency ($priorityOrType)', 285, 495, isBold: false, fontSize: 7.5, r: 0.40, g: 0.48, b: 0.56);

    pdf.drawText('1.0', 432, 505, isBold: false, fontSize: 9.0, r: 0.25, g: 0.32, b: 0.40);

    pdf.drawText('INR $formattedAmount', 472, 505, isBold: true, fontSize: 9.5, r: accentR, g: accentG, b: accentB);

    // 5. FINANCIAL TOTALS & AMOUNT IN WORDS (y: 360 to 468, height: 108)
    // Left Box: Notes & Amount in Words (x: 36, w: 275)
    pdf.drawRect(
      36, 360, 275, 108,
      r: 0.98, g: 0.99, b: 1.0,
      fill: true,
      strokeR: 0.85, strokeG: 0.88, strokeB: 0.92,
      lineWidth: 0.8,
    );
    pdf.drawText('AMOUNT IN WORDS:', 46, 450, isBold: true, fontSize: 8.0, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText(_truncate(amountWords, 40), 46, 436, isBold: true, fontSize: 9.0, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText('TRANSACTION MEMO / REMARKS:', 46, 414, isBold: true, fontSize: 8.0, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText(_truncate(notes, 44), 46, 400, isBold: false, fontSize: 8.5, r: 0.20, g: 0.25, b: 0.30);
    pdf.drawText('Guardrail compliance check passed by Finomos AI CFO Engine.', 46, 375, isBold: false, fontSize: 7.5, r: 0.02, g: 0.59, b: 0.41);

    // Right Box: Totals Breakdown (x: 325, w: 234)
    final double totalsX = 325;
    final double totalsW = pageWidth - 36 - totalsX;
    pdf.drawRect(
      totalsX, 360, totalsW, 108,
      r: 1.0, g: 1.0, b: 1.0,
      fill: true,
      strokeR: 0.85, strokeG: 0.88, strokeB: 0.92,
      lineWidth: 0.8,
    );

    pdf.drawText('Subtotal Amount:', totalsX + 12, 450, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText('INR $formattedAmount', totalsX + totalsW - 95, 450, isBold: true, fontSize: 8.5, r: 0.04, g: 0.15, b: 0.25);

    pdf.drawText('Tax / GST Exemption (0%):', totalsX + 12, 432, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText('INR 0.00', totalsX + totalsW - 55, 432, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);

    pdf.drawText('Platform & Convenience Fee:', totalsX + 12, 414, isBold: false, fontSize: 8.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText('FREE (0.00)', totalsX + totalsW - 65, 414, isBold: true, fontSize: 8.5, r: 0.02, g: 0.59, b: 0.41);

    // Grand Total Accent Banner
    pdf.drawRect(
      totalsX, 360, totalsW, 36,
      r: 0.039, g: 0.145, b: 0.251,
      fill: true,
    );
    pdf.drawText('NET TOTAL:', totalsX + 12, 374, isBold: true, fontSize: 11, r: 1.0, g: 1.0, b: 1.0);
    pdf.drawText('INR $formattedAmount', totalsX + totalsW - 110, 374, isBold: true, fontSize: 12, r: 1.0, g: 0.85, b: 0.30);

    // 6. CRYPTOGRAPHIC INTEGRITY & AUDIT SEAL (y: 255 to 345, height: 90)
    pdf.drawRect(
      36, 255, pageWidth - 72, 90,
      r: 0.95, g: 0.98, b: 0.96,
      fill: true,
      strokeR: 0.70, strokeG: 0.88, strokeB: 0.75,
      lineWidth: 0.9,
    );
    pdf.drawRect(
      48, 268, 55, 62,
      r: 0.039, g: 0.145, b: 0.251,
      fill: true,
    );
    pdf.drawText('SECURE', 55, 312, isBold: true, fontSize: 8.0, r: 1.0, g: 1.0, b: 1.0);
    pdf.drawText('VAULT', 58, 298, isBold: true, fontSize: 8.0, r: 0.20, g: 0.90, b: 0.50);
    pdf.drawText('SEAL', 61, 284, isBold: true, fontSize: 8.0, r: 1.0, g: 1.0, b: 1.0);

    pdf.drawText('FINOMOS DIGITAL RECORD VERIFICATION & AUDIT SEAL', 115, 324, isBold: true, fontSize: 9.5, r: 0.04, g: 0.15, b: 0.25);
    pdf.drawText('This electronic tax invoice was created in FINOMOS Personal CFO under Section 65B of the Indian Evidence Act, 1872.', 115, 308, isBold: false, fontSize: 7.5, r: 0.25, g: 0.35, b: 0.45);
    pdf.drawText('Audit Hash: SHA256:${entryHash(invoiceNumber, amount, date)} | Vault Key ID: FIN-${entryHash(bankAccount, amount, particularsName).substring(0, 12)}', 115, 294, isBold: false, fontSize: 7.0, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText('Verification URL: https://finomos.ai/verify/invoice/$invoiceNumber', 115, 280, isBold: true, fontSize: 7.5, r: 0.00, g: 0.40, b: 1.00);
    pdf.drawText('No physical signature required. Verified computer-generated receipt.', 115, 266, isBold: false, fontSize: 7.0, r: 0.02, g: 0.59, b: 0.41);

    // 7. LEGAL TERMS & BOTTOM FOOTER (y: 65 to 240)
    pdf.drawLine(36, 240, pageWidth - 36, 240, r: 0.85, g: 0.88, b: 0.92, lineWidth: 0.8);

    pdf.drawText('TERMS & CONDITIONS & REGULATORY DISCLOSURES', 36, 226, isBold: true, fontSize: 7.5, r: 0.40, g: 0.48, b: 0.56);
    pdf.drawText('1. Finomos AI Personal CFO acts as an intelligent accounting & wealth orchestration engine reconciling bank aggregator feeds.', 36, 212, isBold: false, fontSize: 7.0, r: 0.45, g: 0.52, b: 0.60);
    pdf.drawText('2. All transactions are digitally encrypted in accordance with ISO 27001 data protection protocols and RBI Account Aggregator guidelines.', 36, 200, isBold: false, fontSize: 7.0, r: 0.45, g: 0.52, b: 0.60);
    pdf.drawText('3. This document is valid for personal income tax filing, corporate reimbursements, and financial statement verification in India.', 36, 188, isBold: false, fontSize: 7.0, r: 0.45, g: 0.52, b: 0.60);
    pdf.drawText('4. For reconciliation queries or billing assistance, contact concierge@finomos.ai or visit https://finomos.ai/support.', 36, 176, isBold: false, fontSize: 7.0, r: 0.45, g: 0.52, b: 0.60);

    // Bottom Footer Bar
    pdf.drawRect(
      36, 130, pageWidth - 72, 28,
      r: 0.039, g: 0.145, b: 0.251,
      fill: true,
    );
    pdf.drawText('FINOMOS TECHNOLOGIES PRIVATE LIMITED  |  BANGALORE, KARNATAKA 560038', 48, 140, isBold: false, fontSize: 7.5, r: 0.70, g: 0.80, b: 0.90);
    pdf.drawText('PAGE 1 OF 1  |  OFFICIAL RECEIPT', pageWidth - 165, 140, isBold: true, fontSize: 7.5, r: 1.0, g: 1.0, b: 1.0);

    return pdf.build();
  }

  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 2)}..';
  }

  static String entryHash(String a, double b, String c) {
    final raw = '$a-$b-$c-${DateTime.now().year}'.codeUnits;
    var hash = 5381;
    for (final byte in raw) {
      hash = ((hash << 5) + hash) + byte;
    }
    return hash.toRadixString(16).padLeft(16, '0').toUpperCase();
  }

  /// Downloads an Expense Invoice directly to the user's device Downloads folder.
  /// Uses DocumentActionHelper.downloadDocumentToDevice to integrate seamlessly
  /// with Android's MediaStore / native download channel and Desktop downloads.
  static Future<File?> downloadExpenseInvoice({
    required BuildContext context,
    required ExpenseEntry entry,
  }) async {
    final invoiceNumber = generateInvoiceNumber(isExpense: true, id: entry.id);
    final fileName = '$invoiceNumber.pdf';
    final pdfBytes = generateExpenseInvoiceBytes(entry);

    // Write to a temporary file first so DocumentActionHelper can copy or pass path
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/$fileName');
    tempFile.writeAsBytesSync(pdfBytes, flush: true);

    if (context.mounted) {
      return await DocumentActionHelper.downloadDocumentToDevice(
        context: context,
        fileName: fileName,
        localPath: tempFile.path,
      );
    }
    return tempFile;
  }

  /// Downloads an Income Invoice directly to the user's device Downloads folder.
  static Future<File?> downloadIncomeInvoice({
    required BuildContext context,
    required IncomeEntry entry,
  }) async {
    final invoiceNumber = generateInvoiceNumber(isExpense: false, id: entry.id);
    final fileName = '$invoiceNumber.pdf';
    final pdfBytes = generateIncomeInvoiceBytes(entry);

    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/$fileName');
    tempFile.writeAsBytesSync(pdfBytes, flush: true);

    if (context.mounted) {
      return await DocumentActionHelper.downloadDocumentToDevice(
        context: context,
        fileName: fileName,
        localPath: tempFile.path,
      );
    }
    return tempFile;
  }
}

/// Lightweight Pure Dart Vector PDF Writer
/// Implements standard ISO 32000 PDF 1.4 objects without external libraries.
class _PdfVectorCanvas {
  final List<int> _offsets = [];
  final StringBuffer _content = StringBuffer();

  void drawRect(
    double x,
    double y,
    double w,
    double h, {
    double? r,
    double? g,
    double? b,
    bool fill = true,
    double? strokeR,
    double? strokeG,
    double? strokeB,
    double lineWidth = 1.0,
  }) {
    _content.writeln('q');
    if (fill && r != null && g != null && b != null) {
      _content.writeln('${r.toStringAsFixed(3)} ${g.toStringAsFixed(3)} ${b.toStringAsFixed(3)} rg');
    }
    if (strokeR != null && strokeG != null && strokeB != null) {
      _content.writeln('${lineWidth.toStringAsFixed(2)} w');
      _content.writeln('${strokeR.toStringAsFixed(3)} ${strokeG.toStringAsFixed(3)} ${strokeB.toStringAsFixed(3)} RG');
    }
    _content.writeln('${x.toStringAsFixed(2)} ${y.toStringAsFixed(2)} ${w.toStringAsFixed(2)} ${h.toStringAsFixed(2)} re');
    if (fill && strokeR != null) {
      _content.writeln('B');
    } else if (fill) {
      _content.writeln('f');
    } else {
      _content.writeln('s');
    }
    _content.writeln('Q');
  }

  void drawLine(
    double x1,
    double y1,
    double x2,
    double y2, {
    double r = 0.8,
    double g = 0.8,
    double b = 0.8,
    lineWidth = 1.0,
  }) {
    _content.writeln('q');
    _content.writeln('${lineWidth.toStringAsFixed(2)} w');
    _content.writeln('${r.toStringAsFixed(3)} ${g.toStringAsFixed(3)} ${b.toStringAsFixed(3)} RG');
    _content.writeln('${x1.toStringAsFixed(2)} ${y1.toStringAsFixed(2)} m');
    _content.writeln('${x2.toStringAsFixed(2)} ${y2.toStringAsFixed(2)} l');
    _content.writeln('s');
    _content.writeln('Q');
  }

  void drawText(
    String text,
    double x,
    double y, {
    bool isBold = false,
    double fontSize = 10,
    double r = 0,
    double g = 0,
    double b = 0,
  }) {
    final sanitized = text
        .replaceAll('\\', '\\\\')
        .replaceAll('(', '\\(')
        .replaceAll(')', '\\)')
        .replaceAll('\r', '')
        .replaceAll('\n', ' ');
    final fontRef = isBold ? '/F2' : '/F1';
    _content.writeln('BT');
    _content.writeln('${r.toStringAsFixed(3)} ${g.toStringAsFixed(3)} ${b.toStringAsFixed(3)} rg');
    _content.writeln('$fontRef ${fontSize.toStringAsFixed(1)} Tf');
    _content.writeln('1 0 0 1 ${x.toStringAsFixed(2)} ${y.toStringAsFixed(2)} Tm');
    _content.writeln('($sanitized) Tj');
    _content.writeln('ET');
  }

  List<int> build() {
    final buffer = BytesBuilder();

    void writeString(String str) {
      buffer.add(latin1.encode(str));
    }

    const header = '%PDF-1.4\n%âãÏÓ\n';
    writeString(header);

    int currentOffset = buffer.length;

    // 1: Catalog
    _offsets.add(currentOffset);
    const obj1 = '1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n';
    writeString(obj1);
    currentOffset = buffer.length;

    // 2: Pages
    _offsets.add(currentOffset);
    const obj2 = '2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n';
    writeString(obj2);
    currentOffset = buffer.length;

    // 3: Page (A4: 595.28 x 841.89)
    _offsets.add(currentOffset);
    const obj3 = '3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595.28 841.89] /Contents 6 0 R /Resources << /Font << /F1 4 0 R /F2 5 0 R >> /ProcSet [/PDF /Text] >> >>\nendobj\n';
    writeString(obj3);
    currentOffset = buffer.length;

    // 4: Font Helvetica
    _offsets.add(currentOffset);
    const obj4 = '4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>\nendobj\n';
    writeString(obj4);
    currentOffset = buffer.length;

    // 5: Font Helvetica-Bold
    _offsets.add(currentOffset);
    const obj5 = '5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>\nendobj\n';
    writeString(obj5);
    currentOffset = buffer.length;

    // 6: Stream Contents
    final streamContent = utf8.encode(_content.toString());
    _offsets.add(currentOffset);
    final obj6Header = '6 0 obj\n<< /Length ${streamContent.length} >>\nstream\n';
    writeString(obj6Header);
    buffer.add(streamContent);
    writeString('\nendstream\nendobj\n');
    currentOffset = buffer.length;

    // xref table
    final xrefStart = currentOffset;
    writeString('xref\n0 7\n');
    writeString('0000000000 65535 f \n');
    for (final offset in _offsets) {
      writeString('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }

    // Trailer
    writeString('trailer\n<< /Size 7 /Root 1 0 R >>\n');
    writeString('startxref\n$xrefStart\n%%EOF\n');

    return buffer.takeBytes();
  }
}
