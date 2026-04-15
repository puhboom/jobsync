import 'package:equatable/equatable.dart';

abstract class ResumesEvent extends Equatable {
  const ResumesEvent();

  @override
  List<Object?> get props => [];
}

class ResumesLoadRequested extends ResumesEvent {
  const ResumesLoadRequested();
}

class ResumesRefreshRequested extends ResumesEvent {
  const ResumesRefreshRequested();
}

class ResumesUploadRequested extends ResumesEvent {
  final String filePath;
  final String fileType; // 'example' or 'template'

  const ResumesUploadRequested({
    required this.filePath,
    required this.fileType,
  });

  @override
  List<Object?> get props => [filePath, fileType];
}

class ResumesDeleteRequested extends ResumesEvent {
  final String id;

  const ResumesDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class ResumesGenerateRequested extends ResumesEvent {
  final String jobId;
  final String? exampleResumeId;
  final String? templateId;

  const ResumesGenerateRequested({
    required this.jobId,
    this.exampleResumeId,
    this.templateId,
  });

  @override
  List<Object?> get props => [jobId, exampleResumeId, templateId];
}

class ResumesExportRequested extends ResumesEvent {
  final String generatedResumeId;

  const ResumesExportRequested({required this.generatedResumeId});

  @override
  List<Object?> get props => [generatedResumeId];
}