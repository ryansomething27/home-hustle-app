import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../data/models/job.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/job_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_indicator.dart';

class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = 'all';
  String _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final authState = ref.read(authProvider);
    if (authState.isAdult) {
      await ref.read(jobProvider.notifier).loadCreatedJobs();
    } else {
      await ref.read(jobProvider.notifier).loadAvailableJobs();
      await ref.read(jobProvider.notifier).loadAssignedJobs();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<JobModel> _filterAndSortJobs(List<JobModel> jobs) {
    // Filter by status
    final filtered = jobs.where((job) {
      if (_filterStatus == 'all') {
        return true;
      }
      return job.status == _filterStatus;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'wage_high':
        filtered.sort((a, b) => b.wage.compareTo(a.wage));
        break;
      case 'wage_low':
        filtered.sort((a, b) => a.wage.compareTo(b.wage));
        break;
    }

    return filtered;
  }

  void _showCreateJobDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => const CreateJobBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAdult = authState.isAdult;
    final jobState = ref.watch(jobProvider);
    
    if (jobState.isLoading && jobState.createdJobs.isEmpty && jobState.availableJobs.isEmpty) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdult ? 'Manage Jobs' : 'Find Jobs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: isAdult ? 'My Jobs' : 'Available'),
            Tab(text: isAdult ? 'All Jobs' : 'My Jobs'),
            const Tab(text: 'History'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                if (value.startsWith('status_')) {
                  _filterStatus = value.substring(7);
                } else if (value.startsWith('sort_')) {
                  _sortBy = value.substring(5);
                }
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'status_all',
                child: Text('All Status'),
              ),
              const PopupMenuItem(
                value: 'status_open',
                child: Text('Open Jobs'),
              ),
              const PopupMenuItem(
                value: 'status_in_progress',
                child: Text('In Progress'),
              ),
              const PopupMenuItem(
                value: 'status_completed',
                child: Text('Completed'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'sort_recent',
                child: Text('Sort by Recent'),
              ),
              const PopupMenuItem(
                value: 'sort_wage_high',
                child: Text('Sort by Wage (High)'),
              ),
              const PopupMenuItem(
                value: 'sort_wage_low',
                child: Text('Sort by Wage (Low)'),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: My Jobs (Adult) / Available Jobs (Child)
          _buildJobList(
            jobs: _filterAndSortJobs(
              isAdult ? jobState.createdJobs : jobState.availableJobs,
            ),
            emptyMessage: isAdult 
              ? 'You haven\'t created any jobs yet'
              : 'No jobs available right now',
            isAdult: isAdult,
          ),
          
          // Tab 2: All Jobs (Adult) / My Jobs (Child)
          _buildJobList(
            jobs: _filterAndSortJobs(
              isAdult 
                ? [...jobState.createdJobs, ...jobState.familyJobs]
                : jobState.assignedJobs,
            ),
            emptyMessage: isAdult 
              ? 'No jobs in the system'
              : 'You haven\'t been assigned any jobs yet',
            isAdult: isAdult,
          ),
          
          // Tab 3: History
          _buildJobList(
            jobs: _filterAndSortJobs(
              ref.watch(completedJobsProvider),
            ),
            emptyMessage: 'No job history',
            isAdult: isAdult,
          ),
        ],
      ),
      floatingActionButton: isAdult
        ? FloatingActionButton.extended(
            onPressed: _showCreateJobDialog,
            label: const Text('Create Job'),
            icon: const Icon(Icons.add),
          )
        : null,
    );
  }

  Widget _buildJobList({
    required List<JobModel> jobs,
    required String emptyMessage,
    required bool isAdult,
  }) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: kDefaultPadding),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(kDefaultPadding),
      itemCount: jobs.length,
      itemBuilder: (BuildContext context, int index) {
        final job = jobs[index];
        final authState = ref.read(authProvider);
        final applications = ref.watch(jobApplicationsProvider(job.id));
        final userApplication = applications?.firstWhere(
          (app) => app.applicantId == authState.user?.id,
          orElse: () => JobApplication(
            id: '',
            jobId: '',
            applicantId: '',
            applicantName: '',
            status: '',
            appliedAt: DateTime.now(),
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: kDefaultPadding),
          child: JobCard(
            job: job,
            application: userApplication?.id.isNotEmpty == true ? userApplication : null,
            hasApplied: userApplication?.id.isNotEmpty == true,
            onTap: () => context.push('/job/${job.id}'),
            onEdit: isAdult && job.createdById == authState.user?.id 
              ? () => _showEditJobDialog(job) 
              : null,
            onDelete: isAdult && job.createdById == authState.user?.id 
              ? () => _confirmDeleteJob(job) 
              : null,
            onApply: !isAdult && job.isAvailable && userApplication?.id.isEmpty == true
              ? () => _applyToJob(job) 
              : null,
            onViewApplications: isAdult && job.createdById == authState.user?.id && (applications?.isNotEmpty ?? false)
              ? () => context.push('/job/${job.id}/applications')
              : null,
            onMarkCompleted: isAdult && job.status == kJobStatusInProgress && job.createdById == authState.user?.id
              ? () => _markJobCompleted(job)
              : null,
          ),
        );
      },
    );
  }

  void _showEditJobDialog(JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => CreateJobBottomSheet(jobToEdit: job),
    );
  }

  void _confirmDeleteJob(JobModel job) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Job?'),
        content: Text('Are you sure you want to delete "${job.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(jobProvider.notifier).deleteJob(job.id);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job deleted successfully')),
                );
              } on Exception catch (e) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting job: $e'),
                    backgroundColor: kErrorColor,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: kErrorColor)),
          ),
        ],
      ),
    );
  }

  void _applyToJob(JobModel job) {
    String? applicationNote;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Apply to ${job.title}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wage: \$${job.wage.toStringAsFixed(2)}${job.wageType == "hourly" ? "/hr" : ""}'),
            const SizedBox(height: 8),
            Text('Posted by: ${job.createdByName}'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Message (optional)',
                hintText: 'Tell them why you\'re perfect for this job!',
              ),
              maxLines: 3,
              onChanged: (String value) {
                applicationNote = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Apply',
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(jobProvider.notifier).applyToJob(
                  job.id,
                  note: applicationNote,
                );
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application submitted!')),
                );
              } on Exception catch (e) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error applying: $e'),
                    backgroundColor: kErrorColor,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _markJobCompleted(JobModel job) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Mark Job as Completed?'),
        content: Text('This will mark "${job.title}" as completed and pay the assigned worker.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Complete & Pay',
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(jobProvider.notifier).completeJob(job.id);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job completed and payment sent!')),
                );
              } on Exception catch (e) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error completing job: $e'),
                    backgroundColor: kErrorColor,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// Create/Edit Job Bottom Sheet
