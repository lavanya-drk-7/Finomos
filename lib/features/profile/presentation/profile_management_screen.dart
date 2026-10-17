import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../../core/widgets/finmos_user_avatar.dart';
import '../../../core/widgets/finmos_kyc_badge.dart';
import '../../../core/widgets/bank_logo.dart';
import '../domain/profile_models.dart';
import '../providers/profile_provider.dart';

/// Full Profile Dashboard for Finomos - Personal Financial Operating System (PFOS)
/// and AI Personal CFO Platform.
///
/// Structures user identity, household management, 7 financial pillars
/// (Earn, Spend, Protect, Borrow, Grow, Plan, Comply), account aggregation,
/// and AI Autopilot controls.
class ProfileManagementScreen extends ConsumerStatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  ConsumerState<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends ConsumerState<ProfileManagementScreen> {
  int _selectedFilterIndex = 0;

  static const List<String> _filterCategories = [
    'All Modules',
    'User & Family',
    '7 Pillars of PFOS',
    'Accounts Aggregation',
    'AI CFO & Autopilot',
    'Vault & Security',
  ];

  void _showEditPersonalDialog(BuildContext context, PersonalInfo info) {
    final nameCtrl = TextEditingController(text: info.fullName);
    final emailCtrl = TextEditingController(text: info.email);
    final phoneCtrl = TextEditingController(text: info.mobileNumber);
    final dobCtrl = TextEditingController(text: info.dob);
    final panCtrl = TextEditingController(text: info.panNumber);
    final aadhaarCtrl = TextEditingController(text: info.aadhaarNumber);

    const genders = ['Female', 'Male', 'Other'];
    String selectedGender = genders.contains(info.gender) ? info.gender : 'Female';

    const maritalStatuses = ['Married', 'Single', 'Divorced', 'Widowed'];
    String selectedMarital = maritalStatuses.contains(info.maritalStatus) ? info.maritalStatus : 'Married';

    const nationalities = ['Indian', 'NRI', 'Other'];
    String selectedNationality = nationalities.contains(info.nationality) ? info.nationality : 'Indian';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
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
                    const Text(
                      'Edit Personal & Regulatory Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dobCtrl,
                      decoration: const InputDecoration(labelText: 'Date of Birth', prefixIcon: Icon(Icons.calendar_today_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: panCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'PAN Number (Mandatory)', prefixIcon: Icon(Icons.credit_card)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: aadhaarCtrl,
                      decoration: const InputDecoration(labelText: 'Aadhaar (Optional/Masked)', prefixIcon: Icon(Icons.badge_outlined)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc_outlined)),
                      items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedGender = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedMarital,
                      decoration: const InputDecoration(labelText: 'Marital Status', prefixIcon: Icon(Icons.family_restroom_outlined)),
                      items: maritalStatuses.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedMarital = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedNationality,
                      decoration: const InputDecoration(labelText: 'Nationality', prefixIcon: Icon(Icons.flag_outlined)),
                      items: nationalities.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedNationality = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ref.read(profileProvider.notifier).updatePersonalInfo(
                                info.copyWith(
                                  fullName: nameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  mobileNumber: phoneCtrl.text.trim(),
                                  dob: dobCtrl.text.trim(),
                                  panNumber: panCtrl.text.trim().toUpperCase(),
                                  aadhaarNumber: aadhaarCtrl.text.trim(),
                                  gender: selectedGender,
                                  maritalStatus: selectedMarital,
                                  nationality: selectedNationality,
                                ),
                              );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Personal profile updated!'), backgroundColor: Color(0xFF10B981)),
                          );
                        },
                        child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _showEditEmploymentDialog(BuildContext context, EmploymentIncomeInfo info) {
    final companyCtrl = TextEditingController(text: info.companyName);
    final desigCtrl = TextEditingController(text: info.designation);
    final expCtrl = TextEditingController(text: info.workExperience);
    final annualCtrl = TextEditingController(text: info.annualIncome);
    final monthlyCtrl = TextEditingController(text: info.monthlyIncome);

    const types = ['Salaried', 'Self-Employed', 'Business Owner', 'Freelancer', 'Retired'];
    String selectedType = types.contains(info.employmentType) ? info.employmentType : 'Salaried';

    const sources = ['Salary & Bonus', 'Business Profit', 'Professional Fees', 'Rental & Investment', 'Multiple Streams'];
    String selectedSource = sources.contains(info.sourceOfIncome) ? info.sourceOfIncome : 'Salary & Bonus';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
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
                    const Text('Edit Employment & Income Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Employment Type', prefixIcon: Icon(Icons.work_outline)),
                      items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: companyCtrl,
                      decoration: const InputDecoration(labelText: 'Company / Organization', prefixIcon: Icon(Icons.business_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: desigCtrl,
                      decoration: const InputDecoration(labelText: 'Designation / Role', prefixIcon: Icon(Icons.badge_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: expCtrl,
                      decoration: const InputDecoration(labelText: 'Work Experience', prefixIcon: Icon(Icons.timeline_outlined)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSource,
                      decoration: const InputDecoration(labelText: 'Source of Income', prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
                      items: sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedSource = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: annualCtrl,
                      decoration: const InputDecoration(labelText: 'Annual Income', prefixIcon: Icon(Icons.currency_rupee)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: monthlyCtrl,
                      decoration: const InputDecoration(labelText: 'Monthly Inflow', prefixIcon: Icon(Icons.payments_outlined)),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ref.read(profileProvider.notifier).updateEmploymentInfo(
                                info.copyWith(
                                  employmentType: selectedType,
                                  companyName: companyCtrl.text.trim(),
                                  designation: desigCtrl.text.trim(),
                                  workExperience: expCtrl.text.trim(),
                                  sourceOfIncome: selectedSource,
                                  annualIncome: annualCtrl.text.trim(),
                                  monthlyIncome: monthlyCtrl.text.trim(),
                                ),
                              );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Employment information updated!'), backgroundColor: Color(0xFF10B981)),
                          );
                        },
                        child: const Text('Save Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _showAddFamilyMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String selectedRelation = 'Spouse';
    bool isDependent = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
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
                    const Text('Add Family Member / Dependent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Member Full Name', prefixIcon: Icon(Icons.person_add_alt_1_outlined)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRelation,
                      decoration: const InputDecoration(labelText: 'Relationship', prefixIcon: Icon(Icons.group_outlined)),
                      items: const [
                        DropdownMenuItem(value: 'Spouse', child: Text('Spouse')),
                        DropdownMenuItem(value: 'Child', child: Text('Child')),
                        DropdownMenuItem(value: 'Parent', child: Text('Parent')),
                        DropdownMenuItem(value: 'Dependent', child: Text('Other Dependent')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedRelation = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake_outlined)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Financial Dependent', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0A2540))),
                        Switch(
                          value: isDependent,
                          activeThumbColor: const Color(0xFF0066FF),
                          onChanged: (val) => setSheetState(() => isDependent = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) return;
                          final newMember = FamilyMember(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: nameCtrl.text.trim(),
                            relation: selectedRelation,
                            age: int.tryParse(ageCtrl.text.trim()) ?? 0,
                            isDependent: isDependent,
                          );
                          ref.read(profileProvider.notifier).addFamilyMember(newMember);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Family member added!'), backgroundColor: Color(0xFF10B981)),
                          );
                        },
                        child: const Text('Add Member', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _showEditAddressDialog(BuildContext context, AddressInfo info) {
    final resCtrl = TextEditingController(text: info.residentialAddress);
    final permCtrl = TextEditingController(text: info.permanentAddress);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
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
                const Text('Edit Residential & Permanent Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                const SizedBox(height: 14),
                TextField(
                  controller: resCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Residential Address', prefixIcon: Icon(Icons.home_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: permCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Permanent Address', prefixIcon: Icon(Icons.business_outlined)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ref.read(profileProvider.notifier).updateAddressInfo(
                            info.copyWith(
                              residentialAddress: resCtrl.text.trim(),
                              permanentAddress: permCtrl.text.trim(),
                            ),
                          );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address details updated!'), backgroundColor: Color(0xFF10B981)),
                      );
                    },
                    child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(profileProvider);
    final personal = profileData.personalInfo;
    final address = profileData.addressInfo;
    final employment = profileData.employmentInfo;
    final security = profileData.securitySettings;
    final prefs = profileData.communicationPrefs;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 0,
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
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF0066FF)),
            onPressed: () => _showEditPersonalDialog(context, personal),
          ),
        ],
      ),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 4),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            _buildExecutiveHeader(),
            const SizedBox(height: 16),

            // Hero Executive Digital Twin & Profile Card
            _buildExecutiveHeroCard(context, personal, employment),
            const SizedBox(height: 16),

            // Horizontal Filter Navigation Pills
            _buildFilterPills(),
            const SizedBox(height: 16),

            // SECTION: USER & FAMILY MANAGEMENT (Module 1)
            if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
              _buildPersonalDetailsSection(context, personal),
              const SizedBox(height: 16),
              _buildEmploymentIncomeSection(context, employment),
              const SizedBox(height: 16),
              _buildFamilyManagementSection(context, profileData),
              const SizedBox(height: 16),
              _buildContactAndAddressSection(context, personal, address),
              const SizedBox(height: 16),
            ],

            // SECTION: THE 7 FINANCIAL PILLARS (Core PFOS Engine)
            if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) ...[
              _buildSevenPillarsExecutiveSection(context),
              const SizedBox(height: 16),
            ],

            // SECTION: FINANCIAL ACCOUNT AGGREGATION (Module 2)
            if (_selectedFilterIndex == 0 || _selectedFilterIndex == 3) ...[
              _buildAccountAggregationSection(context),
              const SizedBox(height: 16),
            ],

            // SECTION: AI PERSONAL CFO & AUTOPILOT (Modules 9, 11, 22)
            if (_selectedFilterIndex == 0 || _selectedFilterIndex == 4) ...[
              _buildAiCfoAndAutopilotSection(context),
              const SizedBox(height: 16),
            ],

            // SECTION: DOCUMENT VAULT & SECURITY (Modules 29 & Governance)
            if (_selectedFilterIndex == 0 || _selectedFilterIndex == 5) ...[
              _buildSecurityAndVaultSection(context, security, prefs),
              const SizedBox(height: 16),
            ],

            // Compliance & Audit Footer Card
            _buildPlatformGovernanceFooter(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // HEADER & HERO PROFILE
  // --------------------------------------------------------------------------

  Widget _buildExecutiveHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Color(0xFF0A2540),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Personal Financial Operating System (PFOS) • Enterprise View',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.25)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: Color(0xFF0066FF)),
                  SizedBox(width: 4),
                  Text('PFOS Core', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0066FF))),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExecutiveHeroCard(BuildContext context, PersonalInfo personal, EmploymentIncomeInfo employment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2540).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FinmosUserAvatar(
                radius: 34,
                showCameraBadge: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personal.fullName,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      personal.email,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        const FinmosKycBadge(isCompact: true),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Text(
                            'PAN: ${personal.panNumber}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066FF).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            employment.employmentType,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0066FF)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // Financial Health Engine Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A2540), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.psychology_rounded, color: Color(0xFF38BDF8), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Financial Health Score',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Multi-Pillar Readiness Index',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Color(0xFF34D399)),
                          SizedBox(width: 4),
                          Text(
                            '88 / 100 • Excellent',
                            style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(
                    value: 0.88,
                    minHeight: 6,
                    backgroundColor: Color(0xFF334155),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Cash Flow: 92%',
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 9.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Protection: 85%',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 9.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Debt: 90%',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 9.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Tax: 96%',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 9.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Key Metrics Grid
          Row(
            children: [
              _buildMiniMetric(Icons.account_balance_wallet_outlined, 'Est. Net Worth', '₹ 48.5 Lakh'),
              _buildMiniMetric(Icons.savings_outlined, 'Emergency Runway', '6.2 Months'),
              _buildMiniMetric(Icons.family_restroom_outlined, 'Active Goals', '4 Linked'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF0066FF)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // HORIZONTAL FILTER PILLS
  // --------------------------------------------------------------------------

  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filterCategories.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0066FF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0066FF) : const Color(0xFFCBD5E1),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0066FF).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _filterCategories[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // MODULE 1: USER & FAMILY MANAGEMENT
  // --------------------------------------------------------------------------

  Widget _buildPersonalDetailsSection(BuildContext context, PersonalInfo personal) {
    return _buildSectionCard(
      title: 'Personal Information',
      subtitle: 'Personal details, PAN, Aadhaar & identity governance',
      badgeText: 'Module 1',
      subScreenRoute: '/profile/personal',
      onEdit: () => _showEditPersonalDialog(context, personal),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoRow('Full Name', personal.fullName)),
              Expanded(child: _buildInfoRow('Date of Birth', personal.dob)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Gender', personal.gender)),
              Expanded(child: _buildInfoRow('Marital Status', personal.maritalStatus)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoRow('PAN Number', personal.panNumber)),
              Expanded(child: _buildInfoRow('Aadhaar (Masked)', personal.aadhaarNumber)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Nationality', personal.nationality)),
              Expanded(child: _buildInfoRow('Regulatory Status', 'PAN Linked • Aadhaar KYC Verified')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentIncomeSection(BuildContext context, EmploymentIncomeInfo employment) {
    return _buildSectionCard(
      title: 'Employment & Income Details',
      subtitle: 'Occupation, income type, organization & earning capacity',
      badgeText: 'Module 4',
      subScreenRoute: '/profile/employment',
      onEdit: () => _showEditEmploymentDialog(context, employment),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoRow('Occupation / Type', employment.employmentType)),
              Expanded(child: _buildInfoRow('Designation', employment.designation)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Company / Employer', employment.companyName)),
              Expanded(child: _buildInfoRow('Work Experience', employment.workExperience)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Income Stream Type', employment.sourceOfIncome)),
              Expanded(child: _buildInfoRow('Annual CTC / Income', employment.annualIncome)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Monthly Take-Home', employment.monthlyIncome)),
              Expanded(child: _buildInfoRow('Income Stability', '94% (Stable • Salary Credit)')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyManagementSection(BuildContext context, ProfileStateData profileData) {
    return _buildSectionCard(
      title: 'Family & Household Management',
      subtitle: 'Spouse, children, parents, dependents & shared finances',
      badgeText: 'Module 1',
      subScreenRoute: '/profile/family',
      onEdit: () => _showAddFamilyMemberDialog(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Household Members & Dependents',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540)),
              ),
              TextButton.icon(
                onPressed: () => _showAddFamilyMemberDialog(context),
                icon: const Icon(Icons.add_circle_outline, size: 16, color: Color(0xFF0066FF)),
                label: const Text('Add Member', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0066FF))),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: profileData.familyMembers.map((member) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF0066FF).withOpacity(0.12),
                      child: Icon(
                        member.relation == 'Spouse'
                            ? Icons.favorite
                            : member.relation == 'Child'
                                ? Icons.child_care
                                : member.relation == 'Parent'
                                    ? Icons.elderly
                                    : Icons.person,
                        size: 16,
                        color: const Color(0xFF0066FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                          const SizedBox(height: 2),
                          Text('${member.relation} • Age ${member.age}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: member.isDependent ? const Color(0xFFF59E0B).withOpacity(0.15) : const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member.isDependent ? 'Dependent' : 'Independent',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: member.isDependent ? const Color(0xFFD97706) : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                      onPressed: () {
                        ref.read(profileProvider.notifier).removeFamilyMember(member.id);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          const Text(
            'Household Financial Structure',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Shared Monthly Expenses', profileData.householdStructure.sharedExpensesMonthly)),
              Expanded(child: _buildInfoRow('Active Family Goals', '${profileData.householdStructure.familyGoalsCount} Connected Goals')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Joint Family Finances', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0A2540))),
                  Text('Consolidates family income & cash flow in AI CFO', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
              Switch(
                value: profileData.householdStructure.jointFinancesEnabled,
                activeThumbColor: const Color(0xFF0066FF),
                onChanged: (val) {
                  ref.read(profileProvider.notifier).updateHouseholdStructure(
                        profileData.householdStructure.copyWith(jointFinancesEnabled: val),
                      );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactAndAddressSection(BuildContext context, PersonalInfo personal, AddressInfo address) {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Contact Information',
          subtitle: 'Verified phone & email communication channels',
          badgeText: 'Verified',
          onEdit: () => _showEditPersonalDialog(context, personal),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_iphone_outlined, color: Color(0xFF0066FF), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mobile Number', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        Text(personal.mobileNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Verified', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.email_outlined, color: Color(0xFF0066FF), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email Address', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        Text(personal.email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Verified', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Address Information',
          subtitle: 'Residential & permanent registered addresses',
          badgeText: 'Verified',
          subScreenRoute: '/profile/address',
          onEdit: () => _showEditAddressDialog(context, address),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Residential Address', address.residentialAddress),
              const SizedBox(height: 12),
              _buildInfoRow('Permanent Address', address.permanentAddress),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // THE 7 FINANCIAL PILLARS EXECUTIVE SECTION
  // --------------------------------------------------------------------------

  Widget _buildSevenPillarsExecutiveSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2540).withOpacity(0.04),
            blurRadius: 14,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The 7 Financial Pillars of PFOS',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Comprehensive operating status across all financial life domains',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('All 7 Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pillar 1: EARN
          _buildPillarTile(
            number: '1',
            name: 'EARN',
            subtitle: 'Income Management (Salaried + Freelance + Passive)',
            metricLabel: 'Monthly Inflow',
            metricValue: '₹ 80,000 / mo',
            status: 'Stable (94/100)',
            statusColor: const Color(0xFF10B981),
            icon: Icons.trending_up_rounded,
          ),

          // Pillar 2: SPEND
          _buildPillarTile(
            number: '2',
            name: 'SPEND',
            subtitle: 'Expenses, Subscriptions & Prioritization Matrix',
            metricLabel: 'Needs vs Wants',
            metricValue: '58% Needs • 28% Wants',
            status: 'P1 Ring-Fenced',
            statusColor: const Color(0xFF0066FF),
            icon: Icons.shopping_bag_outlined,
          ),

          // Pillar 3: PROTECT
          _buildPillarTile(
            number: '3',
            name: 'PROTECT',
            subtitle: 'Emergency Reserve & Insurance Gap Analysis',
            metricLabel: 'Emergency Runway',
            metricValue: '6.2 Months (₹3,00,000)',
            status: '0 Critical Gaps',
            statusColor: const Color(0xFF10B981),
            icon: Icons.health_and_safety_outlined,
          ),

          // Pillar 4: BORROW
          _buildPillarTile(
            number: '4',
            name: 'BORROW',
            subtitle: 'Debt Management & Avalanche Repayment',
            metricLabel: 'Debt-to-Income',
            metricValue: '22% (Safe < 40%)',
            status: '₹23K EMI • On Time',
            statusColor: const Color(0xFF0284C7),
            icon: Icons.credit_score_outlined,
          ),

          // Pillar 5: GROW
          _buildPillarTile(
            number: '5',
            name: 'GROW',
            subtitle: 'Investments, Mutual Funds & Net Worth Tracker',
            metricLabel: 'Net Worth',
            metricValue: '₹ 48.5 Lakh (15.4% XIRR)',
            status: 'Balanced Allocation',
            statusColor: const Color(0xFF8B5CF6),
            icon: Icons.auto_graph_rounded,
          ),

          // Pillar 6: PLAN
          _buildPillarTile(
            number: '6',
            name: 'PLAN',
            subtitle: 'Goals, Retirement Corpus & FIRE Engine',
            metricLabel: 'Target Corpus',
            metricValue: '₹ 3.5 Cr (FIRE Year 2042)',
            status: '74% On Track',
            statusColor: const Color(0xFFF59E0B),
            icon: Icons.flag_outlined,
          ),

          // Pillar 7: COMPLY
          _buildPillarTile(
            number: '7',
            name: 'COMPLY',
            subtitle: 'Tax Management & ITR Preparation Center',
            metricLabel: 'Regime Choice',
            metricValue: 'New Regime (Saves ₹25K)',
            status: '96% ITR Ready',
            statusColor: const Color(0xFF10B981),
            icon: Icons.receipt_long_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPillarTile({
    required String number,
    required String name,
    required String subtitle,
    required String metricLabel,
    required String metricValue,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: statusColor),
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
                        'Pillar $number: $name',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: statusColor),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '$metricLabel: $metricValue',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // MODULE 2: FINANCIAL ACCOUNT AGGREGATION
  // --------------------------------------------------------------------------

  Widget _buildAccountAggregationSection(BuildContext context) {
    return _buildSectionCard(
      title: 'Financial Account Aggregation',
      subtitle: 'Bank accounts, credit cards, UPI, loans & portfolios',
      badgeText: 'Module 2',
      child: Column(
        children: [
          _buildLinkedAccountItem(
            institution: 'HDFC Bank (Primary Savings)',
            details: 'A/C: ••••••••4587 • Balance: ₹1,42,500',
            icon: Icons.account_balance,
            status: 'Connected',
          ),
          _buildLinkedAccountItem(
            institution: 'ICICI Bank (Salary Account)',
            details: 'A/C: ••••••••8921 • Balance: ₹85,200',
            icon: Icons.account_balance,
            status: 'Connected',
          ),
          _buildLinkedAccountItem(
            institution: 'HDFC Regalia Credit Card',
            details: 'Limit: ₹5,00,000 • Due: ₹18,200 (Due 15th)',
            icon: Icons.credit_card,
            status: 'Active',
          ),
          _buildLinkedAccountItem(
            institution: 'UPI Handles (Google Pay & PhonePe)',
            details: 'sireesha@okhdfcbank • sireesha@ybl',
            icon: Icons.qr_code_2,
            status: 'Mandates Active',
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.sync, size: 14, color: Color(0xFF0066FF)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sync Frequency: Real-time & every 4 Hours (AES-256 Encrypted via RBI AA)',
                    style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedAccountItem({
    required String institution,
    required String details,
    required IconData icon,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          BankLogo(bankName: institution, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(institution, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0A2540))),
                const SizedBox(height: 2),
                Text(details, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // AI PERSONAL CFO & AUTOPILOT (Modules 9, 11, 22)
  // --------------------------------------------------------------------------

  Widget _buildAiCfoAndAutopilotSection(BuildContext context) {
    return _buildSectionCard(
      title: 'AI Personal CFO & Financial Autopilot',
      subtitle: 'Autonomous execution rules, priority matrix & scenario simulation',
      badgeText: 'Autonomous',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, color: Color(0xFF16A34A), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Autopilot Mode: Approval-Based Execution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF14532D))),
                      Text('AI prepares payments and allocations; you approve with 1-tap.', style: TextStyle(fontSize: 10, color: Color(0xFF166534))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Active Guardrail Rules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
          const SizedBox(height: 8),
          _buildRuleItem('Rule 1: Never miss EMI / Insurance premium (P1-P3 Protected)', true),
          _buildRuleItem('Rule 2: Always maintain ₹50,000 liquid buffer in Savings', true),
          _buildRuleItem('Rule 3: Auto-allocate 20% salary on arrival (10% Emergency + 10% SIP)', true),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Financial Digital Twin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0A2540))),
                    Text('90-day cash position forecast: Positive Surplus', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/cfo-ai'),
                icon: const Icon(Icons.smart_toy_outlined, size: 14),
                label: const Text('Open CFO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String rule, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(isActive ? Icons.check_circle : Icons.circle_outlined, size: 15, color: const Color(0xFF10B981)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(rule, style: const TextStyle(fontSize: 11, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // VAULT & SECURITY (Modules 29 & Governance)
  // --------------------------------------------------------------------------

  Widget _buildSecurityAndVaultSection(BuildContext context, SecuritySettings security, CommunicationPreferences prefs) {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Document Vault',
          subtitle: 'Encrypted tax proofs, policy schedules, property & KYC docs',
          badgeText: 'Module 29',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildInfoRow('Stored Documents', '6 Encrypted Records')),
                  Expanded(child: _buildInfoRow('Storage Encryption', 'AES-256 Multi-Zone')),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildDocTag(Icons.description_outlined, 'Form 16 (FY26)'),
                  _buildDocTag(Icons.health_and_safety_outlined, 'Health Policy PDF'),
                  _buildDocTag(Icons.security_outlined, 'Term Life Policy'),
                  _buildDocTag(Icons.badge_outlined, 'PAN & Aadhaar XML'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Security Settings',
          subtitle: 'Password, two-factor authentication (2FA) & device controls',
          badgeText: 'Encrypted',
          subScreenRoute: '/profile/security',
          onEdit: () => context.push('/profile/security'),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Two-Factor Authentication (2FA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                      Text('Extra layer of security using biometric / authenticator', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                  Switch(
                    value: security.is2FAEnabled,
                    activeThumbColor: const Color(0xFF0066FF),
                    onChanged: (val) {
                      ref.read(profileProvider.notifier).toggle2FA(val);
                    },
                  ),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Login Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                      Text('••••••••••••', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () => context.push('/settings'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Change', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Communication Preferences',
          subtitle: 'Choose how PFOS sends financial alerts & AI CFO updates',
          badgeText: 'Alerts',
          subScreenRoute: '/profile/preferences',
          onEdit: () => context.push('/profile/preferences'),
          child: Column(
            children: [
              _buildSwitchTile(
                title: 'SMS Notifications',
                subtitle: 'Receive instant OTPs and critical debit alerts via SMS',
                value: prefs.smsNotifications,
                onChanged: (val) {
                  ref.read(profileProvider.notifier).updateCommunicationPrefs(
                        prefs.copyWith(smsNotifications: val),
                      );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSwitchTile(
                title: 'Email Notifications',
                subtitle: 'Get monthly CFO reports and ITR summaries via email',
                value: prefs.emailNotifications,
                onChanged: (val) {
                  ref.read(profileProvider.notifier).updateCommunicationPrefs(
                        prefs.copyWith(emailNotifications: val),
                      );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Real-time autopilot payment recommendations & reminders',
                value: prefs.pushNotifications,
                onChanged: (val) {
                  ref.read(profileProvider.notifier).updateCommunicationPrefs(
                        prefs.copyWith(pushNotifications: val),
                      );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0066FF)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // FOOTER & GOVERNANCE
  // --------------------------------------------------------------------------

  Widget _buildPlatformGovernanceFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user, color: Color(0xFF0066FF), size: 20),
              SizedBox(width: 8),
              Text(
                'Personal Financial Operating System Active',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Your financial digital twin is fully configured with multi-account aggregation, 7-pillar monitoring, AI CFO rules, and bank-grade AES-256 security.',
            style: TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PFOS Profile & AI CFO sync completed!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0066FF),
                side: const BorderSide(color: Color(0xFF0066FF)),
              ),
              child: const Text('Re-Sync Financial Digital Twin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SHARED SECTION CARD BUILDER
  // --------------------------------------------------------------------------

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    String? badgeText,
    VoidCallback? onEdit,
    String? subScreenRoute,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0066FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0066FF)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subScreenRoute != null) ...[
                    ElevatedButton.icon(
                      onPressed: () => context.push(subScreenRoute),
                      icon: const Icon(Icons.arrow_forward, size: 13),
                      label: const Text('Open', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (onEdit != null)
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 12),
                      label: const Text('Edit', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        side: const BorderSide(color: Color(0xFF94A3B8)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2540))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF0066FF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
