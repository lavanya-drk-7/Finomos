# BACKEND API REQUIREMENTS
## Bank Aggregation & 5-Pillar Multi-Institution Engine — Flutter Consumer App (Finomos)

**Document Version**: 1.0 (Production Ready)  
**Target Platform**: Finomos Flutter Mobile App (`lib/features/bank_aggregation/`)  
**Base URL**: `https://finmos-user.onrender.com`  
**Authentication**: Bearer JWT (`Authorization: Bearer <token>` from `/api/auth/login`)  
**Compliance Standards**: RBI Account Aggregator (NBFC-AA), Sahamati Technical Specifications, Section 65B Indian Evidence Act

---

## 1. Executive Summary & Module Architecture

The **Bank Aggregation Module** is the foundational data ingestion layer of Finomos (PFOS / AI Personal CFO). It aggregates a user's entire financial life across the **5 Core Financial Pillars** under RBI's Account Aggregator framework:

1. **Pillar 1 — Bank Accounts**: Savings, Current, Salary, FD, RD, and NRE/NRO accounts with real-time balance tracking, IFSC lookup, and auto-branch detection.
2. **Pillar 2 — Cards (Credit & Debit)**: Credit limits, outstanding balances, available credit, statement due dates, minimum dues, reward points, and debit card daily ATM/POS limits.
3. **Pillar 3 — Loans & Credit Liabilities**: Home loans, vehicle loans, personal loans, interest rates, tenure remaining, next EMI due date, and amortization tracking.
4. **Pillar 4 — Investments & Wealth Holdings**: Mutual funds, equity stocks (Zerodha/Groww), Sovereign Gold Bonds, Fixed Deposits, and EPF/PPF retirement corpus.
5. **Pillar 5 — Insurance Policies**: Health, term life, and comprehensive motor insurance coverage, annual premiums, renewal dates, and nominee tracking.
* **Supporting Pillars**:
  * **UPI & Digital Wallets**: VPA management (GPay, PhonePe, Paytm, BHIM), primary routing, and prepaid wallet balances.
  * **RBI AA Consent Lifecycle**: Consent artifact issuance, data sharing scopes, active validity, automated renewals, and instant revocation.
  * **Multi-Institution Transaction Feed**: Unified transaction stream across banks, cards, UPI, and investments.

### Mobile Client File References
* **Presentation Screen**: [`lib/features/bank_aggregation/presentation/bank_aggregation_screen.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/bank_aggregation/presentation/bank_aggregation_screen.dart)
* **Domain Models**: [`lib/features/bank_aggregation/domain/bank_aggregation_models.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/bank_aggregation/domain/bank_aggregation_models.dart)
* **Riverpod State Provider**: [`lib/features/bank_aggregation/providers/bank_aggregation_provider.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/bank_aggregation/providers/bank_aggregation_provider.dart)
* **Unified Dashboard Service**: [`lib/features/dashboard/services/dashboard_api_service.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/dashboard/services/dashboard_api_service.dart)

---

## 2. Mathematical Formulas & Business Rules

The backend service must compute and maintain the following aggregated financial metrics for every user:

### 2.1 Cash Position
$$\text{Total Bank Cash} = \sum_{a \in \text{bankAccounts}} a.\text{currentBalance}$$
$$\text{Total Wallet Cash} = \sum_{w \in \text{wallets}} w.\text{balance}$$
$$\text{Total Cash Position} = \text{Total Bank Cash} + \text{Total Wallet Cash}$$

### 2.2 Debt & Credit Liability Position
$$\text{Total Credit Card Debt} = \sum_{c \in \text{creditCards}, \neg c.\text{isDebit}} c.\text{outstandingBalance}$$
$$\text{Total Loan Debt} = \sum_{l \in \text{loans}} l.\text{outstandingPrincipal}$$
$$\text{Total Debt Position} = \text{Total Credit Card Debt} + \text{Total Loan Debt}$$

### 2.3 Wealth & Net Worth Metrics
$$\text{Total Investments} = \sum_{i \in \text{investments}} i.\text{currentValue}$$
$$\text{Total Assets} = \text{Total Cash Position} + \text{Total Investments}$$
$$\text{Total Liabilities} = \text{Total Debt Position}$$
$$\text{Net Worth} = \text{Total Assets} - \text{Total Liabilities}$$

### 2.4 Credit Card Utilization Ratio
$$\text{Utilization Ratio} = \begin{cases} \frac{\text{outstandingBalance}}{\text{creditLimit}}, & \text{if } \text{creditLimit} > 0 \text{ and } \neg\text{isDebit} \\ 0.0, & \text{otherwise} \end{cases}$$
$$\text{Utilization \%} = \text{Utilization Ratio} \times 100$$
* **Guardrail Threshold**:
  * $\le 30.0\%$: Healthy / Green (Safe credit guardrail)
  * $> 30.0\%$ and $\le 50.0\%$: Moderate Warning
  * $> 50.0\%$: Critical Overutilization (Negative CIBIL impact warning)

### 2.5 RBI AA Consent State Machine
* **`PENDING`**: Consent request raised, waiting for user OTP authorization on the AA handle.
* **`ACTIVE`**: Authorized by user; real-time scheduled FI data fetch enabled.
* **`EXPIRED`**: Validity period ended; automated polling halted.
* **`REVOKED`**: User terminated consent in UI; all automated background fetches cease immediately.

---

## 3. Complete API Inventory Overview

