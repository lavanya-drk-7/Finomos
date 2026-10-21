import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../document_vault/presentation/widgets/document_action_helper.dart';
import '../../bank_aggregation/providers/bank_aggregation_provider.dart';
import '../domain/detected_transaction_model.dart';
import '../providers/transaction_detection_provider.dart';

class TransactionReviewScreen extends ConsumerStatefulWidget {
  final DetectedTransaction? detectedTransaction;

  const TransactionReviewScreen({
    super.key,
    this.detectedTransaction,
  });

  @override
  ConsumerState<TransactionReviewScreen> createState() => _TransactionReviewScreenState();
}

class _TransactionReviewScreenState extends ConsumerState<TransactionReviewScreen> {
  late TransactionClassification _selectedType;
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late TextEditingController _refIdController;
  late DateTime _selectedDate;
  late String _selectedBankAccount;
  late String _selectedCategory;
  late String _selectedPaymentMethod;

  String? _attachedDocName;
  String? _attachedDocPath;
  String? _attachedDocSize;

  bool _isSaving = false;
  String? _validationError;

  static const List<String> _expenseCategories = [
    'Food & Dining',
    'Groceries',
    'Transportation',
    'Shopping',
    'Rent & Housing',
    'Utilities',
    'Healthcare',
    'Education',
    'Entertainment',
    'Travel',
    'Personal Care',
    'Insurance',
    'Loan Payments',
    'Other',
  ];

  static const List<String> _incomeCategories = [
    'Salary',
    'Freelance Income',
    'Business Income',
    'Interest',
    'Investment Returns',
    'Rental Income',
    'Refunds',
    'Gifts',
    'Other',
  ];

  static const List<String> _paymentMethods = [
    'UPI',
    'Debit Card',
    'Credit Card',
    'Net Banking',
    'Bank Transfer',
    'Cash',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final txn = widget.detectedTransaction ?? _fallbackTransaction();

    _selectedType = txn.type == TransactionClassification.income
        ? TransactionClassification.income
        : TransactionClassification.expense;

    _amountController = TextEditingController(text: txn.amount.toStringAsFixed(0));
    _merchantController = TextEditingController(text: txn.merchantOrSource ?? '');
    _descriptionController = TextEditingController(text: txn.description);
    _notesController = TextEditingController(text: txn.notes);
    _refIdController = TextEditingController(text: txn.referenceId ?? '');
    _selectedDate = txn.timestamp;
    _selectedPaymentMethod = txn.paymentMethod;

    _selectedCategory = txn.suggestedCategory.isNotEmpty
        ? txn.suggestedCategory
        : (_selectedType == TransactionClassification.income ? 'Salary' : 'Food & Dining');

    // Default Bank Account from linked list
    _selectedBankAccount = txn.bankName.isNotEmpty
        ? '${txn.bankName} ${txn.accountIdentifier}'
        : 'HDFC Bank ••••4587';

    _attachedDocName = txn.documentName;
    _attachedDocPath = txn.documentPath;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _refIdController.dispose();
    super.dispose();
  }

  DetectedTransaction _fallbackTransaction() {
    return DetectedTransaction(
      id: 'txn_temp_${DateTime.now().millisecondsSinceEpoch}',
      rawSmsBody: 'Rs. 1,000 debited from your HDFC Bank account.',
      timestamp: DateTime.now(),
      type: TransactionClassification.expense,
      amount: 1000.0,
      bankName: 'HDFC Bank',
      accountIdentifier: '••••4587',
      referenceId: 'UPI/429182391024',
      merchantOrSource: 'Restaurant',
      paymentMethod: 'UPI',
      suggestedCategory: 'Food & Dining',
      description: 'Restaurant food bill',
      duplicateFingerprint: 'manual_1000_expense',
      createdAt: DateTime.now(),
    );
  }

  Future<void> _pickDocument() async {
    final result = await DocumentActionHelper.showDocumentSourcePickerSheet(
      context: context,
      idType: 'Receipt / Invoice Proof',
      currentFileName: _attachedDocName,
      isReplace: _attachedDocName != null,
    );

    if (result != null && mounted) {
      setState(() {
        _attachedDocName = result.fileName;
        _attachedDocPath = result.localPath;
        _attachedDocSize = result.fileSize;
      });
    }
  }

