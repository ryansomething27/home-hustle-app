import 'dart:convert';

/// Model representing a job posting in the Home Hustle app
class JobModel { // For additional flexible data

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.wage,
    required this.wageType,
    required this.jobType,
    required this.category,
    required this.status,
    required this.createdById,
    required this.createdByName,
    required this.createdAt, required this.updatedAt, this.assignedToId,
    this.assignedToName,
    this.startDate,
    this.endDate,
    this.completedAt,
    this.estimatedDuration,
    this.actualDuration,
    this.location,
    this.requiredSkills,
    this.imageUrls,
    this.maxApplicants,
    this.currentApplicants = 0,
    this.isUrgent = false,
    this.cancellationReason,
    this.completionNotes,
    this.rating,
    this.reviewNotes,
    this.metadata,
  });

  /// Create model from map
  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      wage: (map['wage'] ?? 0).toDouble(),
      wageType: map['wageType'] ?? 'fixed',
      jobType: map['jobType'] ?? 'public',
      category: map['category'] ?? 'Other',
      status: map['status'] ?? 'open',
      createdById: map['createdById'] ?? '',
      createdByName: map['createdByName'] ?? '',
      assignedToId: map['assignedToId'],
      assignedToName: map['assignedToName'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
      startDate: map['startDate'] != null 
          ? DateTime.parse(map['startDate']) 
          : null,
      endDate: map['endDate'] != null 
          ? DateTime.parse(map['endDate']) 
          : null,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
      estimatedDuration: map['estimatedDuration']?.toInt(),
      actualDuration: map['actualDuration']?.toInt(),
      location: map['location'],
      requiredSkills: map['requiredSkills'] != null 
          ? List<String>.from(map['requiredSkills']) 
          : null,
      imageUrls: map['imageUrls'] != null 
          ? List<String>.from(map['imageUrls']) 
          : null,
      maxApplicants: map['maxApplicants']?.toInt(),
      currentApplicants: map['currentApplicants']?.toInt() ?? 0,
      isUrgent: map['isUrgent'] ?? false,
      cancellationReason: map['cancellationReason'],
      completionNotes: map['completionNotes'],
      rating: map['rating']?.toDouble(),
      reviewNotes: map['reviewNotes'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata']) 
          : null,
    );
  }

  /// Create model from JSON string
  factory JobModel.fromJson(String source) => 
      JobModel.fromMap(json.decode(source));
  final String id;
  final String title;
  final String description;
  final double wage;
  final String wageType; // 'fixed' or 'hourly'
  final String jobType; // 'family' or 'public'
  final String category;
  final String status; // 'open', 'in_progress', 'completed', 'cancelled', 'pending_approval'
  final String createdById; // Adult/Employer who created the job
  final String createdByName; // Cached name for display
  final String? assignedToId; // Child/Employee assigned to the job
  final String? assignedToName; // Cached name for display
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? completedAt;
  final int? estimatedDuration; // in minutes
  final int? actualDuration; // in minutes
  final String? location;
  final List<String>? requiredSkills;
  final List<String>? imageUrls;
  final int? maxApplicants;
  final int currentApplicants;
  final bool isUrgent;
  final String? cancellationReason;
  final String? completionNotes;
  final double? rating;
  final String? reviewNotes;
  final Map<String, dynamic>? metadata;

  /// Computed property to check if job is available for application
  bool get isAvailable => status == 'open' && 
      (maxApplicants == null || currentApplicants < maxApplicants!);

  /// Computed property to check if job is active
  bool get isActive => status == 'open' || status == 'in_progress';

  /// Computed property to check if job is family job
  bool get isFamilyJob => jobType == 'family';

  /// Computed property to check if job is public job
  bool get isPublicJob => jobType == 'public';

  /// Computed property to get total wage (for fixed wage jobs)
  double get totalWage {
    if (wageType == 'fixed') {
      return wage;
    } else if (wageType == 'hourly' && actualDuration != null) {
      return wage * (actualDuration! / 60); // Convert minutes to hours
    } else if (wageType == 'hourly' && estimatedDuration != null) {
      return wage * (estimatedDuration! / 60); // Use estimated if actual not available
    }
    return wage;
  }

  /// Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'wage': wage,
      'wageType': wageType,
      'jobType': jobType,
      'category': category,
      'status': status,
      'createdById': createdById,
      'createdByName': createdByName,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'estimatedDuration': estimatedDuration,
      'actualDuration': actualDuration,
      'location': location,
      'requiredSkills': requiredSkills,
      'imageUrls': imageUrls,
      'maxApplicants': maxApplicants,
      'currentApplicants': currentApplicants,
      'isUrgent': isUrgent,
      'cancellationReason': cancellationReason,
      'completionNotes': completionNotes,
      'rating': rating,
      'reviewNotes': reviewNotes,
      'metadata': metadata,
    };
  }

  /// Convert model to JSON string
  String toJson() => json.encode(toMap());

  /// Create a copy of the model with updated fields
  JobModel copyWith({
    String? id,
    String? title,
    String? description,
    double? wage,
    String? wageType,
    String? jobType,
    String? category,
    String? status,
    String? createdById,
    String? createdByName,
    String? assignedToId,
    String? assignedToName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? completedAt,
    int? estimatedDuration,
    int? actualDuration,
    String? location,
    List<String>? requiredSkills,
    List<String>? imageUrls,
    int? maxApplicants,
    int? currentApplicants,
    bool? isUrgent,
    String? cancellationReason,
    String? completionNotes,
    double? rating,
    String? reviewNotes,
    Map<String, dynamic>? metadata,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      wage: wage ?? this.wage,
      wageType: wageType ?? this.wageType,
      jobType: jobType ?? this.jobType,
      category: category ?? this.category,
      status: status ?? this.status,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      completedAt: completedAt ?? this.completedAt,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      location: location ?? this.location,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      imageUrls: imageUrls ?? this.imageUrls,
      maxApplicants: maxApplicants ?? this.maxApplicants,
      currentApplicants: currentApplicants ?? this.currentApplicants,
      isUrgent: isUrgent ?? this.isUrgent,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      completionNotes: completionNotes ?? this.completionNotes,
      rating: rating ?? this.rating,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
  
    return other is JobModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'JobModel(id: $id, title: $title, status: $status, wage: $wage, jobType: $jobType)';
  }
}

