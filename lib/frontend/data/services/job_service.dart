import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/constants.dart';
import '../models/job.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Handles CRUD operations for jobs (create, update, delete, apply, approve, etc.) 
/// for both adults and children.
class JobService {
  
  JobService._internal();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  /// Singleton instance
  static final JobService _instance = JobService._internal();
  static JobService get instance => _instance;
  
  /// Create a new job (adults only)
  Future<JobModel> createJob({
    required String title,
    required String description,
    required double wage,
    required String wageType,
    required String jobType,
    required String category,
    String? location,
    List<String>? requiredSkills,
    List<String>? imageUrls,
    int? maxApplicants,
    int? estimatedDuration,
    DateTime? startDate,
    DateTime? endDate,
    bool isUrgent = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null || !currentUser.isAdult) {
        throw Exception('Only adults can create jobs');
      }
      
      final response = await _apiService.post(
        '/jobs/create',
        data: {
          'title': title,
          'description': description,
          'wage': wage,
          'wageType': wageType,
          'jobType': jobType,
          'category': category,
          'location': location,
          'requiredSkills': requiredSkills,
          'imageUrls': imageUrls,
          'maxApplicants': maxApplicants,
          'estimatedDuration': estimatedDuration,
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
          'isUrgent': isUrgent,
          'metadata': metadata,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return JobModel.fromMap(responseData['job']);
    } catch (e) {
      debugPrint('Error creating job: $e');
      rethrow;
    }
  }
  
  /// Update an existing job
  Future<JobModel> updateJob({
    required String jobId,
    String? title,
    String? description,
    double? wage,
    String? wageType,
    String? category,
    String? location,
    List<String>? requiredSkills,
    List<String>? imageUrls,
    int? maxApplicants,
    int? estimatedDuration,
    DateTime? startDate,
    DateTime? endDate,
    bool? isUrgent,
    Map<String, dynamic>? metadata,
  }) async {
    try {
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
      if (wageType != null) {
        updates['wageType'] = wageType;
      }
      if (category != null) {
        updates['category'] = category;
      }
      if (location != null) {
        updates['location'] = location;
      }
      if (requiredSkills != null) {
        updates['requiredSkills'] = requiredSkills;
      }
      if (imageUrls != null) {
        updates['imageUrls'] = imageUrls;
      }
      if (maxApplicants != null) {
        updates['maxApplicants'] = maxApplicants;
      }
      if (estimatedDuration != null) {
        updates['estimatedDuration'] = estimatedDuration;
      }
      if (startDate != null) {
        updates['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        updates['endDate'] = endDate.toIso8601String();
      }
      if (isUrgent != null) {
        updates['isUrgent'] = isUrgent;
      }
      if (metadata != null) {
        updates['metadata'] = metadata;
      }
      
      final response = await _apiService.put(
        '/jobs/$jobId',
        data: updates,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return JobModel.fromMap(responseData['job']);
    } catch (e) {
      debugPrint('Error updating job: $e');
      rethrow;
    }
  }
  
  /// Delete a job
  Future<void> deleteJob(String jobId) async {
    try {
      await _apiService.delete('/jobs/$jobId');
    } catch (e) {
      debugPrint('Error deleting job: $e');
      rethrow;
    }
  }
  
  /// Get a single job by ID
  Future<JobModel> getJob(String jobId) async {
    try {
      final response = await _apiService.get('/jobs/$jobId');
      final responseData = response.data as Map<String, dynamic>;
      return JobModel.fromMap(responseData['job']);
    } catch (e) {
      debugPrint('Error getting job: $e');
      rethrow;
    }
  }
  
  /// Get all jobs created by the current user (adults)
  Future<List<JobModel>> getMyCreatedJobs({
    String? status,
    String? jobType,
    String? sortBy,
    bool descending = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }
      if (jobType != null) {
        queryParams['jobType'] = jobType;
      }
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }
      queryParams['descending'] = descending;
      
      final response = await _apiService.get(
        '/jobs/my-created',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['jobs'] as List)
          .map((job) => JobModel.fromMap(job))
          .toList();
    } catch (e) {
      debugPrint('Error getting created jobs: $e');
      rethrow;
    }
  }
  
  /// Get all jobs assigned to the current user (children)
  Future<List<JobModel>> getMyAssignedJobs({
    String? status,
    String? sortBy,
    bool descending = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }
      queryParams['descending'] = descending;
      
      final response = await _apiService.get(
        '/jobs/my-assigned',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['jobs'] as List)
          .map((job) => JobModel.fromMap(job))
          .toList();
    } catch (e) {
      debugPrint('Error getting assigned jobs: $e');
      rethrow;
    }
  }
  
