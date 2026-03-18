# JobSync Mobile App - Design Specification

**Created:** 2026-03-18
**Status:** Approved

## Overview

Transition the existing JobSync web application to a Flutter mobile app for Android and iOS. The mobile app will connect to the existing backend API, providing feature parity with the web frontend while adding cloud storage integration and subscription monetization.

## Architecture

### System Diagram

```
┌─────────────────┐     ┌─────────────┐     ┌─────────────┐
│  Flutter App    │────▶│  Your API   │────▶│  MariaDB    │
│  (iOS/Android)  │     │  (FastAPI)  │     │             │
└─────────────────┘     └─────────────┘     └─────────────┘
                               │
                        ┌──────┴──────┐
                        │ AI Service  │
                        │ (Ollama)    │
                        └─────────────┘
```

### Components

1. **Mobile Client**: Flutter app connecting to existing API endpoints
2. **Existing Backend**: FastAPI at port 8000 (most features work without changes)
3. **Existing AI Service**: Ollama integration at port 8001 (no changes required)
4. **Existing Database**: MariaDB (no changes required)
5. **Backend Changes Required**: For subscription/Stripe features (see Section 7)

### API Integration

The app will make HTTP requests to existing endpoints:

- `GET/POST /api/jobs` - Job CRUD operations
- `GET/PUT/DELETE /api/jobs/{id}` - Individual job operations
- `POST /api/jobs/{id}/parse-description` - AI job description parsing
- `POST /api/jobs/{id}/analyze-ats` - ATS analysis
- `POST /api/jobs/{id}/analyze-tech-fit` - Tech fit analysis
- `GET/POST/DELETE /api/resumes` - Resume management
- `POST /api/generate-resume` - AI resume generation
- Authentication endpoints (see below)

#### Authentication

The app uses OAuth2 (Google and LinkedIn) - same as the web frontend:

- **Login Flow**: Redirect to Google/LinkedIn OAuth, handle callback, receive token
- **Token Format**: Passed as query parameter (`?token=<token>`) for API calls
- **Token Storage**: Flutter Secure Storage (encrypted)
- **Token on Requests**: Include as query param `?token={token}` for authenticated endpoints
- **401 Handling**: Clear tokens, redirect to OAuth login
- **Endpoints**:
  - `/api/auth/oauth-callback` - Process OAuth code, returns auth token
  - `/api/auth/me?token=<token>` - Get current user info
  - `/api/auth/logout` - Logout (client should also clear local tokens)
- **Error Handling**:
  - Network errors: Show retry option, use cached data if available
  - Server errors (5xx): Show error message with retry
  - Client errors (4xx): Show specific error message

## Feature List

### Core Features

1. **Authentication**
   - User login/signup via existing API
   - Secure token storage
   - Session management
   - Auto-login on app launch

2. **Job Management**
   - View all jobs in list/grid format
   - Add new job with company, position, location, salary, status
   - Edit existing job details
   - Delete jobs
   - 9-stage pipeline: Saved, Applied, Phone Screen, Interview, Executive Call, Offered, Rejected, Withdrawn, Closed
   - Job detail view with all parsed information

3. **AI Features**
   - Job description parsing (calls existing AI service)
   - Resume generation (calls existing AI service)
   - ATS analysis (calls existing AI service)
   - Tech fit analysis (calls existing AI service)
   - Loading states and progress indicators for all AI operations

4. **Dashboard**
   - Application statistics (jobs per stage)
   - Recent activity
   - Quick actions (add job, view stats)
   - Pull-to-refresh

5. **Resume Management**
   - View uploaded resumes
   - Upload new resumes (from device or cloud)
   - Delete resumes
   - Select resume for job applications

6. **Cloud File Integration**
   - Google Drive file picker
   - Microsoft OneDrive file picker
   - Select resumes and templates from cloud storage

7. **Subscription & Monetization**
   - $1/month subscription via Stripe
   - Check subscription status on app launch
   - Grace period (3 days) if payment fails
   - Stripe webhooks for subscription lifecycle
   - Subscription status display in profile
   - **Free Tier Limitations**:
     - Limited to 5 jobs max
     - No AI features (parsing, resume generation, analysis)
     - No cloud file picker (local files only)
     - View-only resume access (cannot upload)
   - **Paywall UI**:
     - Modal overlay when free limits exceeded
     - Shows benefits of subscription ($1/month, unlock all features)
     - "Start Free Trial" button (7 days)
     - "Subscribe Now" button
     - "Maybe Later" to dismiss (with limited access)