/// Model representing a job application
class JobApplication {

  JobApplication({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.applicantName,
    required this.appliedAt,
    required this.status,
    this.applicationNote,
    this.rejectionReason,
    this.respondedAt,
    this.respondedById,
  });

  /// Create model from map
  factory JobApplication.fromMap(Map<String, dynamic> map) {
    return JobApplication(
      id: map['id'] ?? '',
      jobId: map['jobId'] ?? '',
      applicantId: map['applicantId'] ?? '',
      applicantName: map['applicantName'] ?? '',
      appliedAt: map['appliedAt'] != null 
          ? DateTime.parse(map['appliedAt']) 
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      applicationNote: map['applicationNote'],
      rejectionReason: map['rejectionReason'],
      respondedAt: map['respondedAt'] != null 
          ? DateTime.parse(map['respondedAt']) 
          : null,
      respondedById: map['respondedById'],
    );
  }

  /// Create model from JSON string
  factory JobApplication.fromJson(String source) => 
      JobApplication.fromMap(json.decode(source));
  final String id;
  final String jobId;
  final String applicantId; // Child/Employee who applied
  final String applicantName; // Cached name for display
  final DateTime appliedAt;
  final String status; // 'pending', 'approved', 'rejected', 'withdrawn'
  final String? applicationNote;
  final String? rejectionReason;
  final DateTime? respondedAt;
  final String? respondedById;

  /// Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'appliedAt': appliedAt.toIso8601String(),
      'status': status,
      'applicationNote': applicationNote,
      'rejectionReason': rejectionReason,
      'respondedAt': respondedAt?.toIso8601String(),
      'respondedById': respondedById,
    };
  }

  /// Convert model to JSON string
  String toJson() => json.encode(toMap());

  /// Create a copy of the model with updated fields
  JobApplication copyWith({
    String? id,
    String? jobId,
    String? applicantId,
    String? applicantName,
    DateTime? appliedAt,
    String? status,
    String? applicationNote,
    String? rejectionReason,
    DateTime? respondedAt,
    String? respondedById,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      appliedAt: appliedAt ?? this.appliedAt,
      status: status ?? this.status,
      applicationNote: applicationNote ?? this.applicationNote,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      respondedAt: respondedAt ?? this.respondedAt,
      respondedById: respondedById ?? this.respondedById,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
  
    return other is JobApplication && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'JobApplication(id: $id, jobId: $jobId, applicantId: $applicantId, status: $status)';
  }
}