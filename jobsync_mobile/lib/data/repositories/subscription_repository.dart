import '../sources/api_client.dart';
import '../models/subscription_model.dart';
import '../../core/constants/api_constants.dart';

class SubscriptionRepository {
  final ApiClient _apiClient;

  SubscriptionRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<SubscriptionModel> getSubscription() async {
    try {
      final response = await _apiClient.get(ApiConstants.subscription);
      return SubscriptionModel.fromJson(response.data);
    } catch (e) {
      // If endpoint doesn't exist, assume free tier
      return const SubscriptionModel(isActive: false);
    }
  }

  Future<Map<String, dynamic>> createCheckoutSession() async {
    final response = await _apiClient.post(ApiConstants.subscription);
    return response.data;
  }

  Future<void> cancelSubscription() async {
    await _apiClient.delete(ApiConstants.subscription);
  }
}