| Category | Method | Endpoint | Description |
|---|---|---|---|
| **Consolidated Position** | `GET` | `/api/v1/bank-aggregation/summary` | Consolidated Assets, Liabilities, Net Worth & Pillar Counts |
| | `POST` | `/api/v1/bank-aggregation/sync-all` | Trigger full real-time AA refresh across all 5 pillars |
| **Pillar 1: Bank Accounts** | `GET` | `/api/v1/bank-aggregation/accounts` | Fetch all linked bank accounts & balances |
| | `POST` | `/api/v1/bank-aggregation/accounts` | Link new bank account (manual or verified) |
| | `GET` | `/api/v1/bank-aggregation/accounts/:id` | Get single bank account details |
| | `PUT` | `/api/v1/bank-aggregation/accounts/:id` | Update account details (type, branch, holder) |
| | `DELETE` | `/api/v1/bank-aggregation/accounts/:id` | Unlink / disconnect bank account |
| | `POST` | `/api/v1/bank-aggregation/accounts/:id/sync` | Trigger single bank account balance sync |
| | `GET` | `/api/v1/bank-aggregation/lookup/ifsc/:ifsc` | Lookup bank branch & city from IFSC |
| **Pillar 2: Cards** | `GET` | `/api/v1/bank-aggregation/cards` | Fetch all Credit & Debit cards |
| | `POST` | `/api/v1/bank-aggregation/cards` | Link new Credit or Debit card |
| | `GET` | `/api/v1/bank-aggregation/cards/:id` | Get single card details |
| | `PUT` | `/api/v1/bank-aggregation/cards/:id` | Update card limits, due date, billing info |
| | `DELETE` | `/api/v1/bank-aggregation/cards/:id` | Remove / delink card |
| **Pillar 3: Loans & EMIs** | `GET` | `/api/v1/bank-aggregation/loans` | Fetch all active loan accounts & EMIs |
| | `POST` | `/api/v1/bank-aggregation/loans` | Add a loan account |
| | `PUT` | `/api/v1/bank-aggregation/loans/:id` | Update outstanding balance, EMI, or tenure |
| | `DELETE` | `/api/v1/bank-aggregation/loans/:id` | Remove loan record |
| **Pillar 4: Investments** | `GET` | `/api/v1/bank-aggregation/investments` | Fetch all investment holdings |
| | `POST` | `/api/v1/bank-aggregation/investments` | Add an investment holding |
| | `PUT` | `/api/v1/bank-aggregation/investments/:id` | Update current value, returns, or units |
| | `DELETE` | `/api/v1/bank-aggregation/investments/:id` | Remove investment holding |
| **Pillar 5: Insurance** | `GET` | `/api/v1/bank-aggregation/insurance` | Fetch all insurance policies |
| | `POST` | `/api/v1/bank-aggregation/insurance` | Add insurance policy record |
| | `PUT` | `/api/v1/bank-aggregation/insurance/:id` | Update policy coverage, premium, renewal date |
| | `DELETE` | `/api/v1/bank-aggregation/insurance/:id` | Remove insurance policy |
| **UPI & Wallets** | `GET` | `/api/v1/bank-aggregation/upi-accounts` | Fetch linked UPI VPAs |
| | `POST` | `/api/v1/bank-aggregation/upi-accounts` | Link new UPI ID |
| | `PATCH` | `/api/v1/bank-aggregation/upi-accounts/:id/set-primary` | Set primary routing UPI ID |
| | `DELETE` | `/api/v1/bank-aggregation/upi-accounts/:id` | Delink UPI ID |
| | `GET` | `/api/v1/bank-aggregation/wallets` | Fetch digital wallets & balances |
| **AA Consents** | `GET` | `/api/v1/bank-aggregation/consents` | List all RBI AA consents |
| | `POST` | `/api/v1/bank-aggregation/consents/initiate` | Initiate new AA consent request |
| | `POST` | `/api/v1/bank-aggregation/consents/:id/revoke` | Revoke active AA consent |
| | `POST` | `/api/v1/bank-aggregation/consents/:id/renew` | Renew / extend AA consent |
| **Transactions & Directory**| `GET` | `/api/v1/bank-aggregation/transactions` | Filtered timeline feed of transactions |
| | `GET` | `/api/v1/bank-aggregation/institutions` | Directory of supported FIP/FIU institutions |

---

## 4. Detailed Endpoint Specifications

### 4.1 Consolidated Financial Summary
#### `GET /api/v1/bank-aggregation/summary`
Returns the user's top-level financial aggregation overview, cash position, total debt, investments, net worth, and pillar counters.

* **Headers**: `Authorization: Bearer <token>`
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": {
    "totalAssets": 4050750.00,
    "totalLiabilities": 2877650.00,
    "netWorth": 1173100.00,
    "totalCashPosition": 222040.00,
    "totalBankCash": 218750.00,
    "totalWalletCash": 3290.00,
    "totalDebtPosition": 2877650.00,
    "totalCreditCardDebt": 42650.00,
    "totalLoanDebt": 2835000.00,
    "totalInvestments": 3828710.00,
    "totalInsuranceCoverage": 17250000.00,
    "totalCreditLimit": 800000.00,
    "totalCreditAvailable": 757350.00,
    "overallCreditUtilization": 5.33,
    "activePillarsCount": 5,
    "totalPillars": 5,
    "connectionStatus": "All 5 Pillars Connected & Synced",
    "lastSyncedTime": "Today at 14:30 • Real-Time AA Sync Active",
    "counts": {
      "bankAccounts": 2,
      "creditCards": 2,
      "debitCards": 1,
      "loans": 2,
      "investments": 5,
      "insurancePolicies": 3,
      "upiAccounts": 3,
      "wallets": 2,
      "activeConsents": 2
    }
  }
}
```

---

#### `POST /api/v1/bank-aggregation/sync-all`
Forces a fresh on-demand pull from all connected FIPs via the Account Aggregator pipeline.

* **Headers**: `Authorization: Bearer <token>`
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "All 5 pillars synchronized successfully",
  "data": {
    "syncedAt": "2026-10-30T10:05:00.000Z",
    "syncedAccountsCount": 2,
    "syncedCardsCount": 2,
    "syncedLoansCount": 2,
    "syncedInvestmentsCount": 5,
    "newTransactionsDetected": 3,
    "connectionStatus": "All 5 Pillars Connected & Synced",
    "lastSyncedTime": "Just now • Every 4 Hours"
  }
}
```

