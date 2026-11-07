import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../../core/widgets/bank_logo.dart';
import '../../document_vault/presentation/widgets/document_action_helper.dart';
import '../domain/income_models.dart';
import '../providers/income_provider.dart';
import '../../../core/services/invoice_pdf_service.dart';
import '../../../core/services/api_client.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';

class IncomeTrackingScreen extends ConsumerStatefulWidget {
  const IncomeTrackingScreen({super.key});

  @override
  ConsumerState<IncomeTrackingScreen> createState() =>
      _IncomeTrackingScreenState();
}

class _IncomeTrackingScreenState extends ConsumerState<IncomeTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<String> _getUserBankAccountsList({String? existingAccount}) {
    final bankAccounts = ref.read(bankAggregationProvider).bankAccounts;
    final List<String> list = [];

    for (final acc in bankAccounts) {
      final digits =
          (acc.rawAccountNumber != null && acc.rawAccountNumber!.isNotEmpty)
          ? acc.rawAccountNumber!.replaceAll(RegExp(r'\D'), '')
          : acc.maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
      final last4 = digits.length >= 4
          ? digits.substring(digits.length - 4)
          : digits;
      final formatted = last4.isNotEmpty
          ? '${acc.bankName} ••••$last4'
          : acc.bankName;
      if (!list.contains(formatted)) {
        list.add(formatted);
      }
    }

    if (existingAccount != null && existingAccount.trim().isNotEmpty) {
      final exDigits = existingAccount.replaceAll(RegExp(r'\D'), '');
      final exLast4 = exDigits.length >= 4 ? exDigits.substring(exDigits.length - 4) : exDigits;
      final alreadyPresent = list.any((item) {
        if (item == existingAccount.trim()) return true;
        if (item == 'Other / Cash') return false;
        final itDigits = item.replaceAll(RegExp(r'\D'), '');
        final itLast4 = itDigits.length >= 4 ? itDigits.substring(itDigits.length - 4) : itDigits;
        return exLast4.isNotEmpty && itLast4.isNotEmpty && exLast4 == itLast4;
      });
      if (!alreadyPresent) {
        list.insert(0, existingAccount.trim());
      }
    }

    if (!list.contains('Other / Cash')) {
      list.add('Other / Cash');
    }

