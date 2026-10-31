BACKEND API REQUIREMENTS
Income Tracking & Stream Analytics — Flutter Consumer App
Purpose: define the backend endpoints and data contracts needed to replace the static sample data in the Flutter Income Tracking implementation (lib/features/income_tracking/) with production API integration.

1. Current implementation status
The supplied implementation plan describes a static UI prototype in lib/features/income_tracking/. It uses local sample income streams, pure-Dart ISO 32000 PDF receipt vouchers, domain calculation models, and local document vault handling. No existing backend endpoint names or API contracts were provided in the implementation plan. Therefore, every endpoint below is a proposed requirement for backend discussion, not a claim that the endpoint already exists.
Current sample values to preserve during UI/API testing:
•	Stream 1: Tech Corp India Pvt Ltd; category: Salary; amount: ₹85,000; frequency: Monthly; bank: HDFC Bank ••••4587; date: 25 Aug 2025; notes: Base Salary & PF credited; verified: true; document: salary_slip_aug_2025.pdf.
•	Stream 2: UI/UX Design Consulting; category: Freelance; amount: ₹22,000; frequency: Monthly; bank: ICICI Bank ••••9021; date: 18 Aug 2025; notes: Client Retainer Contract; verified: true.
•	Stream 3: Urban 2BHK Apartment; category: Rental; amount: ₹18,500; frequency: Monthly; bank: SBI ••••1123; date: 05 Aug 2025; notes: Rental Inflow Koramangala; verified: true.
•	Stream 4: Nifty 50 Index Dividends; category: Dividend; amount: ₹4,200; frequency: Monthly; bank: HDFC Bank ••••4587; date: 12 Aug 2025; notes: Quarterly Dividend Avg; verified: true.
•	Stream 5: Fixed Deposit Interest; category: Interest; amount: ₹2,800; frequency: Monthly; bank: Axis Bank ••••3301; date: 01 Aug 2025; notes: Auto sweep FD interest; verified: true.
•	Stream 6: Annual Performance Bonus; category: Bonus; amount: ₹65,000; frequency: One-time; bank: HDFC Bank ••••4587; date: 15 Jul 2025; notes: Q4 Appraisal Bonus; verified: true.
•	Sample aggregated metrics: Total monthly inflow: ₹1,32,500; active monthly: ₹1,07,000; passive monthly: ₹25,500; windfall total: ₹65,000; total annual inflow: ₹16,55,000; stability score: 85/100; top source dependency: 64.2%.
•	Sample voucher reference: FIN-INC-202508-00001; auto-tracking: enabled; default forecast horizon: 30D.

2. Proposed API inventory
Feature	Method	Proposed endpoint	Purpose
Income summary	GET	/api/v1/income/summary	Real-time calculation of monthly inflow, active vs passive breakdown, windfall totals, stability score, top dependency percent, and forecast projections.
Income entries list	GET	/api/v1/income/entries	List income entries for the authenticated user; supports search text and multi-criteria filtering by category, bank account, and date/month.
Add income stream	POST	/api/v1/income/entries	Create a new income stream record from the Add Income sheet; system automatically categorizes stream nature (Active, Passive, Windfall) based on category.
Update income stream	PUT	/api/v1/income/entries/{entryId}	Update an existing income stream's amount, source, category, frequency, bank account, date, notes, or attached proof document.
Delete income stream	DELETE	/api/v1/income/entries/{entryId}	Permanently delete an income stream record after confirmation in the UI.
Proof document upload	POST	/api/v1/income/proof-upload	Upload proof document (salary slip, agreement, invoice) to encrypted cloud storage and return documentName and documentPath.
Voucher details	GET	/api/v1/income/entries/{entryId}/voucher	Fetch official receipt voucher metadata and PDF download reference (FIN-INC-YYYYMM-XXXXX) for Section 65B compliance.
Auto-tracking setting	PATCH	/api/v1/income/settings/auto-tracking	Toggle automated SMS and Account Aggregator bank inflow detection.
Note: The proposed paths are examples for agreement. The backend team should map them to existing route conventions where possible and confirm final method, path, auth requirements, and response schema.

