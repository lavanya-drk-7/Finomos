import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../../../core/widgets/finmos_user_avatar.dart';
import '../../../../core/widgets/finmos_kyc_badge.dart';
import '../../providers/profile_provider.dart';

class PersonalInfoSubScreen extends ConsumerStatefulWidget {
  const PersonalInfoSubScreen({super.key});

  @override
  ConsumerState<PersonalInfoSubScreen> createState() => _PersonalInfoSubScreenState();
}

class _PersonalInfoSubScreenState extends ConsumerState<PersonalInfoSubScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController dobCtrl;
  late TextEditingController panCtrl;
  late TextEditingController aadhaarCtrl;

  String selectedGender = 'Female';
  String selectedMarital = 'Married';
  String selectedNationality = 'Indian';

  @override
  void initState() {
    super.initState();
    final personal = ref.read(profileProvider).personalInfo;
    nameCtrl = TextEditingController(text: personal.fullName);
    emailCtrl = TextEditingController(text: personal.email);
    phoneCtrl = TextEditingController(text: personal.mobileNumber);
    dobCtrl = TextEditingController(text: personal.dob);
    panCtrl = TextEditingController(text: personal.panNumber);
    aadhaarCtrl = TextEditingController(text: personal.aadhaarNumber);

    const genders = ['Female', 'Male', 'Other'];
    if (genders.contains(personal.gender)) selectedGender = personal.gender;

    const maritalStatuses = ['Married', 'Single', 'Divorced', 'Widowed'];
    if (maritalStatuses.contains(personal.maritalStatus)) selectedMarital = personal.maritalStatus;

    const nationalities = ['Indian', 'NRI', 'Other'];
    if (nationalities.contains(personal.nationality)) selectedNationality = personal.nationality;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    dobCtrl.dispose();
    panCtrl.dispose();
    aadhaarCtrl.dispose();
    super.dispose();
  }

  void _saveDetails() {
    final current = ref.read(profileProvider).personalInfo;
    final updated = current.copyWith(
      fullName: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      mobileNumber: phoneCtrl.text.trim(),
      dob: dobCtrl.text.trim(),
      gender: selectedGender,
      maritalStatus: selectedMarital,
      panNumber: panCtrl.text.trim(),
      aadhaarNumber: aadhaarCtrl.text.trim(),
      nationality: selectedNationality,
    );

    ref.read(profileProvider.notifier).updatePersonalInfo(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Personal information updated successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personal = ref.watch(profileProvider).personalInfo;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation: 1,
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
        title: const Text(
          'Personal Details',
          style: TextStyle(
            color: Color(0xFF0A2540),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF0066FF)),
            onPressed: _saveDetails,
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: const FinmosBottomNavBar(currentIndex: 4),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          // Profile Photo & Identity Header Card
          Container(
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
                  children: [
                    Center(
                      child: FinmosUserAvatar(
                        radius: 40,
                        showCameraBadge: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      personal.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const FinmosKycBadge(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Section
              Container(
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
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: dobCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.wc),
                        border: OutlineInputBorder(),
                      ),
                      items: ['Female', 'Male', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedGender = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedMarital,
                      decoration: const InputDecoration(
                        labelText: 'Marital Status',
                        prefixIcon: Icon(Icons.family_restroom),
                        border: OutlineInputBorder(),
                      ),
                      items: ['Married', 'Single', 'Divorced', 'Widowed']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedMarital = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: panCtrl,
                      decoration: const InputDecoration(
                        labelText: 'PAN Card Number',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: aadhaarCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Aadhaar Number',
                        prefixIcon: Icon(Icons.fingerprint),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedNationality,
                      decoration: const InputDecoration(
                        labelText: 'Nationality',
                        prefixIcon: Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: ['Indian', 'NRI', 'Other']
                          .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedNationality = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _saveDetails,
                        child: const Text(
                          'Save Personal Details',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