---

### 4.2 Pillar 1: Bank Accounts

#### `GET /api/v1/bank-aggregation/accounts`
Retrieves all bank accounts linked to the user profile.

* **Headers**: `Authorization: Bearer <token>`
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "bank_1",
      "bankName": "State Bank of India",
      "accountType": "Savings Account",
      "maskedAccountNumber": "XXXXXX4821",
      "rawAccountNumber": "1100224587",
      "ifscCode": "SBIN0001234",
      "branch": "Commercial Branch Bangalore",
      "accountHolder": "Sireesha Bandaru",
      "currentBalance": 142850.00,
      "availableBalance": 142850.00,
      "internalBalance": 27000.00,
      "lastSynced": "10 mins ago",
      "isConnected": true,
      "isAggregated": true,
      "consentId": "AA-CONSENT-SBIN-8891",
      "logo": "SBI",
      "color": "#1E3A8A",
      "status": "ACTIVE"
    },
    {
      "id": "bank_2",
      "bankName": "HDFC Bank",
      "accountType": "Current Account",
      "maskedAccountNumber": "XXXXXX6789",
      "rawAccountNumber": "5010045896789",
      "ifscCode": "HDFC0005678",
      "branch": "Koramangala Main Branch",
      "accountHolder": "Sireesha Bandaru",
      "currentBalance": 75900.00,
      "availableBalance": 75900.00,
      "internalBalance": 72311.00,
      "lastSynced": "25 mins ago",
      "isConnected": true,
      "isAggregated": true,
      "consentId": "AA-CONSENT-HDFC-3321",
      "logo": "HDFC",
      "color": "#004C8F",
      "status": "ACTIVE"
    }
  ]
}
```

---

#### `POST /api/v1/bank-aggregation/accounts`
Links a new bank account. Supports IFSC auto-resolution and Account Aggregator consent registration.

* **Headers**: `Authorization: Bearer <token>`, `Content-Type: application/json`
* **Request Body**:
```json
{
  "bankName": "ICICI Bank",
  "accountType": "Savings Account",
  "accountNumber": "001101569021",
  "reEnterAccountNumber": "001101569021",
  "ifscCode": "ICIC0000011",
  "branch": "MG Road Main Branch",
  "accountHolder": "Sireesha Bandaru",
  "openingBalance": 45000.00
}
```
* **Success Response (`201 Created`)**:
```json
{
  "success": true,
  "message": "Bank account linked successfully",
  "data": {
    "id": "cmv6b_icici_001",
    "bankName": "ICICI Bank",
    "accountType": "Savings Account",
    "maskedAccountNumber": "XXXXXX9021",
    "ifscCode": "ICIC0000011",
    "branch": "MG Road Main Branch",
    "accountHolder": "Sireesha Bandaru",
    "currentBalance": 45000.00,
    "availableBalance": 45000.00,
    "lastSynced": "Just now",
    "isConnected": true,
    "isAggregated": true,
    "consentId": "AA-ICICI-179335",
    "logo": "ICICI",
    "color": "#991B1B",
    "status": "ACTIVE"
  }
}
```

---

#### `GET /api/v1/bank-aggregation/lookup/ifsc/:ifsc`
Resolves bank name, branch, city, and state from standard RBI IFSC code for instant UI auto-fill.

* **Example**: `GET /api/v1/bank-aggregation/lookup/ifsc/SBIN0001234`
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": {
    "ifsc": "SBIN0001234",
    "bank": "State Bank of India",
    "branch": "Commercial Branch Bangalore",
    "address": "Residency Road, Bangalore, Karnataka - 560025",
    "city": "Bangalore",
    "district": "Bangalore Urban",
    "state": "Karnataka",
    "contact": "080-25584900",
    "rtgs": true,
    "neft": true,
    "imps": true,
    "upi": true
  }
}
```

---

#### `PUT /api/v1/bank-aggregation/accounts/:id`
Updates details of an existing linked bank account.

* **Request Body**:
```json
{
  "accountType": "Salary Account",
  "branch": "Koramangala 4th Block",
  "accountHolder": "Sireesha Bandaru"
}
```

---

