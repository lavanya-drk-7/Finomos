import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../domain/budget_models.dart';
import '../providers/budget_provider.dart';

class BudgetManagementScreen extends ConsumerStatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  ConsumerState<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends ConsumerState<BudgetManagementScreen> {
  void _showCreateBudgetSheet(BuildContext context, {BudgetItem? existingBudget}) {
    final nameCtrl = TextEditingController(text: existingBudget?.name ?? '');
    final amountCtrl = TextEditingController(text: existingBudget != null ? existingBudget.amount.toStringAsFixed(0) : '');
    String selectedType = existingBudget?.type ?? 'Category-wise Budget';
    String selectedCategory = existingBudget?.category ?? 'Food & Dining';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                        decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      existingBudget != null ? 'Edit Budget' : 'Create Budget',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Budget Name', prefixIcon: Icon(Icons.pie_chart_outline)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Budget Type', prefixIcon: Icon(Icons.category)),
                      items: ['Monthly Budget', 'Category-wise Budget'].map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (val) => setSheetState(() => selectedType = val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.folder_outlined)),
                      items: ['Food & Dining', 'Travel', 'Shopping', 'Entertainment', 'Bills & Utilities'].map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) => setSheetState(() => selectedCategory = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Budget Amount (₹)', prefixIcon: Icon(Icons.currency_rupee)),
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
                          final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                          if (amount <= 0 || nameCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter valid name and amount')),
                            );
                            return;
                          }

                          if (existingBudget != null) {
                            final updated = existingBudget.copyWith(
                              name: nameCtrl.text.trim(),
                              type: selectedType,
                              category: selectedCategory,
                              amount: amount,
                            );
                            ref.read(budgetProvider.notifier).updateBudget(updated);
                          } else {
                            final newB = BudgetItem(
                              id: 'b_${DateTime.now().millisecondsSinceEpoch}',
                              name: nameCtrl.text.trim(),
                              type: selectedType,
                              category: selectedCategory,
                              amount: amount,
                              spent: 0.0,
                              startDate: '01/09/2026',
                              endDate: '30/09/2026',
                            );
                            ref.read(budgetProvider.notifier).addBudget(newB);
                          }

                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(existingBudget != null ? 'Budget updated!' : 'Budget created successfully!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                        child: const Text('Save Budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showExceededAlert(BuildContext context, BudgetItem budget) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 8),
            Text('Budget Exceeded Alert', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have exceeded your ${budget.category} budget!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Text('Spent: ₹ ${budget.spent.toStringAsFixed(0)} of ₹ ${budget.amount.toStringAsFixed(0)} (${budget.progressPercentage.toStringAsFixed(1)}%)'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'Consider reducing your spending or adjusting your budget limit.',
                style: TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('View Budget', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0066FF)),
          onPressed: () {
            context.go('/profile');
          },
        ),
        title: const FinmosLogo(size: 26, showTagline: false, isHorizontal: true),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0066FF)),
            onPressed: () => _showCreateBudgetSheet(context),
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
              // Header Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Budget Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                        Text('Create spending limits and monitor your budget.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateBudgetSheet(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create Budget', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hero Overall Progress Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: (state.overallUsagePercentage / 100).clamp(0.0, 1.0),
                            strokeWidth: 10,
                            backgroundColor: const Color(0xFFE2E8F0),
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          '${state.overallUsagePercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A2540)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Budget Usage', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text('Spent ₹ ${state.totalSpent.toStringAsFixed(0)} of ₹ ${state.totalBudget.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                          const SizedBox(height: 4),
                          Text('Remaining: ₹ ${state.totalRemaining.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Category-wise Budgets List
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category-wise Budgets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 14),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.budgets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (ctx, idx) {
                        final b = state.budgets[idx];
                        final isWarn = b.progressPercentage > 80;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540)))),
                                const SizedBox(width: 8),
                                Text('₹ ${b.spent.toStringAsFixed(0)} / ₹ ${b.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: (b.progressPercentage / 100).clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: const Color(0xFFF1F5F9),
                                color: isWarn ? const Color(0xFFEF4444) : const Color(0xFF0066FF),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${b.progressPercentage.toStringAsFixed(1)}% used', style: TextStyle(fontSize: 10, color: isWarn ? const Color(0xFFEF4444) : const Color(0xFF64748B))),
                                Row(
                                  children: [
                                    if (isWarn)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: InkWell(
                                          onTap: () => _showExceededAlert(context, b),
                                          child: const Text('Alert', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    InkWell(
                                      onTap: () => _showCreateBudgetSheet(context, existingBudget: b),
                                      child: const Text('Edit', style: TextStyle(fontSize: 11, color: Color(0xFF0066FF), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
