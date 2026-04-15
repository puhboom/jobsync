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
  static const String pendingOpsBox = 'pending_ops_box';
  static const String settingsBox = 'settings_box';

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userTokenKey = 'user_token';
}