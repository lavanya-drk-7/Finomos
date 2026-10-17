import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/bank_aggregation_models.dart';

class BankAggregationNotifier extends Notifier<BankAggregationState> {
  @override
  BankAggregationState build() {
    return const BankAggregationState(
      bankAccounts: [
        BankAccountItem(
          id: 'bank_1',
          bankName: 'State Bank of India',
          accountType: 'Savings Account',
          maskedAccountNumber: 'XXXXXX4821',
          ifscCode: 'SBIN0001234',
          accountHolder: 'Sireesha S',
          currentBalance: 142850.00,
          availableBalance: 142850.00,
          lastSynced: '10 mins ago',
          isConnected: true,
        ),
        BankAccountItem(
          id: 'bank_2',
          bankName: 'HDFC Bank',
          accountType: 'Current Account',
          maskedAccountNumber: 'XXXXXX6789',
          ifscCode: 'HDFC0005678',
          accountHolder: 'Sireesha S',
          currentBalance: 75900.00,
          availableBalance: 75900.00,
          lastSynced: '25 mins ago',
          isConnected: true,
        ),
      ],
      upiAccounts: [
        UpiAccountItem(
          id: 'upi_1',
          upiId: 'sireesha@oksbi',
          provider: 'Google Pay',
          linkedBank: 'State Bank of India',
          isPrimary: true,
          status: 'Active',
        ),
        UpiAccountItem(
          id: 'upi_2',
          upiId: 'sireesha@ybl',
          provider: 'PhonePe',
          linkedBank: 'HDFC Bank',
          isPrimary: false,
          status: 'Active',
        ),
        UpiAccountItem(
          id: 'upi_3',
          upiId: '9876543210@paytm',
          provider: 'Paytm UPI',
          linkedBank: 'State Bank of India',
          isPrimary: false,
          status: 'Active',
        ),
      ],
      creditCards: [
        CreditCardItem(
          id: 'card_1',
          cardName: 'HDFC Regalia Gold',
          last4Digits: '4567',
          creditLimit: 500000.00,
          outstandingBalance: 28450.00,
          availableCredit: 471550.00,
          statementDueDate: '18 Nov 2026',
          minimumDue: 1420.00,
          rewardPoints: 14200,
          cardHolderName: 'Sireesha Bandaru',
          issuedBank: 'HDFC Bank',
          cardType: 'Visa',
          expiryDate: '10/28',
        ),
        CreditCardItem(
          id: 'card_2',
          cardName: 'ICICI Amazon Pay',
          last4Digits: '8912',
          creditLimit: 300000.00,
          outstandingBalance: 14200.00,
          availableCredit: 285800.00,
          statementDueDate: '25 Nov 2026',
          minimumDue: 800.00,
          rewardPoints: 4850,
          cardHolderName: 'Sireesha Bandaru',
          issuedBank: 'ICICI Bank',
          cardType: 'Mastercard',
          expiryDate: '06/29',
        ),
      ],
      loans: [
        LoanAccountItem(
          id: 'loan_1',
          loanType: 'Home Loan',
          lender: 'State Bank of India',
          outstandingPrincipal: 2450000.00,
          interestRate: 8.55,
          monthlyEmi: 23450.00,
          tenureRemainingMonths: 168,
          nextDueDate: '05 Nov 2026',
        ),
        LoanAccountItem(
          id: 'loan_2',
          loanType: 'Vehicle Loan',
          lender: 'HDFC Bank',
          outstandingPrincipal: 385000.00,
          interestRate: 8.90,
          monthlyEmi: 11200.00,
          tenureRemainingMonths: 38,
          nextDueDate: '10 Nov 2026',
        ),
      ],
      investments: [
        InvestmentHoldingItem(
          id: 'inv_1',
          assetType: 'Mutual Funds',
          institution: 'Mirae Asset & Parag Parikh Flexi Cap',
          currentValue: 1240000.00,
          investedValue: 950000.00,
          returnPercentage: 30.5,
          isPositive: true,
        ),
        InvestmentHoldingItem(
          id: 'inv_2',
          assetType: 'Equity Stocks & ETFs',
          institution: 'Zerodha Kite Portfolio',
          currentValue: 875000.00,
          investedValue: 710000.00,
          returnPercentage: 23.2,
          isPositive: true,
        ),
        InvestmentHoldingItem(
          id: 'inv_3',
          assetType: 'Fixed Deposits',
          institution: 'HDFC Bank & SBI (7.25% p.a.)',
          currentValue: 500000.00,
          investedValue: 475000.00,
          returnPercentage: 5.3,
          isPositive: true,
        ),
        InvestmentHoldingItem(
          id: 'inv_4',
          assetType: 'Sovereign Gold Bonds',
          institution: 'RBI Gold Bond Series 2024',
          currentValue: 235000.00,
          investedValue: 198000.00,
          returnPercentage: 18.7,
          isPositive: true,
        ),
        InvestmentHoldingItem(
          id: 'inv_5',
          assetType: 'EPF & PPF (Retirement)',
          institution: 'Employees Provident Fund Org.',
          currentValue: 980000.00,
          investedValue: 860000.00,
          returnPercentage: 13.9,
          isPositive: true,
        ),
      ],
      insurancePolicies: [
        InsurancePolicyItem(
          id: 'ins_1',
          policyType: 'Health Insurance',
          policyNumberMasked: 'POL-XXXX-9842',
          provider: 'HDFC ERGO Optima Secure',
          coverageAmount: 1500000.00,
          premiumAmount: 14500.00,
          renewalDate: '14 Jul 2027',
          nominee: 'Spouse',
        ),
        InsurancePolicyItem(
          id: 'ins_2',
          policyType: 'Term Life Insurance',
          policyNumberMasked: 'POL-XXXX-4512',
          provider: 'Tata AIA Life Sampoorna',
          coverageAmount: 15000000.00,
          premiumAmount: 18200.00,
          renewalDate: '22 Sep 2027',
          nominee: 'Spouse',
        ),
        InsurancePolicyItem(
          id: 'ins_3',
          policyType: 'Vehicle Comprehensive',
          policyNumberMasked: 'POL-XXXX-1123',
          provider: 'Maruti Insurance Broking',
          coverageAmount: 750000.00,
          premiumAmount: 8500.00,
          renewalDate: '05 Jan 2027',
          nominee: 'Self',
        ),
      ],
      wallets: [
        WalletAccountItem(
          id: 'wal_1',
          walletName: 'Amazon Pay Wallet',
          balance: 2450.00,
          status: 'Active',
        ),
        WalletAccountItem(
          id: 'wal_2',
          walletName: 'Paytm Wallet',
          balance: 840.00,
          status: 'Active',
        ),
      ],
      consents: [
        AggregatorConsentItem(
          consentId: 'AA-908124567',
          institution: 'State Bank of India',
          consentType: 'Account & Transaction Access',
          startDate: '01 Jan 2026',
          expiryDate: '31 Dec 2027',
          purpose: 'Real-time Net Worth & AI CFO Analytics',
          dataShared: 'Balance, Profile, Transactions',
          status: 'Active',
        ),
        AggregatorConsentItem(
          consentId: 'AA-457812903',
          institution: 'HDFC Bank Ltd',
          consentType: 'Current Account & Card Access',
          startDate: '15 Feb 2026',
          expiryDate: '15 Feb 2027',
          purpose: 'Cash Flow & Auto-Expense Categorization',
          dataShared: 'Current Account Statement, Card Dues',
          status: 'Active',
        ),
        AggregatorConsentItem(
          consentId: 'AA-112233445',
          institution: 'ICICI Bank',
          consentType: 'Credit Card Due Tracking',
          startDate: '10 Mar 2025',
          expiryDate: '10 Mar 2026',
          purpose: 'Credit Utilization Analysis',
          dataShared: 'Card Statement & Limits',
          status: 'Expired',
        ),
      ],
      institutionDirectory: [
        InstitutionDirectoryItem(id: 'inst_1', name: 'State Bank of India', logoText: 'SBI', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_2', name: 'HDFC Bank Ltd', logoText: 'HDFC', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_3', name: 'ICICI Bank Ltd', logoText: 'ICICI', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_4', name: 'Axis Bank Ltd', logoText: 'AXIS', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_5', name: 'Kotak Mahindra Bank', logoText: 'KOTAK', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_6', name: 'Punjab National Bank', logoText: 'PNB', category: 'Banks'),
        InstitutionDirectoryItem(id: 'inst_7', name: 'Google Pay UPI', logoText: 'GPAY', category: 'UPI'),
        InstitutionDirectoryItem(id: 'inst_8', name: 'PhonePe UPI', logoText: 'PHONEPE', category: 'UPI'),
        InstitutionDirectoryItem(id: 'inst_9', name: 'Paytm Payments Bank / UPI', logoText: 'PAYTM', category: 'UPI'),
        InstitutionDirectoryItem(id: 'inst_10', name: 'BHIM UPI', logoText: 'BHIM', category: 'UPI'),
        InstitutionDirectoryItem(id: 'inst_11', name: 'Zerodha Broking', logoText: 'KITE', category: 'Investments'),
        InstitutionDirectoryItem(id: 'inst_12', name: 'Groww Investments', logoText: 'GROWW', category: 'Investments'),
        InstitutionDirectoryItem(id: 'inst_13', name: 'HDFC ERGO Health', logoText: 'ERGO', category: 'Insurance'),
        InstitutionDirectoryItem(id: 'inst_14', name: 'Tata AIA Life Insurance', logoText: 'AIA', category: 'Insurance'),
      ],
      recentTransactions: [
        AggregatorTransactionItem(
          id: 'tx_1',
          title: 'Salary Credit - TechCorp Global',
          category: 'Income',
          amount: 85000.00,
          date: '01 Oct 2026',
          institution: 'State Bank of India',
          type: 'NetBanking',
        ),
        AggregatorTransactionItem(
          id: 'tx_2',
          title: 'Home Loan EMI Debit',
          category: 'Debt EMI',
          amount: -23450.00,
          date: '05 Oct 2026',
          institution: 'State Bank of India',
          type: 'AutoPay Mandate',
        ),
        AggregatorTransactionItem(
          id: 'tx_3',
          title: 'Swiggy Food Delivery',
          category: 'Food & Dining',
          amount: -450.00,
          date: '10 Oct 2026',
          institution: 'Google Pay (SBI)',
          type: 'UPI',
        ),
        AggregatorTransactionItem(
          id: 'tx_4',
          title: 'Amazon Shopping Festival',
          category: 'Shopping',
          amount: -2890.00,
          date: '12 Oct 2026',
          institution: 'ICICI Amazon Pay Card',
          type: 'Credit Card',
        ),
        AggregatorTransactionItem(
          id: 'tx_5',
          title: 'SIP Auto-Debit Mirae Asset',
          category: 'Investments',
          amount: -5000.00,
          date: '14 Oct 2026',
          institution: 'HDFC Bank',
          type: 'AutoPay Mandate',
        ),
      ],
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

  Future<void> syncAllAccounts() async {
    state = state.copyWith(isSyncing: true);
    await Future.delayed(const Duration(milliseconds: 1400));
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    state = state.copyWith(
      isSyncing: false,
      lastSyncedTime: 'Today at $timeStr • Real-Time AA Sync Active',
      connectionStatus: 'All 7 Pillars Connected & Synced',
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
      accountHolder: 'Sireesha S',
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
    required String ifscCode,
    required String accountHolder,
    required double currentBalance,
  }) {
    final newAccount = BankAccountItem(
      id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
      bankName: bankName,
      accountType: accountType,
      maskedAccountNumber: maskedAccountNumber,
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

    state = state.copyWith(
      bankAccounts: [...state.bankAccounts, newAccount],
      consents: [newConsent, ...state.consents],
    );
  }

  void addCreditCardItem({
    required String cardName,
    required String last4Digits,
    required double creditLimit,
    required double outstandingBalance,
    required String statementDueDate,
    required double minimumDue,
    int rewardPoints = 1200,
    String? holderName,
    String? issuedBank,
    String? cardType,
    String? expiryDate,
  }) {
    final newCard = CreditCardItem(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      cardName: cardName,
      last4Digits: last4Digits,
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
    );
    state = state.copyWith(creditCards: [...state.creditCards, newCard]);
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
  }

  void updateBankAccount(BankAccountItem updated) {
    state = state.copyWith(
      bankAccounts: state.bankAccounts.map((a) => a.id == updated.id ? updated : a).toList(),
    );
  }

  void deleteBankAccount(String id) {
    state = state.copyWith(
      bankAccounts: state.bankAccounts.where((a) => a.id != id).toList(),
    );
  }

  void updateCreditCard(CreditCardItem updated) {
    state = state.copyWith(
      creditCards: state.creditCards.map((c) => c.id == updated.id ? updated : c).toList(),
    );
  }

  void deleteCreditCard(String id) {
    state = state.copyWith(
      creditCards: state.creditCards.where((c) => c.id != id).toList(),
    );
  }

  void updateUpiAccount(UpiAccountItem updated) {
    state = state.copyWith(
      upiAccounts: state.upiAccounts.map((u) => u.id == updated.id ? updated : u).toList(),
    );
  }

  void deleteUpiAccount(String id) {
    state = state.copyWith(
      upiAccounts: state.upiAccounts.where((u) => u.id != id).toList(),
    );
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
  }

  void updateLoanAccount(LoanAccountItem updated) {
    state = state.copyWith(
      loans: state.loans.map((l) => l.id == updated.id ? updated : l).toList(),
    );
  }

  void deleteLoanAccount(String id) {
    state = state.copyWith(
      loans: state.loans.where((l) => l.id != id).toList(),
    );
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
  }

  void updateInvestmentHolding(InvestmentHoldingItem updated) {
    state = state.copyWith(
      investments: state.investments.map((i) => i.id == updated.id ? updated : i).toList(),
    );
  }

  void deleteInvestmentHolding(String id) {
    state = state.copyWith(
      investments: state.investments.where((i) => i.id != id).toList(),
    );
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
  }

  void updateInsurancePolicy(InsurancePolicyItem updated) {
    state = state.copyWith(
      insurancePolicies: state.insurancePolicies.map((p) => p.id == updated.id ? updated : p).toList(),
    );
  }

  void deleteInsurancePolicy(String id) {
    state = state.copyWith(
      insurancePolicies: state.insurancePolicies.where((p) => p.id != id).toList(),
    );
  }

  void revokeConsent(String consentId) {
    final updated = state.consents.map((c) {
      if (c.consentId == consentId) {
        return AggregatorConsentItem(
          consentId: c.consentId,
          institution: c.institution,
          consentType: c.consentType,
          startDate: c.startDate,
          expiryDate: c.expiryDate,
          purpose: c.purpose,
          dataShared: c.dataShared,
          status: 'Revoked',
        );
      }
      return c;
    }).toList();
    state = state.copyWith(consents: updated);
  }

  void renewConsent(String consentId) {
    final updated = state.consents.map((c) {
      if (c.consentId == consentId) {
        return AggregatorConsentItem(
          consentId: c.consentId,
          institution: c.institution,
          consentType: c.consentType,
          startDate: 'Renewed Today',
          expiryDate: '1 Year from today',
          purpose: c.purpose,
          dataShared: c.dataShared,
          status: 'Active',
        );
      }
      return c;
    }).toList();
    state = state.copyWith(consents: updated);
  }
}

final bankAggregationProvider = NotifierProvider<BankAggregationNotifier, BankAggregationState>(() {
  return BankAggregationNotifier();
});
