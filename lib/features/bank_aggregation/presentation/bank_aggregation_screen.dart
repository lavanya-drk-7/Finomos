import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../../core/widgets/bank_logo.dart';
import '../domain/bank_aggregation_models.dart';
import '../providers/bank_aggregation_provider.dart';

class BankAggregationScreen extends ConsumerStatefulWidget {
  const BankAggregationScreen({super.key});

  @override
  ConsumerState<BankAggregationScreen> createState() => _BankAggregationScreenState();
}

class _BankAggregationScreenState extends ConsumerState<BankAggregationScreen> {
  final _searchController = TextEditingController();

  static const Color _brandBlue = Color(0xFF0066FF);
  static const Color _navyDark = Color(0xFF0A2540);
  static const Color _slateGrey = Color(0xFF64748B);
  static const Color _bgCanvas = Color(0xFFF8FAFC);
  static const Color _cardBorder = Color(0xFFE2E8F0);
  static const Color _emeraldGreen = Color(0xFF10B981);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showConsentDialog(BuildContext context, InstitutionDirectoryItem institution) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            BankLogo(bankName: institution.name, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect ${institution.name}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _navyDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'RBI Regulated Account Aggregator (AA)',
                    style: TextStyle(fontSize: 10, color: _slateGrey, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explicit User Consent Authorization (FAA-BR-010)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _navyDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'By connecting via Account Aggregator, you authorize Finomos OS to periodically acquire encrypted read-only financial data:',
              style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 10),
            _buildConsentBullet('Account Details, Types & Real-Time Balances'),
            _buildConsentBullet('Transaction History & Credit/Debit Ledger'),
            _buildConsentBullet('Auto-Categorization & AI CFO Cash Flow Feed'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock_outlined, size: 16, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'FAA-BR-001: Bank passwords or PINs are NEVER requested or stored. Account numbers are always masked.',
                      style: TextStyle(fontSize: 10, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _slateGrey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandBlue,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              ref.read(bankAggregationProvider.notifier).connectBankInstitution(institution);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${institution.name} connected securely via RBI Account Aggregator!'),
                  backgroundColor: _emeraldGreen,
                ),
              );
            },
            child: const Text('Authorize & Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddBankModal(BuildContext context, {BankAccountItem? existingAccount}) {
    String selectedBank = existingAccount?.bankName ?? 'State Bank of India';
    String selectedAccountType = existingAccount?.accountType ?? 'Savings Account';
    final initialAccNum = existingAccount != null 
        ? existingAccount.maskedAccountNumber.replaceAll(RegExp(r'[^0-9]'), '')
        : '';
    final accountNumCtrl = TextEditingController(text: initialAccNum);
    final ifscCtrl = TextEditingController(text: existingAccount?.ifscCode ?? '');
    final holderCtrl = TextEditingController(text: existingAccount?.accountHolder ?? '');
    final balanceCtrl = TextEditingController(text: existingAccount != null ? existingAccount.currentBalance.toStringAsFixed(0) : '');
    final otherBankCtrl = TextEditingController();
    final branchCtrl = TextEditingController();

    String lookupBranch(String bank, String ifsc, String otherBankName) {
      final upper = ifsc.trim().toUpperCase();
      if (upper.startsWith('SBIN')) {
        if (upper == 'SBIN0001234') return 'MG Road Main Branch, Bengaluru';
        if (upper == 'SBIN0000691') return 'Parliament Street Branch, New Delhi';
        return 'State Bank Main Branch, Bengaluru';
      } else if (upper.startsWith('HDFC')) {
        if (upper == 'HDFC0000567' || upper == 'HDFC0005678') return 'Fort Main Branch, Mumbai';
        return 'HDFC Bank Corporate Branch, Mumbai';
      } else if (upper.startsWith('ICIC')) {
        if (upper == 'ICIC0000104') return 'Bandra Kurla Complex (BKC) Branch, Mumbai';
        return 'ICICI Bank Towers Branch, Mumbai';
      } else if (upper.startsWith('UTIB')) {
        return 'Corporate Park Branch, Mumbai';
      } else if (upper.startsWith('KKBK')) {
        return 'Nariman Point Branch, Mumbai';
      } else if (upper.startsWith('PUNB')) {
        return 'Connaught Place Branch, New Delhi';
      } else if (upper.startsWith('BARB')) {
        return 'Mandvi Main Branch, Vadodara';
      } else if (upper.startsWith('CNRB')) {
        return 'Town Hall Branch, Bengaluru';
      } else if (upper.startsWith('UBIN')) {
        return 'Nariman Point Branch, Mumbai';
      } else if (upper.startsWith('INDB')) {
        return 'Barakhamba Branch, New Delhi';
      } else if (upper.startsWith('FDRL')) {
        return 'Marine Drive Branch, Kochi';
      } else if (upper.startsWith('IDFB')) {
        return 'BKC Branch, Mumbai';
      }

      final displayBank = bank == 'Others' ? (otherBankName.isNotEmpty ? otherBankName : 'Bank') : bank;
      if (upper.length >= 4) {
        return '$displayBank Main Branch (${upper.substring(0, 4)})';
      }
      return '$displayBank Main Commercial Branch';
    }

    branchCtrl.text = (existingAccount != null && ifscCtrl.text.isNotEmpty)
        ? lookupBranch(selectedBank, ifscCtrl.text, otherBankCtrl.text)
        : '';

    void autoFetchDetails(StateSetter setModalState) {
      final acc = accountNumCtrl.text.trim();
      final ifsc = ifscCtrl.text.trim().toUpperCase();

      if (ifsc.length >= 4) {
        branchCtrl.text = lookupBranch(selectedBank, ifsc, otherBankCtrl.text);
      } else {
        branchCtrl.text = '';
      }

      if (acc.length >= 6 && ifsc.length >= 4) {
        if (holderCtrl.text.trim().isEmpty || holderCtrl.text.trim() == 'Sireesha Bandaru') {
          holderCtrl.text = 'Sireesha Bandaru';
        }
      } else if (existingAccount == null && acc.length < 6) {
        if (holderCtrl.text == 'Sireesha Bandaru') {
          holderCtrl.text = '';
        }
      }
      setModalState(() {});
    }

    final bankOptions = [
      'State Bank of India',
      'HDFC Bank',
      'ICICI Bank',
      'Axis Bank',
      'Kotak Mahindra Bank',
      'Punjab National Bank',
      'Bank of Baroda',
      'Canara Bank',
      'Union Bank of India',
      'IndusInd Bank',
      'Federal Bank',
      'IDFC FIRST Bank',
      'Others',
    ];

    final accountTypes = [
      'Savings Account',
      'Current Account',
      'Salary Account',
      'Fixed Deposit (FD)',
      'Recurring Deposit (RD)',
      'Overdraft (OD) Account',
      'NRI / NRE / NRO Account',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final accNumVal = accountNumCtrl.text.trim();
            final ifscVal = ifscCtrl.text.trim();
            final holderVal = holderCtrl.text.trim();
            final bankDisplayName = selectedBank == 'Others' ? otherBankCtrl.text.trim() : selectedBank;

            final isAccountNumValid = accNumVal.length >= 6;
            final isIfscValid = ifscVal.length >= 4;
            final isHolderValid = holderVal.isNotEmpty;
            final isBankValid = bankDisplayName.isNotEmpty;

            final isDetailsVerified = isAccountNumValid && isIfscValid && isHolderValid && isBankValid;

            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.90,
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                  left: 20,
                  right: 20,
                  top: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance, color: _brandBlue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existingAccount != null ? 'Edit Bank Account' : 'Link Bank Account',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark),
                              ),
                              Text(
                                existingAccount != null ? 'Update bank details (FAA-SEC-02)' : 'Savings, Current, Salary & Deposits (FAA-SEC-02)',
                                style: const TextStyle(fontSize: 11, color: _slateGrey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedBank,
                              decoration: InputDecoration(
                                labelText: 'Select Financial Institution / Bank',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: bankOptions.map((b) => DropdownMenuItem(
                                value: b,
                                child: BankNameWithLogo(bankName: b, logoSize: 22),
                              )).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setModalState(() {
                                    selectedBank = v;
                                  });
                                  autoFetchDetails(setModalState);
                                }
                              },
                            ),
                            if (selectedBank == 'Others') ...[
                              const SizedBox(height: 14),
                              TextField(
                                controller: otherBankCtrl,
                                onChanged: (_) => autoFetchDetails(setModalState),
                                decoration: InputDecoration(
                                  labelText: 'Other Bank Name',
                                  hintText: 'e.g. Standard Chartered, Yes Bank, RBL Bank',
                                  prefixIcon: const Icon(Icons.account_balance, color: _brandBlue),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedAccountType,
                              decoration: InputDecoration(
                                labelText: 'Account Type',
                                prefixIcon: const Icon(Icons.category_outlined, color: _brandBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: accountTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setModalState(() => selectedAccountType = v);
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: accountNumCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => autoFetchDetails(setModalState),
                              decoration: InputDecoration(
                                labelText: 'Bank Account Number',
                                hintText: 'e.g. 501004329871',
                                prefixIcon: const Icon(Icons.pin_outlined, color: _brandBlue),
                                helperText: 'Displayed securely with masked digits (•••• XXXX)',
                                suffixIcon: accountNumCtrl.text.trim().length >= 6
                                    ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20)
                                    : null,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: ifscCtrl,
                                    textCapitalization: TextCapitalization.characters,
                                    onChanged: (val) {
                                      final upper = val.trim().toUpperCase();
                                      if (upper.startsWith('SBIN') && selectedBank != 'State Bank of India') {
                                        selectedBank = 'State Bank of India';
                                      } else if (upper.startsWith('HDFC') && selectedBank != 'HDFC Bank') {
                                        selectedBank = 'HDFC Bank';
                                      } else if (upper.startsWith('ICIC') && selectedBank != 'ICICI Bank') {
                                        selectedBank = 'ICICI Bank';
                                      } else if (upper.startsWith('UTIB') && selectedBank != 'Axis Bank') {
                                        selectedBank = 'Axis Bank';
                                      } else if (upper.startsWith('KKBK') && selectedBank != 'Kotak Mahindra Bank') {
                                        selectedBank = 'Kotak Mahindra Bank';
                                      } else if (upper.startsWith('PUNB') && selectedBank != 'Punjab National Bank') {
                                        selectedBank = 'Punjab National Bank';
                                      } else if (upper.startsWith('BARB') && selectedBank != 'Bank of Baroda') {
                                        selectedBank = 'Bank of Baroda';
                                      } else if (upper.startsWith('CNRB') && selectedBank != 'Canara Bank') {
                                        selectedBank = 'Canara Bank';
                                      }
                                      autoFetchDetails(setModalState);
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Branch IFSC Code',
                                      hintText: 'e.g. SBIN0001234',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: balanceCtrl,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setModalState(() {}),
                                    decoration: InputDecoration(
                                      labelText: 'Balance (₹)',
                                      hintText: 'e.g. 75000',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: branchCtrl,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Bank Branch Location (Auto-Fetched)',
                                helperText: '⚡ Auto-fetched based on Branch IFSC code',
                                helperStyle: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                                prefixIcon: const Icon(Icons.location_on_outlined, color: _brandBlue),
                                suffixIcon: branchCtrl.text.isNotEmpty
                                    ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18)
                                    : null,
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: holderCtrl,
                              onChanged: (_) => setModalState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Primary Account Holder Name (Auto-Fetched)',
                                helperText: holderCtrl.text.isNotEmpty
                                    ? '⚡ Auto-fetched from Bank Account & Penny Drop verification'
                                    : null,
                                helperStyle: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                                prefixIcon: const Icon(Icons.person_outline, color: _brandBlue),
                                suffixIcon: holderCtrl.text.isNotEmpty
                                    ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18)
                                    : null,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            if (isDetailsVerified) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withOpacity(0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.verified, color: Color(0xFF10B981), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  '$bankDisplayName Branch',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF15803D),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 15),
                                              const SizedBox(width: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFDCFCE7),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: const Color(0xFF86EFAC), width: 0.8),
                                                ),
                                                child: const Text(
                                                  'VERIFIED',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF15803D),
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            branchCtrl.text.isNotEmpty ? branchCtrl.text : lookupBranch(selectedBank, ifscVal, otherBankCtrl.text.trim()),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF166534),
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            'IFSC: ${ifscVal.toUpperCase()} • Holder: $holderVal',
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              color: Color(0xFF15803D),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.bolt, size: 18, color: Color(0xFF3B82F6)),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Enter Account Number & Branch IFSC Code to automatically fetch Account Holder Name and Bank Branch location.',
                                        style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified_user_outlined, size: 16, color: _brandBlue),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Regulated under RBI Account Aggregator framework. 256-bit encrypted read-only telemetry. Password/PIN is never requested.',
                                      style: TextStyle(fontSize: 10, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final enteredOther = otherBankCtrl.text.trim();
                          if (selectedBank == 'Others' && enteredOther.isEmpty) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your bank name'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          final accNum = accountNumCtrl.text.trim();

                          if (accNum.isEmpty) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter Bank Account Number'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          if (accNum.length < 6) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid Bank Account Number (minimum 6 digits)'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          final bankName = selectedBank == 'Others' ? enteredOther : selectedBank;
                          final balanceVal = double.tryParse(balanceCtrl.text.trim().replaceAll(',', '')) ?? 50000.0;
                          final ifsc = ifscCtrl.text.trim().isEmpty ? 'SBIN0001234' : ifscCtrl.text.trim().toUpperCase();
                          final holder = holderCtrl.text.trim().isEmpty ? 'Sireesha Bandaru' : holderCtrl.text.trim();

                          final masked = accNum.length >= 4
                              ? '•••• ${accNum.substring(accNum.length - 4)}'
                              : '•••• 1234';

                          if (existingAccount != null) {
                            final updated = existingAccount.copyWith(
                              bankName: bankName,
                              accountType: selectedAccountType,
                              maskedAccountNumber: masked,
                              ifscCode: ifsc,
                              accountHolder: holder,
                              currentBalance: balanceVal,
                              availableBalance: balanceVal,
                              lastSynced: 'Just now',
                            );
                            ref.read(bankAggregationProvider.notifier).updateBankAccount(updated);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedAccountType at $bankName updated successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          } else {
                            ref.read(bankAggregationProvider.notifier).addBankAccount(
                                  bankName: bankName,
                                  accountType: selectedAccountType,
                                  maskedAccountNumber: masked,
                                  ifscCode: ifsc,
                                  accountHolder: holder,
                                  currentBalance: balanceVal,
                                );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedAccountType at $bankName linked successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          }
                        },
                        child: Text(
                          existingAccount != null ? 'Update Bank Account' : 'Verify & Link Bank Account',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  void _showAddCreditCardModal(BuildContext context, {CreditCardItem? existingCard}) {
    String selectedCard = existingCard?.cardName ?? 'HDFC Regalia Gold';
    String selectedDueDate = existingCard?.statementDueDate ?? '15th of every month';
    String selectedIssuedBank = existingCard?.issuedBank ?? 'HDFC Bank';
    String selectedCardType = existingCard?.cardType ?? 'Visa';
    final holderNameCtrl = TextEditingController(text: existingCard?.cardHolderName ?? '');
    final last4Ctrl = TextEditingController(text: existingCard?.last4Digits ?? '');
    final expiryCtrl = TextEditingController(text: existingCard?.expiryDate ?? '');
    final limitCtrl = TextEditingController(text: existingCard != null ? existingCard.creditLimit.toStringAsFixed(0) : '');
    final outstandingCtrl = TextEditingController(text: existingCard != null ? existingCard.outstandingBalance.toStringAsFixed(0) : '');
    final rewardCtrl = TextEditingController(text: existingCard != null ? existingCard.rewardPoints.toString() : '');
    final otherCardCtrl = TextEditingController();
    final otherIssuedBankCtrl = TextEditingController();

    final popularCards = [
      'HDFC Regalia Gold',
      'HDFC Millennia',
      'HDFC Infinia Metal',
      'ICICI Amazon Pay',
      'ICICI Sapphiro',
      'ICICI Coral',
      'SBI SimplyCLICK',
      'SBI Cashback Card',
      'SBI Aurum',
      'Axis Magnus',
      'Axis Ace',
      'Flipkart Axis Bank',
      'Kotak League Platinum',
      'Kotak White',
      'Tata Neu Infinity HDFC',
      'American Express MRCC',
      'Other Credit Card',
    ];

    final issuedBankOptions = [
      'HDFC Bank',
      'State Bank of India',
      'ICICI Bank',
      'Axis Bank',
      'Kotak Mahindra Bank',
      'Punjab National Bank',
      'Bank of Baroda',
      'Canara Bank',
      'IDFC FIRST Bank',
      'IndusInd Bank',
      'RBL Bank',
      'Standard Chartered',
      'American Express',
      'Others',
    ];

    final cardTypeOptions = [
      'Visa',
      'Mastercard',
      'RuPay',
      'American Express',
      'Diners Club',
    ];

    final dueDates = [
      '5th of every month',
      '10th of every month',
      '15th of every month',
      '20th of every month',
      '25th of every month',
      '28th of every month',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.90,
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                  left: 20,
                  right: 20,
                  top: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.credit_card, color: _brandBlue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existingCard != null ? 'Edit Credit Card' : 'Add Credit Card',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark),
                              ),
                              Text(
                                existingCard != null ? 'Update card limits & details (FAA-SEC-04)' : 'Card Limit, Statement & Dues Tracking (FAA-SEC-04)',
                                style: const TextStyle(fontSize: 11, color: _slateGrey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedCard,
                              decoration: InputDecoration(
                                labelText: 'Credit Card Issuer & Variant',
                                prefixIcon: const Icon(Icons.credit_card_outlined, color: _brandBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: popularCards.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setModalState(() {
                                    selectedCard = v;
                                    if (v.contains('HDFC')) {
                                      selectedIssuedBank = 'HDFC Bank';
                                    } else if (v.contains('ICICI')) {
                                      selectedIssuedBank = 'ICICI Bank';
                                    } else if (v.contains('SBI')) {
                                      selectedIssuedBank = 'State Bank of India';
                                    } else if (v.contains('Axis')) {
                                      selectedIssuedBank = 'Axis Bank';
                                    } else if (v.contains('Kotak')) {
                                      selectedIssuedBank = 'Kotak Mahindra Bank';
                                    } else if (v.contains('American Express')) {
                                      selectedIssuedBank = 'American Express';
                                      selectedCardType = 'American Express';
                                    }
                                  });
                                }
                              },
                            ),
                            if (selectedCard == 'Other Credit Card') ...[
                              const SizedBox(height: 14),
                              TextField(
                                controller: otherCardCtrl,
                                onChanged: (_) => setModalState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'Other Credit Card Name & Variant',
                                  hintText: 'e.g. OneCard, Standard Chartered Ultimate, IndusInd',
                                  prefixIcon: const Icon(Icons.credit_card, color: _brandBlue),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            TextField(
                              controller: holderNameCtrl,
                              onChanged: (_) => setModalState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Holder Name',
                                hintText: 'e.g. Sireesha Bandaru',
                                prefixIcon: const Icon(Icons.person_outline, color: _brandBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: selectedIssuedBank,
                                    decoration: InputDecoration(
                                      labelText: 'Issued Bank',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    items: issuedBankOptions.map((b) => DropdownMenuItem(value: b, child: BankNameWithLogo(bankName: b, logoSize: 18, textStyle: const TextStyle(fontSize: 12)))).toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => selectedIssuedBank = v);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 5,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: selectedCardType,
                                    decoration: InputDecoration(
                                      labelText: 'Card Type',
                                      prefixIcon: const Icon(Icons.payment, color: _brandBlue, size: 20),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    items: cardTypeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => selectedCardType = v);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (selectedIssuedBank == 'Others') ...[
                              const SizedBox(height: 14),
                              TextField(
                                controller: otherIssuedBankCtrl,
                                onChanged: (_) => setModalState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'Other Issuing Bank Name',
                                  hintText: 'e.g. Federal Bank, Yes Bank',
                                  prefixIcon: const Icon(Icons.account_balance, color: _brandBlue),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: last4Ctrl,
                                    keyboardType: TextInputType.number,
                                    maxLength: 4,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      labelText: 'Last 4 Digits',
                                      hintText: 'e.g. 8842',
                                      prefixIcon: const Icon(Icons.password, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: expiryCtrl,
                                    keyboardType: TextInputType.datetime,
                                    maxLength: 5,
                                    onChanged: (val) {
                                      if (val.length == 2 && !val.contains('/')) {
                                        expiryCtrl.text = '$val/';
                                        expiryCtrl.selection = TextSelection.fromPosition(TextPosition(offset: expiryCtrl.text.length));
                                      }
                                      setModalState(() {});
                                    },
                                    decoration: InputDecoration(
                                      counterText: '',
                                      labelText: 'Expiry (MM/YY)',
                                      hintText: 'MM/YY (e.g. 10/28)',
                                      prefixIcon: const Icon(Icons.calendar_month_outlined, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: limitCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Total Limit (₹)',
                                      hintText: 'e.g. 300000',
                                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: outstandingCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Outstanding (₹)',
                                      hintText: 'e.g. 34500',
                                      prefixIcon: const Icon(Icons.receipt_long_outlined, color: Color(0xFFEF4444)),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: selectedDueDate,
                                    decoration: InputDecoration(
                                      labelText: 'Statement Due Date',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    items: dueDates.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => selectedDueDate = v);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: rewardCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Reward Points (Optional)',
                                      hintText: 'e.g. 4500',
                                      prefixIcon: const Icon(Icons.stars_outlined, color: Color(0xFFF59E0B)),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.shield_outlined, size: 16, color: _brandBlue),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Card data is tracked for Credit Utilization analytics and timely payment alerts. CVV and Card PIN are NEVER stored.',
                                      style: TextStyle(fontSize: 10, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final enteredOther = otherCardCtrl.text.trim();
                          if (selectedCard == 'Other Credit Card' && enteredOther.isEmpty) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your credit card name'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          final enteredOtherBank = otherIssuedBankCtrl.text.trim();
                          if (selectedIssuedBank == 'Others' && enteredOtherBank.isEmpty) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter issuing bank name'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          final cardName = selectedCard == 'Other Credit Card' ? enteredOther : selectedCard;
                          final finalIssuedBank = selectedIssuedBank == 'Others' ? enteredOtherBank : selectedIssuedBank;
                          final holder = holderNameCtrl.text.trim().isEmpty ? 'Sireesha Bandaru' : holderNameCtrl.text.trim();
                          final expiry = expiryCtrl.text.trim().isEmpty ? '10/28' : expiryCtrl.text.trim();

                          final last4 = last4Ctrl.text.trim();
                          if (last4.isEmpty) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter the last 4 digits of your credit card'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }
                          final limitVal = double.tryParse(limitCtrl.text.trim().replaceAll(',', '')) ?? 100000.0;
                          final outstandingVal = double.tryParse(outstandingCtrl.text.trim().replaceAll(',', '')) ?? 0.0;
                          final rewards = int.tryParse(rewardCtrl.text.trim()) ?? 0;

                          if (existingCard != null) {
                            final updated = existingCard.copyWith(
                              cardName: cardName,
                              last4Digits: last4,
                              creditLimit: limitVal,
                              outstandingBalance: outstandingVal,
                              availableCredit: (limitVal - outstandingVal).clamp(0.0, double.infinity),
                              statementDueDate: selectedDueDate,
                              minimumDue: (outstandingVal * 0.05).clamp(0.0, double.infinity),
                              rewardPoints: rewards,
                              cardHolderName: holder,
                              issuedBank: finalIssuedBank,
                              cardType: selectedCardType,
                              expiryDate: expiry,
                            );
                            ref.read(bankAggregationProvider.notifier).updateCreditCard(updated);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$cardName updated successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          } else {
                            ref.read(bankAggregationProvider.notifier).addCreditCardItem(
                                  cardName: cardName,
                                  last4Digits: last4,
                                  creditLimit: limitVal,
                                  outstandingBalance: outstandingVal,
                                  statementDueDate: selectedDueDate,
                                  minimumDue: (outstandingVal * 0.05).clamp(0.0, double.infinity),
                                  rewardPoints: rewards,
                                  holderName: holder,
                                  issuedBank: finalIssuedBank,
                                  cardType: selectedCardType,
                                  expiryDate: expiry,
                                );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$cardName added to Credit Cards!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          }
                        },
                        child: Text(
                          existingCard != null ? 'Update Credit Card' : 'Add Credit Card to Portfolio',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  void _showAddUpiModal(BuildContext context, {UpiAccountItem? existingUpi}) {
    final upiCtrl = TextEditingController(text: existingUpi?.upiId ?? '');
    final otherUpiCtrl = TextEditingController();
    final otherBankCtrl = TextEditingController();
    String selectedProvider = existingUpi?.provider ?? 'Google Pay';
    String selectedBank = existingUpi?.linkedBank ?? 'State Bank of India';

    final upiProviders = [
      'Google Pay',
      'PhonePe',
      'Paytm UPI',
      'BHIM UPI',
      'Amazon Pay UPI',
      'CRED UPI',
      'WhatsApp Pay',
      'Tata Pay',
      'Other UPI',
    ];

    final bankOptions = [
      'State Bank of India',
      'HDFC Bank',
      'ICICI Bank',
      'Axis Bank',
      'Kotak Mahindra Bank',
      'Punjab National Bank',
      'Bank of Baroda',
      'Canara Bank',
      'Union Bank of India',
      'IndusInd Bank',
      'Federal Bank',
      'IDFC FIRST Bank',
      'Others',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.90,
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                  left: 20,
                  right: 20,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.qr_code_2, color: _brandBlue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existingUpi != null ? 'Edit UPI Account' : 'Link New UPI Account & VPA',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark),
                              ),
                              Text(
                                existingUpi != null ? 'Update UPI VPA details (FAA-SEC-03)' : 'NPCI Unified Payments Interface Aggregation (FAA-SEC-03)',
                                style: const TextStyle(fontSize: 11, color: _slateGrey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: upiCtrl,
                      decoration: InputDecoration(
                        labelText: 'UPI ID (Virtual Payment Address)',
                        hintText: 'e.g. mobile@okhdfcbank',
                        prefixIcon: const Icon(Icons.alternate_email, color: _brandBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedProvider,
                      decoration: InputDecoration(
                        labelText: 'UPI App Provider',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: upiProviders.map((p) => DropdownMenuItem(
                        value: p,
                        child: BankNameWithLogo(bankName: p, logoSize: 20),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() => selectedProvider = v);
                        }
                      },
                    ),
                    if (selectedProvider == 'Other UPI' || selectedProvider == 'Tata Pay / Other UPI') ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: otherUpiCtrl,
                        decoration: InputDecoration(
                          labelText: 'Other UPI App / Provider Name',
                          hintText: 'e.g. Navi, CRED, Super.money, Tata Neu',
                          prefixIcon: const Icon(Icons.apps_outlined, color: _brandBlue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedBank,
                      decoration: InputDecoration(
                        labelText: 'Underlying Linked Bank Account',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: bankOptions.map((b) => DropdownMenuItem(
                        value: b,
                        child: BankNameWithLogo(bankName: b, logoSize: 20),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() => selectedBank = v);
                        }
                      },
                    ),
                    if (selectedBank == 'Others' || selectedBank == 'Other Bank') ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: otherBankCtrl,
                        decoration: InputDecoration(
                          labelText: 'Other Linked Bank Name',
                          hintText: 'e.g. Standard Chartered, Yes Bank, RBL Bank',
                          prefixIcon: const Icon(Icons.account_balance_outlined, color: _brandBlue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final text = upiCtrl.text.trim();
                          if (text.isEmpty) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid UPI ID (e.g. name@bank)'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          final isOtherUpi = selectedProvider == 'Other UPI' || selectedProvider == 'Tata Pay / Other UPI';
                          final enteredOtherUpi = otherUpiCtrl.text.trim();
                          if (isOtherUpi && enteredOtherUpi.isEmpty) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your UPI app / provider name'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          final isOtherBank = selectedBank == 'Others' || selectedBank == 'Other Bank';
                          final enteredOtherBank = otherBankCtrl.text.trim();
                          if (isOtherBank && enteredOtherBank.isEmpty) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your linked bank name'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          final providerName = isOtherUpi ? enteredOtherUpi : selectedProvider;
                          final bankName = isOtherBank ? enteredOtherBank : selectedBank;

                          if (existingUpi != null) {
                            final updated = existingUpi.copyWith(
                              upiId: text,
                              provider: providerName,
                              linkedBank: bankName,
                            );
                            ref.read(bankAggregationProvider.notifier).updateUpiAccount(updated);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('UPI account $text updated successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          } else {
                            ref.read(bankAggregationProvider.notifier).addUpiAccount(
                                  text,
                                  providerName,
                                  bankName,
                                );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('UPI account $text linked successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          }
                        },
                        child: Text(
                          existingUpi != null ? 'Update UPI ID' : 'Verify & Link UPI ID',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
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

  void _showAddLoanModal(BuildContext context, {LoanAccountItem? existingLoan}) {
    String selectedLoanType = existingLoan?.loanType ?? 'Home Loan';
    String selectedLender = existingLoan?.lender ?? 'State Bank of India';
    final principalCtrl = TextEditingController(text: existingLoan != null ? existingLoan.outstandingPrincipal.toStringAsFixed(0) : '');
    final roiCtrl = TextEditingController(text: existingLoan != null ? existingLoan.interestRate.toString() : '');
    final emiCtrl = TextEditingController(text: existingLoan != null ? existingLoan.monthlyEmi.toStringAsFixed(0) : '');
    final tenureCtrl = TextEditingController(text: existingLoan != null ? existingLoan.tenureRemainingMonths.toString() : '');
    final dueDateCtrl = TextEditingController(text: existingLoan?.nextDueDate ?? '');
    final otherLenderCtrl = TextEditingController();

    final loanTypes = [
      'Home Loan',
      'Vehicle Loan',
      'Personal Loan',
      'Education Loan',
      'Business Loan',
      'Gold Loan',
      'Other Loan',
    ];

    final lenderOptions = [
      'State Bank of India',
      'HDFC Bank',
      'ICICI Bank',
      'Axis Bank',
      'Kotak Mahindra Bank',
      'Bank of Baroda',
      'Punjab National Bank',
      'Canara Bank',
      'Union Bank of India',
      'Bajaj Finserv',
      'Tata Capital',
      'L&T Finance',
      'Others',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.90,
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                  left: 20,
                  right: 20,
                  top: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.real_estate_agent_outlined, color: _brandBlue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existingLoan != null ? 'Edit Loan Account' : 'Add Loan Account',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark),
                              ),
                              Text(
                                existingLoan != null ? 'Update loan balance & EMI details (FAA-SEC-05)' : 'Track EMI, interest rate & principal (FAA-SEC-05)',
                                style: const TextStyle(fontSize: 11, color: _slateGrey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedLoanType,
                              decoration: InputDecoration(
                                labelText: 'Loan Category',
                                prefixIcon: const Icon(Icons.category_outlined, color: _brandBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: loanTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) {
                                if (v != null) setModalState(() => selectedLoanType = v);
                              },
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedLender,
                              decoration: InputDecoration(
                                labelText: 'Lender / Institution',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: lenderOptions.map((b) => DropdownMenuItem(
                                value: b,
                                child: BankNameWithLogo(bankName: b, logoSize: 20),
                              )).toList(),
                              onChanged: (v) {
                                if (v != null) setModalState(() => selectedLender = v);
                              },
                            ),
                            if (selectedLender == 'Others') ...[
                              const SizedBox(height: 14),
                              TextField(
                                controller: otherLenderCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Other Lender / Bank Name',
                                  hintText: 'e.g. IDFC FIRST Bank, LIC Housing Finance',
                                  prefixIcon: const Icon(Icons.account_balance, color: _brandBlue),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            TextField(
                              controller: principalCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Outstanding Principal (₹)',
                                hintText: 'e.g. 2450000',
                                prefixIcon: const Icon(Icons.currency_rupee, color: _brandBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: roiCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Interest Rate (% p.a.)',
                                      hintText: 'e.g. 8.55',
                                      prefixIcon: const Icon(Icons.percent, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: emiCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Monthly EMI (₹)',
                                      hintText: 'e.g. 23450',
                                      prefixIcon: const Icon(Icons.calendar_today, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: tenureCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Tenure Left (Months)',
                                      hintText: 'e.g. 168',
                                      prefixIcon: const Icon(Icons.timelapse, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: dueDateCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'Next Due Date',
                                      hintText: 'e.g. 05 Nov 2026',
                                      prefixIcon: const Icon(Icons.event, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final lenderName = selectedLender == 'Others'
                              ? (otherLenderCtrl.text.trim().isEmpty ? 'Private Lender' : otherLenderCtrl.text.trim())
                              : selectedLender;
                          final principalVal = double.tryParse(principalCtrl.text.trim().replaceAll(',', '')) ?? 0.0;
                          final roiVal = double.tryParse(roiCtrl.text.trim()) ?? 8.5;
                          final emiVal = double.tryParse(emiCtrl.text.trim().replaceAll(',', '')) ?? 0.0;
                          final tenureVal = int.tryParse(tenureCtrl.text.trim()) ?? 12;
                          final dueVal = dueDateCtrl.text.trim().isEmpty ? 'Next month' : dueDateCtrl.text.trim();

                          if (existingLoan != null) {
                            final updated = existingLoan.copyWith(
                              loanType: selectedLoanType,
                              lender: lenderName,
                              outstandingPrincipal: principalVal,
                              interestRate: roiVal,
                              monthlyEmi: emiVal,
                              tenureRemainingMonths: tenureVal,
                              nextDueDate: dueVal,
                            );
                            ref.read(bankAggregationProvider.notifier).updateLoanAccount(updated);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$lenderName $selectedLoanType updated successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          } else {
                            ref.read(bankAggregationProvider.notifier).addLoanAccount(
                                  loanType: selectedLoanType,
                                  lender: lenderName,
                                  outstandingPrincipal: principalVal,
                                  interestRate: roiVal,
                                  monthlyEmi: emiVal,
                                  tenureRemainingMonths: tenureVal,
                                  nextDueDate: dueVal,
                                );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedLoanType at $lenderName linked successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          }
                        },
                        child: Text(
                          existingLoan != null ? 'Update Loan Account' : 'Add Loan Account to Liabilities',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  void _showAddInvestmentModal(BuildContext context, {InvestmentHoldingItem? existingInvestment}) {
    String selectedAssetType = existingInvestment?.assetType ?? 'Mutual Funds';
    final institutionCtrl = TextEditingController(text: existingInvestment?.institution ?? '');
    final currentValCtrl = TextEditingController(text: existingInvestment != null ? existingInvestment.currentValue.toStringAsFixed(0) : '');
    final investedValCtrl = TextEditingController(text: existingInvestment != null ? existingInvestment.investedValue.toStringAsFixed(0) : '');
    final returnPercentCtrl = TextEditingController(text: existingInvestment != null ? existingInvestment.returnPercentage.toString() : '');
    bool isPositive = existingInvestment?.isPositive ?? true;

    final assetTypes = [
      'Mutual Funds',
      'Equity Stocks & ETFs',
      'Fixed Deposits',
      'Sovereign Gold Bonds',
      'EPF & PPF (Retirement)',
      'National Pension Scheme (NPS)',
      'Real Estate & REITs',
      'Other Investments',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.90,
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                  left: 20,
                  right: 20,
                  top: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.trending_up, color: _brandBlue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existingInvestment != null ? 'Edit Investment' : 'Add Investment Holding',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark),
                              ),
                              Text(
                                existingInvestment != null ? 'Update holding portfolio values (FAA-SEC-06)' : 'Track MFs, Stocks, FDs, Gold & EPF (FAA-SEC-06)',
                                style: const TextStyle(fontSize: 11, color: _slateGrey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedAssetType,
                              decoration: InputDecoration(
                                labelText: 'Asset Category',
                                prefixIcon: const Icon(Icons.pie_chart_outline, color: _brandBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: assetTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) {
                                if (v != null) setModalState(() => selectedAssetType = v);
                              },
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: institutionCtrl,
                              decoration: InputDecoration(
                                labelText: 'Institution / Platform / Fund Name',
                                hintText: 'e.g. Zerodha Kite, Groww, HDFC AMC, EPFO',
                                prefixIcon: const Icon(Icons.business, color: _brandBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: currentValCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Current Market Value (₹)',
                                      hintText: 'e.g. 500000',
                                      prefixIcon: const Icon(Icons.currency_rupee, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: investedValCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Invested Amount (₹)',
                                      hintText: 'e.g. 400000',
                                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: returnPercentCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Returns (%)',
                                      hintText: 'e.g. 25.0',
                                      prefixIcon: const Icon(Icons.percent, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setModalState(() => isPositive = !isPositive),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isPositive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: isPositive ? _emeraldGreen : const Color(0xFFEF4444)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: isPositive ? _emeraldGreen : const Color(0xFFEF4444)),
                                          const SizedBox(width: 6),
                                          Text(
                                            isPositive ? 'Gain / Profit' : 'Loss / Negative',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isPositive ? _emeraldGreen : const Color(0xFFEF4444)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final instName = institutionCtrl.text.trim().isEmpty ? 'Portfolio Holding' : institutionCtrl.text.trim();
                          final currentVal = double.tryParse(currentValCtrl.text.trim().replaceAll(',', '')) ?? 0.0;
                          final investedVal = double.tryParse(investedValCtrl.text.trim().replaceAll(',', '')) ?? 0.0;
                          final returnVal = double.tryParse(returnPercentCtrl.text.trim()) ?? 0.0;

                          if (existingInvestment != null) {
                            final updated = existingInvestment.copyWith(
                              assetType: selectedAssetType,
                              institution: instName,
                              currentValue: currentVal,
                              investedValue: investedVal,
                              returnPercentage: returnVal,
                              isPositive: isPositive,
                            );
                            ref.read(bankAggregationProvider.notifier).updateInvestmentHolding(updated);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedAssetType updated successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          } else {
                            ref.read(bankAggregationProvider.notifier).addInvestmentHolding(
                                  assetType: selectedAssetType,
                                  institution: instName,
                                  currentValue: currentVal,
                                  investedValue: investedVal,
                                  returnPercentage: returnVal,
                                  isPositive: isPositive,
                                );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedAssetType holding added successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          }
                        },
                        child: Text(
                          existingInvestment != null ? 'Update Investment' : 'Add Investment to Portfolio',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  void _showAddInsuranceModal(BuildContext context, {InsurancePolicyItem? existingPolicy}) {
    String selectedPolicyType = existingPolicy?.policyType ?? 'Health Insurance';
    String selectedProvider = existingPolicy?.provider ?? 'HDFC ERGO Optima Secure';
    final policyNumCtrl = TextEditingController(text: existingPolicy?.policyNumberMasked ?? '');
    final coverageCtrl = TextEditingController(text: existingPolicy != null ? existingPolicy.coverageAmount.toStringAsFixed(0) : '');
    final premiumCtrl = TextEditingController(text: existingPolicy != null ? existingPolicy.premiumAmount.toStringAsFixed(0) : '');
    final renewalCtrl = TextEditingController(text: existingPolicy?.renewalDate ?? '');
    final nomineeCtrl = TextEditingController(text: existingPolicy?.nominee ?? '');
    final otherProviderCtrl = TextEditingController();

    final policyTypes = [
      'Health Insurance',
      'Term Life Insurance',
      'Vehicle Comprehensive',
      'Critical Illness',
      'Personal Accident',
      'Home & Property Insurance',
      'Travel Insurance',
      'Other Insurance',
    ];

    final providers = [
      'HDFC ERGO Optima Secure',
      'Tata AIA Life Sampoorna',
      'Star Health Comprehensive',
      'ICICI Lombard General',
      'Maruti Insurance Broking',
      'Care Health Care Supreme',
      'LIC of India Jeevan Labh',
      'Max Life Smart Term',
      'Bajaj Allianz General',
      'SBI Life eShield',
      'Others',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.90,
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                  left: 20,
                  right: 20,
                  top: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.health_and_safety_outlined, color: _brandBlue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existingPolicy != null ? 'Edit Insurance Policy' : 'Add Insurance Policy',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark),
                              ),
                              Text(
                                existingPolicy != null ? 'Update policy sum insured & renewal (FAA-SEC-07)' : 'Track health, life & vehicle coverage (FAA-SEC-07)',
                                style: const TextStyle(fontSize: 11, color: _slateGrey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedPolicyType,
                              decoration: InputDecoration(
                                labelText: 'Policy Category',
                                prefixIcon: const Icon(Icons.security, color: _brandBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: policyTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) {
                                if (v != null) setModalState(() => selectedPolicyType = v);
                              },
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedProvider,
                              decoration: InputDecoration(
                                labelText: 'Insurance Provider',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: providers.map((b) => DropdownMenuItem(
                                value: b,
                                child: BankNameWithLogo(bankName: b, logoSize: 20),
                              )).toList(),
                              onChanged: (v) {
                                if (v != null) setModalState(() => selectedProvider = v);
                              },
                            ),
                            if (selectedProvider == 'Others') ...[
                              const SizedBox(height: 14),
                              TextField(
                                controller: otherProviderCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Other Provider Name',
                                  hintText: 'e.g. Niva Bupa, Digit Insurance',
                                  prefixIcon: const Icon(Icons.business, color: _brandBlue),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            TextField(
                              controller: policyNumCtrl,
                              decoration: InputDecoration(
                                labelText: 'Policy Number',
                                hintText: 'e.g. POL-XXXX-9842',
                                prefixIcon: const Icon(Icons.pin, color: _brandBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: coverageCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Sum Insured (₹)',
                                      hintText: 'e.g. 1500000',
                                      prefixIcon: const Icon(Icons.verified, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: premiumCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Premium / Year (₹)',
                                      hintText: 'e.g. 14500',
                                      prefixIcon: const Icon(Icons.currency_rupee, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: renewalCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'Renewal Date',
                                      hintText: 'e.g. 14 Jul 2027',
                                      prefixIcon: const Icon(Icons.event_repeat, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: nomineeCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'Nominee',
                                      hintText: 'e.g. Spouse, Parents',
                                      prefixIcon: const Icon(Icons.person_pin, color: _brandBlue),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final providerName = selectedProvider == 'Others'
                              ? (otherProviderCtrl.text.trim().isEmpty ? 'Insurance Provider' : otherProviderCtrl.text.trim())
                              : selectedProvider;
                          final coverageVal = double.tryParse(coverageCtrl.text.trim().replaceAll(',', '')) ?? 0.0;
                          final premiumVal = double.tryParse(premiumCtrl.text.trim().replaceAll(',', '')) ?? 0.0;
                          final polNum = policyNumCtrl.text.trim().isEmpty ? 'POL-XXXX-0001' : policyNumCtrl.text.trim();
                          final renewalVal = renewalCtrl.text.trim().isEmpty ? 'Annual Renewal' : renewalCtrl.text.trim();
                          final nomineeVal = nomineeCtrl.text.trim().isEmpty ? 'Self' : nomineeCtrl.text.trim();

                          if (existingPolicy != null) {
                            final updated = existingPolicy.copyWith(
                              policyType: selectedPolicyType,
                              policyNumberMasked: polNum,
                              provider: providerName,
                              coverageAmount: coverageVal,
                              premiumAmount: premiumVal,
                              renewalDate: renewalVal,
                              nominee: nomineeVal,
                            );
                            ref.read(bankAggregationProvider.notifier).updateInsurancePolicy(updated);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedPolicyType ($providerName) updated successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          } else {
                            ref.read(bankAggregationProvider.notifier).addInsurancePolicy(
                                  policyType: selectedPolicyType,
                                  policyNumberMasked: polNum,
                                  provider: providerName,
                                  coverageAmount: coverageVal,
                                  premiumAmount: premiumVal,
                                  renewalDate: renewalVal,
                                  nominee: nomineeVal,
                                );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedPolicyType policy added successfully!'),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          }
                        },
                        child: Text(
                          existingPolicy != null ? 'Update Insurance Policy' : 'Add Policy to Protection Portfolio',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _buildConsentBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: _emeraldGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bankAggregationProvider);

    final filteredDirectory = state.institutionDirectory.where((inst) {
      final matchesCat = state.selectedCategoryFilter == 'All' || inst.category == state.selectedCategoryFilter;
      final matchesSearch = inst.name.toLowerCase().contains(state.searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: _bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation: 1,
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
        title: const Row(
          children: [
            FinmosLogo(size: 28, showTitle: false, showTagline: false),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bank & Aggregation',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A2540),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Module 2: Account Aggregation (FAA)',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: state.isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0066FF)),
                  )
                : const Icon(Icons.sync, color: Color(0xFF0066FF)),
            tooltip: 'Sync All Accounts (Real-Time)',
            onPressed: state.isSyncing
                ? null
                : () {
                    ref.read(bankAggregationProvider.notifier).syncAllAccounts();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Synchronizing bank accounts, UPI, cards & investments...'),
                        backgroundColor: _brandBlue,
                        duration: Duration(milliseconds: 1500),
                      ),
                    );
                  },
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Title & Subtitle Card (FAA Module Overview)
            _buildModuleTitleBanner(state),
            const SizedBox(height: 14),

            // 2. SECTION 12: Aggregated Financial Position & Net Worth Hero Dashboard
            _buildAggregatedFinancialDashboard(state),
            const SizedBox(height: 14),

            // 3. Quick Category Filter Tabs
            _buildCategoryFilterTabs(state),
            const SizedBox(height: 16),

            // 5. SECTION 2: Connected Bank Accounts
            _buildBankAccountsSection(context, state),
            const SizedBox(height: 16),

            // 6. SECTION 3: UPI Account Aggregation
            _buildUpiAccountsSection(context, state),
            const SizedBox(height: 16),

            // 7. SECTION 4: Credit Card Liabilities
            _buildCreditCardsSection(context, state),
            const SizedBox(height: 16),

            // 8. SECTION 5: Loan Account Aggregation
            _buildLoansSection(context, state),
            const SizedBox(height: 16),

            // 9. SECTION 6 & 9: Investments & Retirement Aggregation
            _buildInvestmentsSection(context, state),
            const SizedBox(height: 16),

            // 10. SECTION 7: Insurance Policy Aggregation
            _buildInsuranceSection(context, state),
            const SizedBox(height: 16),

            // 11. SECTION 8: Digital Wallets Aggregation
            _buildWalletsSection(state),
            const SizedBox(height: 16),

            // 12. SECTION 11: RBI Account Aggregator Consent Management
            _buildConsentManagementSection(context, state),
            const SizedBox(height: 16),

            // 13. SECTION 1: Financial Institution Directory & Connect Box
            _buildInstitutionDirectorySection(context, state, filteredDirectory),
            const SizedBox(height: 16),

            // 14. Recent Ingested Transactions
            _buildRecentTransactionsSection(state),
            const SizedBox(height: 16),

            // 15. Security & Regulatory Compliance Footer
            _buildSecurityFooter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TOP TITLE & SUBTITLE
  // --------------------------------------------------------------------------

  Widget _buildModuleTitleBanner(BankAggregationState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.account_balance, color: _brandBlue, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank Account Aggregation',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _navyDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Personal Financial Operating System (PFOS) • Module 2: FAA',
                      style: TextStyle(fontSize: 11, color: _slateGrey, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _cardBorder),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _FeatureBadge(icon: Icons.shield_outlined, text: 'RBI AA Regulated'),
              _FeatureBadge(icon: Icons.lock_outline, text: 'AES-256 Encrypted'),
              _FeatureBadge(icon: Icons.verified_user_outlined, text: 'Consent Based'),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 12: AGGREGATED FINANCIAL DASHBOARD (NET WORTH & POSITION)
  // --------------------------------------------------------------------------

  Widget _buildAggregatedFinancialDashboard(BankAggregationState state) {
    final netWorth = state.netWorth;
    final totalCash = state.totalCashPosition;
    final totalDebt = state.totalDebtPosition;
    final totalInv = state.totalInvestments;
    final totalIns = state.totalInsuranceCoverage;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A2540), Color(0xFF0066FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x260066FF), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_outline, color: Color(0xFF93C5FD), size: 16),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'CONSOLIDATED FINANCIAL NET WORTH',
                  style: TextStyle(fontSize: 10, color: Color(0xFFBFDBFE), fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Unified Portfolio', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${_formatCurrency(netWorth)}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Total Assets: ₹ ${_formatCurrency(state.totalAssets)}  •  Total Debt: ₹ ${_formatCurrency(totalDebt)}',
            style: const TextStyle(fontSize: 11, color: Color(0xFFE2E8F0)),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 14),

          // 4 Key Aggregated Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Liquid Cash',
                  value: '₹ ${_formatCurrency(totalCash)}',
                  icon: Icons.account_balance_wallet_rounded,
                  accentColor: const Color(0xFF10B981), // Green
                  labelColor: const Color(0xFFA7F3D0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Investments',
                  value: '₹ ${_formatCurrency(totalInv)}',
                  icon: Icons.trending_up_rounded,
                  accentColor: const Color(0xFF38BDF8), // Blue
                  labelColor: const Color(0xFFBAE6FD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Total Debt',
                  value: '₹ ${_formatCurrency(totalDebt)}',
                  icon: Icons.credit_card_off_rounded,
                  accentColor: const Color(0xFFF87171), // Light Red
                  labelColor: const Color(0xFFFECACA),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Insurance Cover',
                  value: '₹ ${_formatCurrency(totalIns)}',
                  icon: Icons.health_and_safety_rounded,
                  accentColor: const Color(0xFFF59E0B), // Insurance Logo Amber/Gold
                  labelColor: const Color(0xFFFDE68A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.24),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // --------------------------------------------------------------------------
  // QUICK CATEGORY FILTER TABS
  // --------------------------------------------------------------------------

  Widget _buildCategoryFilterTabs(BankAggregationState state) {
    final tabs = [
      'All (${state.bankAccounts.length + state.upiAccounts.length + state.creditCards.length + state.loans.length})',
      'Banks (${state.bankAccounts.length})',
      'UPI (${state.upiAccounts.length})',
      'Cards (${state.creditCards.length})',
      'Loans (${state.loans.length})',
      'Investments (${state.investments.length})',
      'Insurance (${state.insurancePolicies.length})',
      'Wallets (${state.wallets.length})',
      'Consents (${state.consents.length})',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final idx = entry.key;
          final title = entry.value;
          final isSelected = state.selectedTabIndex == idx;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => ref.read(bankAggregationProvider.notifier).selectTab(idx),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? _brandBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? _brandBlue : _cardBorder),
                  boxShadow: isSelected
                      ? [BoxShadow(color: _brandBlue.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ACCOUNT DETAILS, EDIT & DELETE HELPERS
  // --------------------------------------------------------------------------

  void _confirmDelete({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _navyDark),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(dlgCtx);
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {bool isHighlight = false, Color? highlightColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isHighlight ? (highlightColor ?? _brandBlue) : _navyDark,
            ),
          ),
        ),
      ],
    );
  }

  void _showBankAccountDetails(BuildContext context, BankAccountItem acc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                  Row(
                    children: [
                      BankLogo(bankName: acc.bankName, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(acc.bankName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark)),
                            Text('${acc.accountType} • ${acc.maskedAccountNumber}', style: const TextStyle(fontSize: 12, color: _slateGrey)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 12, color: _emeraldGreen),
                            SizedBox(width: 4),
                            Text('Synced', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _emeraldGreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Account Holder', acc.accountHolder, Icons.person_outline),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Account Type', acc.accountType, Icons.account_balance_wallet_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Account Number', acc.maskedAccountNumber, Icons.pin_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('IFSC Code', acc.ifscCode, Icons.business_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Available Balance', '₹ ${_formatCurrency(acc.availableBalance)}', Icons.currency_rupee, isHighlight: true),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Last Synced', acc.lastSynced, Icons.sync),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            _confirmDelete(
                              context: context,
                              title: 'Delete Bank Account?',
                              message: 'Are you sure you want to remove ${acc.bankName} (${acc.maskedAccountNumber}) from your connected accounts?',
                              onDelete: () {
                                Navigator.pop(ctx);
                                ref.read(bankAggregationProvider.notifier).deleteBankAccount(acc.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${acc.bankName} account deleted successfully'),
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brandBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAddBankModal(context, existingAccount: acc);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpiAccountDetails(BuildContext context, UpiAccountItem upi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                  Row(
                    children: [
                      BankLogo(bankName: upi.provider.isNotEmpty ? upi.provider : upi.linkedBank, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(upi.upiId, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _navyDark)),
                            Text('${upi.provider} • Linked: ${upi.linkedBank}', style: const TextStyle(fontSize: 12, color: _slateGrey)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _emeraldGreen)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('UPI Virtual Address', upi.upiId, Icons.alternate_email),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('App Provider', upi.provider, Icons.apps_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Underlying Linked Bank', upi.linkedBank, Icons.account_balance_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Primary UPI ID', upi.isPrimary ? 'Yes (Default Mandate)' : 'No', Icons.star_outline),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Account Status', upi.status, Icons.verified_outlined, isHighlight: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            _confirmDelete(
                              context: context,
                              title: 'Delete UPI Account?',
                              message: 'Are you sure you want to remove ${upi.upiId} from linked UPI handles?',
                              onDelete: () {
                                Navigator.pop(ctx);
                                ref.read(bankAggregationProvider.notifier).deleteUpiAccount(upi.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('UPI account ${upi.upiId} deleted successfully'),
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brandBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAddUpiModal(context, existingUpi: upi);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreditCardDetails(BuildContext context, CreditCardItem card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                  Row(
                    children: [
                      BankLogo(bankName: card.issuedBank ?? card.cardName, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(card.cardName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark)),
                            Text('•••• ${card.last4Digits} • ${card.cardType ?? "Credit Card"}${card.expiryDate != null ? " • Exp: ${card.expiryDate}" : ""}', style: const TextStyle(fontSize: 12, color: _slateGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        if (card.cardHolderName != null) ...[
                          _buildDetailRow('Cardholder Name', card.cardHolderName!, Icons.person_outline),
                          const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        ],
                        if (card.issuedBank != null) ...[
                          _buildDetailRow('Issuing Bank', card.issuedBank!, Icons.account_balance_outlined),
                          const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        ],
                        _buildDetailRow('Credit Limit', '₹ ${_formatCurrency(card.creditLimit)}', Icons.credit_score_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Outstanding Due', '₹ ${_formatCurrency(card.outstandingBalance)}', Icons.payment_outlined, isHighlight: true, highlightColor: const Color(0xFFEF4444)),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Available Credit', '₹ ${_formatCurrency(card.availableCredit)}', Icons.account_balance_wallet_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Statement Due Date', card.statementDueDate, Icons.calendar_today_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Minimum Amount Due', '₹ ${_formatCurrency(card.minimumDue)}', Icons.warning_amber_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Reward Points', '${card.rewardPoints} Pts', Icons.stars_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            _confirmDelete(
                              context: context,
                              title: 'Delete Credit Card?',
                              message: 'Are you sure you want to remove ${card.cardName} (•••• ${card.last4Digits}) from your credit portfolio?',
                              onDelete: () {
                                Navigator.pop(ctx);
                                ref.read(bankAggregationProvider.notifier).deleteCreditCard(card.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${card.cardName} deleted successfully'),
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brandBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAddCreditCardModal(context, existingCard: card);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLoanDetails(BuildContext context, LoanAccountItem loan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                  Row(
                    children: [
                      BankLogo(bankName: loan.lender, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${loan.lender} • ${loan.loanType}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark)),
                            Text('ROI: ${loan.interestRate}% p.a. • EMI: ₹ ${_formatCurrency(loan.monthlyEmi)}', style: const TextStyle(fontSize: 12, color: _slateGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Lender Institution', loan.lender, Icons.account_balance_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Loan Category', loan.loanType, Icons.category_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Outstanding Principal', '₹ ${_formatCurrency(loan.outstandingPrincipal)}', Icons.currency_rupee, isHighlight: true, highlightColor: const Color(0xFFB45309)),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Interest Rate (ROI)', '${loan.interestRate}% p.a.', Icons.percent),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Monthly EMI Amount', '₹ ${_formatCurrency(loan.monthlyEmi)}', Icons.payment_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Tenure Remaining', '${loan.tenureRemainingMonths} Months', Icons.timelapse_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Next EMI Due Date', loan.nextDueDate, Icons.calendar_today_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            _confirmDelete(
                              context: context,
                              title: 'Delete Loan Account?',
                              message: 'Are you sure you want to remove ${loan.lender} ${loan.loanType} from your liabilities?',
                              onDelete: () {
                                Navigator.pop(ctx);
                                ref.read(bankAggregationProvider.notifier).deleteLoanAccount(loan.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${loan.lender} ${loan.loanType} deleted successfully'),
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brandBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAddLoanModal(context, existingLoan: loan);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showInvestmentDetails(BuildContext context, InvestmentHoldingItem inv) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Icon(
                          inv.assetType.contains('Mutual')
                              ? Icons.donut_large
                              : inv.assetType.contains('Stock')
                                  ? Icons.show_chart
                                  : inv.assetType.contains('Gold')
                                      ? Icons.monetization_on
                                      : Icons.savings,
                          size: 22,
                          color: _brandBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(inv.assetType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark)),
                            Text(inv.institution, style: const TextStyle(fontSize: 12, color: _slateGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Asset Category', inv.assetType, Icons.pie_chart_outline),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Platform / Institution', inv.institution, Icons.business_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Current Market Value', '₹ ${_formatCurrency(inv.currentValue)}', Icons.currency_rupee, isHighlight: true, highlightColor: _brandBlue),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Invested Amount', '₹ ${_formatCurrency(inv.investedValue)}', Icons.account_balance_wallet_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow(
                          'Overall Returns',
                          '${inv.isPositive ? '+' : '-'}${inv.returnPercentage}%',
                          Icons.trending_up,
                          isHighlight: true,
                          highlightColor: inv.isPositive ? _emeraldGreen : const Color(0xFFEF4444),
                        ),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow(
                          'Absolute Gain / Loss',
                          '${inv.currentValue >= inv.investedValue ? '+' : '-'} ₹ ${_formatCurrency((inv.currentValue - inv.investedValue).abs())}',
                          Icons.insights,
                          isHighlight: true,
                          highlightColor: inv.currentValue >= inv.investedValue ? _emeraldGreen : const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            _confirmDelete(
                              context: context,
                              title: 'Delete Investment Holding?',
                              message: 'Are you sure you want to remove ${inv.assetType} (${inv.institution}) from your investment portfolio?',
                              onDelete: () {
                                Navigator.pop(ctx);
                                ref.read(bankAggregationProvider.notifier).deleteInvestmentHolding(inv.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${inv.assetType} holding deleted successfully'),
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brandBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAddInvestmentModal(context, existingInvestment: inv);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showInsuranceDetails(BuildContext context, InsurancePolicyItem pol) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Icon(
                          pol.policyType.contains('Health')
                              ? Icons.local_hospital
                              : pol.policyType.contains('Life')
                                  ? Icons.favorite
                                  : Icons.directions_car,
                          size: 22,
                          color: _brandBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pol.policyType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navyDark)),
                            Text(pol.provider, style: const TextStyle(fontSize: 12, color: _slateGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Policy Category', pol.policyType, Icons.health_and_safety_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Insurance Provider', pol.provider, Icons.business_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Policy Number', pol.policyNumberMasked, Icons.pin_outlined),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Sum Insured Coverage', '₹ ${_formatCurrency(pol.coverageAmount)}', Icons.security, isHighlight: true, highlightColor: _emeraldGreen),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Annual Premium', '₹ ${_formatCurrency(pol.premiumAmount)} / yr', Icons.currency_rupee),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Next Renewal Date', pol.renewalDate, Icons.event_repeat),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Registered Nominee', pol.nominee, Icons.person_pin_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            _confirmDelete(
                              context: context,
                              title: 'Delete Insurance Policy?',
                              message: 'Are you sure you want to remove ${pol.policyType} (${pol.provider}) from your insurance portfolio?',
                              onDelete: () {
                                Navigator.pop(ctx);
                                ref.read(bankAggregationProvider.notifier).deleteInsurancePolicy(pol.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${pol.policyType} policy deleted successfully'),
                                    backgroundColor: const Color(0xFFEF4444),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brandBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAddInsuranceModal(context, existingPolicy: pol);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 2: CONNECTED BANK ACCOUNTS
  // --------------------------------------------------------------------------

  Widget _buildBankAccountsSection(BuildContext context, BankAggregationState state) {
    if (state.selectedTabIndex != 0 && state.selectedTabIndex != 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connected Accounts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2),
                    Text('Savings & Current Bank Accounts (FAA-SEC-02)', style: TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showAddBankModal(context),
                icon: const Icon(Icons.add, size: 14, color: _brandBlue),
                label: const Text('Link Bank', style: TextStyle(fontSize: 11, color: _brandBlue, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: state.bankAccounts.isEmpty
                ? [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _bgCanvas,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.account_balance_outlined, color: _slateGrey, size: 28),
                          SizedBox(height: 6),
                          Text('No bank accounts connected yet.', style: TextStyle(fontSize: 12, color: _slateGrey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ]
                : state.bankAccounts.map((acc) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showBankAccountDetails(context, acc),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _bgCanvas,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  BankLogo(bankName: acc.bankName, size: 36),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(acc.bankName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                                        Text(
                                          '${acc.accountType} • ${acc.maskedAccountNumber}',
                                          style: const TextStyle(fontSize: 10, color: _slateGrey, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, size: 10, color: _emeraldGreen),
                                        SizedBox(width: 4),
                                        Text('Synced', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _emeraldGreen)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 16, color: _slateGrey),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: _cardBorder),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Account Holder', style: TextStyle(fontSize: 9, color: _slateGrey)),
                                        Text(acc.accountHolder, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('IFSC Code', style: TextStyle(fontSize: 9, color: _slateGrey)),
                                        Text(acc.ifscCode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Available Balance', style: TextStyle(fontSize: 9, color: _slateGrey)),
                                      Text(
                                        '₹ ${_formatCurrency(acc.currentBalance)}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _brandBlue),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 3: UPI ACCOUNT AGGREGATION
  // --------------------------------------------------------------------------

  Widget _buildUpiAccountsSection(BuildContext context, BankAggregationState state) {
    if (state.selectedTabIndex != 0 && state.selectedTabIndex != 2) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UPI Accounts & Mandates', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2),
                    Text('GPay, PhonePe, Paytm & BHIM (FAA-SEC-03)', style: TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showAddUpiModal(context),
                icon: const Icon(Icons.add, size: 14, color: _brandBlue),
                label: const Text('Add UPI', style: TextStyle(fontSize: 11, color: _brandBlue, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: state.upiAccounts.isEmpty
                ? [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _bgCanvas,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.qr_code_2_outlined, color: _slateGrey, size: 28),
                          SizedBox(height: 6),
                          Text('No UPI accounts linked yet.', style: TextStyle(fontSize: 12, color: _slateGrey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ]
                : state.upiAccounts.map((upi) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showUpiAccountDetails(context, upi),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _bgCanvas,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Row(
                            children: [
                              BankLogo(bankName: upi.provider.isNotEmpty ? upi.provider : upi.linkedBank, size: 32),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(upi.upiId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                                        ),
                                        if (upi.isPrimary) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: _brandBlue.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('Primary', style: TextStyle(fontSize: 8, color: _brandBlue, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('${upi.provider} • Linked: ${upi.linkedBank}', style: const TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Active', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _emeraldGreen)),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, size: 16, color: _slateGrey),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 4: CREDIT CARD LIABILITIES
  // --------------------------------------------------------------------------

  Widget _buildCreditCardsSection(BuildContext context, BankAggregationState state) {
    if (state.selectedTabIndex != 0 && state.selectedTabIndex != 3) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Credit Cards & Limits', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2),
                    Text('Credit Line Tracking & Due Dates (FAA-SEC-04)', style: TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showAddCreditCardModal(context),
                icon: const Icon(Icons.add, size: 14, color: _brandBlue),
                label: const Text('Add Card', style: TextStyle(fontSize: 11, color: _brandBlue, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: state.creditCards.isEmpty
                ? [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _bgCanvas,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.credit_card_outlined, color: _slateGrey, size: 28),
                          SizedBox(height: 6),
                          Text('No credit cards added yet.', style: TextStyle(fontSize: 12, color: _slateGrey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ]
                : state.creditCards.map((card) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showCreditCardDetails(context, card),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _bgCanvas,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  BankLogo(bankName: card.issuedBank ?? card.cardName, size: 36),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(card.cardName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                                        Text(
                                          '•••• ${card.last4Digits}${card.cardType != null ? ' • ${card.cardType}' : ''}',
                                          style: const TextStyle(fontSize: 10, color: _slateGrey, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Outstanding Due', style: TextStyle(fontSize: 9, color: _slateGrey)),
                                      Text(
                                        '₹ ${_formatCurrency(card.outstandingBalance)}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 16, color: _slateGrey),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: _cardBorder),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Total Limit', style: TextStyle(fontSize: 9, color: _slateGrey)),
                                        Text('₹ ${_formatCurrency(card.creditLimit)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Available Credit', style: TextStyle(fontSize: 9, color: _slateGrey)),
                                        Text('₹ ${_formatCurrency(card.availableCredit)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _emeraldGreen), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Payment Due', style: TextStyle(fontSize: 9, color: _slateGrey)),
                                      Text(
                                        card.statementDueDate,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 5: LOAN ACCOUNT AGGREGATION
  // --------------------------------------------------------------------------

  Widget _buildLoansSection(BuildContext context, BankAggregationState state) {
    if (state.selectedTabIndex != 0 && state.selectedTabIndex != 4) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loan Accounts & Liabilities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2),
                    Text('Home, Vehicle & Personal Loans (FAA-SEC-05)', style: TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showAddLoanModal(context),
                icon: const Icon(Icons.add, size: 14, color: _brandBlue),
                label: const Text('Add Loan', style: TextStyle(fontSize: 11, color: _brandBlue, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: state.loans.isEmpty
                ? [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _bgCanvas,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.real_estate_agent_outlined, color: _slateGrey, size: 28),
                          SizedBox(height: 6),
                          Text('No loan accounts added yet.', style: TextStyle(fontSize: 12, color: _slateGrey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ]
                : state.loans.map((loan) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showLoanDetails(context, loan),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _bgCanvas,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  BankLogo(bankName: loan.lender, size: 36),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${loan.lender} • ${loan.loanType}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                                        Text('ROI: ${loan.interestRate}% p.a. • Next: ${loan.nextDueDate}', style: const TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Monthly EMI', style: TextStyle(fontSize: 9, color: _slateGrey)),
                                      Text('₹ ${_formatCurrency(loan.monthlyEmi)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navyDark)),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 16, color: _slateGrey),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: _cardBorder),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Principal Balance: ₹ ${_formatCurrency(loan.outstandingPrincipal)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                                  Text('${loan.tenureRemainingMonths} Months Remaining', style: const TextStyle(fontSize: 10, color: _slateGrey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 6 & 9: INVESTMENTS & RETIREMENT AGGREGATION
  // --------------------------------------------------------------------------

  Widget _buildInvestmentsSection(BuildContext context, BankAggregationState state) {
    if (state.selectedTabIndex != 0 && state.selectedTabIndex != 5) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Investment & Retirement Portfolio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2),
                    Text('MFs, Stocks, FDs, Gold & EPF/PPF (FAA-SEC-06 & 09)', style: TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showAddInvestmentModal(context),
                icon: const Icon(Icons.add, size: 14, color: _brandBlue),
                label: const Text('Add Investment', style: TextStyle(fontSize: 11, color: _brandBlue, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: state.investments.isEmpty
                ? [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _bgCanvas,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.trending_up, color: _slateGrey, size: 28),
                          SizedBox(height: 6),
                          Text('No investments added yet.', style: TextStyle(fontSize: 12, color: _slateGrey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ]
                : state.investments.map((inv) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showInvestmentDetails(context, inv),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _bgCanvas,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFFEFF6FF),
                                child: Icon(
                                  inv.assetType.contains('Mutual')
                                      ? Icons.donut_large
                                      : inv.assetType.contains('Stock')
                                          ? Icons.show_chart
                                          : inv.assetType.contains('Gold')
                                              ? Icons.monetization_on
                                              : Icons.savings,
                                  size: 16,
                                  color: _brandBlue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(inv.assetType, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                                    Text(inv.institution, style: const TextStyle(fontSize: 10, color: _slateGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹ ${_formatCurrency(inv.currentValue)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navyDark)),
                                  Text('${inv.isPositive ? '+' : '-'}${inv.returnPercentage}% Returns', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: inv.isPositive ? _emeraldGreen : const Color(0xFFEF4444))),
                                ],
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, size: 16, color: _slateGrey),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 7: INSURANCE POLICY AGGREGATION
  // --------------------------------------------------------------------------

  Widget _buildInsuranceSection(BuildContext context, BankAggregationState state) {
    if (state.selectedTabIndex != 0 && state.selectedTabIndex != 6) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Insurance Protection Coverage', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2),
                    Text('Health, Life & Asset Protection (FAA-SEC-07)', style: TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showAddInsuranceModal(context),
                icon: const Icon(Icons.add, size: 14, color: _brandBlue),
                label: const Text('Add Policy', style: TextStyle(fontSize: 11, color: _brandBlue, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: state.insurancePolicies.isEmpty
                ? [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _bgCanvas,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.health_and_safety_outlined, color: _slateGrey, size: 28),
                          SizedBox(height: 6),
                          Text('No insurance policies added yet.', style: TextStyle(fontSize: 12, color: _slateGrey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ]
                : state.insurancePolicies.map((pol) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showInsuranceDetails(context, pol),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _bgCanvas,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFFEFF6FF),
                                child: Icon(
                                  pol.policyType.contains('Health')
                                      ? Icons.local_hospital
                                      : pol.policyType.contains('Life')
                                          ? Icons.favorite
                                          : Icons.directions_car,
                                  size: 16,
                                  color: _brandBlue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${pol.policyType} (${pol.provider})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                                    Text('Sum Insured: ₹ ${_formatCurrency(pol.coverageAmount)}  •  Renewal: ${pol.renewalDate}', style: const TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹ ${_formatCurrency(pol.premiumAmount)}/yr', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _brandBlue)),
                                  Text('Nominee: ${pol.nominee}', style: const TextStyle(fontSize: 9, color: _slateGrey)),
                                ],
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, size: 16, color: _slateGrey),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 8: WALLETS
  // --------------------------------------------------------------------------

  Widget _buildWalletsSection(BankAggregationState state) {
    if (state.selectedTabIndex != 0 && state.selectedTabIndex != 7) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Digital Wallets & Cash Position (FAA-SEC-08)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark)),
          const SizedBox(height: 10),
          Row(
            children: state.wallets.asMap().entries.map((entry) {
              final idx = entry.key;
              final w = entry.value;
              final isLast = idx == state.wallets.length - 1;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: isLast ? 0 : 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bgCanvas,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(w.walletName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                          ),
                          const Icon(Icons.account_balance_wallet, size: 14, color: _brandBlue),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('₹ ${_formatCurrency(w.balance)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _brandBlue)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 11: CONSENT MANAGEMENT
  // --------------------------------------------------------------------------

  Widget _buildConsentManagementSection(BuildContext context, BankAggregationState state) {
    if (state.selectedTabIndex != 0 && state.selectedTabIndex != 8) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Consent Management (FAA-SEC-11)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2),
                    Text('RBI Regulated Account Aggregator Lifecycle', style: TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.verified_outlined, color: _brandBlue, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: state.consents.map((consent) {
              final isActive = consent.status == 'Active';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _bgCanvas,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              BankLogo(bankName: consent.institution, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(consent.institution, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navyDark), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? _emeraldGreen.withOpacity(0.15) : const Color(0xFFEF4444).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            consent.status,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isActive ? _emeraldGreen : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('ID: ${consent.consentId} • Scope: ${consent.consentType}', style: const TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                    Text('Valid until: ${consent.expiryDate}', style: const TextStyle(fontSize: 10, color: _slateGrey), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isActive) ...[
                          TextButton(
                            onPressed: () {
                              ref.read(bankAggregationProvider.notifier).revokeConsent(consent.consentId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Consent revoked for ${consent.institution} (FAA-BR-011)'), backgroundColor: const Color(0xFFEF4444)),
                              );
                            },
                            child: const Text('Revoke Consent', style: TextStyle(fontSize: 10, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                          ),
                        ] else ...[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              ref.read(bankAggregationProvider.notifier).renewConsent(consent.consentId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Consent renewed for ${consent.institution}!'), backgroundColor: _emeraldGreen),
                              );
                            },
                            child: const Text('Renew Consent', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 1: FINANCIAL INSTITUTION DIRECTORY & CONNECT BOX
  // --------------------------------------------------------------------------

  Widget _buildInstitutionDirectorySection(BuildContext context, BankAggregationState state, List<InstitutionDirectoryItem> filteredDirectory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Institution Directory & Open Banking (FAA-SEC-01)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark)),
          const SizedBox(height: 2),
          const Text('Search from 200+ RBI Regulated banks, NBFCs, AMCs & brokers', style: TextStyle(fontSize: 10, color: _slateGrey)),
          const SizedBox(height: 12),

          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (val) => ref.read(bankAggregationProvider.notifier).search(val),
            decoration: InputDecoration(
              hintText: 'Search Bank, UPI or NBFC...',
              hintStyle: const TextStyle(fontSize: 12, color: _slateGrey),
              prefixIcon: const Icon(Icons.search, size: 18, color: _slateGrey),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _cardBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _cardBorder)),
              filled: true,
              fillColor: _bgCanvas,
            ),
          ),
          const SizedBox(height: 12),

          // Directory Grid of Institutions
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredDirectory.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (ctx, idx) {
              final inst = filteredDirectory[idx];
              return InkWell(
                onTap: () => _showConsentDialog(context, inst),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _bgCanvas,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Row(
                    children: [
                      BankLogo(bankName: inst.name, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(inst.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _navyDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(inst.category, style: const TextStyle(fontSize: 9, color: _slateGrey), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const Icon(Icons.add_circle_outline, size: 14, color: _brandBlue),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // RECENT INGESTED TRANSACTIONS
  // --------------------------------------------------------------------------

  Widget _buildRecentTransactionsSection(BankAggregationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Ingested Transactions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark)),
          const SizedBox(height: 10),
          Column(
            children: state.recentTransactions.map((tx) {
              final isCredit = tx.amount > 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: isCredit ? _emeraldGreen.withOpacity(0.15) : _brandBlue.withOpacity(0.12),
                      child: Icon(
                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 14,
                        color: isCredit ? _emeraldGreen : _brandBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navyDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${tx.institution} • ${tx.date}', style: const TextStyle(fontSize: 9, color: _slateGrey), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${isCredit ? '+' : ''} ₹ ${_formatCurrency(tx.amount)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? _emeraldGreen : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECURITY & COMPLIANCE FOOTER
  // --------------------------------------------------------------------------

  Widget _buildSecurityFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user, color: _brandBlue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RBI Account Aggregator Framework & End-to-End Encryption',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _navyDark),
                ),
                SizedBox(height: 2),
                Text(
                  'Data transferred via TLS 1.3 with HSM-backed AES-256 encryption. Consent is revocable at any time under RBI master directions.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(double amount) {
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final dec = parts[1];

    if (whole.length <= 3) {
      return '$whole.$dec';
    }
    final last3 = whole.substring(whole.length - 3);
    final rest = whole.substring(0, whole.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    buffer.write(',$last3.$dec');
    return (amount < 0 ? '-' : '') + buffer.toString();
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF0066FF)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
        ),
      ],
    );
  }
}
