# BACKEND API REQUIREMENTS
## Authentication, Onboarding, KYC & User Profile Module — Flutter Consumer App (Finomos)

**Document Version**: 1.0 (Production Ready)  
**Target Platform**: Finomos Flutter Mobile App (`lib/features/auth_kyc/` & `lib/features/profile/`)  
**Base URL**: `https://finmos-user.onrender.com`  
**Authentication**: Bearer JWT (`Authorization: Bearer <token>` returned on `/api/auth/login` and `/api/auth/verify-otp`)  
**Standard Header**: `Content-Type: application/json`, `Accept: application/json`

---

## 1. Executive Summary & Architecture

The **Authentication, Onboarding, KYC & Profile Module** is the foundational identity gateway of the Finomos personal CFO and account aggregation ecosystem. It governs user identity verification, multi-factor authentication (SMS/Email OTP), regulatory KYC compliance (PAN & Aadhaar document submission), DPDP Act 2023 statutory consent logging, and continuous user profile management.

### 1.1 The Two Primary Journeys

```
                                      ┌─────────────────────────────────────────────────────────┐
                                      │              FINOMOS IDENTITY GATEWAY                   │
                                      └────────────────────────────┬────────────────────────────┘
                                                                   │
                                     ┌─────────────────────────────┴────────────────────────────┐
                                     ▼                                                          ▼
                        ┌───────────────────────────┐                             ┌───────────────────────────┐
                        │   EXISTING USER JOURNEY   │                             │   NEW ONBOARDING JOURNEY  │
                        └─────────────┬─────────────┘                             └─────────────┬─────────────┘
                                      │                                                         │
                ┌─────────────────────┴─────────────────────┐                     ┌─────────────┴─────────────┐
                ▼                                           ▼                     ▼                           │
    ┌───────────────────────┐                   ┌───────────────────────┐  [Step 1: Sign Up]                  │
    │  Mobile OTP Login     │                   │  Email & Password     │  POST /api/auth/signup              │
    │  POST /send-otp       │                   │  POST /login          │  POST /verify-otp                   │
    │  POST /verify-otp     │                   └───────────┬───────────┘         │                           │
    └───────────┬───────────┘                               │                     ▼                           │
                │                                           │              [Step 2: User Details]             │
                └─────────────────────┬─────────────────────┘              PUT /onboarding/user-details       │
                                      ▼                                           │                           │
                        ┌───────────────────────────┐                             ▼                           │
                        │   JWT TOKEN ISSUANCE      │                      [Step 3: KYC Documents]            │
                        │   Bearer Token + Session  │                      POST /kyc/upload (PAN/Aadhaar)     │
                        └─────────────┬─────────────┘                             │                           │
                                      │                                           ▼                           │
                                      ▼                                    [Step 4: Statutory Consents]       │
                        ┌───────────────────────────┐                      POST /onboarding/consent           │
                        │   FINOMOS HOME DASHBOARD  │                             │                           │
                        │   /dashboard              │                             ▼                           │
                        └───────────────────────────┘                      [Step 5: Privacy Policy]           │
                                                                           POST /onboarding/privacy           │
                                                                                  │                           │
                                                                                  ▼                           │
                                                                           [Step 6: KYC Status Timeline]      │
                                                                           GET /api/v1/kyc/status             │
                                                                                  │                           │
                                                                                  ▼                           │
                                                                           ┌───────────────────────────┐      │
                                                                           │   FINOMOS HOME DASHBOARD  │◄─────┘
                                                                           │   /dashboard              │
                                                                           └───────────────────────────┘
```

---

## 2. Complete API Endpoint Inventory (24 Endpoints)

