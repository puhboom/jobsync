import 'package:equatable/equatable.dart';

/// Base resume model - uploaded example resumes and templates
class BaseResumeModel extends Equatable {
  final String id;
  final String filename;
  final String? contentType;
  final String fileType; // 'example' or 'template'
  final String? textContent;
  final DateTime createdAt;

  const BaseResumeModel({
    required this.id,
    required this.filename,
    this.contentType,
    required this.fileType,
    this.textContent,
    required this.createdAt,
  });

  factory BaseResumeModel.fromJson(Map<String, dynamic> json) {
    return BaseResumeModel(
      id: json['id']?.toString() ?? '',
      filename: json['filename'] ?? '',
      contentType: json['content_type'],
      fileType: json['file_type'] ?? 'example',
      textContent: json['text_content'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'content_type': contentType,
      'file_type': fileType,
      'text_content': textContent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, filename, contentType, fileType, textContent, createdAt];
}

class ResumeModel extends Equatable {
  final String id;
  final String name;
  final String? fileUrl;
  final String? contentType;
  final DateTime uploadedAt;

  const ResumeModel({
    required this.id,
    required this.name,
    this.fileUrl,
    this.contentType,
    required this.uploadedAt,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      fileUrl: json['file_url'],
      contentType: json['content_type'],
      uploadedAt: DateTime.tryParse(json['uploaded_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'file_url': fileUrl,
      'content_type': contentType,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, fileUrl, contentType, uploadedAt];
}

class GeneratedResumeModel extends Equatable {
  final String id;
  final String jobId;
  final String content;
  final DateTime createdAt;

  const GeneratedResumeModel({
    required this.id,
    required this.jobId,
    required this.content,
    required this.createdAt,
  });

  factory GeneratedResumeModel.fromJson(Map<String, dynamic> json) {
    return GeneratedResumeModel(
      id: json['id']?.toString() ?? '',
      jobId: json['job_id']?.toString() ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, jobId, content, createdAt];
}
