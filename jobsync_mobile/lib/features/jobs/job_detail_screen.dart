import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/job_model.dart';
import 'job_form_screen.dart';
import 'bloc/jobs_bloc.dart';
import 'bloc/jobs_event.dart';
import 'bloc/jobs_state.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsBloc, JobsState>(
      listener: (context, state) {
        if (state is JobDescriptionParsed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Job description parsed successfully')),
          );
        } else if (state is ResumeGenerated) {
          _showResultDialog(context, 'Generated Resume', state.generatedResume);
        } else if (state is AtsAnalysisComplete) {
          _showAnalysisDialog(context, 'ATS Analysis', state.analysisResults);
        } else if (state is TechFitAnalysisComplete) {
          _showAnalysisDialog(
              context, 'Tech Fit Analysis', state.analysisResults);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Job Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                final jobsState = context.read<JobsBloc>().state;
                JobModel? job;
                if (jobsState is JobsLoaded) {
                  try {
                    job = jobsState.jobs.firstWhere((j) => j.id == jobId);
                  } catch (_) {}
                }
                if (job != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => JobFormScreen(job: job)),
                  ).then((_) {
                    if (context.mounted) {
                      context.read<JobsBloc>().add(JobsLoadRequested());
                    }
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<JobsBloc, JobsState>(
          builder: (context, state) {
            if (state is JobsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is JobsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<JobsBloc>().add(JobsLoadRequested()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            JobModel? job;
            if (state is JobsLoaded) {
              try {
                job = state.jobs.firstWhere((j) => j.id == jobId);
              } catch (_) {}
            }

            if (job == null) {
              return const Center(child: Text('Job not found'));
            }

            final isLoading = state is JobsLoading;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(job),
                      const SizedBox(height: 24),
                      _buildDetails(job),
                      const SizedBox(height: 24),
                      if (job.description != null) ...[
                        Text('Job Description', style: AppTypography.h3),
                        const SizedBox(height: 8),
                        Text(job.description!, style: AppTypography.body1),
                        const SizedBox(height: 24),
                      ],
                      if (job.keywords.isNotEmpty) ...[
                        Text('Keywords', style: AppTypography.h3),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: job.keywords
                              .map((k) => Chip(label: Text(k)))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text('AI Actions', style: AppTypography.h3),
                      const SizedBox(height: 12),
                      _buildAIActions(context, job),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(JobModel job) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary,
          child: Text(
            job.company.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.position, style: AppTypography.h2),
              Text(job.company, style: AppTypography.body1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(JobModel job) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (job.location != null)
              _buildDetailRow(Icons.location_on, 'Location', job.location!),
            if (job.salary != null)
              _buildDetailRow(Icons.attach_money, 'Salary', job.salary!),
            _buildDetailRow(
              Icons.calendar_today,
              'Applied',
              job.createdAt.toString().split(' ')[0],
            ),
            _buildDetailRow(Icons.flag, 'Status', job.status.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text('$label: ', style: AppTypography.body2),
          Text(value, style: AppTypography.body1),
        ],
      ),
    );
  }

  Widget _buildAIActions(BuildContext context, JobModel job) {
    return Column(
      children: [
        _buildAIButton(
          context,
          'Parse Description',
          Icons.auto_fix_high,
          () => context
              .read<JobsBloc>()
              .add(JobParseDescriptionRequested(job.id, job.description ?? '')),
        ),
        const SizedBox(height: 8),
        _buildAIButton(
          context,
          'Generate Resume',
          Icons.description,
          () =>
              context.read<JobsBloc>().add(JobGenerateResumeRequested(job.id)),
        ),
        const SizedBox(height: 8),
        _buildAIButton(
          context,
          'Run ATS Analysis',
          Icons.analytics,
          () => context.read<JobsBloc>().add(JobAnalyzeAtsRequested(job.id)),
        ),
        const SizedBox(height: 8),
        _buildAIButton(
          context,
          'Run Tech Fit Analysis',
          Icons.psychology,
          () =>
              context.read<JobsBloc>().add(JobAnalyzeTechFitRequested(job.id)),
        ),
      ],
    );
  }

  Widget _buildAIButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  void _showResultDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(fontSize: 13)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAnalysisDialog(
      BuildContext context, String title, Map<String, dynamic> results) {
    final buffer = StringBuffer();
    results.forEach((key, value) {
      if (value != null) {
        final displayKey = key
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');
        if (value is List) {
          buffer.writeln('$displayKey: ${value.join(', ')}');
        } else {
          buffer.writeln('$displayKey: $value');
        }
      }
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(buffer.toString(), style: const TextStyle(fontSize: 13)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<JobsBloc>().add(JobsDeleteRequested(jobId));
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
