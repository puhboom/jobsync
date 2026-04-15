import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
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
      margin: EdgeInsets.only(bottom: 12),
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
                  _buildStatusChip(job.status),
                ],
              ),
              if (job.location != null || job.salary != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (job.location != null) ...[
                      const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(job.location!, style: AppTypography.caption),
                      const SizedBox(width: 12),
                    ],
                    if (job.salary != null) ...[
                      const Icon(Icons.attach_money, size: 16, color: AppColors.textSecondary),
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

  Widget _buildStatusChip(JobStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case JobStatus.saved:
        bgColor = AppColors.savedBg;
        textColor = AppColors.savedText;
      case JobStatus.applied:
        bgColor = AppColors.appliedBg;
        textColor = AppColors.appliedText;
      case JobStatus.phoneScreen:
        bgColor = AppColors.phoneScreenBg;
        textColor = AppColors.phoneScreenText;
      case JobStatus.interview:
        bgColor = AppColors.interviewBg;
        textColor = AppColors.interviewText;
      case JobStatus.executiveCall:
        bgColor = AppColors.executiveCallBg;
        textColor = AppColors.executiveCallText;
      case JobStatus.offered:
        bgColor = AppColors.offeredBg;
        textColor = AppColors.offeredText;
      case JobStatus.rejected:
        bgColor = AppColors.rejectedBg;
        textColor = AppColors.rejectedText;
      case JobStatus.withdrawn:
        bgColor = AppColors.withdrawnBg;
        textColor = AppColors.withdrawnText;
      case JobStatus.closed:
        bgColor = AppColors.closedBg;
        textColor = AppColors.closedText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
    );
  }
}
