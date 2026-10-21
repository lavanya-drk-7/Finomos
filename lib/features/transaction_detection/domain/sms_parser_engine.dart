import 'dart:convert';
import 'detected_transaction_model.dart';

class ParseResult {
  final bool isSuccess;
  final DetectedTransaction? transaction;
  final String? errorMessage;

  const ParseResult({
    required this.isSuccess,
    this.transaction,
    this.errorMessage,
  });
}

class SmsParserEngine {
  static const List<String> supportedBanks = [
    'HDFC Bank',
    'State Bank of India',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'IndusInd Bank',
  ];

  /// Parses a bank SMS message text and returns an intelligent ParseResult.
  static ParseResult parse(
    String rawSms, {
    String sender = 'BANK-ALERT',
    DateTime? receiveTime,
    List<String> knownLinkedBanks = const [
      'HDFC Bank ••••4587',
      'State Bank of India ••••4821',
      'ICICI Bank ••••9021',
      'Axis Bank ••••3301',
    ],
  }) {
    final text = rawSms.trim();
    if (text.isEmpty) {
      return const ParseResult(
        isSuccess: false,
        errorMessage: 'Empty SMS text provided.',
      );
    }

    final now = receiveTime ?? DateTime.now();

    // 1. Extract Amount
    final amount = _extractAmount(text);
    if (amount == null || amount <= 0) {
      return const ParseResult(
        isSuccess: false,
        errorMessage: 'Could not extract a valid transaction amount from the message.',
      );
    }

    // 2. Identify Transaction Direction / Classification
    final classification = _classifyTransaction(text);

    // 3. Extract Bank Name and Account Identifier
    final bankInfo = _extractBankAndAccount(text, knownLinkedBanks);

    // 4. Extract Reference ID / UTR / Txn ID
    final refId = _extractReferenceId(text);

    // 5. Extract Merchant or Source
    final merchant = _extractMerchant(text);

    // 6. Detect Payment Method
    final paymentMethod = _detectPaymentMethod(text);

    // 7. Suggest Category
    final suggestedCat = _suggestCategory(text, merchant, classification);

    // 8. Generate Deduplication Fingerprint
    final fingerprint = _generateFingerprint(
      amount: amount,
      bank: bankInfo.bankName,
      account: bankInfo.accountIdentifier,
      classification: classification,
      refId: refId,
      date: now,
    );

    // Description summary
    final description = _generateDescription(
      classification: classification,
      amount: amount,
      merchant: merchant,
      bankName: bankInfo.bankName,
    );

    final txn = DetectedTransaction(
      id: 'txn_sms_${now.millisecondsSinceEpoch}_${(amount * 100).toInt() % 1000}',
      rawSmsBody: text,
      sender: sender,
      timestamp: now,
      type: classification,
      amount: amount,
      currency: '₹',
      bankName: bankInfo.bankName,
      accountIdentifier: bankInfo.accountIdentifier,
      referenceId: refId,
      merchantOrSource: merchant,
      paymentMethod: paymentMethod,
      suggestedCategory: suggestedCat,
      description: description,
      source: DetectionSource.sms,
      status: DetectedTransactionStatus.pendingReview,
      confidenceScore: _calculateConfidence(amount, bankInfo.bankName, refId, merchant),
      duplicateFingerprint: fingerprint,
      createdAt: now,
    );

    return ParseResult(
      isSuccess: true,
      transaction: txn,
    );
  }

