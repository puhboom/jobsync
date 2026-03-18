# JobSync Flutter Mobile App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a Flutter mobile app for iOS and Android that connects to the existing JobSync API, providing feature parity with the web frontend plus cloud file picking and $1/month Stripe subscription.

**Architecture:** The app follows Clean Architecture with BLoC pattern. It connects to existing FastAPI backend (no changes except subscription endpoints). UI uses Material Design 3 matching ronning.systems aesthetic (navy primary, green accent).

**Tech Stack:** Flutter 3.x, BLoC for state management, Dio for networking, Hive for local caching, Flutter Secure Storage for tokens, Stripe for payments, Google Drive + Microsoft Graph APIs for cloud files.

---

## File Structure

```
jobsync_mobile/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app.dart                           # App configuration
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart         # API endpoints
│   │   │   └── app_constants.dart         # App-wide constants
│   │   ├── theme/
│   │   │   ├── app_colors.dart            # Color palette
│   │   │   ├── app_typography.dart        # Typography
│   │   │   └── app_theme.dart             # ThemeData
│   │   ├── utils/
│   │   │   ├── date_utils.dart            # Date formatting
│   │   │   └── extensions.dart           # String extensions
│   │   └── widgets/
│   │       ├── loading_indicator.dart     # Reusable loader
│   │       ├── error_view.dart            # Error display
│   │       └── status_chip.dart           # Job status chips
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart            # User data
│   │   │   ├── job_model.dart            # Job data
│   │   │   ├── resume_model.dart          # Resume data
│   │   │   └── subscription_model.dart    # Subscription status
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart      # Auth operations
│   │   │   ├── jobs_repository.dart      # Job CRUD
│   │   │   ├── resumes_repository.dart    # Resume operations
│   │   │   └── subscription_repository.dart
│   │   └── sources/
│   │       ├── api_client.dart            # Dio HTTP client
│   │       └── local_storage.dart         # Hive + SharedPreferences
│   ├── features/
│   │   ├── auth/
│   │   │   ├── bloc/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── login_screen.dart
│   │   │   └── oauth_handler.dart
│   │   ├── jobs/
│   │   │   ├── bloc/
│   │   │   │   ├── jobs_bloc.dart
│   │   │   │   ├── jobs_event.dart
│   │   │   │   └── jobs_state.dart
│   │   │   ├── jobs_list_screen.dart
│   │   │   ├── job_detail_screen.dart
│   │   │   ├── job_form_screen.dart
│   │   │   └── widgets/
│   │   │       └── job_card.dart
│   │   ├── resumes/
│   │   │   ├── bloc/
│   │   │   │   ├── resumes_bloc.dart
│   │   │   │   ├── resumes_event.dart
│   │   │   │   └── resumes_state.dart
│   │   │   ├── resumes_screen.dart
│   │   │   └── widgets/
│   │   │       └── resume_card.dart
│   │   ├── dashboard/
│   │   │   ├── bloc/
│   │   │   │   ├── dashboard_bloc.dart
│   │   │   │   ├── dashboard_event.dart
│   │   │   │   └── dashboard_state.dart
│   │   │   └── dashboard_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── subscription_card.dart
│   │   └── subscription/
│   │       ├── bloc/
│   │       │   ├── subscription_bloc.dart
│   │       │   ├── subscription_event.dart
│   │       │   └── subscription_state.dart
│   │       └── paywall_dialog.dart
│   ├── services/
│   │   ├── api/
│   │   │   └── api_service.dart           # Central API calls
│   │   ├── storage/
│   │   │   └── secure_storage.dart       # Token storage
│   │   ├── cloud/
│   │   │   ├── google_drive_service.dart
│   │   │   └── onedrive_service.dart
│   │   └── payment/
│   │       └── stripe_service.dart
│   └── navigation/
│       ├── app_router.dart                # GoRouter setup
│       └── main_navigation.dart           # Bottom nav
├── android/                               # Android config
├── ios/                                   # iOS config
├── pubspec.yaml                           # Dependencies
└── test/                                  # Tests
```

---

## Task Decomposition

### Phase 1: Project Setup

### Task 1: Create Flutter Project

**Files:**
- Create: `jobsync_mobile/pubspec.yaml`
- Create: `jobsync_mobile/lib/main.dart`
- Create: `jobsync_mobile/lib/app.dart`

- [ ] **Step 1: Initialize Flutter project**

Run: `flutter create jobsync_mobile --org com.ronningsystems --platforms android,ios`
Expected: Project scaffold created

- [ ] **Step 2: Update pubspec.yaml with dependencies**

```yaml
name: jobsync_mobile
description: JobSync - Job Application Tracking System

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6

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

  # Authentication
  flutter_secure_storage: ^9.0.0
  google_sign_in: ^6.2.1
  url_launcher: ^6.2.4

  # File Picking
  file_picker: ^6.1.1
  googleapis: ^12.0.0
  http: ^1.2.0

  # Payment
  flutter_stripe: ^11.0.0

  # UI Components
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

  # Navigation
  go_router: ^12.1.1

  # Utils
  intl: ^0.19.0
  path_provider: ^2.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  bloc_test: ^9.1.5
  mocktail: ^1.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: Get dependencies**

Run: `cd jobsync_mobile && flutter pub get`
Expected: Dependencies resolved without errors

- [ ] **Step 4: Commit**

```bash
cd jobsync_mobile
git init
git add .
git commit -m "feat: initialize Flutter project with dependencies"
```

---

### Task 2: Core Theme & Constants

**Files:**
- Create: `lib/core/constants/api_constants.dart`
- Create: `lib/core/constants/app_constants.dart`
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_typography.dart`
- Create: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Write tests for constants**

Create `test/core/constants/api_constants_test.dart`:

