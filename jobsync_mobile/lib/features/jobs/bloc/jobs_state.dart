import 'package:equatable/equatable.dart';
import '../../../data/models/job_model.dart';

abstract class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object?> get props => [];
}

class JobsInitial extends JobsState {
  const JobsInitial();
}

class JobsLoading extends JobsState {
  const JobsLoading();
}

class JobsLoaded extends JobsState {
  final List<JobModel> jobs;

  const JobsLoaded({required this.jobs});

  @override
  List<Object?> get props => [jobs];
}

class JobsError extends JobsState {
  final String message;

  const JobsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// AI Operation States

class JobDescriptionParsed extends JobsState {
  final List<JobModel> jobs;
  final Map<String, dynamic> parsedData;

  const JobDescriptionParsed({
    required this.jobs,
    required this.parsedData,
  });

  @override
  List<Object?> get props => [jobs, parsedData];
}

class ResumeGenerated extends JobsState {
  final List<JobModel> jobs;
  final String generatedResume;
  final String jobId;

  const ResumeGenerated({
    required this.jobs,
    required this.generatedResume,
    required this.jobId,
  });

  @override
  List<Object?> get props => [jobs, generatedResume, jobId];
}

class AtsAnalysisComplete extends JobsState {
  final List<JobModel> jobs;
  final Map<String, dynamic> analysisResults;
  final String jobId;

  const AtsAnalysisComplete({
    required this.jobs,
    required this.analysisResults,
    required this.jobId,
  });

  @override
  List<Object?> get props => [jobs, analysisResults, jobId];
}

class TechFitAnalysisComplete extends JobsState {
  final List<JobModel> jobs;
  final Map<String, dynamic> analysisResults;
  final String jobId;

  const TechFitAnalysisComplete({
    required this.jobs,
    required this.analysisResults,
    required this.jobId,
  });

  @override
  List<Object?> get props => [jobs, analysisResults, jobId];
}
