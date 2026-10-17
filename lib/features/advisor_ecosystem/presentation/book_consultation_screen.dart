import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/advisor_models.dart';
import '../providers/advisor_provider.dart';

class BookConsultationScreen extends ConsumerStatefulWidget {
  final Advisor? advisor;

  const BookConsultationScreen({super.key, this.advisor});

  @override
  ConsumerState<BookConsultationScreen> createState() => _BookConsultationScreenState();
}

class _BookConsultationScreenState extends ConsumerState<BookConsultationScreen> {
  static const Color _brandBlue = Color(0xFF0066FF);
  static const Color _navyDark = Color(0xFF0A2540);
  static const Color _slateGrey = Color(0xFF64748B);
  static const Color _bgCanvas = Color(0xFFF8FAFC);
  static const Color _cardBorder = Color(0xFFE2E8F0);
  static const Color _emeraldGreen = Color(0xFF10B981);

  late Advisor _selectedAdvisor;
  String _selectedRole = 'CA Management';
  int _selectedModeIndex = 0; // 0: Video, 1: Phone, 2: Document Review
  int _selectedDateIndex = 1; // Default to Tomorrow
  String _selectedTimeSlot = '10:45 AM';
  String _selectedAgenda = '';
  String _selectedAssignment = 'Direct 1-on-1 Assigned Advisor';
  final bool _shareAiCfoReport = true;
  bool _showRatingsExpanded = false;

  late List<String> _grantedPermissions;

  final _nameController = TextEditingController(text: 'Sireesha Bandaru');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _emailController = TextEditingController(text: 'sireesha@finomos.io');
  final _notesController = TextEditingController();

  final List<String> _roles = [
    'CA Management',
    'Financial Planner Management',
    'Insurance Advisor Management',
    'Investment Advisor Management',
  ];

  final List<Map<String, dynamic>> _modes = [
    {
      'title': '1-on-1 Video Session',
      'subtitle': 'Google Meet HD with screen share',
      'icon': Icons.videocam_outlined,
      'duration': '45 Mins',
    },
    {
      'title': 'Direct Phone Call',
      'subtitle': 'Private secure audio consultation',
      'icon': Icons.phone_in_talk_outlined,
      'duration': '30 Mins',
    },
    {
      'title': 'Document / Notice Audit',
      'subtitle': 'ITR, notice or portfolio report review',
      'icon': Icons.description_outlined,
      'duration': 'Async + 20 Min Call',
    },
  ];

  late final List<DateTime> _dates;

  final List<String> _morningSlots = ['09:30 AM', '10:45 AM', '11:30 AM'];
  final List<String> _afternoonSlots = ['02:00 PM', '03:15 PM', '04:30 PM'];
  final List<String> _eveningSlots = ['06:00 PM', '07:15 PM', '08:30 PM'];

