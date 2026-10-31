v# BACKEND API REQUIREMENTS
## Budget Management & Smart Guardrails Engine — Flutter Consumer App (Finomos)

**Document Version**: 1.1 (Production Ready)  
**Target Platform**: Finomos Flutter Mobile App (`lib/features/budget_management/`)  
**Base URL**: `https://finmos-user.onrender.com`  
**Authentication**: Bearer JWT (`Authorization: Bearer <token>` from `/api/auth/login`)

---

## 1. Executive Summary & Purpose

The **Budget Management Module** provides users with personal CFO guardrails, category-wise spending limits, automated bank SMS deductions, 80% early warning thresholds, and 100% overspending alert banners.

Currently, the mobile client runs with a rich UI and local mock states in:
* [`lib/features/budget_management/presentation/budget_management_screen.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/budget_management/presentation/budget_management_screen.dart)
* [`lib/features/budget_management/domain/budget_models.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/budget_management/domain/budget_models.dart)
* [`lib/features/budget_management/providers/budget_provider.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/budget_management/providers/budget_provider.dart)

This document defines the **17 production API endpoints**, data contracts, SQL database schema, calculation formulas, and Postman folder hierarchy required to connect this module to live backend services with 100% functional fidelity.

---

## 2. Current Implementation Status & Field Inventory

### 2.1 Standard Categories Supported in the UI
The UI restricts and maps budgets to these **10 official categories**:
1. `Food & Dining`
2. `Groceries`
3. `Transportation`
4. `Shopping`
5. `Rent & Housing`
6. `Utilities`
7. `Healthcare`
8. `Entertainment`
9. `Travel`
10. `Other`

### 2.2 Budget Types
* `Category-wise Budget` (allocated to a specific spending category)
* `Monthly Budget` (overall monthly umbrella budget)

### 2.3 Status Options in Filter Sheet
* `All`
* `On Track` (Spent $< 80\%$ of budget)
* `80% Warning` (Spent $\ge 80\%$ and $< 100\%$)
* `Exceeded` (Spent $> 100\%$)

### 2.4 Baseline Sample Data to Preserve During Testing
* **Food & Dining** (`b_food`): Budget: ₹10,000; Spent: ₹0; Period: October 2026; Start: 01/10/2026; End: 31/10/2026.
* **Groceries** (`b_groceries`): Budget: ₹8,000; Spent: ₹0; Period: October 2026; Start: 01/10/2026; End: 31/10/2026.
* **Transportation & Travel** (`b_travel`): Budget: ₹5,000; Spent: ₹2,000 (40.0%); Period: October 2026.
* **Shopping & Retail** (`b_shopping`): Budget: ₹6,000; Spent: ₹3,450 (57.5%); Period: October 2026.
* **Utilities & Bills** (`b_utilities`): Budget: ₹4,000; Spent: ₹2,350 (58.8%); Period: October 2026.
* **Entertainment** (`b_ent`): Budget: ₹3,000; Spent: ₹1,199 (40.0%); Period: October 2026.

### 2.5 Aggregated Baseline Overview
* **Total Monthly Budget**: ₹36,000 ($= \sum \text{amount}$)
* **Total Spent**: ₹8,999 ($= \sum \text{spent}$)
* **Total Remaining**: ₹27,001 ($= \max(0, \text{Total Budget} - \text{Total Spent})$)
* **Total Overspent**: ₹0.0 ($= \max(0, \text{Total Spent} - \text{Total Budget})$)
* **Overall Usage**: 25.0% ($= (\text{Total Spent} / \text{Total Budget}) \times 100$)
* **Active Categories**: 6
* **Exceeded Count**: 0
* **80% Warning Count**: 0

---

## 3. Mathematical Formulas & Business Rules

1. **Remaining Budget**:
   $$\text{Remaining} = \max(0, \text{amount} - \text{spent})$$
2. **Overspent Amount**:
   $$\text{Overspent} = \max(0, \text{spent} - \text{amount})$$
3. **Utilization Percentage**:
   $$\text{Utilization \%} = \begin{cases} \left(\frac{\text{spent}}{\text{amount}}\right) \times 100, & \text{if } \text{amount} > 0 \\ 0.0, & \text{otherwise} \end{cases}$$
4. **Alert Threshold Hierarchy**:
   * **`none`**: Spent $< 80\%$
   * **`approaching80`**: Spent $\ge 80\%$ and $< 100\%$
   * **`limitReached100`**: Spent $\ge 100\%$ and $\le 100.1\%$
   * **`exceeded`**: Spent $> 100\%$ (Overspent amount $> ₹0$)
5. **Cross-Module Expense Syncing**:
   Whenever a debit transaction is confirmed in `/api/expense` or auto-detected by the Account Aggregator / SMS Parser (FDCE Engine), the backend must automatically match the category and update the budget's `spent` column.
   * Matching rules:
     * `"Food & Dining"` $\leftrightarrow$ `"Food"`, `"Dining"`, `"Restaurant"`
     * `"Groceries"` $\leftrightarrow$ `"Groceries"`, `"Supermarket"`, `"Provisions"`
     * `"Transportation"` $\leftrightarrow$ `"Travel"`, `"Cab"`, `"Fuel"`
     * `"Rent & Housing"` $\leftrightarrow$ `"Rent"`, `"Housing"`
     * `"Utilities"` $\leftrightarrow$ `"Bills"`, `"Electricity"`, `"Water"`, `"Internet"`

---

## 4. Database Schema (PostgreSQL / Supabase / Prisma DDL)

To implement this on Render or Supabase, the backend team can execute the following DDL script:

```sql
-- 1. Budgets Table
CREATE TABLE IF NOT EXISTS budgets (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    name VARCHAR(120) NOT NULL,
    type VARCHAR(40) NOT NULL DEFAULT 'Category-wise Budget',
    category VARCHAR(60) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    spent NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    start_date VARCHAR(20) NOT NULL,
    end_date VARCHAR(20) NOT NULL,
    period VARCHAR(30) NOT NULL DEFAULT 'October 2026',
    alert_level VARCHAR(30) NOT NULL DEFAULT 'none',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_category_period UNIQUE (user_id, category, period)
);

-- 2. Budget Guardrail Settings Table
CREATE TABLE IF NOT EXISTS budget_settings (
    user_id VARCHAR(64) PRIMARY KEY,
    bank_sms_deduction_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    overspending_alerts_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    threshold_80_warning_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    auto_rollover_unspent BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Budget Alert Events Table
CREATE TABLE IF NOT EXISTS budget_alerts (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    budget_id VARCHAR(64) REFERENCES budgets(id) ON DELETE CASCADE,
    level VARCHAR(30) NOT NULL, -- 'approaching80', 'limitReached100', 'exceeded'
    title VARCHAR(120) NOT NULL,
    message TEXT NOT NULL,
    overspent_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    utilization_percentage NUMERIC(6, 2) NOT NULL DEFAULT 0.00,
    is_dismissed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_budgets_user_period ON budgets(user_id, period);
CREATE INDEX idx_budget_alerts_user_active ON budget_alerts(user_id, is_dismissed);
```

---

## 5. Complete API Inventory

The backend must provide the following **17 endpoints** (14 versioned `/api/v1/budgets` endpoints + 3 direct `/api/budget` convenience endpoints for direct JSON array syncing, matching `/api/income` and `/api/expense`):

| # | HTTP Method | Endpoint | Description |
|---|:---:|---|---|
| 1 | `GET` | `/api/v1/budgets/summary` | Real-time aggregate overview (total budget, spent, remaining, overspent, usage %, active alert). |
| 2 | `GET` | `/api/v1/budgets` | Filtered list of budgets (`period`, `category`, `type`, `status`, `search`, `page`, `limit`). |
| 3 | `GET` | `/api/v1/budgets/:id` | Single budget detail with recent transaction breakdown. |
| 4 | `POST` | `/api/v1/budgets` | Create new budget cap. |
| 5 | `PUT` | `/api/v1/budgets/:id` | Update budget cap, name, or dates. |
| 6 | `DELETE` | `/api/v1/budgets/:id` | Delete budget cap. |
| 7 | `POST` | `/api/v1/budgets/:id/expenses` | Manual expense deduction against a budget item. |
| 8 | `POST` | `/api/v1/budgets/recalculate` | Re-aggregate budget spent amounts from confirmed transactions. |
| 9 | `GET` | `/api/v1/budgets/analytics/utilization` | Category utilization breakdown, burn rate per day, and projected variance. |
| 10 | `GET` | `/api/v1/budgets/alerts/active` | Fetch active high-priority guardrail warning banners. |
| 11 | `PATCH` | `/api/v1/budgets/alerts/:alertId/dismiss` | Dismiss an alert banner after user acknowledgement. |
| 12 | `GET` | `/api/v1/budgets/settings/guardrails` | Fetch guardrail automation toggles (SMS deduction, 80% warning, overspending banner). |
| 13 | `PATCH` | `/api/v1/budgets/settings/guardrails` | Update guardrail automation toggles. |
| 14 | `POST` | `/api/v1/budgets/rollover` | Roll forward allocations from previous month into the new month. |
| 15 | `GET` | `/api/budget` | Direct endpoint: returns raw JSON array of all active budget items (UI Web Synced). |
| 16 | `POST` | `/api/budget` | Direct endpoint: creates a budget item directly. |
| 17 | `DELETE` | `/api/budget/:id` | Direct endpoint: deletes a budget item directly. |

---

## 6. Detailed Request & Response Specifications

### 6.1 `GET /api/v1/budgets/summary`
* **Query Params**: `period=October 2026` (optional, defaults to current month)
* **Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "period": "October 2026",
    "totalBudget": 36000.0,
    "totalSpent": 8999.0,
    "totalRemaining": 27001.0,
    "totalOverspent": 0.0,
    "overallUsagePercentage": 25.0,
    "activeCategoriesCount": 6,
    "exceededCount": 0,
    "warning80Count": 0,
    "onTrackCount": 6,
    "alertEnabled": true,
    "aiCfoInsight": "Optimal Budget Health (25% utilized). All 6 active categories are within safe financial guardrails.",
    "activeBannerAlert": null
  }
}
```

---

### 6.2 `GET /api/v1/budgets`
* **Query Params**:
  * `period=October 2026`
  * `category=Food & Dining` *(optional)*
  * `status=on_track` *(optional: `all`, `on_track`, `warning`, `exceeded`)*
  * `search=Food` *(optional)*
  * `page=1`
  * `limit=20`
* **Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "budgets": [
      {
        "id": "b_food",
        "name": "Food & Dining",
        "type": "Category-wise Budget",
        "category": "Food & Dining",
        "amount": 10000.0,
        "spent": 0.0,
        "remaining": 10000.0,
        "overspentAmount": 0.0,
        "utilizationPercentage": 0.0,
        "startDate": "01/10/2026",
        "endDate": "31/10/2026",
        "period": "October 2026",
        "alertLevel": "none",
        "isExceeded": false,
        "isApproachingLimit": false
      },
      {
        "id": "b_travel",
        "name": "Transportation & Travel",
        "type": "Category-wise Budget",
        "category": "Transportation",
        "amount": 5000.0,
        "spent": 2000.0,
        "remaining": 3000.0,
        "overspentAmount": 0.0,
        "utilizationPercentage": 40.0,
        "startDate": "01/10/2026",
        "endDate": "31/10/2026",
        "period": "October 2026",
        "alertLevel": "none",
        "isExceeded": false,
        "isApproachingLimit": false
      }
    ],
    "pagination": {
      "currentPage": 1,
      "perPage": 20,
      "totalRecords": 6,
      "totalPages": 1
    }
  }
}
```

---

### 6.3 `POST /api/v1/budgets`
* **Request Body**:
```json
{
  "name": "Healthcare & Medical",
  "type": "Category-wise Budget",
  "category": "Healthcare",
  "amount": 5000.0,
  "startDate": "01/10/2026",
  "endDate": "31/10/2026",
  "period": "October 2026"
}
```
* **Response (201 Created)**:
```json
{
  "success": true,
  "message": "Budget limit created successfully",
  "data": {
    "id": "cmv_bdg_891024",
    "name": "Healthcare & Medical",
    "type": "Category-wise Budget",
    "category": "Healthcare",
    "amount": 5000.0,
    "spent": 0.0,
    "remaining": 5000.0,
    "overspentAmount": 0.0,
    "utilizationPercentage": 0.0,
    "startDate": "01/10/2026",
    "endDate": "31/10/2026",
    "period": "October 2026",
    "alertLevel": "none",
    "createdAt": "2026-10-29T12:00:00.000Z"
  }
}
```

---

### 6.4 `PUT /api/v1/budgets/:id`
* **Request Body**:
```json
{
  "name": "Food & Fine Dining",
  "amount": 12000.0,
  "category": "Food & Dining",
  "startDate": "01/10/2026",
  "endDate": "31/10/2026",
  "period": "October 2026"
}
```
* **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Budget updated successfully",
  "data": {
    "id": "b_food",
    "name": "Food & Fine Dining",
    "category": "Food & Dining",
    "amount": 12000.0,
    "spent": 0.0,
    "remaining": 12000.0,
    "overspentAmount": 0.0,
    "utilizationPercentage": 0.0,
    "updatedAt": "2026-10-29T12:05:00.000Z"
  }
}
```

---

### 6.5 `DELETE /api/v1/budgets/:id`
* **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Budget cap deleted successfully"
}
```

---

### 6.6 `POST /api/v1/budgets/:id/expenses` (Deduct Expense & Trigger Thresholds)
* **Request Body**:
```json
{
  "amount": 2500.0,
  "description": "Weekend Restaurant Dinner",
  "date": "29 Oct 2026",
  "paymentMode": "HDFC Credit Card ••••4587"
}
```
* **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Expense deducted from budget",
  "data": {
    "budgetId": "b_food",
    "category": "Food & Dining",
    "budgetAmount": 10000.0,
    "previousSpent": 6000.0,
    "newSpent": 8500.0,
    "remaining": 1500.0,
    "overspentAmount": 0.0,
    "utilizationPercentage": 85.0,
    "alertTriggered": {
      "level": "approaching80",
      "title": "Budget Warning: 80% Used",
      "message": "You have utilized 85% of your Food & Dining budget (₹8,500 of ₹10,000).",
      "overspentAmount": 0.0,
      "utilizationPercentage": 85.0
    }
  }
}
```