    return list;
  }

  // ignore: unused_field
  static const List<String> _availableBanks = ['Other / Cash'];

  static const List<String> _availableCategories = [
    'Salary',
    'Business',
    'Freelance',
    'Rental',
    'Dividend',
    'Interest',
    'Bonus',
    'Other',
  ];

  static const List<String> _availableFrequencies = [
    'Monthly',
    'One-time',
    'Quarterly',
    'Yearly',
    'Bi-weekly',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incomeProvider.notifier).loadLiveIncomeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    return '$day $month ${dt.year}';
  }

  String _formatRupees(double amount) {
    if (amount.isNaN || amount.isInfinite || amount < 0) return '₹0';
    final int val = amount.round();
    final str = val.toString();
    if (str.length <= 3) return '₹$str';
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if ((rest.length - i) % 2 == 0 && i != 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    return '₹${buffer.toString()},$lastThree';
  }

  Future<void> _viewUploadedDocument(
    BuildContext context,
    String docName,
    String? docPath,
  ) async {
    String resolvedPath = docPath ?? '';
    String fileSize = '1.2 MB';

    if (resolvedPath.startsWith('http://') ||
        resolvedPath.startsWith('https://')) {
      try {
        final bytes = await ApiClient().getBytes(resolvedPath);
        if (bytes != null && bytes.isNotEmpty) {
          final tempFile = File('${Directory.systemTemp.path}/$docName');
          await tempFile.writeAsBytes(bytes, flush: true);
          resolvedPath = tempFile.path;
          fileSize = bytes.length > 1024 * 1024
              ? '${(bytes.length / (1024 * 1024)).toStringAsFixed(1)} MB'
              : '${(bytes.length / 1024).toStringAsFixed(0)} KB';
        }
      } catch (_) {}
    } else if (resolvedPath.isNotEmpty) {
      try {
        final f = File(resolvedPath);
        if (f.existsSync()) {
          final bytes = f.lengthSync();
          fileSize = bytes > 1024 * 1024
              ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
              : '${(bytes / 1024).toStringAsFixed(0)} KB';
        }
      } catch (_) {}
    }

    if (!context.mounted) return;

    final isVoucher =
        docName.toUpperCase().contains('VOUCHER') ||
        docName.toUpperCase().startsWith('FIN-INC');

    DocumentActionHelper.showDocumentPreviewDialog(
      context: context,
      idType: isVoucher
          ? 'Official Section 65B Receipt Voucher'
          : 'Income Proof Document',
      idNumber: isVoucher
          ? docName.replaceAll('.pdf', '')
          : 'Finomos Attached Proof',
      fileName: docName,
      fileSize: fileSize,
      localPath: resolvedPath,
      uploadDate: 'Today',
      uploadSource: isVoucher
          ? 'RBI Account Aggregator & Section 65B Cloud Vault'
          : (resolvedPath.contains('cache')
                ? 'Camera / Gallery'
                : 'Attached Document'),
      onDownload: () =>
          _downloadUploadedDocument(context, docName, resolvedPath),
    );
  }

  Future<void> _downloadUploadedDocument(
    BuildContext context,
    String docName,
    String? docPath,
  ) async {
    String resolvedPath = docPath ?? '';
    if (resolvedPath.startsWith('http://') ||
        resolvedPath.startsWith('https://')) {
      try {
        final bytes = await ApiClient().getBytes(resolvedPath);
        if (bytes != null && bytes.isNotEmpty) {
          final tempFile = File('${Directory.systemTemp.path}/$docName');
          await tempFile.writeAsBytes(bytes, flush: true);
          resolvedPath = tempFile.path;
        }
      } catch (_) {}
    }

    if (!context.mounted) return;

    DocumentActionHelper.downloadDocumentToDevice(
      context: context,
      fileName: docName,
      localPath: resolvedPath,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2540),
            ),
          ),
        ),
      ],
    );
  }

  void _showTransactionDetailsSheet(BuildContext context, IncomeEntry item) {
    IncomeEntry currentEntry = item;
    final invoiceNumber =
        item.voucherNumber ??
        InvoicePdfService.generateInvoiceNumber(isExpense: false, id: item.id);

    IncomeVoucherData? voucherData;
    bool hasFetchedVoucher = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            if (!hasFetchedVoucher) {
              hasFetchedVoucher = true;
              ref
                  .read(incomeProvider.notifier)
                  .fetchVoucherDetails(item.id)
                  .then((v) {
                    if (v != null && modalCtx.mounted) {
                      setModalState(() {
                        voucherData = v;
                      });
                    }
                  });
              ref.read(incomeProvider.notifier).fetchSingleEntry(item.id).then((
                fresh,
              ) {
                if (fresh != null && modalCtx.mounted) {
                  setModalState(() {
                    currentEntry = fresh;
                  });
                }
              });
            }
            final attachedDocName =
                currentEntry.documentName ??
                (voucherData?.attachedDocumentUrl != null
                    ? voucherData!.attachedDocumentUrl!.split('/').last
                    : null);
            final attachedDocPath =
                currentEntry.documentPath ?? voucherData?.attachedDocumentUrl;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.90,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Color(0xFF059669),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transaction Details',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A2540),
                                  ),
                                ),
                                Text(
                                  'Official Income Receipt & Voucher',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF64748B),
                            ),
                            onPressed: () => Navigator.pop(sheetCtx),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Overview Amount Card
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0A2540),
                                    Color(0xFF059669),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0A2540,
                                    ).withOpacity(0.18),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'TOTAL AMOUNT RECEIVED',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF10B981),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF34D399),
                                              size: 11,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'VERIFIED',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '+${_formatRupees(item.amount)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.source,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Receipt Voucher: ${voucherData?.voucherNumber ?? item.voucherNumber ?? invoiceNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Detailed Information Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'INCOME SUMMARY',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0A2540),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const Divider(
                                    height: 16,
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  _buildDetailRow(
                                    'Source / Payee',
                                    item.source,
                                  ),
                                  const SizedBox(height: 8),
                                  if (voucherData?.amountInWords != null &&
                                      voucherData!
                                          .amountInWords
                                          .isNotEmpty) ...[
                                    _buildDetailRow(
                                      'Amount in Words',
                                      voucherData!.amountInWords,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  _buildDetailRow('Category', item.category),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('Date Credited', item.date),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Inflow Frequency',
                                    item.frequency,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Bank Account',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          BankLogo(
                                            bankName: item.bankAccount,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            item.bankAccount,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0A2540),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Stream Nature',
                                    '${item.type} Income',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Verification Status',
                                    currentEntry.verificationType ??
                                        (currentEntry.isVerified
                                            ? 'Digitally Verified Inflow'
                                            : 'Manual Entry Inflow'),
                                  ),
                                  if (currentEntry.voucherNumber != null &&
                                      currentEntry
                                          .voucherNumber!
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      'Voucher Number',
                                      currentEntry.voucherNumber!,
                                    ),
                                  ],
                                  if (currentEntry.createdAt != null &&
                                      currentEntry.createdAt!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      'Recorded Date',
                                      currentEntry.createdAt!.length >= 10
                                          ? currentEntry.createdAt!.substring(
                                              0,
                                              10,
                                            )
                                          : currentEntry.createdAt!,
                                    ),
                                  ],
                                  if (item.notes.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      'Notes / Remarks',
                                      item.notes,
                                    ),
                                  ],
                                  if (attachedDocName != null &&
                                      attachedDocName.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Attached Document',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: InkWell(
                                            onTap: () => _viewUploadedDocument(
                                              context,
                                              attachedDocName,
                                              attachedDocPath,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.attachment,
                                                  size: 14,
                                                  color: Color(0xFF0066FF),
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    attachedDocName,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF0066FF),
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Security & Compliance Card
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user_outlined,
                                    color: Color(0xFF0066FF),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      voucherData?.complianceStandard ??
                                          'Cryptographically verified & RBI Account Aggregator compliant record. Valid under Section 65B of Indian Evidence Act.',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF1E40AF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // Sticky Bottom Action Bar with Download Invoice Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              key: const ValueKey('download_invoice_button'),
                              onPressed: () async {
                                try {
                                  await InvoicePdfService.downloadIncomeInvoice(
                                    context: context,
                                    entry: item,
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Download failed: $e'),
                                        backgroundColor: const Color(
                                          0xFFEF4444,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                size: 20,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Download Invoice',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final invoiceNumber =
                                    item.voucherNumber ??
                                    InvoicePdfService.generateInvoiceNumber(
                                      isExpense: false,
                                      id: item.id,
                                    );
                                final fileName = '$invoiceNumber.pdf';
                                final bytes =
                                    InvoicePdfService.generateIncomeInvoiceBytes(
                                      item,
                                    );
                                final tempFile = File(
                                  '${Directory.systemTemp.path}/$fileName',
                                );
                                tempFile.writeAsBytesSync(bytes, flush: true);

                                if (context.mounted) {
                                  DocumentActionHelper.showDocumentPreviewDialog(
                                    context: context,
                                    idType: 'Income Voucher & Receipt',
                                    idNumber: invoiceNumber,
                                    fileName: fileName,
                                    fileSize:
                                        '${(bytes.length / 1024).toStringAsFixed(1)} KB',
                                    localPath: tempFile.path,
                                    uploadDate: item.date,
                                    uploadSource: 'Finomos AI Personal CFO',
                                    onDownload: () =>
                                        InvoicePdfService.downloadIncomeInvoice(
                                          context: context,
                                          entry: item,
                                        ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 18,
                                color: Color(0xFF0066FF),
                              ),
                              label: const Text(
                                'Preview Invoice Document',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0066FF),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF0066FF),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          if (voucherData?.voucherPdfUrl != null &&
                              voucherData!.voucherPdfUrl!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: TextButton.icon(
                                onPressed: () {
                                  _viewUploadedDocument(
                                    context,
                                    '${voucherData!.voucherNumber}.pdf',
                                    voucherData!.voucherPdfUrl,
                                  );
                                },
                                icon: const Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: Color(0xFF059669),
                                ),
                                label: const Text(
                                  'View Official Section 65B Voucher',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFECFDF5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(
                                      color: Color(0xFFA7F3D0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddIncomeSheet(
    BuildContext context, {
    IncomeEntry? existingEntry,
    String? defaultCategory,
    String? defaultSource,
  }) {
    final amountCtrl = TextEditingController(
      text: existingEntry != null
          ? existingEntry.amount.toStringAsFixed(0)
          : '',
    );
    final sourceCtrl = TextEditingController(
      text: existingEntry?.source ?? (defaultSource ?? ''),
    );
    final notesCtrl = TextEditingController(text: existingEntry?.notes ?? '');
    String selectedDocumentName = existingEntry?.documentName ?? '';
    String? selectedDocumentPath = existingEntry?.documentPath;

    String selectedCategory =
        existingEntry != null &&
            _availableCategories.contains(existingEntry.category)
        ? existingEntry.category
        : (defaultCategory != null &&
                  _availableCategories.contains(defaultCategory)
              ? defaultCategory
              : 'Salary');

    String selectedType = existingEntry?.type ?? 'Active';
    if (!['Active', 'Passive', 'Windfall'].contains(selectedType)) {
      selectedType = 'Active';
    }

    String selectedFrequency =
        existingEntry != null &&
            _availableFrequencies.contains(existingEntry.frequency)
        ? existingEntry.frequency
        : 'Monthly';

    final bankList = _getUserBankAccountsList(
      existingAccount: existingEntry?.bankAccount,
    );
    if (existingEntry != null &&
        existingEntry.bankAccount.isNotEmpty &&
        !bankList.contains(existingEntry.bankAccount)) {
      bankList.insert(bankList.length - 1, existingEntry.bankAccount);
    }

    String selectedBank =
        existingEntry != null && bankList.contains(existingEntry.bankAccount)
        ? existingEntry.bankAccount
        : bankList.first;

    bool isVerified = existingEntry?.isVerified ?? true;
    String selectedDateStr = existingEntry?.date ?? _formatDate(DateTime.now());

    String? amountError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetCtx).size.height * 0.90,
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            existingEntry != null
                                ? 'Edit Income Stream'
                                : 'Add Income Stream',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(sheetCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) {
                          if (amountError != null) {
                            setSheetState(() => amountError = null);
                          }
                        },
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2540),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Income Amount (₹)',
                          prefixIcon: const Icon(
                            Icons.currency_rupee,
                            color: Color(0xFF10B981),
                          ),
                          errorText: amountError,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: sourceCtrl,
                        decoration: InputDecoration(
                          labelText: 'Source / Employer / Client',
                          hintText: 'e.g. Infosys, Rental Flat, Consulting',
                          prefixIcon: const Icon(
                            Icons.business_outlined,
                            color: Color(0xFF0066FF),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _availableCategories.contains(selectedCategory)
                                  ? selectedCategory
                                  : _availableCategories.first,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _availableCategories
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        c,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setSheetState(() => selectedCategory = val!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _availableFrequencies.contains(selectedFrequency)
                                  ? selectedFrequency
                                  : _availableFrequencies.first,
                              decoration: InputDecoration(
                                labelText: 'Frequency',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _availableFrequencies
                                  .map(
                                    (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(
                                        f,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setSheetState(() => selectedFrequency = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: bankList.contains(selectedBank)
                            ? selectedBank
                            : (bankList.isNotEmpty ? bankList.first : null),
                        decoration: InputDecoration(
                          labelText: 'Deposit Account',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: bankList
                            .map(
                              (b) => DropdownMenuItem(
                                value: b,
                                child: BankNameWithLogo(
                                  bankName: b,
                                  logoSize: 20,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setSheetState(() => selectedBank = val!),
                      ),
                      const SizedBox(height: 12),

                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              selectedDateStr = _formatDate(picked);
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Color(0xFF0066FF),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Credit Date: $selectedDateStr',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0A2540),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'Change',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0066FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Document Upload Field (Replaces Stream Type)
                      const Text(
                        'Upload Document (Salary Slip, Invoice, Agreement)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          try {
                            final res =
                                await DocumentActionHelper.showDocumentSourcePickerSheet(
                                  context: sheetCtx,
                                  idType: 'Income Proof',
                                  currentFileName:
                                      selectedDocumentName.isNotEmpty
                                      ? selectedDocumentName
                                      : null,
                                );
                            if (res != null) {
                              setSheetState(() {
                                selectedDocumentName = res.fileName;
                                selectedDocumentPath = res.localPath;
                              });
                              if (res.localPath != null &&
                                  res.localPath!.isNotEmpty) {
                                try {
                                  final file = File(res.localPath!);
                                  if (file.existsSync()) {
                                    final uploaded = await ref
                                        .read(incomeProvider.notifier)
                                        .uploadProof(
                                          file,
                                          entryId: existingEntry?.id,
                                        );
                                    if (uploaded != null) {
                                      setSheetState(() {
                                        selectedDocumentName =
                                            uploaded.documentName;
                                        selectedDocumentPath =
                                            uploaded.documentPath;
                                      });
                                    }
                                  }
                                } catch (_) {}
                              }
                            }
                          } catch (e) {
                            setSheetState(() {
                              selectedDocumentName =
                                  '${selectedCategory}_Document.pdf';
                              selectedDocumentPath =
                                  '/documents/$selectedDocumentName';
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selectedDocumentName.isNotEmpty
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedDocumentName.isNotEmpty
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: selectedDocumentName.isNotEmpty
                              ? Row(
                                  children: [
                                    const Icon(
                                      Icons.description,
                                      color: Color(0xFF10B981),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedDocumentName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF065F46),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Text(
                                            'Document attached successfully',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF059669),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 20,
                                        color: Color(0xFF0066FF),
                                      ),
                                      tooltip: 'View Document',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      onPressed: () => _viewUploadedDocument(
                                        sheetCtx,
                                        selectedDocumentName,
                                        selectedDocumentPath,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.download_outlined,
                                        size: 20,
                                        color: Color(0xFF059669),
                                      ),
                                      tooltip: 'Download Document',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      onPressed: () =>
                                          _downloadUploadedDocument(
                                            context,
                                            selectedDocumentName,
                                            selectedDocumentPath,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Color(0xFFEF4444),
                                      ),
                                      tooltip: 'Remove Document',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      onPressed: () {
                                        setSheetState(() {
                                          selectedDocumentName = '';
                                          selectedDocumentPath = null;
                                        });
                                      },
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF0066FF,
                                        ).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.cloud_upload_outlined,
                                        color: Color(0xFF0066FF),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Upload Proof / Document',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0066FF),
                                            ),
                                          ),
                                          Text(
                                            'Salary slip, invoice, contract (PDF, JPG, PNG)',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.add_circle_outline,
                                      color: Color(0xFF0066FF),
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: notesCtrl,
                        decoration: InputDecoration(
                          labelText: 'Notes / Memo (Optional)',
                          hintText: 'e.g. Net monthly in-hand credit',
                          prefixIcon: const Icon(Icons.notes, size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            final cleanStr = amountCtrl.text.replaceAll(
                              RegExp(r'[^0-9.]'),
                              '',
                            );
                            final amount = double.tryParse(cleanStr) ?? 0.0;
                            if (amount <= 0) {
                              setSheetState(() {
                                amountError = 'Income Amount is required (> ₹0)';
                              });
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter an amount greater than ₹0',
                                  ),
                                  backgroundColor: Color(0xFFEF4444),
                                ),
                              );
                              return;
                            }

                            String src = sourceCtrl.text.trim();
                            if (src.isEmpty) {
                              src = selectedCategory.isNotEmpty
                                  ? selectedCategory
                                  : 'Income Source';
                            }

                            String autoType = 'Active';
                            final catLower = selectedCategory.toLowerCase();
                            if (catLower == 'rental' ||
                                catLower == 'dividend' ||
                                catLower == 'interest') {
                              autoType = 'Passive';
                            } else if (catLower == 'bonus') {
                              autoType = 'Windfall';
                            }

                            if (existingEntry != null) {
                              final updated = existingEntry.copyWith(
                                amount: amount,
                                source: src,
                                category: selectedCategory,
                                type: autoType,
                                frequency: selectedFrequency,
                                bankAccount: selectedBank,
                                date: selectedDateStr,
                                notes: notesCtrl.text.trim(),
                                isVerified: isVerified,
                                documentName: selectedDocumentName.isNotEmpty
                                    ? selectedDocumentName
                                    : null,
                                documentPath: selectedDocumentPath,
                              );
                              ref
                                  .read(incomeProvider.notifier)
                                  .updateIncome(updated);
                            } else {
                              final newEntry = IncomeEntry(
                                id: 'inc_${DateTime.now().millisecondsSinceEpoch}',
                                source: src,
                                category: selectedCategory,
                                type: autoType,
                                amount: amount,
                                date: selectedDateStr,
                                frequency: selectedFrequency,
                                bankAccount: selectedBank,
                                notes: notesCtrl.text.trim(),
                                isVerified: isVerified,
                                documentName: selectedDocumentName.isNotEmpty
                                    ? selectedDocumentName
                                    : null,
                                documentPath: selectedDocumentPath,
                              );
                              ref
                                  .read(incomeProvider.notifier)
                                  .addIncome(newEntry);
                            }

                            Navigator.pop(sheetCtx);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  existingEntry != null
                                      ? 'Income stream updated!'
                                      : 'Income stream recorded!',
                                ),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          },
                          child: Text(
                            existingEntry != null
                                ? 'Save Changes'
                                : 'Record Stream',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ignore: unused_element
  void _showConfirmInflowSheet(BuildContext context, DetectedInflow inflow) {
    String selectedCategory = inflow.suggestedCategory;
    if (!_availableCategories.contains(selectedCategory)) {
      selectedCategory = 'Salary';
    }
    String selectedFrequency = 'Monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
                top: 12,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Color(0xFF10B981),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Confirm Detected Inflow',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A2540),
                              ),
                            ),
                            Text(
                              'RBI Account Aggregator Live Feed Verification',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inflow.detectedSource,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${inflow.bankAccount} • ${inflow.date}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '+${_formatRupees(inflow.amount)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirm Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A2540),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    items: _availableCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedCategory = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Inflow Frequency',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A2540),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedFrequency,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    items: _availableFrequencies
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedFrequency = val);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(sheetCtx);
                        final created = await ref
                            .read(incomeProvider.notifier)
                            .confirmDetectedInflow(
                              inflow.detectedId,
                              category: selectedCategory,
                              frequency: selectedFrequency,
                            );
                        if (context.mounted && created != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added "${created.source}" as active income stream with Section 65B voucher ${created.voucherNumber}!',
                              ),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Confirm & Add to Income Streams',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 8,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF047857),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Filter Income Streams',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A2540),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(incomeProvider.notifier).resetFilters();
                            setSheetState(() {});
                          },
                          child: const Text(
                            'Reset All',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),

                    // Stream Nature / Type (Active, Passive, Windfall)
                    const Text(
                      'Stream Nature / Type',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (_, ref2, __) {
                        final st = ref2.watch(incomeProvider);
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: ['All', 'Active', 'Passive', 'Windfall']
                                .map((type) {
                                  final isSel =
                                      st.selectedTypeFilter.toLowerCase() ==
                                      type.toLowerCase();
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(type),
                                      selected: isSel,
                                      onSelected: (v) {
                                        ref
                                            .read(incomeProvider.notifier)
                                            .setTypeFilter(v ? type : 'All');
                                        setSheetState(() {});
                                      },
                                      selectedColor: const Color(0xFF10B981),
                                      backgroundColor: Colors.white,
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSel
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSel
                                            ? Colors.white
                                            : const Color(0xFF475569),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: isSel
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      showCheckmark: false,
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (_, ref2, __) {
                        final st = ref2.watch(incomeProvider);
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: ['All', ..._availableCategories].map((
                              cat,
                            ) {
                              final isSel =
                                  st.selectedCategoryFilter.toLowerCase() ==
                                  cat.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  selected: isSel,
                                  onSelected: (v) {
                                    ref
                                        .read(incomeProvider.notifier)
                                        .setCategoryFilter(v ? cat : 'All');
                                    setSheetState(() {});
                                  },
                                  selectedColor: const Color(0xFF0A2540),
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSel
                                        ? Colors.white
                                        : const Color(0xFF475569),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: isSel
                                          ? const Color(0xFF0A2540)
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  showCheckmark: false,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Date / Month
                    const Text(
                      'Date / Month',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (_, ref2, __) {
                        final st = ref2.watch(incomeProvider);
                        // Dynamically generate the last 4 months from today
                        final now = DateTime.now();
                        const monthNames = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        final recentMonths = List.generate(4, (i) {
                          final dt = DateTime(now.year, now.month - i, 1);
                          return '${monthNames[dt.month - 1]} ${dt.year}';
                        });
                        final dateOptions = ['All', ...recentMonths];
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              ...dateOptions.map((opt) {
                                final isSel =
                                    st.selectedDateFilter.toLowerCase() ==
                                    opt.toLowerCase();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(opt),
                                    selected: isSel,
                                    onSelected: (v) {
                                      ref
                                          .read(incomeProvider.notifier)
                                          .setDateFilter(v ? opt : 'All');
                                      setSheetState(() {});
                                    },
                                    selectedColor: const Color(0xFF10B981),
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSel
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSel
                                          ? Colors.white
                                          : const Color(0xFF475569),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isSel
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    showCheckmark: false,
                                  ),
                                );
                              }),
                              ActionChip(
                                avatar: const Icon(
                                  Icons.date_range,
                                  size: 14,
                                  color: Color(0xFF10B981),
                                ),
                                label: const Text(
                                  'Pick Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF047857),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFECFDF5),
                                side: const BorderSide(
                                  color: Color(0xFFA7F3D0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    ref
                                        .read(incomeProvider.notifier)
                                        .setDateFilter(_formatDate(picked));
                                    setSheetState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bank Account
                    const Text(
                      'Bank Account',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (_, ref2, __) {
                        final st = ref2.watch(incomeProvider);
                        final bankFilterOptions = <String>[
                          'All',
                          ..._getUserBankAccountsList(),
                        ];
                        for (final e in st.entries) {
                          if (e.bankAccount.trim().isNotEmpty) {
                            final eDigits = e.bankAccount.replaceAll(RegExp(r'\D'), '');
                            final eLast4 = eDigits.length >= 4 ? eDigits.substring(eDigits.length - 4) : eDigits;
                            final alreadyExists = bankFilterOptions.any((opt) {
                              if (opt == e.bankAccount) return true;
                              if (opt == 'All' || opt == 'Other / Cash') return false;
                              final optDigits = opt.replaceAll(RegExp(r'\D'), '');
                              final optLast4 = optDigits.length >= 4 ? optDigits.substring(optDigits.length - 4) : optDigits;
                              return eLast4.isNotEmpty && optLast4.isNotEmpty && eLast4 == optLast4;
                            });
                            if (!alreadyExists) {
                              bankFilterOptions.insert(
                                bankFilterOptions.length - 1,
                                e.bankAccount,
                              );
                            }
                          }
                        }
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: bankFilterOptions.map((bank) {
                              final isSel =
                                  st.selectedBankAccountFilter.toLowerCase() ==
                                  bank.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  avatar: bank == 'All'
                                      ? Icon(
                                          Icons.account_balance,
                                          size: 14,
                                          color: isSel
                                              ? Colors.white
                                              : const Color(0xFF64748B),
                                        )
                                      : BankLogo(bankName: bank, size: 16),
                                  label: Text(bank),
                                  selected: isSel,
                                  onSelected: (v) {
                                    ref
                                        .read(incomeProvider.notifier)
                                        .setBankAccountFilter(v ? bank : 'All');
                                    setSheetState(() {});
                                  },
                                  selectedColor: const Color(0xFF10B981),
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSel
                                        ? Colors.white
                                        : const Color(0xFF475569),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: isSel
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  showCheckmark: false,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'salary':
        return Icons.work_outline;
      case 'freelance':
        return Icons.laptop_mac_outlined;
      case 'business':
        return Icons.storefront_outlined;
      case 'rental':
        return Icons.apartment_outlined;
      case 'dividend':
        return Icons.trending_up;
      case 'interest':
        return Icons.savings_outlined;
      case 'bonus':
        return Icons.stars_outlined;
      default:
        return Icons.monetization_on_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'active':
        return const Color(0xFF0066FF);
      case 'passive':
        return const Color(0xFF10B981);
      case 'windfall':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'salary':
        return const Color(0xFF0066FF);
      case 'freelance':
        return const Color(0xFF10B981);
      case 'business':
        return const Color(0xFF8B5CF6);
      case 'rental':
        return const Color(0xFF0D9488);
      case 'dividend':
        return const Color(0xFFF59E0B);
      case 'interest':
        return const Color(0xFF06B6D4);
      case 'bonus':
        return const Color(0xFFF43F5E);
      default:
        return const Color(0xFF64748B);
    }
  }

  void _confirmDeleteIncome(BuildContext context, IncomeEntry item) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Delete Income Source',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2540),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${item.source}" (${_formatRupees(item.amount)})?\n\nThis will remove this income source and update your monthly inflow.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                ref.read(incomeProvider.notifier).deleteIncome(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Income source "${item.source}" deleted'),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incomeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A2540)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Row(
          children: [
            const FinmosLogo(size: 32, showTitle: false, showTagline: false),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Income Tracking',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A2540),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              tooltip: 'Add Income',
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF0066FF),
                size: 24,
              ),
              onPressed: () => _showAddIncomeSheet(context),
            ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0066FF),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF0066FF),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Income Streams'),
                Tab(text: 'Income Sources'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildStreamsTab(state), _buildIncomeSourcesTab(state)],
      ),
    );
  }

  Widget _buildStreamsTab(IncomeState state) {
    final filteredEntries = state.entries.where((e) {
      final matchesSearch =
          state.searchQuery.isEmpty ||
          e.source.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          e.category.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          e.bankAccount.toLowerCase().contains(state.searchQuery.toLowerCase());
      final matchesType =
          state.selectedTypeFilter == 'All' ||
          e.type.toLowerCase() == state.selectedTypeFilter.toLowerCase();
      final matchesCat =
          state.selectedCategoryFilter == 'All' ||
          e.category.toLowerCase() ==
              state.selectedCategoryFilter.toLowerCase();
      final matchesBank =
          state.selectedBankAccountFilter == 'All' ||
          e.bankAccount.toLowerCase().contains(
            state.selectedBankAccountFilter.toLowerCase(),
          );
      final matchesDate =
          state.selectedDateFilter == 'All' ||
          e.date.toLowerCase().contains(state.selectedDateFilter.toLowerCase());
      return matchesSearch &&
          matchesType &&
          matchesCat &&
          matchesBank &&
          matchesDate;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(incomeProvider.notifier).loadLiveIncomeData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Total Inflow Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF064E3B),
                  Color(0xFF047857),
                  Color(0xFF10B981),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF064E3B).withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Total Monthly Inflow',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white30, width: 0.8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              [
                                '30D',
                                '90D',
                                '1Y',
                                '5Y',
                              ].contains(state.forecastHorizon)
                              ? state.forecastHorizon
                              : '30D',
                          isDense: true,
                          dropdownColor: const Color(0xFF047857),
                          borderRadius: BorderRadius.circular(14),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 16,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '30D',
                              child: Text(
                                '30 Days (30D)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: '90D',
                              child: Text(
                                '90 Days (90D)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: '1Y',
                              child: Text(
                                '1 Year (1Y)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: '5Y',
                              child: Text(
                                '5 Years (5Y)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                          selectedItemBuilder: (BuildContext context) {
                            return const [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '30D Horizon',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '90D Horizon',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '1Y Horizon',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '5Y Horizon',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ];
                          },
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(incomeProvider.notifier)
                                  .setForecastHorizon(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _formatRupees(state.totalMonthlyIncome),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up,
                            size: 14,
                            color: Color(0xFF34D399),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Projected Inflow (${state.forecastHorizon}): ${_formatRupees(state.getForecastAmount(state.forecastHorizon))}',
                              style: const TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.forecastData != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        state.forecastData!.compoundingRate,
                        style: const TextStyle(
                          color: Color(0xFFA7F3D0),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Detected Inflow Banner from Account Aggregator feed
          if (state.detectedInflows.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF93C5FD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${state.detectedInflows.length} Inflow Detected',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACCOUNT AGGREGATOR',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final inflow in state.detectedInflows) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inflow.detectedSource,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${inflow.bankAccount} • ${inflow.date} • ${(inflow.confidenceScore * 100).round()}% match',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFBFDBFE),
                                            ),
                                          ),
                                          child: Text(
                                            inflow.suggestedCategory.isNotEmpty
                                                ? inflow.suggestedCategory
                                                : 'Salary',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1D4ED8),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECFDF5),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFA7F3D0),
                                            ),
                                          ),
                                          child: const Text(
                                            'Monthly',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF047857),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+${_formatRupees(inflow.amount)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFDC2626),
                                  side: const BorderSide(
                                    color: Color(0xFFFCA5A5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  ref
                                      .read(incomeProvider.notifier)
                                      .dismissDetectedInflow(inflow.detectedId);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF059669),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () async {
                                  final approved = await ref
                                      .read(incomeProvider.notifier)
                                      .approveDetectedInflow(inflow);
                                  if (mounted && approved != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Inflow "${approved.source}" approved & added to active streams',
                                        ),
                                        backgroundColor: const Color(
                                          0xFF10B981,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Approve',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Search Box (Queries live backend by source, company or notes)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (val) {
                ref.read(incomeProvider.notifier).setSearchQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search by source, company or notes...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(incomeProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Section Title: Income History (REQUIRED BY TEST SUITE)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Flexible(
                      child: Text(
                        'Income History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2540),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${filteredEntries.length} records',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showFilterSheet(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (state.selectedCategoryFilter != 'All' ||
                            state.selectedBankAccountFilter != 'All' ||
                            state.selectedDateFilter != 'All' ||
                            state.selectedTypeFilter != 'All')
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          (state.selectedCategoryFilter != 'All' ||
                              state.selectedBankAccountFilter != 'All' ||
                              state.selectedDateFilter != 'All' ||
                              state.selectedTypeFilter != 'All')
                          ? const Color(0xFF10B981)
                          : const Color(0xFFA7F3D0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 15,
                        color:
                            (state.selectedCategoryFilter != 'All' ||
                                state.selectedBankAccountFilter != 'All' ||
                                state.selectedDateFilter != 'All' ||
                                state.selectedTypeFilter != 'All')
                            ? Colors.white
                            : const Color(0xFF059669),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color:
                              (state.selectedCategoryFilter != 'All' ||
                                  state.selectedBankAccountFilter != 'All' ||
                                  state.selectedDateFilter != 'All' ||
                                  state.selectedTypeFilter != 'All')
                              ? Colors.white
                              : const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Active Filter Banner with badges (if any filter is active)
          if (state.selectedCategoryFilter != 'All' ||
              state.selectedBankAccountFilter != 'All' ||
              state.selectedDateFilter != 'All' ||
              state.selectedTypeFilter != 'All' ||
              state.searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(
                          Icons.filter_alt,
                          size: 16,
                          color: Color(0xFF059669),
                        ),
                        Text(
                          '${filteredEntries.length} of ${state.entries.length} shown',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF065F46),
                          ),
                        ),
                        if (state.selectedCategoryFilter != 'All')
                          _buildFilterBadge(
                            'Cat: ${state.selectedCategoryFilter}',
                            () {
                              ref
                                  .read(incomeProvider.notifier)
                                  .setCategoryFilter('All');
                            },
                          ),
                        if (state.selectedBankAccountFilter != 'All')
                          _buildFilterBadge(
                            'Bank: ${state.selectedBankAccountFilter.split(' ').first}',
                            () {
                              ref
                                  .read(incomeProvider.notifier)
                                  .setBankAccountFilter('All');
                            },
                          ),
                        if (state.selectedDateFilter != 'All')
                          _buildFilterBadge(
                            'Date: ${state.selectedDateFilter}',
                            () {
                              ref
                                  .read(incomeProvider.notifier)
                                  .setDateFilter('All');
                            },
                          ),
                        if (state.selectedTypeFilter != 'All')
                          _buildFilterBadge(
                            'Type: ${state.selectedTypeFilter}',
                            () {
                              ref
                                  .read(incomeProvider.notifier)
                                  .setTypeFilter('All');
                            },
                          ),
                        if (state.searchQuery.isNotEmpty)
                          _buildFilterBadge(
                            'Search: "${state.searchQuery}"',
                            () {
                              _searchController.clear();
                              ref
                                  .read(incomeProvider.notifier)
                                  .setSearchQuery('');
                            },
                          ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ref.read(incomeProvider.notifier).resetFilters();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Income Streams Cards
          if (state.isLoading && state.entries.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF047857)),
                    SizedBox(height: 12),
                    Text(
                      'Loading live income streams...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 36,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No streams match this filter',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () {
                        ref.read(incomeProvider.notifier).resetFilters();
                      },
                      child: const Text('Reset Filters'),
                    ),
                  ],
                ),
              ),
            )
          else
            for (final item in filteredEntries)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showTransactionDetailsSheet(context, item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _getTypeColor(
                                  item.type,
                                ).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getCategoryIcon(item.category),
                                color: _getTypeColor(item.type),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.source,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF0A2540),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (item.isVerified) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified,
                                          size: 14,
                                          color: Color(0xFF10B981),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.category} • ${item.frequency}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      BankLogo(
                                        bankName: item.bankAccount,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${item.bankAccount} • ${item.date}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+${_formatRupees(item.amount)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          if (state.pagination != null && state.pagination!.totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.chevron_left, size: 16),
                    label: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: state.pagination!.currentPage > 1
                        ? () => ref
                              .read(incomeProvider.notifier)
                              .setPage(state.pagination!.currentPage - 1)
                        : null,
                  ),
                  Text(
                    'Page ${state.pagination!.currentPage} of ${state.pagination!.totalPages} (${state.pagination!.totalRecords} total)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.chevron_right, size: 16),
                    label: const Text('Next', style: TextStyle(fontSize: 12)),
                    onPressed:
                        state.pagination!.currentPage <
                            state.pagination!.totalPages
                        ? () => ref
                              .read(incomeProvider.notifier)
                              .setPage(state.pagination!.currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIncomeSourcesTab(IncomeState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(incomeProvider.notifier).loadLiveIncomeData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Master Overview Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A2540), Color(0xFF0066FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A2540).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active Income Sources',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.entries.length} Sources',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatRupees(state.totalMonthlyIncome),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Total Monthly Realized Inflow across all sources',
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                ),
                const SizedBox(height: 14),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0066FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _showAddIncomeSheet(context),
                  icon: const Icon(Icons.add_circle, size: 18),
                  label: const Text(
                    'Add New Income Source',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Configured Income Sources',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2540),
                ),
              ),
              Text(
                '${state.entries.length} items',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Sources list
          if (state.isLoading && state.entries.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF047857)),
                    SizedBox(height: 12),
                    Text(
                      'Loading live income sources...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (state.entries.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 40,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No Income Sources Added Yet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add your salary, rental, business, or other income sources to track earnings.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => _showAddIncomeSheet(context),
                      child: const Text('Add Income Source'),
                    ),
                  ],
                ),
              ),
            )
          else
            for (final item in state.entries) _buildIncomeSourceCard(item),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildIncomeSourceCard(IncomeEntry item) {
    final catColor = _getCategoryColor(item.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getCategoryIcon(item.category),
                  color: catColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.source,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0A2540),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified,
                            size: 15,
                            color: Color(0xFF10B981),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildCardPill(item.category, catColor),
                        _buildCardPill(item.frequency, const Color(0xFF64748B)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatRupees(item.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    '/${item.frequency.toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                BankLogo(bankName: item.bankAccount, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${item.bankAccount}  •  ${item.date}${item.notes.isNotEmpty ? "  •  ${item.notes}" : ""}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => _showTransactionDetailsSheet(context, item),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 15,
                        color: Color(0xFF0A2540),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Invoice',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2540),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showAddIncomeSheet(context, existingEntry: item),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: Color(0xFF0066FF),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Edit Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0066FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _confirmDeleteIncome(context, item),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 15,
                        color: Color(0xFFEF4444),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFilterBadge(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(width: 3),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: Color(0xFF065F46)),
          ),
        ],
      ),
    );
  }
}