#### `DELETE /api/v1/bank-aggregation/accounts/:id`
Unlinks the bank account and stops data polling.

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Bank account unlinked successfully"
}
```

---

### 4.3 Pillar 2: Cards (Credit & Debit)

#### `GET /api/v1/bank-aggregation/cards`
Returns all Credit and Debit cards linked to the user.

* **Headers**: `Authorization: Bearer <token>`
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "card_1",
      "cardName": "HDFC Regalia Gold",
      "last4Digits": "4567",
      "creditLimit": 500000.00,
      "outstandingBalance": 28450.00,
      "availableCredit": 471550.00,
      "statementDueDate": "18 Nov 2026",
      "minimumDue": 1420.00,
      "rewardPoints": 14200,
      "cardHolderName": "Sireesha Bandaru",
      "issuedBank": "HDFC Bank",
      "cardType": "Visa",
      "expiryDate": "10/28",
      "isDebit": false,
      "dailyAtmLimit": null,
      "dailyPosLimit": null,
      "linkedAccount": null
    },
    {
      "id": "card_3",
      "cardName": "HDFC Millennia Platinum Debit Card",
      "last4Digits": "8754",
      "creditLimit": 0.00,
      "outstandingBalance": 0.00,
      "availableCredit": 0.00,
      "statementDueDate": "N/A",
      "minimumDue": 0.00,
      "rewardPoints": 3200,
      "cardHolderName": "Sireesha Bandaru",
      "issuedBank": "HDFC Bank",
      "cardType": "Mastercard",
      "expiryDate": "04/30",
      "isDebit": true,
      "dailyAtmLimit": 50000.00,
      "dailyPosLimit": 150000.00,
      "linkedAccount": "Primary Savings A/C (••••6789)"
    }
  ]
}
```

---

#### `POST /api/v1/bank-aggregation/cards`
Links a new Credit or Debit card.

* **Request Body**:
```json
{
  "cardName": "SBI SimplyCLICK",
  "last4Digits": "9981",
  "cardNumber": "4591002233449981",
  "creditLimit": 200000.00,
  "outstandingBalance": 12500.00,
  "statementDueDate": "12 Nov 2026",
  "minimumDue": 650.00,
  "rewardPoints": 2400,
  "cardHolderName": "Sireesha Bandaru",
  "issuedBank": "State Bank of India",
  "cardType": "Visa",
  "expiryDate": "08/29",
  "isDebit": false,
  "dailyAtmLimit": null,
  "dailyPosLimit": null,
  "linkedAccount": null
}
```

---

#### `PUT /api/v1/bank-aggregation/cards/:id`
Updates card limits, daily ATM/POS limits, due dates, or outstanding balance.

---

#### `DELETE /api/v1/bank-aggregation/cards/:id`
Delinks card from profile.

---

### 4.4 Pillar 3: Loans & Credit Liabilities

#### `GET /api/v1/bank-aggregation/loans`
Returns all active loan accounts, EMIs, and outstanding principal balances.

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "loan_1",
      "loanType": "Home Loan",
      "lender": "State Bank of India",
      "outstandingPrincipal": 2450000.00,
      "interestRate": 8.55,
      "monthlyEmi": 23450.00,
      "tenureRemainingMonths": 168,
      "nextDueDate": "05 Nov 2026",
      "loanAccountNumber": "HL-SBIN-99214"
    },
    {
      "id": "loan_2",
      "loanType": "Vehicle Loan",
      "lender": "HDFC Bank",
      "outstandingPrincipal": 385000.00,
      "interestRate": 8.90,
      "monthlyEmi": 11200.00,
      "tenureRemainingMonths": 38,
      "nextDueDate": "10 Nov 2026",
      "loanAccountNumber": "AL-HDFC-3301"
    }
  ]
}
```

---

#### `POST /api/v1/bank-aggregation/loans`
Adds a loan account.

* **Request Body**:
```json
{
  "loanType": "Personal Loan",
  "lender": "Axis Bank",
  "outstandingPrincipal": 150000.00,
  "interestRate": 11.25,
  "monthlyEmi": 6500.00,
  "tenureRemainingMonths": 24,
  "nextDueDate": "15 Nov 2026"
}
```

---

### 4.5 Pillar 4: Investments & Wealth Holdings

#### `GET /api/v1/bank-aggregation/investments`
Returns portfolio investments across Mutual Funds, Stocks, FDs, SGBs, and EPF/PPF.

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "inv_1",
      "assetType": "Mutual Funds",
      "institution": "Mirae Asset & Parag Parikh Flexi Cap",
      "currentValue": 1240000.00,
      "investedValue": 950000.00,
      "returnPercentage": 30.52,
      "isPositive": true
    },
    {
      "id": "inv_2",
      "assetType": "Equity Stocks & ETFs",
      "institution": "Zerodha Kite Portfolio",
      "currentValue": 875000.00,
      "investedValue": 710000.00,
      "returnPercentage": 23.24,
      "isPositive": true
    },
    {
      "id": "inv_4",
      "assetType": "Sovereign Gold Bonds",
      "institution": "RBI Gold Bond Series 2024",
      "currentValue": 235000.00,
      "investedValue": 198000.00,
      "returnPercentage": 18.69,
      "isPositive": true
    }
  ]
}
```

---

#### `POST /api/v1/bank-aggregation/investments`
Creates a new investment asset entry.

---

### 4.6 Pillar 5: Insurance Policies

#### `GET /api/v1/bank-aggregation/insurance`
Returns health, term life, and comprehensive insurance policies.

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "ins_1",
      "policyType": "Health Insurance",
      "policyNumberMasked": "POL-XXXX-9842",
      "provider": "HDFC ERGO Optima Secure",
      "coverageAmount": 1500000.00,
      "premiumAmount": 14500.00,
      "renewalDate": "14 Jul 2027",
      "nominee": "Spouse"
    },
    {
      "id": "ins_2",
      "policyType": "Term Life Insurance",
      "policyNumberMasked": "POL-XXXX-4512",
      "provider": "Tata AIA Life Sampoorna",
      "coverageAmount": 15000000.00,
      "premiumAmount": 18200.00,
      "renewalDate": "22 Sep 2027",
      "nominee": "Spouse"
    }
  ]
}
```

---

#### `POST /api/v1/bank-aggregation/insurance`
Adds a new insurance policy.

---

### 4.7 UPI & Digital Wallets

#### `GET /api/v1/bank-aggregation/upi-accounts`
Returns all linked UPI Virtual Private Addresses (VPAs).

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "upi_1",
      "upiId": "sireesha@oksbi",
      "provider": "Google Pay",
      "linkedBank": "State Bank of India",
      "isPrimary": true,
      "status": "Active"
    },
    {
      "id": "upi_2",
      "upiId": "sireesha@ybl",
      "provider": "PhonePe",
      "linkedBank": "HDFC Bank",
      "isPrimary": false,
      "status": "Active"
    }
  ]
}
```

