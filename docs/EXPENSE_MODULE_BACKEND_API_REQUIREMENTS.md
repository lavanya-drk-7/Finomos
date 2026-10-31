BACKEND API REQUIREMENTS
Expense Tracking, Priority Budgeting & Spending Analytics — Flutter Consumer App
Purpose: define the backend endpoints, data contracts, and business calculation rules needed to replace the static sample data in the Flutter Expense Tracking implementation (lib/features/expense_tracking/) with production API integration, rendering live data across every single field and view.

1. Current Implementation Status & Field Inventory
The Flutter Expense Tracking screen (lib/features/expense_tracking/presentation/expense_tracking_screen.dart) and domain layer (lib/features/expense_tracking/domain/expense_models.dart) feature two comprehensive tabs:
• Tab 0: Expenses & Subscriptions (Outflow Overview, AI Spending Coach, Active Filter Bar, Search, Real-Time Expense List, Transaction Details Sheet with Section 65B Tax Invoice generation).
• Tab 1: Expense Sources (Configured Expense Sources Master Card, committed outflows count, Add Expense Source CTA, and detailed CRUD cards with Edit, Delete, and Invoice actions).

Current sample values and fields to preserve during UI/API testing:
• Stream 1: Apartment Rent (Koramangala); category: Housing; amount: ₹22,000; date: 01 Aug 2025; paymentMode: UPI; priority: P1 - Survival; recurring: true; merchant: Owner Transfer; bank: HDFC Bank ••••4587; notes: Monthly residence lease; document: rent_agreement_koramangala.pdf.
• Stream 2: Car Loan EMI; category: Bills; amount: ₹9,500; date: 05 Aug 2025; paymentMode: Net Banking; priority: P3 - Obligations; recurring: true; merchant: HDFC Auto Finance; bank: HDFC Bank ••••4587; notes: Auto loan tenure month 14/36.
• Stream 3: Health Insurance Premium; category: Healthcare; amount: ₹3,200; date: 10 Aug 2025; paymentMode: Net Banking; priority: P2 - Protection; recurring: true; merchant: Star Health Care; bank: ICICI Bank ••••9021; notes: Annual policy monthly amortization.
• Stream 4: Electricity & High-speed Wifi; category: Utilities; amount: ₹2,350; date: 18 Aug 2025; paymentMode: UPI; priority: P1 - Survival; recurring: true; merchant: BESCOM & ACT Fibernet; bank: SBI ••••1123; notes: Utility mandates.
• Stream 5: Supermarket Groceries & Provisions; category: Food; amount: ₹8,400; date: 24 Aug 2025; paymentMode: UPI; priority: P1 - Survival; recurring: false; merchant: Nature Basket; bank: Axis Bank ••••3301; notes: Monthly household staples.
• Stream 6: OTT & Cloud Subscriptions (Netflix, Prime); category: Subscriptions; amount: ₹1,199; date: 15 Aug 2025; paymentMode: Credit Card; priority: P5 - Lifestyle; recurring: true; merchant: Netflix & Spotify; bank: HDFC Bank ••••4587; notes: Digital entertainment pack.
• Stream 7: Amazon Electronics & Apparel; category: Shopping; amount: ₹3,450; date: 14 Aug 2025; paymentMode: Credit Card; priority: P5 - Lifestyle; recurring: false; merchant: Amazon India; bank: ICICI Bank ••••9021; notes: Home decor & headphones.
• Stream 8: Weekend Dining & Socializing; category: Food; amount: ₹2,800; date: 22 Aug 2025; paymentMode: Credit Card; priority: P5 - Lifestyle; recurring: false; merchant: Toit Microbrewery; bank: Axis Bank ••••3301; notes: Team dinner & friends.