  void _confirmAndSave() async {
    final amt = double.tryParse(_amountController.text.trim());
    if (amt == null || amt <= 0) {
      setState(() => _validationError = 'Please enter a valid amount greater than ₹0');
      return;
    }

    setState(() {
      _isSaving = true;
      _validationError = null;
    });

    final txnId = widget.detectedTransaction?.id ?? 'txn_${DateTime.now().millisecondsSinceEpoch}';
    final dateStr =
        '${_selectedDate.day.toString().padLeft(2, "0")} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';

    // Simulate brief network/save state
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (_selectedType == TransactionClassification.expense) {
      ref.read(transactionDetectionProvider.notifier).confirmAsExpense(
            transactionId: txnId,
            amount: amt,
            category: _selectedCategory,
            bankAccount: _selectedBankAccount,
            paymentMode: _selectedPaymentMethod,
            merchant: _merchantController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : '${_merchantController.text.trim()} expense',
            notes: _notesController.text.trim(),
            date: dateStr,
            documentName: _attachedDocName,
            documentPath: _attachedDocPath,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense of ₹${amt.toStringAsFixed(0)} saved and budget updated!'),
          backgroundColor: const Color(0xFF10B981),
          action: SnackBarAction(
            label: 'View Budget',
            textColor: Colors.white,
            onPressed: () => context.go('/budget-management'),
          ),
        ),
      );
    } else if (_selectedType == TransactionClassification.income) {
      ref.read(transactionDetectionProvider.notifier).confirmAsIncome(
            transactionId: txnId,
            amount: amt,
            category: _selectedCategory,
            bankAccount: _selectedBankAccount,
            source: _merchantController.text.trim().isNotEmpty
                ? _merchantController.text.trim()
                : 'Credit Inflow',
            notes: _notesController.text.trim(),
            date: dateStr,
            documentName: _attachedDocName,
            documentPath: _attachedDocPath,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Income of ₹${amt.toStringAsFixed(0)} saved to Income History!'),
          backgroundColor: const Color(0xFF10B981),
          action: SnackBarAction(
            label: 'View Income',
            textColor: Colors.white,
            onPressed: () => context.go('/income-tracking'),
          ),
        ),
      );
    } else if (_selectedType == TransactionClassification.transfer) {
      // Marked as transfer
      ref.read(transactionDetectionProvider.notifier).dismissTransaction(txnId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Internal transfer recorded. Excluded from spending and income.'),
          backgroundColor: Color(0xFF0066FF),
        ),
      );
    } else {
      ref.read(transactionDetectionProvider.notifier).dismissTransaction(txnId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction recorded.')),
      );
    }

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final bankState = ref.watch(bankAggregationProvider);
    final linkedAccounts = bankState.bankAccounts
        .map((b) => '${b.bankName} ${b.maskedAccountNumber}')
        .toList();

    if (!linkedAccounts.contains(_selectedBankAccount)) {
      linkedAccounts.add(_selectedBankAccount);
    }

    final categories = _selectedType == TransactionClassification.income
        ? _incomeCategories
        : _expenseCategories;

    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0066FF)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const FinmosLogo(size: 24, showTagline: false, isHorizontal: true),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (widget.detectedTransaction != null) {
                ref
                    .read(transactionDetectionProvider.notifier)
                    .dismissTransaction(widget.detectedTransaction!.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction dismissed')),
                );
              }
              context.pop();
            },
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
            label: const Text('Dismiss', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Detected Banner Header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sms_outlined, size: 14, color: Color(0xFF0066FF)),
                              SizedBox(width: 4),
                              Text('SMS Detected Transaction',
                                  style: TextStyle(
                                      color: Color(0xFF0066FF),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Review Required',
                              style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (widget.detectedTransaction?.rawSmsBody != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          widget.detectedTransaction!.rawSmsBody,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF334155), fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Transaction Classification Segmented Switch
              const Text('TRANSACTION CLASSIFICATION',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTypeTab(TransactionClassification.expense, 'Expense', Icons.arrow_downward,
                        const Color(0xFFEF4444)),
                    _buildTypeTab(TransactionClassification.income, 'Income', Icons.arrow_upward,
                        const Color(0xFF10B981)),
                    _buildTypeTab(TransactionClassification.transfer, 'Transfer', Icons.swap_horiz,
                        const Color(0xFF0066FF)),
                    _buildTypeTab(TransactionClassification.refund, 'Refund', Icons.replay,
                        const Color(0xFF8B5CF6)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Transaction Form Container
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Field
                    const Text('Amount (₹) *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0A2540)),
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('₹', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0066FF), width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Field with Suggestions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Category *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                        if (widget.detectedTransaction?.suggestedCategory != null &&
                            widget.detectedTransaction!.suggestedCategory.isNotEmpty)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = widget.detectedTransaction!.suggestedCategory;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Suggested: ${widget.detectedTransaction!.suggestedCategory}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF0066FF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Linked Bank Account Field
                    const Text('Linked Bank Account *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBankAccount,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(Icons.account_balance, color: Color(0xFF0066FF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      items: linkedAccounts.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBankAccount = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Date & Time Picker
                    const Text('Transaction Date *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Color(0xFF0066FF)),
                            const SizedBox(width: 10),
                            Text(
                              '${_selectedDate.day.toString().padLeft(2, "0")} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A2540)),
                            ),
                            const Spacer(),
                            const Icon(Icons.edit_calendar, size: 18, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Merchant / Source Field
                    Text(_selectedType == TransactionClassification.income ? 'Payer / Source' : 'Merchant / Payee',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _merchantController,
                      decoration: InputDecoration(
                        hintText: _selectedType == TransactionClassification.income ? 'e.g. Tech Corp' : 'e.g. Swiggy, Toit',
                        prefixIcon: const Icon(Icons.storefront_outlined, color: Color(0xFF0066FF)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Payment Method & Reference ID
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Payment Method',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedPaymentMethod,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                                items: _paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedPaymentMethod = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Reference / UTR ID',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _refIdController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. 429182391024',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Description / Notes
                    const Text('Description / Notes',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Add transaction notes...',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Supporting Document Upload Card
                    const Text('Supporting Document (Optional)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: _attachedDocName != null
                          ? Row(
                              children: [
                                const Icon(Icons.receipt_long, color: Color(0xFF0066FF), size: 28),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_attachedDocName!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text(_attachedDocSize ?? 'Attached Document',
                                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF0066FF), size: 20),
                                  onPressed: () {
                                    DocumentActionHelper.showDocumentPreviewDialog(
                                      context: context,
                                      idType: 'Expense Receipt',
                                      idNumber: 'Finomos Attached Receipt',
                                      fileName: _attachedDocName!,
                                      fileSize: _attachedDocSize ?? '1.2 MB',
                                      uploadDate: 'Today',
                                      localPath: _attachedDocPath,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _attachedDocName = null;
                                      _attachedDocPath = null;
                                      _attachedDocSize = null;
                                    });
                                  },
                                ),
                              ],
                            )
                          : InkWell(
                              onTap: _pickDocument,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.cloud_upload_outlined, color: Color(0xFF0066FF), size: 20),
                                    SizedBox(width: 8),
                                    Text('Attach Bill, Receipt or Invoice Proof',
                                        style: TextStyle(
                                            color: Color(0xFF0066FF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_validationError != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_validationError!,
                              style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Save Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  onPressed: _isSaving ? null : _confirmAndSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          _selectedType == TransactionClassification.income
                              ? 'Confirm & Save Income'
                              : 'Confirm & Save Expense',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab(
    TransactionClassification type,
    String label,
    IconData icon,
    Color activeColor,
  ) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
            if (type == TransactionClassification.income) {
              _selectedCategory = 'Salary';
            } else {
              _selectedCategory = 'Food & Dining';
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
