import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enums
enum JobType { oneTime, recurring }
enum JobCategory { chores, learning, creative, outdoor, tech, other }
enum JobSchedule { daily, weekly, biweekly, monthly, asNeeded }
enum ApplicationStatus { pending, approved, rejected, withdrawn }

// Job model
class Job {

  Job({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.wage,
    required this.category,
    required this.type,
    required this.schedule,
    required this.isPublic,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.location,
  });

  factory Job.fromMap(Map<String, dynamic> data, String id) {
    return Job(
      id: id,
      creatorId: data['creatorId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      wage: (data['wage'] ?? 0).toDouble(),
      category: JobCategory.values.firstWhere(
        (e) => e.toString() == 'JobCategory.${data['category']}',
        orElse: () => JobCategory.other,
      ),
      type: JobType.values.firstWhere(
        (e) => e.toString() == 'JobType.${data['type']}',
        orElse: () => JobType.oneTime,
      ),
      location: data['location'],
      schedule: JobSchedule.values.firstWhere(
        (e) => e.toString() == 'JobSchedule.${data['schedule']}',
        orElse: () => JobSchedule.asNeeded,
      ),
      isPublic: data['isPublic'] ?? false,
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final double wage;
  final JobCategory category;
  final JobType type;
  final String? location;
  final JobSchedule schedule;
  final bool isPublic;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'wage': wage,
      'category': category.toString().split('.').last,
      'type': type.toString().split('.').last,
      'location': location,
      'schedule': schedule.toString().split('.').last,
      'isPublic': isPublic,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

// Application model
class Application {

  Application({
    required this.id,
    required this.jobId,
    required this.childId,
    required this.childName,
    required this.status,
    required this.appliedAt,
  });

  factory Application.fromMap(Map<String, dynamic> data, String id) {
    return Application(
      id: id,
      jobId: data['jobId'] ?? '',
      childId: data['childId'] ?? '',
      childName: data['childName'] ?? '',
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == 'ApplicationStatus.${data['status']}',
        orElse: () => ApplicationStatus.pending,
      ),
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
    );
  }
  final String id;
  final String jobId;
  final String childId;
  final String childName;
  final ApplicationStatus status;
  final DateTime appliedAt;

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'childId': childId,
      'childName': childName,
      'status': status.toString().split('.').last,
      'appliedAt': Timestamp.fromDate(appliedAt),
    };
  }
}

// Job Details model
class JobDetails {

  JobDetails({
    required this.title,
    required this.description,
    required this.wage,
    required this.category,
    required this.type,
    required this.schedule, this.location,
  });
  final String title;
  final String description;
  final double wage;
  final JobCategory category;
  final JobType type;
  final String? location;
  final JobSchedule schedule;
}

// Job State
class JobState {

  JobState({
    required this.homeJobs,
    required this.publicJobs,
    required this.myActiveJobs,
    required this.myCompletedJobs,
    required this.pendingApplications,
    required this.pendingApprovals,
    required this.jobApplications,
  });
  final List<Job> homeJobs;
  final List<Job> publicJobs;
  final List<Job> myActiveJobs;
  final List<Job> myCompletedJobs;
  final List<Job> pendingApplications;
  final List<Job> pendingApprovals;
  final Map<String, List<Application>> jobApplications;

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

// Job Notifier
class JobNotifier extends StateNotifier<AsyncValue<JobState>> {

