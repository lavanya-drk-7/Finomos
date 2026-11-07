# FINMOS — 100% COMPLETION BACKEND REQUIREMENTS SPECIFICATION
## Comprehensive Gap Analysis & Production API Contracts for Income, Expense, Budget, Bank Aggregation, Auth/SignUp & Profile Modules

**Document Version**: 2.0 (Master Production Spec)  
**Target Environment**: `https://finmos-user.onrender.com`  
**Client Applications**: Finomos Flutter Consumer App (`lib/features/`)  
**Authorization**: `Authorization: Bearer <jwt-token>`  
**Date**: November 2026  

---

## 1. Executive Summary & Readiness Audit

Over 59 endpoints have already been connected and verified with a 100% pass rate across 238 Flutter tests. This document specifies the exact missing endpoints, database schemas, and integration points required to elevate all six core modules from their current high-readiness state (75%–95%) to **100% full production completion**.

| Module | Current Readiness | Target | Remaining Work & Deliverables |
|---|:---:|:---:|---|
| **1. Profile Section** | **75%** | **100%** | Add Employment Details (`/profile/employment`), Family Members CRUD (`/profile/family-members`), and Push Notification FCM token binding. |
| **2. Auth & SignUp** | **90%** | **100%** | Activate live SMS Gateway (Twilio/MSG91 with Indian DLT templates), 60s OTP rate-limiter, and biometric challenge verification. |
| **3. Income Tracking** | **95%** | **100%** | Cloud storage (S3/GCS) payslip multipart upload (`/income/proof-upload`) and automated detected inflow confirmation. |
| **4. Expense Tracking** | **95%** | **100%** | ML Receipt OCR scanning endpoint (`/expenses/receipt-upload`) and recurring monthly expense auto-scheduler. |
| **5. Budget Management** | **95%** | **100%** | Guardrail settings persistence table (`/budgets/settings/guardrails`) and unspent budget month-end rollover. |
| **6. Bank Aggregation** | **98%** | **100%** | Production RBI AA Gateway webhook callback (`/consents/callback`) and automated nightly statement synchronization cron. |

---

## 2. Module 1: Profile Section (75% → 100%)

### 2.1 The Issue Today
While `personal`, `address`, `security`, and `notifications` endpoints are live, the client app's `EmploymentIncomeSubScreen` and `FamilyHouseholdSubScreen` currently save data to in-memory Riverpod state only. When the app is closed or reloaded, employment details and family members reset because the backend has no database tables or endpoints for them.

---

### 2.2 Required API 1: Update Employment & Workplace Details
* **Method**: `PUT`
* **Path**: `/api/v1/user/profile/employment`
* **Auth**: Required (`Bearer <token>`)
* **Headers**: `Content-Type: application/json`

#### Request Payload:
```json
{
  "companyName": "Tech Corp India Pvt Ltd",
  "designation": "Lead Software Engineer",
  "employmentType": "Salaried Full-Time",
  "industry": "Information Technology",
  "workEmail": "sireesha@techcorp.in",
  "epfUanNumber": "100987654321",
  "monthlyInHand": 125000.0,
  "experienceYears": 6,
  "salaryCreditBank": "HDFC Bank ••••4587"
}
```

#### Success Response (HTTP 200 OK):
```json
{
  "success": true,
  "message": "Employment and income profile updated successfully",
  "data": {
    "userId": "cmuzhxi5a000asr4p9f6jcndp",
    "companyName": "Tech Corp India Pvt Ltd",
    "designation": "Lead Software Engineer",
    "employmentType": "Salaried Full-Time",
    "industry": "Information Technology",
    "workEmail": "sireesha@techcorp.in",
    "epfUanNumber": "100987654321",
    "monthlyInHand": 125000.0,
    "updatedAt": "2026-11-03T14:15:00.000Z"
  }
}
```

---

### 2.3 Required API 2: Family & Dependents CRUD
* **Endpoints**:
  * `GET /api/v1/user/profile/family-members` — List all family members
  * `POST /api/v1/user/profile/family-members` — Add new family member
  * `PUT /api/v1/user/profile/family-members/:id` — Edit family member
  * `DELETE /api/v1/user/profile/family-members/:id` — Delete family member
  * `PUT /api/v1/user/profile/household` — Update joint finances toggle & dependent count

#### Request Payload for `POST /api/v1/user/profile/family-members`:
```json
{
  "name": "Arjun Podalakuru",
  "relationship": "Spouse",
  "age": 32,
  "isDependent": false,
  "medicalInsuranceCovered": true,
  "notes": "Covered under employer family health plan"
}
```

#### Success Response (HTTP 201 Created):
```json
{
  "success": true,
  "message": "Family member added successfully",
  "data": {
    "id": "fam_cmw0xyz987654",
    "userId": "cmuzhxi5a000asr4p9f6jcndp",
    "name": "Arjun Podalakuru",
    "relationship": "Spouse",
    "age": 32,
    "isDependent": false,
    "createdAt": "2026-11-03T14:15:00.000Z"
  }
}
```

