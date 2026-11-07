# BACKEND API REQUIREMENTS SPECIFICATION
## Module: Notifications & Financial SMS Transaction Detection System
**Target Service Base URL:** `https://finmos-user.onrender.com/api/v1`  
**Document Version:** 1.0.0  
**Status:** Ready for Backend Implementation  
**Client:** Finomos Flutter Mobile App  

---

## 1. Executive Summary & Purpose
This document specifies the exact backend REST API requirements, database schemas, message parsing specifications, and interaction contracts required to support the newly implemented **Notifications & Financial SMS Detection Engine** in the Finomos consumer mobile application.

The mobile frontend (`lib/features/notifications/`, `lib/features/income_tracking/`, `lib/features/expense_tracking/`, and `lib/features/transaction_detection/`) features:
1. **Financial SMS Ingestion & Categorization**: Real-time identification of transactional SMS messages into distinct financial types (`CREDIT`, `DEBIT`, `FIXED_DEPOSIT`, `PROMOTION`, `SYSTEM`).
2. **Direct Card Actions**: Immediate **Save** (bookmark to notification vault) and **Delete** buttons directly beneath every SMS notification card.
3. **Automated Redirection to Financial Ledgers**:
   - Tapping a **Credit (Inflow) SMS** navigates the user to **Income Tracking** and presents a high-visibility **"Detected Bank Inflow" Short Box**.
   - Tapping a **Debit (Outflow) SMS** navigates the user to **Expense Tracking** and presents a high-visibility **"Detected Bank Outflow" Short Box**.
   - Tapping a **Fixed Deposit SMS** displays a wealth summary modal and links directly into **Bank Aggregation & Wealth Management**.
4. **Interactive Ledger Reconciliation**: Both Short Boxes provide two immediate actions:
   - **Approve**: Immediately converts the detected transaction into a permanent ledger entry (inflow or expense), recalculates running balances/budget allocations, and archives the notification.
   - **Delete / Dismiss**: Rejects the detected transaction, clearing the short box without altering financial balances.

---

