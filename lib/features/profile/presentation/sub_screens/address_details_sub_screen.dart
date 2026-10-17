import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/finmos_bottom_nav_bar.dart';
import '../../providers/profile_provider.dart';

class AddressDetailsSubScreen extends ConsumerStatefulWidget {
  const AddressDetailsSubScreen({super.key});

  @override
  ConsumerState<AddressDetailsSubScreen> createState() => _AddressDetailsSubScreenState();
}

class _AddressDetailsSubScreenState extends ConsumerState<AddressDetailsSubScreen> {
  late TextEditingController resAddressCtrl;
  late TextEditingController permAddressCtrl;
  bool isSameAsResidential = false;

  @override
  void initState() {
    super.initState();
    final address = ref.read(profileProvider).addressInfo;
    resAddressCtrl = TextEditingController(text: address.residentialAddress);
    permAddressCtrl = TextEditingController(text: address.permanentAddress);
    if (address.residentialAddress == address.permanentAddress) {
      isSameAsResidential = true;
    }
  }

  @override
  void dispose() {
    resAddressCtrl.dispose();
    permAddressCtrl.dispose();
    super.dispose();
  }

  void _saveAddress() {
    final current = ref.read(profileProvider).addressInfo;
    final updated = current.copyWith(
      residentialAddress: resAddressCtrl.text.trim(),
      permanentAddress: isSameAsResidential ? resAddressCtrl.text.trim() : permAddressCtrl.text.trim(),
    );

    ref.read(profileProvider.notifier).updateAddressInfo(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address details saved successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Address & Residence',
          style: TextStyle(
            color: Color(0xFF0A2540),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF0066FF)),
            onPressed: _saveAddress,
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
                    const Row(
                      children: [
                        Icon(Icons.home_work_outlined, color: Color(0xFF0066FF), size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Residential Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2540),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: resAddressCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Current Residential Address',
                        prefixIcon: Icon(Icons.home_outlined),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isSameAsResidential,
                      activeColor: const Color(0xFF0066FF),
                      title: const Text(
                        'Permanent address is same as residential address',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0A2540)),
                      ),
                      onChanged: (val) {
                        setState(() {
                          isSameAsResidential = val ?? false;
                          if (isSameAsResidential) {
                            permAddressCtrl.text = resAddressCtrl.text;
                          }
                        });
                      },
                    ),
                    if (!isSameAsResidential) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: permAddressCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Permanent Address',
                          prefixIcon: Icon(Icons.business_outlined),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _saveAddress,
                        child: const Text(
                          'Save Address Details',
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