| # | Endpoint | Method | Purpose / Screen Reference | Auth Required |
|---|---|---|---|---|
| **A** | **Authentication & Session** | | | |
| 1 | `/api/auth/login` | `POST` | Dual-mode login (Email or Mobile + Password) | No |
| 2 | `/api/auth/send-otp` | `POST` | Dispatch 6-digit OTP to Mobile or Email | No |
| 3 | `/api/auth/verify-otp` | `POST` | Validate 6-digit OTP for Mobile login or Signup | No |
| 4 | `/api/auth/refresh-token` | `POST` | Exchange refresh token for fresh short-lived JWT | Refresh Token |
| 5 | `/api/auth/logout` | `POST` | Invalidate current session and revoke refresh token | Yes (Bearer) |
| 6 | `/api/auth/forgot-password/request` | `POST` | Request password reset OTP to Email/SMS | No |
| 7 | `/api/auth/forgot-password/reset` | `POST` | Verify reset OTP and commit new password | No |
| **B** | **Registration & Onboarding Funnel** | | | |
| 8 | `/api/auth/signup` | `POST` | Step 1: Create baseline user record | No |
| 9 | `/api/auth/signup/verify-email` | `POST` | Step 1: Verify email address via 6-digit OTP | No |
| 10 | `/api/auth/signup/verify-mobile` | `POST` | Step 1: Verify phone number via SMS OTP | No |
| 11 | `/api/auth/onboarding/user-details` | `PUT` | Step 2: Save DOB, Gender, Address, State, PIN | Yes (Bearer) |
| 12 | `/api/auth/onboarding/kyc-documents` | `POST` | Step 3: Attach PAN/Aadhaar document metadata | Yes (Bearer) |
| 13 | `/api/auth/onboarding/consent` | `POST` | Step 4 & 5: Record DPDP Act 2023 consents | Yes (Bearer) |
| **C** | **KYC Verification & Document Storage** | | | |
| 14 | `/api/v1/kyc/status` | `GET` | Step 6: Fetch verification progress timeline & status | Yes (Bearer) |
| 15 | `/api/v1/kyc/documents` | `GET` | Retrieve list of submitted KYC documents & status | Yes (Bearer) |
| 16 | `/api/v1/kyc/upload` | `POST` | Multipart upload for PAN, Aadhaar, Passport | Yes (Bearer) |
| 17 | `/api/v1/kyc/re-verify` | `POST` | Trigger instant re-verification on rejected docs | Yes (Bearer) |
| **D** | **User Profile Management** | | | |
| 18 | `/api/v1/user/profile` | `GET` | Fetch complete profile, KYC badge & account stats | Yes (Bearer) |
| 19 | `/api/v1/user/profile/personal` | `PUT` | Update personal details (Full name, DOB, Gender) | Yes (Bearer) |
| 20 | `/api/v1/user/profile/address` | `PUT` | Update residential address, City, State, PIN | Yes (Bearer) |
| 21 | `/api/v1/user/profile/photo` | `POST` | Multipart upload for user avatar photo | Yes (Bearer) |
| 22 | `/api/v1/user/profile/security` | `PUT` | Change password, toggle 2FA & biometric auth | Yes (Bearer) |
| 23 | `/api/v1/user/profile/notifications` | `PUT` | Update WhatsApp, SMS, Email notification flags | Yes (Bearer) |
| 24 | `/api/v1/user/account` | `DELETE` | Deactivate account / DPDP Act right to erasure | Yes (Bearer) |

---

## 3. Detailed Endpoint Specifications

### Group A: Authentication & Session

