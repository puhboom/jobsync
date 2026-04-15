import 'package:equatable/equatable.dart';

enum JobStatus {
  saved,
  applied,
  phoneScreen,
  interview,
  executiveCall,
  offered,
  rejected,
  withdrawn,
  closed;

  String get displayName {
    switch (this) {
      case JobStatus.saved:
        return 'Saved';
      case JobStatus.applied:
        return 'Applied';
      case JobStatus.phoneScreen:
        return 'Phone Screen';
      case JobStatus.interview:
        return 'Interview';
      case JobStatus.executiveCall:
        return 'Executive Call';
      case JobStatus.offered:
        return 'Offered';
      case JobStatus.rejected:
        return 'Rejected';
      case JobStatus.withdrawn:
        return 'Withdrawn';
      case JobStatus.closed:
        return 'Closed';
    }
  }

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase().replaceAll(' ', ''),
      orElse: () => JobStatus.saved,
    );
  }
}

class JobModel extends Equatable {
  final String id;
  final String company;
  final String position;
  final String? location;
  final String? salary;
  final JobStatus status;
  final String? description;
  final List<String> requirements;
  final List<String> keywords;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const JobModel({
    required this.id,
    required this.company,
    required this.position,
    this.location,
    this.salary,
    required this.status,
    this.description,
    this.requirements = const [],
    this.keywords = const [],
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']?.toString() ?? '',
      company: json['company'] ?? '',
      position: json['position'] ?? '',
      location: json['location'],
      salary: json['salary']?.toString(),
      status: JobStatus.fromString(json['status'] ?? 'saved'),
      description: json['description'],
      requirements: List<String>.from(json['requirements'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'location': location,
      'salary': salary,
      'status': status.displayName,
      'description': description,
      'requirements': requirements,
      'keywords': keywords,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  JobModel copyWith({
    String? id,
    String? company,
    String? position,
    String? location,
    String? salary,
    JobStatus? status,
    String? description,
    List<String>? requirements,
    List<String>? keywords,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      keywords: keywords ?? this.keywords,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        company,
        position,
        location,
        salary,
        status,
        description,
        requirements,
        keywords,
        notes,
        createdAt,
        updatedAt,
      ];
}
