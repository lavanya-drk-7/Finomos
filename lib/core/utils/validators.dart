class FormValidators {
  /// Validates full name: non-empty, min 3 chars, letters and spaces only
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Full name must be at least 3 characters';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s.'-]+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Full name should only contain letters and spaces';
    }
    return null;
  }

  /// Validates email address format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email ID is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password: non-empty, min 6 characters
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates mobile number: 10 digits or 12 digits (+91 prefix)
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
        return 'Mobile number should start with 6, 7, 8, or 9';
      }
      return null;
    } else if (digits.length == 12 && digits.startsWith('91')) {
      final local = digits.substring(2);
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(local)) {
        return 'Mobile number should start with 6, 7, 8, or 9';
      }
      return null;
    }
    return 'Please enter a valid 10-digit mobile number';
  }

  /// Validates 6-digit numeric OTP
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter 6-digit OTP';
    }
    final trimmed = value.trim();
    if (trimmed.length != 6 || !RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return 'Please enter complete 6-digit OTP';
    }
    return null;
  }
}
