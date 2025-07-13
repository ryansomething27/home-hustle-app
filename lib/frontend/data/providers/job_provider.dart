// frontend/data/providers/job_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job.dart';
import '../services/job_service.dart';

// Job service provider
final jobServiceProvider = Provider<JobService>((ref) {
  return JobService.instance;
});

// Job state class
class JobState {

  const JobState({
    this.createdJobs = const [],
    this.assignedJobs = const [],
    this.availableJobs = const [],
    this.familyJobs = const [],
    this.jobApplications = const {},
    this.isLoading = false,
    this.error,
    this.selectedJob,
    this.statistics,
  });
  final List<JobModel> createdJobs;
  final List<JobModel> assignedJobs;
  final List<JobModel> availableJobs;
  final List<JobModel> familyJobs;
  final Map<String, List<JobApplication>> jobApplications;
  final bool isLoading;
  final String? error;
  final JobModel? selectedJob;
  final Map<String, dynamic>? statistics;

  JobState copyWith({
    List<JobModel>? createdJobs,
    List<JobModel>? assignedJobs,
    List<JobModel>? availableJobs,
    List<JobModel>? familyJobs,
    Map<String, List<JobApplication>>? jobApplications,
    bool? isLoading,
    String? error,
    JobModel? selectedJob,
    Map<String, dynamic>? statistics,
    bool clearError = false,
    bool clearSelectedJob = false,
  }) {
    return JobState(
      createdJobs: createdJobs ?? this.createdJobs,
      assignedJobs: assignedJobs ?? this.assignedJobs,
      availableJobs: availableJobs ?? this.availableJobs,
      familyJobs: familyJobs ?? this.familyJobs,
      jobApplications: jobApplications ?? this.jobApplications,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedJob: clearSelectedJob ? null : (selectedJob ?? this.selectedJob),
      statistics: statistics ?? this.statistics,
    );
  }
}

// Job notifier
class JobNotifier extends StateNotifier<JobState> {
  
  JobNotifier(this._jobService) : super(const JobState());
  final JobService _jobService;

  // Create a new job
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
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final job = await _jobService.createJob(
        title: title,
        description: description,
        wage: wage,
        wageType: wageType,
        jobType: jobType,
        category: category,
        location: location,
        requiredSkills: requiredSkills,
        imageUrls: imageUrls,
        maxApplicants: maxApplicants,
        estimatedDuration: estimatedDuration,
        startDate: startDate,
        endDate: endDate,
        isUrgent: isUrgent,
        metadata: metadata,
      );
      
      // Add to created jobs list
      state = state.copyWith(
        createdJobs: [...state.createdJobs, job],
        isLoading: false,
      );
      
      return job;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update a job
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
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedJob = await _jobService.updateJob(
        jobId: jobId,
        title: title,
        description: description,
        wage: wage,
        wageType: wageType,
        category: category,
        location: location,
        requiredSkills: requiredSkills,
        imageUrls: imageUrls,
        maxApplicants: maxApplicants,
        estimatedDuration: estimatedDuration,
        startDate: startDate,
        endDate: endDate,
        isUrgent: isUrgent,
        metadata: metadata,
      );
      
      // Update in all lists
      state = state.copyWith(
        createdJobs: _updateJobInList(state.createdJobs, updatedJob),
        assignedJobs: _updateJobInList(state.assignedJobs, updatedJob),
        availableJobs: _updateJobInList(state.availableJobs, updatedJob),
        familyJobs: _updateJobInList(state.familyJobs, updatedJob),
        selectedJob: state.selectedJob?.id == jobId ? updatedJob : state.selectedJob,
        isLoading: false,
      );
      
