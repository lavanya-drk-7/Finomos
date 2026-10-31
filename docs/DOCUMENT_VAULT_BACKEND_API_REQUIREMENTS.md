# BACKEND API REQUIREMENTS
## Document Vault & Section 65B Digital Locker Engine — Flutter Consumer App (Finomos)

**Document Version**: 1.0 (Production Ready)  
**Target Platform**: Finomos Flutter Mobile App (`lib/features/document_vault/`)  
**Base URL**: `https://finmos-user.onrender.com`  
**Authentication**: Bearer JWT (`Authorization: Bearer <token>` from `/api/auth/login`)  
**Compliance Standards**: RBI Digital KYC Master Directions 2024, Section 65B Indian Evidence Act, Information Technology Act 2000, AES-256 at Rest

---

## 1. Executive Summary & Module Architecture

The **Document Vault Module** serves as the user's sovereign, cryptographically secure digital financial locker. It stores, organizes, and verifies all essential financial, tax, identification, and legal records:

* **KYC & Identity Proofs**: PAN Card, Aadhaar Card, Passport, Driving License, Voter ID.
* **Banking & Liquidity**: Multibank 6-month statements, cancelled cheques, passbook copies.
* **Tax & Statutory Compliance**: Form 16, ITR-V Ack receipts, AIS/TIS annual statements, Tax Deduction (26AS) slips.
* **Insurance Policies**: Health insurance policy bonds, Term life agreements, Motor comprehensive policies.
* **Investments & Wealth**: Consolidated Account Statements (CAMS / KFintech CAS), Demat holding statements.
* **Cross-Module Linkages**: Automatically ingests and indexes receipts uploaded in **Expense Tracking** and proof vouchers generated in **Income Tracking**.

