import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_kyc_provider.dart';
import 'flow_header.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _pinController;
  String _selectedGender = 'Female';
  String _selectedState = 'Telangana';

  final List<String> _states = [
    'Telangana',
    'Maharashtra',
    'Karnataka',
    'Delhi',
    'Tamil Nadu',
    'Gujarat',
    'West Bengal',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authKycProvider).user;
    _nameController = TextEditingController(text: user.fullName.isEmpty ? 'Sireesha' : user.fullName);
    _dobController = TextEditingController(text: user.dob.isEmpty ? '1995-08-15' : user.dob);
    _selectedGender = user.gender.isEmpty ? 'Female' : user.gender;
    _addressController = TextEditingController(text: user.address.isEmpty ? '101, Tech Park Avenue, Hitech City' : user.address);
    _cityController = TextEditingController(text: user.city.isEmpty ? 'Hyderabad' : user.city);
    _pinController = TextEditingController(text: user.pinCode.isEmpty ? '500081' : user.pinCode);
    _selectedState = _states.contains(user.state) ? user.state : 'Telangana';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _onPrevious() {
    ref.read(authKycProvider.notifier).updateStep(1);
    context.go('/signup');
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authKycProvider).user;
      final updated = user.copyWith(
        fullName: _nameController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _selectedGender,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _selectedState,
        pinCode: _pinController.text.trim(),
      );
      ref.read(authKycProvider.notifier).updateUserData(updated);
      ref.read(authKycProvider.notifier).updateStep(3);
      context.go('/kyc-details');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 8, 15),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const FlowHeader(activeStep: 2),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Tell Us About Yourself',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Please provide your basic details for identity verification',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
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
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0066FF)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Please enter full name' : null,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _dobController,
                                  readOnly: true,
                                  onTap: _selectDate,
                                  decoration: InputDecoration(
                                    labelText: 'Date of Birth',
                                    prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF0066FF)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Please select date of birth' : null,
                                ),
                                const SizedBox(height: 16),

                                DropdownButtonFormField<String>(
                                  initialValue: _selectedGender,
                                  decoration: InputDecoration(
                                    labelText: 'Gender',
                                    prefixIcon: const Icon(Icons.people_outline, color: Color(0xFF0066FF)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedGender = val;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                 // ADDRESS FIELDS
                                TextFormField(
                                  controller: _addressController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: 'Address',
                                    hintText: '101, Tech Park Avenue, Hitech City',
                                    prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF0066FF)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Please enter address' : null,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _cityController,
                                  decoration: InputDecoration(
                                    labelText: 'City',
                                    hintText: 'Hyderabad',
                                    prefixIcon: const Icon(Icons.location_city_outlined, color: Color(0xFF0066FF)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Please enter city' : null,
                                ),
                                const SizedBox(height: 16),

                                DropdownButtonFormField<String>(
                                  initialValue: _selectedState,
                                  decoration: InputDecoration(
                                    labelText: 'State',
                                    prefixIcon: const Icon(Icons.map_outlined, color: Color(0xFF0066FF)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                  items: _states
                                      .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedState = val;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _pinController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'PIN Code',
                                    hintText: '500081',
                                    prefixIcon: const Icon(Icons.pin_drop_outlined, color: Color(0xFF0066FF)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.length < 6 ? 'Please enter 6-digit PIN code' : null,
                                ),
                                const SizedBox(height: 28),

                                // Action Buttons Row: Previous & Next with FittedBox
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 52,
                                        child: OutlinedButton(
                                          onPressed: _onPrevious,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF475569),
                                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.arrow_back, size: 18),
                                                SizedBox(width: 4),
                                                Text('Previous', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: SizedBox(
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: _onNext,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0066FF),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text('Next', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                                SizedBox(width: 4),
                                                Icon(Icons.arrow_forward, size: 18),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        ),
      );
    }
}
