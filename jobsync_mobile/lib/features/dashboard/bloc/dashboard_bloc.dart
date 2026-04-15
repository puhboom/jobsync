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
      final response = await _apiClient.get('/api/dashboard/stats');

      if (response.statusCode == 200) {
        final jobsResponse = await _apiClient.get('/api/jobs');

        final jobs = (jobsResponse.data as List)
            .map((json) => JobModel.fromJson(json))
            .toList();

        // Calculate job counts by status
        final jobCounts = <JobStatus, int>{};
        for (final status in JobStatus.values) {
          jobCounts[status] = jobs.where((j) => j.status == status).length;
        }

        // Get recent jobs (last 5)
        final recentJobs = jobs.take(5).toList();

        emit(DashboardLoaded(
          jobCounts: jobCounts,
          recentJobs: recentJobs,
          totalJobs: jobs.length,
        ));
      } else {
        emit(DashboardError(message: 'Failed to load dashboard'));
      }
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
