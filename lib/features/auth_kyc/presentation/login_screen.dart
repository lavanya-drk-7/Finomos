import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../providers/auth_kyc_provider.dart';
import 'flow_header.dart';

enum LoginMethod { email, mobile }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _mobileController;

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  LoginMethod _selectedMethod = LoginMethod.email;
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isEmailVerified = false;
  bool _isMobileVerified = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authKycProvider).user;
    _emailController = TextEditingController(text: user.email);
    _passwordController = TextEditingController(text: user.password);
    _mobileController = TextEditingController(text: user.mobileNumber);

    // Default 6-digit OTP pre-filled
    const defaultOtp = ['4', '2', '8', '6', '1', '9'];
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = defaultOtp[i];
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onEmailChanged(String val) {
    final trimmed = val.trim();
    if (RegExp(r'^\+?[0-9\s-]{4,}$').hasMatch(trimmed) && !trimmed.contains('@')) {
      setState(() {
        _selectedMethod = LoginMethod.mobile;
        _mobileController.text = trimmed;
      });
    }
  }

  void _onMobileChanged(String val) {
    final trimmed = val.trim();
    if (trimmed.contains('@')) {
      setState(() {
        _selectedMethod = LoginMethod.email;
        _emailController.text = trimmed;
      });
    }
  }

  void _verifyEmail() {
    final emailError = FormValidators.validateEmail(_emailController.text);
    final passError = FormValidators.validatePassword(_passwordController.text);

    if (emailError != null || passError != null) {
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
              Expanded(child: Text(emailError ?? passError ?? 'Please enter valid credentials!')),
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

    ref.read(authKycProvider.notifier).setIsExistingUser(true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Login Successful!'),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        try {
          context.go('/dashboard');
        } catch (_) {}
      }
    });
  }

  void _resendOtp() {
    final mobileError = FormValidators.validateMobile(_mobileController.text);
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

    // Generate new sample OTP digits
    const newOtp = ['8', '5', '2', '9', '4', '1'];
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = newOtp[i];
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.refresh, color: Colors.white),
            const SizedBox(width: 8),
            Text('New OTP sent to ${_mobileController.text}: 852941'),
          ],
        ),
        backgroundColor: const Color(0xFF0066FF),
      ),
    );
  }

  void _verifyMobileOtp() {
    final mobileError = FormValidators.validateMobile(_mobileController.text);
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
              Expanded(child: Text(mobileError ?? otpError ?? 'Please verify mobile number & OTP')),
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

    ref.read(authKycProvider.notifier).setIsExistingUser(true);
    ref.read(authKycProvider.notifier).setMobileVerified(true);
    ref.read(authKycProvider.notifier).setOtpVerified(true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.verified, color: Colors.white),
            SizedBox(width: 8),
            Text('Login Successful!'),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        try {
          context.go('/dashboard');
        } catch (_) {}
      }
    });
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidateMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Hero Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A2540), Color(0xFF0066FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0066FF).withOpacity(0.22),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const FinmosLogo(size: 38, showFooter: false, showTagline: false),
                            const SizedBox(height: 8),
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Login to your FINMOS account',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // -------------------------------------------------------------
                            // METHOD SELECTOR: EMAIL vs MOBILE
                            // -------------------------------------------------------------
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedMethod = LoginMethod.email;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(9),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 9),
                                        decoration: BoxDecoration(
                                          color: _selectedMethod == LoginMethod.email ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(9),
                                          boxShadow: _selectedMethod == LoginMethod.email
                                              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.email_outlined,
                                              size: 16,
                                              color: _selectedMethod == LoginMethod.email ? const Color(0xFF0066FF) : const Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Email ID',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: _selectedMethod == LoginMethod.email ? const Color(0xFF0066FF) : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedMethod = LoginMethod.mobile;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(9),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 9),
                                        decoration: BoxDecoration(
                                          color: _selectedMethod == LoginMethod.mobile ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(9),
                                          boxShadow: _selectedMethod == LoginMethod.mobile
                                              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.phone_iphone_outlined,
                                              size: 16,
                                              color: _selectedMethod == LoginMethod.mobile ? const Color(0xFF0066FF) : const Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Mobile Number',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: _selectedMethod == LoginMethod.mobile ? const Color(0xFF0066FF) : const Color(0xFF64748B),
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
                            const SizedBox(height: 16),

                            if (_selectedMethod == LoginMethod.email) ...[
                              // -------------------------------------------------------------
                              // 1. EMAIL ID & PASSWORD OPTION
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
                                  hintText: 'Enter your email address',
                                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0066FF)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                ),
                                validator: FormValidators.validateEmail,
                                onChanged: _onEmailChanged,
                              ),
                              const SizedBox(height: 12),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Enter password',
                                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0066FF)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
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
                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: const Color(0xFF0066FF),
                                          onChanged: (val) {
                                            setState(() {
                                              _rememberMe = val ?? true;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Remember Me',
                                        style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(authKycProvider.notifier).updateStep(10);
                                      context.go('/forgot-password');
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Color(0xFF0066FF),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: _verifyEmail,
                                  icon: Icon(_isEmailVerified ? Icons.check_circle : Icons.verified_user_outlined, size: 18),
                                  label: Text(
                                    _isEmailVerified ? 'Email Verified ✓' : 'Verify Email',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isEmailVerified ? const Color(0xFF10B981) : const Color(0xFF0066FF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedMethod = LoginMethod.mobile;
                                    });
                                  },
                                  icon: const Icon(Icons.phone_iphone, size: 15, color: Color(0xFF0066FF)),
                                  label: const Text(
                                    'Or Login with Mobile OTP instead',
                                    style: TextStyle(color: Color(0xFF0066FF), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // -------------------------------------------------------------
                              // 2. MOBILE NUMBER & 6-DIGIT OTP OPTION
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
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number',
                                  hintText: 'Enter mobile number',
                                  prefixIcon: const Icon(Icons.phone_iphone_outlined, color: Color(0xFF0066FF)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                ),
                                validator: FormValidators.validateMobile,
                                onChanged: _onMobileChanged,
                              ),
                              const SizedBox(height: 14),

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
                                      height: 50,
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
                              const SizedBox(height: 14),

                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: _verifyMobileOtp,
                                  icon: Icon(_isMobileVerified ? Icons.check_circle : Icons.verified_outlined, size: 18),
                                  label: Text(
                                    _isMobileVerified ? 'Mobile OTP Verified ✓' : 'Verify Mobile OTP',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isMobileVerified ? const Color(0xFF10B981) : const Color(0xFF0066FF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedMethod = LoginMethod.email;
                                    });
                                  },
                                  icon: const Icon(Icons.email_outlined, size: 15, color: Color(0xFF0066FF)),
                                  label: const Text(
                                    'Or Login with Email Credentials instead',
                                    style: TextStyle(color: Color(0xFF0066FF), fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),

                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ref.read(authKycProvider.notifier).setIsExistingUser(false);
                                    ref.read(authKycProvider.notifier).updateStep(1);
                                    context.go('/signup');
                                  },
                                  child: const Text(
                                    'Sign Up',
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

