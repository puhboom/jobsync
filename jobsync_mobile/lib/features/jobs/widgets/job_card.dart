import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/job_model.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      job.company.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.company, style: AppTypography.h4),
                        Text(job.position, style: AppTypography.body2),
                      ],
                    ),
                  ),
                  StatusChip(status: job.status),
                ],
              ),
              if (job.location != null || job.salary != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (job.location != null) ...[
                      const Icon(Icons.location_on,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(job.location!, style: AppTypography.caption),
                      const SizedBox(width: 12),
                    ],
                    if (job.salary != null) ...[
                      const Icon(Icons.attach_money,
                          size: 16, color: AppColors.textSecondary),
                      Text(job.salary!, style: AppTypography.caption),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