  JobNotifier() : super(const AsyncValue.loading()) {
    loadJobs();
  }
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loadJobs() async {
    try {
      state = const AsyncValue.loading();
      
      final user = _auth.currentUser;
      if (user == null) {
        state = AsyncValue.error('User not authenticated', StackTrace.current);
        return;
      }

      // Get user's family ID
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final familyId = userDoc.data()?['familyId'] ?? '';

      // Load home jobs (jobs created by family members)
      final homeJobsQuery = await _db
          .collection('jobs')
          .where('familyId', isEqualTo: familyId)
          .where('isPublic', isEqualTo: false)
          .get();
      
      final homeJobs = homeJobsQuery.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();

      // Load public jobs
      final publicJobsQuery = await _db
          .collection('jobs')
          .where('isPublic', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .get();
      
      final publicJobs = publicJobsQuery.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();

      // Load my active jobs
      final myActiveJobsQuery = await _db
          .collection('jobs')
          .where('assignedTo', isEqualTo: user.uid)
          .where('status', isEqualTo: 'active')
          .get();
      
      final myActiveJobs = myActiveJobsQuery.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();

      // Load my completed jobs
      final myCompletedJobsQuery = await _db
          .collection('jobs')
          .where('assignedTo', isEqualTo: user.uid)
          .where('status', isEqualTo: 'completed')
          .get();
      
      final myCompletedJobs = myCompletedJobsQuery.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();

      // Load pending applications
      final pendingApplicationsQuery = await _db
          .collection('applications')
          .where('childId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      final pendingApplicationIds = pendingApplicationsQuery.docs
          .map((doc) => doc.data()['jobId'] as String)
          .toList();

      final pendingApplications = <Job>[];
      for (final jobId in pendingApplicationIds) {
        final jobDoc = await _db.collection('jobs').doc(jobId).get();
        if (jobDoc.exists) {
          pendingApplications.add(Job.fromMap(jobDoc.data()!, jobDoc.id));
        }
      }

      // Load pending approvals (for parents)
      final pendingApprovals = <Job>[];
      if (userDoc.data()?['role'] == 'parent') {
        final childrenQuery = await _db
            .collection('users')
            .where('parentId', isEqualTo: user.uid)
            .get();
        
        final childIds = childrenQuery.docs.map((doc) => doc.id).toList();
        
        if (childIds.isNotEmpty) {
          final approvalsQuery = await _db
              .collection('applications')
              .where('childId', whereIn: childIds)
              .where('status', isEqualTo: 'pending')
              .get();

          for (final doc in approvalsQuery.docs) {
            final jobId = doc.data()['jobId'] as String;
            final jobDoc = await _db.collection('jobs').doc(jobId).get();
            if (jobDoc.exists) {
              pendingApprovals.add(Job.fromMap(jobDoc.data()!, jobDoc.id));
            }
          }
        }
      }

      // Load job applications
      final jobApplications = <String, List<Application>>{};
      
      state = AsyncValue.data(JobState(
        homeJobs: homeJobs,
        publicJobs: publicJobs,
        myActiveJobs: myActiveJobs,
        myCompletedJobs: myCompletedJobs,
        pendingApplications: pendingApplications,
        pendingApprovals: pendingApprovals,
        jobApplications: jobApplications,
      ));
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createJob({
    required String creatorId,
    required JobDetails jobDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get user's family ID
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final familyId = userDoc.data()?['familyId'] ?? '';

      final job = Job(
        id: '',
        creatorId: creatorId,
        title: jobDetails.title,
        description: jobDetails.description,
        wage: jobDetails.wage,
        category: jobDetails.category,
        type: jobDetails.type,
        location: jobDetails.location,
        schedule: jobDetails.schedule,
        isPublic: jobDetails.location != null, // Public if has location
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.collection('jobs').add({
        ...job.toMap(),
        'familyId': familyId,
      });
      
      await loadJobs();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> applyToJob({
    required String jobId,
    required String childId,
  }) async {
    try {
      final userDoc = await _db.collection('users').doc(childId).get();
      final childName = userDoc.data()?['name'] ?? 'Unknown';

      final application = Application(
        id: '',
        jobId: jobId,
        childId: childId,
        childName: childName,
        status: ApplicationStatus.pending,
        appliedAt: DateTime.now(),
      );

      await _db.collection('applications').add(application.toMap());
      await loadJobs();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> approveOffer({
    required String applicationId,
    required String parentId,
  }) async {
    try {
      await _db.collection('applications').doc(applicationId).update({
        'status': 'approved',
        'approvedBy': parentId,
        'approvedAt': Timestamp.now(),
      });

      // Get application details
      final appDoc = await _db.collection('applications').doc(applicationId).get();
      final jobId = appDoc.data()?['jobId'];
      final childId = appDoc.data()?['childId'];

      // Assign job to child
      if (jobId != null && childId != null) {
        await _db.collection('jobs').doc(jobId).update({
          'assignedTo': childId,
          'status': 'active',
          'updatedAt': Timestamp.now(),
        });
      }
      
      await loadJobs();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeJob({
    required String jobId,
    required String childId,
  }) async {
    try {
      await _db.collection('jobs').doc(jobId).update({
        'status': 'completed',
        'completedBy': childId,
        'completedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      
      await loadJobs();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> resignJob({
    required String jobId,
    required String childId,
  }) async {
    try {
      await _db.collection('jobs').doc(jobId).update({
        'assignedTo': null,
        'status': 'active',
        'updatedAt': Timestamp.now(),
      });
      
      await loadJobs();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<Job>> getNearbyJobs({
    required double userLat,
    required double userLng,
    required int radiusMiles,
  }) async {
    try {
      // For now, return all public jobs
      // In production, you'd implement geospatial queries
      final query = await _db
          .collection('jobs')
          .where('isPublic', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .get();
      
      return query.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();
    } on Exception {
      return [];
    }
  }

  Future<void> markJobAsPaid({
    required String jobId,
    required String childId,
  }) async {
    try {
      final jobDoc = await _db.collection('jobs').doc(jobId).get();
      final wage = jobDoc.data()?['wage'] ?? 0.0;

      // Create payment transaction
      await _db.collection('transactions').add({
        'type': 'job_payment',
        'jobId': jobId,
        'childId': childId,
        'amount': wage,
        'status': 'completed',
        'createdAt': Timestamp.now(),
      });

      await _db.collection('jobs').doc(jobId).update({
        'isPaid': true,
        'paidAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      
      await loadJobs();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Job? getJobById(String jobId) {
    final currentState = state.value;
    if (currentState == null) {
      return null;
    }
    
    final allJobs = [
      ...currentState.homeJobs,
      ...currentState.publicJobs,
      ...currentState.myActiveJobs,
      ...currentState.myCompletedJobs,
    ];
    
    try {
      return allJobs.firstWhere((job) => job.id == jobId);
    } on StateError {
      return null;
    }
  }

  List<Application> getApplicationsForJob(String jobId) {
    final currentState = state.value;
    if (currentState == null) {
      return [];
    }
    
    return currentState.jobApplications[jobId] ?? [];
  }

  int getPendingApprovalsCount() {
    final currentState = state.value;
    if (currentState == null) {
      return 0;
    }
    
    return currentState.pendingApprovals.length;
  }

  Future<void> refreshJobs() async {
    await loadJobs();
  }
}

// Provider
final jobProvider = StateNotifierProvider<JobNotifier, AsyncValue<JobState>>((ref) {
  return JobNotifier();
});