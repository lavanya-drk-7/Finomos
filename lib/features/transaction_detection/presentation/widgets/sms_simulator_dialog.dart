import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/transaction_detection_provider.dart';

class SmsSimulatorDialog extends ConsumerStatefulWidget {
  const SmsSimulatorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SmsSimulatorDialog(),
    );
  }

  @override
  ConsumerState<SmsSimulatorDialog> createState() => _SmsSimulatorDialogState();
}

class _SmsSimulatorDialogState extends ConsumerState<SmsSimulatorDialog> {
  final TextEditingController _customSmsController = TextEditingController(
    text: 'Rs. 1,000 debited from your HDFC Bank account ••••4587 to VPA restaurant@upi. Ref 429182391024',
  );
  final TextEditingController _senderController = TextEditingController(text: 'VK-HDFCBK');
  String? _statusMessage;
  bool _isError = false;

  @override
  void dispose() {
    _customSmsController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  void _runPreset(String presetKey) {
    final result = ref.read(transactionDetectionProvider.notifier).simulatePreset(presetKey);
    setState(() {
      if (result.isSuccess) {
        _statusMessage = 'Transaction detected & parsed successfully!';
        _isError = false;
      } else {
        _statusMessage = result.errorMessage ?? 'Detection failed';
        _isError = true;
      }
    });

    if (result.isSuccess && result.transaction != null) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          Navigator.pop(context);
          context.push('/transaction-review', extra: result.transaction);
        }
      });
    }
  }

  void _parseCustomSms() {
    final text = _customSmsController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter or paste an SMS message';
        _isError = true;
      });
      return;
    }

    final result = ref.read(transactionDetectionProvider.notifier).processIncomingSms(
          text,
          sender: _senderController.text.trim().isNotEmpty
              ? _senderController.text.trim()
              : 'BANK-SMS',
        );

    setState(() {
      if (result.isSuccess) {
        _statusMessage = 'SMS parsed successfully! Opening Review screen...';
        _isError = false;
      } else {
        _statusMessage = result.errorMessage ?? 'Could not parse transaction from SMS';
        _isError = true;
      }
    });

    if (result.isSuccess && result.transaction != null) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          Navigator.pop(context);
          context.push('/transaction-review', extra: result.transaction);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),

            // Title & Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.mark_chat_unread_outlined, color: Color(0xFF0066FF), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bank SMS Ingestion & Detection',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                      ),
                      Text(
                        'Test bank messages or paste an SMS from clipboard',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Privacy & Policy Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Privacy Assured: Finomos parses bank transaction amounts locally on your device. We NEVER read or store OTPs, personal passwords, or unrelated personal messages.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Test Preset Buttons
            const Text(
              'QUICK TEST SCENARIOS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildScenarioChip(
                  label: '₹1,000 Food & Dining (HDFC)',
                  color: const Color(0xFF0066FF),
                  onTap: () => _runPreset('hdfc_1000_food'),
                ),
                _buildScenarioChip(
                  label: '₹30,000 Salary Credit (SBI)',
                  color: const Color(0xFF10B981),
                  onTap: () => _runPreset('sbi_30000_salary'),
                ),
                _buildScenarioChip(
                  label: '₹2,000 Groceries (Axis)',
                  color: const Color(0xFFF59E0B),
                  onTap: () => _runPreset('axis_2000_groceries'),
                ),
                _buildScenarioChip(
                  label: '₹11,000 Overspending Debit',
                  color: const Color(0xFFEF4444),
                  onTap: () => _runPreset('hdfc_11000_overspent'),
                ),
                _buildScenarioChip(
                  label: '₹5,000 Self Transfer',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _runPreset('transfer_5000'),
                ),
                _buildScenarioChip(
                  label: '₹1,500 Refund Credit',
                  color: const Color(0xFF0284C7),
                  onTap: () => _runPreset('refund_1500'),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Custom SMS Input
            const Text(
              'OR PASTE / TYPE BANK SMS MESSAGE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customSmsController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Rs. 1,000 debited from your HDFC Bank account.',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0066FF), width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),

            if (_statusMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isError ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _isError ? const Color(0xFFFCA5A5) : const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    Icon(_isError ? Icons.error_outline : Icons.check_circle_outline,
                        size: 16, color: _isError ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isError ? const Color(0xFF991B1B) : const Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _parseCustomSms,
                icon: const Icon(Icons.flash_on, size: 18, color: Colors.white),
                label: const Text(
                  'Parse & Detect Transaction',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioChip({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_outline, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
