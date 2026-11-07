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
  late TextEditingController cityCtrl;
  late TextEditingController stateCtrl;
  late TextEditingController pinCodeCtrl;
  bool isSameAsResidential = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final address = ref.read(profileProvider).addressInfo;
    resAddressCtrl = TextEditingController(text: address.residentialAddress);
    permAddressCtrl = TextEditingController(text: address.permanentAddress);
    cityCtrl = TextEditingController(text: address.city);
    stateCtrl = TextEditingController(text: address.state);
    pinCodeCtrl = TextEditingController(text: address.pinCode);
    if (address.residentialAddress == address.permanentAddress) {
      isSameAsResidential = true;
    }
  }

  @override
  void dispose() {
    resAddressCtrl.dispose();
    permAddressCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pinCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    setState(() => _isSaving = true);
    final current = ref.read(profileProvider).addressInfo;
    final updated = current.copyWith(
      residentialAddress: resAddressCtrl.text.trim(),
      city: cityCtrl.text.trim().isNotEmpty ? cityCtrl.text.trim() : current.city,
      state: stateCtrl.text.trim().isNotEmpty ? stateCtrl.text.trim() : current.state,
      pinCode: pinCodeCtrl.text.trim().isNotEmpty ? pinCodeCtrl.text.trim() : current.pinCode,
      permanentAddress: isSameAsResidential ? resAddressCtrl.text.trim() : permAddressCtrl.text.trim(),
    );

    final success = await ref.read(profileProvider.notifier).updateAddressInfo(updated);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Residential address updated successfully!' : 'Failed to update address. Please retry.',
          ),
          backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
      );
    }
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
              context.go('/profile-management');
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileProvider.notifier).loadProfile(force: true),
        child: ListView(
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
                        Expanded(
                          child: Text(
                            'Residential Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2540),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: resAddressCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Current Residential Address',
                        prefixIcon: Icon(Icons.home_outlined),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              prefixIcon: Icon(Icons.location_city_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: pinCodeCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'PIN Code',
                              prefixIcon: Icon(Icons.pin_drop_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: stateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'State / Province',
                        prefixIcon: Icon(Icons.map_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
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
                        onPressed: _isSaving ? null : _saveAddress,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
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
      ),
    );
  }
}
