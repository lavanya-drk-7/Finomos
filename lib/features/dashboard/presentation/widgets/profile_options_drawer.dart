import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/finmos_user_avatar.dart';
import '../../../../core/widgets/finmos_kyc_badge.dart';
import '../../../auth_kyc/domain/kyc_models.dart';
import '../../../auth_kyc/providers/auth_kyc_provider.dart';
import '../../../profile/domain/profile_models.dart';
import '../../../profile/providers/profile_provider.dart';

class _SubSectionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _SubSectionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

class ProfileOptionsDrawer extends ConsumerStatefulWidget {
  const ProfileOptionsDrawer({super.key});

  @override
  ConsumerState<ProfileOptionsDrawer> createState() => _ProfileOptionsDrawerState();
}

class _ProfileOptionsDrawerState extends ConsumerState<ProfileOptionsDrawer> {
  bool _isPersonalExpanded = false;
  bool _isAccountExpanded = false;

  // Sub-section expansion inside Personal Profile (all collapsed initially)
  bool _isPersonalInfoExpanded = false;
  bool _isAddressExpanded = false;
  bool _isEmploymentExpanded = false;
  bool _isFamilyExpanded = false;

  static const Color _primaryBrandColor = Color(0xFF0066FF);

  final List<_SubSectionData> _accountSubItems = const [
    _SubSectionData(
      icon: Icons.manage_accounts_outlined,
      title: 'Full Profile Dashboard',
      subtitle: 'Consolidated profile management view',
      route: '/profile-management',
    ),
    _SubSectionData(
      icon: Icons.verified_user_outlined,
      title: 'KYC Status & Verification',
      subtitle: 'KYC documents & verification status',
      route: '/kyc-status',
    ),
    _SubSectionData(
      icon: Icons.folder_open_outlined,
      title: 'Document Vaults',
      subtitle: 'Tax, Identity & Financial Documents',
      route: '/document-vault',
    ),
    _SubSectionData(
      icon: Icons.security_outlined,
      title: 'Security & Login Settings',
      subtitle: 'Password, 2FA, Biometrics & Sessions',
      route: '/profile/security',
    ),
    _SubSectionData(
      icon: Icons.notifications_none_outlined,
      title: 'Communication Preferences',
      subtitle: 'SMS, Email & Push notification alerts',
      route: '/profile/preferences',
    ),
    _SubSectionData(
      icon: Icons.account_balance_outlined,
      title: 'Bank Accounts & Aggregation',
      subtitle: 'Linked bank accounts & mandates',
      route: '/bank-aggregation',
    ),
    _SubSectionData(
      icon: Icons.settings_outlined,
      title: 'App Settings & Support',
      subtitle: 'System preferences & application setup',
      route: '/settings',
    ),
    _SubSectionData(
      icon: Icons.help_outline,
      title: 'Help & Support',
      subtitle: 'Help center, FAQs & customer support',
      route: '/help-support',
    ),
  ];

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF0F2B48),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFF87171), size: 26),
            SizedBox(width: 10),
            Text(
              'Confirm Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your Finomos account? You will need to log back in to access your financial OS dashboard.',
          style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF87171),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx); // Close dialog
              if (context.mounted) {
                Navigator.pop(context); // Close drawer
              }
              ref.read(authKycProvider.notifier).reset();
              ref.read(authKycProvider.notifier).updateStep(2);
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // EDIT DIALOGS FOR PROFILE FIELDS
  // --------------------------------------------------------------------------

  void _showEditPersonalDialog(BuildContext context, PersonalInfo info, UserRegistrationData user) {
    final nameCtrl = TextEditingController(text: info.fullName);
    final emailCtrl = TextEditingController(text: info.email);
    final phoneCtrl = TextEditingController(text: info.mobileNumber);
    final dobCtrl = TextEditingController(text: info.dob);
    final panCtrl = TextEditingController(text: info.panNumber);
    final aadhaarCtrl = TextEditingController(text: info.aadhaarNumber);
    final cityCtrl = TextEditingController(text: user.city.isNotEmpty ? user.city : 'Hyderabad');
    final stateCtrl = TextEditingController(text: user.state.isNotEmpty ? user.state : 'Telangana');
    final pinCtrl = TextEditingController(text: user.pinCode.isNotEmpty ? user.pinCode : '500081');

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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cityCtrl,
                            decoration: const InputDecoration(labelText: 'City / District', prefixIcon: Icon(Icons.location_city)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: pinCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'PIN Code', prefixIcon: Icon(Icons.pin_drop_outlined)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stateCtrl,
                      decoration: const InputDecoration(labelText: 'State / Region', prefixIcon: Icon(Icons.map_outlined)),
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
                          ref.read(authKycProvider.notifier).updateUserData(
                                user.copyWith(
                                  fullName: nameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  mobileNumber: phoneCtrl.text.trim(),
                                  city: cityCtrl.text.trim(),
                                  state: stateCtrl.text.trim(),
                                  pinCode: pinCtrl.text.trim(),
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

  void _showEditAddressDialog(BuildContext context, AddressInfo address, UserRegistrationData user) {
    final resCtrl = TextEditingController(text: address.residentialAddress);
    final permCtrl = TextEditingController(text: address.permanentAddress);
    final cityCtrl = TextEditingController(text: user.city.isNotEmpty ? user.city : 'Hyderabad');
    final stateCtrl = TextEditingController(text: user.state.isNotEmpty ? user.state : 'Telangana');
    final pinCtrl = TextEditingController(text: user.pinCode.isNotEmpty ? user.pinCode : '500081');
    bool sameAsRes = address.residentialAddress == address.permanentAddress;

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
                    const Text('Edit Address & Location Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 14),
                    TextField(
                      controller: resCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Current Residential Address', prefixIcon: Icon(Icons.home_outlined)),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Permanent address same as residential', style: TextStyle(fontSize: 13, color: Color(0xFF334155))),
                      value: sameAsRes,
                      onChanged: (val) {
                        setSheetState(() {
                          sameAsRes = val ?? false;
                          if (sameAsRes) {
                            permCtrl.text = resCtrl.text;
                          }
                        });
                      },
                    ),
                    if (!sameAsRes) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: permCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Permanent Address', prefixIcon: Icon(Icons.location_city_outlined)),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cityCtrl,
                            decoration: const InputDecoration(labelText: 'City / District', prefixIcon: Icon(Icons.location_city)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: pinCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'PIN Code', prefixIcon: Icon(Icons.pin_drop_outlined)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stateCtrl,
                      decoration: const InputDecoration(labelText: 'State', prefixIcon: Icon(Icons.map_outlined)),
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
                                address.copyWith(
                                  residentialAddress: resCtrl.text.trim(),
                                  permanentAddress: sameAsRes ? resCtrl.text.trim() : permCtrl.text.trim(),
                                ),
                              );
                          ref.read(authKycProvider.notifier).updateUserData(
                                user.copyWith(
                                  address: resCtrl.text.trim(),
                                  city: cityCtrl.text.trim(),
                                  state: stateCtrl.text.trim(),
                                  pinCode: pinCtrl.text.trim(),
                                ),
                              );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Address details saved!'), backgroundColor: Color(0xFF10B981)),
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
      },
    );
  }

  void _showEditEmploymentDialog(BuildContext context, EmploymentIncomeInfo info) {
    final companyCtrl = TextEditingController(text: info.companyName);
    final desigCtrl = TextEditingController(text: info.designation);
    final expCtrl = TextEditingController(text: info.workExperience);
    final locationCtrl = TextEditingController(text: info.workLocation.isNotEmpty ? info.workLocation : 'Hyderabad');
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
                      decoration: const InputDecoration(labelText: 'Work Experience', prefixIcon: Icon(Icons.timeline)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationCtrl,
                      decoration: const InputDecoration(labelText: 'Work Location / Base', prefixIcon: Icon(Icons.location_on_outlined)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSource,
                      decoration: const InputDecoration(labelText: 'Primary Source of Income', prefixIcon: Icon(Icons.attach_money)),
                      items: sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedSource = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: annualCtrl,
                      decoration: const InputDecoration(labelText: 'Annual Income / CTC', prefixIcon: Icon(Icons.currency_rupee)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: monthlyCtrl,
                      decoration: const InputDecoration(labelText: 'Monthly In-Hand / Take Home', prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
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
                                  workLocation: locationCtrl.text.trim(),
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
                        child: const Text('Save Employment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
    String relation = 'Spouse';
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
                    const Text('Add Family Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2540))),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Member Full Name', prefixIcon: Icon(Icons.person_add_outlined)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: relation,
                      decoration: const InputDecoration(labelText: 'Relationship', prefixIcon: Icon(Icons.family_restroom)),
                      items: ['Spouse', 'Child', 'Parent', 'Dependent'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => relation = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age (Years)', prefixIcon: Icon(Icons.cake_outlined)),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Is Financial Dependent?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: const Text('Included in household expense planning', style: TextStyle(fontSize: 11)),
                      value: isDependent,
                      onChanged: (val) => setSheetState(() => isDependent = val),
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
                            relation: relation,
                            age: int.tryParse(ageCtrl.text.trim()) ?? 30,
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

  // --------------------------------------------------------------------------
  // FIELD RENDERING HELPERS
  // --------------------------------------------------------------------------

  Widget _buildDrawerInfoRow(String label, String value, {Color? valueColor, Widget? badge}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value.isNotEmpty ? value : '—',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? const Color(0xFF0A2540),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              badge,
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseSplitBar(String label, String pct, double fraction, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(pct, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 1: PERSONAL INFORMATION & IDENTITY SUB-CARD
  // --------------------------------------------------------------------------

  Widget _buildPersonalInfoSection(BuildContext context, PersonalInfo personal, UserRegistrationData user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isPersonalInfoExpanded ? _primaryBrandColor.withOpacity(0.5) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sub-Section Header
          InkWell(
            onTap: () => setState(() => _isPersonalInfoExpanded = !_isPersonalInfoExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.badge_outlined, color: _primaryBrandColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information & Identity',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isPersonalInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Fields Grid
          if (_isPersonalInfoExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDrawerInfoRow('Full Name', personal.fullName)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDrawerInfoRow('Date of Birth', personal.dob)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDrawerInfoRow('Gender', personal.gender)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDrawerInfoRow('Marital Status', personal.maritalStatus)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDrawerInfoRow('PAN Number', personal.panNumber)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDrawerInfoRow('Aadhaar (Masked)', personal.aadhaarNumber)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDrawerInfoRow('Nationality', personal.nationality)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'City & State',
                          '${user.city.isNotEmpty ? user.city : "Hyderabad"}, ${user.state.isNotEmpty ? user.state : "Telangana"}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDrawerInfoRow('PIN Code', user.pinCode.isNotEmpty ? user.pinCode : '500081')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'Regulatory Status',
                          'PAN Linked',
                          valueColor: const Color(0xFF10B981),
                          badge: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('KYC Verified', style: TextStyle(fontSize: 8, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/profile/personal');
                          },
                          icon: const Icon(Icons.open_in_new, size: 12, color: Color(0xFF64748B)),
                          label: const Text('Full View', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditPersonalDialog(context, personal, user),
                          icon: const Icon(Icons.edit, size: 12, color: Colors.white),
                          label: const Text('Edit Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBrandColor,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 2: CONTACT & ADDRESS DETAILS SUB-CARD
  // --------------------------------------------------------------------------

  Widget _buildAddressSection(BuildContext context, PersonalInfo personal, AddressInfo address, UserRegistrationData user) {
    final sameAsRes = address.residentialAddress == address.permanentAddress;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isAddressExpanded ? _primaryBrandColor.withOpacity(0.5) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sub-Section Header
          InkWell(
            onTap: () => setState(() => _isAddressExpanded = !_isAddressExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.home_outlined, color: _primaryBrandColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Address & Residence Details',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isAddressExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Fields Grid
          if (_isAddressExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'Mobile Number',
                          personal.mobileNumber,
                          badge: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Verified', style: TextStyle(fontSize: 8, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'Email Address',
                          personal.email,
                          badge: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Verified', style: TextStyle(fontSize: 8, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDrawerInfoRow('City / District', user.city.isNotEmpty ? user.city : 'Hyderabad')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDrawerInfoRow('State', user.state.isNotEmpty ? user.state : 'Telangana')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDrawerInfoRow('Postal PIN Code', user.pinCode.isNotEmpty ? user.pinCode : '500081')),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'Address Match Status',
                          sameAsRes ? 'Permanent Same as Res.' : 'Separate Addresses',
                          valueColor: sameAsRes ? const Color(0xFF10B981) : _primaryBrandColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildDrawerInfoRow('Current Residential Address', address.residentialAddress),
                  const SizedBox(height: 10),
                  _buildDrawerInfoRow('Permanent Address', address.permanentAddress),
                  const SizedBox(height: 12),
                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/profile/address');
                          },
                          icon: const Icon(Icons.open_in_new, size: 12, color: Color(0xFF64748B)),
                          label: const Text('Full View', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditAddressDialog(context, address, user),
                          icon: const Icon(Icons.edit, size: 12, color: Colors.white),
                          label: const Text('Edit Address', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBrandColor,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 3: EMPLOYMENT & INCOME DETAILS SUB-CARD
  // --------------------------------------------------------------------------

  Widget _buildEmploymentSection(BuildContext context, EmploymentIncomeInfo employment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isEmploymentExpanded ? _primaryBrandColor.withOpacity(0.5) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sub-Section Header
          InkWell(
            onTap: () => setState(() => _isEmploymentExpanded = !_isEmploymentExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.work_outline, color: _primaryBrandColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Employment & Income Details',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isEmploymentExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Fields Grid
          if (_isEmploymentExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDrawerInfoRow('Occupation / Type', employment.employmentType)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDrawerInfoRow('Designation', employment.designation)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDrawerInfoRow('Company / Employer', employment.companyName)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDrawerInfoRow('Work Experience', employment.workExperience)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'Work Location',
                          employment.workLocation.isNotEmpty ? employment.workLocation : 'Hyderabad',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDrawerInfoRow('Income Stream Type', employment.sourceOfIncome)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'Annual CTC / Income',
                          employment.annualIncome,
                          valueColor: _primaryBrandColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'Monthly Take-Home',
                          employment.monthlyIncome,
                          valueColor: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'Income Stability',
                          '94% (Stable • Salary Credit)',
                          valueColor: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/profile/employment');
                          },
                          icon: const Icon(Icons.open_in_new, size: 12, color: Color(0xFF64748B)),
                          label: const Text('Full View', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditEmploymentDialog(context, employment),
                          icon: const Icon(Icons.edit, size: 12, color: Colors.white),
                          label: const Text('Edit Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBrandColor,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SECTION 4: FAMILY & HOUSEHOLD MANAGEMENT SUB-CARD
  // --------------------------------------------------------------------------

  Widget _buildFamilySection(BuildContext context, ProfileStateData profileData) {
    final household = profileData.householdStructure;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFamilyExpanded ? _primaryBrandColor.withOpacity(0.5) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sub-Section Header
          InkWell(
            onTap: () => setState(() => _isFamilyExpanded = !_isFamilyExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.family_restroom_outlined, color: _primaryBrandColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Family & Household Management',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isFamilyExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Fields Grid
          if (_isFamilyExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Household Key Metrics
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'Shared Expenses (Monthly)',
                          household.sharedExpensesMonthly,
                          valueColor: _primaryBrandColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDrawerInfoRow(
                          'Active Family Goals',
                          '${household.familyGoalsCount} Connected Goals',
                          valueColor: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Members List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Household Members & Dependents',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      Text(
                        '${profileData.familyMembers.length} Members',
                        style: const TextStyle(fontSize: 10, color: _primaryBrandColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: profileData.familyMembers.map((member) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundColor: const Color(0xFFEFF6FF),
                              child: Icon(
                                member.relation == 'Spouse'
                                    ? Icons.favorite
                                    : member.relation == 'Child'
                                        ? Icons.child_care
                                        : member.relation == 'Parent'
                                            ? Icons.elderly
                                            : Icons.person,
                                size: 13,
                                color: _primaryBrandColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0A2540)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${member.relation} • Age ${member.age}',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: member.isDependent ? const Color(0xFFF59E0B).withOpacity(0.15) : const Color(0xFF10B981).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                member.isDependent ? 'Dependent' : 'Independent',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: member.isDependent ? const Color(0xFFD97706) : const Color(0xFF059669),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 14, color: Color(0xFF94A3B8)),
                              tooltip: 'Remove',
                              onPressed: () {
                                ref.read(profileProvider.notifier).removeFamilyMember(member.id);
                              },
                              padding: const EdgeInsets.only(left: 4),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // 3. Shared Household Expense Allocation
                  const Text(
                    'Shared Household Expense Allocation',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  _buildExpenseSplitBar('Essentials (Groceries, Utilities)', '45%', 0.45, _primaryBrandColor),
                  _buildExpenseSplitBar('Housing & Maintenance', '30%', 0.30, const Color(0xFF10B981)),
                  _buildExpenseSplitBar('Healthcare & Insurance', '15%', 0.15, const Color(0xFFF59E0B)),
                  _buildExpenseSplitBar('Discretionary & Leisure', '10%', 0.10, const Color(0xFF8B5CF6)),
                  const SizedBox(height: 6),

                  // 4. Joint Household Finances Switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Joint Household Finances', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0A2540))),
                              Text('Consolidates family income & cash flow in AI CFO', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        Switch(
                          value: household.jointFinancesEnabled,
                          activeThumbColor: _primaryBrandColor,
                          activeTrackColor: _primaryBrandColor.withOpacity(0.3),
                          onChanged: (val) {
                            ref.read(profileProvider.notifier).updateHouseholdStructure(
                                  household.copyWith(jointFinancesEnabled: val),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/profile/family');
                          },
                          icon: const Icon(Icons.open_in_new, size: 12, color: Color(0xFF64748B)),
                          label: const Text('Full View', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddFamilyMemberDialog(context),
                          icon: const Icon(Icons.person_add, size: 12, color: Colors.white),
                          label: const Text('Add Member', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBrandColor,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // MAIN PERSONAL PROFILE DROPDOWN WITH ALL RELATED SECTIONS & FIELDS
  // --------------------------------------------------------------------------

  Widget _buildPersonalProfileDropdown(
    BuildContext context,
    ProfileStateData profileData,
    UserRegistrationData user,
  ) {
    final personal = profileData.personalInfo;
    final address = profileData.addressInfo;
    final employment = profileData.employmentInfo;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isPersonalExpanded ? _primaryBrandColor.withOpacity(0.6) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Option Card Header (Tappable Dropdown Header)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isPersonalExpanded = !_isPersonalExpanded;
                  if (_isPersonalExpanded) {
                    _isAccountExpanded = false;
                  }
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _primaryBrandColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryBrandColor.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_pin_outlined, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Profile',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Identity, Residence, Employment & Household Details',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPersonalExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: _primaryBrandColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // All Related Sections & Fields Rendered Inline Inside Profile Section
          if (_isPersonalExpanded) ...[
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE2E8F0),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Column(
                children: [
                  // Section 1: Personal Information & Identity
                  _buildPersonalInfoSection(context, personal, user),

                  // Section 2: Address & Residence Details
                  _buildAddressSection(context, personal, address, user),

                  // Section 3: Employment & Income Details
                  _buildEmploymentSection(context, employment),

                  // Section 4: Family & Household Management
                  _buildFamilySection(context, profileData),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ACCOUNT SETTINGS DROPDOWN (PRESERVED)
  // --------------------------------------------------------------------------

  Widget _buildAccountSettingsDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isAccountExpanded ? _primaryBrandColor.withOpacity(0.6) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isAccountExpanded = !_isAccountExpanded;
                  if (_isAccountExpanded) {
                    _isPersonalExpanded = false;
                  }
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _primaryBrandColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryBrandColor.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.manage_accounts_outlined, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Settings',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Full Profile, KYC, Vaults, Security & App Settings',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isAccountExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: _primaryBrandColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isAccountExpanded) ...[
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE2E8F0),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Column(
                children: _accountSubItems.map((subItem) {
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(subItem.icon, color: _primaryBrandColor, size: 18),
                      ),
                      title: Text(
                        subItem.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2540),
                        ),
                      ),
                      subtitle: Text(
                        subItem.subtitle,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                      onTap: () {
                        if (subItem.route == '/kyc-status') {
                          ref.read(authKycProvider.notifier).updateStep(11);
                        }
                        final router = GoRouter.of(context);
                        Navigator.pop(context); // Close drawer
                        router.push(subItem.route);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // LOGOUT TILE
  // --------------------------------------------------------------------------

  Widget _buildLogoutTile(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutConfirmation(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0AF87171),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF87171),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF87171).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sign out of your Finomos account & end session',
                      style: TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.logout_rounded,
                size: 20,
                color: Color(0xFFDC2626),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // DRAWER BUILD METHOD
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(authKycProvider);
    final profileData = ref.watch(profileProvider);

    final userName = profileData.personalInfo.fullName.trim().isNotEmpty
        ? profileData.personalInfo.fullName
        : (kycState.user.fullName.trim().isNotEmpty ? kycState.user.fullName : 'Sireesha');

    final userEmail = profileData.personalInfo.email.trim().isNotEmpty
        ? profileData.personalInfo.email
        : (kycState.user.email.trim().isNotEmpty ? kycState.user.email : 'sireesha@gmail.com');

    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.90 > 420 ? 420.0 : screenWidth * 0.90;
    final isAnyExpanded = _isPersonalExpanded || _isAccountExpanded;

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.white,
      elevation: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Drawer Header with User Profile (White Header portion)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const FinmosUserAvatar(
                                radius: 22,
                                showCameraBadge: true,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A2540),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      userEmail,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const FinmosKycBadge(isCompact: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF0A2540)),
                          tooltip: 'Close Menu',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            padding: const EdgeInsets.all(6),
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Section Title Row
                    Row(
                      children: [
                        if (isAnyExpanded) ...[
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isPersonalExpanded = false;
                                _isAccountExpanded = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF0A2540)),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        const Expanded(
                          child: Text(
                            'Profile Options',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Middle Scrollable Area: Top 2 Options with Inline Dropdown
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Personal Profile Section with ALL Moved Related Sections & Fields
                      _buildPersonalProfileDropdown(context, profileData, kycState.user),
                      const SizedBox(height: 14),

                      // 2. Account Settings Dropdown
                      _buildAccountSettingsDropdown(context),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Section: 3rd Option Logout
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _buildLogoutTile(context),
              ),

              // 4. Security & Encryption Badge Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Finomos OS • 256-Bit SSL Encrypted',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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
}
