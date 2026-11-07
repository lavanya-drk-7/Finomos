# FINOMOS FINANCIAL OS — BACKEND API REQUIREMENTS SPECIFICATION
## System: Native Device SMS Tracking, Historical Sync & Real-Time Financial Detection
**Target Service Base URL:** `https://finmos-user.onrender.com/api/v1`  
**Document Version:** 2.0.0  
**Status:** Approved for Implementation  
**Client Platform:** Finomos Flutter Mobile App (Android / iOS)  

---

## 1. Executive Summary & Objective

In the Finomos Personal CFO application, users authenticate using their registered mobile number (e.g., `+91 98765 43210`). The goal of this system is to:
1. **Automatically track transactional SMS** received in the device's native Messages app on that mobile number.
2. **Classify and extract financial entities** in real-time (Credit / Inflow, Debit / Outflow, Fixed Deposit, EMI, Promotion).
3. **Batch-sync historical financial SMS** (e.g. past 30-90 days) upon user login/consent.
4. **Display SMS alerts in the Notifications Center** and reflect real-time unread counts on the **Dashboard notification badge**.
5. **Route detected inflows to Income Tracking** and **outflows to Expense Tracking** through an interactive **Short Box** interface where users can **Approve** (commits to financial ledgers with Section 65B audit voucher) or **Delete / Dismiss** (rejects without ledger mutation).

---

## 2. Architecture & Data Flow

```
[ User Mobile Device ]
       │
       ▼ (User grants SMS Read/Receive Permission)
[ Native Messages App ] ────► [ Finomos Flutter Client ]
                                        │
             ┌──────────────────────────┴──────────────────────────┐
             ▼ (On Login / Sync)                                   ▼ (Real-Time Incoming SMS)
     Batch SMS Sync                                        Single SMS Ingest
   POST /notifications/sms/batch-sync                    POST /notifications/sms/ingest
             │                                                     │
             └──────────────────────────┬──────────────────────────┘
                                        ▼
                         [ Finomos Backend Service ]
                                        │
             ┌──────────────────────────┼──────────────────────────┐
             ▼                          ▼                          ▼
   Idempotency & Hash        NLP / Regex Entity Extractor  DB Storage (PostgreSQL/Prisma)
  (Prevents duplicates)     (Amount, Bank, Merchant, Ref) (Notification & DetectedTxn)
             │                          │                          │
             └──────────────────────────┼──────────────────────────┘
                                        ▼
                [ Real-Time Notification & Ledger Redirection ]
                   ├── 1. Dashboard: Unread Badge Count Increments
                   ├── 2. Notifications Screen: SMS Cards with Save & Delete
                   └── 3. Short Box: 
                           ├── Credit ──► /income (Detected Inflow Short Box)
                           └── Debit  ──► /expenses (Detected Outflow Short Box)
```

---

## 3. Endpoints Inventory

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| **POST** | `/api/v1/notifications/sms/batch-sync` | Ingest multiple historical SMS from device inbox | Yes (Bearer JWT) |
| **POST** | `/api/v1/notifications/sms/ingest` | Ingest single real-time incoming SMS | Yes (Bearer JWT) |
| **GET** | `/api/v1/notifications` | Fetch paginated notifications with category filters | Yes (Bearer JWT) |
| **GET** | `/api/v1/notifications/unread-count` | Real-time unread count for Dashboard bell badge | Yes (Bearer JWT) |
| **PATCH** | `/api/v1/notifications/:id/save` | Bookmark / save SMS notification to vault | Yes (Bearer JWT) |
| **DELETE**| `/api/v1/notifications/:id` | Permanently delete notification | Yes (Bearer JWT) |
| **PATCH** | `/api/v1/notifications/:id/read` | Mark individual notification as read | Yes (Bearer JWT) |
| **POST** | `/api/v1/notifications/read-all` | Mark all notifications as read | Yes (Bearer JWT) |
| **GET** | `/api/v1/income/detected-inflows` | Fetch pending detected credit transactions | Yes (Bearer JWT) |
| **POST** | `/api/v1/income/detected-inflows/:id/confirm` | Approve detected inflow into active income stream | Yes (Bearer JWT) |
| **DELETE**| `/api/v1/income/detected-inflows/:id` | Dismiss / delete detected inflow from short box | Yes (Bearer JWT) |
| **GET** | `/api/v1/expense/detected-expenses` | Fetch pending detected debit transactions | Yes (Bearer JWT) |
| **POST** | `/api/v1/expense/detected-expenses/:id/confirm` | Approve detected expense into active expense ledger | Yes (Bearer JWT) |
| **DELETE**| `/api/v1/expense/detected-expenses/:id` | Dismiss / delete detected expense from short box | Yes (Bearer JWT) |