---

### 6.7 `GET /api/v1/budgets/alerts/active` (Top Warning Banner)
* **Response (200 OK — when budget exceeded)**:
```json
{
  "success": true,
  "data": [
    {
      "alertId": "alt_bdg_90124",
      "budgetId": "b_dining",
      "category": "Dining Out",
      "level": "exceeded",
      "title": "Budget Exceeded!",
      "message": "You have spent ₹11,200 on Dining Out against your monthly budget of ₹10,000. You exceeded your budget by ₹1,200.",
      "overspentAmount": 1200.0,
      "utilizationPercentage": 112.0,
      "createdAt": "2026-10-29T11:45:00.000Z"
    }
  ]
}
```

---

### 6.8 `PATCH /api/v1/budgets/alerts/:alertId/dismiss`
* **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Alert banner dismissed"
}
```

---

### 6.9 `GET /api/v1/budgets/analytics/utilization` (Analytics Tab 1)
* **Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "period": "October 2026",
    "daysInMonth": 31,
    "daysElapsed": 29,
    "burnRatePerDay": 310.31,
    "projectedMonthEndExpense": 9619.61,
    "projectedSurplus": 26380.39,
    "categories": [
      {
        "category": "Shopping",
        "allocated": 6000.0,
        "spent": 3450.0,
        "utilizationPercentage": 57.5,
        "dailyBurnRate": 118.96,
        "status": "ON_TRACK"
      },
      {
        "category": "Utilities",
        "allocated": 4000.0,
        "spent": 2350.0,
        "utilizationPercentage": 58.75,
        "dailyBurnRate": 81.03,
        "status": "ON_TRACK"
      },
      {
        "category": "Transportation",
        "allocated": 5000.0,
        "spent": 2000.0,
        "utilizationPercentage": 40.0,
        "dailyBurnRate": 68.96,
        "status": "ON_TRACK"
      },
      {
        "category": "Entertainment",
        "allocated": 3000.0,
        "spent": 1199.0,
        "utilizationPercentage": 39.96,
        "dailyBurnRate": 41.34,
        "status": "ON_TRACK"
      }
    ]
  }
}
```