## 2. API Endpoints Inventory

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/v1/notifications` | Retrieve paginated list of notifications with filtering support | Yes (Bearer JWT) |
| **GET** | `/api/v1/notifications/unread-count` | Retrieve real-time count of unread notifications for badge display | Yes (Bearer JWT) |
| **POST** | `/api/v1/notifications/sms/ingest` | Ingest raw SMS from device listener; parses and classifies financial entities | Yes (Bearer JWT) |
| **PATCH** | `/api/v1/notifications/{id}/save` | Toggle saved/bookmarked status of an SMS in user's notification vault | Yes (Bearer JWT) |
| **DELETE** | `/api/v1/notifications/{id}` | Permanently delete or dismiss a notification for the authenticated user | Yes (Bearer JWT) |
| **PATCH** | `/api/v1/notifications/{id}/read` | Mark an individual notification as read | Yes (Bearer JWT) |
| **POST** | `/api/v1/notifications/read-all` | Mark all unread notifications as read | Yes (Bearer JWT) |
| **GET** | `/api/v1/income/detected-inflows` | Fetch pending detected credit transactions for Income Tracking Short Box | Yes (Bearer JWT) |
| **POST** | `/api/v1/income/detected-inflows/{detectedId}/confirm` | Approve detected inflow and convert into an official Income Entry | Yes (Bearer JWT) |
| **DELETE** | `/api/v1/income/detected-inflows/{detectedId}` | Dismiss / Delete detected inflow without adding to income ledger | Yes (Bearer JWT) |
| **GET** | `/api/v1/expense/detected-expenses` | Fetch pending detected debit transactions for Expense Tracking Short Box | Yes (Bearer JWT) |
| **POST** | `/api/v1/expense/detected-expenses/{detectionId}/confirm` | Approve detected expense and convert into an official Expense Entry | Yes (Bearer JWT) |
| **DELETE** | `/api/v1/expense/detected-expenses/{detectionId}` | Dismiss / Delete detected expense without adding to expense ledger | Yes (Bearer JWT) |

---

## 3. Detailed Endpoint Contracts & JSON Schemas

### 3.1 Fetch Notifications List
* **Endpoint:** `GET /api/v1/notifications`
* **Query Parameters:**
  - `filter` (optional): `all` | `unread` | `saved` | `sms`
  - `category` (optional): `Credit` | `Debit` | `Fixed Deposit` | `Promotion`
  - `page` (optional, default `1`): Integer
  - `limit` (optional, default `20`): Integer
* **Headers:**
  ```http
  Authorization: Bearer <jwt_token>
  Accept: application/json
  ```
* **Success Response (200 OK):**
```json
{
  "success": true,
  "count": 4,
  "unreadCount": 2,
  "total": 18,
  "page": 1,
  "totalPages": 1,
  "data": [
    {
      "id": "notif-sms-001",
      "userId": "cmuzhxi5a000asr4p9f6jcndp",
      "title": "Salary Credited",
      "message": "Rs 85,000.00 credited to A/C ••••4587 on 25-Aug-2025 by Tech Corp India Pvt Ltd. Bal: Rs 1,42,500.00",
      "type": "SMS",
      "priority": "High",
      "timestamp": "2026-11-03T09:30:00.000Z",
      "isRead": false,
      "isSaved": false,
      "isSms": true,
      "smsCategory": "Credit",
      "amount": 85000.0,
      "bankName": "HDFC Bank",
      "accountDigits": "4587",
      "rawSms": "Dear Customer, INR 85,000.00 has been credited to your A/C ending 4587 on 25-Aug-25 towards SALARY by TECH CORP INDIA PVT LTD. Info: CMS/NEFT/002941829. Avail Bal: INR 1,42,500.00 - HDFC Bank",
      "merchantOrSource": "Tech Corp India Pvt Ltd",
      "referenceId": "UTR-HDFC-99182301",
      "status": "PENDING_APPROVAL",
      "createdAt": "2026-11-03T09:30:00.000Z",
      "updatedAt": "2026-11-03T09:30:00.000Z"
    },
    {
      "id": "notif-sms-002",
      "userId": "cmuzhxi5a000asr4p9f6jcndp",
      "title": "Expense Detected",
      "message": "Rs 1,450.00 spent on Swiggy via HDFC Card ••••4587 on 03-Nov-2026",
      "type": "SMS",
      "priority": "Medium",
      "timestamp": "2026-11-03T08:15:00.000Z",
      "isRead": true,
      "isSaved": true,
      "isSms": true,
      "smsCategory": "Debit",
      "amount": 1450.0,
      "bankName": "HDFC Bank",
      "accountDigits": "4587",
      "rawSms": "Alert: You have spent Rs 1,450.00 on your HDFC Card ending 4587 at SWIGGY on 03-NOV-2026 at 01:45 PM. Avail Lmt: Rs 1,85,550.00",
      "merchantOrSource": "Swiggy",
      "referenceId": "TXN-SWIG-481920",
      "status": "APPROVED",
      "createdAt": "2026-11-03T08:15:00.000Z",
      "updatedAt": "2026-11-03T08:20:00.000Z"
    },
    {
      "id": "notif-sms-003",
      "userId": "cmuzhxi5a000asr4p9f6jcndp",
      "title": "Fixed Deposit Created",
      "message": "Fixed Deposit of Rs 1,00,000.00 created at 7.25% p.a. Maturing on 03-Nov-2027 in SBI ••••4821",
      "type": "SMS",
      "priority": "Info",
      "timestamp": "2026-11-03T07:00:00.000Z",
      "isRead": false,
      "isSaved": false,
      "isSms": true,
      "smsCategory": "Fixed Deposit",
      "amount": 100000.0,
      "bankName": "SBI",
      "accountDigits": "4821",
      "rawSms": "State Bank of India: Your FD A/C 98124018 for INR 1,00,000.00 has been opened successfully on 03-11-2026. Rate: 7.25% p.a. Tenor: 1 Year.",
      "merchantOrSource": "State Bank of India",
      "referenceId": "FD-SBI-98124018",
      "status": "VIEWED",
      "createdAt": "2026-11-03T07:00:00.000Z",
      "updatedAt": "2026-11-03T07:00:00.000Z"
    },
    {
      "id": "notif-sms-004",
      "userId": "cmuzhxi5a000asr4p9f6jcndp",
      "title": "Exclusive Offer",
      "message": "Get 5% cashback up to Rs 500 on your next grocery purchase using Finomos Card",
      "type": "SMS",
      "priority": "Low",
      "timestamp": "2026-11-02T14:30:00.000Z",
      "isRead": true,
      "isSaved": false,
      "isSms": true,
      "smsCategory": "Promotion",
      "amount": 500.0,
      "bankName": "Finomos Card",
      "accountDigits": null,
      "rawSms": "Exclusive Diwali Offer: Use your Finomos Platinum Card for grocery shopping and get flat 5% cashback up to Rs 500. Valid till 15 Nov. T&C apply.",
      "merchantOrSource": "Finomos Promotions",
      "referenceId": "PROMO-DIWALI-2026",
      "status": "VIEWED",
      "createdAt": "2026-11-02T14:30:00.000Z",
      "updatedAt": "2026-11-02T14:30:00.000Z"
    }
  ]
}
```

---

### 3.2 Unread Notification Badge Count
* **Endpoint:** `GET /api/v1/notifications/unread-count`
* **Success Response (200 OK):**
```json
{
  "success": true,
  "unreadCount": 2,
  "unreadSmsCount": 2,
  "unreadSystemCount": 0
}
```

---

### 3.3 Real-Time SMS Ingestion & NLP Parsing API
* **Endpoint:** `POST /api/v1/notifications/sms/ingest`
* **Description:** Called by Android background broadcast receiver or simulated SMS tester when a bank SMS is delivered to the device.
* **Request Body Example:**
```json
{
  "sender": "VK-HDFCBK",
  "body": "Dear Customer, INR 45,000.00 has been credited to your A/C ending 4587 on 03-Nov-26 towards CONSULTING INFLOW by ACME TECHNOLOGIES. Avail Bal: INR 1,87,500.00 - HDFC Bank",
  "receivedAt": "2026-11-03T10:15:30.000Z"
}
```
* **Success Response (201 Created):**
```json
{
  "success": true,
  "message": "SMS processed and transaction identified successfully",
  "parsed": {
    "isFinancial": true,
    "smsCategory": "Credit",
    "amount": 45000.0,
    "currency": "INR",
    "bankName": "HDFC Bank",
    "accountDigits": "4587",
    "merchantOrSource": "Acme Technologies",
    "referenceId": "UTR-HDFC-09281938",
    "availableBalance": 187500.0,
    "confidenceScore": 0.98
  },
  "notification": {
    "id": "notif-sms-005",
    "title": "Income Credited",
    "message": "Rs 45,000.00 credited to HDFC Bank ••••4587 by Acme Technologies",
    "isSms": true,
    "smsCategory": "Credit",
    "isRead": false,
    "isSaved": false,
    "createdAt": "2026-11-03T10:15:30.000Z"
  },
  "detectedRecord": {
    "detectedId": "inflow-det-005",
    "targetModule": "INCOME",
    "status": "PENDING_APPROVAL"
  }
}
```

---

### 3.4 Save / Bookmark Notification
* **Endpoint:** `PATCH /api/v1/notifications/{id}/save`
* **Description:** Toggles the saved status of the specified notification.
* **Request Body (optional):**
```json
{
  "isSaved": true
}
```
* **Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Notification saved to vault successfully",
  "data": {
    "id": "notif-sms-001",
    "isSaved": true,
    "savedAt": "2026-11-03T10:30:00.000Z"
  }
}
```

