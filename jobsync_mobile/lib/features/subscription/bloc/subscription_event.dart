import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class SubscriptionLoadRequested extends SubscriptionEvent {
  const SubscriptionLoadRequested();
}

class SubscriptionSubscribeRequested extends SubscriptionEvent {
  const SubscriptionSubscribeRequested();
}

class SubscriptionCancelRequested extends SubscriptionEvent {
  const SubscriptionCancelRequested();
}