  @override
  void initState() {
    super.initState();
    _dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
    final allAdvisors = ref.read(advisorProvider).advisors;
    _selectedAdvisor = widget.advisor ?? (allAdvisors.isNotEmpty ? allAdvisors.first : Advisor(
      id: 'a1',
      name: 'CA Rajesh Sharma',
      title: 'Senior Tax & Capital Gains Consultant',
      category: 'Chartered Accountant',
      role: 'CA Management',
      experience: '14+ Years Exp',
      rating: 4.9,
      consultationFee: 1499,
      isVerified: 'SEBI & ICAI Verified',
      registrationNumber: 'ICAI-MRN-492810',
    ));
    _selectedRole = _selectedAdvisor.role;
    _grantedPermissions = List.from(_selectedAdvisor.permissionsOffered);
    if (_selectedAdvisor.specializations.isNotEmpty) {
      _selectedAgenda = _selectedAdvisor.specializations.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDatePill(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _getDateBadge(int index) {
    if (index == 0) return 'Today';
    if (index == 1) return 'Tomorrow';
    return '';
  }

  void _onRoleChanged(String newRole) {
    setState(() {
      _selectedRole = newRole;
      final allAdvisors = ref.read(advisorProvider).advisors;
      final matching = allAdvisors.where((a) => a.role == newRole).toList();
      if (matching.isNotEmpty && !matching.contains(_selectedAdvisor)) {
        _selectedAdvisor = matching.first;
        _grantedPermissions = List.from(_selectedAdvisor.permissionsOffered);
        if (_selectedAdvisor.specializations.isNotEmpty) {
          _selectedAgenda = _selectedAdvisor.specializations.first;
        }
      }
    });
  }

  void _confirmAndBookSession() {
    final clientName = _nameController.text.trim();
    final clientPhone = _phoneController.text.trim();
    if (clientName.isEmpty || clientPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your name and contact phone number.')),
      );
      return;
    }

    final chosenDate = _dates[_selectedDateIndex];
    final dateStr = _formatDatePill(chosenDate);
    final bookingId = 'FNM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final fee = _selectedAdvisor.consultationFee;
    const discount = 150.0;
    final total = fee > discount ? (fee - discount) : fee;

    final booking = ConsultationBooking(
      bookingId: bookingId,
      advisorId: _selectedAdvisor.id,
      advisorName: _selectedAdvisor.name,
      advisorTitle: _selectedAdvisor.title,
      selectedRole: _selectedRole,
      date: dateStr,
      timeSlot: _selectedTimeSlot,
      consultationMode: _modes[_selectedModeIndex]['title'] as String,
      agenda: _selectedAgenda.isNotEmpty ? _selectedAgenda : 'General Financial Consultation',
      clientName: clientName,
      clientPhone: clientPhone,
      clientEmail: _emailController.text.trim(),
      notes: _notesController.text.trim(),
      shareAiCfoReport: _shareAiCfoReport,
      grantedPermissions: _grantedPermissions,
      assignmentType: _selectedAssignment,
      amountPaid: total,
      meetLink: 'https://meet.google.com/fnm-adv-${_selectedAdvisor.id}',
      createdAt: DateTime.now(),
    );

    ref.read(advisorProvider.notifier).bookConsultation(booking);
    _showBookingSuccessDialog(booking);
  }

  void _showBookingSuccessDialog(ConsultationBooking booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: _emeraldGreen, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Consultation Confirmed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _navyDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Booking ID: ${booking.bookingId}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _slateGrey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: _brandBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${booking.advisorName} (${booking.selectedRole})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _navyDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.event, size: 16, color: _brandBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${booking.date} at ${booking.timeSlot}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _navyDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.assignment_ind_outlined, size: 16, color: Color(0xFF8B5CF6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.assignmentType,
                          style: const TextStyle(fontSize: 12, color: _slateGrey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.security, size: 16, color: _emeraldGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${booking.grantedPermissions.length} Data Scopes Granted (48h Expiry)',
                          style: const TextStyle(fontSize: 11, color: _emeraldGreen, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16, color: _brandBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.meetLink,
                      style: const TextStyle(fontSize: 11, color: _brandBlue, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: _brandBlue),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Meeting link copied to clipboard!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Meeting added to Google & Apple Calendar!')),
                      );
                    },
                    child: const Text('Add to Calendar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pop();
                    },
                    child: const Text('Done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allAdvisors = ref.watch(advisorProvider).advisors;
    final fee = _selectedAdvisor.consultationFee;
    const discount = 150.0;
    final total = fee > discount ? (fee - discount) : fee;

    return Scaffold(
      backgroundColor: _bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _navyDark),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Book 1-on-1 Consultation',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _navyDark,
              ),
            ),
            Text(
              '${_selectedAdvisor.name} • ${_selectedAdvisor.role}',
              style: const TextStyle(fontSize: 11, color: _slateGrey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Role Selection Tabs
            _buildSectionHeader('1. Select Advisory Role', Icons.category_outlined),
            const SizedBox(height: 10),
            _buildRoleSelector(),
            const SizedBox(height: 16),

            // 2. Advisor Profile Card
            _buildAdvisorProfileCard(allAdvisors),
            const SizedBox(height: 14),

            // 3. Advisor Verification & Regulatory Credentials
            _buildVerificationCard(),
            const SizedBox(height: 14),

            // 4. Advisor Ratings & Client Feedback
            _buildRatingsScorecard(),
            const SizedBox(height: 18),

            // 5. Select Consultation Mode
            _buildSectionHeader('2. Consultation Mode', Icons.devices_outlined),
            const SizedBox(height: 10),
            _buildModeSelector(),
            const SizedBox(height: 18),

            // 6. Select Date
            _buildSectionHeader('3. Appointment Date', Icons.calendar_month_outlined),
            const SizedBox(height: 10),
            _buildDateSelector(),
            const SizedBox(height: 18),

            // 7. Select Time Slot
            _buildSectionHeader('4. Time Slot (IST)', Icons.access_time_outlined),
            const SizedBox(height: 10),
            _buildTimeSlotSelector(),
            const SizedBox(height: 18),

            // 8. Consultation Topic / Agenda
            _buildSectionHeader('5. Consultation Agenda & Focus', Icons.psychology_outlined),
            const SizedBox(height: 10),
            _buildAgendaSelector(),
            const SizedBox(height: 18),

            // 9. Advisor Access Permissions
            _buildSectionHeader('6. Advisor Access Permissions (Data Governance)', Icons.security_rounded),
            const SizedBox(height: 10),
            _buildPermissionsCard(),
            const SizedBox(height: 18),

            // 10. Client Assignment Protocol
            _buildSectionHeader('7. Client Assignment Protocol', Icons.person_pin_circle_rounded),
            const SizedBox(height: 10),
            _buildAssignmentProtocolCard(),
            const SizedBox(height: 18),

            // 11. Client Details
            _buildSectionHeader('8. Client Information', Icons.person_outline),
            const SizedBox(height: 10),
            _buildClientInfoFields(),
            const SizedBox(height: 18),

            // 12. Fee & Price Breakdown Card
            _buildPaymentSummaryCard(fee, discount, total),
            const SizedBox(height: 20),

            // 13. Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: _confirmAndBookSession,
                child: Text(
                  'Confirm & Book 1-on-1 Session • ₹${total.toInt()}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '100% Satisfaction Guarantee • Full refund if cancelled 2 hrs before session',
                style: TextStyle(fontSize: 10, color: _slateGrey, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 17, color: _brandBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _navyDark),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _roles.map((role) {
          final isSelected = _selectedRole == role;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(role.replaceAll(' Management', '')),
              selected: isSelected,
              selectedColor: _brandBlue,
              backgroundColor: Colors.white,
              side: BorderSide(color: isSelected ? _brandBlue : _cardBorder),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : _navyDark,
              ),
              onSelected: (selected) {
                if (selected) _onRoleChanged(role);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdvisorProfileCard(List<Advisor> allAdvisors) {
    final matchingAdvisors = allAdvisors.where((a) => a.role == _selectedRole).toList();
    final dropdownAdvisors = matchingAdvisors.isNotEmpty ? matchingAdvisors : allAdvisors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _brandBlue.withOpacity(0.12),
                child: Text(
                  _selectedAdvisor.name.substring(0, 2),
                  style: const TextStyle(color: _brandBlue, fontWeight: FontWeight.bold, fontSize: 16),
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
                            _selectedAdvisor.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _navyDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Color(0xFFD97706), size: 14),
                              const SizedBox(width: 3),
                              Text(
                                '${_selectedAdvisor.rating} (${_selectedAdvisor.reviewsCount})',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedAdvisor.title,
                      style: const TextStyle(fontSize: 11, color: _slateGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildPillBadge(_selectedAdvisor.role, _brandBlue),
              _buildPillBadge(_selectedAdvisor.isVerified, _emeraldGreen),
              _buildPillBadge(_selectedAdvisor.experience, const Color(0xFF8B5CF6)),
              _buildPillBadge(_selectedAdvisor.languages, const Color(0xFF0D9488)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _selectedAdvisor.bio,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.4),
          ),
          if (dropdownAdvisors.length > 1) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: _cardBorder),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Switch Specialist:', style: TextStyle(fontSize: 11, color: _slateGrey, fontWeight: FontWeight.w500)),
                DropdownButton<String>(
                  value: _selectedAdvisor.id,
                  isDense: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: _brandBlue, size: 20),
                  items: dropdownAdvisors.map((adv) => DropdownMenuItem(
                    value: adv.id,
                    child: Text(adv.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navyDark)),
                  )).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      setState(() {
                        _selectedAdvisor = dropdownAdvisors.firstWhere((a) => a.id == id);
                        _selectedRole = _selectedAdvisor.role;
                        _grantedPermissions = List.from(_selectedAdvisor.permissionsOffered);
                        if (_selectedAdvisor.specializations.isNotEmpty) {
                          _selectedAgenda = _selectedAdvisor.specializations.first;
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: _emeraldGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Advisor Verification Details',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _emeraldGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('AUDITED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Registration ID: ', style: TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.w600)),
              Text(_selectedAdvisor.registrationNumber, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _navyDark)),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Text('Authority: ', style: TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.w600)),
              Text(_selectedAdvisor.verificationAgency, style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.w600)),
              Text(_selectedAdvisor.verificationStatus, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _emeraldGreen)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsScorecard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _showRatingsExpanded = !_showRatingsExpanded),
            child: Row(
              children: [
                const Icon(Icons.star_rate_rounded, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Advisor Ratings (${_selectedAdvisor.rating} / 5.0)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _navyDark),
                ),
                const Spacer(),
                Text(
                  _showRatingsExpanded ? 'Hide Reviews' : 'View Reviews (${_selectedAdvisor.reviews.length})',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _brandBlue),
                ),
                Icon(
                  _showRatingsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: _brandBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _selectedAdvisor.ratingBreakdown.entries.map((entry) {
              return Column(
                children: [
                  Text(
                    '${entry.value}★',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 9.5, color: _slateGrey),
                  ),
                ],
              );
            }).toList(),
          ),
          if (_showRatingsExpanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: _cardBorder),
            const SizedBox(height: 10),
            for (final rev in _selectedAdvisor.reviews)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rev['client'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _navyDark)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 12),
                            const SizedBox(width: 2),
                            Text(rev['rating'] ?? '5.0', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _navyDark)),
                            const SizedBox(width: 6),
                            Text(rev['time'] ?? '', style: const TextStyle(fontSize: 10, color: _slateGrey)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(rev['comment'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Select Financial Records to Share:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navyDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final perm in _selectedAdvisor.permissionsOffered)
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: _brandBlue,
              title: Text(perm, style: const TextStyle(fontSize: 12, color: _navyDark)),
              value: _grantedPermissions.contains(perm),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    if (!_grantedPermissions.contains(perm)) _grantedPermissions.add(perm);
                  } else {
                    _grantedPermissions.remove(perm);
                  }
                });
              },
            ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Icon(Icons.timer_outlined, size: 14, color: _slateGrey),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Encrypted view-only access automatically expires 48 hours after consultation.',
                  style: TextStyle(fontSize: 10, color: _slateGrey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentProtocolCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final opt in _selectedAdvisor.assignmentOptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedAssignment = opt),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _selectedAssignment == opt ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedAssignment == opt ? _brandBlue : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedAssignment == opt ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: _selectedAssignment == opt ? _brandBlue : _slateGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _selectedAssignment == opt ? FontWeight.bold : FontWeight.w500,
                            color: _selectedAssignment == opt ? _navyDark : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPillBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      children: List.generate(_modes.length, (index) {
        final mode = _modes[index];
        final isSelected = _selectedModeIndex == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => setState(() => _selectedModeIndex = index),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? _brandBlue : _cardBorder,
                  width: isSelected ? 1.6 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    mode['icon'] as IconData,
                    color: isSelected ? _brandBlue : _slateGrey,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? _navyDark : const Color(0xFF334155),
                          ),
                        ),
                        Text(
                          mode['subtitle'] as String,
                          style: const TextStyle(fontSize: 10.5, color: _slateGrey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected ? _brandBlue : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      mode['duration'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : _slateGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 74,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = _selectedDateIndex == index;
          final badge = _getDateBadge(index);
          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedDateIndex = index),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 66,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _brandBlue : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? _brandBlue : _cardBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: _brandBlue.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 3))]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (badge.isNotEmpty)
                      Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFFBAE6FD) : _brandBlue,
                        ),
                      )
                    else
                      Text(
                        days[date.weekday - 1],
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white70 : _slateGrey,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : _navyDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeCategory('Morning', Icons.wb_sunny_outlined, _morningSlots),
          const SizedBox(height: 12),
          _buildTimeCategory('Afternoon', Icons.wb_twilight_outlined, _afternoonSlots),
          const SizedBox(height: 12),
          _buildTimeCategory('Evening', Icons.nightlight_outlined, _eveningSlots),
        ],
      ),
    );
  }

  Widget _buildTimeCategory(String label, IconData icon, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _slateGrey),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _slateGrey)),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              selectedColor: _brandBlue,
              backgroundColor: const Color(0xFFF8FAFC),
              side: BorderSide(color: isSelected ? _brandBlue : const Color(0xFFE2E8F0)),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : _navyDark,
              ),
              onSelected: (selected) {
                if (selected) setState(() => _selectedTimeSlot = slot);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAgendaSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select primary objective:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _slateGrey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedAdvisor.specializations.map((spec) {
              final isSelected = _selectedAgenda == spec;
              return ChoiceChip(
                label: Text(spec),
                selected: isSelected,
                selectedColor: const Color(0xFF0A2540),
                backgroundColor: const Color(0xFFF1F5F9),
                side: BorderSide(color: isSelected ? _navyDark : Colors.transparent),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedAgenda = spec);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 2,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Specific questions or details for the advisor (optional)...',
              hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _cardBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _cardBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brandBlue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfoFields() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          _buildTextField('Full Name', _nameController, Icons.person_outline),
          const SizedBox(height: 10),
          _buildTextField('WhatsApp / Phone Number', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          _buildTextField('Email Address (for calendar invite)', _emailController, Icons.mail_outline, keyboardType: TextInputType.emailAddress),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _navyDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: _slateGrey),
        prefixIcon: Icon(icon, size: 18, color: _brandBlue),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brandBlue)),
      ),
    );
  }

  Widget _buildPaymentSummaryCard(double fee, double discount, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fee Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _navyDark)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('1-on-1 Consultation Fee', style: TextStyle(fontSize: 12, color: _slateGrey)),
              Text('₹${fee.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _navyDark)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Platform Assurance & Secure Meet', style: TextStyle(fontSize: 12, color: _slateGrey)),
              Text('FREE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _emeraldGreen)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Finomos AI CFO Member Discount', style: TextStyle(fontSize: 12, color: _emeraldGreen, fontWeight: FontWeight.w600)),
              Text('-₹${discount.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _emeraldGreen)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _cardBorder),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Payable Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _navyDark)),
              Text(
                '₹${total.toInt()}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _brandBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
