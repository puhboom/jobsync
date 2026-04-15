import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/resumes_repository.dart';
import 'resumes_event.dart';
import 'resumes_state.dart';

class ResumesBloc extends Bloc<ResumesEvent, ResumesState> {
  final ResumesRepository _repository;

  ResumesBloc({ResumesRepository? repository})
      : _repository = repository ?? ResumesRepository(),
        super(const ResumesInitial()) {
    on<ResumesLoadRequested>(_onLoadRequested);
    on<ResumesRefreshRequested>(_onRefreshRequested);
    on<ResumesUploadRequested>(_onUploadRequested);
    on<ResumesDeleteRequested>(_onDeleteRequested);
    on<ResumesGenerateRequested>(_onGenerateRequested);
    on<ResumesExportRequested>(_onExportRequested);
  }

  Future<void> _onLoadRequested(
    ResumesLoadRequested event,
    Emitter<ResumesState> emit,
  ) async {
    emit(const ResumesLoading());

    try {
      final exampleResumes = await _repository.getExampleResumes();
      final templates = await _repository.getTemplates();
      final generatedResumes = await _repository.getGeneratedResumes();

      emit(ResumesLoaded(
        exampleResumes: exampleResumes,
        templates: templates,
        generatedResumes: generatedResumes,
      ));
    } catch (e) {
      emit(ResumesError(message: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    ResumesRefreshRequested event,
    Emitter<ResumesState> emit,
  ) async {
    await _onLoadRequested(const ResumesLoadRequested(), emit);
  }

  Future<void> _onUploadRequested(
    ResumesUploadRequested event,
    Emitter<ResumesState> emit,
  ) async {
    emit(const ResumesLoading());

    try {
      final file = File(event.filePath);
      final fileName = event.filePath.split('/').last;
      final fileType = event.fileType;

      await _repository.uploadResume(
        fileName: fileName,
        fileContent: base64Encode(await file.readAsBytes()),
        fileType: fileType,
      );

      // Reload all resumes
      final exampleResumes = await _repository.getExampleResumes();
      final templates = await _repository.getTemplates();
      final generatedResumes = await _repository.getGeneratedResumes();

      emit(ResumeUploadSuccess(
        exampleResumes: exampleResumes,
        templates: templates,
        generatedResumes: generatedResumes,
        message: 'Resume uploaded successfully',
      ));
    } catch (e) {
      emit(ResumesError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    ResumesDeleteRequested event,
    Emitter<ResumesState> emit,
  ) async {
    emit(const ResumesLoading());

    try {
      await _repository.deleteResume(event.id);

      // Reload all resumes
      final exampleResumes = await _repository.getExampleResumes();
      final templates = await _repository.getTemplates();
      final generatedResumes = await _repository.getGeneratedResumes();

      emit(ResumesLoaded(
        exampleResumes: exampleResumes,
        templates: templates,
        generatedResumes: generatedResumes,
      ));
    } catch (e) {
      emit(ResumesError(message: e.toString()));
    }
  }

  Future<void> _onGenerateRequested(
    ResumesGenerateRequested event,
    Emitter<ResumesState> emit,
  ) async {
    emit(const ResumesLoading());

    try {
      final newResume = await _repository.generateResume(
        jobId: event.jobId,
        exampleResumeId: event.exampleResumeId,
        templateId: event.templateId,
      );

      // Reload all resumes
      final exampleResumes = await _repository.getExampleResumes();
      final templates = await _repository.getTemplates();
      final generatedResumes = await _repository.getGeneratedResumes();

      emit(ResumeGenerated(
        exampleResumes: exampleResumes,
        templates: templates,
        generatedResumes: generatedResumes,
        newResume: newResume,
      ));
    } catch (e) {
      emit(ResumesError(message: e.toString()));
    }
  }

  Future<void> _onExportRequested(
    ResumesExportRequested event,
    Emitter<ResumesState> emit,
  ) async {
    emit(const ResumesLoading());

    try {
      final filePath = await _repository.exportResume(event.generatedResumeId);

      // Reload all resumes
      final exampleResumes = await _repository.getExampleResumes();
      final templates = await _repository.getTemplates();
      final generatedResumes = await _repository.getGeneratedResumes();

      emit(ResumeExportSuccess(
        exampleResumes: exampleResumes,
        templates: templates,
        generatedResumes: generatedResumes,
        filePath: filePath,
      ));
    } catch (e) {
      emit(ResumesError(message: e.toString()));
    }
  }
}