---

## 4. Detailed API Specifications

### 4.1 Batch Historical SMS Sync
* **Endpoint:** `POST /api/v1/notifications/sms/batch-sync`
* **Purpose:** Called once after user logs in or grants SMS permissions. Sends filtered transactional SMS from the device's native inbox (past 30 to 90 days).
* **Headers:**
  ```http
  Authorization: Bearer <jwt_token>
  Content-Type: application/json
  ```
* **Request Body:**
  ```json
  {
    "userMobile": "+919876543210",
    "syncMode": "HISTORICAL",
    "deviceTimestamp": "2026-11-04T11:15:00.000Z",
    "messages": [
      {
        "sender": "VK-HDFCBK",
        "body": "Dear Customer, INR 5,420.00 debited from A/C ••••4587 on 03-Nov-26 via UPI/Swiggy. Ref 430892019283. Bal: INR 45,000.00",
        "timestamp": 1793769107000
      },
      {
        "sender": "AD-SBIINB",
        "body": "Dear SBI User, A/C ••••1123 credited by Rs 85,000.00 on 03Nov26 by transfer from Infosys Technologies Ltd. Bal Rs 1,45,400.00 - SBI Ref 9901823912",
        "timestamp": 1793769000000
      },
      {
        "sender": "JM-ICICIB",
        "body": "Dear Customer, Fixed Deposit of INR 1,00,000.00 booked under A/C ••••8891 on 03-Nov-26 for 12 months at 7.10% p.a. Ref FD492019.",
        "timestamp": 1793750000000
      }
    ]
  }
  ```
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Batch SMS processed successfully",
    "summary": {
      "totalReceived": 3,
      "ingested": 3,
      "duplicatesSkipped": 0,
      "creditsCount": 1,
      "debitsCount": 1,
      "fixedDepositsCount": 1
    },
    "data": [
      {
        "notificationId": "notif_batch_001",
        "classification": "Debit",
        "entities": {
          "amount": 5420.0,
          "bankName": "HDFC Bank",
          "accountDigits": "••••4587",
          "merchantOrSource": "Swiggy",
          "suggestedCategory": "Food & Dining",
          "suggestedPriority": "P4 - Discretionary",
          "referenceId": "430892019283",
          "balance": 45000.0,
          "date": "2026-11-03"
        },
        "redirection": {
          "route": "/expenses",
          "action": "DETECTED_OUTFLOW_SHORTBOX",
          "detectionId": "det_deb_001",
          "targetModule": "EXPENSE_TRACKING"
        }
      },
      {
        "notificationId": "notif_batch_002",
        "classification": "Credit",
        "entities": {
          "amount": 85000.0,
          "bankName": "State Bank of India",
          "accountDigits": "••••1123",
          "merchantOrSource": "Infosys Technologies Ltd",
          "suggestedCategory": "Salary",
          "suggestedPriority": "P1 - Essential",
          "referenceId": "9901823912",
          "balance": 145400.0,
          "date": "2026-11-03"
        },
        "redirection": {
          "route": "/income",
          "action": "DETECTED_INFLOW_SHORTBOX",
          "detectedId": "det_inf_002",
          "targetModule": "INCOME_TRACKING"
        }
      }
    ]
  }
  ```

---

### 4.2 Real-Time Incoming SMS Ingestion
* **Endpoint:** `POST /api/v1/notifications/sms/ingest`
* **Purpose:** Called immediately when an SMS arrives via device broadcast receiver.
* **Headers:**
  ```http
  Authorization: Bearer <jwt_token>
  Content-Type: application/json
  ```
* **Request Body:**
  ```json
  {
    "sender": "VK-HDFCBK",
    "body": "Dear Customer, INR 5,420.00 debited from A/C ••••4587 on 03-Nov-26 via UPI/Swiggy. Ref 430892019283. Bal: INR 45,000.00"
  }
  ```
* **Success Response (200 OK / 201 Created):**
  ```json
  {
    "success": true,
    "alreadyIngested": false,
    "message": "SMS ingested and processed successfully",
    "data": {
      "notificationId": "cmw0kzpm70001ekofznhtumkx",
      "classification": "Debit",
      "entities": {
        "amount": 5420.0,
        "bankName": "HDFC Bank",
        "accountDigits": "••••4587",
        "merchantOrSource": "Swiggy",
        "suggestedCategory": "Food & Dining",
        "suggestedPriority": "P4 - Discretionary",
        "referenceId": "430892019283",
        "balance": 45000.0,
        "date": "03-Nov-26",
        "fdDetails": null
      },
      "redirection": {
        "route": "/expenses",
        "action": "DETECTED_OUTFLOW_SHORTBOX",
        "detectionId": "det_deb_mw0kzqqg_85in",
        "targetModule": "EXPENSE_TRACKING"
      }
    }
  }
  ```
* **Idempotent Response (If already received):**
  ```json
  {
    "success": true,
    "alreadyIngested": true,
    "message": "SMS already ingested and processed for this reference ID (idempotent)",
    "data": { ... }
  }
  ```

---

### 4.3 Unread Notification Count (Dashboard Bell Badge)
* **Endpoint:** `GET /api/v1/notifications/unread-count`
* **Purpose:** Powers the red notification badge on the Dashboard top navigation bar.
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "unreadCount": 3,
    "unreadSmsCount": 3,
    "unreadSystemCount": 0
  }
  ```

