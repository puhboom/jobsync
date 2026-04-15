import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/sources/api_client.dart';
import '../../../data/models/job_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiClient _apiClient = ApiClient();

  DashboardBloc() : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final statsResponse = await _apiClient.get('/api/dashboard/stats');
      final jobsResponse = await _apiClient.get('/api/jobs');

      final stats = statsResponse.data as Map<String, dynamic>;
      final jobs = (jobsResponse.data as List)
          .map((json) => JobModel.fromJson(json))
          .toList();

      final jobCounts = <JobStatus, int>{};
      for (final status in JobStatus.values) {
        jobCounts[status] = jobs.where((j) => j.status == status).length;
      }

      final recentJobs = jobs.take(5).toList();

      emit(DashboardLoaded(
        jobCounts: jobCounts,
        recentJobs: recentJobs,
        totalJobs: stats['total_jobs'] as int? ?? jobs.length,
        activeApplications: stats['active_applications'] as int? ?? 0,
        interviewCount: stats['interviews'] as int? ?? 0,
        offerCount: stats['offers'] as int? ?? 0,
      ));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _onLoadRequested(DashboardLoadRequested(), emit);
  }
}
