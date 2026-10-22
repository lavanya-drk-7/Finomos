import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../../core/widgets/bank_logo.dart';
import '../../document_vault/presentation/widgets/document_action_helper.dart';
import '../domain/expense_models.dart';
import '../providers/expense_provider.dart';
import '../../budget_management/providers/budget_provider.dart';
import '../../transaction_detection/presentation/widgets/in_app_transaction_alert_banner.dart';

class ExpenseTrackingScreen extends ConsumerStatefulWidget {
  const ExpenseTrackingScreen({super.key});

  @override
  ConsumerState<ExpenseTrackingScreen> createState() =>
      _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends ConsumerState<ExpenseTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _availableCategories = [
    'Housing',
    'Food',
    'Utilities',
    'Bills',
    'Healthcare',
    'Transportation',
    'Subscriptions',
    'Shopping',
    'Entertainment',
    'Other',
  ];

  static const List<String> _availablePriorities = [
    'P1 - Survival',
    'P2 - Protection',
    'P3 - Obligations',
    'P4 - Growth',
    'P5 - Lifestyle',
    'P6 - Luxury',
  ];

  static const List<String> _availablePaymentModes = [
    'UPI',
    'Credit Card',
    'Debit Card',
    'Net Banking',
    'Auto Debit',
    'Cash',
  ];

  static const List<String> _availableBanks = [
    'HDFC Bank ••••4587',
    'ICICI Bank ••••9021',
    'SBI ••••1123',
    'Axis Bank ••••3301',
    'Other / Cash',
  ];

  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  String? _highlightedExpenseId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
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

  void _viewUploadedDocument(
    BuildContext context,
    String docName,
    String? docPath,
  ) {
    String fileSize = '1.2 MB';
    if (docPath != null && docPath.isNotEmpty) {
      try {
        final f = File(docPath);
        if (f.existsSync()) {
          final bytes = f.lengthSync();
          fileSize = bytes > 1024 * 1024
              ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
              : '${(bytes / 1024).toStringAsFixed(0)} KB';
        }
      } catch (_) {}
    }

    DocumentActionHelper.showDocumentPreviewDialog(
      context: context,
      idType: 'Expense Receipt Document',
      idNumber: 'Finomos Attached Receipt',
      fileName: docName,
      fileSize: fileSize,
      localPath: docPath,
      uploadDate: 'Today',
      uploadSource: (docPath != null && docPath.contains('cache'))
          ? 'Camera / Gallery'
          : 'Attached Document',
      onDownload: () => _downloadUploadedDocument(context, docName, docPath),
    );
  }

  void _downloadUploadedDocument(
    BuildContext context,
    String docName,
    String? docPath,
  ) {
    DocumentActionHelper.downloadDocumentToDevice(
      context: context,
      fileName: docName,
      localPath: docPath,
    );
  }

