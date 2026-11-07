import 'dart:convert';
import 'dart:io';

/// Fast, synchronous local cache service for Stale-While-Revalidate data delivery.
/// Caches the latest dynamic API payloads in memory and persists to local disk.
class LocalCacheService {
  static final LocalCacheService _instance = LocalCacheService._internal();
  factory LocalCacheService() => _instance;

  LocalCacheService._internal() {
    _initDefaultSeeds();
  }

  final Map<String, dynamic> _memoryCache = {};

  void _initDefaultSeeds() {
    // Only set baseline default seeds if there is NO persisted disk cache file for that key.
    // If a disk file exists (including empty lists/records deleted by the user), disk state is preserved.
    void seed(String key, dynamic data) {
      try {
        final file = _getCacheFile(key);
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          _memoryCache[key] = jsonDecode(content);
          return;
        }
      } catch (_) {}
      _memoryCache[key] = data;
    }

    seed('income_summary', {
      'totalMonthlyIncome': 0.0,
      'activeMonthlyIncome': 0.0,
      'passiveMonthlyIncome': 0.0,
      'windfallTotalIncome': 0.0,
      'totalAnnualIncome': 0.0,
      'stabilityScore': 0,
      'stabilityRating': 'Stable',
      'passiveRatio': 0.0,
      'topDependencyPercent': 0.0,
      'topSource': '',
      'totalStreamsCount': 0,
      'autoTrackingEnabled': true,
      'aiCfoInsight': '',
    });

    seed('income_entries', {
      'entries': <Map<String, dynamic>>[],
      'pagination': {
        'currentPage': 1,
        'perPage': 20,
        'totalRecords': 0,
        'totalPages': 1,
      },
    });

    seed('expenses_summary', {
      'totalMonthlyExpenses': 0.0,
      'monthlyAverage': 0.0,
      'dailyAverage': 0.0,
      'monthlyInflow': 0.0,
      'netCashFlow': 0.0,
      'savingsRate': 0.0,
      'cashRunwayMonths': 0.0,
      'recurringExpenses': 0.0,
      'discretionaryExpenses': 0.0,
      'priorityBreakdown': {
        'P1_Survival': 0.0,
        'P2_Protection': 0.0,
        'P3_Obligations': 0.0,
        'P4_Growth': 0.0,
        'P5_Lifestyle': 0.0,
        'P6_Luxury': 0.0,
      },
    });

    seed('expenses_entries', {
      'data': {
        'expenses': <Map<String, dynamic>>[],
        'pagination': {
          'currentPage': 1,
          'perPage': 20,
          'totalRecords': 0,
          'totalPages': 1,
        },
      },
      'entries': <Map<String, dynamic>>[],
      'pagination': {
        'currentPage': 1,
        'perPage': 20,
        'totalRecords': 0,
        'totalPages': 1,
      },
    });

    seed('budgets_summary', {
      'totalBudget': 0.0,
      'totalSpent': 0.0,
      'remaining': 0.0,
      'overspent': 0.0,
      'overallUsage': 0.0,
      'activeCategoriesCount': 0,
      'totalBudgetsCount': 0,
      'exceededCount': 0,
      'warningCount': 0,
      'onTrackCount': 0,
      'aiCfoInsight':
          'Set up your budget allocations to track spending limits.',
    });