#### Request Payload for `PUT /api/v1/user/profile/household`:
```json
{
  "totalDependents": 2,
  "jointFinancesEnabled": true,
  "emergencyFundMonths": 6,
  "primaryEarner": true
}
```

---

### 2.4 Required API 3: Device FCM Token for Push Notifications
* **Method**: `POST`
* **Path**: `/api/v1/user/profile/device-token`
* **Request Payload**:
```json
{
  "fcmToken": "eK38b9X...d81",
  "platform": "android",
  "deviceModel": "Pixel 7 Pro",
  "pushNotificationsEnabled": true
}
```

---

## 3. Module 2: Authentication & SignUp (90% → 100%)

### 3.1 The Issue Today
1. The backend responds with `devOtp: "482256"` in the response payload because third-party telecom SMS dispatch is disabled. Physical devices do not receive a telecom SMS without a configured gateway.
2. No server-side cooldown rate-limiter prevents users from spamming OTP requests.

---

### 3.2 Required Deliverables:

#### A. Telecom SMS Gateway Integration (MSG91 / Twilio / AWS SNS)
Configure environment variables on Render:
```env
SMS_PROVIDER=MSG91
MSG91_AUTH_KEY=your_msg91_auth_key
MSG91_SENDER_ID=FINMOS
MSG91_DLT_TE_ID_OTP=1207161829304918273
MSG91_OTP_TEMPLATE_ID=64a2b10f82c...
```
* **TRAI DLT Template Format (India Regulatory Requirement)**:
  `Your Finomos verification code is {#var#}. Valid for 10 minutes. Do not share this OTP with anyone.`

#### B. Cooldown Rate Limiting on `POST /api/auth/send-otp`:
* Maximum 1 request per 60 seconds per phone number/IP.
* If requested before 60 seconds, return HTTP 429:
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Please wait 45 seconds before requesting a new OTP.",
    "retryAfterSeconds": 45
  }
}
```

#### C. Biometric Session Fast-Login (Optional/Recommended)
* **Method**: `POST`
* **Path**: `/api/auth/biometric/login`
* **Payload**: `{ "deviceId": "...", "signature": "...", "userId": "..." }`
* **Response**: Returns refreshed Bearer JWT.

---

## 4. Module 3: Income Tracking (95% → 100%)

### 4.1 The Issue Today
Income CRUD, analytics, and voucher generation work seamlessly, but uploading salary slips / proof documents relies on local file paths when the server storage bucket is disconnected.

---

### 4.2 Required API: S3/Cloud Storage Payslip Upload
* **Method**: `POST`
* **Path**: `/api/v1/income/proof-upload`
* **Content-Type**: `multipart/form-data`
* **Fields**:
  * `file`: Binary file (PDF, PNG, JPEG up to 10MB)
  * `incomeEntryId`: (Optional) ID of existing income stream
* **Success Response (HTTP 200 OK)**:
```json
{
  "success": true,
  "message": "Payslip document uploaded and scanned successfully",
  "data": {
    "documentName": "salary_slip_oct_2026.pdf",
    "documentPath": "https://s3.ap-south-1.amazonaws.com/finmos-vault/income/oct2026_cmuzh.pdf",
    "fileSizeBytes": 1245900,
    "mimeType": "application/pdf",
    "sha256Hash": "7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069"
  }
}
```

---

## 5. Module 4: Expense Tracking (95% → 100%)

### 5.1 The Issue Today
Users can manually add, edit, and filter expenses and download invoices. However, receipt scanning requires automatic OCR extraction to parse amounts and merchant names directly from receipt photos.

---

### 5.2 Required API: Smart Receipt OCR Auto-Scanning
* **Method**: `POST`
* **Path**: `/api/v1/expenses/receipt-upload`
* **Content-Type**: `multipart/form-data`
* **Field**: `receipt`: Binary image file (JPEG, PNG)
* **Success Response (HTTP 200 OK)**:
```json
{
  "success": true,
  "message": "Receipt processed and OCR fields extracted",
  "data": {
    "documentName": "receipt_starbucks_1029.jpg",
    "documentPath": "https://s3.ap-south-1.amazonaws.com/finmos-vault/expenses/starbucks_1029.jpg",
    "extracted": {
      "amount": 475.0,
      "merchant": "Starbucks Coffee",
      "date": "2026-11-03",
      "suggestedCategory": "Food & Dining",
      "suggestedPriority": "P5 - Lifestyle",
      "confidenceScore": 0.96,
      "taxAmount": 22.62,
      "lineItems": [
        { "name": "Caffe Latte Tall", "qty": 1, "price": 275.0 },
        { "name": "Almond Croissant", "qty": 1, "price": 200.0 }
      ]
    }
  }
}
```

---

## 6. Module 5: Budget Management (95% → 100%)

### 6.1 The Issue Today
Category budgets, utilization bars, and overspending warnings work live. But guardrail settings (auto SMS deduction, 80% threshold warnings) are stored in client cache and need backend persistence across devices.

---

### 6.2 Required API 1: Guardrail Settings Persistence
* **Method**: `PUT`
* **Path**: `/api/v1/budgets/settings/guardrails`
* **Request Payload**:
```json
{
  "warning80Alerts": true,
  "overspendingBanners": true,
  "autoSmsDeduction": true,
  "dailySpendingCap": 5000.0,
  "alertThresholdPercentage": 80.0
}
```
* **Success Response (HTTP 200 OK)**:
```json
{
  "success": true,
  "message": "Budget guardrail rules saved successfully",
  "data": {
    "userId": "cmuzhxi5a000asr4p9f6jcndp",
    "warning80Alerts": true,
    "overspendingBanners": true,
    "autoSmsDeduction": true,
    "dailySpendingCap": 5000.0,
    "alertThresholdPercentage": 80.0,
    "updatedAt": "2026-11-03T14:15:00.000Z"
  }
}
```

---

### 6.3 Required API 2: Month-End Budget Rollover
* **Method**: `POST`
* **Path**: `/api/v1/budgets/rollover`
* **Request Payload**:
```json
{
  "sourceMonth": "2026-10",
  "targetMonth": "2026-11",
  "rolloverSurplus": true,
  "resetOverspent": true
}
```

---

## 7. Module 6: Bank Aggregation (98% → 100%)

### 7.1 The Production Need
Bank aggregation endpoints are 100% verified with mock/sandbox data. For production readiness with live bank accounts across India, the backend requires a callback webhook for Account Aggregator authorization.

---

### 7.2 Required API: RBI Account Aggregator Webhook Callback
* **Method**: `POST`
* **Path**: `/api/v1/bank-aggregation/consents/callback`
* **Auth**: Webhook Signature (`X-AA-Signature` / HMAC-SHA256)
* **Payload**:
```json
{
  "consentHandle": "AA-REQ-1793685542531-4720",
  "consentId": "ART-FIP-ICICI-01-1793685542531",
  "status": "READY",
  "fipId": "FIP-ICICI-01",
  "dataSessionId": "SESSION-DATA-918274",
  "signedConsentArtifact": "eyJhbGciOiJSUzI1NiIsIn..."
}
```
* **Backend Action**:
  1. Validates RSA-2048/HMAC signature.
  2. Initiates automated FI fetch from ICICI Bank FIP.
  3. Decrypts and ingests accounts, credit cards, and transactions.
  4. Pushes real-time WebSocket / SSE notification to client app.

---

## 8. Database Schema Extensions (Prisma / SQL)

```prisma
// 1. Employment Profile Table
model UserEmployment {
  id              String   @id @default(cuid())
  userId          String   @unique
  companyName     String
  designation     String
  employmentType  String
  industry        String
  workEmail       String?
  epfUanNumber    String?
  monthlyInHand   Float    @default(0.0)
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  user            User     @relation(fields: [userId], references: [id], onDelete: Cascade)
}

