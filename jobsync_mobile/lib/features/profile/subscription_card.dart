import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

class SubscriptionCard extends StatelessWidget {
  final bool hasActiveSubscription;
  final VoidCallback? onSubscribe;

  const SubscriptionCard({
    super.key,
    required this.hasActiveSubscription,
    this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasActiveSubscription ? 'Pro Plan' : 'Free Plan',
                    style: AppTypography.h4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasActiveSubscription
                        ? 'You have full access to all features'
                        : 'Limit 5 jobs, limited AI features',
                    style: AppTypography.body2,
                  ),
                ],
              ),
            ),
            if (!hasActiveSubscription)
              ElevatedButton(
                onPressed: onSubscribe,
                child: const Text('Upgrade'),
              ),
          ],
        ),
      ),
    );
  }
}