#### Endpoint 1: Dual-Mode Login
* **URL**: `/api/auth/login`
* **Method**: `POST`
* **Current App Implementation**: [`AuthApiService.login()`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/services/auth_api_service.dart#L28-L75)
* **Request Headers**: `Content-Type: application/json`
* **Request Payload**:
  ```json
  {
    "identifier": "sireesha@gmail.com",
    "password": "Sireesha@123"
  }
  ```
  *(Note: `identifier` can be either a registered email address or a 10-digit/12-digit Indian mobile number like `9876543210` or `+919876543210`)*
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Login successful",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjbXV6aHhpNWEwMDBhc3I0cDlmNmpjbmRwIiwiaWF0IjoxNzkzMzU2ODAwfQ.abc123token",
    "refreshToken": "ref_98a76bc45e12f0",
    "expiresIn": 86400,
    "user": {
      "id": "cmuzhxi5a000asr4p9f6jcndp",
      "name": "Sireesha Bandaru",
      "email": "sireesha@gmail.com",
      "phone": "+91 98765 43210",
      "kycStatus": "VERIFIED",
      "avatarUrl": "https://finmos-user.onrender.com/uploads/avatars/sireesha.jpg"
    }
  }
  ```
* **Failure Responses**:
  * `401 Unauthorized`: `{"success": false, "message": "Invalid credentials. Please verify your email/phone and password."}`
  * `403 Forbidden`: `{"success": false, "message": "Account suspended. Please contact compliance support."}`

---

#### Endpoint 2: Send OTP
* **URL**: `/api/auth/send-otp`
* **Method**: `POST`
* **Purpose**: Dispatches a secure 6-digit numeric OTP to the recipient's SMS gateway or Email SMTP.
* **Request Payload**:
  ```json
  {
    "identifier": "+91 98765 43210",
    "channel": "SMS",
    "purpose": "LOGIN"
  }
  ```
  * `channel`: `"SMS"` or `"EMAIL"`
  * `purpose`: `"LOGIN"`, `"SIGNUP"`, `"FORGOT_PASSWORD"`, or `"KYC_VERIFICATION"`
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "6-digit OTP has been sent successfully",
    "retryAfterSeconds": 30,
    "expiresInSeconds": 600
  }
  ```
* **Failure Responses**:
  * `429 Too Many Requests`: `{"success": false, "message": "Too many OTP requests. Please wait 30 seconds."}`

---

#### Endpoint 3: Verify OTP
* **URL**: `/api/auth/verify-otp`
* **Method**: `POST`
* **Request Payload**:
  ```json
  {
    "identifier": "+91 98765 43210",
    "otp": "428619",
    "purpose": "LOGIN"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "OTP verified successfully",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "ref_87d9a3028",
    "user": {
      "id": "cmuzhxi5a000asr4p9f6jcndp",
      "name": "Sireesha Bandaru",
      "email": "sireesha@gmail.com",
      "phone": "+91 98765 43210",
      "kycStatus": "VERIFIED"
    }
  }
  ```
* **Failure Responses**:
  * `400 Bad Request`: `{"success": false, "message": "Invalid or expired OTP. Please try again."}`

---

#### Endpoint 4: Refresh JWT Token
* **URL**: `/api/auth/refresh-token`
* **Method**: `POST`
* **Request Payload**:
  ```json
  {
    "refreshToken": "ref_98a76bc45e12f0"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.new_jwt_payload...",
    "expiresIn": 86400
  }
  ```

---

#### Endpoint 5: Logout
* **URL**: `/api/auth/logout`
* **Method**: `POST`
* **Headers**: `Authorization: Bearer <token>`
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "User session invalidated successfully"
  }
  ```

---

#### Endpoint 6: Forgot Password Request
* **URL**: `/api/auth/forgot-password/request`
* **Method**: `POST`
* **Request Payload**:
  ```json
  {
    "identifier": "sireesha@gmail.com"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Password reset OTP sent to sireesha@gmail.com",
    "retryAfterSeconds": 30
  }
  ```

---

#### Endpoint 7: Forgot Password Reset
* **URL**: `/api/auth/forgot-password/reset`
* **Method**: `POST`
* **Request Payload**:
  ```json
  {
    "identifier": "sireesha@gmail.com",
    "otp": "428619",
    "newPassword": "Sireesha@NewPassword2026"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Password updated successfully. You can now login with your new credentials."
  }
  ```

---

### Group B: Registration & Onboarding Funnel

#### Endpoint 8: Step 1 Sign Up
* **URL**: `/api/auth/signup`
* **Method**: `POST`
* **App Reference**: [`SignUpScreen`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/presentation/sign_up_screen.dart)
* **Request Payload**:
  ```json
  {
    "fullName": "Sireesha Bandaru",
    "email": "sireesha@gmail.com",
    "mobileNumber": "+91 98765 43210",
    "password": "Sireesha@123"
  }
  ```
* **Success Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Registration initiated. Verification OTPs sent to email and phone.",
    "userId": "cmuzhxi5a000asr4p9f6jcndp",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "onboardingStep": 2
  }
  ```