  /// Extracts Amount with support for Rs., INR, ₹, with commas and decimals.
  static double? _extractAmount(String text) {
    // Patterns:
    // "Rs. 1,000", "Rs 5,000.00", "INR 2,500", "₹10,000.50", "credited with Rs.1500"
    final regex = RegExp(
      r'(?:(?:Rs\.?|INR|₹)\s*|amount\s*(?:of\s*)?(?:Rs\.?|INR|₹)?\s*)([0-9]{1,3}(?:,[0-9]{2,3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    );

    final match = regex.firstMatch(text);
    if (match != null && match.group(1) != null) {
      final clean = match.group(1)!.replaceAll(',', '');
      return double.tryParse(clean);
    }

    // Secondary fallback: "debited by 1000.00" or "spent 2500"
    final fallbackRegex = RegExp(
      r'(?:debited\s*(?:by|for)?|credited\s*(?:by|for)?|spent|paid)\s*(?:Rs\.?|INR|₹)?\s*([0-9]+(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    );
    final fallbackMatch = fallbackRegex.firstMatch(text);
    if (fallbackMatch != null && fallbackMatch.group(1) != null) {
      return double.tryParse(fallbackMatch.group(1)!);
    }

    return null;
  }

  /// Classifies message into Expense, Income, Transfer, Refund, or ReviewRequired.
  static TransactionClassification _classifyTransaction(String text) {
    final lower = text.toLowerCase();

    // Check for internal transfer keywords first
    if (lower.contains('transfer to own') ||
        lower.contains('self transfer') ||
        lower.contains('internal transfer') ||
        (lower.contains('transfer') && lower.contains('between your accounts'))) {
      return TransactionClassification.transfer;
    }

    // Check for refund or reversal
    if (lower.contains('refund') ||
        lower.contains('reversed') ||
        lower.contains('reversal') ||
        lower.contains('cashback credited')) {
      return TransactionClassification.refund;
    }

    // Check for Debits (Expenses, EMI, purchases)
    final isDebit = lower.contains('debit') ||
        lower.contains('spent') ||
        lower.contains('paid') ||
        lower.contains('withdrawn') ||
        lower.contains('deducted') ||
        lower.contains('sent to') ||
        lower.contains('purchase of');

    // Check for Credits (Salary, Income, Deposits)
    final isCredit = lower.contains('credit') ||
        lower.contains('deposited') ||
        lower.contains('received') ||
        lower.contains('added to your account');

    if (isDebit && !isCredit) {
      return TransactionClassification.expense;
    } else if (isCredit && !isDebit) {
      return TransactionClassification.income;
    }

    // Ambiguous or both mentioned (e.g. "debited from X and credited to Y")
    if (lower.contains('debited from') && lower.contains('credited to')) {
      return TransactionClassification.transfer;
    }

    return TransactionClassification.reviewRequired;
  }

  /// Extracts Bank Name and Account identifier, checking against linked accounts.
  static ({String bankName, String accountIdentifier}) _extractBankAndAccount(
    String text,
    List<String> knownLinkedBanks,
  ) {
    final lower = text.toLowerCase();
    String detectedBank = 'Linked Bank Account';
    String detectedAccount = '••••4587';

    // 1. Check for specific bank names
    if (lower.contains('hdfc')) {
      detectedBank = 'HDFC Bank';
      detectedAccount = '••••4587';
    } else if (lower.contains('sbi') || lower.contains('state bank')) {
      detectedBank = 'State Bank of India';
      detectedAccount = '••••4821';
    } else if (lower.contains('icici')) {
      detectedBank = 'ICICI Bank';
      detectedAccount = '••••9021';
    } else if (lower.contains('axis')) {
      detectedBank = 'Axis Bank';
      detectedAccount = '••••3301';
    } else if (lower.contains('kotak')) {
      detectedBank = 'Kotak Mahindra Bank';
      detectedAccount = '••••5520';
    } else if (lower.contains('pnb') || lower.contains('punjab national')) {
      detectedBank = 'Punjab National Bank';
      detectedAccount = '••••7812';
    }

    // 2. Extract account digits if present in SMS (e.g. "A/c **4587", "A/C XXXXXX4821", "Card ending 9021")
    final accRegex = RegExp(
      r'(?:a/c|acct|acc|card|ending|account)\s*(?:no\.?)?\s*[:\s]*([X\*]*[0-9]{3,6})',
      caseSensitive: false,
    );
    final match = accRegex.firstMatch(text);
    if (match != null && match.group(1) != null) {
      final rawDigits = match.group(1)!;
      final digits = rawDigits.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isNotEmpty) {
        detectedAccount = '••••$digits';
      }
    }

    // Match with user's known linked banks by bank name OR by account digits
    final digitsOnly = detectedAccount.replaceAll(RegExp(r'[^0-9]'), '');
    for (final linked in knownLinkedBanks) {
      final bankPart = linked.split('•').first.trim();
      final digitPart = linked.replaceAll(RegExp(r'[^0-9]'), '');

      // Check if account digits match
      if (digitsOnly.isNotEmpty && digitPart.isNotEmpty && digitPart.endsWith(digitsOnly)) {
        detectedBank = bankPart;
        detectedAccount = '••••$digitsOnly';
        break;
      }

      // Check if bank name matches
      if (detectedBank != 'Linked Bank Account' && linked.toLowerCase().contains(detectedBank.toLowerCase())) {
        detectedBank = bankPart;
        if (linked.contains('•')) {
          detectedAccount = '••••${linked.split('•').last.trim()}';
        }
        break;
      }
    }

    return (bankName: detectedBank, accountIdentifier: detectedAccount);
  }

  /// Extracts reference ID / UTR / Txn number.
  static String? _extractReferenceId(String text) {
    final regex = RegExp(
      r'(?:ref(?:\s*no\.?)?|utr(?:\s*no\.?)?|txn(?:\s*id)?|rrn|upi\s*ref|upi/)\s*[:\s/]*([A-Za-z0-9]{6,22})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match != null && match.group(1) != null) {
      return match.group(1);
    }
    return null;
  }

  /// Extracts merchant or source name.
  static String? _extractMerchant(String text) {
    // E.g. "spent at SWIGGY", "paid to Zomato", "transfer from TECH CORP SALARY", "to VPA cafe@upi"
    final regex = RegExp(
      r'(?:at|paid to|sent to|to VPA|transfer from|from)\s+([A-Za-z0-9\s&@\.-]{2,35}?)(?:\s+(?:on|ref|utr|avl|bal|using|via|\.|$))',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match != null && match.group(1) != null) {
      final m = match.group(1)!.trim();
      if (!m.toLowerCase().startsWith('your') &&
          !m.toLowerCase().startsWith('a/c') &&
          m.length > 2) {
        return m;
      }
    }
    return null;
  }

  /// Detects payment method: UPI, Credit Card, Debit Card, Net Banking, etc.
  static String _detectPaymentMethod(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('upi') || lower.contains('vpa') || lower.contains('@')) {
      return 'UPI';
    }
    if (lower.contains('credit card') || lower.contains('card ending') || lower.contains('spent on card')) {
      return 'Credit Card';
    }
    if (lower.contains('debit card') || lower.contains('atm') || lower.contains('pos')) {
      return 'Debit Card';
    }
    if (lower.contains('netbanking') || lower.contains('net banking') || lower.contains('neft') || lower.contains('rtgs') || lower.contains('imps')) {
      return 'Net Banking';
    }
    if (lower.contains('auto debit') || lower.contains('mandate') || lower.contains('nach')) {
      return 'Auto Debit';
    }
    return 'UPI'; // Default popular method in India
  }

