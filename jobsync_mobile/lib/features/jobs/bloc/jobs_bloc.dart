import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/jobs_repository.dart';
import 'jobs_event.dart';
import 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final JobsRepository _repository;

  JobsBloc({JobsRepository? repository})
      : _repository = repository ?? JobsRepository(),
        super(JobsInitial()) {
    on<JobsLoadRequested>(_onLoadRequested);
    on<JobsRefreshRequested>(_onRefreshRequested);
    on<JobsCreateRequested>(_onCreateRequested);
    on<JobsUpdateRequested>(_onUpdateRequested);
    on<JobsDeleteRequested>(_onDeleteRequested);
    on<JobParseDescriptionRequested>(_onParseDescriptionRequested);
    on<JobGenerateResumeRequested>(_onGenerateResumeRequested);
    on<JobAnalyzeAtsRequested>(_onAnalyzeAtsRequested);
    on<JobAnalyzeTechFitRequested>(_onAnalyzeTechFitRequested);
  }

  Future<void> _onLoadRequested(
    JobsLoadRequested event,
    Emitter<JobsState> emit,
  ) async {
    emit(JobsLoading());

    try {
      final jobs = await _repository.getJobs();
      emit(JobsLoaded(jobs: jobs));
    } catch (e) {
      emit(JobsError(message: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    JobsRefreshRequested event,
    Emitter<JobsState> emit,
  ) async {
    await _onLoadRequested(JobsLoadRequested(), emit);
  }

  Future<void> _onCreateRequested(
    JobsCreateRequested event,
    Emitter<JobsState> emit,
  ) async {
    emit(JobsLoading());

    try {
      await _repository.createJob(event.data);
      final jobs = await _repository.getJobs();
      emit(JobsLoaded(jobs: jobs));
    } catch (e) {
      emit(JobsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    JobsUpdateRequested event,
    Emitter<JobsState> emit,
  ) async {
    emit(JobsLoading());

    try {
      await _repository.updateJob(event.id, event.data);
      final jobs = await _repository.getJobs();
      emit(JobsLoaded(jobs: jobs));
    } catch (e) {
      emit(JobsError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    JobsDeleteRequested event,
    Emitter<JobsState> emit,
  ) async {
    emit(JobsLoading());

    try {
      await _repository.deleteJob(event.id);
      final jobs = await _repository.getJobs();
      emit(JobsLoaded(jobs: jobs));
    } catch (e) {
      emit(JobsError(message: e.toString()));
    }
  }

  Future<void> _onParseDescriptionRequested(
    JobParseDescriptionRequested event,
    Emitter<JobsState> emit,
  ) async {
    emit(const JobsLoading());

    try {
      final parsedData = await _repository.parseDescription(
        event.jobId,
        event.description,
      );
      // Refresh jobs list and emit parsed data
      final jobs = await _repository.getJobs();
      emit(JobDescriptionParsed(jobs: jobs, parsedData: parsedData));
    } catch (e) {
      emit(JobsError(message: e.toString()));
    }
  }

  Future<void> _onGenerateResumeRequested(
    JobGenerateResumeRequested event,
    Emitter<JobsState> emit,
  ) async {
    emit(const JobsLoading());

    try {
      final result = await _repository.generateResume(event.jobId, '');
      final generatedResume = result['content'] as String? ?? '';
      final jobs = await _repository.getJobs();
      emit(ResumeGenerated(
        jobs: jobs,
        generatedResume: generatedResume,
        jobId: event.jobId,
      ));
    } catch (e) {
      emit(JobsError(message: e.toString()));
    }
  }

  Future<void> _onAnalyzeAtsRequested(
    JobAnalyzeAtsRequested event,
    Emitter<JobsState> emit,
  ) async {
    emit(const JobsLoading());

    try {
      final analysisResults = await _repository.analyzeAts(event.jobId, '');
      final jobs = await _repository.getJobs();
      emit(AtsAnalysisComplete(
        jobs: jobs,
        analysisResults: analysisResults,
        jobId: event.jobId,
      ));
    } catch (e) {
      emit(JobsError(message: e.toString()));
    }
  }

  Future<void> _onAnalyzeTechFitRequested(
    JobAnalyzeTechFitRequested event,
    Emitter<JobsState> emit,
  ) async {
    emit(const JobsLoading());

    try {
      final analysisResults = await _repository.analyzeTechFit(event.jobId);
      final jobs = await _repository.getJobs();
      emit(TechFitAnalysisComplete(
        jobs: jobs,
        analysisResults: analysisResults,
        jobId: event.jobId,
      ));
    } catch (e) {
      emit(JobsError(message: e.toString()));
    }
  }
}
