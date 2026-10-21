import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../domain/budget_models.dart';
import '../providers/budget_provider.dart';
import '../../expense_tracking/domain/expense_models.dart';
import '../../expense_tracking/providers/expense_provider.dart';
import '../../transaction_detection/presentation/widgets/sms_simulator_dialog.dart';
import '../../transaction_detection/presentation/widgets/pending_transactions_sheet.dart';
import '../../transaction_detection/presentation/widgets/in_app_transaction_alert_banner.dart';
import '../../transaction_detection/providers/transaction_detection_provider.dart';

class BudgetManagementScreen extends ConsumerStatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  ConsumerState<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends ConsumerState<BudgetManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  String _selectedStatusFilter = 'All';
  String _selectedSortBy = 'Default';

  static const List<String> _categoryOptions = [
    'Food & Dining',
    'Groceries',
    'Transportation',
    'Shopping',
    'Rent & Housing',
    'Utilities',
    'Healthcare',
    'Entertainment',
    'Travel',
    'Other',
  ];

  static const List<String> _statusOptions = [
    'All',
    'On Track',
    '80% Warning',
    'Exceeded',
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
    _searchController.dispose();
    super.dispose();
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

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('dining') || cat.contains('restaurant')) {
      return Icons.restaurant;
    } else if (cat.contains('grocer')) {
      return Icons.local_grocery_store;
    } else if (cat.contains('transport') || cat.contains('travel') || cat.contains('fuel')) {
      return Icons.directions_car;
    } else if (cat.contains('shopping') || cat.contains('retail')) {
      return Icons.shopping_bag_outlined;
    } else if (cat.contains('utilit') || cat.contains('bill')) {
      return Icons.bolt;
    } else if (cat.contains('rent') || cat.contains('housing')) {
      return Icons.home_work_outlined;
    } else if (cat.contains('health') || cat.contains('medical')) {
      return Icons.medical_services_outlined;
    } else if (cat.contains('entertain') || cat.contains('movie')) {
      return Icons.movie_outlined;
    }
    return Icons.pie_chart_outline;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food')) return const Color(0xFFF97316);
    if (cat.contains('grocer')) return const Color(0xFF10B981);
    if (cat.contains('transport') || cat.contains('travel')) return const Color(0xFF0066FF);
    if (cat.contains('shopping')) return const Color(0xFF8B5CF6);
    if (cat.contains('utilit')) return const Color(0xFFEAB308);
    if (cat.contains('rent')) return const Color(0xFF0EA5E9);
    if (cat.contains('health')) return const Color(0xFFEF4444);
    if (cat.contains('entertain')) return const Color(0xFFEC4899);
    return const Color(0xFF64748B);
  }

  void _showFilterSheet(BuildContext context) {
    String tempStatus = _selectedStatusFilter;
    String tempCategory = _selectedCategoryFilter;
    String tempSort = _selectedSortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 10,
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
                              color: Color(0xFF0066FF),
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Filter Budgets',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A2540),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempStatus = 'All';
                              tempCategory = 'All';
                              tempSort = 'Default';
                            });
                          },
                          child: const Text(
                            'Reset All',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),

                    // Status Filter
                    const Text(
                      'Budget Status',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _statusOptions.map((status) {
                        final isSel = tempStatus == status;
                        Color statusColor = const Color(0xFF0066FF);
                        IconData statusIcon = Icons.all_inclusive;
                        if (status == 'On Track') {
                          statusColor = const Color(0xFF10B981);
                          statusIcon = Icons.check_circle_outline;
                        } else if (status == '80% Warning') {
                          statusColor = const Color(0xFFF59E0B);
                          statusIcon = Icons.warning_amber_rounded;
                        } else if (status == 'Exceeded') {
                          statusColor = const Color(0xFFEF4444);
                          statusIcon = Icons.error_outline;
                        }

                        return ChoiceChip(
                          avatar: Icon(
                            statusIcon,
                            size: 14,
                            color: isSel ? Colors.white : statusColor,
                          ),
                          label: Text(status),
                          selected: isSel,
                          onSelected: (selected) {
                            setSheetState(() {
                              tempStatus = selected ? status : 'All';
                            });
                          },
                          selectedColor: const Color(0xFF0066FF),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            color: isSel ? Colors.white : const Color(0xFF334155),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSel ? const Color(0xFF0066FF) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Category Filter
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All Categories', ..._categoryOptions].map((cat) {
                        final isSel = (cat == 'All Categories' && tempCategory == 'All') ||
                            tempCategory.toLowerCase() == cat.toLowerCase();
                        final icon = cat == 'All Categories'
                            ? Icons.apps
                            : _getCategoryIcon(cat);
                        final catColor = cat == 'All Categories'
                            ? const Color(0xFF0066FF)
                            : _getCategoryColor(cat);

                        return ChoiceChip(
                          avatar: Icon(
                            icon,
                            size: 14,
                            color: isSel ? Colors.white : catColor,
                          ),
                          label: Text(cat),
                          selected: isSel,
                          onSelected: (selected) {
                            setSheetState(() {
                              if (cat == 'All Categories') {
                                tempCategory = 'All';
                              } else {
                                tempCategory = selected ? cat : 'All';
                              }
                            });
                          },
                          selectedColor: const Color(0xFF0066FF),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            color: isSel ? Colors.white : const Color(0xFF334155),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSel ? const Color(0xFF0066FF) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Sort Order
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Default',
                        'Highest Budget',
                        'Highest Spent',
                        'Utilization %',
                      ].map((sort) {
                        final isSel = tempSort == sort;
                        return ChoiceChip(
                          label: Text(sort),
                          selected: isSel,
                          onSelected: (selected) {
                            setSheetState(() {
                              tempSort = selected ? sort : 'Default';
                            });
                          },
                          selectedColor: const Color(0xFF0A2540),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            color: isSel ? Colors.white : const Color(0xFF334155),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSel ? const Color(0xFF0A2540) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Apply Button
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
                          setState(() {
                            _selectedStatusFilter = tempStatus;
                            _selectedCategoryFilter = tempCategory;
                            _selectedSortBy = tempSort;
                          });
                          Navigator.pop(ctx);
                        },
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

  Widget _buildFilterBadge(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: Color(0xFF1E40AF)),
          ),
        ],
      ),
    );
  }

  void _showCreateBudgetSheet(BuildContext context, {BudgetItem? existingBudget}) {
    final nameCtrl = TextEditingController(text: existingBudget?.name ?? '');
    final amountCtrl = TextEditingController(
      text: existingBudget != null ? existingBudget.amount.toStringAsFixed(0) : '',
    );
    String selectedType = existingBudget?.type ?? 'Category-wise Budget';
    String selectedCategory = existingBudget?.category ?? 'Food & Dining';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
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
                    Text(
                      existingBudget != null ? 'Edit Budget' : 'Create Budget Limit',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Budget Name',
                        hintText: 'e.g. Monthly Dining Out',
                        prefixIcon: const Icon(Icons.pie_chart_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Budget Type',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Monthly Budget', 'Category-wise Budget'].map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (val) => setSheetState(() => selectedType = val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Target Category',
                        prefixIcon: const Icon(Icons.folder_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _categoryOptions.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) => setSheetState(() => selectedCategory = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Monthly Limit Amount (₹)',
                        prefixIcon: const Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final parsedAmount = double.tryParse(amountCtrl.text) ?? 0.0;
                          if (parsedAmount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid budget amount > 0')),
                            );
                            return;
                          }

                          final budgetName = nameCtrl.text.trim().isEmpty
                              ? selectedCategory
                              : nameCtrl.text.trim();

                          if (existingBudget != null) {
                            ref.read(budgetProvider.notifier).updateBudget(
                              existingBudget.copyWith(
                                name: budgetName,
                                type: selectedType,
                                category: selectedCategory,
                                amount: parsedAmount,
                              ),
                            );
                          } else {
                            final newBudget = BudgetItem(
                              id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
                              name: budgetName,
                              type: selectedType,
                              category: selectedCategory,
                              amount: parsedAmount,
                              spent: 0.0,
                              startDate: '01/10/2026',
                              endDate: '31/10/2026',
                              period: 'October 2026',
                            );
                            ref.read(budgetProvider.notifier).addBudget(newBudget);
                          }

                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                existingBudget != null
                                    ? 'Budget updated successfully!'
                                    : 'Budget limit created successfully!',
                              ),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                        child: Text(
                          existingBudget != null ? 'Save Changes' : 'Create Budget',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteBudgetDialog(BuildContext context, BudgetItem budget) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Budget Limit?'),
        content: Text(
          'Are you sure you want to remove the "${budget.name}" budget of ${_formatRupees(budget.amount)}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              ref.read(budgetProvider.notifier).deleteBudget(budget.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Budget "${budget.name}" removed'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseToBudgetSheet(BuildContext context, BudgetItem budget) {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
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
              Text(
                'Record Expense for ${budget.category}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2540),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Remaining Budget: ${_formatRupees(budget.remaining)} of ${_formatRupees(budget.amount)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: 'Description / Merchant',
                  hintText: 'e.g. Swiggy Lunch',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                    if (amt <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an amount > 0')),
                      );
                      return;
                    }

                    final desc = descCtrl.text.trim().isEmpty ? budget.category : descCtrl.text.trim();

                    // Apply directly to budget provider and expense provider
                    final alert = ref.read(budgetProvider.notifier).applyExpense(
                      category: budget.category,
                      amount: amt,
                      description: desc,
                    );

                    final newExpense = ExpenseEntry(
                      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
                      description: desc,
                      category: budget.category,
                      amount: amt,
                      priority: 'Medium',
                      date: 'Today',
                      bankAccount: 'HDFC Bank ••••4587',
                      merchant: desc,
                    );
                    ref.read(expenseProvider.notifier).addExpense(newExpense);

                    Navigator.pop(sheetCtx);

                    if (alert != null && alert.level == BudgetAlertLevel.exceeded) {
                      _showExceededAlert(context, alert.budget);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('₹${amt.toStringAsFixed(0)} recorded in ${budget.category}'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Record Expense',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showExceededAlert(BuildContext context, BudgetItem budget) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 8),
            Text(
              'Budget Exceeded Alert',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Exceeded! You have spent ${_formatRupees(budget.spent)} on ${budget.category} against your monthly budget of ${_formatRupees(budget.amount)}.',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540)),
            ),
            const SizedBox(height: 8),
            Text(
              'You exceeded your budget by ${_formatRupees(budget.overspentAmount)} (${budget.utilizationPercentage.toStringAsFixed(1)}% utilized).',
              style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Consider reducing spending or adjusting your budget limit to keep your personal CFO runway intact.',
                style: TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/expense-tracking');
            },
            child: const Text('View Expenses', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetProvider);
    final detectionState = ref.watch(transactionDetectionProvider);

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
                    'Budget Management',
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
          // Pending Detected Transactions Badge Icon
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.mark_chat_unread_outlined, color: Color(0xFF0066FF)),
                tooltip: 'Detected SMS Transactions',
                onPressed: () => PendingTransactionsSheet.show(context),
              ),
              if (detectionState.pendingCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${detectionState.pendingCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.flash_on, color: Color(0xFF0066FF)),
            tooltip: 'Simulate Bank SMS',
            onPressed: () => SmsSimulatorDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0066FF)),
            tooltip: 'Create Budget',
            onPressed: () => _showCreateBudgetSheet(context),
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
                Tab(text: 'Budget Categories'),
                Tab(text: 'Analytics & Alerts'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoriesTab(state),
          _buildAnalyticsTab(state),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(BudgetState state) {
    final exceededList = state.exceededBudgets;
    final warningList = state.warningBudgets;

    final filteredBudgets = state.budgets.where((b) {
      final matchesSearch = _searchQuery.isEmpty ||
          b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategoryFilter == 'All' ||
          b.category.toLowerCase() == _selectedCategoryFilter.toLowerCase();

      bool matchesStatus = true;
      if (_selectedStatusFilter == 'On Track') {
        matchesStatus = !b.isExceeded && !b.isApproachingLimit;
      } else if (_selectedStatusFilter == '80% Warning') {
        matchesStatus = b.isApproachingLimit;
      } else if (_selectedStatusFilter == 'Exceeded') {
        matchesStatus = b.isExceeded;
      }

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    if (_selectedSortBy == 'Highest Budget') {
      filteredBudgets.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_selectedSortBy == 'Highest Spent') {
      filteredBudgets.sort((a, b) => b.spent.compareTo(a.spent));
    } else if (_selectedSortBy == 'Utilization %') {
      filteredBudgets.sort((a, b) => b.utilizationPercentage.compareTo(a.utilizationPercentage));
    }

    final hasActiveFilters = _selectedStatusFilter != 'All' ||
        _selectedCategoryFilter != 'All' ||
        _selectedSortBy != 'Default';
    final activeFilterCount = (_selectedStatusFilter != 'All' ? 1 : 0) +
        (_selectedCategoryFilter != 'All' ? 1 : 0) +
        (_selectedSortBy != 'Default' ? 1 : 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // In-App SMS Alert Banner if present
        const InAppTransactionAlertBanner(),

        // Outflow & Priority Overview Card (Matching Finomos Project Standard)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A2540), Color(0xFFD97706)],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Total Monthly Budget Allocation',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${state.budgets.length} Categories',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatRupees(state.totalBudget),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Spent',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatRupees(state.totalSpent),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: state.totalOverspent > 0
                            ? const Color(0xFFEF4444).withOpacity(0.3)
                            : Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.totalOverspent > 0 ? 'Overspent' : 'Remaining',
                            style: TextStyle(
                              color: state.totalOverspent > 0
                                  ? const Color(0xFFFECACA)
                                  : Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.totalOverspent > 0
                                ? _formatRupees(state.totalOverspent)
                                : _formatRupees(state.totalRemaining),
                            style: TextStyle(
                              color: state.totalOverspent > 0
                                  ? const Color(0xFFFCA5A5)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (state.overallUsagePercentage / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  color: state.totalOverspent > 0
                      ? const Color(0xFFEF4444)
                      : (state.overallUsagePercentage > 80
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFF10B981)),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.overallUsagePercentage.toStringAsFixed(1)}% total utilized',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  Text(
                    state.totalOverspent > 0 ? 'Over Budget' : 'Safe Runway',
                    style: TextStyle(
                      color: state.totalOverspent > 0
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFF6EE7B7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // AI Personal CFO Spending Coach Banner (Matching Project Standard)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology, color: Color(0xFFD97706), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.totalOverspent > 0
                      ? 'AI Personal CFO: High alert! Spending has breached your allocated ceiling by ${_formatRupees(state.totalOverspent)}. Reduce discretionary expenses immediately.'
                      : 'AI Personal CFO: ${state.budgets.length} category budgets active. Overall utilization is ${_formatRupees(state.totalSpent)} (${state.overallUsagePercentage.toStringAsFixed(1)}%). Remaining runway is healthy.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Prominent Red Alert Banner if any budget exceeded
        if (exceededList.isNotEmpty) ...[
          for (final exceeded in exceededList)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Budget Exceeded!',
                          style: TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Exceeded by ${_formatRupees(exceeded.overspentAmount)} on ${exceeded.category} (${exceeded.utilizationPercentage.toStringAsFixed(0)}% used)',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFFB91C1C)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _showExceededAlert(context, exceeded),
                    child: const Text('Review', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
            ),
        ] else if (warningList.isNotEmpty) ...[
          for (final warn in warningList)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Warning: ${warn.utilizationPercentage.toStringAsFixed(0)}% of your ${warn.category} budget used (${_formatRupees(warn.spent)} / ${_formatRupees(warn.amount)}).',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],

        // Search Box and Filter Button Row
        Row(
          children: [
            Expanded(
              child: Container(
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
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search budgets by name or category...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showFilterSheet(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: hasActiveFilters ? const Color(0xFF0066FF) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasActiveFilters ? const Color(0xFF0066FF) : const Color(0xFFCBD5E1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: hasActiveFilters
                          ? const Color(0xFF0066FF).withOpacity(0.2)
                          : Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: hasActiveFilters ? Colors.white : const Color(0xFF0066FF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: hasActiveFilters ? Colors.white : const Color(0xFF0A2540),
                      ),
                    ),
                    if (activeFilterCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$activeFilterCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // Active Filter Banner with Dismiss Badges
        if (hasActiveFilters) ...[
          const SizedBox(height: 10),
          Container(
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
                      const Icon(Icons.filter_alt, size: 16, color: Color(0xFF0066FF)),
                      Text(
                        '${filteredBudgets.length} of ${state.budgets.length} shown',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      if (_selectedStatusFilter != 'All')
                        _buildFilterBadge('Status: $_selectedStatusFilter', () {
                          setState(() => _selectedStatusFilter = 'All');
                        }),
                      if (_selectedCategoryFilter != 'All')
                        _buildFilterBadge('Category: $_selectedCategoryFilter', () {
                          setState(() => _selectedCategoryFilter = 'All');
                        }),
                      if (_selectedSortBy != 'Default')
                        _buildFilterBadge('Sort: $_selectedSortBy', () {
                          setState(() => _selectedSortBy = 'Default');
                        }),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedStatusFilter = 'All';
                      _selectedCategoryFilter = 'All';
                      _selectedSortBy = 'Default';
                    });
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
        ],
        const SizedBox(height: 14),

        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Flexible(
                    child: Text(
                      'Budget Categories',
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${filteredBudgets.length} active',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showCreateBudgetSheet(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Add Budget',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Budget Items List
        if (filteredBudgets.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(Icons.pie_chart_outline, size: 44, color: Color(0xFF94A3B8)),
                const SizedBox(height: 10),
                const Text(
                  'No matching budgets found',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Try adjusting your search or filters, or create a new budget limit.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => _showCreateBudgetSheet(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create Budget'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
                ),
              ],
            ),
          )
        else
          for (final b in filteredBudgets) ...[
            _buildBudgetCard(b),
            const SizedBox(height: 12),
          ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBudgetCard(BudgetItem b) {
    final isExceeded = b.isExceeded;
    final isWarn = b.isApproachingLimit;
    final catColor = _getCategoryColor(b.category);
    final catIcon = _getCategoryIcon(b.category);

    final progressColor = isExceeded
        ? const Color(0xFFEF4444)
        : (isWarn ? const Color(0xFFF59E0B) : catColor);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExceeded
              ? const Color(0xFFFCA5A5)
              : (isWarn ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
          width: isExceeded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(catIcon, color: catColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            b.name,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isExceeded)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'EXCEEDED',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          )
                        else if (isWarn)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '80% REACHED',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ON TRACK',
                              style: TextStyle(
                                color: Color(0xFF047857),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b.category,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (b.utilizationPercentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              color: progressColor,
            ),
          ),
          const SizedBox(height: 8),

          // Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${_formatRupees(b.spent)} of ${_formatRupees(b.amount)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0A2540)),
              ),
              Text(
                '${b.utilizationPercentage.toStringAsFixed(1)}% utilized',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isExceeded
                      ? const Color(0xFFEF4444)
                      : (isWarn ? const Color(0xFFD97706) : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Status & Remaining/Overspent line
          Text(
            isExceeded
                ? 'Overspent by ${_formatRupees(b.overspentAmount)}'
                : 'Remaining: ${_formatRupees(b.remaining)} balance',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isExceeded ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            ),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _showAddExpenseToBudgetSheet(context, b),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: const [
                      Icon(Icons.add_circle, size: 14, color: Color(0xFF0066FF)),
                      SizedBox(width: 4),
                      Text(
                        'Record Expense',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => _showCreateBudgetSheet(context, existingBudget: b),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Edit',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF0066FF), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showDeleteBudgetDialog(context, b),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Delete',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BudgetState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Metrics Cards Grid
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Total Budgets',
                value: '${state.budgets.length}',
                subtitle: 'Active Categories',
                icon: Icons.pie_chart,
                color: const Color(0xFF0066FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Overspent',
                value: '${state.exceededBudgets.length}',
                subtitle: 'Exceeded Limits',
                icon: Icons.error_outline,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: '80% Warnings',
                value: '${state.warningBudgets.length}',
                subtitle: 'Nearing Cap',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Overall Usage',
                value: '${state.overallUsagePercentage.toStringAsFixed(0)}%',
                subtitle: 'Of Total Monthly',
                icon: Icons.speed,
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Category Breakdown Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category Budget Utilization',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Live comparison of spent amounts against allocated limits',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              for (final b in state.budgets) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(_getCategoryIcon(b.category), size: 16, color: _getCategoryColor(b.category)),
                        const SizedBox(width: 6),
                        Text(
                          b.category,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                        ),
                      ],
                    ),
                    Text(
                      '${_formatRupees(b.spent)} / ${_formatRupees(b.amount)} (${b.utilizationPercentage.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: b.isExceeded
                            ? const Color(0xFFEF4444)
                            : (b.isApproachingLimit ? const Color(0xFFF59E0B) : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (b.utilizationPercentage / 100).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: b.isExceeded
                        ? const Color(0xFFEF4444)
                        : (b.isApproachingLimit ? const Color(0xFFF59E0B) : _getCategoryColor(b.category)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Automated Bank SMS Rules & Thresholds
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Smart Guardrail Automation',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bank SMS Expense Deduction', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Automatically deduct confirmed bank SMS debits from category budgets', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                value: true,
                activeColor: const Color(0xFF0066FF),
                onChanged: (val) {},
              ),
              const Divider(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Prominent Overspending Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Display high-visibility red warning banners when a category crosses 100%', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                value: state.alertEnabled,
                activeColor: const Color(0xFFEF4444),
                onChanged: (val) => ref.read(budgetProvider.notifier).toggleAlert(val),
              ),
              const Divider(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('80% Threshold Early Warning', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Notify when expenses reach 80% of monthly allocation', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                value: true,
                activeColor: const Color(0xFFF59E0B),
                onChanged: (val) {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
