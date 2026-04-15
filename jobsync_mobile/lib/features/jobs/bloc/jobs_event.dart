import 'package:equatable/equatable.dart';

abstract class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object?> get props => [];
}

class JobsLoadRequested extends JobsEvent {}

class JobsRefreshRequested extends JobsEvent {}

class JobsCreateRequested extends JobsEvent {
  final Map<String, dynamic> data;

  const JobsCreateRequested({required this.data});

  @override
  List<Object?> get props => [data];
}

class JobsUpdateRequested extends JobsEvent {
  final String id;
  final Map<String, dynamic> data;

  const JobsUpdateRequested({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class JobsDeleteRequested extends JobsEvent {
  final String id;

  const JobsDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class JobParseDescriptionRequested extends JobsEvent {
  final String jobId;
  final String description;

  const JobParseDescriptionRequested(this.jobId, this.description);

  @override
  List<Object?> get props => [jobId, description];
}

class JobGenerateResumeRequested extends JobsEvent {
  final String jobId;

  const JobGenerateResumeRequested(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class JobAnalyzeAtsRequested extends JobsEvent {
  final String jobId;

  const JobAnalyzeAtsRequested(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class JobAnalyzeTechFitRequested extends JobsEvent {
  final String jobId;

  const JobAnalyzeTechFitRequested(this.jobId);

  @override
  List<Object?> get props => [jobId];
}
