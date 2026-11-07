import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';
import '../domain/bank_aggregation_models.dart';

class BankAggregationApiService {
  final ApiClient _client = ApiClient();

  /// 1. GET Consolidated Bank Aggregation Summary across 5 financial pillars
  /// GET /api/v1/bank-aggregation/summary
  Future<BankAggregationSummary?> getSummary() async {
    try {
      final response = await _client.get(ApiConstants.bankAggregationSummary);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return BankAggregationSummary.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 2. POST Real-time Account Aggregator refresh across all 5 financial pillars
  /// POST /api/v1/bank-aggregation/sync-all
  Future<SyncAllPillarsResult?> syncAllPillars() async {
    try {
      final response = await _client.post(ApiConstants.bankAggregationSyncAll);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return SyncAllPillarsResult.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 3. GET IFSC Branch Details resolution & validation
  /// GET /api/v1/bank-aggregation/lookup/ifsc/:ifsc
  Future<IfscBranchDetails?> lookupIfsc(String ifsc) async {
    final cleanIfsc = ifsc.trim().toUpperCase();
    if (cleanIfsc.isEmpty) return null;
    try {
      final response = await _client.get(ApiConstants.bankAggregationLookupIfsc(cleanIfsc));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return IfscBranchDetails.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 4. GET Linked & Aggregated Bank Accounts List
  /// GET /api/v1/bank-aggregation/accounts?type=all
  Future<List<BankAccountItem>?> getAccounts({String type = 'all'}) async {
    try {
      final response = await _client.get(ApiConstants.bankAggregationAccountsQuery(type: type));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          final list = body['data'] as List<dynamic>;
          return list
              .whereType<Map<String, dynamic>>()
              .map((a) => BankAccountItem.fromJson(a))
              .toList();
        }
      }
    } catch (_) {}
    return null;
  }

  /// 5. POST Link & Verify new Bank Account via NPCI/IMPS penny-drop
  /// POST /api/v1/bank-aggregation/accounts
  Future<BankAccountItem?> linkBankAccount(LinkBankAccountRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.bankAggregationAccounts,
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return BankAccountItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 6. GET Single Bank Account Details with associated Debit Cards & Expenses
  /// GET /api/v1/bank-aggregation/accounts/:id
  Future<BankAccountItem?> getAccountById(String id) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.get(ApiConstants.bankAggregationAccountById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return BankAccountItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 7. PUT Update Bank Account Details (nickname, accountType)
  /// PUT /api/v1/bank-aggregation/accounts/:id
  Future<BankAccountItem?> updateBankAccount(String id, UpdateBankAccountRequest request) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.put(
        ApiConstants.bankAggregationAccountById(id),
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return BankAccountItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 8. POST Sync single Bank Account Balance
  /// POST /api/v1/bank-aggregation/accounts/:id/sync
  Future<SyncAccountBalanceResult?> syncAccountBalance(String id) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.post(ApiConstants.bankAggregationAccountSync(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return SyncAccountBalanceResult.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 9. DELETE Unlink and Disconnect Bank Account
  /// DELETE /api/v1/bank-aggregation/accounts/:id
  Future<bool> deleteBankAccount(String id) async {
    if (id.isEmpty) return false;
    try {
      final response = await _client.delete(ApiConstants.bankAggregationAccountById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // ---------------------------------------------------------------------------
  // CARDS (CREDIT & DEBIT) ENDPOINTS
  // ---------------------------------------------------------------------------

  /// 10. GET Cards List & Summary
  /// GET /api/v1/bank-aggregation/cards?type=all
  Future<CardsApiResponse?> getCards({String type = 'all'}) async {
    try {
      final response = await _client.get(ApiConstants.bankAggregationCardsQuery(type: type));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return CardsApiResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 11. POST Link Credit Card
  /// POST /api/v1/bank-aggregation/cards
  Future<CreditCardItem?> linkCreditCard(LinkCreditCardRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.bankAggregationCards,
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return CreditCardItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 12. GET Single Card by ID
  /// GET /api/v1/bank-aggregation/cards/:id
  Future<CreditCardItem?> getCardById(String id) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.get(ApiConstants.bankAggregationCardById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return CreditCardItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 13. PUT Update Card by ID
  /// PUT /api/v1/bank-aggregation/cards/:id
  Future<CreditCardItem?> updateCard(String id, UpdateCreditCardRequest request) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.put(
        ApiConstants.bankAggregationCardById(id),
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return CreditCardItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 14. DELETE Unlink Card by ID
  /// DELETE /api/v1/bank-aggregation/cards/:id
  Future<bool> deleteCard(String id) async {
    if (id.isEmpty) return false;
    try {
      final response = await _client.delete(ApiConstants.bankAggregationCardById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // ---------------------------------------------------------------------------
  // LOANS ENDPOINTS
  // ---------------------------------------------------------------------------

  /// 15. GET Loans List & Summary
  /// GET /api/v1/bank-aggregation/loans
  Future<LoansApiResponse?> getLoans() async {
    try {
      final response = await _client.get(ApiConstants.bankAggregationLoans);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return LoansApiResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 16. POST Link Loan Account
  /// POST /api/v1/bank-aggregation/loans
  Future<LoanAccountItem?> linkLoan(LinkLoanRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.bankAggregationLoans,
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return LoanAccountItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 17. PUT Update Loan by ID
  /// PUT /api/v1/bank-aggregation/loans/:id
  Future<LoanAccountItem?> updateLoan(String id, UpdateLoanRequest request) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.put(
        ApiConstants.bankAggregationLoanById(id),
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return LoanAccountItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 18. DELETE Unlink Loan by ID
  /// DELETE /api/v1/bank-aggregation/loans/:id
  Future<bool> deleteLoan(String id) async {
    if (id.isEmpty) return false;
    try {
      final response = await _client.delete(ApiConstants.bankAggregationLoanById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // ---------------------------------------------------------------------------
  // INVESTMENTS ENDPOINTS
  // ---------------------------------------------------------------------------

  /// 19. GET Investments List & Portfolio Summary
  /// GET /api/v1/bank-aggregation/investments
  Future<InvestmentsApiResponse?> getInvestments() async {
    try {
      final response = await _client.get(ApiConstants.bankAggregationInvestments);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return InvestmentsApiResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 20. POST Link Investment Holding
  /// POST /api/v1/bank-aggregation/investments
  Future<InvestmentHoldingItem?> linkInvestment(LinkInvestmentRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.bankAggregationInvestments,
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return InvestmentHoldingItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 21. PUT Update Investment by ID
  /// PUT /api/v1/bank-aggregation/investments/:id
  Future<InvestmentHoldingItem?> updateInvestment(String id, UpdateInvestmentRequest request) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.put(
        ApiConstants.bankAggregationInvestmentById(id),
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return InvestmentHoldingItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 22. DELETE Remove Investment by ID
  /// DELETE /api/v1/bank-aggregation/investments/:id
  Future<bool> deleteInvestment(String id) async {
    if (id.isEmpty) return false;
    try {
      final response = await _client.delete(ApiConstants.bankAggregationInvestmentById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // ---------------------------------------------------------------------------
  // INSURANCE POLICIES ENDPOINTS
  // ---------------------------------------------------------------------------

  /// 23. GET Insurance Policies & Summary
  /// GET /api/v1/bank-aggregation/insurance
  Future<InsurancePoliciesApiResponse?> getInsurancePolicies() async {
    try {
      final response = await _client.get(ApiConstants.bankAggregationInsurance);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return InsurancePoliciesApiResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 24. POST Link Insurance Policy
  /// POST /api/v1/bank-aggregation/insurance
  Future<InsurancePolicyItem?> linkInsurancePolicy(LinkInsurancePolicyRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.bankAggregationInsurance,
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return InsurancePolicyItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 25. PUT Update Insurance Policy
  /// PUT /api/v1/bank-aggregation/insurance/:id
  Future<InsurancePolicyItem?> updateInsurancePolicy(String id, UpdateInsurancePolicyRequest request) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.put(
        ApiConstants.bankAggregationInsuranceById(id),
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return InsurancePolicyItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 26. DELETE Remove Insurance Policy Record
  /// DELETE /api/v1/bank-aggregation/insurance/:id
  Future<bool> deleteInsurancePolicy(String id) async {
    if (id.isEmpty) return false;
    try {
      final response = await _client.delete(ApiConstants.bankAggregationInsuranceById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // ---------------------------------------------------------------------------
  // UPI ACCOUNTS ENDPOINTS
  // ---------------------------------------------------------------------------

  /// 27. GET UPI Accounts List
  /// GET /api/v1/bank-aggregation/upi-accounts
  Future<UpiAccountsApiResponse?> getUpiAccounts() async {
    try {
      final response = await _client.get(ApiConstants.bankAggregationUpiAccounts);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return UpiAccountsApiResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 28. POST Link UPI ID
  /// POST /api/v1/bank-aggregation/upi-accounts
  Future<UpiAccountItem?> linkUpiAccount(LinkUpiAccountRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.bankAggregationUpiAccounts,
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return UpiAccountItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 29. PATCH Set Primary Routing VPA
  /// PATCH /api/v1/bank-aggregation/upi-accounts/:id/set-primary
  Future<UpiAccountItem?> setPrimaryUpiAccount(String id) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.patch(
        ApiConstants.bankAggregationUpiSetPrimary(id),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return UpiAccountItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 30. DELETE Delink UPI ID
  /// DELETE /api/v1/bank-aggregation/upi-accounts/:id
  Future<bool> deleteUpiAccount(String id) async {
    if (id.isEmpty) return false;
    try {
      final response = await _client.delete(ApiConstants.bankAggregationUpiAccountById(id));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // ---------------------------------------------------------------------------
  // DIGITAL WALLETS ENDPOINTS
  // ---------------------------------------------------------------------------

  /// 31. GET Digital Wallets List & Balance
  /// GET /api/v1/bank-aggregation/wallets
  Future<WalletsApiResponse?> getWallets() async {
    try {
      final response = await _client.get(ApiConstants.bankAggregationWallets);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return WalletsApiResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 32. POST Link Digital Wallet
  /// POST /api/v1/bank-aggregation/wallets
  Future<WalletAccountItem?> linkWallet(LinkWalletRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.bankAggregationWallets,
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return WalletAccountItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  // ---------------------------------------------------------------------------
  // CONSENTS (RBI ACCOUNT AGGREGATOR CONSENTS)
  // ---------------------------------------------------------------------------

  /// 33. GET Consents List
  /// GET /api/v1/bank-aggregation/consents
  Future<ConsentsApiResponse?> getConsents() async {
    try {
      final response = await _client.get(ApiConstants.bankAggregationConsents);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return ConsentsApiResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 34. POST Initiate AA Consent Artifact
  /// POST /api/v1/bank-aggregation/consents/initiate
  Future<InitiateConsentResponse?> initiateConsent(InitiateConsentRequest request) async {
    try {
      final response = await _client.post(
        ApiConstants.bankAggregationConsentInitiate,
        body: request.toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return InitiateConsentResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 35. POST Revoke AA Consent immediately
  /// POST /api/v1/bank-aggregation/consents/:id/revoke
  Future<AggregatorConsentItem?> revokeConsent(String id) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.post(
        ApiConstants.bankAggregationConsentRevoke(id),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return AggregatorConsentItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 36. POST Renew AA Consent
  /// POST /api/v1/bank-aggregation/consents/:id/renew
  Future<AggregatorConsentItem?> renewConsent(String id, {int extensionDays = 365}) async {
    if (id.isEmpty) return null;
    try {
      final response = await _client.post(
        ApiConstants.bankAggregationConsentRenew(id),
        body: RenewConsentRequest(extensionDays: extensionDays).toJson(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map<String, dynamic>) {
          return AggregatorConsentItem.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  // ---------------------------------------------------------------------------
  // AGGREGATED TRANSACTIONS
  // ---------------------------------------------------------------------------

  /// 37. GET Aggregated Transactions Across All Institutions
  /// GET /api/v1/bank-aggregation/transactions?limit=20&page=1
  Future<AggregatorTransactionsApiResponse?> getAggregatedTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.bankAggregationTransactionsQuery(page: page, limit: limit),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return AggregatorTransactionsApiResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  // ---------------------------------------------------------------------------
  // FINANCIAL INSTITUTIONS DIRECTORY
  // ---------------------------------------------------------------------------

  /// 38. GET Supported Financial Institutions Directory
  /// GET /api/v1/bank-aggregation/institutions
  Future<InstitutionDirectoryApiResponse?> getInstitutions() async {
    try {
      final response = await _client.get(ApiConstants.bankAggregationInstitutions);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return InstitutionDirectoryApiResponse.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }
}

