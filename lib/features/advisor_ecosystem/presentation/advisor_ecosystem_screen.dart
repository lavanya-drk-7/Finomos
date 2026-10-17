import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../providers/advisor_provider.dart';

class AdvisorEcosystemScreen extends ConsumerStatefulWidget {
  const AdvisorEcosystemScreen({super.key});

  @override
  ConsumerState<AdvisorEcosystemScreen> createState() => _AdvisorEcosystemScreenState();
}

class _AdvisorEcosystemScreenState extends ConsumerState<AdvisorEcosystemScreen> {
  static const Color _brandBlue = Color(0xFF0066FF);
  static const Color _navyDark = Color(0xFF0A2540);
  static const Color _emeraldGreen = Color(0xFF10B981);
  static const Color _slateGrey = Color(0xFF64748B);

  String _selectedRole = 'All';
  double _minRating = 0.0;

  final Set<String> _selectedPermissions = {
    'AIS & Form 26AS Tax Returns',
    'Bank Aggregation Statements',
    'AI CFO Balance Sheet & Net Worth',
    'Document Vault Identity Records',
  };

  final List<Map<String, String>> _permissionOptions = [
    {
      'title': 'AIS & Form 26AS Tax Returns',
      'desc': 'Grants view-only access to tax summary and withholding receipts.',
    },
    {
      'title': 'Bank Aggregation Statements',
      'desc': 'Shares aggregated account balances without credentials.',
    },
    {
      'title': 'AI CFO Balance Sheet & Net Worth',
      'desc': 'Allows advisor to view asset/liability allocation breakdown.',
    },
    {
      'title': 'Document Vault Identity Records',
      'desc': 'Passports, Aadhaar & PAN document images for compliance verification.',
    },
  ];

  String _selectedAssignmentProtocol = 'Direct 1-on-1 Assigned Advisor';

  final List<Map<String, String>> _assignmentOptions = [
    {
      'title': 'Direct 1-on-1 Assigned Advisor',
      'desc': 'You manually pick and schedule with your preferred specialist.',
    },
    {
      'title': 'AI CFO Smart Match (Instant)',
      'desc': 'Algorithmic matching to highest rated available advisor for urgent tax notices.',
    },
    {
      'title': 'Quarterly Advisory Board Retainer',
      'desc': 'Dedicated CA + CFP team handling continuous tax and wealth management.',
    },
  ];

  final List<String> _roleFilters = [
    'All',
    'CA Management',
    'Financial Planner Management',
    'Insurance Advisor Management',
    'Investment Advisor Management',
  ];