  void _showAddExpenseSheet(
    BuildContext context, {
    ExpenseEntry? existingEntry,
    String? defaultCategory,
    String? defaultDesc,
    String? defaultPriority,
  }) {
    final amountCtrl = TextEditingController(
      text: existingEntry != null
          ? existingEntry.amount.toStringAsFixed(0)
          : '',
    );
    final descCtrl = TextEditingController(
      text: existingEntry?.description ?? (defaultDesc ?? ''),
    );
    final notesCtrl = TextEditingController(text: existingEntry?.notes ?? '');
    final merchantCtrl = TextEditingController(
      text: existingEntry?.merchant ?? '',
    );
    String selectedDocumentName = existingEntry?.documentName ?? '';
    String? selectedDocumentPath = existingEntry?.documentPath;

    String selectedCategory =
        existingEntry != null &&
            _availableCategories.contains(existingEntry.category)
        ? existingEntry.category
        : (defaultCategory != null &&
                  _availableCategories.contains(defaultCategory)
              ? defaultCategory
              : 'Food');

    String selectedPriority =
        existingEntry != null &&
            _availablePriorities.contains(existingEntry.priority)
        ? existingEntry.priority
        : (defaultPriority != null &&
                  _availablePriorities.contains(defaultPriority)
              ? defaultPriority
              : 'P1 - Survival');

    String selectedPaymentMode =
        existingEntry != null &&
            _availablePaymentModes.contains(existingEntry.paymentMode)
        ? existingEntry.paymentMode
        : 'UPI';

    String selectedBank =
        existingEntry != null &&
            _availableBanks.contains(existingEntry.bankAccount)
        ? existingEntry.bankAccount
        : 'HDFC Bank ••••4587';

    bool isRecurring = existingEntry?.isRecurring ?? false;
    DateTime selectedDateTime = DateTime.now();
    String selectedDateStr =
        existingEntry?.date ?? _formatDate(selectedDateTime);

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
                                ? 'Edit Expense Record'
                                : 'Record New Expense',
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2540),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Expense Amount (₹)',
                          prefixIcon: const Icon(
                            Icons.currency_rupee,
                            color: Color(0xFFEF4444),
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

                      TextField(
                        controller: descCtrl,
                        decoration: InputDecoration(
                          labelText: 'Description / Purpose',
                          hintText: 'e.g. Grocery staples, Rent, Dining out',
                          prefixIcon: const Icon(
                            Icons.description_outlined,
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

                      // Date & Month Picker
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: sheetCtx,
                            initialDate: selectedDateTime,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              selectedDateTime = picked;
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
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                size: 20,
                                color: Color(0xFF0066FF),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Expense Date / Month',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      selectedDateStr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A2540),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Change Date',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0066FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedCategory,
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
                      const SizedBox(height: 12),

                      // Bank Account Dropdown
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedBank,
                        decoration: InputDecoration(
                          labelText: 'Bank / Source Account',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _availableBanks
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

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedPaymentMode,
                              decoration: InputDecoration(
                                labelText: 'Payment Channel',
                                prefixIcon: const Icon(
                                  Icons.payment,
                                  size: 18,
                                  color: Color(0xFF0066FF),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _availablePaymentModes
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(
                                        m,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) => setSheetState(
                                () => selectedPaymentMode = val!,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: merchantCtrl,
                              decoration: InputDecoration(
                                labelText: 'Merchant / Payee',
                                hintText: 'e.g. Swiggy, Amazon',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Document Upload Field
                      const Text(
                        'Upload Receipt / Invoice / Bill Document',
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
                                  idType: 'Expense Receipt',
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
                            }
                          } catch (e) {
                            setSheetState(() {
                              selectedDocumentName =
                                  '${selectedCategory}_Receipt.pdf';
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
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedDocumentName.isNotEmpty
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: selectedDocumentName.isNotEmpty
                              ? Row(
                                  children: [
                                    const Icon(
                                      Icons.receipt_long,
                                      color: Color(0xFFEF4444),
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
                                              color: Color(0xFF991B1B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Text(
                                            'Receipt attached successfully',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFFDC2626),
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
                                          0xFFDC2626,
                                        ).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.cloud_upload_outlined,
                                        color: Color(0xFFDC2626),
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
                                            'Upload Receipt / Invoice',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFDC2626),
                                            ),
                                          ),
                                          Text(
                                            'Bill, tax invoice, payment receipt (PDF, JPG, PNG)',
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
                                      color: Color(0xFFDC2626),
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
                          hintText: 'e.g. Reimbursable, family shared',
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

                            String desc = descCtrl.text.trim();
                            if (desc.isEmpty) {
                              final merchant = merchantCtrl.text.trim();
                              if (merchant.isNotEmpty) {
                                desc = merchant;
                              } else if (selectedCategory.isNotEmpty) {
                                desc = selectedCategory;
                              } else {
                                desc = 'Expense';
                              }
                            }

                            if (existingEntry != null) {
                              final updated = existingEntry.copyWith(
                                amount: amount,
                                description: desc,
                                category: selectedCategory,
                                priority: selectedPriority,
                                paymentMode: selectedPaymentMode,
                                bankAccount: selectedBank,
                                date: selectedDateStr,
                                merchant: merchantCtrl.text.trim(),
                                notes: notesCtrl.text.trim(),
                                isRecurring: isRecurring,
                                documentName: selectedDocumentName.isNotEmpty
                                    ? selectedDocumentName
                                    : null,
                                documentPath: selectedDocumentPath,
                              );
                              ref
                                  .read(expenseProvider.notifier)
                                  .updateExpense(updated);
                              setState(() {
                                _highlightedExpenseId = updated.id;
                              });
                            } else {
                              final newId =
                                  'exp_${DateTime.now().millisecondsSinceEpoch}';
                              final newEntry = ExpenseEntry(
                                id: newId,
                                description: desc,
                                category: selectedCategory,
                                amount: amount,
                                date: selectedDateStr,
                                priority: selectedPriority,
                                paymentMode: selectedPaymentMode,
                                bankAccount: selectedBank,
                                merchant: merchantCtrl.text.trim(),
                                notes: notesCtrl.text.trim(),
                                isRecurring: isRecurring,
                                documentName: selectedDocumentName.isNotEmpty
                                    ? selectedDocumentName
                                    : null,
                                documentPath: selectedDocumentPath,
                              );
                              ref
                                  .read(expenseProvider.notifier)
                                  .addExpense(newEntry);
                              ref
                                  .read(budgetProvider.notifier)
                                  .applyExpense(
                                    category: selectedCategory,
                                    amount: amount,
                                    description: desc,
                                  );
                              setState(() {
                                _highlightedExpenseId = newId;
                              });
                            }

                            _searchController.clear();
                            if (_tabController.index == 0) {
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  0.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            }

                            Navigator.pop(sheetCtx);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  existingEntry != null
                                      ? 'Expense updated! "$desc" saved.'
                                      : 'Expense recorded! "$desc" added to list.',
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          child: Text(
                            existingEntry != null
                                ? 'Save Changes'
                                : 'Record Outflow',
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
                              color: Color(0xFF1E40AF),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Filter Expenses',
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
                            _searchController.clear();
                            ref.read(expenseProvider.notifier).resetFilters();
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
                        final st = ref2.watch(expenseProvider);
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
                                        .read(expenseProvider.notifier)
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
                        final st = ref2.watch(expenseProvider);
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
                                          .read(expenseProvider.notifier)
                                          .setDateFilter(v ? opt : 'All');
                                      setSheetState(() {});
                                    },
                                    selectedColor: const Color(0xFF0066FF),
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
                                            ? const Color(0xFF0066FF)
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
                                  color: Color(0xFF0066FF),
                                ),
                                label: const Text(
                                  'Pick Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1E40AF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFEFF6FF),
                                side: const BorderSide(
                                  color: Color(0xFFBFDBFE),
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
                                        .read(expenseProvider.notifier)
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
                        final st = ref2.watch(expenseProvider);
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: ['All', ..._availableBanks].map((bank) {
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
                                        .read(expenseProvider.notifier)
                                        .setBankAccountFilter(v ? bank : 'All');
                                    setSheetState(() {});
                                  },
                                  selectedColor: const Color(0xFF0066FF),
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
                                          ? const Color(0xFF0066FF)
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
                          backgroundColor: const Color(0xFF0066FF),
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
      case 'housing':
        return Icons.home_work_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'utilities':
        return Icons.bolt_outlined;
      case 'bills':
        return Icons.receipt_long_outlined;
      case 'healthcare':
        return Icons.medical_services_outlined;
      case 'transportation':
        return Icons.directions_car_outlined;
      case 'subscriptions':
        return Icons.subscriptions_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getPriorityColor(String priority) {
    if (priority.startsWith('P1')) return const Color(0xFFEF4444);
    if (priority.startsWith('P2')) return const Color(0xFF0066FF);
    if (priority.startsWith('P3')) return const Color(0xFFF59E0B);
    if (priority.startsWith('P4')) return const Color(0xFF10B981);
    if (priority.startsWith('P5')) return const Color(0xFF8B5CF6);
    return const Color(0xFFEC4899);
  }

  void _confirmDeleteExpense(BuildContext context, ExpenseEntry item) {
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
                  'Delete Expense Source',
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
            'Are you sure you want to delete "${item.description}" (${_formatRupees(item.amount)})?\n\nThis will remove this expense record and update your monthly outflow calculations.',
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
                ref.read(expenseProvider.notifier).deleteExpense(item.id);
                final remaining = ref
                    .read(expenseProvider)
                    .expenses
                    .where((e) => e.id != item.id)
                    .toList();
                ref
                    .read(budgetProvider.notifier)
                    .recalculateFromExpenses(remaining);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Expense "${item.description}" deleted and budget updated',
                    ),
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
    final state = ref.watch(expenseProvider);

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
                    'Expense Tracking',
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
              tooltip: 'Add Expense',
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF0066FF),
                size: 24,
              ),
              onPressed: () => _showAddExpenseSheet(context),
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
                Tab(text: 'Expenses & Subscriptions'),
                Tab(text: 'Expense Sources'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildExpensesTab(state), _buildExpenseSourcesTab(state)],
      ),
    );
  }

  Widget _buildExpensesTab(ExpenseState state) {
    final filteredExpenses = state.expenses.where((e) {
      final matchesSearch =
          state.searchQuery.isEmpty ||
          e.description.toLowerCase().contains(
            state.searchQuery.toLowerCase(),
          ) ||
          e.category.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          e.merchant.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          e.bankAccount.toLowerCase().contains(state.searchQuery.toLowerCase());
      final matchesPriority =
          state.selectedPriorityFilter == 'All' ||
          e.priority.toLowerCase().contains(
            state.selectedPriorityFilter.toLowerCase(),
          );
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
          matchesPriority &&
          matchesCat &&
          matchesBank &&
          matchesDate;
    }).toList();

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        const InAppTransactionAlertBanner(),
        // Outflow & Priority Overview Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A2540), Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A2540).withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Monthly Outflow',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _formatRupees(state.totalExpenses),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // AI Personal CFO Spending Coach Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology, color: Color(0xFFDC2626), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Personal CFO: Expense Health Score is ${state.expenseHealthScore.toStringAsFixed(0)}/100. Discretionary spending (${state.wantsRatio.toStringAsFixed(1)}%) is well within the 30% financial guardrail.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF991B1B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Search Box
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) =>
                ref.read(expenseProvider.notifier).setSearchQuery(val),
            decoration: InputDecoration(
              hintText: 'Search expenses by name, merchant, or category...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF64748B),
                size: 20,
              ),
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(expenseProvider.notifier).setSearchQuery('');
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
        const SizedBox(height: 14),

        // Section Title: Expense List (REQUIRED BY TEST SUITE)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Expense List',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2540),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${filteredExpenses.length} records',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0066FF),
                    ),
                  ),
                ),
              ],
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
                          state.selectedPriorityFilter != 'All')
                      ? const Color(0xFF0066FF)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        (state.selectedCategoryFilter != 'All' ||
                            state.selectedBankAccountFilter != 'All' ||
                            state.selectedDateFilter != 'All' ||
                            state.selectedPriorityFilter != 'All')
                        ? const Color(0xFF0066FF)
                        : const Color(0xFFBFDBFE),
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
                              state.selectedPriorityFilter != 'All')
                          ? Colors.white
                          : const Color(0xFF1E40AF),
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
                                state.selectedPriorityFilter != 'All')
                            ? Colors.white
                            : const Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Active Filter Banner with badges
        if (state.selectedCategoryFilter != 'All' ||
            state.selectedBankAccountFilter != 'All' ||
            state.selectedDateFilter != 'All' ||
            state.selectedPriorityFilter != 'All' ||
            state.searchQuery.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
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
                        color: Color(0xFF0066FF),
                      ),
                      Text(
                        '${filteredExpenses.length} of ${state.expenses.length} shown',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      if (state.selectedCategoryFilter != 'All')
                        _buildFilterBadge(
                          'Cat: ${state.selectedCategoryFilter}',
                          () {
                            ref
                                .read(expenseProvider.notifier)
                                .setCategoryFilter('All');
                          },
                        ),
                      if (state.selectedBankAccountFilter != 'All')
                        _buildFilterBadge(
                          'Bank: ${state.selectedBankAccountFilter.split(' ').first}',
                          () {
                            ref
                                .read(expenseProvider.notifier)
                                .setBankAccountFilter('All');
                          },
                        ),
                      if (state.selectedDateFilter != 'All')
                        _buildFilterBadge(
                          'Date: ${state.selectedDateFilter}',
                          () {
                            ref
                                .read(expenseProvider.notifier)
                                .setDateFilter('All');
                          },
                        ),
                      if (state.selectedPriorityFilter != 'All')
                        _buildFilterBadge(
                          'Pri: ${state.selectedPriorityFilter.split(' ').first}',
                          () {
                            ref
                                .read(expenseProvider.notifier)
                                .setPriorityFilter('All');
                          },
                        ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _searchController.clear();
                    ref.read(expenseProvider.notifier).resetFilters();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Expense Items Cards
        if (filteredExpenses.isEmpty)
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
                    'No expenses match this filter',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(expenseProvider.notifier).resetFilters();
                    },
                    child: const Text('Reset Filters'),
                  ),
                ],
              ),
            ),
          )
        else
          for (final item in filteredExpenses)
            Builder(
              builder: (context) {
                final isNewlyAdded = item.id == _highlightedExpenseId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isNewlyAdded
                        ? const Color(0xFFF0FDF4)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isNewlyAdded
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE2E8F0),
                      width: isNewlyAdded ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isNewlyAdded
                            ? const Color(0xFF10B981).withOpacity(0.12)
                            : Colors.black.withOpacity(0.02),
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
                              color: _getPriorityColor(
                                item.priority,
                              ).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(item.category),
                              color: _getPriorityColor(item.priority),
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
                                        item.description,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF0A2540),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isNewlyAdded) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'JUST RECORDED',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (item.isRecurring) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDBEAFE),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'AUTO',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0066FF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.category} • ${item.paymentMode}',
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
                                        '${item.bankAccount} • ${item.merchant.isNotEmpty ? "${item.merchant} • " : ""}${item.date}',
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
                            '-${_formatRupees(item.amount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildExpenseSourcesTab(ExpenseState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Master Card: Configured Expense Sources
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A2540), Color(0xFFDC2626)],
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
                    'Active Expense Sources',
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
                      '${state.expenses.length} Outflows',
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
                _formatRupees(state.totalExpenses),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Total Monthly Committed Outflow across all categories',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
              ),
              const SizedBox(height: 14),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _showAddExpenseSheet(context),
                icon: const Icon(Icons.add_circle, size: 18),
                label: const Text(
                  'Add New Expense Source',
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
              'Configured Expense Sources',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2540),
              ),
            ),
            Text(
              '${state.expenses.length} items',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Expense Sources list
        if (state.expenses.isEmpty)
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
                    Icons.receipt_outlined,
                    size: 40,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No Expense Sources Added Yet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2540),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add your rent, EMIs, utilities, groceries, and lifestyle expenses to manage outflows.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => _showAddExpenseSheet(context),
                    child: const Text('Add Expense Source'),
                  ),
                ],
              ),
            ),
          )
        else
          for (final item in state.expenses) _buildExpenseSourceCard(item),

        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildExpenseSourceCard(ExpenseEntry item) {
    final priColor = _getPriorityColor(item.priority);
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
                  color: priColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getCategoryIcon(item.category),
                  color: priColor,
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
                            item.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0A2540),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isRecurring) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'AUTO',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0066FF),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildCardPill(item.category, const Color(0xFF0A2540)),
                        _buildCardPill(
                          item.paymentMode,
                          const Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatRupees(item.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFFEF4444),
                ),
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
                    '${item.bankAccount}  •  ${item.merchant.isNotEmpty ? "${item.merchant}  •  " : ""}${item.date}${item.notes.isNotEmpty ? "  •  ${item.notes}" : ""}',
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
                onTap: () => _showAddExpenseSheet(context, existingEntry: item),
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
                onTap: () => _confirmDeleteExpense(context, item),
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

  Widget _buildHeaderMetricChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickExpenseChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
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
        color: const Color(0xFFDBEAFE),
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
              color: Color(0xFF1E40AF),
            ),
          ),
          const SizedBox(width: 3),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: Color(0xFF1E40AF)),
          ),
        ],
      ),
    );
  }
}
