import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../providers/profile_provider.dart';

class _EmpTypeConfig {
  final String field1Label;
  final IconData field1Icon;
  final String field2Label;
  final IconData field2Icon;
  final String field3Label;
  final IconData field3Icon;
  final String field4Label;
  final IconData field4Icon;
  final List<String> incomeSources;
  final String annualIncomeLabel;
  final IconData annualIncomeIcon;
  final String monthlyIncomeLabel;
  final IconData monthlyIncomeIcon;

  const _EmpTypeConfig({
    required this.field1Label,
    required this.field1Icon,
    required this.field2Label,
    required this.field2Icon,
    required this.field3Label,
    required this.field3Icon,
    required this.field4Label,
    required this.field4Icon,
    required this.incomeSources,
    required this.annualIncomeLabel,
    required this.annualIncomeIcon,
    required this.monthlyIncomeLabel,
    required this.monthlyIncomeIcon,
  });
}

class EmploymentIncomeSubScreen extends ConsumerStatefulWidget {
  const EmploymentIncomeSubScreen({super.key});

  @override
  ConsumerState<EmploymentIncomeSubScreen> createState() => _EmploymentIncomeSubScreenState();
}

class _EmploymentIncomeSubScreenState extends ConsumerState<EmploymentIncomeSubScreen> {
  late TextEditingController companyCtrl;
  late TextEditingController designationCtrl;
  late TextEditingController experienceCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController annualIncomeCtrl;
  late TextEditingController monthlyIncomeCtrl;

  String selectedEmpType = 'Salaried';
  String selectedSource = 'Salary & Bonus';

  static const List<String> empTypes = [
    'Salaried',
    'Self-Employed',
    'Business Owner',
    'Freelancer',
    'Others',
  ];

  static const Map<String, _EmpTypeConfig> empConfigs = {
    'Salaried': _EmpTypeConfig(
      field1Label: 'Company / Organization Name',
      field1Icon: Icons.business,
      field2Label: 'Designation / Job Role',
      field2Icon: Icons.badge_outlined,
      field3Label: 'Work Experience',
      field3Icon: Icons.timeline,
      field4Label: 'Work Location',
      field4Icon: Icons.location_city_outlined,
      incomeSources: ['Salary', 'Salary & Bonus', 'Allowances', 'Commission'],
      annualIncomeLabel: 'Annual Total Income',
      annualIncomeIcon: Icons.payments_outlined,
      monthlyIncomeLabel: 'Monthly Take-Home Salary',
      monthlyIncomeIcon: Icons.monetization_on_outlined,
    ),
    'Self-Employed': _EmpTypeConfig(
      field1Label: 'Practice / Profession Name',
      field1Icon: Icons.medical_services_outlined,
      field2Label: 'Nature of Profession / Services',
      field2Icon: Icons.category_outlined,
      field3Label: 'Years in Practice / Operation',
      field3Icon: Icons.timeline,
      field4Label: 'Clinic / Office Location',
      field4Icon: Icons.location_on_outlined,
      incomeSources: ['Professional Fees', 'Consultation Charges', 'Retainer Fees', 'Other Services'],
      annualIncomeLabel: 'Annual Net Professional Revenue',
      annualIncomeIcon: Icons.account_balance_outlined,
      monthlyIncomeLabel: 'Monthly Average Net Income',
      monthlyIncomeIcon: Icons.attach_money_outlined,
    ),
    'Business Owner': _EmpTypeConfig(
      field1Label: 'Business / Enterprise Name',
      field1Icon: Icons.storefront_outlined,
      field2Label: 'Industry / Sector',
      field2Icon: Icons.domain,
      field3Label: 'Years of Business Establishment',
      field3Icon: Icons.history_outlined,
      field4Label: 'Business Registered Location',
      field4Icon: Icons.map_outlined,
      incomeSources: ['Business Profits', 'Dividend Distribution', "Director's Salary / Draw", 'Capital Gains'],
      annualIncomeLabel: 'Annual Business Turnover / Revenue',
      annualIncomeIcon: Icons.account_balance_wallet_outlined,
      monthlyIncomeLabel: 'Monthly Net Profit / Draw',
      monthlyIncomeIcon: Icons.monetization_on_outlined,
    ),
    'Freelancer': _EmpTypeConfig(
      field1Label: 'Primary Skill / Domain',
      field1Icon: Icons.code_outlined,
      field2Label: 'Key Clients / Platforms',
      field2Icon: Icons.connect_without_contact,
      field3Label: 'Freelancing Experience',
      field3Icon: Icons.timelapse,
      field4Label: 'Work / Operating Base',
      field4Icon: Icons.home_work_outlined,
      incomeSources: ['Freelance Projects', 'Contract Retainers', 'Hourly Billing', 'Consulting'],
      annualIncomeLabel: 'Annual Freelance Earnings',
      annualIncomeIcon: Icons.payments_outlined,
      monthlyIncomeLabel: 'Monthly Average Freelance Income',
      monthlyIncomeIcon: Icons.savings_outlined,
    ),
    'Others': _EmpTypeConfig(
      field1Label: 'Specify Occupation / Activity',
      field1Icon: Icons.edit_note,
      field2Label: 'Entity / Source Name',
      field2Icon: Icons.account_balance_outlined,
      field3Label: 'Years / Experience Duration',
      field3Icon: Icons.access_time,
      field4Label: 'Primary Location',
      field4Icon: Icons.place_outlined,
      incomeSources: ['Pension', 'Rental Income', 'Investment Dividends', 'Agriculture', 'Interest Income', 'Other Income'],
      annualIncomeLabel: 'Annual Total Income',
      annualIncomeIcon: Icons.payments_outlined,
      monthlyIncomeLabel: 'Monthly Average Income / Stipend',
      monthlyIncomeIcon: Icons.monetization_on_outlined,
    ),
  };

