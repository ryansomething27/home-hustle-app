import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/job.dart';
import '../models/user.dart';

final jobProvider = StateNotifierProvider<JobNotifier, AsyncValue<JobState>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return JobNotifier(apiService);
});

class JobState {
  final List<Job> homeJobs;
  final List<Job> publicJobs;
  final List<Job> myActiveJobs;
  final List<Job> myCompletedJobs;
  final List<Job> pendingApplications;
  final List<Job> pendingApprovals;
  final Map<String, List<Application>> jobApplications;

  JobState({
    required this.homeJobs,
    required this.publicJobs,
    required this.myActiveJobs,
    required this.myCompletedJobs,
    required this.pendingApplications,
    required this.pendingApprovals,
    required this.jobApplications,
  });

  JobState copyWith({
    List<Job>? homeJobs,
    List<Job>? publicJobs,
    List<Job>? myActiveJobs,
    List<Job>? myCompletedJobs,
    List<Job>? pendingApplications,
    List<Job>? pendingApprovals,
    Map<String, List<Application>>? jobApplications,
  }) {
    return JobState(
      homeJobs: homeJobs ?? this.homeJobs,
      publicJobs: publicJobs ?? this.publicJobs,
      myActiveJobs: myActiveJobs ?? this.myActiveJobs,
      myCompletedJobs: myCompletedJobs ?? this.myCompletedJobs,
      pendingApplications: pendingApplications ?? this.pendingApplications,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      jobApplications: jobApplications ?? this.jobApplications,
    );
  }
}

class Application {
  final String id;
  final String jobId;
  final String childId;
  final String childName;
  final ApplicationStatus status;
  final DateTime appliedAt;

  Application({
    required this.id,
    required this.jobId,
    required this.childId,
    required this.childName,
    required this.status,
    required this.appliedAt,
  });
}

enum ApplicationStatus {
  pending,
  approved,
  rejected,
  withdrawn,
}

class JobNotifier extends StateNotifier<AsyncValue<JobState>> {
  final ApiService _apiService;

  JobNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadJobs();
  }

  Future<void> loadJobs() async {
    try {
      state = const AsyncValue.loading();
      
      final homeJobs = await _apiService.getHomeJobs();
      final publicJobs = await _apiService.getPublicJobs();
      final myActiveJobs = await _apiService.getMyActiveJobs();
      final myCompletedJobs = await _apiService.getMyCompletedJobs();
      final pendingApplications = await _apiService.getPendingApplications();
      final pendingApprovals = await _apiService.getPendingApprovals();
      
      final jobApplications = <String, List<Application>>{};
      for (var job in [...homeJobs, ...publicJobs]) {
        jobApplications[job.id] = await _apiService.getJobApplications(job.id);
      }
      
      state = AsyncValue.data(JobState(
        homeJobs: homeJobs,
        publicJobs: publicJobs,
        myActiveJobs: myActiveJobs,
        myCompletedJobs: myCompletedJobs,
        pendingApplications: pendingApplications,
        pendingApprovals: pendingApprovals,
        jobApplications: jobApplications,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createJob({
    required String creatorId,
    required JobDetails jobDetails,
  }) async {
    try {
      await _apiService.createJob(
        creatorId: creatorId,
        jobDetails: jobDetails,
      );
      
      await loadJobs();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> applyToJob({
    required String jobId,
    required String childId,
  }) async {
    try {
      await _apiService.applyToJob(
        jobId: jobId,
        childId: childId,
      );
      
      await loadJobs();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> approveOffer({
    required String applicationId,
    required String parentId,
  }) async {
    try {
      await _apiService.approveOffer(
        applicationId: applicationId,
        parentId: parentId,
      );
      
      await loadJobs();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeJob({
    required String jobId,
    required String childId,
  }) async {
    try {
      await _apiService.completeJob(
        jobId: jobId,
        childId: childId,
      );
      
      await loadJobs();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> resignJob({
    required String jobId,
    required String childId,
  }) async {
    try {
      await _apiService.resignJob(
        jobId: jobId,
        childId: childId,
      );
      
      await loadJobs();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<Job>> getNearbyJobs({
    required double userLat,
    required double userLng,
    required int radiusMiles,
  }) async {
    try {
      final jobs = await _apiService.getNearbyJobs(
        userLat: userLat,
        userLng: userLng,
        radiusMiles: radiusMiles,
      );
      
      return jobs;
    } catch (e) {
      return [];
    }
  }

  Future<void> markJobAsPaid({
    required String jobId,
    required String childId,
  }) async {
    try {
      await _apiService.markJobAsPaid(
        jobId: jobId,
        childId: childId,
      );
      
      await loadJobs();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Job? getJobById(String jobId) {
    final currentState = state.value;
    if (currentState == null) return null;
    
    final allJobs = [
      ...currentState.homeJobs,
      ...currentState.publicJobs,
      ...currentState.myActiveJobs,
      ...currentState.myCompletedJobs,
    ];
    
    try {
      return allJobs.firstWhere((job) => job.id == jobId);
    } catch (_) {
      return null;
    }
  }

  List<Application> getApplicationsForJob(String jobId) {
    final currentState = state.value;
    if (currentState == null) return [];
    
    return currentState.jobApplications[jobId] ?? [];
  }

  int getPendingApprovalsCount() {
    final currentState = state.value;
    if (currentState == null) return 0;
    
    return currentState.pendingApprovals.length;
  }

  Future<void> refreshJobs() async {
    await loadJobs();
  }
}

class JobDetails {
  final String title;
  final String description;
  final double wage;
  final JobCategory category;
  final JobType type;
  final String? location;
  final JobSchedule schedule;

  JobDetails({
    required this.title,
    required this.description,
    required this.wage,
    required this.category,
    required this.type,
    this.location,
    required this.schedule,
  });
}