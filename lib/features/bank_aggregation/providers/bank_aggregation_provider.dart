import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/cache_service.dart';
import '../domain/bank_aggregation_models.dart';
import '../services/bank_aggregation_api_service.dart';

class BankAggregationNotifier extends Notifier<BankAggregationState> {
  final BankAggregationApiService _apiService = BankAggregationApiService();

  @override
  BankAggregationState build() {
    Future.microtask(() => loadInitialData());

    final cachedCashEntries = LocalCacheService().get('user_liquid_cash_entries');
    List<LiquidCashItem> initialCashEntries = [];
    if (cachedCashEntries is List) {
      initialCashEntries = cachedCashEntries
          .whereType<Map>()
          .map((e) => LiquidCashItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    final cachedLiquidCash = LocalCacheService().get('user_liquid_cash_amount');
    final double initialLiquidCash = (cachedLiquidCash as num?)?.toDouble() ??
        (initialCashEntries.isNotEmpty
            ? initialCashEntries.fold(0.0, (s, c) => s + c.amount)
            : 0.0);

    final deletedBankIdsRaw = LocalCacheService().get('deleted_bank_account_ids');
    final deletedBankIds = deletedBankIdsRaw is List ? deletedBankIdsRaw.cast<String>() : <String>[];
    final cachedBankAccounts = LocalCacheService().get('bank_accounts');
    List<BankAccountItem>? initialBankAccounts;
    if (cachedBankAccounts is List) {
      initialBankAccounts = cachedBankAccounts
          .whereType<Map>()
          .map((e) => BankAccountItem.fromJson(Map<String, dynamic>.from(e)))
          .where((a) => !deletedBankIds.contains(a.id))
          .toList();
    }
    final initialDeduped = initialBankAccounts != null
        ? deduplicateAccounts(initialBankAccounts)
        : const <BankAccountItem>[];

    final cachedCards = LocalCacheService().get('bank_cards');
    List<CreditCardItem>? initialCards;
    if (cachedCards is List) {
      initialCards = cachedCards
          .whereType<Map>()
          .map((e) => CreditCardItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final cachedLoans = LocalCacheService().get('bank_loans');
    List<LoanAccountItem>? initialLoans;
    if (cachedLoans is List) {
      initialLoans = cachedLoans
          .whereType<Map>()
          .map((e) => LoanAccountItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final cachedInvestments = LocalCacheService().get('bank_investments');
    List<InvestmentHoldingItem>? initialInvestments;
    if (cachedInvestments is List) {
      initialInvestments = cachedInvestments
          .whereType<Map>()
          .map((e) => InvestmentHoldingItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final cachedInsurance = LocalCacheService().get('bank_insurance');
    List<InsurancePolicyItem>? initialInsurance;
    if (cachedInsurance is List) {
      initialInsurance = cachedInsurance
          .whereType<Map>()
          .map((e) => InsurancePolicyItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final cachedUpi = LocalCacheService().get('bank_upi');
    List<UpiAccountItem>? initialUpi;
    if (cachedUpi is List) {
      initialUpi = cachedUpi
          .whereType<Map>()
          .map((e) => UpiAccountItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final cachedWallets = LocalCacheService().get('bank_wallets');
    List<WalletAccountItem>? initialWallets;
    if (cachedWallets is List) {
      initialWallets = cachedWallets
          .whereType<Map>()
          .map((e) => WalletAccountItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return BankAggregationState(
      cashEntries: initialCashEntries,
      liquidCash: initialLiquidCash,
      bankAccounts: initialDeduped,
      upiAccounts: initialUpi ?? const [],
      creditCards: initialCards ?? const [],
      loans: initialLoans ?? const [],
      investments: initialInvestments ?? const [],
      insurancePolicies: initialInsurance ?? const [],
      wallets: initialWallets ?? const [],
      consents: const [],
      institutionDirectory: const [
        InstitutionDirectoryItem(id: 'inst_1', name: 'State Bank of India', logoText: 'SBI', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_2', name: 'HDFC Bank Ltd', logoText: 'HDFC', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_3', name: 'ICICI Bank Ltd', logoText: 'ICICI', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_4', name: 'Axis Bank Ltd', logoText: 'AXIS', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_5', name: 'Kotak Mahindra Bank', logoText: 'KOTAK', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_6', name: 'Punjab National Bank', logoText: 'PNB', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_7', name: 'Standard Chartered Bank', logoText: 'SCB', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_8', name: 'Bank of Baroda', logoText: 'BOB', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_9', name: 'Canara Bank', logoText: 'CNRB', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_10', name: 'Federal Bank', logoText: 'FDRL', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_11', name: 'Zerodha Broking', logoText: 'KITE', category: 'Investments'),
        InstitutionDirectoryItem(id: 'inst_12', name: 'Groww Investments', logoText: 'GROWW', category: 'Investments'),
        InstitutionDirectoryItem(id: 'inst_13', name: 'HDFC ERGO Health', logoText: 'ERGO', category: 'Insurance'),
        InstitutionDirectoryItem(id: 'inst_14', name: 'Tata AIA Life Insurance', logoText: 'AIA', category: 'Insurance'),
      ],
      recentTransactions: const [],
    );
  }

  void filterCategory(String category) {
    state = state.copyWith(selectedCategoryFilter: category);
  }

  void selectTab(int tabIndex) {
    state = state.copyWith(selectedTabIndex: tabIndex);
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// 1. Fetch Consolidated Summary across 5 financial pillars
  Future<void> fetchSummary() async {
    try {
      final summary = await _apiService.getSummary();
      if (summary != null) {
        state = state.copyWith(summary: summary);
      }
    } catch (_) {}
  }

  /// 2. Fetch linked bank accounts list from live API
  Future<void> fetchAccounts() async {
    try {
      final deletedBankIdsRaw = LocalCacheService().get('deleted_bank_account_ids');
      final deletedBankIds = deletedBankIdsRaw is List ? deletedBankIdsRaw.cast<String>() : <String>[];
      final accounts = await _apiService.getAccounts(type: 'all');
      if (accounts != null) {
        final serverAccounts = accounts.where((a) => !deletedBankIds.contains(a.id)).toList();
        
        final Map<String, BankAccountItem> merged = {};
        // Retain accounts from current active session that were adjusted or locally created
        for (final cur in state.bankAccounts) {
          if (!deletedBankIds.contains(cur.id)) {
            merged[cur.id] = cur;
          }
        }

        final Map<String, BankAccountItem> result = {};

        for (final server in serverAccounts) {
          final serverDigits = server.maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
          final serverLast4 = serverDigits.length >= 4 ? serverDigits.substring(serverDigits.length - 4) : serverDigits;

          // Find match by ID or by bank account number (last 4 digits)
          String? matchingKey;
          if (merged.containsKey(server.id)) {
            matchingKey = server.id;
          } else {
            for (final entry in merged.entries) {
              final loc = entry.value;
              final locDigits = (loc.rawAccountNumber != null && loc.rawAccountNumber!.isNotEmpty)
                  ? loc.rawAccountNumber!.replaceAll(RegExp(r'\D'), '')
                  : loc.maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
              final locLast4 = locDigits.length >= 4 ? locDigits.substring(locDigits.length - 4) : locDigits;

              final bool numberMatch = locLast4.isNotEmpty && serverLast4.isNotEmpty && locLast4 == serverLast4;
              final bool nameMatch = loc.bankName.trim().toLowerCase() == server.bankName.trim().toLowerCase() ||
                  loc.bankName.toLowerCase().contains(server.bankName.toLowerCase()) ||
                  server.bankName.toLowerCase().contains(loc.bankName.toLowerCase());

              if (numberMatch || (nameMatch && locLast4 == serverLast4)) {
                matchingKey = entry.key;
                break;
              }
            }
          }

          if (matchingKey != null) {
            final existing = merged.remove(matchingKey)!;
            // Preserve the updated dynamic balance if it was adjusted by income/expense or user edit
            final bool wasAdjusted = existing.lastSynced == 'Just now' ||
                existing.availableBalance != server.availableBalance ||
                existing.currentBalance != server.currentBalance;
            final activeAvail = wasAdjusted ? existing.availableBalance : server.availableBalance;
            final activeCurr = wasAdjusted ? existing.currentBalance : server.currentBalance;

            result[server.id] = server.copyWith(
              id: server.id,
              availableBalance: activeAvail,
              currentBalance: activeCurr,
              accountHolder: existing.accountHolder.isNotEmpty ? existing.accountHolder : server.accountHolder,
              ifscCode: existing.ifscCode.isNotEmpty ? existing.ifscCode : server.ifscCode,
              rawAccountNumber: existing.rawAccountNumber ?? server.rawAccountNumber,
              lastSynced: wasAdjusted ? 'Just now' : server.lastSynced,
            );
          } else {
            result[server.id] = server;
          }
        }

        // Retain un-synced locally created and existing session accounts
        for (final entry in merged.entries) {
          if (!result.containsKey(entry.key)) {
            result[entry.key] = entry.value;
          }
        }

        final activeAccounts = deduplicateAccounts(result.values.toList());
        state = state.copyWith(bankAccounts: activeAccounts);
        LocalCacheService().save('bank_accounts', activeAccounts.map((a) => a.toJson()).toList());
      }
    } catch (_) {}
  }

  /// Fetch credit & debit cards from live API
  Future<void> fetchCards() async {
    try {
      final res = await _apiService.getCards(type: 'all');
      if (res != null) {
        final allCards = [...res.creditCards, ...res.debitCards];
        state = state.copyWith(
          creditCards: allCards,
          cardsSummary: res.summary,
        );
        LocalCacheService().save('bank_cards', allCards.map((c) => c.toJson()).toList());
      }
    } catch (_) {}
  }

  /// Fetch active loans from live API
  Future<void> fetchLoans() async {
    try {
      final res = await _apiService.getLoans();
      if (res != null) {
        state = state.copyWith(
          loans: res.loans,
          loansSummary: res.summary,
        );
        LocalCacheService().save('bank_loans', res.loans.map((l) => l.toJson()).toList());
      }
    } catch (_) {}
  }

  /// Fetch investment holdings from live API
  Future<void> fetchInvestments() async {
    try {
      final res = await _apiService.getInvestments();
      if (res != null) {
        state = state.copyWith(
          investments: res.investments,
          portfolioSummary: res.portfolioSummary,
        );
        LocalCacheService().save('bank_investments', res.investments.map((i) => i.toJson()).toList());
      }
    } catch (_) {}
  }

  /// Fetch insurance policies from live API
  Future<void> fetchInsurancePolicies() async {
    try {
      final res = await _apiService.getInsurancePolicies();
      if (res != null) {
        state = state.copyWith(
          insurancePolicies: res.policies,
          insuranceSummary: res.summary,
        );
        LocalCacheService().save('bank_insurance', res.policies.map((p) => p.toJson()).toList());
      }
    } catch (_) {}
  }

  /// Fetch UPI accounts from live API
  Future<void> fetchUpiAccounts() async {
    try {
      final res = await _apiService.getUpiAccounts();
      if (res != null) {
        state = state.copyWith(
          upiAccounts: res.accounts,
          primaryVpa: res.primaryVpa,
        );
        LocalCacheService().save('bank_upi', res.accounts.map((u) => u.toJson()).toList());
      }
    } catch (_) {}
  }

  /// Fetch digital wallets from live API
  Future<void> fetchWallets() async {
    try {
      final res = await _apiService.getWallets();
      if (res != null) {
        state = state.copyWith(
          wallets: res.wallets,
          totalWalletBalance: res.totalWalletBalance,
        );
      }
    } catch (_) {}
  }

  /// Fetch RBI Account Aggregator consents from live API
  Future<void> fetchConsents() async {
    try {
      final res = await _apiService.getConsents();
      if (res != null) {
        state = state.copyWith(
          consents: res.consents,
          activeConsentsCount: res.activeConsentsCount,
        );
      }
    } catch (_) {}
  }

  /// Fetch aggregated transactions across all linked institutions from live API
  Future<void> fetchAggregatedTransactions({int page = 1, int limit = 20}) async {
    try {
      final res = await _apiService.getAggregatedTransactions(page: page, limit: limit);
      if (res != null) {
        state = state.copyWith(
          recentTransactions: res.transactions,
          transactionAggregates: res.aggregates,
        );
      }
    } catch (_) {}
  }

  /// Fetch supported institutions directory from live API
  Future<void> fetchInstitutions() async {
    try {
      final res = await _apiService.getInstitutions();
      if (res != null && res.institutions.isNotEmpty) {
        state = state.copyWith(institutionDirectory: res.institutions);
      }
    } catch (_) {}
  }

  /// Initial loader combining all 5 financial pillars, consents, transactions and directory
  Future<void> loadInitialData() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true);
    await Future.wait([
      fetchSummary(),
      fetchAccounts(),
      fetchCards(),
      fetchLoans(),
      fetchInvestments(),
      fetchInsurancePolicies(),
      fetchUpiAccounts(),
      fetchWallets(),
      fetchConsents(),
      fetchAggregatedTransactions(),
      fetchInstitutions(),
    ]);
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: false);
  }

  /// 3. Lookup and validate IFSC branch details
  Future<IfscBranchDetails?> lookupIfsc(String ifsc) async {
    return await _apiService.lookupIfsc(ifsc);
  }

  /// 4. Sync single bank account balance
  Future<SyncAccountBalanceResult?> syncAccountBalance(String accountId) async {
    try {
      final result = await _apiService.syncAccountBalance(accountId);
      if (result != null) {
        state = state.copyWith(
          bankAccounts: state.bankAccounts.map((a) {
            if (a.id == accountId) {
              return a.copyWith(
                currentBalance: result.currentBalance,
                availableBalance: result.currentBalance,
                lastSynced: 'Just now',
                lastSyncedAt: result.lastSyncedAt,
              );
            }
            return a;
          }).toList(),
        );
        fetchSummary(); // Refresh summary in background
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  /// 5. Link new bank account online with live backend & NPCI verification
  Future<BankAccountItem?> linkAccountOnline(LinkBankAccountRequest req) async {
    try {
      final newAcc = await _apiService.linkBankAccount(req);
      if (newAcc != null) {
        final updated = deduplicateAccounts([newAcc, ...state.bankAccounts]);
        state = state.copyWith(bankAccounts: updated);
        LocalCacheService().save('bank_accounts', updated.map((a) => a.toJson()).toList());
        await fetchSummary();
        return newAcc;
      }
    } catch (_) {}
    return null;
  }

  /// 6. Update bank account details online
  Future<BankAccountItem?> updateAccountOnline(String id, UpdateBankAccountRequest req) async {
    try {
      final updated = await _apiService.updateBankAccount(id, req);
      if (updated != null) {
        state = state.copyWith(
          bankAccounts: state.bankAccounts.map((a) => a.id == id ? updated : a).toList(),
        );
        await fetchSummary();
        return updated;
      }
    } catch (_) {}
    return null;
  }

  /// 7. Unlink bank account online
  Future<bool> unlinkAccountOnline(String id) async {
    final updated = state.bankAccounts.where((a) => a.id != id).toList();
    state = state.copyWith(bankAccounts: updated);
    LocalCacheService().save('bank_accounts', updated.map((a) => a.toJson()).toList());
    try {
      final success = await _apiService.deleteBankAccount(id);
      if (success) {
        await fetchSummary();
        return true;
      }
    } catch (_) {}
    return true;
  }

  /// Cards Online Operations
  Future<CreditCardItem?> linkCreditCardOnline(LinkCreditCardRequest req) async {
    try {
      final newCard = await _apiService.linkCreditCard(req);
      if (newCard != null) {
        final updated = [newCard, ...state.creditCards];
        state = state.copyWith(creditCards: updated);
        LocalCacheService().save('bank_cards', updated.map((c) => c.toJson()).toList());
        fetchCards();
        fetchSummary();
        return newCard;
      }
    } catch (_) {}
    return null;
  }

  Future<CreditCardItem?> updateCreditCardOnline(String id, UpdateCreditCardRequest req) async {
    try {
      final updated = await _apiService.updateCard(id, req);
      if (updated != null) {
        state = state.copyWith(
          creditCards: state.creditCards.map((c) => c.id == id ? updated : c).toList(),
        );
        fetchCards();
        fetchSummary();
        return updated;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> unlinkCreditCardOnline(String id) async {
    final updated = state.creditCards.where((c) => c.id != id).toList();
    state = state.copyWith(creditCards: updated);
    LocalCacheService().save('bank_cards', updated.map((c) => c.toJson()).toList());
    try {
      final success = await _apiService.deleteCard(id);
      if (success) {
        fetchCards();
        fetchSummary();
        return true;
      }
    } catch (_) {}
    return true;
  }

  /// Loans Online Operations
  Future<LoanAccountItem?> linkLoanOnline(LinkLoanRequest req) async {
    try {
      final newLoan = await _apiService.linkLoan(req);
      if (newLoan != null) {
        final updated = [newLoan, ...state.loans];
        state = state.copyWith(loans: updated);
        LocalCacheService().save('bank_loans', updated.map((l) => l.toJson()).toList());
        fetchLoans();
        fetchSummary();
        return newLoan;
      }
    } catch (_) {}
    return null;
  }

  Future<LoanAccountItem?> updateLoanOnline(String id, UpdateLoanRequest req) async {
    try {
      final updated = await _apiService.updateLoan(id, req);
      if (updated != null) {
        state = state.copyWith(
          loans: state.loans.map((l) => l.id == id ? updated : l).toList(),
        );
        fetchLoans();
        fetchSummary();
        return updated;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> unlinkLoanOnline(String id) async {
    final updated = state.loans.where((l) => l.id != id).toList();
    state = state.copyWith(loans: updated);
    LocalCacheService().save('bank_loans', updated.map((l) => l.toJson()).toList());
    try {
      final success = await _apiService.deleteLoan(id);
      if (success) {
        fetchLoans();
        fetchSummary();
        return true;
      }
    } catch (_) {}
    return true;
  }

  /// Investments Online Operations
  Future<InvestmentHoldingItem?> linkInvestmentOnline(LinkInvestmentRequest req) async {
    try {
      final newInv = await _apiService.linkInvestment(req);
      if (newInv != null) {
        state = state.copyWith(investments: [newInv, ...state.investments]);
        fetchInvestments();
        fetchSummary();
        return newInv;
      }
    } catch (_) {}
    return null;
  }

  Future<InvestmentHoldingItem?> updateInvestmentOnline(String id, UpdateInvestmentRequest req) async {
    try {
      final updated = await _apiService.updateInvestment(id, req);
      if (updated != null) {
        state = state.copyWith(
          investments: state.investments.map((i) => i.id == id ? updated : i).toList(),
        );
        fetchInvestments();
        fetchSummary();
        return updated;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> unlinkInvestmentOnline(String id) async {
    try {
      final success = await _apiService.deleteInvestment(id);
      if (success) {
        state = state.copyWith(
          investments: state.investments.where((i) => i.id != id).toList(),
        );
        fetchInvestments();
        fetchSummary();
        return true;
      }
    } catch (_) {}
    deleteInvestmentHolding(id);
    return true;
  }

  /// Insurance Online Operations
  Future<InsurancePolicyItem?> linkInsurancePolicyOnline(LinkInsurancePolicyRequest req) async {
    try {
      final newPol = await _apiService.linkInsurancePolicy(req);
      if (newPol != null) {
        state = state.copyWith(insurancePolicies: [newPol, ...state.insurancePolicies]);
        fetchInsurancePolicies();
        fetchSummary();
        return newPol;
      }
    } catch (_) {}
    return null;
  }

  Future<InsurancePolicyItem?> updateInsurancePolicyOnline(String id, UpdateInsurancePolicyRequest req) async {
    try {
      final updated = await _apiService.updateInsurancePolicy(id, req);
      if (updated != null) {
        state = state.copyWith(
          insurancePolicies: state.insurancePolicies.map((p) => p.id == id ? updated : p).toList(),
        );
        fetchInsurancePolicies();
        fetchSummary();
        return updated;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> unlinkInsurancePolicyOnline(String id) async {
    try {
      final success = await _apiService.deleteInsurancePolicy(id);
      if (success) {
        state = state.copyWith(
          insurancePolicies: state.insurancePolicies.where((p) => p.id != id).toList(),
        );
        fetchInsurancePolicies();
        fetchSummary();
        return true;
      }
    } catch (_) {}
    deleteInsurancePolicy(id);
    return true;
  }

  /// UPI Accounts Online Operations
  Future<UpiAccountItem?> linkUpiAccountOnline(LinkUpiAccountRequest req) async {
    try {
      final newUpi = await _apiService.linkUpiAccount(req);
      if (newUpi != null) {
        state = state.copyWith(upiAccounts: [newUpi, ...state.upiAccounts]);
        fetchUpiAccounts();
        fetchSummary();
        return newUpi;
      }
    } catch (_) {}
    return null;
  }

  Future<UpiAccountItem?> setPrimaryUpiOnline(String id) async {
    try {
      final updated = await _apiService.setPrimaryUpiAccount(id);
      if (updated != null) {
        state = state.copyWith(
          upiAccounts: state.upiAccounts.map((u) {
            if (u.id == id) {
              return updated;
            }
            return u.copyWith(isPrimary: false);
          }).toList(),
          primaryVpa: updated.upiId,
        );
        fetchUpiAccounts();
        return updated;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> unlinkUpiAccountOnline(String id) async {
    try {
      final success = await _apiService.deleteUpiAccount(id);
      if (success) {
        state = state.copyWith(
          upiAccounts: state.upiAccounts.where((u) => u.id != id).toList(),
        );
        fetchUpiAccounts();
        fetchSummary();
        return true;
      }
    } catch (_) {}
    deleteUpiAccount(id);
    return true;
  }

  /// Digital Wallets Online Operations
  Future<WalletAccountItem?> linkWalletOnline(LinkWalletRequest req) async {
    try {
      final newWallet = await _apiService.linkWallet(req);
      if (newWallet != null) {
        state = state.copyWith(wallets: [newWallet, ...state.wallets]);
        fetchWallets();
        fetchSummary();
        return newWallet;
      }
    } catch (_) {}
    return null;
  }

  /// Consents Online Operations
  Future<InitiateConsentResponse?> initiateConsentOnline(InitiateConsentRequest req) async {
    try {
      final res = await _apiService.initiateConsent(req);
      if (res != null && res.data != null) {
        state = state.copyWith(
          consents: [res.data!, ...state.consents],
          activeConsentsCount: state.activeConsentsCount + 1,
        );
        fetchConsents();
        return res;
      }
    } catch (_) {}
    return null;
  }

  Future<AggregatorConsentItem?> revokeConsentOnline(String consentId) async {
    try {
      final res = await _apiService.revokeConsent(consentId);
      if (res != null) {
        state = state.copyWith(
          consents: state.consents.map((c) => c.id == consentId || c.consentHandle == consentId ? res : c).toList(),
        );
        fetchConsents();
        return res;
      }
    } catch (_) {}
    return null;
  }

  Future<AggregatorConsentItem?> renewConsentOnline(String consentId, {int extensionDays = 365}) async {
    try {
      final res = await _apiService.renewConsent(consentId, extensionDays: extensionDays);
      if (res != null) {
        state = state.copyWith(
          consents: state.consents.map((c) => c.id == consentId || c.consentHandle == consentId ? res : c).toList(),
        );
        fetchConsents();
        return res;
      }
    } catch (_) {}
    return null;
  }

  /// 8. Sync all accounts & pillars
  Future<void> syncAllAccounts() async {
    state = state.copyWith(isSyncing: true);
    try {
      await Future.wait([
        _apiService.syncAllPillars(),
        fetchAccounts(),
        fetchCards(),
        fetchLoans(),
        fetchInvestments(),
        fetchInsurancePolicies(),
        fetchUpiAccounts(),
        fetchWallets(),
        fetchConsents(),
        fetchAggregatedTransactions(),
        fetchInstitutions(),
        fetchSummary(),
      ]);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    state = state.copyWith(
      isSyncing: false,
      lastSyncedTime: 'Today at $timeStr • Real-Time AA Sync Active',
      connectionStatus: 'All 5 Pillars Connected & Synced',
    );
  }

  void connectBankInstitution(InstitutionDirectoryItem institution, {String accountType = 'Savings Account'}) {
    final randomDigits = (1000 + (DateTime.now().millisecondsSinceEpoch % 8999)).toString();
    final newAccount = BankAccountItem(
      id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
      bankName: institution.name,
      accountType: accountType,
      maskedAccountNumber: 'XXXXXX$randomDigits',
      ifscCode: '${institution.logoText}000$randomDigits',
      accountHolder: LocalCacheService().get('user_name')?.toString() ?? 'Account Holder',
      currentBalance: 35000.0 + (institution.name.hashCode.abs() % 40000),
      availableBalance: 35000.0 + (institution.name.hashCode.abs() % 40000),
      lastSynced: 'Just now',
      isConnected: true,
    );

    // Also register an active RBI AA consent
    final newConsent = AggregatorConsentItem(
      consentId: 'AA-${DateTime.now().millisecondsSinceEpoch}',
      institution: institution.name,
      consentType: 'Account & Transaction Access',
      startDate: 'Today',
      expiryDate: '1 Year from today',
      purpose: 'Financial Account Aggregation & PFOS Insights',
      dataShared: 'Balances, Account Profile & Statements',
      status: 'Active',
    );

    state = state.copyWith(
      bankAccounts: [...state.bankAccounts, newAccount],
      consents: [newConsent, ...state.consents],
    );
  }

  void addBankAccount({
    required String bankName,
    required String accountType,
    required String maskedAccountNumber,
    String? rawAccountNumber,
    required String ifscCode,
    required String accountHolder,
    required double currentBalance,
  }) {
    final cleanDigits = (rawAccountNumber != null && rawAccountNumber.isNotEmpty)
        ? rawAccountNumber.replaceAll(RegExp(r'\D'), '')
        : maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
    final newLast4 = cleanDigits.length >= 4 ? cleanDigits.substring(cleanDigits.length - 4) : cleanDigits;

    // Check if an existing bank account has the same account number - update it instead of adding extra field
    final existingIndex = state.bankAccounts.indexWhere((a) {
      final aDigits = (a.rawAccountNumber != null && a.rawAccountNumber!.isNotEmpty)
          ? a.rawAccountNumber!.replaceAll(RegExp(r'\D'), '')
          : a.maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
      final aLast4 = aDigits.length >= 4 ? aDigits.substring(aDigits.length - 4) : aDigits;
      return newLast4.isNotEmpty && aLast4.isNotEmpty && (aLast4 == newLast4 || aDigits == cleanDigits);
    });

    if (existingIndex >= 0) {
      final existing = state.bankAccounts[existingIndex];
      final updatedAcc = existing.copyWith(
        bankName: bankName.isNotEmpty ? bankName : existing.bankName,
        accountType: accountType,
        maskedAccountNumber: maskedAccountNumber,
        rawAccountNumber: rawAccountNumber ?? existing.rawAccountNumber,
        ifscCode: ifscCode.isNotEmpty ? ifscCode : existing.ifscCode,
        accountHolder: accountHolder.isNotEmpty ? accountHolder : existing.accountHolder,
        currentBalance: currentBalance,
        availableBalance: currentBalance,
        lastSynced: 'Just now',
      );
      final updatedList = List<BankAccountItem>.from(state.bankAccounts);
      updatedList[existingIndex] = updatedAcc;
      final deduplicated = deduplicateAccounts(updatedList);
      state = state.copyWith(bankAccounts: deduplicated);
      LocalCacheService().save('bank_accounts', deduplicated.map((a) => a.toJson()).toList());

      if (cleanDigits.length >= 4 && ifscCode.trim().length >= 6) {
        final reqType = accountType.toUpperCase().contains('CURRENT')
            ? 'CURRENT'
            : (accountType.toUpperCase().contains('SALARY') ? 'SALARY' : 'SAVINGS');
        _apiService.updateBankAccount(
          existing.id,
          UpdateBankAccountRequest(
            nickname: '$bankName $accountType',
            accountType: reqType,
          ),
        ).then((_) {
          fetchAccounts();
          fetchSummary();
        }).catchError((_) {});
      }
      return;
    }

    final newAccount = BankAccountItem(
      id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
      bankName: bankName,
      accountType: accountType,
      maskedAccountNumber: maskedAccountNumber,
      rawAccountNumber: rawAccountNumber,
      ifscCode: ifscCode,
      accountHolder: accountHolder,
      currentBalance: currentBalance,
      availableBalance: currentBalance,
      lastSynced: 'Just now',
      isConnected: true,
    );

    final newConsent = AggregatorConsentItem(
      consentId: 'AA-${DateTime.now().millisecondsSinceEpoch}',
      institution: bankName,
      consentType: '$accountType & Transaction Access',
      startDate: 'Today',
      expiryDate: '1 Year from today',
      purpose: 'Financial Account Aggregation & PFOS Insights',
      dataShared: 'Balances, Account Profile & Statements',
      status: 'Active',
    );

    final updated = deduplicateAccounts([...state.bankAccounts, newAccount]);
    state = state.copyWith(
      bankAccounts: updated,
      consents: [newConsent, ...state.consents],
    );
    LocalCacheService().save('bank_accounts', updated.map((a) => a.toJson()).toList());

    // Asynchronously link via backend API if possible
    if (cleanDigits.length >= 4 && ifscCode.trim().length >= 6) {
      final reqType = accountType.toUpperCase().contains('CURRENT')
          ? 'CURRENT'
          : (accountType.toUpperCase().contains('SALARY') ? 'SALARY' : 'SAVINGS');
      _apiService.linkBankAccount(LinkBankAccountRequest(
        accountNumber: cleanDigits,
        confirmAccountNumber: cleanDigits,
        ifsc: ifscCode.trim(),
        accountType: reqType,
        openingBalance: currentBalance,
        holderName: accountHolder,
        nickname: '$bankName $accountType',
      )).then((linked) {
        if (linked != null) {
          fetchAccounts();
          fetchSummary();
        }
      }).catchError((_) {});
    }
  }

  void addCreditCardItem({
    required String cardName,
    required String last4Digits,
    String? cardNumber,
    String? cvv,
    required double creditLimit,
    required double outstandingBalance,
    required String statementDueDate,
    required double minimumDue,
    int rewardPoints = 1200,
    String? holderName,
    String? issuedBank,
    String? cardType,
    String? expiryDate,
    bool isDebit = false,
    double? dailyAtmLimit,
    double? dailyPosLimit,
    String? linkedAccount,
  }) {
    final newCard = CreditCardItem(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      cardName: cardName,
      last4Digits: last4Digits,
      cardNumber: cardNumber,
      cvv: cvv,
      creditLimit: creditLimit,
      outstandingBalance: outstandingBalance,
      availableCredit: (creditLimit - outstandingBalance).clamp(0.0, double.infinity),
      statementDueDate: statementDueDate,
      minimumDue: minimumDue,
      rewardPoints: rewardPoints,
      cardHolderName: holderName,
      issuedBank: issuedBank,
      cardType: cardType,
      expiryDate: expiryDate,
      isDebit: isDebit,
      dailyAtmLimit: dailyAtmLimit,
      dailyPosLimit: dailyPosLimit,
      linkedAccount: linkedAccount,
    );
    state = state.copyWith(creditCards: [...state.creditCards, newCard]);

    // Live backend linking in background
    final cleanDigits = (cardNumber ?? last4Digits).replaceAll(RegExp(r'\D'), '');
    final last4 = cleanDigits.length >= 4 ? cleanDigits.substring(cleanDigits.length - 4) : '8921';
    _apiService.linkCreditCard(LinkCreditCardRequest(
      cardType: isDebit ? 'Debit' : 'Credit',
      issuingBank: issuedBank ?? (cardName.contains(' ') ? cardName.split(' ').first : 'Axis Bank'),
      cardholderName: holderName ?? (LocalCacheService().get('user_name')?.toString() ?? 'Card Holder'),
      network: cardType ?? 'Visa',
      lastFourDigits: last4,
      creditLimit: creditLimit > 0 ? creditLimit : 250000,
      currentOutstanding: outstandingBalance,
      billingCycleDate: '20th of month',
      paymentDueDate: statementDueDate.isNotEmpty ? statementDueDate : '2026-12-10',
      rewardPoints: rewardPoints,
    )).then((c) {
      if (c != null) {
        fetchCards();
        fetchSummary();
      }
    }).catchError((_) {});
  }

  void addCreditCard(String name, String last4, double limit, double outstanding) {
    addCreditCardItem(
      cardName: name,
      last4Digits: last4,
      creditLimit: limit,
      outstandingBalance: outstanding,
      statementDueDate: '20th of month',
      minimumDue: outstanding * 0.05,
      rewardPoints: 1200,
    );
  }

  void addUpiAccount(String upiId, String provider, String linkedBank) {
    final newUpi = UpiAccountItem(
      id: 'upi_${DateTime.now().millisecondsSinceEpoch}',
      upiId: upiId,
      provider: provider,
      linkedBank: linkedBank,
      isPrimary: false,
      status: 'Active',
    );
    state = state.copyWith(upiAccounts: [...state.upiAccounts, newUpi]);
    _apiService.linkUpiAccount(
      LinkUpiAccountRequest(
        vpa: upiId,
        bankName: linkedBank,
        appProvider: provider,
        isPrimary: false,
      ),
    ).then((_) {
      fetchUpiAccounts();
      fetchSummary();
    }).catchError((_) {});
  }

  /// Deduplicate bank accounts by account number digits, merging balances & metadata
  static List<BankAccountItem> deduplicateAccounts(List<BankAccountItem> accounts) {
    final Map<String, BankAccountItem> unique = {};
    for (final acc in accounts) {
      final digits = (acc.rawAccountNumber != null && acc.rawAccountNumber!.isNotEmpty)
          ? acc.rawAccountNumber!.replaceAll(RegExp(r'\D'), '')
          : acc.maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
      final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;

      // Key primarily by account number (last4 digits)
      final key = last4.isNotEmpty
          ? 'acc_num_$last4'
          : 'acc_id_${acc.id}';

      if (!unique.containsKey(key)) {
        unique[key] = acc;
      } else {
        final existing = unique[key]!;
        // Choose dynamic updated balance
        final double finalAvail;
        final double finalCurr;
        if (acc.lastSynced == 'Just now') {
          finalAvail = acc.availableBalance;
          finalCurr = acc.currentBalance;
        } else if (existing.lastSynced == 'Just now') {
          finalAvail = existing.availableBalance;
          finalCurr = existing.currentBalance;
        } else {
          finalAvail = acc.availableBalance != 0 ? acc.availableBalance : existing.availableBalance;
          finalCurr = acc.currentBalance != 0 ? acc.currentBalance : existing.currentBalance;
        }

        final finalId = (existing.id.startsWith('bank_') && !acc.id.startsWith('bank_'))
            ? acc.id
            : (acc.id.startsWith('bank_') && !existing.id.startsWith('bank_') ? existing.id : acc.id);

        unique[key] = acc.copyWith(
          id: finalId,
          availableBalance: finalAvail,
          currentBalance: finalCurr,
          accountHolder: acc.accountHolder.isNotEmpty ? acc.accountHolder : existing.accountHolder,
          ifscCode: acc.ifscCode.isNotEmpty ? acc.ifscCode : existing.ifscCode,
          bankName: acc.bankName.isNotEmpty ? acc.bankName : existing.bankName,
          maskedAccountNumber: acc.maskedAccountNumber.isNotEmpty ? acc.maskedAccountNumber : existing.maskedAccountNumber,
          rawAccountNumber: (acc.rawAccountNumber != null && acc.rawAccountNumber!.isNotEmpty)
              ? acc.rawAccountNumber
              : existing.rawAccountNumber,
          lastSynced: 'Just now',
        );
      }
    }
    return unique.values.toList();
  }

  /// Find a connected bank account that matches the given account identifier string.
  BankAccountItem? findAccountMatching(String bankAccountString) {
    if (bankAccountString.trim().isEmpty) return null;
    final query = bankAccountString.trim().toLowerCase();

    // 1. Exact ID match
    for (final acc in state.bankAccounts) {
      if (acc.id.toLowerCase() == query) return acc;
    }

    // 2. Extract digits (e.g. "••••4587" or "**** 1123" -> "4587")
    final digits = query.replaceAll(RegExp(r'\D'), '');
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;

    if (last4.isNotEmpty) {
      for (final acc in state.bankAccounts) {
        final accDigits = (acc.rawAccountNumber != null && acc.rawAccountNumber!.isNotEmpty)
            ? acc.rawAccountNumber!.replaceAll(RegExp(r'\D'), '')
            : acc.maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
        final accLast4 = accDigits.length >= 4 ? accDigits.substring(accDigits.length - 4) : accDigits;

        if (accLast4.isNotEmpty && (last4 == accLast4 || accDigits.endsWith(last4) || digits.endsWith(accLast4))) {
          return acc;
        }
      }
    }

    // 3. Substring match on bank name
    for (final acc in state.bankAccounts) {
      final nameLower = acc.bankName.toLowerCase();
      if (query.contains(nameLower) || nameLower.contains(query)) {
        return acc;
      }
    }

    return null;
  }

  /// Adjust account balance dynamically when income is credited (+delta) or expense is debited (-delta).
  void adjustAccountBalance({
    required String bankAccount,
    required double delta,
  }) {
    if (delta == 0) return;

    final targetAccount = findAccountMatching(bankAccount);
    if (targetAccount != null) {
      final newAvail = (targetAccount.availableBalance + delta).clamp(0.0, double.infinity);
      final newCurr = (targetAccount.currentBalance + delta).clamp(0.0, double.infinity);

      final updatedAcc = targetAccount.copyWith(
        availableBalance: newAvail,
        currentBalance: newCurr,
        lastSynced: 'Just now',
      );

      final targetDigits = (targetAccount.rawAccountNumber != null && targetAccount.rawAccountNumber!.isNotEmpty)
          ? targetAccount.rawAccountNumber!.replaceAll(RegExp(r'\D'), '')
          : targetAccount.maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
      final targetLast4 = targetDigits.length >= 4 ? targetDigits.substring(targetDigits.length - 4) : targetDigits;

      final updatedAccounts = state.bankAccounts.map((a) {
        final aDigits = (a.rawAccountNumber != null && a.rawAccountNumber!.isNotEmpty)
            ? a.rawAccountNumber!.replaceAll(RegExp(r'\D'), '')
            : a.maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
        final aLast4 = aDigits.length >= 4 ? aDigits.substring(aDigits.length - 4) : aDigits;

        // If it matches ID OR the same bank account number digits, update to the new balance!
        if (a.id == targetAccount.id || (targetLast4.isNotEmpty && aLast4.isNotEmpty && aLast4 == targetLast4)) {
          return updatedAcc;
        }
        return a;
      }).toList();

      final deduplicated = deduplicateAccounts(updatedAccounts);
      state = state.copyWith(bankAccounts: deduplicated);
      LocalCacheService().save(
        'bank_accounts',
        deduplicated.map((a) => a.toJson()).toList(),
      );
      return;
    }

    // If Other / Cash
    final lower = bankAccount.toLowerCase();
    if (lower.contains('cash') || lower.contains('wallet')) {
      final newCash = (state.liquidCash + delta).clamp(0.0, double.infinity);
      state = state.copyWith(liquidCash: newCash);
      LocalCacheService().save('user_liquid_cash_amount', newCash);
    } else if (state.bankAccounts.isNotEmpty) {
      // If only 1 account exists or fallback
      final firstAcc = state.bankAccounts.first;
      final newAvail = (firstAcc.availableBalance + delta).clamp(0.0, double.infinity);
      final newCurr = (firstAcc.currentBalance + delta).clamp(0.0, double.infinity);

      final updatedAcc = firstAcc.copyWith(
        availableBalance: newAvail,
        currentBalance: newCurr,
        lastSynced: 'Just now',
      );

      final updatedAccounts = state.bankAccounts.map((a) {
        return a.id == firstAcc.id ? updatedAcc : a;
      }).toList();

      final deduplicated = deduplicateAccounts(updatedAccounts);
      state = state.copyWith(bankAccounts: deduplicated);
      LocalCacheService().save(
        'bank_accounts',
        deduplicated.map((a) => a.toJson()).toList(),
      );
    }
  }

  void updateBankAccount(BankAccountItem updated) {
    final upDigits = (updated.rawAccountNumber != null && updated.rawAccountNumber!.isNotEmpty)
        ? updated.rawAccountNumber!.replaceAll(RegExp(r'\D'), '')
        : updated.maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
    final upLast4 = upDigits.length >= 4 ? upDigits.substring(upDigits.length - 4) : upDigits;

    final updatedList = state.bankAccounts.map((a) {
      if (a.id == updated.id) return updated;
      final aDigits = (a.rawAccountNumber != null && a.rawAccountNumber!.isNotEmpty)
          ? a.rawAccountNumber!.replaceAll(RegExp(r'\D'), '')
          : a.maskedAccountNumber.replaceAll(RegExp(r'\D'), '');
      final aLast4 = aDigits.length >= 4 ? aDigits.substring(aDigits.length - 4) : aDigits;
      if (aLast4.isNotEmpty && upLast4.isNotEmpty && aLast4 == upLast4) {
        return updated;
      }
      return a;
    }).toList();
    final deduplicated = deduplicateAccounts(updatedList);
    state = state.copyWith(bankAccounts: deduplicated);
    LocalCacheService().save('bank_accounts', deduplicated.map((a) => a.toJson()).toList());
    final reqType = updated.accountType.toUpperCase().contains('CURRENT')
        ? 'CURRENT'
        : (updated.accountType.toUpperCase().contains('SALARY') ? 'SALARY' : 'SAVINGS');
    _apiService.updateBankAccount(
      updated.id,
      UpdateBankAccountRequest(
        nickname: updated.nickname ?? '${updated.bankName} ${updated.accountType}',
        accountType: reqType,
      ),
    ).then((_) {
      fetchSummary();
    }).catchError((_) {});
  }

  void deleteBankAccount(String id) {
    final deletedBankIdsRaw = LocalCacheService().get('deleted_bank_account_ids');
    final deletedBankIds = deletedBankIdsRaw is List ? deletedBankIdsRaw.cast<String>() : <String>[];
    if (!deletedBankIds.contains(id)) {
      deletedBankIds.add(id);
      LocalCacheService().save('deleted_bank_account_ids', deletedBankIds);
    }
    final updated = state.bankAccounts.where((a) => a.id != id).toList();
    state = state.copyWith(bankAccounts: updated);
    LocalCacheService().save('bank_accounts', updated.map((a) => a.toJson()).toList());
    _apiService.deleteBankAccount(id).then((_) {
      fetchAccounts();
      fetchSummary();
    }).catchError((_) {});
  }

  void updateCreditCard(CreditCardItem updated) {
    state = state.copyWith(
      creditCards: state.creditCards.map((c) => c.id == updated.id ? updated : c).toList(),
    );
    _apiService.updateCard(
      updated.id,
      UpdateCreditCardRequest(
        creditLimit: updated.creditLimit,
        currentOutstanding: updated.outstandingBalance,
        cardNickname: updated.cardName,
      ),
    ).then((_) {
      fetchCards();
      fetchSummary();
    }).catchError((_) {});
  }

  void deleteCreditCard(String id) {
    final updated = state.creditCards.where((c) => c.id != id).toList();
    state = state.copyWith(creditCards: updated);
    LocalCacheService().save('bank_cards', updated.map((c) => c.toJson()).toList());
    _apiService.deleteCard(id).then((_) {
      fetchCards();
      fetchSummary();
    }).catchError((_) {});
  }

  void updateUpiAccount(UpiAccountItem updated) {
    state = state.copyWith(
      upiAccounts: state.upiAccounts.map((u) => u.id == updated.id ? updated : u).toList(),
    );
  }

  void deleteUpiAccount(String id) {
    final updated = state.upiAccounts.where((u) => u.id != id).toList();
    state = state.copyWith(upiAccounts: updated);
    LocalCacheService().save('bank_upi', updated.map((u) => u.toJson()).toList());
    _apiService.deleteUpiAccount(id).then((_) {
      fetchUpiAccounts();
      fetchSummary();
    }).catchError((_) {});
  }

  void addLoanAccount({
    required String loanType,
    required String lender,
    required double outstandingPrincipal,
    required double interestRate,
    required double monthlyEmi,
    required int tenureRemainingMonths,
    required String nextDueDate,
  }) {
    final newLoan = LoanAccountItem(
      id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
      loanType: loanType,
      lender: lender,
      outstandingPrincipal: outstandingPrincipal,
      interestRate: interestRate,
      monthlyEmi: monthlyEmi,
      tenureRemainingMonths: tenureRemainingMonths,
      nextDueDate: nextDueDate,
    );
    state = state.copyWith(loans: [...state.loans, newLoan]);

    _apiService.linkLoan(LinkLoanRequest(
      lenderName: lender,
      loanType: loanType,
      accountNumber: 'HL-${lender.replaceAll(' ', '')}-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      sanctionedAmount: outstandingPrincipal * 1.25,
      outstandingPrincipal: outstandingPrincipal,
      interestRate: interestRate,
      monthlyEmi: monthlyEmi,
      totalTenureMonths: (tenureRemainingMonths * 1.2).toInt(),
      remainingTenureMonths: tenureRemainingMonths,
      nextEmiDate: nextDueDate,
    )).then((l) {
      if (l != null) {
        fetchLoans();
        fetchSummary();
      }
    }).catchError((_) {});
  }

  void updateLoanAccount(LoanAccountItem updated) {
    state = state.copyWith(
      loans: state.loans.map((l) => l.id == updated.id ? updated : l).toList(),
    );
    _apiService.updateLoan(
      updated.id,
      UpdateLoanRequest(
        outstandingPrincipal: updated.outstandingPrincipal,
        remainingTenureMonths: updated.tenureRemainingMonths,
      ),
    ).then((_) {
      fetchLoans();
      fetchSummary();
    }).catchError((_) {});
  }

  void deleteLoanAccount(String id) {
    final updated = state.loans.where((l) => l.id != id).toList();
    state = state.copyWith(loans: updated);
    LocalCacheService().save('bank_loans', updated.map((l) => l.toJson()).toList());
    _apiService.deleteLoan(id).then((_) {
      fetchLoans();
      fetchSummary();
    }).catchError((_) {});
  }

  void addInvestmentHolding({
    required String assetType,
    required String institution,
    required double currentValue,
    required double investedValue,
    required double returnPercentage,
    bool isPositive = true,
  }) {
    final newInv = InvestmentHoldingItem(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      assetType: assetType,
      institution: institution,
      currentValue: currentValue,
      investedValue: investedValue,
      returnPercentage: returnPercentage,
      isPositive: isPositive,
    );
    state = state.copyWith(investments: [...state.investments, newInv]);

    final safePrice = (investedValue > 0) ? (investedValue / 1000) : 100.0;
    _apiService.linkInvestment(LinkInvestmentRequest(
      assetType: assetType.toUpperCase().replaceAll(' ', '_'),
      name: '$institution $assetType Holding',
      symbolOrFolio: 'FOLIO-${DateTime.now().millisecondsSinceEpoch % 10000}',
      platform: institution,
      quantity: 1000,
      buyNavOrPrice: safePrice,
      currentNavOrPrice: safePrice * (1 + (returnPercentage / 100)),
    )).then((inv) {
      if (inv != null) {
        fetchInvestments();
        fetchSummary();
      }
    }).catchError((_) {});
  }

  void updateInvestmentHolding(InvestmentHoldingItem updated) {
    state = state.copyWith(
      investments: state.investments.map((i) => i.id == updated.id ? updated : i).toList(),
    );
    _apiService.updateInvestment(
      updated.id,
      UpdateInvestmentRequest(
        currentNavOrPrice: updated.currentNavOrPrice ?? (updated.currentValue / (updated.quantity ?? 1)),
      ),
    ).then((_) {
      fetchInvestments();
      fetchSummary();
    }).catchError((_) {});
  }

  void deleteInvestmentHolding(String id) {
    final updated = state.investments.where((i) => i.id != id).toList();
    state = state.copyWith(investments: updated);
    LocalCacheService().save('bank_investments', updated.map((i) => i.toJson()).toList());
    _apiService.deleteInvestment(id).then((_) {
      fetchInvestments();
      fetchSummary();
    }).catchError((_) {});
  }

  void addInsurancePolicy({
    required String policyType,
    required String policyNumberMasked,
    required String provider,
    required double coverageAmount,
    required double premiumAmount,
    required String renewalDate,
    required String nominee,
  }) {
    final newPolicy = InsurancePolicyItem(
      id: 'ins_${DateTime.now().millisecondsSinceEpoch}',
      policyType: policyType,
      policyNumberMasked: policyNumberMasked,
      provider: provider,
      coverageAmount: coverageAmount,
      premiumAmount: premiumAmount,
      renewalDate: renewalDate,
      nominee: nominee,
    );
    state = state.copyWith(insurancePolicies: [...state.insurancePolicies, newPolicy]);
    final insTypeReq = policyType.toUpperCase().contains('HEALTH')
        ? 'HEALTH'
        : (policyType.toUpperCase().contains('CAR') || policyType.toUpperCase().contains('VEHICLE') ? 'CAR' : 'LIFE');
    _apiService.linkInsurancePolicy(
      LinkInsurancePolicyRequest(
        insuranceType: insTypeReq,
        policyName: '$provider $policyType',
        policyNumber: policyNumberMasked,
        providerName: provider,
        sumInsured: coverageAmount,
        annualPremium: premiumAmount,
        renewalDate: renewalDate,
        nomineeName: nominee,
      ),
    ).then((_) {
      fetchInsurancePolicies();
      fetchSummary();
    }).catchError((_) {});
  }

  void updateInsurancePolicy(InsurancePolicyItem updated) {
    state = state.copyWith(
      insurancePolicies: state.insurancePolicies.map((p) => p.id == updated.id ? updated : p).toList(),
    );
    _apiService.updateInsurancePolicy(
      updated.id,
      UpdateInsurancePolicyRequest(
        sumInsured: updated.coverageAmount,
        annualPremium: updated.premiumAmount,
      ),
    ).then((_) {
      fetchInsurancePolicies();
      fetchSummary();
    }).catchError((_) {});
  }

  void deleteInsurancePolicy(String id) {
    final updated = state.insurancePolicies.where((p) => p.id != id).toList();
    state = state.copyWith(insurancePolicies: updated);
    LocalCacheService().save('bank_insurance', updated.map((p) => p.toJson()).toList());
    _apiService.deleteInsurancePolicy(id).then((_) {
      fetchInsurancePolicies();
      fetchSummary();
    }).catchError((_) {});
  }

  void addWalletAccount({
    required String walletName,
    required String walletProvider,
    required double balance,
    required String linkedMobile,
  }) {
    final newWallet = WalletAccountItem(
      id: 'wal_${DateTime.now().millisecondsSinceEpoch}',
      walletName: walletName,
      walletProvider: walletProvider,
      balance: balance,
      linkedMobile: linkedMobile,
      isKycDone: true,
      status: 'ACTIVE',
    );
    state = state.copyWith(wallets: [...state.wallets, newWallet]);
    _apiService.linkWallet(
      LinkWalletRequest(
        walletName: walletName,
        walletProvider: walletProvider,
        balance: balance,
        linkedMobile: linkedMobile,
      ),
    ).then((_) {
      fetchWallets();
      fetchSummary();
    }).catchError((_) {});
  }

  void revokeConsent(String consentId) {
    final updated = state.consents.map((c) {
      if (c.consentId == consentId || c.id == consentId) {
        return c.copyWith(status: 'REVOKED');
      }
      return c;
    }).toList();
    state = state.copyWith(consents: updated);
    _apiService.revokeConsent(consentId).then((_) {
      fetchConsents();
      fetchSummary();
    }).catchError((_) {});
  }

  void renewConsent(String consentId) {
    final updated = state.consents.map((c) {
      if (c.consentId == consentId || c.id == consentId) {
        return c.copyWith(
          status: 'ACTIVE',
          validTo: '2027-11-03T06:01:30.887Z',
        );
      }
      return c;
    }).toList();
    state = state.copyWith(consents: updated);
    _apiService.renewConsent(consentId, extensionDays: 365).then((_) {
      fetchConsents();
      fetchSummary();
    }).catchError((_) {});
  }

  // ---------------------------------------------------------------------------
  // LIQUID CASH OPERATIONS
  // ---------------------------------------------------------------------------

  /// Add a liquid cash entry and persist
  Future<void> addLiquidCash({
    required String title,
    required double amount,
    String? notes,
  }) async {
    final now = DateTime.now();
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final hourStr = (now.hour % 12 == 0 ? 12 : now.hour % 12).toString();
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final formattedDate = 'Today, $hourStr:$minuteStr $ampm';

    final newItem = LiquidCashItem(
      id: 'cash_${now.millisecondsSinceEpoch}',
      title: title.trim().isNotEmpty ? title.trim() : 'Physical Cash in Hand',
      amount: amount,
      lastUpdated: formattedDate,
      notes: notes,
    );

    final updatedEntries = [newItem, ...state.cashEntries];
    final newTotal = updatedEntries.fold(0.0, (s, c) => s + c.amount);

    state = state.copyWith(
      cashEntries: updatedEntries,
      liquidCash: newTotal,
    );

    LocalCacheService().save(
      'user_liquid_cash_entries',
      updatedEntries.map((e) => e.toJson()).toList(),
    );
    LocalCacheService().save('user_liquid_cash_amount', newTotal);
  }

  /// Update existing liquid cash entry
  Future<void> updateLiquidCash(
    String id, {
    required String title,
    required double amount,
    String? notes,
  }) async {
    final now = DateTime.now();
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final hourStr = (now.hour % 12 == 0 ? 12 : now.hour % 12).toString();
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final formattedDate = 'Today, $hourStr:$minuteStr $ampm';

    final updatedEntries = state.cashEntries.map((e) {
      if (e.id == id) {
        return e.copyWith(
          title: title.trim().isNotEmpty ? title.trim() : e.title,
          amount: amount,
          lastUpdated: formattedDate,
          notes: notes,
        );
      }
      return e;
    }).toList();

    final newTotal = updatedEntries.fold(0.0, (s, c) => s + c.amount);

    state = state.copyWith(
      cashEntries: updatedEntries,
      liquidCash: newTotal,
    );

    LocalCacheService().save(
      'user_liquid_cash_entries',
      updatedEntries.map((e) => e.toJson()).toList(),
    );
    LocalCacheService().save('user_liquid_cash_amount', newTotal);
  }

  /// Delete liquid cash entry
  Future<void> deleteLiquidCash(String id) async {
    final updatedEntries = state.cashEntries.where((e) => e.id != id).toList();
    final newTotal = updatedEntries.fold(0.0, (s, c) => s + c.amount);

    state = state.copyWith(
      cashEntries: updatedEntries,
      liquidCash: newTotal,
    );

    LocalCacheService().save(
      'user_liquid_cash_entries',
      updatedEntries.map((e) => e.toJson()).toList(),
    );
    LocalCacheService().save('user_liquid_cash_amount', newTotal);
  }

  /// Set overall liquid cash amount directly
  Future<void> setLiquidCash(double amount, {String? title}) async {
    await addLiquidCash(
      title: title ?? 'Physical Cash',
      amount: amount,
    );
  }
}

final bankAggregationProvider = NotifierProvider<BankAggregationNotifier, BankAggregationState>(() {
  return BankAggregationNotifier();
});

final bankAggregationApiServiceProvider = Provider<BankAggregationApiService>((ref) {
  return BankAggregationApiService();
});

