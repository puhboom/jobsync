import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/repositories/subscription_repository.dart';
import '../../../data/models/subscription_model.dart';
import '../../../services/payment/stripe_service.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;
  final StripeService _stripeService;

  SubscriptionBloc(
      {SubscriptionRepository? repository, StripeService? stripeService})
      : _repository = repository ?? SubscriptionRepository(),
        _stripeService = stripeService ?? StripeService(),
        super(SubscriptionInitial()) {
    on<SubscriptionLoadRequested>(_onLoadRequested);
    on<SubscriptionSubscribeRequested>(_onSubscribeRequested);
    on<SubscriptionCancelRequested>(_onCancelRequested);
  }

  Future<void> _onLoadRequested(
    SubscriptionLoadRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    try {
      final subscription = await _repository.getSubscription();
      emit(SubscriptionLoaded(subscription: subscription));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onSubscribeRequested(
    SubscriptionSubscribeRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    try {
      final result = await _stripeService.openPaywall();

      if (result['success'] == true && result['url'] != null) {
        final uri = Uri.parse(result['url'] as String);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        emit(SubscriptionCheckoutStarted(sessionId: 'checkout_url'));
      } else {
        final errorMsg = result['error'] as String? ?? 'Checkout failed';
        emit(SubscriptionError(message: errorMsg));
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onCancelRequested(
    SubscriptionCancelRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    try {
      await _repository.cancelSubscription();
      emit(SubscriptionUnsubscribed());
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }
}