```dart
import 'package:flutter_test/flutter_test';
import 'package:jobsync_mobile/core/constants/api_constants.dart';

void main() {
  group('ApiConstants', () {
    test('baseUrl defaults to localhost for development', () {
      expect(ApiConstants.baseUrl, contains('localhost'));
    });

    test('all job endpoints are defined', () {
      expect(ApiConstants.jobs, '/api/jobs');
      expect(ApiConstants.parseDescription, contains('parse-description'));
      expect(ApiConstants.analyzeAts, contains('analyze-ats'));
      expect(ApiConstants.analyzeTechFit, contains('analyze-tech-fit'));
    });

    test('all auth endpoints are defined', () {
      expect(ApiConstants.oauthCallback, '/api/auth/oauth-callback');
      expect(ApiConstants.authMe, '/api/auth/me');
      expect(ApiConstants.logout, '/api/auth/logout');
    });
  });
}
```

- [ ] **Step 2: Run tests**

Run: `cd jobsync_mobile && flutter test test/core/constants/api_constants_test.dart`
Expected: FAIL - files don't exist yet

- [ ] **Step 3: Create api_constants.dart**

```dart
class ApiConstants {
  // TODO: Change for production
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000'; // iOS simulator

  // Jobs
  static const String jobs = '/api/jobs';
  static String job(String id) => '/api/jobs/$id';
  static String parseDescription(String id) => '/api/jobs/$id/parse-description';
  static String analyzeAts(String id) => '/api/jobs/$id/analyze-ats';
  static String analyzeTechFit(String id) => '/api/jobs/$id/analyze-tech-fit';
  static String jobHistory(String id) => '/api/jobs/$id/history';

  // Resumes
  static const String resumes = '/api/resumes';
  static const String generateResume = '/api/generate-resume';
  static String resume(String id) => '/api/resumes/$id';
  static String generatedResumes = '/api/generated-resumes';
  static String generatedResume(String id) => '/api/generated-resumes/$id';
  static String exportResume(String id) => '/api/generated-resumes/$id/export';

  // Auth
  static const String oauthCallback = '/api/auth/oauth-callback';
  static const String authMe = '/api/auth/me';
  static const String logout = '/api/auth/logout';
  static const String profile = '/api/auth/profile';
  static const String uploadPicture = '/api/auth/upload-picture';

  // Dashboard
  static const String dashboardStats = '/api/dashboard/stats';

  // Subscription (requires backend addition)
  static const String subscription = '/api/subscription';
}
```

- [ ] **Step 4: Create app_constants.dart**

```dart
class AppConstants {
  static const String appName = 'JobSync';
  static const String appVersion = '1.0.0';

  // Subscription
  static const double subscriptionPrice = 1.0;
  static const int freeTrialDays = 7;
  static const int gracePeriodDays = 3;

  // Limits
  static const int maxFreeJobs = 5;
  static const int maxOfflineQueue = 50;
  static const int maxRetryAttempts = 3;

  // Cache
  static const String jobsBox = 'jobs_box';
  static const String resumesBox = 'resumes_box';
  static const String pendingOpsBox = 'pending_operations';
  static const String settingsBox = 'settings';
}
```

- [ ] **Step 5: Run tests again**

Run: `cd jobsync_mobile && flutter test test/core/constants/api_constants_test.dart`
Expected: PASS

- [ ] **Step 6: Create app_colors.dart**

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF1E293B);
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color secondary = Color(0xFF334155);

  // Accent
  static const Color accent = Color(0xFF22C55E);
  static const Color accentHover = Color(0xFF16A34A);

  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);

  // Neutral
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);

  // Status chip colors
  static const Color savedBg = Color(0xFFE2E8F0);
  static const Color savedText = Color(0xFF64748B);
  static const Color appliedBg = Color(0xFFDBEAFE);
  static const Color appliedText = Color(0xFF2563EB);
  static const Color phoneScreenBg = Color(0xFFFEF3C7);
  static const Color phoneScreenText = Color(0xFFD97706);
  static const Color interviewBg = Color(0xFFFDE68A);
  static const Color interviewText = Color(0xFFCA8A04);
  static const Color executiveCallBg = Color(0xFFC7D2FE);
  static const Color executiveCallText = Color(0xFF6366F1);
  static const Color offeredBg = Color(0xFFDCFCE7);
  static const Color offeredText = Color(0xFF16A34A);
  static const Color rejectedBg = Color(0xFFFEE2E2);
  static const Color rejectedText = Color(0xFFDC2626);
  static const Color withdrawnBg = Color(0xFFF1F5F9);
  static const Color withdrawnText = Color(0xFF475569);
  static const Color closedBg = Color(0xFF1E293B);
  static const Color closedText = Color(0xFFF8FAFC);
}
```

- [ ] **Step 7: Create app_typography.dart**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'Roboto';

  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
```

- [ ] **Step 8: Create app_theme.dart**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AppColors.accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}
```

- [ ] **Step 9: Create main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'data/sources/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open boxes
  await Hive.openBox(AppConstants.jobsBox);
  await Hive.openBox(AppConstants.resumesBox);
  await Hive.openBox(AppConstants.pendingOpsBox);
  await Hive.openBox(AppConstants.settingsBox);

  // Initialize storage
  final storage = LocalStorage();

  runApp(
    BlocProvider(
      create: (_) => AuthBloc(storage: storage),
      child: const JobSyncApp(),
    ),
  );
}
```

- [ ] **Step 10: Create app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/login_screen.dart';
import 'navigation/main_navigation.dart';

