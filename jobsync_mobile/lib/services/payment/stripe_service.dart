import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/models/subscription_model.dart';

class StripeService {
  final SubscriptionRepository _repository;

  StripeService({SubscriptionRepository? repository})
      : _repository = repository ?? SubscriptionRepository();

  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_placeholder',
  );

  bool _initialized = false;

  Future<bool> init() async {
    if (_initialized) return true;

    try {
      Stripe.publishableKey = publishableKey;
      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('Stripe init failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> openPaywall() async {
    try {
      final sessionData = await _repository.createCheckoutSession();
      final url = sessionData['url'] as String?;

      if (url != null) {
        return {'success': true, 'url': url};
      }

      return {'success': false, 'error': 'No checkout URL returned'};
    } catch (e) {
      debugPrint('Paywall error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<SubscriptionModel> checkSubscriptionStatus() async {
    return await _repository.getSubscription();
  }
}
