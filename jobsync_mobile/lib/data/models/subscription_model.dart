import 'package:equatable/equatable.dart';

class SubscriptionModel extends Equatable {
  final bool isActive;
  final DateTime? gracePeriodUntil;
  final DateTime? trialEndDate;
  final String? stripeCustomerId;

  const SubscriptionModel({
    required this.isActive,
    this.gracePeriodUntil,
    this.trialEndDate,
    this.stripeCustomerId,
  });

  bool get isInGracePeriod {
    if (gracePeriodUntil == null) return false;
    return DateTime.now().isBefore(gracePeriodUntil!);
  }

  bool get isInTrial {
    if (trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  bool get hasFullAccess => isActive || isInGracePeriod || isInTrial;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      isActive: json['is_active'] ?? false,
      gracePeriodUntil: json['grace_period_until'] != null
          ? DateTime.tryParse(json['grace_period_until'])
          : null,
      trialEndDate: json['trial_end_date'] != null
          ? DateTime.tryParse(json['trial_end_date'])
          : null,
      stripeCustomerId: json['stripe_customer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_active': isActive,
      'grace_period_until': gracePeriodUntil?.toIso8601String(),
      'trial_end_date': trialEndDate?.toIso8601String(),
      'stripe_customer_id': stripeCustomerId,
    };
  }

  @override
  List<Object?> get props => [
        isActive,
        gracePeriodUntil,
        trialEndDate,
        stripeCustomerId,
      ];
}