---

### 3.5 Delete Notification
* **Endpoint:** `DELETE /api/v1/notifications/{id}`
* **Description:** Deletes or archives the notification record for the user.
* **Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Notification deleted successfully",
  "deletedId": "notif-sms-001"
}
```

---

### 3.6 Income Tracking: Pending Detected Inflows (Short Box API)
* **Endpoint:** `GET /api/v1/income/detected-inflows`
* **Description:** Returns all detected credit transactions that have not yet been approved or dismissed by the user.
* **Success Response (200 OK):**
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "detectedId": "inflow-det-001",
      "source": "Tech Corp India Pvt Ltd",
      "amount": 85000.0,
      "category": "Salary",
      "bankAccount": "HDFC Bank ••••4587",
      "date": "2026-11-03",
      "rawSms": "Dear Customer, INR 85,000.00 has been credited to your A/C ending 4587 on 25-Aug-25 towards SALARY by TECH CORP INDIA PVT LTD. Info: CMS/NEFT/002941829. Avail Bal: INR 1,42,500.00 - HDFC Bank",
      "confidenceScore": 0.95,
      "isDuplicate": false,
      "status": "PENDING"
    }
  ]
}
```

---

### 3.7 Income Tracking: Approve Detected Inflow
* **Endpoint:** `POST /api/v1/income/detected-inflows/{detectedId}/confirm`
* **Description:** Approves the detected inflow from the Short Box. Automatically creates an official `IncomeEntry`, marks the detected inflow as `APPROVED`, and reconciles monthly totals.
* **Request Body Example:**
```json
{
  "category": "Salary",
  "streamNature": "Active",
  "frequency": "Monthly",
  "notes": "Verified from HDFC Bank SMS credit alert"
}
```
* **Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Detected inflow approved and committed to income ledger",
  "data": {
    "incomeEntry": {
      "id": "inc-entry-991",
      "userId": "cmuzhxi5a000asr4p9f6jcndp",
      "source": "Tech Corp India Pvt Ltd",
      "category": "Salary",
      "streamNature": "Active",
      "amount": 85000.0,
      "frequency": "Monthly",
      "bankAccount": "HDFC Bank ••••4587",
      "date": "2026-11-03",
      "isVerified": true,
      "voucherNumber": "FIN-INC-202611-00049"
    },
    "updatedMonthlyInflow": 217500.0,
    "detectedRecordStatus": "APPROVED"
  }
}
```

---

### 3.8 Income Tracking: Delete / Dismiss Detected Inflow
* **Endpoint:** `DELETE /api/v1/income/detected-inflows/{detectedId}`
* **Description:** Dismisses the detected inflow short box without altering the user's financial income stream or ledger.
* **Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Detected inflow dismissed successfully",
  "detectedId": "inflow-det-001"
}
```

