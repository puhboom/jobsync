import '../sources/api_client.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<UserModel?> getMe() async {
    try {
      final response = await _apiClient.get(ApiConstants.authMe);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _apiClient.post(ApiConstants.logout);
  }

  Future<Map<String, dynamic>> uploadPicture(String filePath) async {
    // Placeholder for file upload
    // Would need proper multipart request handling
    return {};
  }
}