---

### 4.4 Confirm Detected Inflow (Income Short Box Approval)
* **Endpoint:** `POST /api/v1/income/detected-inflows/:detectedId/confirm`
* **Request Body:**
  ```json
  {
    "category": "Salary",
    "frequency": "Monthly"
  }
  ```
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Detected inflow confirmed and added to active income streams",
    "data": {
      "id": "inc_mw1mirldy64a",
      "userId": "cmuzhxi5a000asr4p9f6jcndp",
      "amount": 85000.0,
      "date": "04 Nov 2026",
      "category": "Salary",
      "source": "Infosys Technologies Ltd",
      "paymentMode": "State Bank of India ••••1123",
      "frequency": "Monthly",
      "notes": "Confirmed via SMS_ALERT (Ref: 9901823912)",
      "voucherNumber": "FIN-INC-202611-00002",
      "isVerified": true,
      "verificationType": "Digitally Verified Inflow",
      "createdAt": "2026-11-04T04:35:38.162Z"
    }
  }
  ```

---

### 4.5 Confirm Detected Expense (Expense Short Box Approval)
* **Endpoint:** `POST /api/v1/expense/detected-expenses/:detectionId/confirm`
* **Request Body:**
  ```json
  {
    "category": "Food & Dining",
    "priority": "P4 - Discretionary",
    "paymentMode": "HDFC Bank ••••4587"
  }
  ```
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Detected expense confirmed and committed to expense ledger",
    "data": {
      "id": "exp_mw1mirl_001",
      "userId": "cmuzhxi5a000asr4p9f6jcndp",
      "amount": 5420.0,
      "description": "Swiggy",
      "category": "Food & Dining",
      "priority": "P4 - Discretionary",
      "date": "03 Nov 2026",
      "bankAccount": "HDFC Bank ••••4587",
      "paymentMode": "UPI",
      "notes": "Auto-detected from HDFC SMS (Ref: 430892019283)",
      "voucherNumber": "FIN-EXP-202611-00014",
      "isVerified": true,
      "createdAt": "2026-11-04T04:35:38.162Z"
    }
  }
  ```

---

## 5. Database Schema Requirements (Prisma / SQL)

