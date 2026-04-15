import 'package:equatable/equatable.dart';
import '../../../data/models/subscription_model.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionModel subscription;

  const SubscriptionLoaded({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SubscriptionCheckoutStarted extends SubscriptionState {
  final String sessionId;

  const SubscriptionCheckoutStarted({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class SubscriptionUnsubscribed extends SubscriptionState {
  const SubscriptionUnsubscribed();
}