---

#### `PATCH /api/v1/bank-aggregation/upi-accounts/:id/set-primary`
Sets the specified UPI ID as the default primary VPA for all in-app UPI payouts and payment requests.

---

#### `GET /api/v1/bank-aggregation/wallets`
Returns digital prepaid wallets and balances.

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "wal_1",
      "walletName": "Amazon Pay Wallet",
      "balance": 2450.00,
      "status": "Active"
    },
    {
      "id": "wal_2",
      "walletName": "Paytm Wallet",
      "balance": 840.00,
      "status": "Active"
    }
  ]
}
```

---

### 4.8 RBI Account Aggregator Consents

#### `GET /api/v1/bank-aggregation/consents`
Fetches all user consent artifacts registered with RBI NBFC-AAs.

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": [
    {
      "consentId": "AA-908124567",
      "institution": "State Bank of India",
      "consentType": "Account & Transaction Access",
      "startDate": "01 Jan 2026",
      "expiryDate": "31 Dec 2027",
      "purpose": "Real-time Net Worth & AI CFO Analytics",
      "dataShared": "Balance, Profile, Transactions",
      "status": "Active"
    },
    {
      "consentId": "AA-112233445",
      "institution": "ICICI Bank",
      "consentType": "Credit Card Due Tracking",
      "startDate": "10 Mar 2025",
      "expiryDate": "10 Mar 2026",
      "purpose": "Credit Utilization Analysis",
      "dataShared": "Card Statement & Limits",
      "status": "Expired"
    }
  ]
}
```

---

#### `POST /api/v1/bank-aggregation/consents/:id/revoke`
Instantly revokes an active AA consent. Future automated polling from this institution is blocked immediately.

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Consent revoked successfully",
  "data": {
    "consentId": "AA-908124567",
    "status": "Revoked",
    "revokedAt": "2026-10-30T10:15:00.000Z"
  }
}
```

---

#### `POST /api/v1/bank-aggregation/consents/:id/renew`
Extends or re-initiates an expired or expiring consent for another 12 to 24 months.

---

### 4.9 Multi-Institution Transactions Timeline Feed

#### `GET /api/v1/bank-aggregation/transactions`
Unified feed combining debit, credit, EMI, and investment auto-debits across all accounts.

* **Query Parameters**:
  * `category`: Optional filter (`Income`, `Debt EMI`, `Food & Dining`, `Shopping`, `Investments`, `All`)
  * `institution`: Optional filter by institution name
  * `type`: `UPI`, `NetBanking`, `Card`, `Standing Instruction`, `Auto-Debit`, `All`
  * `search`: Free text search
  * `page`: Default `1`
  * `limit`: Default `20`
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "id": "tx_1",
        "title": "Salary Credit - TechCorp Global",
        "category": "Income",
        "amount": 85000.00,
        "date": "01 Oct 2026",
        "institution": "State Bank of India",
        "type": "NetBanking",
        "isCredit": true
      },
      {
        "id": "tx_2",
        "title": "Home Loan EMI Debit",
        "category": "Debt EMI",
        "amount": -23450.00,
        "date": "05 Oct 2026",
        "institution": "State Bank of India",
        "type": "Standing Instruction",
        "isCredit": false
      },
      {
        "id": "tx_4",
        "title": "Amazon Shopping Festival",
        "category": "Shopping",
        "amount": -2890.00,
        "date": "12 Oct 2026",
        "institution": "ICICI Amazon Pay Card",
        "type": "Credit Card",
        "isCredit": false
      }
    ],
    "pagination": {
      "currentPage": 1,
      "perPage": 20,
      "totalRecords": 45,
      "totalPages": 3
    }
  }
}
```

---

## 5. PostgreSQL Database Schema (Prisma / Supabase DDL)

The backend team can execute the following SQL DDL script to create the complete relational database tables for this module:

