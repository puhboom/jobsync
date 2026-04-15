import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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