  @override
  Widget build(BuildContext context) {
    final advisorState = ref.watch(advisorProvider);

    final filteredAdvisors = advisorState.advisors.where((adv) {
      final matchesRole = _selectedRole == 'All' || adv.role == _selectedRole;
      final matchesRating = adv.rating >= _minRating;
      return matchesRole && matchesRating;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _navyDark),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
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
                    'Advisor Ecosystem',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: _navyDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Human + AI Expert Marketplace',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _emeraldGreen),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_navyDark, _brandBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Personal Financial Board', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                  'Connect your AI Personal CFO with verified CAs, CFP Wealth Planners, and Insurance Advisors with zero paperwork friction.',
                  style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),

          // Active Consultations
          if (advisorState.bookings.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Consultations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _navyDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _emeraldGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${advisorState.bookings.length} Confirmed',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _emeraldGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final booking in advisorState.bookings)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _emeraldGreen.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(color: _emeraldGreen.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _brandBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.videocam_rounded, color: _brandBlue, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.advisorName,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _navyDark),
                              ),
                              Text(
                                '${booking.dateFormatted} • ${booking.timeSlot} (${booking.selectedRole})',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _brandBlue),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _emeraldGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            booking.status,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _emeraldGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link_rounded, size: 16, color: _slateGrey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              booking.meetLink,
                              style: const TextStyle(fontSize: 11, color: _brandBlue, decoration: TextDecoration.underline),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'Agenda: ${booking.agenda}',
                            style: const TextStyle(fontSize: 11, color: _slateGrey, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],

          const SizedBox(height: 20),

          // 4 Governance Tools Grid
          Row(
            children: const [
              Text(
                'Advisory Management & Controls',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildControlCard(
                  icon: Icons.verified_user_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Advisor Verification',
                  subtitle: 'ICAI / SEBI Badges',
                  onTap: () => _showVerificationSheet(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildControlCard(
                  icon: Icons.security_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Access Permissions',
                  subtitle: 'Data Sharing Scopes',
                  onTap: () => _showPermissionsSheet(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildControlCard(
                  icon: Icons.person_pin_circle_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Client Assignment',
                  subtitle: 'Direct / Smart Match',
                  onTap: () => _showAssignmentSheet(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildControlCard(
                  icon: Icons.star_rate_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Advisor Ratings',
                  subtitle: '4.8+ Verified Reviews',
                  onTap: () => _showRatingsSheet(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Role Filter Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Advisory Role',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark),
              ),
              if (_selectedRole != 'All' || _minRating > 0)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = 'All';
                      _minRating = 0.0;
                    });
                  },
                  child: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _brandBlue)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _roleFilters.map((role) {
                final isSelected = _selectedRole == role;
                final label = role == 'All' ? 'All Roles' : role.replaceAll(' Management', '');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: _brandBlue,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: isSelected ? _brandBlue : const Color(0xFFE2E8F0)),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : _navyDark,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedRole = role;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Section Title
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedRole == 'All' ? 'Verified Experts Marketplace' : '$_selectedRole Specialists',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navyDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${filteredAdvisors.length} Available',
                style: const TextStyle(fontSize: 12, color: _slateGrey, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Advisors List
          for (final adv in filteredAdvisors)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.push('/book-consultation', extra: adv);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: _brandBlue.withOpacity(0.1),
                              child: Text(
                                adv.name.substring(0, 2),
                                style: const TextStyle(color: _brandBlue, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          adv.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _navyDark),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${adv.rating}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _navyDark),
                                          ),
                                          Text(
                                            ' (${adv.reviewsCount})',
                                            style: const TextStyle(fontSize: 11, color: _slateGrey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(adv.title, style: const TextStyle(fontSize: 12, color: _slateGrey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _brandBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                adv.role,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _brandBlue),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _emeraldGreen.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${adv.registrationNumber} • ${adv.isVerified}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _emeraldGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              adv.experience,
                              style: const TextStyle(fontSize: 12, color: _slateGrey, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '₹${adv.consultationFee.toInt()} / Session',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _brandBlue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _brandBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              context.push('/book-consultation', extra: adv);
                            },
                            child: const Text('Book 1-on-1 Consultation', style: TextStyle(color: _brandBlue, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navyDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 10, color: _slateGrey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.verified_user_rounded, color: _emeraldGreen, size: 24),
                SizedBox(width: 10),
                Text('Advisor Verification Registry', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _navyDark)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'All advisors listed on Finomos are verified against statutory government registers before onboarding.',
              style: TextStyle(fontSize: 13, color: _slateGrey, height: 1.4),
            ),
            const SizedBox(height: 16),
            _buildVerificationItem(
              title: 'ICAI Chartered Accountants',
              regText: 'Verified via ICAI Membership Registry (COP & UDIN Validation)',
              authority: 'ICAI & CBDT',
              status: '100% Active & Verified',
            ),
            _buildVerificationItem(
              title: 'SEBI Registered Investment Advisors (RIA)',
              regText: 'Fee-only Fiduciary Registration & Compliance Audits',
              authority: 'SEBI (Securities & Exchange Board of India)',
              status: 'NISM Certified & Audited',
            ),
            _buildVerificationItem(
              title: 'IRDAI Insurance Advisors',
              regText: 'Individual & Corporate Broker License Verification',
              authority: 'IRDAI Regulatory Portal',
              status: 'Clean Disciplinary Record',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navyDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close Verification Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationItem({
    required String title,
    required String regText,
    required String authority,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
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
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _navyDark),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _emeraldGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _emeraldGreen)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(regText, style: const TextStyle(fontSize: 11, color: _slateGrey)),
          const SizedBox(height: 2),
          Text('Regulator: $authority', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _brandBlue)),
        ],
      ),
    );
  }

  void _showPermissionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.security_rounded, color: _brandBlue, size: 24),
                  SizedBox(width: 10),
                  Text('Advisor Access Permissions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _navyDark)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Control what data is shared with your advisor during the 1-on-1 session. Data access automatically expires 48 hours after consultation.',
                style: TextStyle(fontSize: 13, color: _slateGrey, height: 1.4),
              ),
              const SizedBox(height: 16),
              for (final p in _permissionOptions)
                _buildPermissionItem(
                  title: p['title']!,
                  desc: p['desc']!,
                  isEnabled: _selectedPermissions.contains(p['title']),
                  onTap: () {
                    setSheetState(() {
                      if (_selectedPermissions.contains(p['title'])) {
                        _selectedPermissions.remove(p['title']);
                      } else {
                        _selectedPermissions.add(p['title']!);
                      }
                    });
                    setState(() {});
                  },
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated permissions: ${_selectedPermissions.length} active data scopes.')),
                    );
                  },
                  child: const Text('Save Permission Defaults', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required String title,
    required String desc,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isEnabled ? const Color(0xFF10B981).withOpacity(0.05) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isEnabled ? _emeraldGreen : const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  isEnabled ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: isEnabled ? _emeraldGreen : _slateGrey,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _navyDark)),
                      const SizedBox(height: 2),
                      Text(desc, style: const TextStyle(fontSize: 11, color: _slateGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAssignmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.person_pin_circle_rounded, color: Color(0xFF8B5CF6), size: 24),
                  SizedBox(width: 10),
                  Text('Client Assignment Protocols', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _navyDark)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Select how Finomos assigns advisors to your financial board. You can switch models anytime.',
                style: TextStyle(fontSize: 13, color: _slateGrey, height: 1.4),
              ),
              const SizedBox(height: 16),
              for (final a in _assignmentOptions)
                _buildAssignmentItem(
                  title: a['title']!,
                  desc: a['desc']!,
                  isSelected: _selectedAssignmentProtocol == a['title'],
                  onTap: () {
                    setSheetState(() {
                      _selectedAssignmentProtocol = a['title']!;
                    });
                    setState(() {});
                  },
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navyDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Protocol updated to: $_selectedAssignmentProtocol')),
                    );
                  },
                  child: const Text('Update Assignment Preference', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentItem({
    required String title,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.08) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE2E8F0), width: isSelected ? 1.6 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF8B5CF6) : _slateGrey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _navyDark)),
                      const SizedBox(height: 2),
                      Text(desc, style: const TextStyle(fontSize: 11, color: _slateGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRatingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.star_rate_rounded, color: Color(0xFFF59E0B), size: 24),
                SizedBox(width: 10),
                Text('Advisor Ratings & Reviews', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _navyDark)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('4.9', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Platform Advisory Average', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _navyDark)),
                        Text('Based on 620+ completed 1-on-1 consultations with verified Finomos members.', style: TextStyle(fontSize: 11, color: _slateGrey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Filter Experts by Minimum Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _navyDark)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _minRating == 0.0 ? _brandBlue : Colors.white,
                      side: BorderSide(color: _minRating == 0.0 ? _brandBlue : const Color(0xFFE2E8F0)),
                    ),
                    onPressed: () {
                      setState(() => _minRating = 0.0);
                      Navigator.pop(ctx);
                    },
                    child: Text('All Ratings', style: TextStyle(color: _minRating == 0.0 ? Colors.white : _navyDark, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _minRating == 4.8 ? _brandBlue : Colors.white,
                      side: BorderSide(color: _minRating == 4.8 ? _brandBlue : const Color(0xFFE2E8F0)),
                    ),
                    onPressed: () {
                      setState(() => _minRating = 4.8);
                      Navigator.pop(ctx);
                    },
                    child: Text('★ 4.8 & Above', style: TextStyle(color: _minRating == 4.8 ? Colors.white : _navyDark, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _minRating == 4.9 ? _brandBlue : Colors.white,
                      side: BorderSide(color: _minRating == 4.9 ? _brandBlue : const Color(0xFFE2E8F0)),
                    ),
                    onPressed: () {
                      setState(() => _minRating = 4.9);
                      Navigator.pop(ctx);
                    },
                    child: Text('★ 4.9 Only', style: TextStyle(color: _minRating == 4.9 ? Colors.white : _navyDark, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
