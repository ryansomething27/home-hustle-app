import '../../core/constants.dart';
import '../models/job.dart';
import 'api_service.dart';
import 'auth_service.dart';

class JobService {

  JobService({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;
  final ApiService _apiService;
  final AuthService _authService;

  // Create a new job (parent or employer)
  Future<Job> createJob({
    required String title,
    required String description,
    required double wage,
    required JobType type,
    required String category,
    String? location,
    String? address,
    JobSchedule? schedule,
    String? assignedChildId,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final requestBody = {
      'creatorId': userId,
      'jobDetails': {
        'title': title,
        'description': description,
        'wage': wage,
        'type': type.toString().split('.').last,
        'category': category,
        if (location != null) 'location': location,
        if (address != null) 'address': address,
        if (schedule != null) 'schedule': schedule.toJson(),
        if (assignedChildId != null) 'assignedChildId': assignedChildId,
      },
    };

    final response = await _apiService.post('/jobs/create', requestBody);
    return Job.fromJson(response);
  }

  // Get all jobs for current user
  Future<List<Job>> getJobs() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final response = await _apiService.get(
      '/jobs/list',
      params: {'userId': userId},
    );

    return (response['jobs'] as List)
        .map((json) => Job.fromJson(json))
        .toList();
  }

  // Get job by ID
  Future<Job> getJobById(String jobId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final response = await _apiService.get('/jobs/$jobId');
    return Job.fromJson(response);
  }

  // Apply to a job (child)
  Future<JobApplication> applyToJob({
    required String jobId,
    String? applicationNote,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final requestBody = {
      'jobId': jobId,
      'childId': userId,
      if (applicationNote != null) 'applicationNote': applicationNote,
    };

    final response = await _apiService.post('/jobs/apply', requestBody);
    return JobApplication.fromJson(response);
  }

  // Approve job offer (parent)
  Future<void> approveJobOffer({
    required String applicationId,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    await _apiService.post('/jobs/approve-offer', {
      'applicationId': applicationId,
      'parentId': userId,
    });
  }

  // Reject job offer (parent)
  Future<void> rejectJobOffer({
    required String applicationId,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    await _apiService.post('/jobs/reject-offer', {
      'applicationId': applicationId,
      'parentId': userId,
    });
  }

  // Complete a job
  Future<void> completeJob({
    required String jobId,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    await _apiService.post('/jobs/complete', {
      'jobId': jobId,
      'childId': userId,
    });
  }

  // Resign from a job
  Future<void> resignFromJob({
    required String jobId,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    await _apiService.post('/jobs/resign', {
      'jobId': jobId,
      'childId': userId,
    });
  }

  // Get nearby public jobs (marketplace)
  Future<List<Job>> getNearbyJobs({
    required double radiusMiles,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final response = await _apiService.get(
      '/marketplace/nearby-jobs',
      params: {'radiusMiles': radiusMiles},
    );

    return (response['jobs'] as List)
        .map((json) => Job.fromJson(json))
        .toList();
  }

  // Mark job as paid (employer)
  Future<void> markJobAsPaid({
    required String jobId,
    required String childId,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    await _apiService.post('/marketplace/mark-paid', {
      'jobId': jobId,
      'childId': childId,
    });
  }

  // Update job details (parent/employer)
  Future<Job> updateJob({
    required String jobId,
    String? title,
    String? description,
    double? wage,
    String? category,
    String? location,
    JobSchedule? schedule,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final updates = <String, dynamic>{};
    if (title != null) {
      updates['title'] = title;
    }
    if (description != null) {
      updates['description'] = description;
    }
    if (wage != null) {
      updates['wage'] = wage;
    }
    if (category != null) {
      updates['category'] = category;
    }
    if (location != null) {
      updates['location'] = location;
    }
    if (schedule != null) {
      updates['schedule'] = schedule.toJson();
    }

    final response = await _apiService.patch('/jobs/$jobId', updates);
    return Job.fromJson(response);
  }

  // Delete job (parent/employer)
  Future<void> deleteJob(String jobId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    await _apiService.delete('/jobs/$jobId');
  }

  // Get job applications for a job (parent/employer)
  Future<List<JobApplication>> getJobApplications(String jobId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final response = await _apiService.get('/jobs/$jobId/applications');

    return (response['applications'] as List)
        .map((json) => JobApplication.fromJson(json))
        .toList();
  }

  // Get applications for a child
  Future<List<JobApplication>> getChildApplications(String childId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final response = await _apiService.get(
      '/jobs/applications',
      params: {'childId': childId},
    );

    return (response['applications'] as List)
        .map((json) => JobApplication.fromJson(json))
        .toList();
  }

  // Accept job application (employer)
  Future<void> acceptApplication({
    required String applicationId,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    await _apiService.post('/jobs/accept-application', {
      'applicationId': applicationId,
    });
  }

  // Reject job application (employer)
  Future<void> rejectApplication({
    required String applicationId,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    await _apiService.post('/jobs/reject-application', {
      'applicationId': applicationId,
    });
  }

  // Get active jobs for child
  Future<List<Job>> getActiveJobsForChild(String childId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final response = await _apiService.get(
      '/jobs/active',
      params: {'childId': childId},
    );

    return (response['jobs'] as List)
        .map((json) => Job.fromJson(json))
        .toList();
  }

  // Get job history for resume
  Future<List<Job>> getJobHistory(String userId) async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      throw Exception('Not authenticated');
    }

    final response = await _apiService.get(
      '/jobs/history',
      params: {'userId': userId},
    );

    return (response['jobs'] as List)
        .map((json) => Job.fromJson(json))
        .toList();
  }
}