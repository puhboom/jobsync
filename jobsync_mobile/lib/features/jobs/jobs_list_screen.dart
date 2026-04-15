import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/job_model.dart';
import 'job_detail_screen.dart';
import 'job_form_screen.dart';
import 'bloc/jobs_bloc.dart';
import 'bloc/jobs_event.dart';
import 'bloc/jobs_state.dart';
import 'widgets/job_card.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  String _searchQuery = '';
  JobStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsBloc>().add(JobsLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // Filter chips
          if (_filterStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(_filterStatus!.displayName),
                    onDeleted: () => setState(() => _filterStatus = null),
                  ),
                ],
              ),
            ),
          // Jobs list
          Expanded(
            child: BlocBuilder<JobsBloc, JobsState>(
              builder: (context, state) {
                if (state is JobsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is JobsError) {
                  return Center(child: Text(state.message));
                }

                if (state is JobsLoaded) {
                  var jobs = state.jobs;

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    jobs = jobs
                        .where((job) =>
                            job.company
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            job.position
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                        .toList();
                  }

                  // Apply status filter
                  if (_filterStatus != null) {
                    jobs = jobs
                        .where((job) => job.status == _filterStatus)
                        .toList();
                  }

                  if (jobs.isEmpty) {
                    return const Center(child: Text('No jobs found'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<JobsBloc>().add(JobsRefreshRequested());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        return JobCard(
                          job: jobs[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      JobDetailScreen(jobId: jobs[index].id)),
                            ).then((_) {
                              if (context.mounted) {
                                context
                                    .read<JobsBloc>()
                                    .add(JobsLoadRequested());
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JobFormScreen()),
          ).then((_) {
            if (context.mounted) {
              context.read<JobsBloc>().add(JobsLoadRequested());
            }
          });
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Filter by Status', style: AppTypography.h3),
            ),
            ...JobStatus.values.map((status) {
              return ListTile(
                title: Text(status.displayName),
                trailing:
                    _filterStatus == status ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _filterStatus = status);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }
}
