import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../providers/auth_kyc_provider.dart';
import 'flow_header.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  bool _obscurePassword = true;
  bool _isEmailVerified = false;
  bool _isMobileVerified = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authKycProvider).user;
    _nameController = TextEditingController(text: user.fullName);
    _emailController = TextEditingController(text: user.email);
    _passwordController = TextEditingController(text: user.password);
    _phoneController = TextEditingController(text: user.mobileNumber);

    // Default sample 6-digit OTP pre-filled for smooth testing
    const defaultOtp = ['4', '2', '8', '6', '1', '9'];
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = defaultOtp[i];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _checkAndProceedToNextStep() {
    if (_isEmailVerified && _isMobileVerified) {
      final currentUser = ref.read(authKycProvider).user;
      final updatedUser = currentUser.copyWith(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        mobileNumber: _phoneController.text.trim(),
      );

      ref.read(authKycProvider.notifier).updateUserData(updatedUser);
      ref.read(authKycProvider.notifier).setIsExistingUser(false);
      ref.read(authKycProvider.notifier).setMobileVerified(true);
      ref.read(authKycProvider.notifier).setOtpVerified(true);
      ref.read(authKycProvider.notifier).updateStep(3);

      ScaffoldMessenger.of(context).clearSnackBars();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          context.go('/user-details');
        }
      });
    }
  }

  void _verifyEmail() {
    final nameError = FormValidators.validateFullName(_nameController.text);
    final emailError = FormValidators.validateEmail(_emailController.text);
    final passError = FormValidators.validatePassword(_passwordController.text);

    if (nameError != null || emailError != null || passError != null) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      _formKey.currentState?.validate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(nameError ?? emailError ?? passError ?? 'Please complete all required fields'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isEmailVerified = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Email ID Verified Successfully!'),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    _checkAndProceedToNextStep();
  }

  void _resendOtp() {
    final mobileError = FormValidators.validateMobile(_phoneController.text);
    if (mobileError != null) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      _formKey.currentState?.validate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(mobileError)),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    const newOtp = ['6', '1', '9', '4', '2', '8'];
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = newOtp[i];
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.refresh, color: Colors.white),
            const SizedBox(width: 8),
            Text('New OTP sent to ${_phoneController.text}: 619428'),
          ],
        ),
        backgroundColor: const Color(0xFF0066FF),
      ),
    );
  }

  void _verifyMobileOtp() {
    final mobileError = FormValidators.validateMobile(_phoneController.text);
    final otp = _otpControllers.map((c) => c.text.trim()).join();
    final otpError = FormValidators.validateOtp(otp);

    if (mobileError != null || otpError != null) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      _formKey.currentState?.validate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(mobileError ?? otpError ?? 'Please verify mobile number & OTP'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isMobileVerified = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.verified, color: Colors.white),
            SizedBox(width: 8),
            Text('Mobile OTP Verified!'),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    _checkAndProceedToNextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const FlowHeader(activeStep: 1),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidateMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Hero Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A2540), Color(0xFF0066FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0066FF).withOpacity(0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const FinmosLogo(size: 44, showFooter: false, showTagline: false),
                            const SizedBox(height: 12),
                            const Text(
                              'Create Your Account',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get started with your FINMOS journey (Step 1 of 6)',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            // Full Name Field
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                hintText: 'e.g. Sireesha',
                                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0066FF)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              validator: FormValidators.validateFullName,
                            ),
                            const SizedBox(height: 16),

                            // -------------------------------------------------------------
                            // 1. EMAIL ID ENTER FIELD
                            // -------------------------------------------------------------
                            Row(
                              children: [
                                const Icon(Icons.email_outlined, size: 18, color: Color(0xFF0066FF)),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Email Credentials',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                if (_isEmailVerified) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, size: 12, color: Color(0xFF10B981)),
                                        SizedBox(width: 4),
                                        Text('Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email ID',
                                hintText: 'sireesha@gmail.com',
                                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0066FF)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              validator: FormValidators.validateEmail,
                            ),
                            const SizedBox(height: 14),

                            // -------------------------------------------------------------
                            // 2. PASSWORD FIELD + VERIFY EMAIL BUTTON
                            // -------------------------------------------------------------
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Create password',
                                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0066FF)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: const Color(0xFF64748B),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: FormValidators.validatePassword,
                            ),
                            const SizedBox(height: 12),

                            // "Verify Email" Button
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: _verifyEmail,
                                icon: Icon(_isEmailVerified ? Icons.check_circle : Icons.verified_user_outlined, size: 18),
                                label: Text(
                                  _isEmailVerified ? 'Email Verified ✓' : 'Verify Email',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isEmailVerified ? const Color(0xFF10B981) : const Color(0xFF0066FF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 20),

                            // -------------------------------------------------------------
                            // 3. MOBILE NUMBER FIELD & 6-DIGIT OTP BLOCKS
                            // -------------------------------------------------------------
                            Row(
                              children: [
                                const Icon(Icons.phone_iphone_outlined, size: 18, color: Color(0xFF0066FF)),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Mobile & OTP Verification',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                if (_isMobileVerified) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified, size: 12, color: Color(0xFF10B981)),
                                        SizedBox(width: 4),
                                        Text('OTP Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Mobile Number',
                                hintText: 'Enter mobile number',
                                prefixIcon: const Icon(Icons.phone_iphone_outlined, color: Color(0xFF0066FF)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              validator: FormValidators.validateMobile,
                            ),
                            const SizedBox(height: 16),

                            // 6-DIGIT OTP BLOCKS + CLICKABLE RESEND OTP
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Enter 6-Digit OTP',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                                ),
                                GestureDetector(
                                  onTap: _resendOtp,
                                  child: const Text(
                                    'Resend OTP',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0066FF)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(6, (index) {
                                  return Container(
                                    width: 44,
                                    height: 52,
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    child: TextFormField(
                                      controller: _otpControllers[index],
                                      focusNode: _otpFocusNodes[index],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      textAlign: TextAlign.center,
                                      maxLength: 1,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A2540),
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFF0066FF)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFF0066FF), width: 2),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        if (val.isNotEmpty && index < 5) {
                                          _otpFocusNodes[index + 1].requestFocus();
                                        } else if (val.isEmpty && index > 0) {
                                          _otpFocusNodes[index - 1].requestFocus();
                                        }
                                      },
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Verify Mobile Button
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: _verifyMobileOtp,
                                icon: Icon(_isMobileVerified ? Icons.check_circle : Icons.verified_outlined, size: 18),
                                label: Text(
                                  _isMobileVerified ? 'Mobile OTP Verified ✓' : 'Verify Mobile OTP',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isMobileVerified ? const Color(0xFF10B981) : const Color(0xFF0066FF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ref.read(authKycProvider.notifier).updateStep(1);
                                    context.go('/login');
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Color(0xFF0066FF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
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
          ],
        ),
      ),
    );
  }
}