---

### 3.9 Expense Tracking: Pending Detected Expenses (Short Box API)
* **Endpoint:** `GET /api/v1/expense/detected-expenses`
* **Description:** Returns all detected debit transactions awaiting confirmation.
* **Success Response (200 OK):**
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "detectionId": "exp-det-002",
      "amount": 1450.0,
      "merchant": "Swiggy",
      "category": "Food & Dining",
      "date": "2026-11-03T08:15:00.000Z",
      "paymentMode": "Credit Card",
      "bankAccount": "HDFC Bank ••••4587",
      "rawSms": "Alert: You have spent Rs 1,450.00 on your HDFC Card ending 4587 at SWIGGY on 03-NOV-2026. Avail Lmt: Rs 1,85,550.00",
      "confidence": 0.96,
      "status": "PENDING"
    }
  ]
}
```

---

### 3.10 Expense Tracking: Approve Detected Expense
* **Endpoint:** `POST /api/v1/expense/detected-expenses/{detectionId}/confirm`
* **Description:** Approves the detected expense from the Short Box. Automatically creates an official `ExpenseEntry`, marks the detected record as `APPROVED`, and updates the corresponding budget bucket spent totals.
* **Request Body Example:**
```json
{
  "category": "Food & Dining",
  "paymentMode": "Credit Card",
  "notes": "Lunch delivery order from Swiggy",
  "tags": ["Food", "Delivery"]
}
```
* **Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Detected expense approved and committed to ledger",
  "data": {
    "expenseEntry": {
      "id": "exp-entry-882",
      "userId": "cmuzhxi5a000asr4p9f6jcndp",
      "merchant": "Swiggy",
      "category": "Food & Dining",
      "amount": 1450.0,
      "paymentMode": "Credit Card",
      "bankAccount": "HDFC Bank ••••4587",
      "date": "2026-11-03T08:15:00.000Z",
      "isRecurring": false,
      "voucherNumber": "FIN-EXP-202611-00108"
    },
    "budgetImpact": {
      "category": "Food & Dining",
      "allocated": 15000.0,
      "spent": 8450.0,
      "remaining": 6550.0,
      "utilizationPercent": 56.33
    },
    "detectedRecordStatus": "APPROVED"
  }
}
```

---