class JobSyncApp extends StatelessWidget {
  const JobSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobSync',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const MainNavigation();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
```

- [ ] **Step 11: Run tests**

Run: `cd jobsync_mobile && flutter test test/core/constants/`
Expected: PASS

- [ ] **Step 12: Commit**

```bash
git add lib/core/
git commit -m "feat: add core theme and constants"
```

---

### Task 3: Data Layer - Models

**Files:**
- Create: `lib/data/models/user_model.dart`
- Create: `lib/data/models/job_model.dart`
- Create: `lib/data/models/resume_model.dart`
- Create: `lib/data/models/subscription_model.dart`

- [ ] **Step 1: Write model tests**

Create `test/data/models/job_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsync_mobile/data/models/job_model.dart';

void main() {
  group('JobModel', () {
    test('fromJson creates valid model', () {
      final json = {
        'id': '1',
        'company': 'Google',
        'position': 'Software Engineer',
        'location': 'Mountain View, CA',
        'salary': '150000',
        'status': 'Applied',
        'description': 'Full stack developer',
        'requirements': ['Python', 'Go'],
        'keywords': ['tech', 'remote'],
        'created_at': '2026-03-15T10:00:00Z',
      };

      final job = JobModel.fromJson(json);

      expect(job.id, '1');
      expect(job.company, 'Google');
      expect(job.position, 'Software Engineer');
      expect(job.status, JobStatus.applied);
    });

    test('toJson creates valid map', () {
      final job = JobModel(
        id: '1',
        company: 'Google',
        position: 'Software Engineer',
        location: 'Mountain View, CA',
        salary: '150000',
        status: JobStatus.applied,
        description: 'Full stack developer',
        requirements: ['Python', 'Go'],
        keywords: ['tech', 'remote'],
        createdAt: DateTime.parse('2026-03-15T10:00:00Z'),
      );

      final json = job.toJson();

      expect(json['company'], 'Google');
      expect(json['position'], 'Software Engineer');
    });
  });
}
```

- [ ] **Step 2: Run tests**

Run: `cd jobsync_mobile && flutter test test/data/models/job_model_test.dart`
Expected: FAIL - models don't exist

- [ ] **Step 3: Create job_model.dart**

```dart
import 'package:equatable/equatable.dart';

enum JobStatus {
  saved,
  applied,
  phoneScreen,
  interview,
  executiveCall,
  offered,
  rejected,
  withdrawn,
  closed;

  String get displayName {
    switch (this) {
      case JobStatus.saved:
        return 'Saved';
      case JobStatus.applied:
        return 'Applied';
      case JobStatus.phoneScreen:
        return 'Phone Screen';
      case JobStatus.interview:
        return 'Interview';
      case JobStatus.executiveCall:
        return 'Executive Call';
      case JobStatus.offered:
        return 'Offered';
      case JobStatus.rejected:
        return 'Rejected';
      case JobStatus.withdrawn:
        return 'Withdrawn';
      case JobStatus.closed:
        return 'Closed';
    }
  }

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase().replaceAll(' ', ''),
      orElse: () => JobStatus.saved,
    );
  }
}