Sample Aggregated Metrics & Live Screen State:
• Total Monthly Outflow: ₹52,899.
• Monthly Inflow baseline (from Income Module): ₹1,32,500.
• Net Cash Flow: ₹79,601 (monthlyInflow - totalExpenses).
• Savings Rate: 60.08% (((monthlyInflow - totalExpenses) / monthlyInflow) * 100).
• Cash Runway: 5.67 months (calculated from liquid emergency reserve of ₹3,00,000 / totalExpenses).
• Monthly Recurring Commitments: ₹38,249 (rent, EMI, insurance, utilities, subscriptions).
• Discretionary Outflow: ₹14,650 (groceries, shopping, dining).
• Needs Ratio: 85.7% ((P1 + P2 + P3) / totalExpenses * 100).
• Wants Ratio: 14.3% (Lifestyle & Luxury P5/P6 / totalExpenses * 100).
• Expense Health Score: 88 / 100 (High financial health, low impulse risk).
• AI Personal CFO Insight: "Expense Health Score is 88/100. Discretionary spending (14.3%) is well within the 30% financial guardrail."
• Sample Invoice Number: INV-EXP-2026-EXP001.

---

2. Proposed API Inventory

Feature	Method	Proposed Endpoint	Purpose
Expense Summary	GET	/api/v1/expenses/summary	Real-time calculation of total monthly outflow, daily/monthly averages, recurring vs discretionary commitments, net cash flow, savings rate, runway months, needs vs wants ratio, expense health score, and AI CFO insight banner.
Expense Entries List	GET	/api/v1/expenses/entries	List expenses for authenticated user; supports search text and multi-criteria filtering by category, priority (P1-P6), bank account, payment mode, and date/month.
Expense Details	GET	/api/v1/expenses/entries/{expenseId}	Retrieve a single detailed expense entry, merchant metadata, and document links.
Record Expense	POST	/api/v1/expenses/entries	Create a new expense entry from the Record Outflow sheet; links to Budget Engine (BDG) and generates Section 65B invoice number.
Update Expense	PUT	/api/v1/expenses/entries/{expenseId}	Update an existing expense's amount, description, category, priority, payment mode, recurring status, merchant, notes, bank account, or attached receipt.
Delete Expense	DELETE	/api/v1/expenses/entries/{expenseId}	Permanently delete an expense record and update budget spent deductions.
Receipt Document Upload	POST	/api/v1/expenses/receipt-upload	Upload proof document (bill, invoice, receipt image/PDF) to encrypted cloud vault and return documentName and documentPath.
Official Invoice Details	GET	/api/v1/expenses/entries/{expenseId}/invoice	Fetch official tax invoice metadata and PDF reference (INV-EXP-YYYY-XXXXXX) for Section 65B Indian Evidence Act compliance.
Category Breakdown	GET	/api/v1/expenses/breakdown/category	Returns spend amounts and percentages grouped by the 10 standard categories for charts and analysis.
Priority Breakdown	GET	/api/v1/expenses/breakdown/priority	Returns spend amounts grouped by P1 Survival through P6 Luxury hierarchy.
Detected Outflows Sync	GET	/api/v1/expenses/detected	Fetch candidate debit transactions detected by SMS/Account Aggregator (FDCE engine) to display in the InAppTransactionAlertBanner.
Confirm Detected Outflow	POST	/api/v1/expenses/detected/{detectionId}/confirm	1-tap confirm and convert an auto-detected debit alert into a recorded expense entry.

---

3. Suggested Request & Response Contracts

3.1 Expense Summary & Health Metrics
Request:
GET /api/v1/expenses/summary?month=2025-08

Response (200 OK):
{
  "success": true,
  "data": {
    "totalMonthlyExpenses": 52899.0,
    "monthlyAverage": 52899.0,
    "dailyAverage": 1763.3,
    "monthlyInflow": 132500.0,
    "netCashFlow": 79601.0,
    "savingsRate": 60.08,
    "cashRunwayMonths": 5.67,
    "recurringExpenses": 38249.0,
    "discretionaryExpenses": 14650.0,
    "priorityBreakdown": {
      "P1_Survival": 32750.0,
      "P2_Protection": 3200.0,
      "P3_Obligations": 9500.0,
      "P4_Growth": 0.0,
      "P5_Lifestyle": 7449.0,
      "P6_Luxury": 0.0
    },
    "needsRatio": 85.73,
    "wantsRatio": 14.27,
    "expenseHealthScore": 88.0,
    "healthScoreRating": "Excellent Financial Health",
    "totalCount": 8,
    "aiCfoInsight": "AI Personal CFO: Expense Health Score is 88/100. Discretionary spending (14.3%) is well within the 30% financial guardrail."
  }
}