### 3.11 Expense Tracking: Delete / Dismiss Detected Expense
* **Endpoint:** `DELETE /api/v1/expense/detected-expenses/{detectionId}`
* **Description:** Dismisses the detected expense short box without posting any debit to expenses.
* **Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Detected expense dismissed successfully",
  "detectionId": "exp-det-002"
}
```

---

## 4. SMS Classification & Parsing Rules (Indian Banking Standards)

The backend ingestion pipeline must apply standard regular expressions and NLP entity extraction to support all major Indian financial institutions:

### 4.1 Keyword Patterns for Financial Categorization

| Category | Primary Keywords | Disqualifying Keywords | Action on Client |
| :--- | :--- | :--- | :--- |
| **CREDIT** (Inflow) | `credited`, `deposited`, `received`, `refund`, `cashback added`, `salary credited` | `debited`, `withdrawn`, `declined`, `failed` | Redirect to **Income Tracking** -> Display **Inflow Short Box** |
| **DEBIT** (Outflow) | `debited`, `spent`, `paid to`, `withdrawn at`, `purchase at`, `txn of` | `credited`, `refund`, `failed`, `declined` | Redirect to **Expense Tracking** -> Display **Outflow Short Box** |
| **FIXED DEPOSIT** | `fixed deposit`, `term deposit`, `fd a/c`, `auto sweep fd`, `matured on` | `offer`, `apply` | Display **FD Detail Sheet** -> Redirect to **Bank Aggregation** |
| **PROMOTION** | `offer`, `pre-approved`, `eligible for`, `discount`, `coupon`, `cashback up to` | `credited to your a/c`, `debited from` | Display **Promotion Detail Sheet** |
| **SYSTEM / OTP** | `otp`, `secret code`, `verification code`, `do not share` | - | Omit from transaction ledger; retain in security logs |

### 4.2 Entity Extraction Regex Patterns
1. **Amount Extraction**:
   - `(?:(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?))`
2. **Account Number Extraction**:
   - `(?:(?:A\/C|acct|ending|card|ac|account)\s*(?:no\.?)?\s*(?:ending\s*)?(?:[xX*•]*(\d{4})))`
3. **Reference / UTR Extraction**:
   - `(?:(?:UTR|Ref|Txn|Reference|UPI\s*Ref)\s*(?:No\.?|ID)?[:\s]*([A-Za-z0-9]+))`
4. **Merchant / Beneficiary Extraction**:
   - `(?:(?:at|to|by|towards|vpa)\s+([A-Za-z0-9\s&.,'-]{3,35}?)(?:\s+on|\s+ref|\s+avail|\s+info|\s*\.))`

---

## 5. Recommended Database Schema (PostgreSQL / Prisma)

```prisma
// Notification Record
model Notification {
  id               String            @id @default(cuid())
  userId           String
  title            String
  message          String
  type             NotificationType  @default(SMS)
  priority         PriorityLevel     @default(INFO)
  isRead           Boolean           @default(false)
  isSaved          Boolean           @default(false)
  isSms            Boolean           @default(true)
  smsCategory      SmsCategory?
  amount           Decimal?          @db.Decimal(14, 2)
  bankName         String?
  accountDigits    String?
  rawSms           String?           @db.Text
  merchantOrSource String?
  referenceId      String?
  status           ActionStatus      @default(PENDING_APPROVAL)
  createdAt        DateTime          @default(now())
  updatedAt        DateTime          @updatedAt

  user             User              @relation(fields: [userId], references: [id], onDelete: Cascade)
  detectedInflow   DetectedInflow?
  detectedExpense  DetectedExpense?

  @@index([userId, isRead])
  @@index([userId, isSaved])
  @@index([userId, isSms, smsCategory])
  @@index([referenceId])
}

// Detected Inflow (Income Short Box)
model DetectedInflow {
  id              String         @id @default(cuid())
  notificationId  String?        @unique
  userId          String
  source          String
  amount          Decimal        @db.Decimal(14, 2)
  category        String         @default("Salary")
  bankAccount     String
  date            DateTime       @default(now())
  rawSms          String?        @db.Text
  confidenceScore Float          @default(0.95)
  isDuplicate     Boolean        @default(false)
  status          ActionStatus   @default(PENDING)
  createdAt       DateTime       @default(now())
  updatedAt       DateTime       @updatedAt

  notification    Notification?  @relation(fields: [notificationId], references: [id], onDelete: SetNull)
  user            User           @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, status])
}

// Detected Expense (Expense Short Box)
model DetectedExpense {
  id              String         @id @default(cuid())
  notificationId  String?        @unique
  userId          String
  merchant        String
  amount          Decimal        @db.Decimal(14, 2)
  category        String         @default("General")
  paymentMode     String         @default("UPI")
  bankAccount     String
  date            DateTime       @default(now())
  rawSms          String?        @db.Text
  confidence      Float          @default(0.95)
  status          ActionStatus   @default(PENDING)
  createdAt       DateTime       @default(now())
  updatedAt       DateTime       @updatedAt

  notification    Notification?  @relation(fields: [notificationId], references: [id], onDelete: SetNull)
  user            User           @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, status])
}

enum NotificationType {
  SMS
  BUDGET
  KYC
  DOCUMENT
  ACCOUNT
  SECURITY
  PAYMENT
}

enum PriorityLevel {
  HIGH
  MEDIUM
  LOW
  INFO
}

enum SmsCategory {
  Credit
  Debit
  FixedDeposit
  Promotion
}

enum ActionStatus {
  PENDING
  PENDING_APPROVAL
  APPROVED
  DISMISSED
  VIEWED
}
```

---

## 6. Deduplication & Idempotency Rules
1. **Reference ID Deduplication**: If an incoming SMS has a non-empty `referenceId` or UTR that already exists in the database for the user within the last 30 days, the backend must avoid creating duplicate pending notifications.
2. **Approval Idempotency**: If a client submits `POST /confirm` multiple times for the same `detectedId`, the backend must return HTTP 200 with the already existing entry instead of posting duplicate ledger credits/debits.
3. **Short Box Dismissal**: When a detected transaction is dismissed via `DELETE`, set `status = DISMISSED` and do not display it on future queries.

