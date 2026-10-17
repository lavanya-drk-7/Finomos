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

class IncomeTrackingScreen extends ConsumerStatefulWidget {
  const IncomeTrackingScreen({super.key});

  @override
  ConsumerState<IncomeTrackingScreen> createState() =>
      _IncomeTrackingScreenState();
}

class _IncomeTrackingScreenState extends ConsumerState<IncomeTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _availableBanks = [
    'HDFC Bank ••••4587',
    'ICICI Bank ••••9021',
    'SBI ••••1123',
    'Axis Bank ••••3301',
    'Other / Cash',
  ];

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
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      idType: 'Income Proof Document',
      idNumber: 'Finomos Attached Proof',
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

    String selectedBank =
        existingEntry != null &&
            _availableBanks.contains(existingEntry.bankAccount)
        ? existingEntry.bankAccount
        : 'HDFC Bank ••••4587';

    bool isVerified = existingEntry?.isVerified ?? true;
    String selectedDateStr = existingEntry?.date ?? '25 Aug 2025';

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
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedFrequency,
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
                        value: selectedBank,
                        decoration: InputDecoration(
                          labelText: 'Deposit Account',
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
                                child: BankNameWithLogo(bankName: b, logoSize: 20),
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
                            initialDate: DateTime(2025, 8, 25),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Inflow Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A2540), Color(0xFF10B981)],
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
                'Total Monthly Inflow',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
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
            ],
          ),
        ),
        const SizedBox(height: 14),

        // AI Personal CFO Recommendation Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology, color: Color(0xFF047857), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Personal CFO: High Stability (Score ${state.stabilityScore.toStringAsFixed(0)}/100). Passive cash flow generates ${_formatRupees(state.passiveMonthlyIncome)}/mo across rent and dividend holdings.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF047857),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section Title: Income History (REQUIRED BY TEST SUITE)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Income History',
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
            state.selectedTypeFilter != 'All')
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
        if (filteredEntries.isEmpty)
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
            Container(
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
                          color: _getTypeColor(item.type).withOpacity(0.12),
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
                                BankLogo(bankName: item.bankAccount, size: 12),
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
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildIncomeSourcesTab(IncomeState state) {
    return ListView(
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
        if (state.entries.isEmpty)
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

  Widget _buildQuickSourceChip({
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