3.2 List & Filter Expense Entries
Request:
GET /api/v1/expenses/entries?search=&category=Food&priority=P1%20-%20Survival&bankAccount=Axis%20Bank%20••••3301&dateFilter=Aug%202025&page=1&limit=20

Response (200 OK):
{
  "success": true,
  "data": {
    "expenses": [
      {
        "id": "exp_5",
        "invoiceNumber": "INV-EXP-2026-EXP005",
        "description": "Supermarket Groceries & Provisions",
        "category": "Food",
        "amount": 8400.0,
        "date": "24 Aug 2025",
        "paymentMode": "UPI",
        "priority": "P1 - Survival",
        "isRecurring": false,
        "merchant": "Nature Basket",
        "notes": "Monthly household staples",
        "bankAccount": "Axis Bank ••••3301",
        "documentName": null,
        "documentPath": null,
        "isVerified": true,
        "createdAt": "2025-08-24T12:00:00Z"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "perPage": 20,
      "totalRecords": 1,
      "totalPages": 1
    }
  }
}

3.3 Record New Expense
Request:
POST /api/v1/expenses/entries
{
  "description": "Starbucks Coffee & Snacks",
  "category": "Food",
  "amount": 650.0,
  "date": "28 Oct 2026",
  "paymentMode": "UPI",
  "priority": "P5 - Lifestyle",
  "isRecurring": false,
  "merchant": "Starbucks India",
  "notes": "Afternoon coffee meeting",
  "bankAccount": "HDFC Bank ••••4587",
  "documentName": "starbucks_receipt_oct28.jpg",
  "documentPath": "https://vault.finomos.com/docs/users/u101/starbucks_receipt_oct28.jpg"
}

Response (201 Created):
{
  "success": true,
  "message": "Expense recorded successfully",
  "data": {
    "id": "exp_109",
    "invoiceNumber": "INV-EXP-2026-EXP109",
    "description": "Starbucks Coffee & Snacks",
    "category": "Food",
    "amount": 650.0,
    "date": "28 Oct 2026",
    "paymentMode": "UPI",
    "priority": "P5 - Lifestyle",
    "isRecurring": false,
    "merchant": "Starbucks India",
    "notes": "Afternoon coffee meeting",
    "bankAccount": "HDFC Bank ••••4587",
    "documentName": "starbucks_receipt_oct28.jpg",
    "documentPath": "https://vault.finomos.com/docs/users/u101/starbucks_receipt_oct28.jpg",
    "budgetImpact": {
      "budgetId": "b_food",
      "category": "Food",
      "allocatedAmount": 10000.0,
      "newSpentAmount": 9050.0,
      "remainingAmount": 950.0,
      "utilizationPercentage": 90.5
    },
    "createdAt": "2026-10-28T10:45:00Z"
  }
}

3.4 Update Expense Entry
Request:
PUT /api/v1/expenses/entries/exp_1
{
  "description": "Apartment Rent (Koramangala)",
  "category": "Housing",
  "amount": 23000.0,
  "date": "01 Aug 2025",
  "paymentMode": "UPI",
  "priority": "P1 - Survival",
  "isRecurring": true,
  "merchant": "Owner Transfer",
  "notes": "Monthly residence lease - amended with maintenance",
  "bankAccount": "HDFC Bank ••••4587",
  "documentName": "rent_agreement_koramangala.pdf",
  "documentPath": "https://vault.finomos.com/docs/users/u101/rent_agreement_koramangala.pdf"
}

Response (200 OK):
{
  "success": true,
  "message": "Expense updated successfully",
  "data": {
    "id": "exp_1",
    "invoiceNumber": "INV-EXP-2026-EXP001",
    "description": "Apartment Rent (Koramangala)",
    "category": "Housing",
    "amount": 23000.0,
    "date": "01 Aug 2025",
    "paymentMode": "UPI",
    "priority": "P1 - Survival",
    "isRecurring": true,
    "merchant": "Owner Transfer",
    "notes": "Monthly residence lease - amended with maintenance",
    "bankAccount": "HDFC Bank ••••4587",
    "documentName": "rent_agreement_koramangala.pdf",
    "documentPath": "https://vault.finomos.com/docs/users/u101/rent_agreement_koramangala.pdf",
    "updatedAt": "2026-10-28T10:50:00Z"
  }
}

3.5 Delete Expense Entry
Request:
DELETE /api/v1/expenses/entries/exp_8

Response (200 OK):
{
  "success": true,
  "message": "Expense deleted successfully",
  "data": {
    "id": "exp_8",
    "deletedAt": "2026-10-28T10:52:00Z"
  }
}

3.6 Proof Document / Receipt Upload
Request (multipart/form-data):
file: [Binary bill, invoice, or receipt image/PDF, max 10MB]
purpose: "expense_receipt"
entryId: "exp_1" (optional)

Response (200 OK):
{
  "success": true,
  "data": {
    "documentName": "restaurant_bill_oct26.jpg",
    "documentPath": "https://vault.finomos.com/docs/users/u101/restaurant_bill_oct26.jpg",
    "fileSizeBytes": 894520,
    "mimeType": "image/jpeg",
    "uploadedAt": "2026-10-28T10:54:00Z"
  }
}

3.7 Official Invoice Details & PDF Receipt
Request:
GET /api/v1/expenses/entries/exp_1/invoice

Response (200 OK):
{
  "success": true,
  "data": {
    "invoiceNumber": "INV-EXP-2026-EXP001",
    "id": "exp_1",
    "particularsTitle": "EXPENSE OUTFLOW DETAILS",
    "description": "Apartment Rent (Koramangala)",
    "category": "Housing",
    "amount": 22000.0,
    "amountInWords": "Twenty Two Thousand Rupees Only",
    "date": "01 Aug 2025",
    "paymentMode": "UPI",
    "priority": "P1 - Survival",
    "isRecurring": true,
    "frequencyLabel": "Recurring Automatic Outflow",
    "merchant": "Owner Transfer",
    "bankAccount": "HDFC Bank ••••4587",
    "notes": "Monthly residence lease",
    "attachedDocumentUrl": "https://vault.finomos.com/docs/users/u101/rent_agreement_koramangala.pdf",
    "invoicePdfUrl": "https://vault.finomos.com/invoices/INV-EXP-2026-EXP001.pdf",
    "complianceStandard": "RBI Account Aggregator & Section 65B Indian Evidence Act"
  }
}

3.8 In-App Transaction Alert Banner (Detected Debits Feed)
Request:
GET /api/v1/expenses/detected

Response (200 OK):
{
  "success": true,
  "data": [
    {
      "detectionId": "det_deb_501",
      "description": "Swiggy Bangalore Order #8921",
      "suggestedCategory": "Food",
      "suggestedPriority": "P5 - Lifestyle",
      "amount": 420.0,
      "date": "28 Oct 2026",
      "paymentMode": "UPI",
      "bankAccount": "HDFC Bank ••••4587",
      "merchant": "Swiggy",
      "isDebit": true,
      "confidenceScore": 0.96,
      "channel": "SMS_ALERT"
    }
  ]
}

3.9 Confirm Detected Debit
Request:
POST /api/v1/expenses/detected/det_deb_501/confirm
{
  "priority": "P5 - Lifestyle",
  "category": "Food"
}

Response (200 OK):
{
  "success": true,
  "message": "Transaction converted to recorded expense",
  "data": {
    "expenseId": "exp_110",
    "invoiceNumber": "INV-EXP-2026-EXP110",
    "status": "RECORDED"
  }
}

---

4. Business Rules & Server-Side Formulas

• Financial Priority Hierarchy (FPE Engine Module 9):
  - P1 - Survival: Essential life support (Housing rent, groceries, electricity, water, life-saving medicines).
  - P2 - Protection: Family & asset shielding (Health insurance, Term life cover, Emergency reserves).
  - P3 - Obligations: Legal commitments & debt service (Home/auto loan EMIs, credit card dues, statutory taxes).
  - P4 - Growth: Systematic capital creation (Mutual fund SIPs, PPF/NPS contributions).
  - P5 - Lifestyle: Discretionary comforts (Dining, apparel shopping, OTT entertainment packs, subscriptions).
  - P6 - Luxury: High-end indulgence (Luxury travel, fine dining, collectibles).

• Needs vs Wants Calculation:
  - Needs Ratio = ((P1_Total + P2_Total + P3_Total) / Total_Expenses) * 100, clamped to [0.0, 100.0].
  - Wants Ratio = (100.0 - Needs_Ratio), clamped to [0.0, 100.0].

• Savings Rate Calculation:
  - Savings Rate = (((Monthly_Inflow - Total_Expenses) / Monthly_Inflow) * 100), clamped to [-100.0, 100.0].

• Cash Runway (Emergency Safety Net):
  - Runway Months = (Liquid_Reserve_Buffer / Total_Expenses), clamped to [1.0, 24.0] (default liquid reserve buffer: ₹3,00,000).

• Expense Health Score (35 to 95 scale):
  - Baseline: 70.0.
  - Savings Rate Bonus: +15 if Savings Rate >= 30%; +8 if Savings Rate >= 15%; -10 if Savings Rate < 15%.
  - Needs Discipline Bonus: +10 if Needs Ratio <= 70%; -8 if Needs Ratio > 70%.
  - Final score is clamped to [35.0, 95.0].

• Deterministic Invoice Numbering:
  - Formatted as: INV-EXP-YYYY-XXXXXX where XXXXXX is derived from the alphanumeric entry ID.
  - Validated under Section 65B of Indian Evidence Act for tax and audit compliance.

• Allowed Enums:
  - Categories: Housing, Food, Utilities, Bills, Healthcare, Transportation, Subscriptions, Shopping, Entertainment, Other.
  - Priorities: P1 - Survival, P2 - Protection, P3 - Obligations, P4 - Growth, P5 - Lifestyle, P6 - Luxury.
  - Payment Modes: UPI, Credit Card, Debit Card, Net Banking, Auto Debit, Cash.
  - Bank Accounts: HDFC Bank ••••4587, ICICI Bank ••••9021, SBI ••••1123, Axis Bank ••••3301, Other / Cash.

---

5. Standardized Error Response Format

{
  "success": false,
  "error": {
    "code": "INVALID_AMOUNT",
    "message": "Please enter an amount greater than ₹0.",
    "details": {
      "field": "amount",
      "value": 0
    }
  }
}

Common error codes:
• UNAUTHORIZED: Missing or expired Bearer token.
• EXPENSE_NOT_FOUND: Provided expenseId does not exist for the authenticated user.
• INVALID_AMOUNT: Outflow amount must be positive.
• INVALID_CATEGORY: Category must be one of the 10 system categories.
• INVALID_PRIORITY: Priority must be one of P1 through P6.
• FILE_TOO_LARGE: Uploaded receipt exceeds 10MB limit.
• UNSUPPORTED_FILE_TYPE: Only PDF, JPG, and PNG are accepted.
• BUDGET_LIMIT_EXCEEDED: Outflow triggers critical budget breach (returned as warning or error based on user settings).

---

6. Implementation Priority Matrix

Priority	API Group	Reason
P0	Expense Summary & Entries List APIs	Required to replace in-memory mocks and render live data across Tab 0 (Expenses) and Tab 1 (Expense Sources).
P0	Expense CRUD APIs (Create, Update, Delete)	Required for the Record Outflow sheet, card editing, and deletions.
P1	Proof Document Upload API	Required for camera/file picker receipt attachment to cloud Document Vault.
P1	Section 65B Invoice API	Required for Download Invoice button and document preview modal dialogs.
P2	Detected Debits Sync & 1-Tap Confirm	Required for live interaction with InAppTransactionAlertBanner and Account Aggregator.
P2	Budget Impact Sync	Required for updating Budget Management (BDG) categories in real-time.
