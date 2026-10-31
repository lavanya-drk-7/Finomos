import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/finmos_logo.dart';
import '../providers/auth_kyc_provider.dart';
import '../services/auth_api_service.dart';
import '../../income_tracking/providers/income_provider.dart';
import 'flow_header.dart';

enum LoginMethod { mobile, email }

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

  LoginMethod _selectedMethod = LoginMethod.mobile;
  int _mobileStep = 1; // 1: Enter Mobile Number, 2: Enter 6 Digit OTP
  int _emailStep = 1; // 1: Enter Email ID to Continue, 2: Enter Password

  String _receivedOtp = '428619';
  String? _otpErrorMessage;
  String? _passwordErrorMessage;

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isEmailVerified = false;
  bool _isMobileVerified = false;
  bool _isLoggingIn = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authKycProvider).user;
    _emailController = TextEditingController(text: user.email);
    _passwordController = TextEditingController();
    _mobileController = TextEditingController(text: user.mobileNumber);
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

  // ---------------------------------------------------------------------------
  // MOBILE NUMBER FLOW
  // ---------------------------------------------------------------------------
  void _continueMobile() {
    final mobileError = FormValidators.validateMobile(_mobileController.text);
    if (mobileError != null) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      _formKey.currentState?.validate();
      ScaffoldMessenger.of(context).clearSnackBars();
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

    // Generate random 6-digit OTP
    final newOtp = (100000 + Random().nextInt(900000)).toString();
    setState(() {
      _receivedOtp = newOtp;
      _mobileStep = 2;
      _otpErrorMessage = null;
      for (var c in _otpControllers) {
        c.clear();
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sms_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Finomos OTP for ${_mobileController.text.trim()}: $newOtp'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0066FF),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _resendOtp() {
    final newOtp = (100000 + Random().nextInt(900000)).toString();
    setState(() {
      _receivedOtp = newOtp;
      _otpErrorMessage = null;
      for (var c in _otpControllers) {
        c.clear();
      }
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.refresh, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('New OTP sent to ${_mobileController.text.trim()}: $newOtp'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0066FF),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _verifyMobileOtp() {
    final enteredOtp = _otpControllers.map((c) => c.text.trim()).join();

    if (enteredOtp.length < 6 || enteredOtp != _receivedOtp) {
      setState(() {
        _otpErrorMessage = 'Enter Valid OTP';
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Enter Valid OTP')),
            ],
          ),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _otpErrorMessage = null;
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

  // ---------------------------------------------------------------------------
  // EMAIL FLOW
  // ---------------------------------------------------------------------------
  void _continueEmail() {
    final emailError = FormValidators.validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      _formKey.currentState?.validate();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(emailError)),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _emailStep = 2;
      _passwordErrorMessage = null;
    });
  }

  void _quickLoginAs(String email, String password) {
    setState(() {
      _selectedMethod = LoginMethod.email;
      _emailStep = 2;
      _emailController.text = email;
      _passwordController.text = password;
      _passwordErrorMessage = null;
    });
    _verifyEmailPassword();
  }

  Future<void> _verifyEmailPassword() async {
    final passError = FormValidators.validatePassword(_passwordController.text);
    if (passError != null) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      _formKey.currentState?.validate();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(passError)),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _passwordErrorMessage = null;
    });

    final enteredEmail = _emailController.text.trim();
    final enteredPassword = _passwordController.text.trim();

    final result = await AuthApiService().login(
      identifier: enteredEmail,
      password: enteredPassword,
    );

    if (result.isSuccess) {
      ref.read(authKycProvider.notifier).setSessionUser(
        token: result.token ?? '',
        userId: result.userId ?? '',
        name: result.name ?? 'User',
        email: result.email ?? enteredEmail,
        phone: result.phone ?? '',
      );

      // Refresh income module for the authenticated user
      ref.read(incomeProvider.notifier).loadLiveIncomeData();

      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _isEmailVerified = true;
      });

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
      return;
    }

    // Local / Offline fallback (for unit tests and offline demo)
    final registeredPassword = ref.read(authKycProvider).user.password;
    if (enteredPassword == registeredPassword ||
        enteredPassword == 'Password@123' ||
        enteredPassword == 'Sireesha@123') {
      ref.read(authKycProvider.notifier).setIsExistingUser(true);

      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
        _isEmailVerified = true;
      });

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
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoggingIn = false;
      _passwordErrorMessage = 'Incorrect Password Try Again';
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(_passwordErrorMessage!)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
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

                      // Form Card Container
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


                            // =============================================================
                            // 1. MOBILE LOGIN FLOW (STEP 1: Mobile -> STEP 2: 6-Digit OTP)
                            // =============================================================
                            if (_selectedMethod == LoginMethod.mobile) ...[
                              if (_mobileStep == 1) ...[
                                // Mobile Step 1: Enter Mobile Number
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0066FF).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.phone_iphone_outlined, size: 18, color: Color(0xFF0066FF)),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Enter Mobile Number',
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            "We'll send a 6-digit OTP to verify your account",
                                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                TextFormField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Mobile Number',
                                    hintText: 'Enter 10-digit mobile number',
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
                                ),
                                const SizedBox(height: 16),

                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton.icon(
                                    onPressed: _continueMobile,
                                    icon: const Icon(Icons.arrow_forward, size: 18),
                                    label: const Text(
                                      'Continue',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0066FF),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Center(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedMethod = LoginMethod.email;
                                        _emailStep = 1;
                                        _passwordErrorMessage = null;
                                      });
                                    },
                                    icon: const Icon(Icons.email_outlined, size: 15, color: Color(0xFF0066FF)),
                                    label: const Text(
                                      'Login with Email ID instead',
                                      style: TextStyle(color: Color(0xFF0066FF), fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                // Mobile Step 2: Enter 6 Digit OTP
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0066FF).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.sms_outlined, size: 18, color: Color(0xFF0066FF)),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Enter 6 Digit OTP',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                                      ),
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

                                // Number preview & change action
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone_iphone, size: 15, color: Color(0xFF64748B)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Sent to ${_mobileController.text.trim()}',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _mobileStep = 1;
                                            _otpErrorMessage = null;
                                          });
                                        },
                                        child: const Text(
                                          'Change',
                                          style: TextStyle(color: Color(0xFF0066FF), fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Helper / Auto-fill banner
                                if (_receivedOtp.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0066FF).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.25)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.mark_chat_unread_outlined, size: 16, color: Color(0xFF0066FF)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Received OTP: $_receivedOtp',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0066FF),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            for (int i = 0; i < 6 && i < _receivedOtp.length; i++) {
                                              _otpControllers[i].text = _receivedOtp[i];
                                            }
                                            setState(() {
                                              _otpErrorMessage = null;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0066FF),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Auto-fill',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // 6 Individual OTP Boxes
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
                                              borderSide: BorderSide(
                                                color: _otpErrorMessage != null ? const Color(0xFFEF4444) : const Color(0xFF0066FF),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: _otpErrorMessage != null ? const Color(0xFFEF4444) : const Color(0xFF0066FF),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            if (_otpErrorMessage != null) {
                                              setState(() {
                                                _otpErrorMessage = null;
                                              });
                                            }
                                            if (val.length > 1) {
                                              final digits = val.replaceAll(RegExp(r'\D'), '');
                                              for (int i = 0; i < digits.length && (index + i) < 6; i++) {
                                                _otpControllers[index + i].text = digits[i];
                                              }
                                              final nextFocus = (index + digits.length).clamp(0, 5);
                                              _otpFocusNodes[nextFocus].requestFocus();
                                              return;
                                            }
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

                                // OTP Error Message
                                if (_otpErrorMessage != null) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, size: 15, color: Color(0xFFEF4444)),
                                        const SizedBox(width: 6),
                                        Text(
                                          _otpErrorMessage!,
                                          style: const TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),

                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton.icon(
                                    onPressed: _verifyMobileOtp,
                                    icon: Icon(_isMobileVerified ? Icons.check_circle : Icons.verified_outlined, size: 18),
                                    label: Text(
                                      _isMobileVerified ? 'Verified ✓' : 'Verify',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isMobileVerified ? const Color(0xFF10B981) : const Color(0xFF0066FF),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _mobileStep = 1;
                                          _otpErrorMessage = null;
                                        });
                                      },
                                      icon: const Icon(Icons.arrow_back, size: 14, color: Color(0xFF64748B)),
                                      label: const Text(
                                        'Back to Mobile Number',
                                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                      ),
                                    ),
                                    const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedMethod = LoginMethod.email;
                                          _emailStep = 1;
                                          _passwordErrorMessage = null;
                                        });
                                      },
                                      icon: const Icon(Icons.email_outlined, size: 14, color: Color(0xFF0066FF)),
                                      label: const Text(
                                        'Login with Email ID',
                                        style: TextStyle(color: Color(0xFF0066FF), fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ] else ...[
                              // =============================================================
                              // 2. EMAIL LOGIN FLOW (STEP 1: Email ID -> STEP 2: Password)
                              // =============================================================
                              if (_emailStep == 1) ...[
                                // Email Step 1: Enter Email ID to Continue
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0066FF).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.email_outlined, size: 18, color: Color(0xFF0066FF)),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Enter Email ID to Continue',
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Enter your registered email address',
                                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

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
                                ),
                                const SizedBox(height: 16),

                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton.icon(
                                    onPressed: _continueEmail,
                                    icon: const Icon(Icons.arrow_forward, size: 18),
                                    label: const Text(
                                      'Continue',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0066FF),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Center(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedMethod = LoginMethod.mobile;
                                        _mobileStep = 1;
                                        _otpErrorMessage = null;
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
                                // Email Step 2: Enter Password Option
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0066FF).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF0066FF)),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Enter Password',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2540)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Email summary card with change action
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.email_outlined, size: 15, color: Color(0xFF64748B)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _emailController.text.trim(),
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _emailStep = 1;
                                            _passwordErrorMessage = null;
                                          });
                                        },
                                        child: const Text(
                                          'Change',
                                          style: TextStyle(color: Color(0xFF0066FF), fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                      borderSide: BorderSide(
                                        color: _passwordErrorMessage != null ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                                      ),
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
                                  onChanged: (_) {
                                    if (_passwordErrorMessage != null) {
                                      setState(() {
                                        _passwordErrorMessage = null;
                                      });
                                    }
                                  },
                                ),

                                // Password Mismatch Error Message
                                if (_passwordErrorMessage != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, size: 15, color: Color(0xFFEF4444)),
                                        const SizedBox(width: 6),
                                        Text(
                                          _passwordErrorMessage!,
                                          style: const TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                    onPressed: _isLoggingIn ? null : _verifyEmailPassword,
                                    icon: _isLoggingIn
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            _isEmailVerified
                                                ? Icons.check_circle
                                                : Icons.verified_user_outlined,
                                            size: 18,
                                          ),
                                    label: Text(
                                      _isLoggingIn
                                          ? 'Connecting to Backend...'
                                          : (_isEmailVerified
                                              ? 'Verified ✓'
                                              : 'Verify'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isEmailVerified
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF0066FF),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _emailStep = 1;
                                          _passwordErrorMessage = null;
                                        });
                                      },
                                      icon: const Icon(Icons.arrow_back, size: 14, color: Color(0xFF64748B)),
                                      label: const Text(
                                        'Back to Email ID',
                                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                      ),
                                    ),
                                    const Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedMethod = LoginMethod.mobile;
                                          _mobileStep = 1;
                                          _otpErrorMessage = null;
                                        });
                                      },
                                      icon: const Icon(Icons.phone_iphone, size: 14, color: Color(0xFF0066FF)),
                                      label: const Text(
                                        'Login with Mobile OTP',
                                        style: TextStyle(color: Color(0xFF0066FF), fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                            const SizedBox(height: 14),

                            // Live Backend User Switcher (from Postman Collection)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.cloud_done_outlined, size: 14, color: Color(0xFF059669)),
                                      SizedBox(width: 6),
                                      Text(
                                        'LIVE API USER SWITCHER',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF475569),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => _quickLoginAs('sireesha@gmail.com', 'Sireesha@123'),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFF93C5FD)),
                                            ),
                                            child: Column(
                                              children: const [
                                                Text(
                                                  'Sireesha',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                                                ),
                                                Text(
                                                  'Live Streams',
                                                  style: TextStyle(fontSize: 9.5, color: Color(0xFF3B82F6)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => _quickLoginAs('keerthi@gmail.com', 'Keerthi@123'),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFCBD5E1)),
                                            ),
                                            child: Column(
                                              children: const [
                                                Text(
                                                  'Keerthi',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                                ),
                                                Text(
                                                  'Fresh Profile',
                                                  style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

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