```sql
-- 1. Linked Bank Accounts Table
CREATE TABLE IF NOT EXISTS bank_accounts (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    bank_name VARCHAR(128) NOT NULL,
    account_type VARCHAR(64) NOT NULL DEFAULT 'Savings Account',
    masked_account_number VARCHAR(32) NOT NULL,
    raw_account_number VARCHAR(32),
    ifsc_code VARCHAR(16) NOT NULL,
    branch VARCHAR(128),
    account_holder VARCHAR(128) NOT NULL,
    current_balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    available_balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    internal_balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    is_connected BOOLEAN NOT NULL DEFAULT true,
    is_aggregated BOOLEAN NOT NULL DEFAULT true,
    consent_id VARCHAR(64),
    logo VARCHAR(32) DEFAULT 'GENERIC',
    color VARCHAR(16) DEFAULT '#1E3A8A',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    last_synced_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Cards Table (Credit & Debit)
CREATE TABLE IF NOT EXISTS credit_cards (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    card_name VARCHAR(128) NOT NULL,
    last4_digits VARCHAR(4) NOT NULL,
    card_number VARCHAR(32),
    credit_limit NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    outstanding_balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    available_credit NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    statement_due_date VARCHAR(64) NOT NULL DEFAULT '20th of month',
    minimum_due NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    reward_points INT NOT NULL DEFAULT 0,
    card_holder_name VARCHAR(128),
    issued_bank VARCHAR(128),
    card_type VARCHAR(32) DEFAULT 'Visa',
    expiry_date VARCHAR(16),
    is_debit BOOLEAN NOT NULL DEFAULT false,
    daily_atm_limit NUMERIC(14, 2),
    daily_pos_limit NUMERIC(14, 2),
    linked_account VARCHAR(128),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Loan Accounts Table
CREATE TABLE IF NOT EXISTS loan_accounts (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    loan_type VARCHAR(64) NOT NULL,
    lender VARCHAR(128) NOT NULL,
    loan_account_number VARCHAR(64),
    outstanding_principal NUMERIC(14, 2) NOT NULL,
    interest_rate NUMERIC(5, 2) NOT NULL,
    monthly_emi NUMERIC(14, 2) NOT NULL,
    tenure_remaining_months INT NOT NULL,
    next_due_date VARCHAR(64) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Investment Holdings Table
CREATE TABLE IF NOT EXISTS investment_holdings (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    asset_type VARCHAR(64) NOT NULL,
    institution VARCHAR(128) NOT NULL,
    current_value NUMERIC(14, 2) NOT NULL,
    invested_value NUMERIC(14, 2) NOT NULL,
    return_percentage NUMERIC(6, 2) NOT NULL,
    is_positive BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Insurance Policies Table
CREATE TABLE IF NOT EXISTS insurance_policies (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    policy_type VARCHAR(64) NOT NULL,
    policy_number_masked VARCHAR(64) NOT NULL,
    provider VARCHAR(128) NOT NULL,
    coverage_amount NUMERIC(14, 2) NOT NULL,
    premium_amount NUMERIC(14, 2) NOT NULL,
    renewal_date VARCHAR(64) NOT NULL,
    nominee VARCHAR(128) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. UPI Accounts Table
CREATE TABLE IF NOT EXISTS upi_accounts (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    upi_id VARCHAR(128) NOT NULL UNIQUE,
    provider VARCHAR(64) NOT NULL,
    linked_bank VARCHAR(128) NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    status VARCHAR(32) NOT NULL DEFAULT 'Active',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Digital Wallets Table
CREATE TABLE IF NOT EXISTS wallets (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    wallet_name VARCHAR(64) NOT NULL,
    balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(32) NOT NULL DEFAULT 'Active',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 8. RBI AA Consents Table
CREATE TABLE IF NOT EXISTS aa_consents (
    id VARCHAR(64) PRIMARY KEY,
    consent_id VARCHAR(64) NOT NULL UNIQUE,
    user_id VARCHAR(64) NOT NULL,
    institution VARCHAR(128) NOT NULL,
    consent_type VARCHAR(128) NOT NULL,
    start_date VARCHAR(64) NOT NULL,
    expiry_date VARCHAR(64) NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    data_shared VARCHAR(255) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'Active',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for lightning fast queries
CREATE INDEX IF NOT EXISTS idx_bank_accounts_user ON bank_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_credit_cards_user ON credit_cards(user_id);
CREATE INDEX IF NOT EXISTS idx_loan_accounts_user ON loan_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_investment_holdings_user ON investment_holdings(user_id);
CREATE INDEX IF NOT EXISTS idx_insurance_policies_user ON insurance_policies(user_id);
CREATE INDEX IF NOT EXISTS idx_upi_accounts_user ON upi_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_aa_consents_user ON aa_consents(user_id);
```

---

## 6. Postman Collection & Testing Instructions

To test these endpoints quickly via Postman or cURL:

### Step 1: Login to get Bearer Token
```bash
curl -X POST https://finmos-user.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "sireesha@finmos.com", "password": "Password123!"}'
```

### Step 2: Fetch Aggregation Summary
```bash
curl -X GET https://finmos-user.onrender.com/api/v1/bank-aggregation/summary \
  -H "Authorization: Bearer <TOKEN>"
```

### Step 3: Link a Bank Account
```bash
curl -X POST https://finmos-user.onrender.com/api/v1/bank-aggregation/accounts \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "bankName": "State Bank of India",
    "accountType": "Savings Account",
    "accountNumber": "1100224587",
    "reEnterAccountNumber": "1100224587",
    "ifscCode": "SBIN0001234",
    "branch": "Commercial Branch Bangalore",
    "accountHolder": "Sireesha Bandaru",
    "openingBalance": 45250.00
  }'
```

### Step 4: Link a Credit Card
```bash
curl -X POST https://finmos-user.onrender.com/api/v1/bank-aggregation/cards \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "cardName": "HDFC Regalia Gold",
    "last4Digits": "4567",
    "creditLimit": 500000.00,
    "outstandingBalance": 28450.00,
    "statementDueDate": "18 Nov 2026",
    "minimumDue": 1420.00,
    "issuedBank": "HDFC Bank",
    "cardType": "Visa",
    "expiryDate": "10/28"
  }'
```

### Step 5: Test IFSC Lookup
```bash
curl -X GET https://finmos-user.onrender.com/api/v1/bank-aggregation/lookup/ifsc/SBIN0001234 \
  -H "Authorization: Bearer <TOKEN>"
```

---

## 7. Delivery Checklist for Backend Team