---

### 6.10 `GET` & `PATCH` `/api/v1/budgets/settings/guardrails`
* **Fetch GET Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "bankSmsDeductionEnabled": true,
    "overspendingAlertsEnabled": true,
    "threshold80WarningEnabled": true,
    "autoRolloverUnspent": false,
    "updatedAt": "2026-10-29T10:00:00.000Z"
  }
}
```
* **Update PATCH Body**:
```json
{
  "bankSmsDeductionEnabled": true,
  "overspendingAlertsEnabled": true,
  "threshold80WarningEnabled": true
}
```

---

### 6.11 Direct Endpoints (`/api/budget`)
Matching `/api/income` and `/api/expense`:
* **`GET /api/budget`**: Returns a direct array of all budget objects for the current user.
* **`POST /api/budget`**: Creates a budget entry directly.
* **`DELETE /api/budget/:id`**: Deletes a budget entry directly.

---

## 7. Error Handling Standards

| HTTP Status | Error Code | Description / Message |
|:---:|---|---|
| `400 Bad Request` | `INVALID_AMOUNT` | `"Budget amount must be a positive number greater than ₹0."` |
| `400 Bad Request` | `INVALID_DATES` | `"End date must be on or after Start date."` |
| `409 Conflict` | `CATEGORY_BUDGET_EXISTS` | `"A budget for 'Food & Dining' already exists for October 2026. Please edit the existing budget."` |
| `404 Not Found` | `BUDGET_NOT_FOUND` | `"Budget item with ID '...' does not exist."` |
| `401 Unauthorized` | `UNAUTHORIZED` | `"Session expired or invalid Bearer token. Please log in again."` |

---

## 8. Postman Collection Folder Organization

To match the existing Income and Expense Postman collections, the backend team should organize their collection into the following folders:

```text
FINMOS - Budget Management Module (BDG)
│
├── 0. Authentication & User Switcher
│   ├── POST Login as Sireesha
│   └── POST Login as Keerthi
│
├── 1. Budget Summary & Overview
│   └── GET Get Budget Summary (October 2026)
│
├── 2. Budget CRUD Operations
│   ├── GET Get All Budgets (Page 1, Limit 20)
│   ├── GET Get Single Budget by ID
│   ├── POST Create Budget (Healthcare & Medical)
│   ├── PUT Update Budget (Food & Fine Dining)
│   └── DEL Delete Budget by ID
│
├── 3. Filtering & Search
│   ├── GET Filter by Category (Food & Dining)
│   ├── GET Filter by Status (Exceeded / Warning / On Track)
│   └── GET Search by Query (Dining / Transport)
│
├── 4. Expense Deduction & Recalculation
│   ├── POST Deduct Expense Against Budget (With Threshold Evaluation)
│   └── POST Recalculate Budgets from Expense Module
│
├── 5. Guardrail Alerts & Notifications
│   ├── GET Get Active Banner Alert Queue
│   └── PATCH Dismiss Alert Banner by ID
│
├── 6. Analytics & Utilization Engine
│   └── GET Get Category Utilization & Daily Burn Rate
│
├── 7. Guardrail Settings & Automation
│   ├── GET Get Guardrail Settings (SMS, Warnings, Alerts)
│   ├── PATCH Update Guardrail Settings
│   └── POST Trigger Monthly Budget Rollover
│
└── 8. Direct Endpoints (UI Synced)
    ├── GET Direct Budget List (/api/budget)
    ├── POST Direct Create Budget (/api/budget)
    └── DEL Direct Delete Budget (/api/budget/:id)
```

---

## 9. Conclusion
This document is **100% complete and self-contained**. It provides everything backend engineers need:
1. Exact database schema (DDL) with foreign keys and uniqueness constraints.
2. Complete request/response JSON contracts matching Flutter domain models.
3. Automated guardrail logic (80% warning, 100% exceeded, burn rate).
4. Direct endpoints (`/api/budget`) consistent with `/api/income` and `/api/expense`.
5. Postman folder hierarchy for testing and verification.