      return updatedJob;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Delete a job
  Future<void> deleteJob(String jobId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await _jobService.deleteJob(jobId);
      
      // Remove from all lists
      state = state.copyWith(
        createdJobs: state.createdJobs.where((job) => job.id != jobId).toList(),
        assignedJobs: state.assignedJobs.where((job) => job.id != jobId).toList(),
        availableJobs: state.availableJobs.where((job) => job.id != jobId).toList(),
        familyJobs: state.familyJobs.where((job) => job.id != jobId).toList(),
        jobApplications: Map.from(state.jobApplications)..remove(jobId),
        selectedJob: state.selectedJob?.id == jobId ? null : state.selectedJob,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load a specific job
  Future<void> loadJob(String jobId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final job = await _jobService.getJob(jobId);
      state = state.copyWith(
        selectedJob: job,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load created jobs (for adults)
  Future<void> loadCreatedJobs({
    String? status,
    String? jobType,
    String? sortBy,
    bool descending = true,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final jobs = await _jobService.getMyCreatedJobs(
        status: status,
        jobType: jobType,
        sortBy: sortBy,
        descending: descending,
      );
      
      state = state.copyWith(
        createdJobs: jobs,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load assigned jobs (for children)
  Future<void> loadAssignedJobs({
    String? status,
    String? sortBy,
    bool descending = true,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final jobs = await _jobService.getMyAssignedJobs(
        status: status,
        sortBy: sortBy,
        descending: descending,
      );
      
      state = state.copyWith(
        assignedJobs: jobs,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load available public jobs
  Future<void> loadAvailableJobs({
    String? category,
    String? searchQuery,
    double? minWage,
    double? maxWage,
    String? sortBy,
    bool descending = true,
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final jobs = await _jobService.getAvailableJobs(
        category: category,
        searchQuery: searchQuery,
        minWage: minWage,
        maxWage: maxWage,
        sortBy: sortBy,
        descending: descending,
        page: page,
        limit: limit,
      );
      
      state = state.copyWith(
        availableJobs: jobs,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load family jobs
  Future<void> loadFamilyJobs({
    String? status,
    String? assignedToId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final jobs = await _jobService.getFamilyJobs(
        status: status,
        assignedToId: assignedToId,
      );
      
      state = state.copyWith(
        familyJobs: jobs,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Apply to a job
  Future<void> applyToJob(String jobId, {String? note}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await _jobService.applyToJob(jobId, note: note);
      
      // Reload available jobs to update application status
      await loadAvailableJobs();
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load applications for a job
  Future<void> loadJobApplications(String jobId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final applications = await _jobService.getJobApplications(jobId);
      
      state = state.copyWith(
        jobApplications: {
          ...state.jobApplications,
          jobId: applications,
        },
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Approve application
  Future<void> approveApplication(String jobId, String applicationId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await _jobService.approveApplication(jobId, applicationId);
      
      // Reload applications and jobs
      await loadJobApplications(jobId);
      await loadCreatedJobs();
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Reject application
  Future<void> rejectApplication(
    String jobId, 
    String applicationId, {
    String? reason,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await _jobService.rejectApplication(
        jobId, 
        applicationId, 
        reason: reason,
      );
      
      // Reload applications
      await loadJobApplications(jobId);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Start a job
  Future<void> startJob(String jobId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedJob = await _jobService.startJob(jobId);
      
      // Update job in lists
      state = state.copyWith(
        assignedJobs: _updateJobInList(state.assignedJobs, updatedJob),
        familyJobs: _updateJobInList(state.familyJobs, updatedJob),
        selectedJob: state.selectedJob?.id == jobId ? updatedJob : state.selectedJob,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Complete a job
  Future<void> completeJob(
    String jobId, {
    String? completionNotes,
    int? actualDuration,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedJob = await _jobService.completeJob(
        jobId,
        completionNotes: completionNotes,
        actualDuration: actualDuration,
      );
      
      // Update job in lists
      state = state.copyWith(
        assignedJobs: _updateJobInList(state.assignedJobs, updatedJob),
        familyJobs: _updateJobInList(state.familyJobs, updatedJob),
        selectedJob: state.selectedJob?.id == jobId ? updatedJob : state.selectedJob,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Cancel a job
  Future<void> cancelJob(String jobId, {required String reason}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedJob = await _jobService.cancelJob(jobId, reason: reason);
      
      // Update job in lists
      state = state.copyWith(
        createdJobs: _updateJobInList(state.createdJobs, updatedJob),
        assignedJobs: _updateJobInList(state.assignedJobs, updatedJob),
        familyJobs: _updateJobInList(state.familyJobs, updatedJob),
        selectedJob: state.selectedJob?.id == jobId ? updatedJob : state.selectedJob,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Rate a job
  Future<void> rateJob(
    String jobId, {
    required double rating,
    String? reviewNotes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedJob = await _jobService.rateJob(
        jobId,
        rating: rating,
        reviewNotes: reviewNotes,
      );
      
      // Update job in lists
      state = state.copyWith(
        createdJobs: _updateJobInList(state.createdJobs, updatedJob),
        assignedJobs: _updateJobInList(state.assignedJobs, updatedJob),
        familyJobs: _updateJobInList(state.familyJobs, updatedJob),
        selectedJob: state.selectedJob?.id == jobId ? updatedJob : state.selectedJob,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load job statistics
  Future<void> loadJobStatistics({String? userId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final stats = await _jobService.getJobStatistics(userId: userId);
      
      state = state.copyWith(
        statistics: stats,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Clear selected job
  void clearSelectedJob() {
    state = state.copyWith(clearSelectedJob: true);
  }

  // Helper method to update job in list
  List<JobModel> _updateJobInList(List<JobModel> jobs, JobModel updatedJob) {
    return jobs.map((job) => job.id == updatedJob.id ? updatedJob : job).toList();
  }
}

// Main job provider
final jobProvider = StateNotifierProvider<JobNotifier, JobState>((ref) {
  final jobService = ref.watch(jobServiceProvider);
  return JobNotifier(jobService);
});

// Convenience providers
final createdJobsProvider = Provider<List<JobModel>>((ref) {
  return ref.watch(jobProvider).createdJobs;
});

final assignedJobsProvider = Provider<List<JobModel>>((ref) {
  return ref.watch(jobProvider).assignedJobs;
});

final availableJobsProvider = Provider<List<JobModel>>((ref) {
  return ref.watch(jobProvider).availableJobs;
});

final familyJobsProvider = Provider<List<JobModel>>((ref) {
  return ref.watch(jobProvider).familyJobs;
});

final selectedJobProvider = Provider<JobModel?>((ref) {
  return ref.watch(jobProvider).selectedJob;
});

final jobStatisticsProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(jobProvider).statistics;
});

final isJobLoadingProvider = Provider<bool>((ref) {
  return ref.watch(jobProvider).isLoading;
});

final jobErrorProvider = Provider<String?>((ref) {
  return ref.watch(jobProvider).error;
});

// Job applications for a specific job
final jobApplicationsProvider = Provider.family<List<JobApplication>?, String>((ref, jobId) {
  return ref.watch(jobProvider).jobApplications[jobId];
});

// Active jobs (open or in progress)
final activeJobsProvider = Provider<List<JobModel>>((ref) {
  final allJobs = [
    ...ref.watch(createdJobsProvider),
    ...ref.watch(assignedJobsProvider),
    ...ref.watch(familyJobsProvider),
  ];
  
  // Remove duplicates and filter active
  final uniqueActiveJobs = <String, JobModel>{};
  for (final job in allJobs) {
    if (job.isActive) {
      uniqueActiveJobs[job.id] = job;
    }
  }
  
  return uniqueActiveJobs.values.toList();
});

// Completed jobs
final completedJobsProvider = Provider<List<JobModel>>((ref) {
  final allJobs = [
    ...ref.watch(createdJobsProvider),
    ...ref.watch(assignedJobsProvider),
    ...ref.watch(familyJobsProvider),
  ];
  
  // Remove duplicates and filter completed
  final uniqueCompletedJobs = <String, JobModel>{};
  for (final job in allJobs) {
    if (job.status == 'completed') {
      uniqueCompletedJobs[job.id] = job;
    }
  }
  
  return uniqueCompletedJobs.values.toList();
});

// Usage Examples:
/*
// In a widget:
class JobListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobState = ref.watch(jobProvider);
    final availableJobs = ref.watch(availableJobsProvider);
    
    if (jobState.isLoading) {
      return const LoadingIndicator();
    }
    
    return ListView.builder(
      itemCount: availableJobs.length,
      itemBuilder: (context, index) {
        return JobCard(job: availableJobs[index]);
      },
    );
  }
}

// Create a job:
await ref.read(jobProvider.notifier).createJob(
  title: 'Clean the garage',
  description: 'Need help organizing and cleaning the garage',
  wage: 25.0,
  wageType: 'fixed',
  jobType: 'family',
  category: 'Cleaning',
);

// Apply to a job:
await ref.read(jobProvider.notifier).applyToJob(
  jobId,
  note: 'I have experience with this type of work',
);

// Load different job lists:
await ref.read(jobProvider.notifier).loadCreatedJobs();
await ref.read(jobProvider.notifier).loadAssignedJobs();
await ref.read(jobProvider.notifier).loadAvailableJobs();
*/