  /// Suggests category based on merchant and description keywords.
  static String _suggestCategory(
    String text,
    String? merchant,
    TransactionClassification classification,
  ) {
    final combined = '${text.toLowerCase()} ${merchant?.toLowerCase() ?? ''}';

    if (classification == TransactionClassification.income) {
      if (combined.contains('salary') || combined.contains('payroll') || combined.contains('stipend')) {
        return 'Salary';
      }
      if (combined.contains('freelance') || combined.contains('upwork') || combined.contains('fiverr')) {
        return 'Freelance Income';
      }
      if (combined.contains('dividend') || combined.contains('zerodha') || combined.contains('groww') || combined.contains('interest')) {
        return 'Interest & Investments';
      }
      if (combined.contains('rent') || combined.contains('tenant')) {
        return 'Rental Income';
      }
      if (combined.contains('refund') || combined.contains('cashback')) {
        return 'Refunds';
      }
      return 'Salary';
    }

    // Expense Categories
    if (combined.contains('restaurant') ||
        combined.contains('swiggy') ||
        combined.contains('zomato') ||
        combined.contains('cafe') ||
        combined.contains('dining') ||
        combined.contains('mcdonald') ||
        combined.contains('starbucks') ||
        combined.contains('food') ||
        combined.contains('toit') ||
        combined.contains('barbeque')) {
      return 'Food & Dining';
    }

    if (combined.contains('grocer') ||
        combined.contains('zepto') ||
        combined.contains('blinkit') ||
        combined.contains('bigbasket') ||
        combined.contains('instamart') ||
        combined.contains('supermarket') ||
        combined.contains('provisions') ||
        combined.contains('dmart') ||
        combined.contains('nature basket')) {
      return 'Groceries';
    }

    if (combined.contains('uber') ||
        combined.contains('ola') ||
        combined.contains('rapido') ||
        combined.contains('metro') ||
        combined.contains('fuel') ||
        combined.contains('petrol') ||
        combined.contains('shell') ||
        combined.contains('bpcl') ||
        combined.contains('fastag') ||
        combined.contains('irctc') ||
        combined.contains('flight')) {
      return 'Transportation';
    }

    if (combined.contains('amazon') ||
        combined.contains('flipkart') ||
        combined.contains('myntra') ||
        combined.contains('zara') ||
        combined.contains('shopping') ||
        combined.contains('retail') ||
        combined.contains('lifestyle')) {
      return 'Shopping';
    }

    if (combined.contains('rent') ||
        combined.contains('landlord') ||
        combined.contains('housing') ||
        combined.contains('maintenance')) {
      return 'Rent & Housing';
    }

    if (combined.contains('bescom') ||
        combined.contains('electricity') ||
        combined.contains('act fibernet') ||
        combined.contains('wifi') ||
        combined.contains('airtel') ||
        combined.contains('jio') ||
        combined.contains('utility') ||
        combined.contains('water bill')) {
      return 'Utilities';
    }

    if (combined.contains('apollo') ||
        combined.contains('pharmacy') ||
        combined.contains('hospital') ||
        combined.contains('medplus') ||
        combined.contains('doctor') ||
        combined.contains('clinic') ||
        combined.contains('health')) {
      return 'Healthcare';
    }

    if (combined.contains('netflix') ||
        combined.contains('spotify') ||
        combined.contains('prime') ||
        combined.contains('bookmyshow') ||
        combined.contains('cinema') ||
        combined.contains('pvr')) {
      return 'Entertainment';
    }

    if (combined.contains('emi') ||
        combined.contains('loan') ||
        combined.contains('auto finance') ||
        combined.contains('mortgage')) {
      return 'Loan Payments';
    }

    return 'Food & Dining'; // Default fallback
  }