  /// Get available public jobs (for children to browse)
  Future<List<JobModel>> getAvailableJobs({
    String? category,
    String? searchQuery,
    double? minWage,
    double? maxWage,
    String? sortBy,
    bool descending = true,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'descending': descending,
      };
      
      if (category != null) {
        queryParams['category'] = category;
      }
      if (searchQuery != null) {
        queryParams['search'] = searchQuery;
      }
      if (minWage != null) {
        queryParams['minWage'] = minWage;
      }
      if (maxWage != null) {
        queryParams['maxWage'] = maxWage;
      }
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }
      
      final response = await _apiService.get(
        '/jobs/available',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['jobs'] as List)
          .map((job) => JobModel.fromMap(job))
          .toList();
    } catch (e) {
      debugPrint('Error getting available jobs: $e');
      rethrow;
    }
  }
  
  /// Get family jobs for the current family
  Future<List<JobModel>> getFamilyJobs({
    String? status,
    String? assignedToId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }
      if (assignedToId != null) {
        queryParams['assignedToId'] = assignedToId;
      }
      
      final response = await _apiService.get(
        '/jobs/family',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['jobs'] as List)
          .map((job) => JobModel.fromMap(job))
          .toList();
    } catch (e) {
      debugPrint('Error getting family jobs: $e');
      rethrow;
    }
  }
  
  /// Apply to a job (children only)
  Future<JobApplication> applyToJob(String jobId, {String? note}) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null || !currentUser.isChild) {
        throw Exception('Only children can apply to jobs');
      }
      
      final response = await _apiService.post(
        '/jobs/$jobId/apply',
        data: {
          'note': note,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return JobApplication.fromMap(responseData['application']);
    } catch (e) {
      debugPrint('Error applying to job: $e');
      rethrow;
    }
  }
  
  /// Withdraw job application
  Future<void> withdrawApplication(String jobId, String applicationId) async {
    try {
      await _apiService.delete('/jobs/$jobId/applications/$applicationId');
    } catch (e) {
      debugPrint('Error withdrawing application: $e');
      rethrow;
    }
  }
  
  /// Get applications for a job (job creator only)
  Future<List<JobApplication>> getJobApplications(String jobId) async {
    try {
      final response = await _apiService.get('/jobs/$jobId/applications');
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['applications'] as List)
          .map((app) => JobApplication.fromMap(app))
          .toList();
    } catch (e) {
      debugPrint('Error getting job applications: $e');
      rethrow;
    }
  }
  
  /// Approve a job application
  Future<JobApplication> approveApplication(
    String jobId,
    String applicationId,
  ) async {
    try {
      final response = await _apiService.post(
        '/jobs/$jobId/applications/$applicationId/approve',
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return JobApplication.fromMap(responseData['application']);
    } catch (e) {
      debugPrint('Error approving application: $e');
      rethrow;
    }
  }
  
  /// Reject a job application
  Future<JobApplication> rejectApplication(
    String jobId,
    String applicationId, {
    String? reason,
  }) async {
    try {
      final response = await _apiService.post(
        '/jobs/$jobId/applications/$applicationId/reject',
        data: {
          'reason': reason,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return JobApplication.fromMap(responseData['application']);
    } catch (e) {
      debugPrint('Error rejecting application: $e');
      rethrow;
    }
  }
  
  /// Assign a job directly to a child (family jobs)
  Future<JobModel> assignJob(String jobId, String childId) async {
    try {
      final response = await _apiService.post(
        '/jobs/$jobId/assign',
        data: {
          'childId': childId,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return JobModel.fromMap(responseData['job']);
    } catch (e) {
      debugPrint('Error assigning job: $e');
      rethrow;
    }
  }
  
  /// Update job status
  Future<JobModel> updateJobStatus(String jobId, String status, {
    String? reason,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/jobs/$jobId/status',
        data: {
          'status': status,
          'reason': reason,
          'notes': notes,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return JobModel.fromMap(responseData['job']);
    } catch (e) {
      debugPrint('Error updating job status: $e');
      rethrow;
    }
  }
  
  /// Mark job as started
  Future<JobModel> startJob(String jobId) async {
    try {
      return await updateJobStatus(jobId, kJobStatusInProgress);
    } catch (e) {
      debugPrint('Error starting job: $e');
      rethrow;
    }
  }
  
  /// Complete a job
  Future<JobModel> completeJob(String jobId, {
    String? completionNotes,
    int? actualDuration,
  }) async {
    try {
      final response = await _apiService.post(
        '/jobs/$jobId/complete',
        data: {
          'completionNotes': completionNotes,
          'actualDuration': actualDuration,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return JobModel.fromMap(responseData['job']);
    } catch (e) {
      debugPrint('Error completing job: $e');
      rethrow;
    }
  }
  
  /// Cancel a job
  Future<JobModel> cancelJob(String jobId, {required String reason}) async {
    try {
      return await updateJobStatus(
        jobId,
        kJobStatusCancelled,
        reason: reason,
      );
    } catch (e) {
      debugPrint('Error cancelling job: $e');
      rethrow;
    }
  }
  
  /// Rate and review a completed job
  Future<JobModel> rateJob(String jobId, {
    required double rating,
    String? reviewNotes,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }
      
      final response = await _apiService.post(
        '/jobs/$jobId/rate',
        data: {
          'rating': rating,
          'reviewNotes': reviewNotes,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return JobModel.fromMap(responseData['job']);
    } catch (e) {
      debugPrint('Error rating job: $e');
      rethrow;
    }
  }
  
  /// Upload images for a job
  Future<List<String>> uploadJobImages(String jobId, List<String> imagePaths) async {
    try {
      final uploadedUrls = <String>[];
      
      for (final imagePath in imagePaths) {
        final response = await _apiService.uploadFile(
          '/jobs/$jobId/images',
          file: File(imagePath),
          fileFieldName: 'image',
          onSendProgress: (sent, total) {
            debugPrint('Upload progress: ${(sent / total * 100).toStringAsFixed(2)}%');
          },
        );
        
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['imageUrl'] != null) {
          uploadedUrls.add(responseData['imageUrl'] as String);
        }
      }
      
      return uploadedUrls;
    } catch (e) {
      debugPrint('Error uploading job images: $e');
      rethrow;
    }
  }
  
  /// Get job statistics for a user
  Future<Map<String, dynamic>> getJobStatistics({String? userId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) {
        queryParams['userId'] = userId;
      }
      
      final response = await _apiService.get(
        '/jobs/statistics',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return responseData['statistics'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting job statistics: $e');
      rethrow;
    }
  }
  
  /// Search jobs with advanced filters
  Future<List<JobModel>> searchJobs({
    required String query,
    List<String>? categories,
    String? jobType,
    String? status,
    double? minWage,
    double? maxWage,
    String? wageType,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    bool? isUrgent,
    String? location,
    List<String>? requiredSkills,
    String? sortBy,
    bool descending = true,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
        'descending': descending,
      };
      
      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories.join(',');
      }
      if (jobType != null) {
        queryParams['jobType'] = jobType;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (minWage != null) {
        queryParams['minWage'] = minWage;
      }
      if (maxWage != null) {
        queryParams['maxWage'] = maxWage;
      }
      if (wageType != null) {
        queryParams['wageType'] = wageType;
      }
      if (startDateFrom != null) {
        queryParams['startDateFrom'] = startDateFrom.toIso8601String();
      }
      if (startDateTo != null) {
        queryParams['startDateTo'] = startDateTo.toIso8601String();
      }
      if (isUrgent != null) {
        queryParams['isUrgent'] = isUrgent;
      }
      if (location != null) {
        queryParams['location'] = location;
      }
      if (requiredSkills != null && requiredSkills.isNotEmpty) {
        queryParams['skills'] = requiredSkills.join(',');
      }
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }
      
      final response = await _apiService.get(
        '/jobs/search',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['jobs'] as List)
          .map((job) => JobModel.fromMap(job))
          .toList();
    } catch (e) {
      debugPrint('Error searching jobs: $e');
      rethrow;
    }
  }
}