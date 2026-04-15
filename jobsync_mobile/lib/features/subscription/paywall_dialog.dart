import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class PaywallDialog extends StatelessWidget {
  final String featureName;
  final VoidCallback onSubscribe;
  final VoidCallback onDismiss;

  const PaywallDialog({
    super.key,
    required this.featureName,
    required this.onSubscribe,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upgrade to Pro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 64, color: AppColors.accent),
          const SizedBox(height: 16),
          Text(
            'Unlock $featureName',
            style: AppTypography.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Get unlimited jobs, AI features, and cloud storage for just \$1/month.',
            style: AppTypography.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text('7-day free trial'),
        ],
      ),
      actions: [
        TextButton(onPressed: onDismiss, child: const Text('Maybe Later')),
        ElevatedButton(
          onPressed: onSubscribe,
          child: const Text('Start Free Trial'),
        ),
      ],
    );
  }
}
