import 'package:equatable/equatable.dart';
import '../../../data/models/resume_model.dart';

abstract class ResumesState extends Equatable {
  const ResumesState();

  @override
  List<Object?> get props => [];
}

class ResumesInitial extends ResumesState {
  const ResumesInitial();
}

class ResumesLoading extends ResumesState {
  const ResumesLoading();
}

class ResumesLoaded extends ResumesState {
  final List<BaseResumeModel> exampleResumes;
  final List<BaseResumeModel> templates;
  final List<GeneratedResumeModel> generatedResumes;

  const ResumesLoaded({
    required this.exampleResumes,
    required this.templates,
    required this.generatedResumes,
  });

  @override
  List<Object?> get props => [exampleResumes, templates, generatedResumes];
}

class ResumesError extends ResumesState {
  final String message;

  const ResumesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ResumeUploadSuccess extends ResumesState {
  final List<BaseResumeModel> exampleResumes;
  final List<BaseResumeModel> templates;
  final List<GeneratedResumeModel> generatedResumes;
  final String message;

  const ResumeUploadSuccess({
    required this.exampleResumes,
    required this.templates,
    required this.generatedResumes,
    required this.message,
  });

  @override
  List<Object?> get props => [exampleResumes, templates, generatedResumes, message];
}

class ResumeGenerated extends ResumesState {
  final List<BaseResumeModel> exampleResumes;
  final List<BaseResumeModel> templates;
  final List<GeneratedResumeModel> generatedResumes;
  final GeneratedResumeModel newResume;

  const ResumeGenerated({
    required this.exampleResumes,
    required this.templates,
    required this.generatedResumes,
    required this.newResume,
  });

  @override
  List<Object?> get props => [exampleResumes, templates, generatedResumes, newResume];
}

class ResumeExportSuccess extends ResumesState {
  final List<BaseResumeModel> exampleResumes;
  final List<BaseResumeModel> templates;
  final List<GeneratedResumeModel> generatedResumes;
  final String filePath;

  const ResumeExportSuccess({
    required this.exampleResumes,
    required this.templates,
    required this.generatedResumes,
    required this.filePath,
  });

  @override
  List<Object?> get props => [exampleResumes, templates, generatedResumes, filePath];
}