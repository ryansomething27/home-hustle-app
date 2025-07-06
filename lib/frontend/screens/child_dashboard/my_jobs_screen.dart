import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/job_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/job.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/job_card.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(jobProvider.notifier).loadMyJobs();
      ref.read(jobProvider.notifier).loadAvailableJobs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _JobDetailsSheet(
        job: job,
        onApply: job.type == JobType.HOME && job.assigneeId == null
            ? () {
                Navigator.pop(context);
                ref.read(jobProvider.notifier).applyToJob(job.id);
                _showApplicationSuccess(job, isHomeJob: true);
              }
            : job.type == JobType.PUBLIC
                ? () {
                    Navigator.pop(context);
                    ref.read(jobProvider.notifier).applyToJob(job.id);
                    _showApplicationSuccess(job, isHomeJob: false);
                  }
                : null,
        onComplete: job.status == JobStatus.PENDING && job.assigneeId == ref.read(authProvider).value?.id
            ? () {
                Navigator.pop(context);
                _showCompleteConfirmation(job);
              }
            : null,
      ),
    );
  }

  void _showCompleteConfirmation(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Complete Job',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you have completed "${job.title}"?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(jobProvider.notifier).completeJob(job.id);
              Navigator.pop(context);
              _showJobCompletedSuccess(job);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showApplicationSuccess(Job job, {required bool isHomeJob}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isHomeJob
                    ? 'Applied for "${job.title}"!'
                    : 'Application sent! Waiting for parent approval.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showJobCompletedSuccess(Job job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.celebration, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Great job! You earned ${CurrencyHelpers.formatCurrency(job.wage, CurrencyType.DOLLARS)}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildJobsList(List<Job> jobs, String emptyMessage, IconData emptyIcon) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _JobListItem(
            job: job,
            onTap: () => _showJobDetails(job),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(jobProvider);
    final userId = ref.watch(authProvider).value?.id;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'My Jobs',
          style: AppTheme.headingLarge.copyWith(color: AppTheme.textPrimary),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Available'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: jobState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: AppTheme.errorColor),
          ),
        ),
        data: (data) {
          final myJobs = data['myJobs'] as List<Job>? ?? [];
          final availableJobs = data['availableJobs'] as List<Job>? ?? [];

          // Filter jobs by status
          final activeJobs = myJobs.where((job) => 
            job.status == JobStatus.PENDING && job.assigneeId == userId
          ).toList();
          
          final completedJobs = myJobs.where((job) => 
            job.status == JobStatus.COMPLETED && job.assigneeId == userId
          ).toList();

          // Available jobs include unassigned home jobs and public jobs
          final openJobs = availableJobs.where((job) => 
            job.status == JobStatus.OPEN && 
            (job.assigneeId == null || job.type == JobType.PUBLIC)
          ).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildJobsList(
                activeJobs,
                'No active jobs',
                Icons.work_outline,
              ),
              _buildJobsList(
                openJobs,
                'No available jobs',
                Icons.search_off,
              ),
              _buildJobsList(
                completedJobs,
                'No completed jobs yet',
                Icons.check_circle_outline,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _JobListItem extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const _JobListItem({
    Key? key,
    required this.job,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPublic = job.type == JobType.PUBLIC;
    final statusColor = _getStatusColor(job.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getJobIcon(job.category),
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: AppTheme.bodyLarge.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isPublic)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'PUBLIC',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.warningColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.description,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyHelpers.formatCurrency(job.wage, CurrencyType.DOLLARS),
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (job.status == JobStatus.PENDING)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'Tap to mark as complete',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.OPEN:
        return AppTheme.accentColor;
      case JobStatus.PENDING:
        return AppTheme.warningColor;
      case JobStatus.COMPLETED:
        return AppTheme.successColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getJobIcon(String category) {
    switch (category.toLowerCase()) {
      case 'kitchen':
        return Icons.kitchen;
      case 'outdoor':
        return Icons.park;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'pet care':
        return Icons.pets;
      case 'organizing':
        return Icons.inventory_2;
      default:
        return Icons.work_outline;
    }
  }
}

class _JobDetailsSheet extends StatelessWidget {
  final Job job;
  final VoidCallback? onApply;
  final VoidCallback? onComplete;

  const _JobDetailsSheet({
    Key? key,
    required this.job,
    this.onApply,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.work_outline,
                  color: AppTheme.accentColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            CurrencyHelpers.formatCurrency(job.wage, CurrencyType.DOLLARS),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            job.category,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Description',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            job.description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          if (job.type == JobType.PUBLIC) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is a public job. Parent approval required.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (onApply != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply for Job'),
              ),
            ),
          if (onComplete != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}