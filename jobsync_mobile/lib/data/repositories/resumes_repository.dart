import '../sources/api_client.dart';
import '../models/resume_model.dart';
import '../../core/constants/api_constants.dart';

class ResumesRepository {
  final ApiClient _apiClient;

  ResumesRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Get example resumes (used for content reference)
  Future<List<BaseResumeModel>> getExampleResumes() async {
    final response = await _apiClient.get(
      ApiConstants.resumes,
      queryParameters: {'file_type': 'example'},
    );
    return (response.data as List)
        .map((json) => BaseResumeModel.fromJson(json))
        .toList();
  }

  // Get resume templates (used for formatting)
  Future<List<BaseResumeModel>> getTemplates() async {
    final response = await _apiClient.get(
      ApiConstants.resumes,
      queryParameters: {'file_type': 'template'},
    );
    return (response.data as List)
        .map((json) => BaseResumeModel.fromJson(json))
        .toList();
  }

  // Get all resumes
  Future<List<BaseResumeModel>> getResumes() async {
    final response = await _apiClient.get(ApiConstants.resumes);
    return (response.data as List)
        .map((json) => BaseResumeModel.fromJson(json))
        .toList();
  }

  Future<BaseResumeModel> getResume(String id) async {
    final response = await _apiClient.get(ApiConstants.resume(id));
    return BaseResumeModel.fromJson(response.data);
  }

  // Upload a resume (example or template)
  Future<BaseResumeModel> uploadResume({
    required String fileName,
    required String fileContent,
    required String fileType,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.resumes,
      data: {
        'filename': fileName,
        'content': fileContent,
        'file_type': fileType,
      },
    );
    return BaseResumeModel.fromJson(response.data);
  }

  Future<void> deleteResume(String id) async {
    await _apiClient.delete(ApiConstants.resume(id));
  }

  // Generate a tailored resume for a job
  Future<GeneratedResumeModel> generateResume({
    required String jobId,
    String? exampleResumeId,
    String? templateId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.generateResume,
      data: {
        'job_id': jobId,
        'example_resume_id': exampleResumeId,
        'template_id': templateId,
      },
    );
    return GeneratedResumeModel.fromJson(response.data);
  }

  // Get generated resumes
  Future<List<GeneratedResumeModel>> getGeneratedResumes() async {
    final response = await _apiClient.get(ApiConstants.generatedResumes);
    return (response.data as List)
        .map((json) => GeneratedResumeModel.fromJson(json))
        .toList();
  }

  // Get a specific generated resume
  Future<GeneratedResumeModel> getGeneratedResume(String id) async {
    final response = await _apiClient.get(ApiConstants.generatedResume(id));
    return GeneratedResumeModel.fromJson(response.data);
  }

  // Export resume to DOCX - returns file path
  Future<String> exportResume(String id) async {
    final response = await _apiClient.get(ApiConstants.exportResume(id));
    return response.data['file_path'] as String;
  }
}