3. Suggested request/response contracts
3.1 Income summary
Request example:
GET /api/v1/income/summary?horizon=30D
Response example (illustrative):
{
  "success": true,
  "data": {
    "totalMonthlyIncome": 132500.0,
    "activeMonthlyIncome": 107000.0,
    "passiveMonthlyIncome": 25500.0,
    "windfallTotalIncome": 65000.0,
    "totalAnnualIncome": 1655000.0,
    "stabilityScore": 84.5,
    "stabilityRating": "High Stability",
    "passiveRatio": 19.25,
    "topDependencyPercent": 64.15,
    "topSource": "Tech Corp India Pvt Ltd",
    "totalStreamsCount": 6,
    "autoTrackingEnabled": true,
    "aiCfoInsight": "High Stability (Score 85/100). Passive cash flow generates ₹25,500/mo across rent and dividend holdings.",
    "forecast": {
      "selectedHorizon": "30D",
      "projectedAmount": 132500.0,
      "horizonBreakdown": {
        "30D": 132500.0,
        "90D": 397500.0,
        "1Y": 1655000.0,
        "5Y": 9639500.0
      }
    }
  }
}
Response should include server-calculated recurring totals, normalized monthly inflow, passive cash ratio, stability score, top source dependency, and projected forecast. Client total monthly inflow must match server aggregates.