* **Failure Responses**:
  * `409 Conflict`: `{"success": false, "message": "An account with this email or mobile number already exists."}`

---

#### Endpoint 9: Send & Verify Email OTP
* **URL (Send Email OTP)**: `/api/auth/signup/send-email-otp`
* **Method**: `POST`
* **App Reference**: [`SignUpScreen._verifyEmail()`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/presentation/sign_up_screen.dart#L96-L141)
* **Request Payload**:
  ```json
  {
    "email": "sireesha@gmail.com",
    "fullName": "Sireesha Bandaru"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "6-digit email verification code sent to sireesha@gmail.com",
    "retryAfterSeconds": 30,
    "expiresInSeconds": 600
  }
  ```

* **URL (Verify Email OTP)**: `/api/auth/signup/verify-email`
* **Method**: `POST`
* **Request Payload**:
  ```json
  {
    "email": "sireesha@gmail.com",
    "otp": "428619"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "isEmailVerified": true,
    "message": "Email ID verified successfully!",
    "verifiedAt": "2026-10-30T10:55:00.000Z"
  }
  ```
* **Failure Responses**:
  * `400 Bad Request`: `{"success": false, "message": "Invalid or expired email OTP code. Please request a new one."}`

---

#### Endpoint 10: Send & Verify Mobile SMS OTP
* **URL (Send Mobile OTP)**: `/api/auth/signup/send-mobile-otp`
* **Method**: `POST`
* **App Reference**: [`SignUpScreen._resendOtp()`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/presentation/sign_up_screen.dart#L143-L181)
* **Request Payload**:
  ```json
  {
    "mobileNumber": "+91 98765 43210"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "6-digit OTP sent to +91 98765 43210",
    "retryAfterSeconds": 30,
    "expiresInSeconds": 600
  }
  ```

* **URL (Verify Mobile OTP)**: `/api/auth/signup/verify-mobile`
* **Method**: `POST`
* **App Reference**: [`SignUpScreen._verifyMobileOtp()`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/presentation/sign_up_screen.dart#L183-L228)
* **Request Payload**:
  ```json
  {
    "mobileNumber": "+91 98765 43210",
    "otp": "428619"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "isMobileVerified": true,
    "message": "Mobile number verified successfully!",
    "proceedToStep2": true
  }
  ```
* **Failure Responses**:
  * `400 Bad Request`: `{"success": false, "message": "Invalid or expired mobile OTP. Please try again."}`

---

#### Endpoint 11: Step 2 User Details
* **URL**: `/api/auth/onboarding/user-details`
* **Method**: `PUT`
* **Headers**: `Authorization: Bearer <token>`
* **App Reference**: [`UserDetailsScreen`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/presentation/user_details_screen.dart)
* **Request Payload**:
  ```json
  {
    "fullName": "Sireesha Bandaru",
    "dob": "1995-08-15",
    "gender": "Female",
    "address": "101, Tech Park Avenue, Hitech City",
    "city": "Hyderabad",
    "state": "Telangana",
    "pinCode": "500081"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "User details saved successfully",
    "onboardingStep": 3,
    "data": {
      "fullName": "Sireesha Bandaru",
      "dob": "1995-08-15",
      "gender": "Female",
      "address": "101, Tech Park Avenue, Hitech City",
      "city": "Hyderabad",
      "state": "Telangana",
      "pinCode": "500081"
    }
  }
  ```

---

#### Endpoint 12: Step 3 KYC Document Records
* **URL**: `/api/auth/onboarding/kyc-documents`
* **Method**: `POST`
* **Headers**: `Authorization: Bearer <token>`
* **App Reference**: [`KycDetailsScreen`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/presentation/kyc_details_screen.dart)
* **Request Payload**:
  ```json
  {
    "panNumber": "ABCDE1234F",
    "documents": [
      {
        "idType": "PAN Card",
        "idNumber": "ABCDE1234F",
        "fileName": "PAN_Card_Sireesha.pdf",
        "fileUrl": "//opt/render/project/src/backend/uploads/pan_sireesha_179334866.pdf",
        "fileSizeBytes": 1887436,
        "isUploaded": true
      },
      {
        "idType": "Aadhaar Card",
        "idNumber": "•••• •••• 5678",
        "fileName": "Aadhaar_Card_Sireesha.pdf",
        "fileUrl": "//opt/render/project/src/backend/uploads/aadhaar_sireesha_179334867.pdf",
        "fileSizeBytes": 2516582,
        "isUploaded": true
      }
    ]
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "KYC identity documents submitted for automated verification",
    "onboardingStep": 4,
    "verificationStatus": "IN_PROGRESS"
  }
  ```

---

#### Endpoint 13: Step 4 & 5 Consents & Privacy Acceptance
* **URL**: `/api/auth/onboarding/consent`
* **Method**: `POST`
* **Headers**: `Authorization: Bearer <token>`
* **App References**: [`ConsentScreen`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/presentation/consent_screen.dart) & [`PrivacyPolicyScreen`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/presentation/privacy_policy_screen.dart)
* **Request Payload**:
  ```json
  {
    "consentProcessing": true,
    "consentSharing": true,
    "consentTermsPrivacy": true,
    "agreeTerms": true,
    "agreePrivacy": true,
    "policyVersion": "v2026.10-RBI-DPDP",
    "ipAddress": "49.205.142.88",
    "deviceUserAgent": "Finomos-Android/2.0 (Build 14; Vivo I2221)"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Statutory consents logged per Section 65B Indian Evidence Act & DPDP Act 2023",
    "onboardingStep": 6,
    "consentLogId": "CONS-DPDP-2026-98124"
  }
  ```

---

### Group C: KYC Verification & Document Storage

#### Endpoint 14: Step 6 KYC Verification Status
* **URL**: `/api/v1/kyc/status`
* **Method**: `GET`
* **Headers**: `Authorization: Bearer <token>`
* **App Reference**: [`KycStatusScreen`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/presentation/kyc_status_screen.dart)
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "data": {
      "kycStatus": "VERIFIED",
      "statusBadge": "Verified",
      "statusColor": "#10B981",
      "verificationMethod": "RBI Account Aggregator & NSDL/UIDAI Pan-Aadhaar Link",
      "registrationCompletedTime": "30 Oct 2026, 12:00 PM",
      "kycSubmittedTime": "30 Oct 2026, 12:30 PM",
      "kycVerifiedTime": "30 Oct 2026, 12:32 PM",
      "panNumber": "ABCDE1234F",
      "panMasked": "ABCDE••••F",
      "aadhaarMasked": "•••• •••• 5678",
      "timeline": [
        {
          "step": 1,
          "title": "Registration Completed",
          "subtitle": "30 Oct 2026, 12:00 PM",
          "isCompleted": true
        },
        {
          "step": 2,
          "title": "Email & Phone OTP Verification",
          "subtitle": "30 Oct 2026, 12:05 PM",
          "isCompleted": true
        },
        {
          "step": 3,
          "title": "KYC Documents Uploaded",
          "subtitle": "30 Oct 2026, 12:30 PM",
          "isCompleted": true
        },
        {
          "step": 4,
          "title": "AA Automated Identity Match",
          "subtitle": "30 Oct 2026, 12:32 PM",
          "isCompleted": true
        }
      ]
    }
  }
  ```

---

#### Endpoint 16: KYC File Multipart Upload
* **URL**: `/api/v1/kyc/upload`
* **Method**: `POST`
* **Headers**: `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Form-Data Parameters**:
  * `documentType`: `"PAN Card"` | `"Aadhaar Card"` | `"Passport"` | `"Driving License"`
  * `idNumber`: Document identification string (e.g. `ABCDE1234F`)
  * `file`: Binary file (`.pdf`, `.png`, `.jpg`, `.jpeg`, max 10MB)
* **Success Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "data": {
      "documentId": "kyc_doc_983141",
      "documentType": "PAN Card",
      "documentName": "PAN_Card_Sireesha.pdf",
      "documentPath": "//opt/render/project/src/backend/uploads/17933568912-PAN_Card_Sireesha.pdf",
      "fileSizeBytes": 1887436,
      "mimeType": "application/pdf",
      "sha256": "4a7d1ed414474e4033ac29ccb8653d9b",
      "uploadedAt": "2026-10-30T10:45:00.000Z"
    }
  }
  ```

---

### Group D: User Profile Management

#### Endpoint 18: Get Complete User Profile
* **URL**: `/api/v1/user/profile`
* **Method**: `GET`
* **Headers**: `Authorization: Bearer <token>`
* **App Reference**: [`ProfileScreen`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/auth_kyc/presentation/profile_screen.dart)
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "cmuzhxi5a000asr4p9f6jcndp",
      "fullName": "Sireesha Bandaru",
      "email": "sireesha@gmail.com",
      "mobileNumber": "+91 98765 43210",
      "dob": "1995-08-15",
      "gender": "Female",
      "panNumber": "ABCDE1234F",
      "address": "101, Tech Park Avenue, Hitech City",
      "city": "Hyderabad",
      "state": "Telangana",
      "pinCode": "500081",
      "avatarUrl": "https://finmos-user.onrender.com/uploads/avatars/sireesha.jpg",
      "kycStatus": "VERIFIED",
      "accountStats": {
        "connectedBanks": 4,
        "vaultDocuments": 7,
        "monthlyInflow": 158041,
        "monthlyOutflow": 8999
      },
      "security": {
        "twoFactorEnabled": true,
        "biometricsEnabled": true,
        "lastPasswordChange": "2026-10-15T08:00:00Z"
      },
      "notifications": {
        "whatsappAlerts": true,
        "smsAlerts": true,
        "emailDigest": true
      }
    }
  }
  ```

---

#### Endpoint 21: Upload User Avatar Photo
* **URL**: `/api/v1/user/profile/photo`
* **Method**: `POST`
* **Headers**: `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Form-Data Parameter**:
  * `photo`: Image file (`.jpg`, `.png`, `.webp`, max 5MB)
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Avatar photo updated successfully",
    "avatarUrl": "https://finmos-user.onrender.com/uploads/avatars/sireesha_updated.jpg"
  }
  ```

---

#### Endpoint 24: Account Deletion (DPDP Act Compliance)
* **URL**: `/api/v1/user/account`
* **Method**: `DELETE`
* **Headers**: `Authorization: Bearer <token>`
* **Request Payload**:
  ```json
  {
    "password": "Sireesha@123",
    "reason": "Personal decision / switching platforms"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Account scheduled for permanent erasure per DPDP Act 2023 30-day grace period."
  }
  ```

---

## 4. Frontend Validation & Regulatory Rules

To prevent 400 Bad Request errors, the backend validation rules must strictly mirror the frontend validators in [`lib/core/utils/validators.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/core/utils/validators.dart):

| Field | Frontend Regex / Rule | Backend Validation Rule |
|---|---|---|
| **Full Name** | `r"^[a-zA-Z\s.'-]+$"` (min 3 chars) | Non-empty string, min 3 chars, letters and spaces only |
| **Email** | `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$` | RFC 5322 compliant email string, unique in database |
| **Mobile Number** | `^[6-9]\d{9}$` (10 digits) or `+91` prefix (12 digits) | E.164 format or 10-digit Indian standard starting 6, 7, 8, or 9 |
| **Password** | Non-empty, min 6 characters | Min 6 chars (bcrypt/Argon2 hash stored in DB) |
| **6-Digit OTP** | `^\d{6}$` | Numeric 6 digits, 10-minute expiry, max 5 attempts |
| **PAN Number** | `^[A-Z]{5}[0-9]{4}[A-Z]{1}$` | 10 alphanumeric characters (5 letters, 4 digits, 1 letter) |
| **Indian PIN Code**| `^[1-9][0-9]{5}$` | 6-digit numeric starting with non-zero digit |
| **Aadhaar Masking**| Mask first 8 digits: `•••• •••• 5678` | Only store last 4 digits unmasked in DB per UIDAI regulations |

---

## 5. PostgreSQL Database Schema (DDL)

```sql
-- 1. Core Users Table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url TEXT DEFAULT '',
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_mobile_verified BOOLEAN DEFAULT FALSE,
    kyc_status VARCHAR(20) DEFAULT 'PENDING' CHECK (kyc_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. User Profiles Extended Table
CREATE TABLE IF NOT EXISTS user_profiles (
    user_id VARCHAR(36) PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    dob DATE,
    gender VARCHAR(15) CHECK (gender IN ('Female', 'Male', 'Other')),
    pan_number VARCHAR(10),
    address TEXT,
    city VARCHAR(80),
    state VARCHAR(80),
    pin_code VARCHAR(10),
    occupation VARCHAR(80) DEFAULT 'Private Sector Employee',
    annual_income NUMERIC(15,2) DEFAULT 1896492.00,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. KYC Identity Documents Table
CREATE TABLE IF NOT EXISTS kyc_documents (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    id_type VARCHAR(50) NOT NULL CHECK (id_type IN ('PAN Card', 'Aadhaar Card', 'Passport', 'Driving License', 'Voter ID', 'Other Govt ID')),
    id_number VARCHAR(80) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    mime_type VARCHAR(80) NOT NULL,
    sha256_hash VARCHAR(64),
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Statutory Consent Logs Table (DPDP Act 2023 & RBI AA)
CREATE TABLE IF NOT EXISTS user_consents (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    consent_processing BOOLEAN NOT NULL DEFAULT TRUE,
    consent_sharing BOOLEAN NOT NULL DEFAULT TRUE,
    agree_terms BOOLEAN NOT NULL DEFAULT TRUE,
    agree_privacy BOOLEAN NOT NULL DEFAULT TRUE,
    policy_version VARCHAR(40) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. One-Time Passwords (OTP) Table
CREATE TABLE IF NOT EXISTS auth_otps (
    id SERIAL PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    purpose VARCHAR(30) NOT NULL,
    attempts INT DEFAULT 0,
    is_used BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_auth_otps_lookup ON auth_otps(identifier, purpose, is_used);
```

---

## 6. Seed Data Script for Live User Sireesha Bandaru

To ensure continuous seamless testing across all modules for demo user `cmuzhxi5a000asr4p9f6jcndp`:

```sql
-- Insert Core User (Password: Sireesha@123 hashed via bcrypt)
INSERT INTO users (id, full_name, email, phone, password_hash, avatar_url, kyc_status, is_active)
VALUES (
    'cmuzhxi5a000asr4p9f6jcndp',
    'Sireesha Bandaru',
    'sireesha@gmail.com',
    '+91 98765 43210',
    '$2b$12$e8YkC84T07O7k5v4F6G7AeQ7gXF3x2Kj/W5K.3m4rU8d29yHn9Ere', -- Sireesha@123
    'https://finmos-user.onrender.com/uploads/avatars/sireesha.jpg',
    'VERIFIED',
    TRUE
) ON CONFLICT (id) DO UPDATE SET 
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    kyc_status = EXCLUDED.kyc_status;

-- Insert User Profile
INSERT INTO user_profiles (user_id, dob, gender, pan_number, address, city, state, pin_code, occupation, annual_income)
VALUES (
    'cmuzhxi5a000asr4p9f6jcndp',
    '1995-08-15',
    'Female',
    'ABCDE1234F',
    '101, Tech Park Avenue, Hitech City',
    'Hyderabad',
    'Telangana',
    '500081',
    'Lead Software Engineer',
    1896492.00
) ON CONFLICT (user_id) DO UPDATE SET 
    address = EXCLUDED.address,
    city = EXCLUDED.city,
    state = EXCLUDED.state,
    pin_code = EXCLUDED.pin_code;

-- Insert KYC Documents
INSERT INTO kyc_documents (id, user_id, id_type, id_number, file_name, file_path, file_size_bytes, mime_type, is_verified, verified_at)
VALUES 
(
    'kyc_pan_1',
    'cmuzhxi5a000asr4p9f6jcndp',
    'PAN Card',
    'ABCDE1234F',
    'PAN_Card_Sireesha.pdf',
    '//opt/render/project/src/backend/uploads/1793349618863-PAN_Card_Sireesha.pdf',
    1887436,
    'application/pdf',
    TRUE,
    '2026-10-30 12:32:00+05:30'
),
(
    'kyc_aadhaar_2',
    'cmuzhxi5a000asr4p9f6jcndp',
    'Aadhaar Card',
    '•••• •••• 5678',
    'Aadhaar_Card_Sireesha.pdf',
    '//opt/render/project/src/backend/uploads/1793349618864-Aadhaar_Card_Sireesha.pdf',
    2516582,
    'application/pdf',
    TRUE,
    '2026-10-30 12:32:00+05:30'
) ON CONFLICT (id) DO NOTHING;

-- Insert Statutory Consents
INSERT INTO user_consents (id, user_id, consent_processing, consent_sharing, agree_terms, agree_privacy, policy_version, ip_address)
VALUES (
    'CONS-DPDP-2026-98124',
    'cmuzhxi5a000asr4p9f6jcndp',
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    'v2026.10-RBI-DPDP',
    '49.205.142.88'
) ON CONFLICT (id) DO NOTHING;
```

---

## 7. Postman & cURL Testing Guide

### 7.1 Testing Dual-Mode Login via cURL
```bash
curl -X POST "https://finmos-user.onrender.com/api/auth/login" \
     -H "Content-Type: application/json" \
     -d '{
       "identifier": "sireesha@gmail.com",
       "password": "Sireesha@123"
     }'
```

### 7.2 Testing KYC Status Retrieval via cURL
```bash
curl -X GET "https://finmos-user.onrender.com/api/v1/kyc/status" \
     -H "Authorization: Bearer <your_jwt_token_here>" \
     -H "Accept: application/json"
```

### 7.3 Testing Profile Details via cURL
```bash
curl -X GET "https://finmos-user.onrender.com/api/v1/user/profile" \
     -H "Authorization: Bearer <your_jwt_token_here>" \
     -H "Accept: application/json"
```

---

## 8. Summary Checklist for Backend Engineering Team

- [ ] Implement dual-identifier lookup in `/api/auth/login` (accepts either email or mobile number).
- [ ] Configure SMS and SMTP gateway triggers for 6-digit OTP delivery in `/api/auth/send-otp`.
- [ ] Ensure JWT token returns standard expiration (`expiresIn: 86400`) and standard refresh token tokenomics.
- [ ] Implement multipart/form-data upload handler with SHA-256 legal hash calculation in `/api/v1/kyc/upload`.
- [ ] Run the provided PostgreSQL DDL script to generate `users`, `user_profiles`, `kyc_documents`, and `user_consents`.
- [ ] Execute the seed data script for user `cmuzhxi5a000asr4p9f6jcndp` to match live demo accounts.
- [ ] Enable CORS headers: `Access-Control-Allow-Origin: *`, `Access-Control-Allow-Headers: Authorization, Content-Type`.