### Mobile Client File References
* **Presentation Screen**: [`lib/features/document_vault/presentation/document_vault_screen.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/document_vault/presentation/document_vault_screen.dart)
* **Action Helper & Preview Dialog**: [`lib/features/document_vault/presentation/widgets/document_action_helper.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/document_vault/presentation/widgets/document_action_helper.dart)
* **Domain Models**: [`lib/features/document_vault/domain/document_models.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/document_vault/domain/document_models.dart)
* **Riverpod State Provider**: [`lib/features/document_vault/providers/document_provider.dart`](file:///c:/Users/DELL/Desktop/Finomos/lib/features/document_vault/providers/document_provider.dart)

---

## 2. Mathematical Formulas & Storage Accounting Rules

The backend service must maintain strict per-user storage accounting and quota enforcement:

### 2.1 Storage Quota Calculations
$$\text{Storage Used Bytes} = \sum_{d \in \text{activeDocuments}} d.\text{fileSizeBytes}$$
$$\text{Storage Used GB} = \frac{\text{Storage Used Bytes}}{1024 \times 1024 \times 1024}$$
$$\text{Storage Percentage} = \min\left(100.0, \left(\frac{\text{Storage Used GB}}{\text{Storage Limit GB}}\right) \times 100\right)$$
$$\text{Remaining Storage GB} = \max(0.0, \text{Storage Limit GB} - \text{Storage Used GB})$$

* **Default Tier Quota**: `10.0 GB` per user profile.
* **Max File Size Limit**: `25.0 MB` per individual document upload.
* **Allowed MIME Types**: `application/pdf`, `image/jpeg`, `image/png`, `image/webp`.

### 2.2 Human-Readable File Size Display Rules
The backend must return both exact `fileSizeBytes` (integer) and computed `fileSize` (formatted string):
$$\text{fileSize} = \begin{cases} \left(\frac{\text{bytes}}{1024 \times 1024}\right).\text{toFixed(1)} + \text{ " MB"}, & \text{if } \text{bytes} \ge 1024 \times 1024 \\ \left(\frac{\text{bytes}}{1024}\right).\text{toFixed(0)} + \text{ " KB"}, & \text{otherwise} \end{cases}$$

### 2.3 Section 65B Cryptographic Stamping
Every uploaded document must receive an automated SHA-256 tamper-evident cryptographic hash at the time of upload:
$$\text{SHA-256 Hash} = \text{HMAC-SHA256}(\text{fileBytes}, \text{timestamp} + \text{userId})$$
This guarantees admissibility under Section 65B of the Indian Evidence Act for tax audits and loan verifications.

---

## 3. Complete API Inventory Overview

| Category | Method | Endpoint | Description |
|---|---|---|---|
| **Storage & Quota** | `GET` | `/api/v1/vault/storage-summary` | Used GB, limit GB, usage percentage & category counts |
| **Document Management** | `GET` | `/api/v1/vault/documents` | List documents with search, category filter & pagination |
| | `POST` | `/api/v1/vault/documents/upload` | Multipart upload (file + category + ID type + doc number) |
| | `GET` | `/api/v1/vault/documents/:id` | Get single document metadata & cryptographic hash |
| | `PUT` | `/api/v1/vault/documents/:id` | Update document metadata (name, docNumber, expiry) |
| | `PUT` | `/api/v1/vault/documents/:id/replace` | Replace existing file binary with new version |
| | `DELETE` | `/api/v1/vault/documents/:id` | Delete document record and free storage quota |
| | `DELETE` | `/api/v1/vault/documents/:id/file` | Remove uploaded file binary only, keep metadata card |
| **File Download & Preview** | `GET` | `/api/v1/vault/documents/:id/download` | Download binary with Content-Disposition header |
| | `GET` | `/api/v1/vault/documents/:id/preview` | Stream inline binary for in-app preview dialog |
| **Sharing & Expiring Links** | `POST` | `/api/v1/vault/documents/:id/share` | Generate time-limited secure signed share URL |
| | `GET` | `/api/v1/vault/shared/:token` | Public download endpoint for shared document link |
| **Cross-Module Sync** | `POST` | `/api/v1/vault/sync/kyc` | Sync KYC onboarding documents into vault |
| | `GET` | `/api/v1/vault/cross-module/summary` | Aggregate receipts & vouchers from Income & Expense |

---

## 4. Detailed Endpoint Specifications

### 4.1 Storage Quota Summary
#### `GET /api/v1/vault/storage-summary`
Returns the user's storage consumption, quota limits, percentage, and document distribution.

* **Headers**: `Authorization: Bearer <token>`
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": {
    "storageUsedGB": 2.80,
    "storageLimitGB": 10.00,
    "storagePercentage": 28.0,
    "storageUsedBytes": 3006477107,
    "totalDocuments": 6,
    "verifiedDocuments": 6,
    "pendingUploads": 0,
    "categoryBreakdown": [
      { "category": "KYC & ID Proof", "count": 2, "sizeBytes": 3774873, "sizeFormatted": "3.6 MB" },
      { "category": "Tax & ITR", "count": 1, "sizeBytes": 1887436, "sizeFormatted": "1.8 MB" },
      { "category": "Bank Statements", "count": 1, "sizeBytes": 3670016, "sizeFormatted": "3.5 MB" },
      { "category": "Insurance", "count": 1, "sizeBytes": 2306867, "sizeFormatted": "2.2 MB" },
      { "category": "Investment", "count": 1, "sizeBytes": 3040870, "sizeFormatted": "2.9 MB" },
      { "category": "Other", "count": 0, "sizeBytes": 0, "sizeFormatted": "0 KB" }
    ]
  }
}
```

---

### 4.2 List Vault Documents
#### `GET /api/v1/vault/documents`
Retrieves all documents in the user's digital locker with optional category, search, and verification filters.

* **Query Parameters**:
  * `category`: Optional filter (`KYC & ID Proof`, `Bank Statements`, `Tax & ITR`, `Insurance`, `Investment`, `Other`, `All`)
  * `search`: Free text search matching document name, ID number, or category
  * `isVerified`: `true` or `false`
  * `page`: Default `1`
  * `limit`: Default `20`
* **Headers**: `Authorization: Bearer <token>`
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "data": {
    "documents": [
      {
        "id": "kyc_doc_pan",
        "name": "PAN_Card_Sireesha.pdf",
        "category": "KYC & ID Proof",
        "idType": "PAN Card",
        "documentNumber": "ABCDE1234F",
        "fileSize": "1.2 MB",
        "fileSizeBytes": 1258291,
        "uploadDate": "30 Sep 2026",
        "expiryDate": "-",
        "fileUrl": "/api/v1/vault/documents/kyc_doc_pan/download",
        "mimeType": "application/pdf",
        "isUploaded": true,
        "isVerified": true,
        "isFromKyc": true,
        "sha256Hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "complianceStandard": "Section 65B Indian Evidence Act Valid"
      },
      {
        "id": "kyc_doc_aadhaar",
        "name": "Aadhaar_Card_Sireesha.pdf",
        "category": "KYC & ID Proof",
        "idType": "Aadhaar Card",
        "documentNumber": "•••• •••• 5678",
        "fileSize": "2.4 MB",
        "fileSizeBytes": 2516582,
        "uploadDate": "30 Sep 2026",
        "expiryDate": "-",
        "fileUrl": "/api/v1/vault/documents/kyc_doc_aadhaar/download",
        "mimeType": "application/pdf",
        "isUploaded": true,
        "isVerified": true,
        "isFromKyc": true,
        "sha256Hash": "f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2",
        "complianceStandard": "UIDAI Masked Aadhaar Guidelines Compliant"
      },
      {
        "id": "tax_doc_form16",
        "name": "Form_16_FY2025_26.pdf",
        "category": "Tax & ITR",
        "idType": "Form 16",
        "documentNumber": "TCS-FY2025-26",
        "fileSize": "1.8 MB",
        "fileSizeBytes": 1887436,
        "uploadDate": "15 Jul 2026",
        "expiryDate": "-",
        "fileUrl": "/api/v1/vault/documents/tax_doc_form16/download",
        "mimeType": "application/pdf",
        "isUploaded": true,
        "isVerified": true,
        "isFromKyc": false,
        "sha256Hash": "38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da",
        "complianceStandard": "Section 65B Indian Evidence Act Valid"
      },
      {
        "id": "bank_doc_stmt",
        "name": "HDFC_Bank_Statement_6M.pdf",
        "category": "Bank Statements",
        "idType": "Bank Statement",
        "documentNumber": "A/C ••••4587",
        "fileSize": "3.5 MB",
        "fileSizeBytes": 3670016,
        "uploadDate": "01 Oct 2026",
        "expiryDate": "-",
        "fileUrl": "/api/v1/vault/documents/bank_doc_stmt/download",
        "mimeType": "application/pdf",
        "isUploaded": true,
        "isVerified": true,
        "isFromKyc": false,
        "sha256Hash": "a6c5f7823e20e8b2b1a13e2f5b4d7c9a123e456f789a012b345c678d901e234f",
        "complianceStandard": "RBI Account Aggregator Validated"
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

### 4.3 Upload New Document
#### `POST /api/v1/vault/documents/upload`
Uploads a document via multipart/form-data. Computes file size, MIME type, and cryptographic SHA-256 hash.

* **Headers**: `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Form Fields**:
  * `file`: Binary file (`PDF`, `JPG`, `PNG`, `WEBP`) *(required)*
  * `name`: Custom file name *(optional; defaults to client file name)*
  * `category`: `KYC & ID Proof`, `Bank Statements`, `Insurance`, `Tax & ITR`, `Investment`, `Other` *(required)*
  * `idType`: `PAN Card`, `Aadhaar Card`, `Passport`, `Driving License`, `Bank Statement`, `Form 16`, `Insurance Policy`, etc. *(required)*
  * `documentNumber`: Identifier number on document (e.g. `ABCDE1234F`) *(optional)*
  * `expiryDate`: Expiry string or `-` *(optional)*
* **Success Response (`201 Created`)**:
```json
{
  "success": true,
  "message": "Document uploaded and verified successfully",
  "data": {
    "id": "vault_doc_179335600",
    "name": "Vehicle_Insurance_Policy.pdf",
    "category": "Insurance",
    "idType": "Vehicle Insurance",
    "documentNumber": "MARUTI-POL-9921",
    "fileSize": "1.4 MB",
    "fileSizeBytes": 1468006,
    "uploadDate": "30 Oct 2026",
    "expiryDate": "05 Jan 2027",
    "fileUrl": "/api/v1/vault/documents/vault_doc_179335600/download",
    "mimeType": "application/pdf",
    "isUploaded": true,
    "isVerified": true,
    "isFromKyc": false,
    "sha256Hash": "7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069",
    "complianceStandard": "Section 65B Indian Evidence Act Valid"
  }
}
```

---

### 4.4 Update Document Metadata
#### `PUT /api/v1/vault/documents/:id`
Updates document title, ID number, category, or expiry date without re-uploading the file.

* **Request Body**:
```json
{
  "name": "PAN_Card_Sireesha_Verified.pdf",
  "documentNumber": "ABCDE1234F",
  "expiryDate": "-"
}
```
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Document metadata updated successfully",
  "data": {
    "id": "kyc_doc_pan",
    "name": "PAN_Card_Sireesha_Verified.pdf",
    "documentNumber": "ABCDE1234F",
    "expiryDate": "-"
  }
}
```

---

### 4.5 Replace Document Binary
#### `PUT /api/v1/vault/documents/:id/replace`
Overwrites the underlying file binary with an updated file version while preserving the record's ID, metadata history, and audit log.

* **Headers**: `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Form Fields**: `file` (Binary file)
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Document binary replaced successfully",
  "data": {
    "id": "kyc_doc_pan",
    "name": "PAN_Card_Sireesha_Updated.pdf",
    "fileSize": "1.3 MB",
    "fileSizeBytes": 1363148,
    "uploadDate": "Today",
    "sha256Hash": "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92"
  }
}
```

---

### 4.6 Delete Document
#### `DELETE /api/v1/vault/documents/:id`
Permanently deletes the document record, deletes the file from cloud storage, and decrements the user's storage quota.

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Document deleted and storage freed successfully",
  "data": {
    "deletedDocumentId": "vault_doc_179335600",
    "freedSizeBytes": 1468006,
    "updatedStorageUsedGB": 2.78
  }
}
```

---

### 4.7 Delete Uploaded File Only
#### `DELETE /api/v1/vault/documents/:id/file`
Removes the uploaded binary from cloud storage and decrements storage quota, but **preserves the metadata card** in the UI with status `isUploaded: false` so the user can easily re-upload the missing proof later.

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "File binary deleted; document placeholder preserved",
  "data": {
    "id": "kyc_doc_pan",
    "isUploaded": false,
    "fileUrl": "",
    "fileSize": "",
    "fileSizeBytes": 0
  }
}
```

---

### 4.8 Download Document Binary
#### `GET /api/v1/vault/documents/:id/download`
Streams the binary file directly to the client with appropriate headers for local downloading.

* **Headers**: `Authorization: Bearer <token>`
* **Response Headers**:
  * `Content-Type`: `application/pdf` (or `image/jpeg` / `image/png`)
  * `Content-Disposition`: `attachment; filename="PAN_Card_Sireesha.pdf"`
  * `Content-Length`: `1258291`
  * `X-Section-65B-Hash`: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
* **Response Body**: Raw binary stream (`200 OK`)

---

### 4.9 Preview Document Binary
#### `GET /api/v1/vault/documents/:id/preview`
Streams the binary file with inline disposition for in-app preview rendering:
* **Response Headers**:
  * `Content-Type`: `application/pdf`
  * `Content-Disposition`: `inline; filename="PAN_Card_Sireesha.pdf"`

---

### 4.10 Generate Time-Limited Secure Share Link
#### `POST /api/v1/vault/documents/:id/share`
Generates a signed, expiring URL to safely share a document with third parties (banks, tax consultants, auditors) without exposing full account access.

* **Request Body**:
```json
{
  "expiresInHours": 24,
  "allowDownload": true,
  "passwordProtected": false
}
```
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Secure share link generated successfully",
  "data": {
    "shareUrl": "https://finmos-user.onrender.com/api/v1/vault/shared/sh_9981245a8f",
    "expiresAt": "2026-10-31T15:30:00.000Z",
    "expiresInHours": 24,
    "accessCount": 0,
    "maxAccess": 5
  }
}
```

---

### 4.11 Auto-Sync KYC Documents
#### `POST /api/v1/vault/sync/kyc`
Invoked upon successful KYC completion or profile updates to ensure all identity proofs (PAN, Aadhaar, Passport) appear seamlessly inside the Document Vault.

* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "KYC documents synchronized with Document Vault",
  "data": {
    "syncedCount": 2,
    "documentIds": ["kyc_doc_pan", "kyc_doc_aadhaar"]
  }
}
```

---

## 5. PostgreSQL Database Schema (Prisma / Supabase DDL)

The backend team can execute the following SQL DDL script to create the database tables:

```sql
-- 1. Vault Documents Table
CREATE TABLE IF NOT EXISTS vault_documents (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(64) NOT NULL DEFAULT 'Other',
    id_type VARCHAR(64) NOT NULL DEFAULT 'Govt ID',
    document_number VARCHAR(128) DEFAULT '',
    file_size VARCHAR(32) NOT NULL DEFAULT '0 KB',
    file_size_bytes BIGINT NOT NULL DEFAULT 0,
    upload_date VARCHAR(64) NOT NULL,
    expiry_date VARCHAR(64) DEFAULT '-',
    file_path VARCHAR(512),
    file_url VARCHAR(512),
    mime_type VARCHAR(64) NOT NULL DEFAULT 'application/pdf',
    is_uploaded BOOLEAN NOT NULL DEFAULT true,
    is_verified BOOLEAN NOT NULL DEFAULT true,
    is_from_kyc BOOLEAN NOT NULL DEFAULT false,
    sha256_hash VARCHAR(128),
    compliance_standard VARCHAR(128) DEFAULT 'Section 65B Indian Evidence Act Valid',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. User Vault Storage Quotas Table
CREATE TABLE IF NOT EXISTS vault_storage_quotas (
    user_id VARCHAR(64) PRIMARY KEY,
    storage_used_bytes BIGINT NOT NULL DEFAULT 0,
    storage_limit_bytes BIGINT NOT NULL DEFAULT 10737418240, -- 10 GB
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Document Share Links Table
CREATE TABLE IF NOT EXISTS vault_share_links (
    id VARCHAR(64) PRIMARY KEY,
    document_id VARCHAR(64) NOT NULL REFERENCES vault_documents(id) ON DELETE CASCADE,
    user_id VARCHAR(64) NOT NULL,
    share_token VARCHAR(128) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    allow_download BOOLEAN NOT NULL DEFAULT true,
    access_count INT NOT NULL DEFAULT 0,
    max_access INT DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Vault Audit Log Table
CREATE TABLE IF NOT EXISTS vault_audit_logs (
    id VARCHAR(64) PRIMARY KEY,
    document_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    action VARCHAR(64) NOT NULL, -- UPLOAD, REPLACE, DELETE, DOWNLOAD, SHARE
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for lightning fast lookups
CREATE INDEX IF NOT EXISTS idx_vault_documents_user ON vault_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_vault_documents_cat ON vault_documents(user_id, category);
CREATE INDEX IF NOT EXISTS idx_vault_share_links_token ON vault_share_links(share_token);
```

---

## 6. Baseline Production Seed Data Script (Sireesha Bandaru Profile)

The backend team can execute this SQL script to immediately populate the initial vault state for the active user:

```sql
-- Seed User ID: 'cmuzhxi5a000asr4p9f6jcndp' (Sireesha Bandaru)

-- 1. Initialize Quota
INSERT INTO vault_storage_quotas (user_id, storage_used_bytes, storage_limit_bytes)
VALUES ('cmuzhxi5a000asr4p9f6jcndp', 3006477107, 10737418240)
ON CONFLICT (user_id) DO NOTHING;

-- 2. Seed Default Verified Documents
INSERT INTO vault_documents (id, user_id, name, category, id_type, document_number, file_size, file_size_bytes, upload_date, expiry_date, file_path, file_url, mime_type, is_uploaded, is_verified, is_from_kyc, sha256_hash)
VALUES 
('kyc_doc_pan', 'cmuzhxi5a000asr4p9f6jcndp', 'PAN_Card_Sireesha.pdf', 'KYC & ID Proof', 'PAN Card', 'ABCDE1234F', '1.2 MB', 1258291, '30 Sep 2026', '-', '/uploads/pan_card_sireesha.pdf', '/api/v1/vault/documents/kyc_doc_pan/download', 'application/pdf', true, true, true, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),
('kyc_doc_aadhaar', 'cmuzhxi5a000asr4p9f6jcndp', 'Aadhaar_Card_Sireesha.pdf', 'KYC & ID Proof', 'Aadhaar Card', '•••• •••• 5678', '2.4 MB', 2516582, '30 Sep 2026', '-', '/uploads/aadhaar_card_sireesha.pdf', '/api/v1/vault/documents/kyc_doc_aadhaar/download', 'application/pdf', true, true, true, 'f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2'),
('tax_doc_form16', 'cmuzhxi5a000asr4p9f6jcndp', 'Form_16_FY2025_26.pdf', 'Tax & ITR', 'Form 16', 'TCS-FY2025-26', '1.8 MB', 1887436, '15 Jul 2026', '-', '/uploads/form_16_fy25_26.pdf', '/api/v1/vault/documents/tax_doc_form16/download', 'application/pdf', true, true, false, '38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da'),
('bank_doc_stmt', 'cmuzhxi5a000asr4p9f6jcndp', 'HDFC_Bank_Statement_6M.pdf', 'Bank Statements', 'Bank Statement', 'A/C ••••4587', '3.5 MB', 3670016, '01 Oct 2026', '-', '/uploads/hdfc_statement_6m.pdf', '/api/v1/vault/documents/bank_doc_stmt/download', 'application/pdf', true, true, false, 'a6c5f7823e20e8b2b1a13e2f5b4d7c9a123e456f789a012b345c678d901e234f'),
('ins_doc_health', 'cmuzhxi5a000asr4p9f6jcndp', 'HDFC_ERGO_Health_Policy.pdf', 'Insurance', 'Insurance Policy', 'POL-29837194', '2.2 MB', 2306867, '12 Aug 2026', '14 Jul 2027', '/uploads/hdfc_ergo_health.pdf', '/api/v1/vault/documents/ins_doc_health/download', 'application/pdf', true, true, false, 'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2'),
('inv_doc_cas', 'cmuzhxi5a000asr4p9f6jcndp', 'CAMS_Consolidated_Statement.pdf', 'Investment', 'Mutual Fund CAS', 'CAS-998822', '2.9 MB', 3040870, '05 Oct 2026', '-', '/uploads/cams_cas_statement.pdf', '/api/v1/vault/documents/inv_doc_cas/download', 'application/pdf', true, true, false, 'c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3')
ON CONFLICT (id) DO NOTHING;
```

---

## 7. Postman & cURL Testing Guide

### Step 1: Login to get Bearer Token
```bash
curl -X POST https://finmos-user.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "sireesha@finmos.com", "password": "Password123!"}'
```

### Step 2: Fetch Storage Quota Summary
```bash
curl -X GET https://finmos-user.onrender.com/api/v1/vault/storage-summary \
  -H "Authorization: Bearer <TOKEN>"
```

### Step 3: Fetch Document List (Filter by Category)
```bash
curl -X GET "https://finmos-user.onrender.com/api/v1/vault/documents?category=KYC%20%26%20ID%20Proof" \
  -H "Authorization: Bearer <TOKEN>"
```

### Step 4: Multipart Document Upload
```bash
curl -X POST https://finmos-user.onrender.com/api/v1/vault/documents/upload \
  -H "Authorization: Bearer <TOKEN>" \
  -F "file=@/path/to/my_passport.pdf" \
  -F "category=KYC & ID Proof" \
  -F "idType=Passport" \
  -F "documentNumber=Z1234567" \
  -F "expiryDate=12 Dec 2032"
```

### Step 5: Generate Share Link
```bash
curl -X POST https://finmos-user.onrender.com/api/v1/vault/documents/kyc_doc_pan/share \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"expiresInHours": 24, "allowDownload": true}'
```

---

## 8. Delivery Checklist for Backend Team

- [ ] **Database Setup**: Execute Section 5 DDL script on PostgreSQL/Supabase.
- [ ] **Seed Data**: Execute Section 6 baseline seed script.
- [ ] **File Storage Setup**: Configure persistent uploads directory on Render (`/uploads/`) or connect AWS S3 / Cloudflare R2 bucket.
- [ ] **MIME & Quota Validation**: Reject uploads exceeding `25 MB` per file or exceeding user's `10 GB` quota.
- [ ] **SHA-256 Hash Computation**: Automatically generate and store SHA-256 hash for every uploaded file.
- [ ] **Download Streaming**: Ensure `Content-Disposition` header with correct filename is set for `/download` and `/preview`.
- [ ] **Expiring Share Links**: Implement HMAC token validation for shared document links.
- [ ] **Deploy to Render**: Deploy all endpoints under `/api/v1/vault/`.

