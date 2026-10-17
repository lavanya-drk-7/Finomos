import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<Map<String, String>> _allFaqs = [
    {
      'category': 'Bank Aggregation',
      'question': 'How does bank account aggregation work in FINOMOS?',
      'answer': 'FINOMOS connects to financial institutions via RBI-regulated Account Aggregators. No bank passwords or passwords are required. You retain full control over consent.',
    },
    {
      'category': 'Account & Security',
      'question': 'Is my financial data safe and encrypted?',
      'answer': 'Yes. All data transmitted and stored is encrypted using 256-bit AES encryption with zero-knowledge architecture. We do not store credential data.',
    },
    {
      'category': 'AI CFO & Analytics',
      'question': 'How often does the AI CFO update financial insights?',
      'answer': 'AI CFO updates insights in real-time as new transactions and data sync from your connected accounts or manual entries.',
    },
    {
      'category': 'KYC & Verification',
      'question': 'Why is KYC required and how long does it take?',
      'answer': 'KYC is required by Indian financial regulations to unlock full investment and wealth tools. Verification usually takes less than 2 minutes.',
    },
    {
      'category': 'Budgeting & Expense',
      'question': 'Can I edit or reset my monthly budget limits?',
      'answer': 'Yes, you can edit budget limits anytime from the Budget Management section by selecting the category and updating the limit.',
    },
  ];

  final List<Map<String, String>> _tickets = [
    {
      'id': 'TICK-8842',
      'subject': 'Bank statement auto-sync delay',
      'date': 'Yesterday, 4:30 PM',
      'status': 'In Progress',
    },
    {
      'id': 'TICK-7201',
      'subject': 'KYC Document resubmission assistance',
      'date': '02 Oct 2026',
      'status': 'Resolved',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRaiseTicketSheet() {
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Bank Aggregation';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
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
                    const Text('Raise Support Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Issue Category', prefixIcon: Icon(Icons.category_outlined)),
                      items: ['Bank Aggregation', 'KYC & Profile', 'AI CFO Insights', 'Payments & Subscriptions', 'Other'].map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) => setSheetState(() => category = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectCtrl,
                      decoration: const InputDecoration(labelText: 'Subject / Summary', prefixIcon: Icon(Icons.title)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Detailed Description of Issue', alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Screenshot/file attached successfully.')),
                        );
                      },
                      icon: const Icon(Icons.attach_file, size: 16),
                      label: const Text('Attach Screenshot or Log (Optional)'),
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
                          if (subjectCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter subject and description.')),
                            );
                            return;
                          }

                          setState(() {
                            _tickets.insert(0, {
                              'id': 'TICK-${1000 + _tickets.length * 451}',
                              'subject': subjectCtrl.text.trim(),
                              'date': 'Just now',
                              'status': 'Open',
                            });
                          });

                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Support Ticket submitted! Our team will respond within 2 hours.'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                        child: const Text('Submit Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showLiveChatDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
              child: const Icon(Icons.support_agent, color: Color(0xFF10B981)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FINOMOS Live Assistant', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                Text('Online • Instant Help', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'Hello! How can I assist you with your FINOMOS account, bank connections, or financial tools today?',
                style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type your message...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF0066FF)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Support agent notified. Joining live chat session...')),
                    );
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final search = _searchController.text.toLowerCase();
    final filteredFaqs = _allFaqs.where((f) {
      final matchesCat = _selectedCategory == 'All' || f['category'] == _selectedCategory;
      final matchesQuery = f['question']!.toLowerCase().contains(search) || f['answer']!.toLowerCase().contains(search);
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0066FF)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: const FinmosLogo(size: 26, showTagline: false, isHorizontal: true),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent, color: Color(0xFF0066FF)),
            onPressed: _showLiveChatDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Header
              const Text('Help & Support Center', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
              const Text('We are here to help you get the most out of FINOMOS.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 16),

              // Quick Action Cards Banner
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _showLiveChatDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Column(
                          children: [
                            CircleAvatar(radius: 18, backgroundColor: Color(0xFF0066FF), child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18)),
                            SizedBox(height: 8),
                            Text('Live Chat Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0A2540))),
                            SizedBox(height: 2),
                            Text('Instant AI response', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _showRaiseTicketSheet,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Column(
                          children: [
                            CircleAvatar(radius: 18, backgroundColor: Color(0xFF10B981), child: Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 18)),
                            SizedBox(height: 8),
                            Text('Raise Support Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0A2540))),
                            SizedBox(height: 2),
                            Text('2 hour resolution', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search FAQs Box
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search help articles, FAQs, guides...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),

              // Filter category chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Bank Aggregation', 'Account & Security', 'AI CFO & Analytics', 'KYC & Verification'].map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(cat, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : const Color(0xFF475569))),
                        selected: isSel,
                        selectedColor: const Color(0xFF0066FF),
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Frequently Asked Questions Section Card
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
                    const Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 12),
                    filteredFaqs.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: Text('No FAQs matching search query.', style: TextStyle(color: Color(0xFF64748B)))),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredFaqs.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (ctx, idx) {
                              final faq = filteredFaqs[idx];
                              return ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                leading: const Icon(Icons.help_outline, color: Color(0xFF0066FF), size: 20),
                                title: Text(faq['question']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                                subtitle: Text(faq['category']!, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12, left: 32, right: 12),
                                    child: Text(faq['answer']!, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4)),
                                  ),
                                ],
                              );
                            },
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Support Tickets Section Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Support Tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                        TextButton.icon(
                          onPressed: _showRaiseTicketSheet,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('New Ticket', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tickets.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (ctx, idx) {
                        final tick = _tickets[idx];
                        final isResolved = tick['status'] == 'Resolved';
                        final isProgress = tick['status'] == 'In Progress';
                        final statusColor = isResolved
                            ? const Color(0xFF10B981)
                            : isProgress
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF0066FF);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: statusColor.withOpacity(0.15),
                                child: Text(tick['id']!.substring(5), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tick['subject']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                                    Text('${tick['id']} • ${tick['date']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                child: Text(tick['status']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                              ),
                            ],
                          ),
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
      ),
    );
  }
}
