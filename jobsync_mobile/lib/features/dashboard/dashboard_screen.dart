import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/job_model.dart';
import '../../data/models/subscription_model.dart';
import '../../features/subscription/bloc/subscription_bloc.dart';
import '../../features/subscription/bloc/subscription_event.dart';
import '../../features/subscription/bloc/subscription_state.dart';
import '../../features/subscription/paywall_dialog.dart';
import '../../features/subscription/subscription_checker.dart';
import '../jobs/job_form_screen.dart';
import '../jobs/job_detail_screen.dart';
import '../jobs/bloc/jobs_bloc.dart';
import '../jobs/bloc/jobs_event.dart';
import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_event.dart';
import 'bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen first appears
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<DashboardBloc>()
                  .add(const DashboardRefreshRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<DashboardBloc>()
                          .add(const DashboardLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<DashboardBloc>()
                    .add(const DashboardRefreshRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    _buildStatsGrid(state),
                    const SizedBox(height: 24),
                    // Recent Jobs
                    Text('Recent Applications', style: AppTypography.h3),
                    const SizedBox(height: 12),
                    _buildRecentJobs(context, state),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddJob(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardLoaded state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Jobs',
          state.totalJobs.toString(),
          Icons.work,
          AppColors.primary,
        ),
        _buildStatCard(
          'Applied',
          (state.jobCounts[JobStatus.applied] ?? 0).toString(),
          Icons.send,
          AppColors.appliedText,
        ),
        _buildStatCard(
          'Interviews',
          ((state.jobCounts[JobStatus.interview] ?? 0) +
                  (state.jobCounts[JobStatus.phoneScreen] ?? 0) +
                  (state.jobCounts[JobStatus.executiveCall] ?? 0))
              .toString(),
          Icons.people,
          AppColors.interviewText,
        ),
        _buildStatCard(
          'Offers',
          (state.jobCounts[JobStatus.offered] ?? 0).toString(),
          Icons.celebration,
          AppColors.offeredText,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTypography.h2.copyWith(color: color),
                ),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(label, style: AppTypography.caption),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentJobs(BuildContext context, DashboardLoaded state) {
    if (state.recentJobs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.work_outline,
                    size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                Text(
                  'No jobs yet',
                  style: AppTypography.body2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add your first job',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.recentJobs.length,
      itemBuilder: (context, index) {
        final job = state.recentJobs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                job.company.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(job.company, style: AppTypography.body1),
            subtitle: Text(job.position, style: AppTypography.caption),
            trailing: _buildStatusChip(job.status),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => JobDetailScreen(jobId: job.id)),
              ).then((_) {
                if (context.mounted) {
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardRefreshRequested());
                }
              });
            },
          ),
        );
      },
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

  Future<void> _onAddJob(BuildContext context) async {
    final subState = context.read<SubscriptionBloc>().state;
    final dashboardState = context.read<DashboardBloc>().state;

    int jobCount = 0;
    if (dashboardState is DashboardLoaded) {
      jobCount = dashboardState.totalJobs;
    }

    SubscriptionModel? subModel;
    if (subState is SubscriptionLoaded) {
      subModel = subState.subscription;
    } else {
      final checker = SubscriptionChecker();
      subModel = await checker.checkSubscription();
    }

    final checker = SubscriptionChecker();
    if (!checker.canCreateJob(jobCount, subModel)) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => PaywallDialog(
            featureName: 'unlimited job tracking',
            onSubscribe: () {
              Navigator.pop(ctx);
              context
                  .read<SubscriptionBloc>()
                  .add(const SubscriptionSubscribeRequested());
            },
            onDismiss: () => Navigator.pop(ctx),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const JobFormScreen()),
      ).then((_) {
        if (context.mounted) {
          context.read<DashboardBloc>().add(const DashboardRefreshRequested());
        }
      });
    }
  }
}