8. **Offline Support**
   - Cache job data locally
   - Queue operations when offline
   - Sync when connection restored
   - Clear offline indicator

## UI/UX Specification

### Design System

#### Color Palette

| Color Name     | Hex Code  | Usage                           |
|----------------|-----------|---------------------------------|
| Primary        | #1e293b   | Navigation, headers, primary buttons |
| Primary Dark   | #0f172a   | Status bar, app bar             |
| Secondary      | #334155   | Secondary elements, cards       |
| Accent         | #22c55e   | Success states, CTAs, highlights |
| Accent Hover   | #16a34a   | Button hover states             |
| Error          | #ef4444   | Error states, delete actions    |
| Warning        | #f59e0b   | Warning states                  |
| Background     | #f8fafc   | Main background                 |
| Surface        | #ffffff   | Card surfaces                   |
| Text Primary   | #1e293b   | Main text                       |
| Text Secondary | #64748b   | Secondary text, labels          |
| Divider        | #e2e8f0   | Dividers, borders               |

#### Typography

- **Font Family**: System default (Roboto on Android, SF Pro on iOS)
- **Headings**:
  - H1: 28sp, Bold, #1e293b
  - H2: 24sp, SemiBold, #1e293b
  - H3: 20sp, Medium, #1e293b
  - H4: 18sp, Medium, #1e293b
- **Body**:
  - Body1: 16sp, Regular, #1e293b
  - Body2: 14sp, Regular, #64748b
- **Caption**: 12sp, Regular, #64748b
- **Button**: 16sp, SemiBold, uppercase

#### Spacing System (8pt grid)

- xs: 4dp
- sm: 8dp
- md: 16dp
- lg: 24dp
- xl: 32dp
- xxl: 48dp

#### Border Radius

- Small: 4dp (chips, tags)
- Medium: 8dp (buttons, inputs)
- Large: 16dp (cards, modals)
- Full: 9999dp (avatars, FAB)

### Layout Structure

#### Navigation

- **Bottom Navigation Bar** (4 tabs)
  - Dashboard (Home icon)
  - Jobs (Briefcase icon)
  - Resumes (Document icon)
  - Profile (Person icon)

- **App Bar**
  - Title centered or left-aligned
  - Action buttons (search, filter, add)
  - Back button for detail screens

#### Screen Layouts

1. **Dashboard Screen**
   - Statistics cards in grid (2x2)
   - Recent jobs list (last 5)
   - Quick action FAB

2. **Jobs List Screen**
   - Search bar at top
   - Filter chips (by status)
   - Job cards in scrollable list
   - FAB to add new job
   - Pull-to-refresh

3. **Job Detail Screen**
   - Company header with logo placeholder
   - Position and status
   - Details section (location, salary, date)
   - Job description (expandable)
   - Parsed keywords (chips)
   - AI Actions section (Parse, Generate Resume, Analyze)
   - Notes section

4. **Add/Edit Job Screen**
   - Form fields: Company, Position, Location, Salary, Status
   - Job description textarea with parse button
   - Save/Cancel actions

5. **Resumes Screen**
   - Grid of resume cards
   - Upload FAB (options: device, Google Drive, OneDrive)
   - Resume preview on tap

6. **Profile Screen**
   - User avatar and name
   - Subscription status card
   - Settings list (notifications, theme, about)
   - Logout button

### Widget Components

#### Job Card
- Company logo placeholder (colored circle with initials)
- Company name (H4)
- Position (Body1)
- Location + Salary (Caption)
- Status chip (colored by stage)
- Date added (Caption)

#### Status Chip Colors

| Stage          | Background   | Text        |
|----------------|--------------|-------------|
| Saved          | #e2e8f0      | #64748b     |
| Applied        | #dbeafe      | #2563eb     |
| Phone Screen   | #fef3c7      | #d97706     |
| Interview      | #fde68a      | #ca8a04     |
| Executive Call | #c7d2fe      | #6366f1     |
| Offered        | #dcfce7      | #16a34a     |
| Rejected       | #fee2e2      | #dc2626     |
| Withdrawn      | #f1f5f9      | #475569     |
| Closed         | #1e293b      | #f8fafc     |