class CreateJobBottomSheet extends ConsumerStatefulWidget {
  const CreateJobBottomSheet({super.key, this.jobToEdit});
  
  final JobModel? jobToEdit;

  @override
  ConsumerState<CreateJobBottomSheet> createState() => _CreateJobBottomSheetState();
}

class _CreateJobBottomSheetState extends ConsumerState<CreateJobBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _wageController;
  late String _wageType;
  late String _jobType;
  late String _category;
  late bool _isUrgent;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.jobToEdit?.title);
    _descriptionController = TextEditingController(text: widget.jobToEdit?.description);
    _wageController = TextEditingController(text: widget.jobToEdit?.wage.toString());
    _wageType = widget.jobToEdit?.wageType ?? 'fixed';
    _jobType = widget.jobToEdit?.jobType ?? 'family';
    _category = widget.jobToEdit?.category ?? 'Cleaning';
    _isUrgent = widget.jobToEdit?.isUrgent ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _wageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.jobToEdit != null) {
        await ref.read(jobProvider.notifier).updateJob(
          jobId: widget.jobToEdit!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          wage: double.parse(_wageController.text),
          wageType: _wageType,
          category: _category,
          isUrgent: _isUrgent,
        );
      } else {
        await ref.read(jobProvider.notifier).createJob(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          wage: double.parse(_wageController.text),
          wageType: _wageType,
          jobType: _jobType,
          category: _category,
          isUrgent: _isUrgent,
        );
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.jobToEdit != null ? 'Job updated!' : 'Job created!'),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: kErrorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.jobToEdit != null ? 'Edit Job' : 'Create New Job',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: kLargePadding),
                
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Title',
                    prefixIcon: Icon(Icons.work),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kDefaultPadding),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kDefaultPadding),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _wageController,
                        decoration: const InputDecoration(
                          labelText: 'Wage',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding),
                    DropdownButton<String>(
                      value: _wageType,
                      items: const [
                        DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                        DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _wageType = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: kDefaultPadding),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _jobType,
                        decoration: const InputDecoration(
                          labelText: 'Job Type',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'family', child: Text('Family Job')),
                          DropdownMenuItem(value: 'public', child: Text('Public Job')),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _jobType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kDefaultPadding),
                
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.label),
                  ),
                  items: kJobCategories.map((String cat) => 
                    DropdownMenuItem(value: cat, child: Text(cat))
                  ).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                ),
                const SizedBox(height: kDefaultPadding),
                
                SwitchListTile(
                  title: const Text('Mark as Urgent'),
                  subtitle: const Text('This job needs immediate attention'),
                  value: _isUrgent,
                  onChanged: (bool value) {
                    setState(() {
                      _isUrgent = value;
                    });
                  },
                ),
                const SizedBox(height: kLargePadding),
                
                CustomButton(
                  text: widget.jobToEdit != null ? 'Update Job' : 'Create Job',
                  onPressed: _isLoading ? null : _handleSubmit,
                  isLoading: _isLoading,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}