```prisma
// User Model Reference
model User {
  id             String          @id @default(cuid())
  email          String?         @unique
  mobile         String          @unique
  fullName       String
  notifications  Notification[]
  detectedInflows DetectedInflow[]
  detectedExpenses DetectedExpense[]
  createdAt      DateTime        @default(now())
}

// Notifications Table (Stores parsed and system notifications)
model Notification {
  id               String       @id @default(cuid())
  userId           String
  user             User         @relation(fields: [userId], references: [id], onDelete: Cascade)
  title            String
  message          String
  type             String       // "SMS", "SYSTEM", "ALERT"
  priority         String       // "High", "Medium", "Low", "Info"
  timestamp        DateTime     @default(now())
  isRead           Boolean      @default(false)
  isSaved          Boolean      @default(false)
  isSms            Boolean      @default(true)
  smsCategory      String       // "Credit", "Debit", "Fixed Deposit", "Promotion"
  amount           Float?
  bankName         String?
  accountDigits    String?      // e.g. "4587"
  rawSms           String?      @db.Text
  sender           String?      // e.g. "VK-HDFCBK"
  referenceId      String?      // UTR / Transaction reference
  dedupHash        String?      @unique // SHA256(userId + referenceId / amount + date)
  status           String       @default("UNCONFIRMED") // "UNCONFIRMED", "APPROVED", "DISMISSED"
  redirectionRoute String?      // "/income", "/expenses", "/bank-aggregation"
  createdAt        DateTime     @default(now())
  updatedAt        DateTime     @updatedAt

  @@index([userId, isRead])
  @@index([userId, smsCategory])
  @@index([dedupHash])
}

// Detected Inflows Table (Short Box Queue for Credits)
model DetectedInflow {
  id               String       @id @default(cuid())
  userId           String
  user             User         @relation(fields: [userId], references: [id], onDelete: Cascade)
  detectedSource   String       // e.g. "Infosys Technologies Ltd"
  amount           Float
  date             String
  bankAccount      String
  confidenceScore  Float        @default(0.95)
  suggestedCategory String      @default("Salary")
  referenceId      String?
  status           String       @default("PENDING") // "PENDING", "CONFIRMED", "DISMISSED"
  notificationId   String?
  createdAt        DateTime     @default(now())
  updatedAt        DateTime     @updatedAt

  @@index([userId, status])
}

// Detected Expenses Table (Short Box Queue for Debits)
model DetectedExpense {
  id               String       @id @default(cuid())
  userId           String
  user             User         @relation(fields: [userId], references: [id], onDelete: Cascade)
  description      String       // e.g. "Swiggy"
  merchant         String
  amount           Float
  date             String
  bankAccount      String
  paymentMode      String       @default("UPI")
  suggestedCategory String      @default("Food & Dining")
  suggestedPriority String      @default("P4 - Discretionary")
  confidenceScore  Float        @default(0.95)
  referenceId      String?
  status           String       @default("PENDING") // "PENDING", "CONFIRMED", "DISMISSED"
  notificationId   String?
  createdAt        DateTime     @default(now())
  updatedAt        DateTime     @updatedAt

  @@index([userId, status])
}
```

---

## 6. Deduplication & Idempotency Rules

1. **Deduplication Hash Calculation**:
   ```
   dedupHash = SHA256(userId + "|" + sender + "|" + amount + "|" + (referenceId ?? date) + "|" + (accountDigits ?? ""))
   ```
2. **Behavior on Match**:
   - If `dedupHash` already exists in the database, return HTTP `200 OK` with `"alreadyIngested": true`.
   - Do **NOT** create duplicate notifications or multiple short box entries.
   - Return the existing `notificationId` and `redirection` so the client can navigate without error.

---

## 7. Security, Privacy & TRAI Regulatory Compliance

1. **User Phone Matching**: The backend authenticates via the Bearer JWT. The user's registered phone number is stored in the JWT payload. Any SMS ingested must be associated strictly with the authenticated `userId`.
2. **TRAI Senders Only**: Only messages from recognized Indian bank sender codes (e.g. `[A-Z]{2}-[A-Z0-9]{6}`) should be accepted. Personal messages (from 10-digit mobile numbers) must be rejected with HTTP `422 Unprocessable Entity`.
3. **Data Protection**: Raw SMS bodies must be encrypted at rest using AES-256. OTP and authentication codes must be scrubbed before database persistence.
4. **Section 65B Admissibility**: Inflow and expense confirmations generate a Section 65B hash voucher stored with timestamp and SHA-256 transaction fingerprint.

