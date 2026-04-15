import '../sources/api_client.dart';
import '../models/job_model.dart';
import '../../core/constants/api_constants.dart';

class JobsRepository {
  final ApiClient _apiClient;

  JobsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<JobModel>> getJobs() async {
    final response = await _apiClient.get(ApiConstants.jobs);
    return (response.data as List).map((json) => JobModel.fromJson(json)).toList();
  }

  Future<JobModel> getJob(String id) async {
    final response = await _apiClient.get(ApiConstants.job(id));
    return JobModel.fromJson(response.data);
  }

  Future<JobModel> createJob(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.jobs, data: data);
    return JobModel.fromJson(response.data);
  }

  Future<JobModel> updateJob(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(ApiConstants.job(id), data: data);
    return JobModel.fromJson(response.data);
  }

  Future<void> deleteJob(String id) async {
    await _apiClient.delete(ApiConstants.job(id));
  }

  Future<Map<String, dynamic>> parseDescription(String id, String description) async {
    final response = await _apiClient.post(
      ApiConstants.parseDescription(id),
      data: {'description': description},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> analyzeAts(String id, String resumeId) async {
    final response = await _apiClient.post(
      ApiConstants.analyzeAts(id),
      data: {'resume_id': resumeId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> analyzeTechFit(String id) async {
    final response = await _apiClient.post(ApiConstants.analyzeTechFit(id));
    return response.data;
  }

  Future<Map<String, dynamic>> generateResume(String jobId, String content) async {
    final response = await _apiClient.post(
      ApiConstants.generateResume,
      data: {'job_id': jobId, 'content': content},
    );
    return response.data;
  }
}
