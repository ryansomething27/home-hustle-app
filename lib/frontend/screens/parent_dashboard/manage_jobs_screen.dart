import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/job_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/job.dart';
import '../../data/models/user.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/job_card.dart';
import '../../navigation/routes.dart';

class ManageJobsScreen extends ConsumerStatefulWidget {
  const ManageJobsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends ConsumerState<ManageJobsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<User> _children = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(jobProvider.notifier).loadHomeJobs();
      _loadChildren();
    });
  }

  void _loadChildren() async {
    final authState = ref.read(authProvider);
    if (authState.value?.role == UserRole.PARENT) {
      final children = await ref.read(authProvider.notifier).getFamilyChildren();
      setState(() {
        _children = children;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAssignJobDialog(Job job) {
    User? selectedChild;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            'Assign Job',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select a child to assign "${job.title}" to:',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<User>(
                value: selectedChild,
                decoration: InputDecoration(
                  labelText: 'Child',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.accentColor),
                  ),
                ),
                dropdownColor: AppTheme.surfaceColor,
                style: TextStyle(color: AppTheme.textPrimary),
                items: _children.map((child) {
                  return DropdownMenuItem(
                    value: child,
                    child: Text(
                      child.name,
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedChild = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: selectedChild != null
                  ? () {
                      ref.read(jobProvider.notifier).assignJob(
                        jobId: job.id,
                        childId: selectedChild!.id,
                      );
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  List<Job> _filterJobsByStatus(List<Job> jobs, JobStatus status) {
    return jobs.where((job) => job.status == status).toList();
  }

  Widget _buildJobList(List<Job> jobs, JobStatus status) {
    final filteredJobs = _filterJobsByStatus(jobs, status);

    if (filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == JobStatus.OPEN
                  ? Icons.assignment_outlined
                  : status == JobStatus.PENDING
                      ? Icons.pending_outlined
                      : Icons.check_circle_outline,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              status == JobStatus.OPEN
                  ? 'No open jobs'
                  : status == JobStatus.PENDING
                      ? 'No jobs in progress'
                      : 'No completed jobs',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            if (status == JobStatus.OPEN)
              Text(
                'Create jobs for your children',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: JobCard(
            job: job,
            onTap: () {
              _showJobDetailsBottomSheet(job);
            },
            trailing: _buildJobActions(job),
          ),
        );
      },
    );
  }

  Widget _buildJobActions(Job job) {
    if (job.status == JobStatus.COMPLETED) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Completed',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.successColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (job.status == JobStatus.OPEN && job.assigneeId == null)
          IconButton(
            icon: Icon(Icons.person_add, color: AppTheme.accentColor),
            onPressed: () => _showAssignJobDialog(job),
          ),
        if (job.status == JobStatus.OPEN)
          IconButton(
            icon: Icon(Icons.edit, color: AppTheme.accentColor),
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.createJob,
                arguments: job,
              );
            },
          ),
        if (job.status == JobStatus.OPEN)
          IconButton(
            icon: Icon(Icons.delete, color: AppTheme.errorColor),
            onPressed: () => _showDeleteConfirmation(job),
          ),
      ],
    );
  }

  void _showJobDetailsBottomSheet(Job job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    job.title,
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.status.toString().split('.').last,
                      style: AppTheme.bodySmall.copyWith(
                        color: _getStatusColor(job.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Wage',
                      CurrencyHelpers.formatCurrency(job.wage, CurrencyType.DOLLARS),
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      'Category',
                      job.category,
                      Icons.category,
                    ),
                  ),
                ],
              ),
              if (job.assigneeId != null) ...[
                const SizedBox(height: 16),
                _buildDetailItem(
                  'Assigned To',
                  _getChildName(job.assigneeId!),
                  Icons.person,
                ),
              ],
              if (job.completedAt != null) ...[
                const SizedBox(height: 16),
                _buildDetailItem(
                  'Completed On',
                  DateHelpers.formatDate(job.completedAt!),
                  Icons.check_circle,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getChildName(String childId) {
    final child = _children.firstWhere(
      (c) => c.id == childId,
      orElse: () => User(id: '', name: 'Unknown', email: '', role: UserRole.CHILD),
    );
    return child.name;
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

  void _showDeleteConfirmation(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Delete Job',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${job.title}"?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(jobProvider.notifier).deleteJob(job.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(jobProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Manage Jobs',
          style: AppTheme.headingLarge.copyWith(color: AppTheme.textPrimary),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Open'),
            Tab(text: 'In Progress'),
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
          final homeJobs = data['homeJobs'] as List<Job>? ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildJobList(homeJobs, JobStatus.OPEN),
              _buildJobList(homeJobs, JobStatus.PENDING),
              _buildJobList(homeJobs, JobStatus.COMPLETED),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.createJob);
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}