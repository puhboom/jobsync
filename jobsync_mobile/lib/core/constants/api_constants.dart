class ApiConstants {
  // TODO: Change for production
  // For development, use host.docker.internal for Docker on macOS
  // For production use ronning.systems endpoint for backend
  // static const String baseUrl = 'http://host.docker.internal:8000';
  static const String baseUrl = 'https://jobsync.ronning.systems';

  // Jobs
  static const String jobs = '/api/jobs';
  static String job(String id) => '/api/jobs/$id';
  static String parseDescription(String id) =>
      '/api/jobs/$id/parse-description';
  static String analyzeAts(String id) => '/api/jobs/$id/analyze-ats';
  static String analyzeTechFit(String id) => '/api/jobs/$id/analyze-tech-fit';
  static String jobHistory(String id) => '/api/jobs/$id/history';

  // Resumes
  static const String resumes = '/api/resumes';
  static const String generateResume = '/api/generate-resume';
  static String resume(String id) => '/api/resumes/$id';
  static const String generatedResumes = '/api/generated-resumes';
  static String generatedResume(String id) => '/api/generated-resumes/$id';
  static String exportResume(String id) => '/api/generated-resumes/$id/export';

  // Auth
  static const String oauthUrl = '/login';
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