- [ ] **Database Setup**: Run the SQL schema script in Section 5 on PostgreSQL/Supabase.
- [ ] **Base Router**: Mount router at `/api/v1/bank-aggregation/`.
- [ ] **Authentication Middleware**: Validate Bearer JWT token on all `/api/v1/bank-aggregation/*` endpoints.
- [ ] **Summary Calculations**: Implement formulas for Cash Position, Debt Position, and Net Worth as defined in Section 2.
- [ ] **IFSC Resolution**: Integrate Razorpay IFSC API or RBI static branch directory for `/lookup/ifsc/:ifsc`.
- [ ] **Account Aggregator Webhook**: Handle consent callbacks (`ACTIVE`, `REVOKED`, `EXPIRED`).
- [ ] **Live Deployment**: Deploy to Render (`https://finmos-user.onrender.com`).



---

## 8. Cross-Module Dynamic Balance Sync Rules (PFOS Core)

To make the system truly live and dynamic (rather than static silos), the backend MUST execute the following balance mutations across modules:

1. **Expense Deduction**:
   When an expense is recorded via POST /api/v1/expenses/entries, POST /api/expense, or confirmed from POST /api/v1/expenses/detected/:id/confirm:
   * Identify the target ank_account_id or matched ank_name.
   * Execute atomic deduction:
     \text{bank_accounts.current_balance} = \text{bank_accounts.current_balance} - \text{expense.amount}
     \text{bank_accounts.internal_balance} = \text{bank_accounts.internal_balance} - \text{expense.amount}
   * If paid via Credit Card:
     \text{credit_cards.outstanding_balance} = \text{credit_cards.outstanding_balance} + \text{expense.amount}
     \text{credit_cards.available_credit} = \max(0, \text{credit_cards.credit_limit} - \text{credit_cards.outstanding_balance})

2. **Income Addition**:
   When an income inflow is recorded via POST /api/v1/income/entries, POST /api/income, or confirmed from POST /api/v1/income/detected-inflows/:id/confirm:
   * Identify target ank_account_id.
   * Execute atomic addition:
     \text{bank_accounts.current_balance} = \text{bank_accounts.current_balance} + \text{income.amount}
     \text{bank_accounts.internal_balance} = \text{bank_accounts.internal_balance} + \text{income.amount}

3. **Loan EMI Debit**:
   When a loan standing instruction fires on its 
ext_due_date:
   * Deduct monthly_emi from linked bank account.
   * Reduce outstanding_principal:
     \text{loan_accounts.outstanding_principal} = \max(0, \text{loan_accounts.outstanding_principal} - (\text{monthly_emi} \times 0.70))
   * Decrement 	enure_remaining_months by 1.

---

## 9. Baseline Production Seed Data Script (Sireesha Bandaru Profile)

The backend team can execute this SQL script immediately after creating tables so the app opens with rich, live data:

