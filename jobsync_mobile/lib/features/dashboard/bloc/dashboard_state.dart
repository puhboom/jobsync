import 'package:equatable/equatable.dart';
import '../../../data/models/job_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final Map<JobStatus, int> jobCounts;
  final List<JobModel> recentJobs;
  final int totalJobs;

  const DashboardLoaded({
    required this.jobCounts,
    required this.recentJobs,
    required this.totalJobs,
  });

  @override
  List<Object?> get props => [jobCounts, recentJobs, totalJobs];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
