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
  final int activeApplications;
  final int interviewCount;
  final int offerCount;

  const DashboardLoaded({
    required this.jobCounts,
    required this.recentJobs,
    required this.totalJobs,
    this.activeApplications = 0,
    this.interviewCount = 0,
    this.offerCount = 0,
  });

  @override
  List<Object?> get props => [
        jobCounts,
        recentJobs,
        totalJobs,
        activeApplications,
        interviewCount,
        offerCount
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