3.2 Income entries list & filter
Request example:
GET /api/v1/income/entries?category=Salary&bankAccount=HDFC%20Bank%20••••4587&dateFilter=Aug%202025&page=1&limit=20
Response example (illustrative):
{
  "success": true,
  "data": {
    "entries": [
      {
        "id": "inc_1",
        "voucherNumber": "FIN-INC-202508-00001",
        "source": "Tech Corp India Pvt Ltd",
        "category": "Salary",
        "type": "Active",
        "amount": 85000.0,
        "date": "25 Aug 2025",
        "frequency": "Monthly",
        "bankAccount": "HDFC Bank ••••4587",
        "notes": "Base Salary & PF credited",
        "isVerified": true,
        "verificationType": "Digitally Verified Inflow",
        "documentName": "salary_slip_aug_2025.pdf",
        "documentPath": "https://vault.finomos.com/docs/users/u101/salary_slip_aug_2025.pdf",
        "createdAt": "2025-08-25T10:00:00Z"
      },
      {
        "id": "inc_4",
        "voucherNumber": "FIN-INC-202508-00004",
        "source": "Nifty 50 Index Dividends",
        "category": "Dividend",
        "type": "Passive",
        "amount": 4200.0,
        "date": "12 Aug 2025",
        "frequency": "Monthly",
        "bankAccount": "HDFC Bank ••••4587",
        "notes": "Quarterly Dividend Avg",
        "isVerified": true,
        "verificationType": "Digitally Verified Inflow",
        "documentName": null,
        "documentPath": null,
        "createdAt": "2025-08-12T14:30:00Z"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "perPage": 20,
      "totalRecords": 2,
      "totalPages": 1
    }
  }
}
Supports filtering by category (Salary, Freelance, Rental, etc.), bank account (HDFC, ICICI, etc.), and credit date/month. When filters are cleared, return all user entries.

3.3 Add new income stream
Request example:
{
  "amount": 35000.0,
  "source": "Starlight Consulting LLP",
  "category": "Freelance",
  "frequency": "Monthly",
  "bankAccount": "HDFC Bank ••••4587",
  "date": "27 Oct 2026",
  "documentName": "invoice_starlight_oct26.pdf",
  "documentPath": "https://vault.finomos.com/docs/users/u101/invoice_starlight_oct26.pdf",
  "notes": "Mobile app consulting retainer"
}
Response example (illustrative):
{
  "success": true,
  "message": "Income stream added successfully",
  "data": {
    "id": "inc_107",
    "voucherNumber": "FIN-INC-202610-00107",
    "amount": 35000.0,
    "source": "Starlight Consulting LLP",
    "category": "Freelance",
    "type": "Active",
    "frequency": "Monthly",
    "bankAccount": "HDFC Bank ••••4587",
    "date": "27 Oct 2026",
    "documentName": "invoice_starlight_oct26.pdf",
    "documentPath": "https://vault.finomos.com/docs/users/u101/invoice_starlight_oct26.pdf",
    "notes": "Mobile app consulting retainer",
    "isVerified": false,
    "createdAt": "2026-10-27T10:45:00Z"
  }
}
The client does not provide a stream type field. The backend automatically classifies stream nature: Rental/Dividend/Interest as Passive, Bonus as Windfall, and others as Active.

3.4 Update income stream
Request example:
{
  "amount": 25000.0,
  "source": "UI/UX Design Consulting",
  "category": "Freelance",
  "frequency": "Monthly",
  "bankAccount": "ICICI Bank ••••9021",
  "date": "18 Aug 2025",
  "documentName": "retainer_amendment.pdf",
  "documentPath": "https://vault.finomos.com/docs/users/u101/retainer_amendment.pdf",
  "notes": "Revised retainer for 2025-26"
}
Response example (illustrative):
{
  "success": true,
  "message": "Income stream updated successfully",
  "data": {
    "id": "inc_2",
    "voucherNumber": "FIN-INC-202508-00002",
    "amount": 25000.0,
    "source": "UI/UX Design Consulting",
    "category": "Freelance",
    "type": "Active",
    "frequency": "Monthly",
    "bankAccount": "ICICI Bank ••••9021",
    "date": "18 Aug 2025",
    "documentName": "retainer_amendment.pdf",
    "documentPath": "https://vault.finomos.com/docs/users/u101/retainer_amendment.pdf",
    "notes": "Revised retainer for 2025-26",
    "isVerified": true,
    "updatedAt": "2026-10-27T10:48:00Z"
  }
}

3.5 Delete income stream
Request example:
DELETE /api/v1/income/entries/inc_6
Response example (illustrative):
{
  "success": true,
  "message": "Income stream deleted successfully",
  "data": {
    "id": "inc_6",
    "deletedAt": "2026-10-27T10:50:00Z"
  }
}

3.6 Proof document upload
Request example (multipart/form-data):
file: [Binary salary slip, invoice, contract PDF/JPG/PNG, max 10MB]
purpose: "income_proof"
Response example (illustrative):
{
  "success": true,
  "data": {
    "documentName": "salary_slip_sep_2026.pdf",
    "documentPath": "https://vault.finomos.com/docs/users/u101/salary_slip_sep_2026.pdf",
    "fileSizeBytes": 1428570,
    "mimeType": "application/pdf",
    "uploadedAt": "2026-10-27T10:52:00Z"
  }
}

3.7 Voucher details & receipt
Request example:
GET /api/v1/income/entries/inc_1/voucher
Response example (illustrative):
{
  "success": true,
  "data": {
    "voucherNumber": "FIN-INC-202508-00001",
    "id": "inc_1",
    "source": "Tech Corp India Pvt Ltd",
    "category": "Salary",
    "type": "Active",
    "amount": 85000.0,
    "amountInWords": "Eighty Five Thousand Rupees Only",
    "date": "25 Aug 2025",
    "frequency": "Monthly",
    "bankAccount": "HDFC Bank ••••4587",
    "isVerified": true,
    "verificationType": "Digitally Verified Inflow",
    "complianceStandard": "RBI Account Aggregator & Section 65B Indian Evidence Act",
    "attachedDocumentUrl": "https://vault.finomos.com/docs/users/u101/salary_slip_aug_2025.pdf",
    "voucherPdfUrl": "https://vault.finomos.com/vouchers/FIN-INC-202508-00001.pdf"
  }
}

3.8 Auto-tracking setting
Request example:
{
  "enabled": false
}
Response example (illustrative):
{
  "success": true,
  "data": {
    "autoTrackingEnabled": false,
    "updatedAt": "2026-10-27T10:55:00Z"
  }
}

4. Business rules to confirm with backend
•	Automatic stream classification: client form does not contain a type selector; backend derives type automatically: Rental, Dividend, Interest as Passive; Bonus as Windfall; Salary, Business, Freelance, Other as Active.
•	Monthly normalization: backend must normalize frequencies identically to the client engine: Monthly = amount; Bi-weekly = amount * 2; Quarterly = amount / 3; Yearly = amount / 12; One-time / Windfall = 0.0 monthly equivalent.
•	Annual inflow formula: Total Annual Inflow = (Total Monthly Normalized * 12) + Total Windfall Inflow.
•	Stability score: calculated on a 40 to 96 scale based on recurring ratio (55%), source count weight (35%), and passive income bonus (10%).
•	Top source dependency: calculated as (Largest Single Monthly Source / Total Monthly Inflow) * 100, clamped to [0.0, 100.0].
•	Forecast horizons: 30D = 1x monthly; 90D = 3x monthly; 1Y = annual inflow; 5Y = (total monthly * 12 * 5.86) + (windfall * 5) to account for compounding growth on recurring streams.
•	Allowed categories: Salary, Business, Freelance, Rental, Dividend, Interest, Bonus, Other.
•	Allowed frequencies: Monthly, One-time, Quarterly, Yearly, Bi-weekly.
•	Allowed deposit accounts: HDFC Bank ••••4587, ICICI Bank ••••9021, SBI ••••1123, Axis Bank ••••3301, Other / Cash.
•	Deterministic voucher numbering: every recorded income entry must have a unique sequential receipt voucher formatted as FIN-INC-YYYYMM-XXXXX.
•	Verification status: auto-tracked or bank-verified records must have isVerified set to true; self-reported entries set to false.

5. Error response format
Please standardize errors so Flutter can display reliable messages:
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
Suggested cases include UNAUTHORIZED, INCOME_NOT_FOUND, INVALID_AMOUNT, INVALID_CATEGORY, INVALID_FREQUENCY, FILE_TOO_LARGE, UNSUPPORTED_FILE_TYPE, ACCOUNT_NOT_LINKED, and DATABASE_ERROR.

6. Authentication, environment and API documentation
•	Confirm the existing authentication mechanism and required access token/headers for every endpoint (Authorization: Bearer <JWT_ACCESS_TOKEN>).
•	Provide development/staging base URL and production base URL separately.
•	Share Postman collection or OpenAPI/Swagger documentation.
•	Provide sample success and failure responses for each endpoint.
•	Document pagination, filtering, sorting, date/time format, currency format, and enum values.
•	Confirm whether document vault URLs are public, signed, or require authorization headers.
•	Specify rate limits, timeout expectations, retry behavior and logging/correlation IDs.
•	Do not share production secrets or bank credentials in the mobile app.

7. Suggested implementation priority
Priority	API group	Reason
P0	Income summary and entries list APIs	Needed immediately to replace in-memory mock lists and render live data across Tab 0 (Streams) and Tab 1 (Sources).
P0	Income CRUD APIs	Needed to persist new income streams, edit details from source cards, and execute deletions.
P1	Proof document upload API	Required for salary slips, invoices, and rental agreements selected via camera/file picker.
P1	Voucher details and receipt API	Required for transaction details sheet and Section 65B compliant PDF receipt downloading.
P2	Auto-tracking setting API	Required for persisting user toggle for SMS and Account Aggregator bank inflow synchronization.
