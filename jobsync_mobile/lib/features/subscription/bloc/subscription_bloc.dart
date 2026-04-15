import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;

  SubscriptionBloc({SubscriptionRepository? repository})
      : _repository = repository ?? SubscriptionRepository(),
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
      final response = await _repository.createCheckoutSession();
      // Return session ID to trigger Stripe payment
      emit(SubscriptionCheckoutStarted(sessionId: response['session_id']));
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
