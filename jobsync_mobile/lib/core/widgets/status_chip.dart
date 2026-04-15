import 'package:flutter/material.dart';
import '../../data/models/job_model.dart';
import '../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final JobStatus status;
  final bool showIcon;

  const StatusChip({
    super.key,
    required this.status,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData? icon;

    switch (status) {
      case JobStatus.saved:
        bgColor = AppColors.savedBg;
        textColor = AppColors.savedText;
        icon = Icons.save;
      case JobStatus.applied:
        bgColor = AppColors.appliedBg;
        textColor = AppColors.appliedText;
        icon = Icons.send;
      case JobStatus.phoneScreen:
        bgColor = AppColors.phoneScreenBg;
        textColor = AppColors.phoneScreenText;
        icon = Icons.phone;
      case JobStatus.interview:
        bgColor = AppColors.interviewBg;
        textColor = AppColors.interviewText;
        icon = Icons.people;
      case JobStatus.executiveCall:
        bgColor = AppColors.executiveCallBg;
        textColor = AppColors.executiveCallText;
        icon = Icons.corporate_fare;
      case JobStatus.offered:
        bgColor = AppColors.offeredBg;
        textColor = AppColors.offeredText;
        icon = Icons.celebration;
      case JobStatus.rejected:
        bgColor = AppColors.rejectedBg;
        textColor = AppColors.rejectedText;
        icon = Icons.close;
      case JobStatus.withdrawn:
        bgColor = AppColors.withdrawnBg;
        textColor = AppColors.withdrawnText;
        icon = Icons.cancel;
      case JobStatus.closed:
        bgColor = AppColors.closedBg;
        textColor = AppColors.closedText;
        icon = Icons.check;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            status.displayName,
            style: TextStyle(color: textColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