#### Button Styles

- **Primary Button**: #22c55e background, white text, 8dp radius, 48dp height
- **Secondary Button**: Transparent, #22c55e border and text
- **Danger Button**: #ef4444 background, white text
- **Text Button**: No background, #22c55e text

#### Form Inputs
- Outlined style
- 8dp border radius
- Focus color: #22c55e
- Error color: #ef4444
- 56dp height

#### Loading States
- Circular progress indicator (#22c55e)
- Shimmer effect for content loading
- Skeleton screens for list items

## Technical Specification

### Required Packages

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Networking
  dio: ^5.4.0
  connectivity_plus: ^5.0.2

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2

  # Authentication (OAuth2)
  flutter_secure_storage: ^9.0.0
  google_sign_in: ^6.2.1  # For native Google OAuth, or use url_launcher for web-based flow

  # File Picking
  file_picker: ^6.1.1
  googleapis: ^12.0.0
  http: ^1.2.0  # For Microsoft Graph API (OneDrive)

  # Payment
  flutter_stripe: ^11.0.0

  # UI Components
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_slidable: ^3.0.1
  pull_to_refresh: ^2.0.0

  # Utils
  intl: ^0.19.0
  url_launcher: ^6.2.4
  path_provider: ^2.1.2
```

### State Management

- **BLoC Pattern** for business logic separation
- Each feature has its own BLoC
- Events and States defined with Equatable

### Data Layer

- Repository pattern for API calls
- Local data source (Hive) for offline caching
- Models with JSON serialization

### Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── data/
│   ├── models/
│   ├── repositories/
│   └── sources/
├── features/
│   ├── auth/
│   ├── jobs/
│   ├── resumes/
│   ├── dashboard/
│   ├── profile/
│   └── subscription/
└── services/
    ├── api/
    ├── storage/
    ├── cloud/
    └── payment/
```

## Monetization Details

> **Backend Changes Required**: The following features require backend additions:
> - Stripe webhook handlers for subscription lifecycle
> - Subscription status endpoint (returns `is_active` and `grace_period_until`)
> - Integration with your Stripe account

### Stripe Integration

- **Product**: $1/month subscription
- **Free Trial**: 7 days
- **Grace Period**: 3 days after failed payment
- **Webhook Events**:
  - `customer.subscription.created`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
  - `invoice.payment_failed`

### Subscription Flow

1. App checks subscription status on launch
2. If not active and no grace period, show paywall
3. User initiates Stripe checkout
4. Webhook updates subscription status
5. App reflects current status in Profile screen

#### Grace Period Implementation

- **Backend-driven**: The API should return subscription status including grace period info
- **Expected API response**: `{ "is_active": true/false, "grace_period_until": "2026-03-25T00:00:00Z" }`
- **Client logic**: If `grace_period_until` is in the future, allow full access
- **If no grace period from API**: Fall back to 3-day local grace period (stored when payment fails)

## Cloud Storage Integration

### Google Drive

- OAuth2 authentication flow
- File picker for selecting resumes/templates
- Read-only access to user's Drive

### Microsoft OneDrive

- OAuth2 authentication flow via Microsoft Graph API
- HTTP client using `http` package to call Graph API
- File picker for selecting resumes/templates
- Read-only access to user's OneDrive files
- Requires Azure AD app registration with Files.Read permission

## Offline Support Strategy

1. **Cache Strategy**
   - Jobs cached in Hive on fetch
   - Resumes cached with references (not file content)
   - Settings cached in SharedPreferences

2. **Offline Operations**
   - Queue create/update/delete operations
   - Store in Hive with pending flag and timestamp
   - Process queue on connectivity restore (FIFO order)
   - **Failure Handling**:
     - Max 3 retry attempts per operation
     - After max retries, mark as failed and notify user
     - User can manually retry failed operations
   - **Conflict Resolution** (server wins):
     - If job edited on both mobile and web while offline, server version overwrites local
     - If job deleted on server while edited locally, remove from local queue
     - Show notification to user when conflicts are resolved
   - **Queue Limits**: Max 50 pending operations, warn user when approaching limit

3. **Sync Logic**
   - Pull-to-refresh triggers sync
   - Auto-sync on app resume
   - Conflict resolution: server wins

4. **Indicators**
   - Offline banner at top when disconnected
   - Pending sync badge on jobs tab
   - Last synced timestamp in settings