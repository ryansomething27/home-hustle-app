import '../../core/constants.dart';

class Job {
  final String jobId;
  final String creatorId;
  final String? assigneeId;
  final JobType type;
  final JobStatus status;
  final String title;
  final String description;
  final double wage;
  final String category;
  final JobLocation? location;
  final JobSchedule schedule;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  Job({
    required this.jobId,
    required this.creatorId,
    this.assigneeId,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.wage,
    required this.category,
    this.location,
    required this.schedule,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.metadata,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobId: json['jobId'] as String,
      creatorId: json['creatorId'] as String,
      assigneeId: json['assigneeId'] as String?,
      type: _parseJobType(json['type'] as String),
      status: _parseJobStatus(json['status'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      wage: (json['wage'] as num).toDouble(),
      category: json['category'] as String,
      location: json['location'] != null 
          ? JobLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      schedule: JobSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'creatorId': creatorId,
      'assigneeId': assigneeId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'title': title,
      'description': description,
      'wage': wage,
      'category': category,
      'location': location?.toJson(),
      'schedule': schedule.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  static JobType _parseJobType(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return JobType.home;
      case 'public':
        return JobType.public;
      default:
        throw ArgumentError('Invalid job type: $type');
    }
  }

  static JobStatus _parseJobStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return JobStatus.open;
      case 'pending':
        return JobStatus.pending;
      case 'assigned':
        return JobStatus.assigned;
      case 'completed':
        return JobStatus.completed;
      case 'resigned':
        return JobStatus.resigned;
      case 'cancelled':
        return JobStatus.cancelled;
      default:
        throw ArgumentError('Invalid job status: $status');
    }
  }

  Job copyWith({
    String? jobId,
    String? creatorId,
    String? assigneeId,
    JobType? type,
    JobStatus? status,
    String? title,
    String? description,
    double? wage,
    String? category,
    JobLocation? location,
    JobSchedule? schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Job(
      jobId: jobId ?? this.jobId,
      creatorId: creatorId ?? this.creatorId,
      assigneeId: assigneeId ?? this.assigneeId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      wage: wage ?? this.wage,
      category: category ?? this.category,
      location: location ?? this.location,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isPublic => type == JobType.public;
  bool get isHome => type == JobType.home;
  bool get isOpen => status == JobStatus.open;
  bool get isAssigned => status == JobStatus.assigned;
  bool get isCompleted => status == JobStatus.completed;
  bool get canApply => status == JobStatus.open && assigneeId == null;
}

class JobLocation {
  final String address;
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? zipCode;

  JobLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.zipCode,
  });

  factory JobLocation.fromJson(Map<String, dynamic> json) {
    return JobLocation(
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }
}

class JobSchedule {
  final bool isRecurring;
  final List<String> daysOfWeek;
  final String? startTime;
  final String? endTime;
  final DateTime? oneTimeDate;
  final String? frequency;
  final String? notes;

  JobSchedule({
    required this.isRecurring,
    this.daysOfWeek = const [],
    this.startTime,
    this.endTime,
    this.oneTimeDate,
    this.frequency,
    this.notes,
  });

  factory JobSchedule.fromJson(Map<String, dynamic> json) {
    return JobSchedule(
      isRecurring: json['isRecurring'] as bool,
      daysOfWeek: List<String>.from(json['daysOfWeek'] ?? []),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      oneTimeDate: json['oneTimeDate'] != null 
          ? DateTime.parse(json['oneTimeDate'] as String)
          : null,
      frequency: json['frequency'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isRecurring': isRecurring,
      'daysOfWeek': daysOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'oneTimeDate': oneTimeDate?.toIso8601String(),
      'frequency': frequency,
      'notes': notes,
    };
  }

  String get displaySchedule {
    if (!isRecurring && oneTimeDate != null) {
      return 'One time job';
    } else if (isRecurring && daysOfWeek.isNotEmpty) {
      return daysOfWeek.join(', ');
    } else {
      return 'Flexible schedule';
    }
  }
}

class JobApplication {
  final String applicationId;
  final String jobId;
  final String childId;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? respondedAt;
  final String? message;
  final String? parentApprovalId;

  JobApplication({
    required this.applicationId,
    required this.jobId,
    required this.childId,
    required this.status,
    required this.appliedAt,
    this.respondedAt,
    this.message,
    this.parentApprovalId,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      applicationId: json['applicationId'] as String,
      jobId: json['jobId'] as String,
      childId: json['childId'] as String,
      status: _parseApplicationStatus(json['status'] as String),
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
      message: json['message'] as String?,
      parentApprovalId: json['parentApprovalId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'jobId': jobId,
      'childId': childId,
      'status': status.toString().split('.').last,
      'appliedAt': appliedAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'message': message,
      'parentApprovalId': parentApprovalId,
    };
  }

  static ApplicationStatus _parseApplicationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'approved':
        return ApplicationStatus.approved;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      default:
        throw ArgumentError('Invalid application status: $status');
    }
  }

  bool get isPending => status == ApplicationStatus.pending;
  bool get isAccepted => status == ApplicationStatus.accepted;
  bool get needsParentApproval => isAccepted && parentApprovalId == null;
}

class JobCompletion {
  final String jobId;
  final String childId;
  final DateTime completedAt;
  final double? rating;
  final String? feedback;
  final bool paidStatus;
  final DateTime? paidAt;
  final double hoursWorked;

  JobCompletion({
    required this.jobId,
    required this.childId,
    required this.completedAt,
    this.rating,
    this.feedback,
    required this.paidStatus,
    this.paidAt,
    required this.hoursWorked,
  });

  factory JobCompletion.fromJson(Map<String, dynamic> json) {
    return JobCompletion(
      jobId: json['jobId'] as String,
      childId: json['childId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      rating: (json['rating'] as num?)?.toDouble(),
      feedback: json['feedback'] as String?,
      paidStatus: json['paidStatus'] as bool,
      paidAt: json['paidAt'] != null 
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      hoursWorked: (json['hoursWorked'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'childId': childId,
      'completedAt': completedAt.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
      'paidStatus': paidStatus,
      'paidAt': paidAt?.toIso8601String(),
      'hoursWorked': hoursWorked,
    };
  }
}