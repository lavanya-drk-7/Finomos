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

  /// Validates bank account number (non-empty, minimum 4 digits)
  static String? validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bank Account Number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) {
      return 'Please enter a valid Bank Account Number (minimum 4 digits)';
    }
    return null;
  }

  /// Validates re-entered bank account number matches the original
  static String? validateReEnterAccountNumber(String? value, String? original) {
    if (value == null || value.trim().isEmpty) {
      return 'Please re-enter Bank Account Number to verify';
    }
    if (value.trim() != (original ?? '').trim()) {
      return 'Account Number Mismatch Enter Correctly!';
    }
    return null;
  }

  /// Validates branch IFSC code: non-empty, min 4 chars up to 11 chars
  static String? validateIfscCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Branch IFSC Code is required';
    }
    final trimmed = value.trim().toUpperCase();
    if (trimmed.length < 4) {
      return 'Branch IFSC Code must be at least 4 characters';
    }
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (trimmed.length == 11 && !ifscRegex.hasMatch(trimmed)) {
      return 'Please enter a valid 11-character IFSC Code (e.g. SBIN0001234)';
    }
    return null;
  }

  /// Validates balance amount: non-empty, valid positive or zero number
  static String? validateBalance(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Balance is required';
    }
    final clean = value.replaceAll(',', '').trim();
    final num = double.tryParse(clean);
    if (num == null) {
      return 'Please enter a valid numeric Balance amount';
    }
    if (num < 0) {
      return 'Balance cannot be negative';
    }
    return null;
  }

  /// Validates primary account holder name: non-empty, min 2 characters
  static String? validateAccountHolder(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Primary Account Holder Name is required';
    }
    if (value.trim().length < 2) {
      return 'Primary Account Holder Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates bank name when 'Others' or custom input
  static String? validateBankName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bank Name is required';
    }
    return null;
  }

  /// Validates card number: minimum 12 digits
  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card Number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 12) {
      return 'Card Number must be at least 12 digits (entered ${digits.length} digits)';
    }
    return null;
  }

  /// Validates CVV: 3 or 4 digits
  static String? validateCvv(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV Number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 3 || digits.length > 4) {
      return 'CVV Number must be 3 or 4 digits';
    }
    return null;
  }

  /// Validates income amount: non-empty, greater than 0
  static String? validateIncomeAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Income Amount is required';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final num = double.tryParse(clean);
    if (num == null || num <= 0) {
      return 'Please enter an amount greater than ₹0';
    }
    return null;
  }

  /// Validates income source name
  static String? validateIncomeSource(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Income Source Name is required';
    }
    return null;
  }

  /// Validates expense amount: non-empty, greater than 0
  static String? validateExpenseAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expense Amount is required';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final num = double.tryParse(clean);
    if (num == null || num <= 0) {
      return 'Please enter an amount greater than ₹0';
    }
    return null;
  }

  /// Validates expense description
  static String? validateExpenseDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expense Description is required';
    }
    return null;
  }

  /// Validates budget name
  static String? validateBudgetName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Budget Name is required';
    }
    return null;
  }

  /// Validates budget allocated amount
  static String? validateBudgetAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Budget Amount is required';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final num = double.tryParse(clean);
    if (num == null || num <= 0) {
      return 'Please enter a valid budget amount > 0';
    }
    return null;
  }

  /// Validates PAN card format: 5 letters, 4 digits, 1 letter
  static String? validatePanNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN Card Number is required';
    }
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid 10-character PAN (e.g. ABCDE1234F)';
    }
    return null;
  }

  /// Validates 6-digit Indian PIN Code
  static String? validatePinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN Code is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 6) {
      return 'Please enter 6-digit PIN code';
    }
    return null;
  }

  /// Generic required field validator
  static String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