  @override
  void initState() {
    super.initState();
    final emp = ref.read(profileProvider).employmentInfo;
    companyCtrl = TextEditingController(text: emp.companyName);
    designationCtrl = TextEditingController(text: emp.designation);
    experienceCtrl = TextEditingController(text: emp.workExperience);
    locationCtrl = TextEditingController(text: emp.workLocation);
    annualIncomeCtrl = TextEditingController(text: emp.annualIncome);
    monthlyIncomeCtrl = TextEditingController(text: emp.monthlyIncome);

    if (empTypes.contains(emp.employmentType)) {
      selectedEmpType = emp.employmentType;
    } else {
      selectedEmpType = 'Salaried';
    }

    final config = empConfigs[selectedEmpType] ?? empConfigs['Salaried']!;
    if (config.incomeSources.contains(emp.sourceOfIncome)) {
      selectedSource = emp.sourceOfIncome;
    } else {
      selectedSource = config.incomeSources.first;
    }
  }

  @override
  void dispose() {
    companyCtrl.dispose();
    designationCtrl.dispose();
    experienceCtrl.dispose();
    locationCtrl.dispose();
    annualIncomeCtrl.dispose();
    monthlyIncomeCtrl.dispose();
    super.dispose();
  }

  void _saveDetails() {
    final current = ref.read(profileProvider).employmentInfo;
    final updated = current.copyWith(
      employmentType: selectedEmpType,
      companyName: companyCtrl.text.trim(),
      designation: designationCtrl.text.trim(),
      workExperience: experienceCtrl.text.trim(),
      workLocation: locationCtrl.text.trim(),
      sourceOfIncome: selectedSource,
      annualIncome: annualIncomeCtrl.text.trim(),
      monthlyIncome: monthlyIncomeCtrl.text.trim(),
    );

    ref.read(profileProvider.notifier).updateEmploymentInfo(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Employment & income details updated!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = empConfigs[selectedEmpType] ?? empConfigs['Salaried']!;

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
          'Employment & Income',
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
                  'Job & Financial Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2540),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedEmpType,
                  decoration: const InputDecoration(
                    labelText: 'Employment Type',
                    prefixIcon: Icon(Icons.work_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: empTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedEmpType = val;
                        final newConfig = empConfigs[val] ?? empConfigs['Salaried']!;
                        if (!newConfig.incomeSources.contains(selectedSource)) {
                          selectedSource = newConfig.incomeSources.first;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: companyCtrl,
                  decoration: InputDecoration(
                    labelText: config.field1Label,
                    prefixIcon: Icon(config.field1Icon),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: designationCtrl,
                  decoration: InputDecoration(
                    labelText: config.field2Label,
                    prefixIcon: Icon(config.field2Icon),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: experienceCtrl,
                  decoration: InputDecoration(
                    labelText: config.field3Label,
                    prefixIcon: Icon(config.field3Icon),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: locationCtrl,
                  decoration: InputDecoration(
                    labelText: config.field4Label,
                    prefixIcon: Icon(config.field4Icon),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSource,
                  decoration: const InputDecoration(
                    labelText: 'Primary Source of Income',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: config.incomeSources
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedSource = val);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: annualIncomeCtrl,
                  decoration: InputDecoration(
                    labelText: config.annualIncomeLabel,
                    prefixIcon: Icon(config.annualIncomeIcon),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: monthlyIncomeCtrl,
                  decoration: InputDecoration(
                    labelText: config.monthlyIncomeLabel,
                    prefixIcon: Icon(config.monthlyIncomeIcon),
                    border: const OutlineInputBorder(),
                  ),
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
                      'Save Employment Info',
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

