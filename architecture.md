# TenantVerify Architecture

## Overview
TenantVerify is a blockchain-based tenant verification platform enabling landlords to verify tenant identity documents and generate tamper-proof certificates.

## Tech Stack
- **Frontend**: Flutter (Cross-platform: Web, iOS, Android)
- **Navigation**: go_router
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **File Handling**: file_picker
- **Cryptography**: crypto (SHA-256 hashing)
- **QR Codes**: qr_flutter

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── nav.dart                     # Router configuration
├── theme.dart                   # Theme & design system
├── models/                      # Data models
│   ├── tenant.dart              # Tenant data model
│   ├── document.dart            # Document data model
│   ├── verification.dart        # Verification data model
│   └── certificate.dart         # Certificate data model
├── services/                    # Business logic & data operations
│   ├── auth_service.dart        # Authentication (mock wallet)
│   ├── verification_service.dart # Verification workflow
│   ├── blockchain_service.dart  # Mock blockchain interactions
│   └── storage_service.dart     # Local storage operations
├── providers/                   # State management
│   ├── auth_provider.dart       # Authentication state
│   └── verification_provider.dart # Verification state
├── screens/                     # Main screens
│   ├── landing_screen.dart      # Landing/home page
│   ├── auth_screen.dart         # Authentication
│   ├── dashboard_screen.dart    # Main dashboard
│   ├── verification_wizard/     # Multi-step wizard
│   │   ├── wizard_screen.dart   # Wizard container
│   │   ├── tenant_details_step.dart
│   │   ├── document_upload_step.dart
│   │   └── consent_step.dart
│   ├── verification_progress_screen.dart
│   ├── certificate_screen.dart  # Certificate viewer
│   ├── settings_screen.dart     # Settings & admin
│   └── help_screen.dart         # Help & privacy
└── components/                  # Reusable UI components
    ├── app_card.dart            # Styled card component
    ├── primary_button.dart      # Primary action button
    ├── secondary_button.dart    # Secondary action button
    ├── status_badge.dart        # Status indicator
    ├── file_upload_card.dart    # Document upload widget
    ├── step_timeline.dart       # Progress timeline
    ├── qr_code_widget.dart      # QR code display
    ├── tenant_card.dart         # Tenant info card
    └── responsive_layout.dart   # Responsive layout wrapper
```

## Data Models

### Tenant
- id, name, email, phone, dob, aadhaarLast4
- createdAt, updatedAt

### Document
- id, tenantId, type (aadhaar/pan/employment)
- fileName, fileSize, hash, uploadedAt

### Verification
- id, tenantId, status (pending/processing/verified/failed)
- documents[], steps[], merkleRoot
- startedAt, completedAt

### Certificate
- id, verificationId, tenantId
- certificateNumber, issueDate, expiryDate
- landlordAddress, transactionHash
- merkleRoot, qrCodeData, isRevoked

## Navigation Routes
- `/` - Landing
- `/auth` - Authentication
- `/dashboard` - Dashboard
- `/verify` - Verification wizard
- `/progress/:id` - Verification progress
- `/certificate/:id` - Certificate viewer
- `/settings` - Settings
- `/help` - Help & Privacy

## Security Principles
- ❌ No raw PII stored on-chain
- ✅ Only cryptographic hashes & Merkle roots
- ✅ Documents stored encrypted off-chain (mocked)
- ✅ Explicit tenant consent recorded
- ✅ Full audit trail per verification

## MVP Implementation
- All verifications are mocked
- Blockchain interactions are simulated
- Architecture mirrors production for easy swap
