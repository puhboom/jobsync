import 'package:flutter/foundation.dart';
import '../../../data/repositories/subscription_repository.dart';
import '../../../data/models/subscription_model.dart';

class SubscriptionChecker {
  final SubscriptionRepository _repository;

  SubscriptionChecker({SubscriptionRepository? repository})
      : _repository = repository ?? SubscriptionRepository();

  Future<SubscriptionModel> checkSubscription() async {
    try {
      final response = await _repository.getSubscription();
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Subscription check failed: $e');
      }
      return const SubscriptionModel(isActive: false);
    }
  }

  bool canAccessAI(SubscriptionModel sub) => sub.hasFullAccess;
  bool canUseCloudStorage(SubscriptionModel sub) => sub.hasFullAccess;
  bool canCreateJob(int currentJobCount, SubscriptionModel sub) {
    if (sub.hasFullAccess) return true;
    return currentJobCount < 5;
  }
}