    seed('budgets_list', <Map<String, dynamic>>[]);
    seed('bank_accounts', <Map<String, dynamic>>[]);
    seed('bank_cards', <Map<String, dynamic>>[]);
    seed('bank_loans', <Map<String, dynamic>>[]);
    seed('bank_investments', <Map<String, dynamic>>[]);
    seed('bank_insurance', <Map<String, dynamic>>[]);
    seed('bank_upi', <Map<String, dynamic>>[]);
    seed('bank_wallets', <Map<String, dynamic>>[]);
    seed('kyc_status', {
      'kycStatus': 'VERIFIED',
      'isVerified': true,
      'redirectRoute': '/dashboard',
      'currentStep': 5,
      'totalSteps': 5,
      'timeline': [
        {
          'step': 1,
          'title': 'Account Registration',
          'description': 'Mobile OTP & Email credentials verified',
          'status': 'COMPLETED',
        },
        {
          'step': 2,
          'title': 'Personal & Residential Details',
          'description': 'DOB, gender, address, and city submitted',
          'status': 'COMPLETED',
        },
        {
          'step': 3,
          'title': 'KYC Identity Proofs',
          'description': 'PAN & Masked Aadhaar uploaded and hashed under Section 65B',
          'status': 'COMPLETED',
        },
        {
          'step': 4,
          'title': 'Statutory DPDP & AA Consents',
          'description': 'Data processing, account aggregator & legal policy acceptance',
          'status': 'COMPLETED',
        },
        {
          'step': 5,
          'title': 'CFO Locker & Live Sync',
          'description': 'Connected accounts and financial pillars verified',
          'status': 'COMPLETED',
        },
      ],
    });
    seed('kyc_documents', <Map<String, dynamic>>[]);
  }

  File _getCacheFile(String key) {
    final tempDir = Directory.systemTemp;
    bool isTest = false;
    try {
      isTest = Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {}
    final prefix = isTest ? 'finmos_cache_test_${pid}_' : 'finmos_cache_';
    return File('${tempDir.path}/$prefix$key.json');
  }

  void save(String key, dynamic jsonMap) {
    if (jsonMap == null) return;
    _memoryCache[key] = jsonMap;
    try {
      final file = _getCacheFile(key);
      file.writeAsStringSync(jsonEncode(jsonMap));
    } catch (_) {}
  }

  dynamic get(String key) {
    try {
      final file = _getCacheFile(key);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final parsed = jsonDecode(content);
        _memoryCache[key] = parsed;
        return parsed;
      }
    } catch (_) {}
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }
    return null;
  }

  void remove(String key) {
    _memoryCache.remove(key);
    try {
      final file = _getCacheFile(key);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }

  /// Save user profile record indexed by mobile number and email.
  /// Merges with existing record if already present so incremental updates are not lost.
  void saveUserProfileRecord({
    String? phone,
    String? email,
    String? userId,
    required Map<String, dynamic> data,
  }) {
    final cleanPhone = (phone != null && phone.isNotEmpty)
        ? phone.replaceAll(RegExp(r'\D'), '')
        : '';
    final cleanEmail = (email != null && email.isNotEmpty)
        ? email.trim().toLowerCase()
        : '';

    // Check for existing record
    Map<String, dynamic> merged = {};
    if (cleanPhone.isNotEmpty) {
      final existing = get('user_record_phone_$cleanPhone');
      if (existing is Map<String, dynamic>) merged.addAll(existing);
    }
    if (cleanEmail.isNotEmpty && merged.isEmpty) {
      final existing = get('user_record_email_$cleanEmail');
      if (existing is Map<String, dynamic>) merged.addAll(existing);
    }
    if (userId != null && userId.isNotEmpty && merged.isEmpty) {
      final existing = get('user_record_id_$userId');
      if (existing is Map<String, dynamic>) merged.addAll(existing);
    }

    // Merge new data over existing (ignoring empty string overrides if existing has a value)
    data.forEach((key, val) {
      if (val == null) return;
      if (val is String && val.trim().isEmpty && merged[key] != null && merged[key].toString().trim().isNotEmpty) {
        return; // don't overwrite non-empty with empty
      }
      merged[key] = val;
    });

    if (cleanPhone.isNotEmpty) merged['phone'] = cleanPhone;
    if (cleanEmail.isNotEmpty) merged['email'] = cleanEmail;
    if (userId != null && userId.isNotEmpty) merged['userId'] = userId;

    if (cleanPhone.isNotEmpty) {
      save('user_record_phone_$cleanPhone', merged);
      final last10 = cleanPhone.length > 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;
      if (last10 != cleanPhone) {
        save('user_record_phone_$last10', merged);
      }
    }
    if (cleanEmail.isNotEmpty) {
      save('user_record_email_$cleanEmail', merged);
    }
    if (userId != null && userId.isNotEmpty) {
      save('user_record_id_$userId', merged);
    }

    // Keep registry of all accounts on device
    final rawRegistry = get('registered_users_registry');
    final Map<String, dynamic> registry = (rawRegistry is Map<String, dynamic>)
        ? Map<String, dynamic>.from(rawRegistry)
        : {};
    if (cleanPhone.isNotEmpty) registry[cleanPhone] = merged;
    if (cleanEmail.isNotEmpty) registry[cleanEmail] = merged;
    save('registered_users_registry', registry);
  }

  /// Retrieve saved user profile record by phone, email, or user ID
  Map<String, dynamic>? getUserProfileRecord(String? identifier) {
    if (identifier == null || identifier.trim().isEmpty) return null;
    final trimmed = identifier.trim();

    if (trimmed.contains('@')) {
      final emailKey = trimmed.toLowerCase();
      final res = get('user_record_email_$emailKey');
      if (res is Map<String, dynamic>) return res;
    }

    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty) {
      final phoneKey = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
      final res = get('user_record_phone_$phoneKey');
      if (res is Map<String, dynamic>) return res;
      final resFull = get('user_record_phone_$digits');
      if (resFull is Map<String, dynamic>) return resFull;
    }

    final byId = get('user_record_id_$trimmed');
    if (byId is Map<String, dynamic>) return byId;

    // Check registry
    final rawRegistry = get('registered_users_registry');
    if (rawRegistry is Map<String, dynamic>) {
      if (rawRegistry.containsKey(trimmed)) {
        final val = rawRegistry[trimmed];
        if (val is Map<String, dynamic>) return val;
      }
      if (digits.isNotEmpty) {
        final phoneKey = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
        if (rawRegistry.containsKey(phoneKey)) {
          final val = rawRegistry[phoneKey];
          if (val is Map<String, dynamic>) return val;
        }
        if (rawRegistry.containsKey(digits)) {
          final val = rawRegistry[digits];
          if (val is Map<String, dynamic>) return val;
        }
      }
    }
    return null;
  }

  /// Sync active user keys into fast cache
  void syncActiveUserKeys(Map<String, dynamic> record) {
    final phone = record['phone']?.toString();
    final email = record['email']?.toString();
    final name = record['fullName']?.toString() ?? record['name']?.toString();
    final id = record['userId']?.toString() ?? record['id']?.toString();

    if (phone != null && phone.isNotEmpty) save('user_mobile_number', phone);
    if (email != null && email.isNotEmpty) save('user_email', email);
    if (name != null && name.isNotEmpty) save('user_name', name);
    if (id != null && id.isNotEmpty) save('user_id', id);

    if (record['employment'] is Map<String, dynamic>) {
      save('user_employment', record['employment']);
    }
    if (record['familyMembers'] is List) {
      save('user_family_members', record['familyMembers']);
    }
    if (record['household'] is Map<String, dynamic>) {
      save('user_household', record['household']);
    }
  }
}