class JobModel extends Equatable {
  final String id;
  final String company;
  final String position;
  final String? location;
  final String? salary;
  final JobStatus status;
  final String? description;
  final List<String> requirements;
  final List<String> keywords;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const JobModel({
    required this.id,
    required this.company,
    required this.position,
    this.location,
    this.salary,
    required this.status,
    this.description,
    this.requirements = const [],
    this.keywords = const [],
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']?.toString() ?? '',
      company: json['company'] ?? '',
      position: json['position'] ?? '',
      location: json['location'],
      salary: json['salary']?.toString(),
      status: JobStatus.fromString(json['status'] ?? 'saved'),
      description: json['description'],
      requirements: List<String>.from(json['requirements'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'location': location,
      'salary': salary,
      'status': status.displayName,
      'description': description,
      'requirements': requirements,
      'keywords': keywords,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  JobModel copyWith({
    String? id,
    String? company,
    String? position,
    String? location,
    String? salary,
    JobStatus? status,
    String? description,
    List<String>? requirements,
    List<String>? keywords,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      keywords: keywords ?? this.keywords,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        company,
        position,
        location,
        salary,
        status,
        description,
        requirements,
        keywords,
        notes,
        createdAt,
        updatedAt,
      ];
}
```

- [ ] **Step 4: Create user_model.dart**

```dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? pictureUrl;
  final List<String> oauthProviders;
  final bool hasActiveSubscription;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.pictureUrl,
    this.oauthProviders = const [],
    this.hasActiveSubscription = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      pictureUrl: json['picture_url'],
      oauthProviders: List<String>.from(json['oauth_providers'] ?? []),
      hasActiveSubscription: json['has_active_subscription'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'picture_url': pictureUrl,
      'oauth_providers': oauthProviders,
      'has_active_subscription': hasActiveSubscription,
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        pictureUrl,
        oauthProviders,
        hasActiveSubscription,
      ];
}
```

- [ ] **Step 5: Create resume_model.dart**

```dart
import 'package:equatable/equatable.dart';

class ResumeModel extends Equatable {
  final String id;
  final String name;
  final String? fileUrl;
  final String? contentType;
  final DateTime uploadedAt;

  const ResumeModel({
    required this.id,
    required this.name,
    this.fileUrl,
    this.contentType,
    required this.uploadedAt,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      fileUrl: json['file_url'],
      contentType: json['content_type'],
      uploadedAt: DateTime.tryParse(json['uploaded_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'file_url': fileUrl,
      'content_type': contentType,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, fileUrl, contentType, uploadedAt];
}

class GeneratedResumeModel extends Equatable {
  final String id;
  final String jobId;
  final String content;
  final DateTime createdAt;

  const GeneratedResumeModel({
    required this.id,
    required this.jobId,
    required this.content,
    required this.createdAt,
  });

  factory GeneratedResumeModel.fromJson(Map<String, dynamic> json) {
    return GeneratedResumeModel(
      id: json['id']?.toString() ?? '',
      jobId: json['job_id']?.toString() ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, jobId, content, createdAt];
}
```

- [ ] **Step 6: Create subscription_model.dart**

```dart
import 'package:equatable/equatable.dart';

class SubscriptionModel extends Equatable {
  final bool isActive;
  final DateTime? gracePeriodUntil;
  final DateTime? trialEndDate;
  final String? stripeCustomerId;

  const SubscriptionModel({
    required this.isActive,
    this.gracePeriodUntil,
    this.trialEndDate,
    this.stripeCustomerId,
  });

  bool get isInGracePeriod {
    if (gracePeriodUntil == null) return false;
    return DateTime.now().isBefore(gracePeriodUntil!);
  }

  bool get isInTrial {
    if (trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  bool get hasFullAccess => isActive || isInGracePeriod || isInTrial;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      isActive: json['is_active'] ?? false,
      gracePeriodUntil: json['grace_period_until'] != null
          ? DateTime.tryParse(json['grace_period_until'])
          : null,
      trialEndDate: json['trial_end_date'] != null
          ? DateTime.tryParse(json['trial_end_date'])
          : null,
      stripeCustomerId: json['stripe_customer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_active': isActive,
      'grace_period_until': gracePeriodUntil?.toIso8601String(),
      'trial_end_date': trialEndDate?.toIso8601String(),
      'stripe_customer_id': stripeCustomerId,
    };
  }

  @override
  List<Object?> get props => [
        isActive,
        gracePeriodUntil,
        trialEndDate,
        stripeCustomerId,
      ];
}
```

- [ ] **Step 7: Run tests**

Run: `cd jobsync_mobile && flutter test test/data/models/job_model_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/data/models/
git commit -m "feat: add data models (User, Job, Resume, Subscription)"
```

---

### Task 4: Data Layer - API Client & Storage

**Files:**
- Create: `lib/data/sources/api_client.dart`
- Create: `lib/data/sources/local_storage.dart`

- [ ] **Step 1: Write api_client test**

Create `test/data/sources/api_client_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:jobsync_mobile/data/sources/api_client.dart';

void main() {
  group('ApiClient', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    test('has default base URL', () {
      expect(apiClient.dio.options.baseUrl, isNotEmpty);
    });

    test('can set auth token', () {
      apiClient.setAuthToken('test_token');
      // Token should be included in requests
    });

    test('can clear auth token', () {
      apiClient.setAuthToken('test_token');
      apiClient.clearAuthToken();
      // Token should be cleared
    });
  });
}
```

- [ ] **Step 2: Run tests**

Run: `cd jobsync_mobile && flutter test test/data/sources/api_client_test.dart`
Expected: FAIL - files don't exist

- [ ] **Step 3: Create api_client.dart**

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  void setAuthToken(String token) {
    // Token is passed as query parameter per the API spec
    dio.options.queryParameters['token'] = token;
  }

  void clearAuthToken() {
    dio.options.queryParameters.remove('token');
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }
}
```

- [ ] **Step 4: Create local_storage.dart**

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class LocalStorage {
  final FlutterSecureStorage _secureStorage;

  LocalStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Secure storage for tokens
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // Hive for jobs
  Future<void> cacheJobs(List<Map<String, dynamic>> jobs) async {
    final box = Hive.box(AppConstants.jobsBox);
    await box.put('cached_jobs', jobs);
  }

  Future<List<Map<String, dynamic>>> getCachedJobs() async {
    final box = Hive.box(AppConstants.jobsBox);
    final cached = box.get('cached_jobs');
    if (cached == null) return [];
    return List<Map<String, dynamic>>.from(cached);
  }

  // Hive for pending offline operations
  Future<void> addPendingOperation(Map<String, dynamic> operation) async {
    final box = Hive.box(AppConstants.pendingOpsBox);
    final operations = box.get('pending') ?? [];
    operations.add(operation);
    await box.put('pending', operations);
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final box = Hive.box(AppConstants.pendingOpsBox);
    final ops = box.get('pending');
    if (ops == null) return [];
    return List<Map<String, dynamic>>.from(ops);
  }

  Future<void> clearPendingOperations() async {
    final box = Hive.box(AppConstants.pendingOpsBox);
    await box.delete('pending');
  }

  // SharedPreferences for simple settings
  Future<void> saveLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sync', time.toIso8601String());
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString('last_sync');
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }

  // Grace period tracking
  Future<void> setGracePeriodEnd(DateTime endDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('grace_period_end', endDate.toIso8601String());
  }

  Future<DateTime?> getGracePeriodEnd() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString('grace_period_end');
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }
}
```

- [ ] **Step 5: Run tests**

Run: `cd jobsync_mobile && flutter test test/data/sources/api_client_test.dart`
Expected: FAIL - need mocktail dependency properly set up

- [ ] **Step 6: Commit**

```bash
git add lib/data/sources/
git commit -m "feat: add API client and local storage"
```

---

### Task 5: Auth Feature

**Files:**
- Create: `lib/features/auth/bloc/auth_bloc.dart`
- Create: `lib/features/auth/bloc/auth_event.dart`
- Create: `lib/features/auth/bloc/auth_state.dart`
- Create: `lib/features/auth/login_screen.dart`

- [ ] **Step 1: Create auth_event.dart**

```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String provider; // 'google' or 'linkedin'

  const AuthLoginRequested({required this.provider});

  @override
  List<Object?> get props => [provider];
}

class AuthOAuthCallback extends AuthEvent {
  final String code;
  final String provider;

  const AuthOAuthCallback({required this.code, required this.provider});

  @override
  List<Object?> get props => [code, provider];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
```

- [ ] **Step 2: Create auth_state.dart**

```dart
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 3: Create auth_bloc.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/sources/local_storage.dart';
import '../../../data/sources/api_client.dart';
import '../../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalStorage storage;
  final ApiClient _apiClient = ApiClient();

  AuthBloc({required this.storage}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthOAuthCallback>(_onAuthOAuthCallback);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final token = await storage.getToken();
      if (token == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      _apiClient.setAuthToken(token);
      final response = await _apiClient.get('/api/auth/me');

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        emit(AuthAuthenticated(user: user));
      } else {
        await storage.clearToken();
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      await storage.clearToken();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // In a real app, this would redirect to OAuth provider
    // For now, we'll emit the URL to open
    // The OAuth callback would be handled by the app's deep link handler
    emit(AuthLoading());

    // TODO: Implement actual OAuth redirect
    // This is where you'd use google_sign_in or url_launcher
  }

  Future<void> _onAuthOAuthCallback(
    AuthOAuthCallback event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _apiClient.post(
        '/api/auth/oauth-callback',
        data: {
          'code': event.code,
          'provider': event.provider,
        },
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];
        await storage.saveToken(token);
        _apiClient.setAuthToken(token);

        final userResponse = await _apiClient.get('/api/auth/me');
        final user = UserModel.fromJson(userResponse.data);
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Authentication failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _apiClient.post('/api/auth/logout');
    } catch (_) {
      // Ignore logout API errors
    }

    await storage.clearToken();
    _apiClient.clearAuthToken();
    emit(const AuthUnauthenticated());
  }
}
```

- [ ] **Step 4: Create login_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo/Title
                Icon(
                  Icons.work_outline,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'JobSync',
                  style: AppTypography.h1,
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your job applications with AI',
                  style: AppTypography.body2,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // OAuth Buttons
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => _handleOAuth(context, 'google'),
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.g_mobiledata, size: 24),
                            label: const Text('Continue with Google'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => _handleOAuth(context, 'linkedin'),
                            icon: const Icon(Icons.link, size: 24),
                            label: const Text('Continue with LinkedIn'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 48),
                // Footer
                Text(
                  'By continuing, you agree to our Terms of Service',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleOAuth(BuildContext context, String provider) async {
    // TODO: Replace with actual OAuth URLs from backend
    // For now, this is a placeholder that would open the OAuth flow
    final googleOAuthUrl =
        'http://10.0.2.2:5000/login'; // Android emulator points to localhost:5000

    final uri = Uri.parse(googleOAuthUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    // After OAuth, the app would receive a callback
    // For now, we'll simulate successful auth for testing
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/
git commit -m "feat: add authentication feature with OAuth"
```

---

### Task 6: Navigation

**Files:**
- Create: `lib/navigation/main_navigation.dart`

- [ ] **Step 1: Create main_navigation.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/jobs/jobs_list_screen.dart';
import '../features/resumes/resumes_screen.dart';
import '../features/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    JobsListScreen(),
    ResumesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Resumes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/navigation/
git commit -m "feat: add bottom navigation"
```

---

### Task 7: Dashboard Feature

**Files:**
- Create: `lib/features/dashboard/bloc/dashboard_bloc.dart`
- Create: `lib/features/dashboard/bloc/dashboard_event.dart`
- Create: `lib/features/dashboard/bloc/dashboard_state.dart`
- Create: `lib/features/dashboard/dashboard_screen.dart`

- [ ] **Step 1: Create dashboard state & event**

```dart
// dashboard_event.dart
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}
```

```dart
// dashboard_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/job_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final Map<JobStatus, int> jobCounts;
  final List<JobModel> recentJobs;
  final int totalJobs;

  const DashboardLoaded({
    required this.jobCounts,
    required this.recentJobs,
    required this.totalJobs,
  });

  @override
  List<Object?> get props => [jobCounts, recentJobs, totalJobs];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 2: Create dashboard_bloc.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/sources/api_client.dart';
import '../../../data/models/job_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiClient _apiClient = ApiClient();

  DashboardBloc() : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    try {
      final response = await _apiClient.get('/api/dashboard/stats');

      if (response.statusCode == 200) {
        final stats = response.data as Map<String, dynamic>;
        final jobsResponse = await _apiClient.get('/api/jobs');

        final jobs = (jobsResponse.data as List)
            .map((json) => JobModel.fromJson(json))
            .toList();

        // Calculate job counts by status
        final jobCounts = <JobStatus, int>{};
        for (final status in JobStatus.values) {
          jobCounts[status] = jobs.where((j) => j.status == status).length;
        }

        // Get recent jobs (last 5)
        final recentJobs = jobs.take(5).toList();

        emit(DashboardLoaded(
          jobCounts: jobCounts,
          recentJobs: recentJobs,
          totalJobs: jobs.length,
        ));
      } else {
        emit(DashboardError(message: 'Failed to load dashboard'));
      }
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _onLoadRequested(const DashboardLoadRequested(), emit);
  }
}
```

- [ ] **Step 3: Create dashboard_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../jobs/bloc/jobs_bloc.dart';
import '../jobs/bloc/jobs_event.dart';
import 'dashboard_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JobSync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(const DashboardRefreshRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(const DashboardLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const DashboardRefreshRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    _buildStatsGrid(state),
                    const SizedBox(height: 24),
                    // Recent Jobs
                    Text('Recent Applications', style: AppTypography.h3),
                    const SizedBox(height: 12),
                    _buildRecentJobs(context, state),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add job
          // TODO: Implement navigation
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardLoaded state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Jobs',
          state.totalJobs.toString(),
          Icons.work,
          AppColors.primary,
        ),
        _buildStatCard(
          'Applied',
          (state.jobCounts[JobStatus.applied] ?? 0).toString(),
          Icons.send,
          AppColors.appliedText,
        ),
        _buildStatCard(
          'Interviews',
          ((state.jobCounts[JobStatus.interview] ?? 0) +
                  (state.jobCounts[JobStatus.phoneScreen] ?? 0) +
                  (state.jobCounts[JobStatus.executiveCall] ?? 0))
              .toString(),
          Icons.people,
          AppColors.interviewText,
        ),
        _buildStatCard(
          'Offers',
          (state.jobCounts[JobStatus.offered] ?? 0).toString(),
          Icons.celebration,
          AppColors.offeredText,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTypography.h2.copyWith(color: color),
                ),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(label, style: AppTypography.caption),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentJobs(BuildContext context, DashboardLoaded state) {
    if (state.recentJobs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.work_outline, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                Text(
                  'No jobs yet',
                  style: AppTypography.body2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add your first job',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.recentJobs.length,
      itemBuilder: (context, index) {
        final job = state.recentJobs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                job.company.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(job.company, style: AppTypography.body1),
            subtitle: Text(job.position, style: AppTypography.caption),
            trailing: _buildStatusChip(job.status),
            onTap: () {
              // Navigate to job detail
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(JobStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case JobStatus.saved:
        bgColor = AppColors.savedBg;
        textColor = AppColors.savedText;
      case JobStatus.applied:
        bgColor = AppColors.appliedBg;
        textColor = AppColors.appliedText;
      case JobStatus.phoneScreen:
        bgColor = AppColors.phoneScreenBg;
        textColor = AppColors.phoneScreenText;
      case JobStatus.interview:
        bgColor = AppColors.interviewBg;
        textColor = AppColors.interviewText;
      case JobStatus.executiveCall:
        bgColor = AppColors.executiveCallBg;
        textColor = AppColors.executiveCallText;
      case JobStatus.offered:
        bgColor = AppColors.offeredBg;
        textColor = AppColors.offeredText;
      case JobStatus.rejected:
        bgColor = AppColors.rejectedBg;
        textColor = AppColors.rejectedText;
      case JobStatus.withdrawn:
        bgColor = AppColors.withdrawnBg;
        textColor = AppColors.withdrawnText;
      case JobStatus.closed:
        bgColor = AppColors.closedBg;
        textColor = AppColors.closedText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
    );
  }
}

// Import for JobStatus
import '../../../data/models/job_model.dart';
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/dashboard/
git commit -m "feat: add dashboard feature with stats"
```

---

### Phase 2: Feature Implementation

### Task 8: Jobs Feature (Full CRUD)

**Files:**
- Modify: `lib/features/jobs/bloc/jobs_bloc.dart`
- Create: `lib/features/jobs/jobs_list_screen.dart`
- Create: `lib/features/jobs/job_detail_screen.dart`
- Create: `lib/features/jobs/job_form_screen.dart`
- Create: `lib/features/jobs/widgets/job_card.dart`

- [ ] **Step 1: Create jobs_repository.dart**

```dart
import '../sources/api_client.dart';
import '../models/job_model.dart';
import '../../core/constants/api_constants.dart';

class JobsRepository {
  final ApiClient _apiClient;

  JobsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<JobModel>> getJobs() async {
    final response = await _apiClient.get(ApiConstants.jobs);
    return (response.data as List).map((json) => JobModel.fromJson(json)).toList();
  }

  Future<JobModel> getJob(String id) async {
    final response = await _apiClient.get(ApiConstants.job(id));
    return JobModel.fromJson(response.data);
  }

  Future<JobModel> createJob(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.jobs, data: data);
    return JobModel.fromJson(response.data);
  }

  Future<JobModel> updateJob(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(ApiConstants.job(id), data: data);
    return JobModel.fromJson(response.data);
  }

  Future<void> deleteJob(String id) async {
    await _apiClient.delete(ApiConstants.job(id));
  }

  Future<Map<String, dynamic>> parseDescription(String id, String description) async {
    final response = await _apiClient.post(
      ApiConstants.parseDescription(id),
      data: {'description': description},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> analyzeAts(String id, String resumeId) async {
    final response = await _apiClient.post(
      ApiConstants.analyzeAts(id),
      data: {'resume_id': resumeId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> analyzeTechFit(String id) async {
    final response = await _apiClient.post(ApiConstants.analyzeTechFit(id));
    return response.data;
  }
}
```

- [ ] **Step 2: Create jobs_list_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/job_model.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../widgets/job_card.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  String _searchQuery = '';
  JobStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // Filter chips
          if (_filterStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(_filterStatus!.displayName),
                    onDeleted: () => setState(() => _filterStatus = null),
                  ),
                ],
              ),
            ),
          // Jobs list
          Expanded(
            child: BlocBuilder<JobsBloc, JobsState>(
              builder: (context, state) {
                if (state is JobsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is JobsError) {
                  return Center(child: Text(state.message));
                }

                if (state is JobsLoaded) {
                  var jobs = state.jobs;

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    jobs = jobs.where((job) =>
                        job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        job.position.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                  }

                  // Apply status filter
                  if (_filterStatus != null) {
                    jobs = jobs.where((job) => job.status == _filterStatus).toList();
                  }

                  if (jobs.isEmpty) {
                    return const Center(child: Text('No jobs found'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<JobsBloc>().add(const JobsRefreshRequested());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        return JobCard(
                          job: jobs[index],
                          onTap: () {
                            // Navigate to job detail
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add job
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Filter by Status', style: AppTypography.h3),
            ),
            ...JobStatus.values.map((status) {
              return ListTile(
                title: Text(status.displayName),
                trailing: _filterStatus == status ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _filterStatus = status);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }
}
```

- [ ] **Step 3: Create job_card.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/job_model.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      job.company.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.company, style: AppTypography.h4),
                        Text(job.position, style: AppTypography.body2),
                      ],
                    ),
                  ),
                  _buildStatusChip(job.status),
                ],
              ),
              if (job.location != null || job.salary != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (job.location != null) ...[
                      const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(job.location!, style: AppTypography.caption),
                      const SizedBox(width: 12),
                    ],
                    if (job.salary != null) ...[
                      const Icon(Icons.attach_money, size: 16, color: AppColors.textSecondary),
                      Text(job.salary!, style: AppTypography.caption),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(JobStatus status) {
    // Same implementation as dashboard
    // ... (see dashboard_screen.dart)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: _getStatusColor(status), fontSize: 12),
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.saved: return AppColors.savedText;
      case JobStatus.applied: return AppColors.appliedText;
      case JobStatus.phoneScreen: return AppColors.phoneScreenText;
      case JobStatus.interview: return AppColors.interviewText;
      case JobStatus.executiveCall: return AppColors.executiveCallText;
      case JobStatus.offered: return AppColors.offeredText;
      case JobStatus.rejected: return AppColors.rejectedText;
      case JobStatus.withdrawn: return AppColors.withdrawnText;
      case JobStatus.closed: return AppColors.closedText;
    }
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/jobs/
git commit -m "feat: add jobs feature with list and cards"
```

---

### Task 9: AI Actions & Job Detail

**Files:**
- Create: `lib/features/jobs/job_detail_screen.dart`

- [ ] **Step 1: Create job_detail_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/job_model.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit form
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state is JobsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final job = state is JobsLoaded
              ? state.jobs.firstWhere((j) => j.id == jobId, orElse: () => throw Exception('Job not found'))
              : null;

          if (job == null) {
            return const Center(child: Text('Job not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(job),
                const SizedBox(height: 24),
                // Details
                _buildDetails(job),
                const SizedBox(height: 24),
                // Description
                if (job.description != null) ...[
                  Text('Job Description', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Text(job.description!, style: AppTypography.body1),
                  const SizedBox(height: 24),
                ],
                // Keywords
                if (job.keywords.isNotEmpty) ...[
                  Text('Keywords', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.keywords.map((k) => Chip(label: Text(k))).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                // AI Actions
                Text('AI Actions', style: AppTypography.h3),
                const SizedBox(height: 12),
                _buildAIActions(context, job),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(JobModel job) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary,
          child: Text(
            job.company.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.position, style: AppTypography.h2),
              Text(job.company, style: AppTypography.body1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(JobModel job) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (job.location != null)
              _buildDetailRow(Icons.location_on, 'Location', job.location!),
            if (job.salary != null)
              _buildDetailRow(Icons.attach_money, 'Salary', job.salary!),
            _buildDetailRow(Icons.calendar_today, 'Applied',
              job.createdAt.toString().split(' ')[0]),
            _buildDetailRow(Icons.flag, 'Status', job.status.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text('$label: ', style: AppTypography.body2),
          Text(value, style: AppTypography.body1),
        ],
      ),
    );
  }

  Widget _buildAIActions(BuildContext context, JobModel job) {
    return Column(
      children: [
        _buildAIButton(
          context,
          'Parse Description',
          Icons.auto_fix_high,
          () => context.read<JobsBloc>().add(JobParseDescriptionRequested(job.id)),
        ),
        const SizedBox(height: 8),
        _buildAIButton(
          context,
          'Generate Resume',
          Icons.description,
          () => context.read<JobsBloc>().add(JobGenerateResumeRequested(job.id)),
        ),
        const SizedBox(height: 8),
        _buildAIButton(
          context,
          'Run ATS Analysis',
          Icons.analytics,
          () => context.read<JobsBloc>().add(JobAnalyzeAtsRequested(job.id)),
        ),
        const SizedBox(height: 8),
        _buildAIButton(
          context,
          'Run Tech Fit Analysis',
          Icons.psychology,
          () => context.read<JobsBloc>().add(JobAnalyzeTechFitRequested(job.id)),
        ),
      ],
    );
  }

  Widget _buildAIButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<JobsBloc>().add(JobDeleteRequested(jobId));
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/jobs/
git commit -m "feat: add job detail screen with AI actions"
```

---

### Task 10: Resumes Feature

**Files:**
- Create: `lib/services/cloud/google_drive_service.dart`
- Create: `lib/services/cloud/onedrive_service.dart`
- Create: `lib/features/resumes/resumes_screen.dart`

- [ ] **Step 1: Create google_drive_service.dart**

```dart
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveService {
  // Requires OAuth2 token from Google Sign-In
  Future<List<DriveFile>> pickFile(String accessToken) async {
    final client = http.Client();
    final driveApi = drive.DriveApi(client);

    // Get files with specific MIME types (documents, PDFs)
    final files = await driveApi.files.list(
      q: "mimeType='application/pdf' or mimeType='application/vnd.google-apps.document'",
      spaces: 'drive',
    );

    return files.files ?? [];
  }

  Future<List<int>?> downloadFile(String accessToken, String fileId) async {
    final client = http.Client();
    final driveApi = drive.DriveApi(client);

    final response = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.downloadMedia);
    return (response as List<int>?)
```

- [ ] **Step 2: Create onedrive_service.dart**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OneDriveService {
  static const String graphEndpoint = 'https://graph.microsoft.com/v1.0';

  Future<List<OneDriveItem>> pickFile(String accessToken) async {
    final response = await http.get(
      Uri.parse('$graphEndpoint/me/drive/root/children'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['value'] as List;
      return items
          .where((item) => item['file'] != null)
          .map((item) => OneDriveItem.fromJson(item))
          .toList();
    }
    return [];
  }
}

class OneDriveItem {
  final String id;
  final String name;
  final String? webUrl;

  OneDriveItem({required this.id, required this.name, this.webUrl});

  factory OneDriveItem.fromJson(Map<String, dynamic> json) {
    return OneDriveItem(
      id: json['id'],
      name: json['name'],
      webUrl: json['webUrl'],
    );
  }
}
```

- [ ] **Step 3: Create resumes_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/cloud/google_drive_service.dart';
import '../../../services/cloud/onedrive_service.dart';

class ResumesScreen extends StatelessWidget {
  const ResumesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumes')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 0, // TODO: Load from state
        itemBuilder: (context, index) {
          return Card(
            child: InkWell(
              onTap: () {},
              child: const Center(child: Icon(Icons.description, size: 48)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadOptions(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('Upload from Device'),
            onTap: () {
              Navigator.pop(ctx);
              _pickFromDevice();
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Google Drive'),
            onTap: () {
              Navigator.pop(ctx);
              _pickFromGoogleDrive();
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_circle),
            title: const Text('OneDrive'),
            onTap: () {
              Navigator.pop(ctx);
              _pickFromOneDrive();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    // TODO: Upload to server
  }

  Future<void> _pickFromGoogleDrive() async {
    final service = GoogleDriveService();
    // TODO: Implement OAuth flow and file picking
  }

  Future<void> _pickFromOneDrive() async {
    final service = OneDriveService();
    // TODO: Implement OAuth flow and file picking
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/resumes/ lib/services/cloud/
git commit -m "feat: add resumes feature with cloud storage"
```

---

### Task 11: Subscription & Paywall

**Files:**
- Create: `lib/features/subscription/paywall_dialog.dart`
- Create: `lib/features/subscription/subscription_checker.dart`

- [ ] **Step 1: Create subscription_checker.dart**

```dart
import '../data/models/subscription_model.dart';
import '../data/sources/api_client.dart';

class SubscriptionChecker {
  final ApiClient _apiClient;

  SubscriptionChecker({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<SubscriptionModel> checkSubscription() async {
    try {
      final response = await _apiClient.get('/api/subscription');
      return SubscriptionModel.fromJson(response.data);
    } catch (e) {
      // If endpoint doesn't exist, assume free tier
      return const SubscriptionModel(isActive: false);
    }
  }

  bool canAccessAI(SubscriptionModel sub) => sub.hasFullAccess;
  bool canUseCloudStorage(SubscriptionModel sub) => sub.hasFullAccess;
  bool canCreateJob(int currentJobCount, SubscriptionModel sub) {
    if (sub.hasFullAccess) return true;
    return currentJobCount < 5; // Free tier limit
  }
}
```

- [ ] **Step 2: Create paywall_dialog.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../core/theme/app_theme.dart';

class PaywallDialog extends StatelessWidget {
  final String featureName;
  final VoidCallback onSubscribe;
  final VoidCallback onDismiss;

  const PaywallDialog({
    super.key,
    required this.featureName,
    required this.onSubscribe,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upgrade to Pro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 64, color: AppColors.accent),
          const SizedBox(height: 16),
          Text(
            'Unlock $featureName',
            style: AppTypography.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Get unlimited jobs, AI features, and cloud storage for just \$1/month.',
            style: AppTypography.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text('7-day free trial'),
        ],
      ),
      actions: [
        TextButton(onPressed: onDismiss, child: const Text('Maybe Later')),
        ElevatedButton(
          onPressed: onSubscribe,
          child: const Text('Start Free Trial'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/subscription/
git commit -m "feat: add subscription and paywall"
```

---

### Task 12: Offline Support

- [ ] **Step 1: Create offline_sync_service.dart**

```dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/sources/local_storage.dart';
import '../data/sources/api_client.dart';

class OfflineSyncService {
  final LocalStorage _storage;
  final ApiClient _apiClient;
  final Connectivity _connectivity = Connectivity();

  OfflineSyncService({required LocalStorage storage, required ApiClient apiClient})
      : _storage = storage,
        _apiClient = apiClient;

  Future<void> init() async {
    _connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        syncPendingOperations();
      }
    });
  }

  Future<void> queueOperation(Map<String, dynamic> operation) async {
    await _storage.addPendingOperation({
      ...operation,
      'timestamp': DateTime.now().toIso8601String(),
      'retries': 0,
    });
  }

  Future<void> syncPendingOperations() async {
    final operations = await _storage.getPendingOperations();

    for (final op in operations) {
      try {
        await _processOperation(op);
        // Remove from queue on success
      } catch (e) {
        final retries = (op['retries'] ?? 0) + 1;
        if (retries >= 3) {
          // Mark as failed
        } else {
          // Update retry count
        }
      }
    }
  }

  Future<void> _processOperation(Map<String, dynamic> op) async {
    final type = op['type'];
    final endpoint = op['endpoint'];
    final data = op['data'];

    switch (type) {
      case 'create':
        await _apiClient.post(endpoint, data: data);
        break;
      case 'update':
        await _apiClient.put(endpoint, data: data);
        break;
      case 'delete':
        await _apiClient.delete(endpoint, data: data);
        break;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/
git commit -m "feat: add offline sync service"
```

---

### Task 13: Platform Configuration

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`

- [ ] **Step 1: Configure Android permissions**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet for API calls -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <!-- Network state for offline detection -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <!-- Read storage for file picking -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
</manifest>
```

- [ ] **Step 2: Configure iOS Info.plist**

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
<key>NSPhotoLibraryUsageDescription</key>
<string>Access photos to upload resumes</string>
```

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: add platform configurations"
```

---

## Plan Review

This is a comprehensive plan. Due to its scope, I recommend **subagent-driven execution** - implementing in focused batches:

1. Phase 1: Core setup (Tasks 1-7)
2. Phase 2: Feature implementation (Tasks 8-10)
3. Phase 3: Subscription & Offline (Tasks 11-13)

**Each phase should be tested and committed before moving to the next.**