// 2. Family Members Table
model FamilyMember {
  id                      String   @id @default(cuid())
  userId                  String
  name                    String
  relationship            String
  age                     Int
  isDependent             Boolean  @default(false)
  medicalInsuranceCovered Boolean  @default(false)
  notes                   String?
  createdAt               DateTime @default(now())
  updatedAt               DateTime @updatedAt
  user                    User     @relation(fields: [userId], references: [id], onDelete: Cascade)
}

// 3. User Guardrail Settings
model BudgetGuardrails {
  id                        String   @id @default(cuid())
  userId                    String   @unique
  warning80Alerts           Boolean  @default(true)
  overspendingBanners       Boolean  @default(true)
  autoSmsDeduction          Boolean  @default(true)
  dailySpendingCap          Float?
  alertThresholdPercentage  Float    @default(80.0)
  createdAt                 DateTime @default(now())
  updatedAt                 DateTime @updatedAt
  user                      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

---

## 9. Implementation Checklist

- [ ] **Step 1 (Profile Module)**: Deploy `PUT /profile/employment`, `GET/POST/DELETE /profile/family-members`, and `PUT /profile/household` on Render.
- [ ] **Step 2 (Auth Module)**: Configure MSG91/Twilio credentials and TRAI DLT templates for live SMS dispatch.
- [ ] **Step 3 (Income Module)**: Connect AWS S3 bucket to `POST /income/proof-upload`.
- [ ] **Step 4 (Expense Module)**: Connect Vision OCR API to `POST /expenses/receipt-upload`.
- [ ] **Step 5 (Budget Module)**: Deploy `PUT /budgets/settings/guardrails` with `BudgetGuardrails` database table.
- [ ] **Step 6 (Bank Aggregation)**: Wire production AA FIP webhook `/consents/callback` with Setu/Finvu.