  /// Calculates a duplicate prevention fingerprint.
  static String _generateFingerprint({
    required double amount,
    required String bank,
    required String account,
    required TransactionClassification classification,
    String? refId,
    required DateTime date,
  }) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final normalized = [
      amount.toStringAsFixed(2),
      bank.trim().toLowerCase(),
      account.replaceAll(RegExp(r'[^0-9]'), ''),
      classification.name,
      refId?.trim().toLowerCase() ?? dateStr,
    ].join('|');

    return base64UrlEncode(utf8.encode(normalized));
  }

  /// Generates human-friendly description.
  static String _generateDescription({
    required TransactionClassification classification,
    required double amount,
    String? merchant,
    required String bankName,
  }) {
    final amtStr = '₹${amount.toStringAsFixed(0)}';
    if (merchant != null && merchant.isNotEmpty) {
      if (classification == TransactionClassification.income) {
        return '$merchant - $amtStr received into $bankName';
      }
      return '$merchant payment via $bankName';
    }
    if (classification == TransactionClassification.income) {
      return 'Credit of $amtStr to $bankName';
    }
    return 'Debit of $amtStr from $bankName';
  }

  /// Calculates parser confidence score.
  static double _calculateConfidence(
    double amount,
    String bankName,
    String? refId,
    String? merchant,
  ) {
    double score = 0.70;
    if (amount > 0) score += 0.10;
    if (bankName != 'Linked Bank Account') score += 0.10;
    if (refId != null && refId.isNotEmpty) score += 0.05;
    if (merchant != null && merchant.isNotEmpty) score += 0.05;
    return score.clamp(0.0, 1.0);
  }
}