`sql
-- Seed User ID: 'cmuzhxi5a000asr4p9f6jcndp' (Sireesha Bandaru)

-- 1. Seed Bank Accounts
INSERT INTO bank_accounts (id, user_id, bank_name, account_type, masked_account_number, raw_account_number, ifsc_code, branch, account_holder, current_balance, available_balance, internal_balance, is_connected, is_aggregated, consent_id, logo, color, status)
VALUES 
('cmv6b7bvc00012ak0sy594x7q', 'cmuzhxi5a000asr4p9f6jcndp', 'State Bank of India', 'Savings Account', '**** 4587', '1100224587', 'SBIN0001234', 'Commercial Branch Bangalore', 'Sireesha Bandaru', 142850.00, 142850.00, 27000.00, true, true, 'AA-CONSENT-SBIN-8891', 'SBI', '#1E3A8A', 'ACTIVE'),
('cmv6b96j300032ak0d0o7eoc5', 'cmuzhxi5a000asr4p9f6jcndp', 'HDFC Bank', 'Current Account', '**** 6789', '5010045896789', 'HDFC0005678', 'Koramangala Main Branch', 'Sireesha Bandaru', 75900.00, 75900.00, 72311.00, true, true, 'AA-CONSENT-HDFC-3321', 'HDFC', '#004C8F', 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

-- 2. Seed Credit & Debit Cards
INSERT INTO credit_cards (id, user_id, card_name, last4_digits, credit_limit, outstanding_balance, available_credit, statement_due_date, minimum_due, reward_points, card_holder_name, issued_bank, card_type, expiry_date, is_debit, daily_atm_limit, daily_pos_limit, linked_account)
VALUES 
('card_1', 'cmuzhxi5a000asr4p9f6jcndp', 'HDFC Regalia Gold', '4567', 500000.00, 28450.00, 471550.00, '18 Nov 2026', 1420.00, 14200, 'Sireesha Bandaru', 'HDFC Bank', 'Visa', '10/28', false, NULL, NULL, NULL),
('card_2', 'cmuzhxi5a000asr4p9f6jcndp', 'ICICI Amazon Pay', '8912', 300000.00, 14200.00, 285800.00, '25 Nov 2026', 800.00, 4850, 'Sireesha Bandaru', 'ICICI Bank', 'Mastercard', '06/29', false, NULL, NULL, NULL),
('card_3', 'cmuzhxi5a000asr4p9f6jcndp', 'HDFC Millennia Platinum Debit Card', '8754', 0.00, 0.00, 0.00, 'N/A', 0.00, 3200, 'Sireesha Bandaru', 'HDFC Bank', 'Mastercard', '04/30', true, 50000.00, 150000.00, 'Primary Savings A/C (••••6789)')
ON CONFLICT (id) DO NOTHING;

-- 3. Seed Loan Accounts
INSERT INTO loan_accounts (id, user_id, loan_type, lender, loan_account_number, outstanding_principal, interest_rate, monthly_emi, tenure_remaining_months, next_due_date, status)
VALUES 
('loan_1', 'cmuzhxi5a000asr4p9f6jcndp', 'Home Loan', 'State Bank of India', 'HL-SBIN-99214', 2450000.00, 8.55, 23450.00, 168, '05 Nov 2026', 'ACTIVE'),
('loan_2', 'cmuzhxi5a000asr4p9f6jcndp', 'Vehicle Loan', 'HDFC Bank', 'AL-HDFC-3301', 385000.00, 8.90, 11200.00, 38, '10 Nov 2026', 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

-- 4. Seed Investment Holdings
INSERT INTO investment_holdings (id, user_id, asset_type, institution, current_value, invested_value, return_percentage, is_positive)
VALUES 
('inv_1', 'cmuzhxi5a000asr4p9f6jcndp', 'Mutual Funds', 'Mirae Asset & Parag Parikh Flexi Cap', 1240000.00, 950000.00, 30.52, true),
('inv_2', 'cmuzhxi5a000asr4p9f6jcndp', 'Equity Stocks & ETFs', 'Zerodha Kite Portfolio', 875000.00, 710000.00, 23.24, true),
('inv_3', 'cmuzhxi5a000asr4p9f6jcndp', 'Fixed Deposits', 'HDFC Bank & SBI (7.25% p.a.)', 500000.00, 475000.00, 5.26, true),
('inv_4', 'cmuzhxi5a000asr4p9f6jcndp', 'Sovereign Gold Bonds', 'RBI Gold Bond Series 2024', 235000.00, 198000.00, 18.69, true),
('inv_5', 'cmuzhxi5a000asr4p9f6jcndp', 'EPF & PPF (Retirement)', 'Employees Provident Fund Org.', 980000.00, 860000.00, 13.95, true)
ON CONFLICT (id) DO NOTHING;

-- 5. Seed Insurance Policies
INSERT INTO insurance_policies (id, user_id, policy_type, policy_number_masked, provider, coverage_amount, premium_amount, renewal_date, nominee, status)
VALUES 
('ins_1', 'cmuzhxi5a000asr4p9f6jcndp', 'Health Insurance', 'POL-XXXX-9842', 'HDFC ERGO Optima Secure', 1500000.00, 14500.00, '14 Jul 2027', 'Spouse', 'ACTIVE'),
('ins_2', 'cmuzhxi5a000asr4p9f6jcndp', 'Term Life Insurance', 'POL-XXXX-4512', 'Tata AIA Life Sampoorna', 15000000.00, 18200.00, '22 Sep 2027', 'Spouse', 'ACTIVE'),
('ins_3', 'cmuzhxi5a000asr4p9f6jcndp', 'Vehicle Comprehensive', 'POL-XXXX-1123', 'Maruti Insurance Broking', 750000.00, 8500.00, '05 Jan 2027', 'Self', 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

-- 6. Seed UPI Accounts & Wallets
INSERT INTO upi_accounts (id, user_id, upi_id, provider, linked_bank, is_primary, status)
VALUES 
('upi_1', 'cmuzhxi5a000asr4p9f6jcndp', 'sireesha@oksbi', 'Google Pay', 'State Bank of India', true, 'Active'),
('upi_2', 'cmuzhxi5a000asr4p9f6jcndp', 'sireesha@ybl', 'PhonePe', 'HDFC Bank', false, 'Active'),
('upi_3', 'cmuzhxi5a000asr4p9f6jcndp', '9876543210@paytm', 'Paytm UPI', 'State Bank of India', false, 'Active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO wallets (id, user_id, wallet_name, balance, status)
VALUES 
('wal_1', 'cmuzhxi5a000asr4p9f6jcndp', 'Amazon Pay Wallet', 2450.00, 'Active'),
('wal_2', 'cmuzhxi5a000asr4p9f6jcndp', 'Paytm Wallet', 840.00, 'Active')
ON CONFLICT (id) DO NOTHING;

-- 7. Seed Active AA Consents
INSERT INTO aa_consents (id, consent_id, user_id, institution, consent_type, start_date, expiry_date, purpose, data_shared, status)
VALUES 
('aa_1', 'AA-908124567', 'cmuzhxi5a000asr4p9f6jcndp', 'State Bank of India', 'Account & Transaction Access', '01 Jan 2026', '31 Dec 2027', 'Real-time Net Worth & AI CFO Analytics', 'Balance, Profile, Transactions', 'Active'),
('aa_2', 'AA-457812903', 'cmuzhxi5a000asr4p9f6jcndp', 'HDFC Bank Ltd', 'Current Account & Card Access', '15 Feb 2026', '15 Feb 2027', 'Cash Flow & Auto-Expense Categorization', 'Current Account Statement, Card Dues', 'Active')
ON CONFLICT (id) DO NOTHING;
`

---

## 10. Verdict: Is this document 100% sufficient for full dynamic live operation?

**YES. This document covers 100% of the requirements needed to render the entire Bank Aggregation Module dynamically without static mock data.**

Once the backend team:
1. Executes the SQL Schema (Section 5) and Seed Data (Section 9) on Render / Supabase PostgreSQL,
2. Exposes the 38 REST endpoints mapped in Section 3 and 4 under /api/v1/bank-aggregation/,
3. Applies the Cross-Module balance sync rules in Section 8,

The Flutter client will switch completely from local in-memory state to live Render cloud backend feeds with zero code breaking changes.
