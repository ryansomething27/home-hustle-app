import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'auth_service.dart';

class JobService {
  final ApiService _apiService;
  final AuthService _authService;

  JobService({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

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
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    final requestBody = {
      'creatorId': currentUser.id,
      'jobDetails': {
        'title': title,
        'description': description,
        'wage': wage,
        'type': type.name,
        'category': category,
        if (location != null) 'location': location,
        if (address != null) 'address': address,
        if (schedule != null) 'schedule': schedule.name,
        if (assignedChildId != null) 'assignedChildId': assignedChildId,
      },
    };

    final response = await _apiService.post(
      '/jobs/create',
      body: requestBody,
      token: token,
    );

    return Job.fromJson(response);
  }

  // Get all jobs for current user
  Future<List<Job>> getJobs() async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    final response = await _apiService.get(
      '/jobs/list?userId=${currentUser.id}',
      token: token,
    );

    return (response['jobs'] as List)
        .map((json) => Job.fromJson(json))
        .toList();
  }

  // Get job by ID
  Future<Job> getJobById(String jobId) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/jobs/$jobId',
      token: token,
    );

    return Job.fromJson(response);
  }

  // Apply to a job (child)
  Future<JobApplication> applyToJob({
    required String jobId,
    String? applicationNote,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    final requestBody = {
      'jobId': jobId,
      'childId': currentUser.id,
      if (applicationNote != null) 'applicationNote': applicationNote,
    };

    final response = await _apiService.post(
      '/jobs/apply',
      body: requestBody,
      token: token,
    );

    return JobApplication.fromJson(response);
  }

  // Approve job offer (parent)
  Future<void> approveJobOffer({
    required String applicationId,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    await _apiService.post(
      '/jobs/approve-offer',
      body: {
        'applicationId': applicationId,
        'parentId': currentUser.id,
      },
      token: token,
    );
  }

  // Reject job offer (parent)
  Future<void> rejectJobOffer({
    required String applicationId,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    await _apiService.post(
      '/jobs/reject-offer',
      body: {
        'applicationId': applicationId,
        'parentId': currentUser.id,
      },
      token: token,
    );
  }

  // Complete a job
  Future<void> completeJob({
    required String jobId,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    await _apiService.post(
      '/jobs/complete',
      body: {
        'jobId': jobId,
        'childId': currentUser.id,
      },
      token: token,
    );
  }

  // Resign from a job
  Future<void> resignFromJob({
    required String jobId,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    await _apiService.post(
      '/jobs/resign',
      body: {
        'jobId': jobId,
        'childId': currentUser.id,
      },
      token: token,
    );
  }

  // Get nearby public jobs (marketplace)
  Future<List<Job>> getNearbyJobs({
    required double radiusMiles,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    // Get user's location from their family settings
    final response = await _apiService.get(
      '/marketplace/nearby-jobs?radiusMiles=$radiusMiles',
      token: token,
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
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    await _apiService.post(
      '/marketplace/mark-paid',
      body: {
        'jobId': jobId,
        'childId': childId,
      },
      token: token,
    );
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
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (wage != null) updates['wage'] = wage;
    if (category != null) updates['category'] = category;
    if (location != null) updates['location'] = location;
    if (schedule != null) updates['schedule'] = schedule.name;

    final response = await _apiService.patch(
      '/jobs/$jobId',
      body: updates,
      token: token,
    );

    return Job.fromJson(response);
  }

  // Delete job (parent/employer)
  Future<void> deleteJob(String jobId) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    await _apiService.delete(
      '/jobs/$jobId',
      token: token,
    );
  }

  // Get job applications for a job (parent/employer)
  Future<List<JobApplication>> getJobApplications(String jobId) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/jobs/$jobId/applications',
      token: token,
    );

    return (response['applications'] as List)
        .map((json) => JobApplication.fromJson(json))
        .toList();
  }

  // Get applications for a child
  Future<List<JobApplication>> getChildApplications(String childId) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/jobs/applications?childId=$childId',
      token: token,
    );

    return (response['applications'] as List)
        .map((json) => JobApplication.fromJson(json))
        .toList();
  }

  // Accept job application (employer)
  Future<void> acceptApplication({
    required String applicationId,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    await _apiService.post(
      '/jobs/accept-application',
      body: {
        'applicationId': applicationId,
      },
      token: token,
    );
  }

  // Reject job application (employer)
  Future<void> rejectApplication({
    required String applicationId,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    await _apiService.post(
      '/jobs/reject-application',
      body: {
        'applicationId': applicationId,
      },
      token: token,
    );
  }

  // Get active jobs for child
  Future<List<Job>> getActiveJobsForChild(String childId) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/jobs/active?childId=$childId',
      token: token,
    );

    return (response['jobs'] as List)
        .map((json) => Job.fromJson(json))
        .toList();
  }

  // Get job history for resume
  Future<List<Job>> getJobHistory(String userId) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/jobs/history?userId=$userId',
      token: token,
    );

    return (response['jobs'] as List)
        .map((json) => Job.fromJson(json))
        .toList();
  }
}