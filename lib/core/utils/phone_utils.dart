/// Utility functions for sanitizing and formatting mobile phone numbers across Finomos.
class PhoneUtils {
  /// Strips any detached prefixes (e.g. "detached_1793798031941_7207535810"),
  /// removes international prefix "+91", leading zeroes, spaces, and special symbols,
  /// returning a clean, dynamic 10-digit mobile number.
  static String sanitize(String? phone) {
    if (phone == null || phone.trim().isEmpty) return '';

    String cleaned = phone.trim();

    // 1. Check for backend detached session format: detached_<timestamp>_<phone>
    final detachedMatch = RegExp(r'detached_\d+_([0-9+]+)').firstMatch(cleaned);
    if (detachedMatch != null) {
      cleaned = detachedMatch.group(1)!;
    }

    // 2. Remove all formatting whitespace, hyphens, parentheses, and periods
    cleaned = cleaned.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');

    // 3. Remove international "+91" prefix
    if (cleaned.startsWith('+91')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    } else if (cleaned.startsWith('0') && cleaned.length == 11) {
      cleaned = cleaned.substring(1);
    }

    return cleaned;
  }

  /// Formats clean mobile number with +91 country prefix for display
  static String formatWithCountryCode(String? phone) {
    final clean = sanitize(phone);
    if (clean.isEmpty) return '';
    if (clean.length == 10) {
      return '+91 ${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return '+91 $clean';
  }

  /// Masks middle digits for security & privacy display: e.g. "••••••5810"
  static String mask(String? phone) {
    final clean = sanitize(phone);
    if (clean.length < 4) return clean;
    final last4 = clean.substring(clean.length - 4);
    return '••••••$last4';
  }
}

