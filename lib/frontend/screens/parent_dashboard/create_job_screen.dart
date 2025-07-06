import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/job_provider.dart';
import '../../data/models/job.dart';
import '../../data/models/user.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _wageController = TextEditingController();
  final _locationController = TextEditingController();
  
  JobCategory _selectedCategory = JobCategory.household;
  JobType _jobType = JobType.home;
  ScheduleType _scheduleType = ScheduleType.oneTime;
  String? _selectedChildId;
  bool _isLoading = false;

  // Recurring job settings
  RecurrenceFrequency _recurrenceFrequency = RecurrenceFrequency.daily;
  final List<int> _selectedDaysOfWeek = [];
  int _dayOfMonth = 1;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _wageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateJob() async {
    if (!_formKey.currentState!.validate()) return;

    if (_jobType == JobType.home && _selectedChildId == null) {
      _showErrorSnackBar('Please select a child for this job');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jobData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'type': _jobType,
        'wage': double.parse(_wageController.text),
        'scheduleType': _scheduleType,
        'assignedChildId': _selectedChildId,
      };

      if (_jobType == JobType.public) {
        jobData['location'] = _locationController.text.trim();
      }

      if (_scheduleType == ScheduleType.recurring) {
        jobData['recurrenceFrequency'] = _recurrenceFrequency;
        if (_recurrenceFrequency == RecurrenceFrequency.weekly) {
          jobData['daysOfWeek'] = _selectedDaysOfWeek;
        } else if (_recurrenceFrequency == RecurrenceFrequency.monthly) {
          jobData['dayOfMonth'] = _dayOfMonth;
        }
      }

      final result = await ref.read(jobProvider.notifier).createJob(jobData);

      if (result.success && mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('Job created successfully!');
      } else if (mounted) {
        _showErrorSnackBar(result.error ?? 'Failed to create job');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(childrenProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cream),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Job',
          style: TextStyle(
            color: AppColors.cream,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Type Selector
                Text(
                  'Job Type',
                  style: TextStyle(
                    color: AppColors.cream.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildJobTypeOption(
                        JobType.home,
                        'Home Job',
                        Icons.home,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildJobTypeOption(
                        JobType.public,
                        'Public Job',
                        Icons.public,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Job Title
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: AppColors.cream),
                  decoration: _buildInputDecoration(
                    label: 'Job Title',
                    hint: 'e.g., Clean the kitchen',
                    icon: Icons.work_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a job title';
                    }
                    if (value.length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: AppColors.cream),
                  maxLines: 3,
                  decoration: _buildInputDecoration(
                    label: 'Description',
                    hint: 'Describe what needs to be done',
                    icon: Icons.description_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<JobCategory>(
                  value: _selectedCategory,
                  dropdownColor: AppColors.backgroundDark,
                  style: const TextStyle(color: AppColors.cream),
                  decoration: _buildInputDecoration(
                    label: 'Category',
                    icon: Icons.category_outlined,
                  ),
                  items: JobCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        Helpers.getCategoryName(category),
                        style: const TextStyle(color: AppColors.cream),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Wage
                TextFormField(
                  controller: _wageController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: AppColors.cream),
                  decoration: _buildInputDecoration(
                    label: 'Wage',
                    hint: '0.00',
                    icon: Icons.attach_money,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a wage';
                    }
                    final wage = double.tryParse(value);
                    if (wage == null || wage <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Schedule Type
                Text(
                  'Schedule',
                  style: TextStyle(
                    color: AppColors.cream.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildScheduleTypeOption(
                        ScheduleType.oneTime,
                        'One Time',
                        Icons.schedule,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildScheduleTypeOption(
                        ScheduleType.recurring,
                        'Recurring',
                        Icons.repeat,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Recurring Options
                if (_scheduleType == ScheduleType.recurring) ...[
                  DropdownButtonFormField<RecurrenceFrequency>(
                    value: _recurrenceFrequency,
                    dropdownColor: AppColors.backgroundDark,
                    style: const TextStyle(color: AppColors.cream),
                    decoration: _buildInputDecoration(
                      label: 'Frequency',
                      icon: Icons.event_repeat,
                    ),
                    items: RecurrenceFrequency.values.map((frequency) {
                      return DropdownMenuItem(
                        value: frequency,
                        child: Text(
                          Helpers.getFrequencyName(frequency),
                          style: const TextStyle(color: AppColors.cream),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _recurrenceFrequency = value;
                          _selectedDaysOfWeek.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Weekly Days Selection
                  if (_recurrenceFrequency == RecurrenceFrequency.weekly) ...[
                    Text(
                      'Select Days',
                      style: TextStyle(
                        color: AppColors.cream.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        final dayName = Helpers.getDayName(index);
                        final isSelected = _selectedDaysOfWeek.contains(index);
                        
                        return FilterChip(
                          label: Text(dayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDaysOfWeek.add(index);
                              } else {
                                _selectedDaysOfWeek.remove(index);
                              }
                            });
                          },
                          selectedColor: AppColors.cream.withOpacity(0.2),
                          backgroundColor: AppColors.cream.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.cream : AppColors.cream.withOpacity(0.7),
                          ),
                          checkmarkColor: AppColors.cream,
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Monthly Day Selection
                  if (_recurrenceFrequency == RecurrenceFrequency.monthly) ...[
                    DropdownButtonFormField<int>(
                      value: _dayOfMonth,
                      dropdownColor: AppColors.backgroundDark,
                      style: const TextStyle(color: AppColors.cream),
                      decoration: _buildInputDecoration(
                        label: 'Day of Month',
                        icon: Icons.calendar_today,
                      ),
                      items: List.generate(28, (index) {
                        final day = index + 1;
                        return DropdownMenuItem(
                          value: day,
                          child: Text(
                            Helpers.getOrdinalDay(day),
                            style: const TextStyle(color: AppColors.cream),
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _dayOfMonth = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ],

                // Child Assignment (for home jobs)
                if (_jobType == JobType.home) ...[
                  children.when(
                    data: (childList) {
                      if (childList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cream.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.cream.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.cream.withOpacity(0.7),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No children in your family yet. Invite them first!',
                                  style: TextStyle(
                                    color: AppColors.cream.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return DropdownButtonFormField<String>(
                        value: _selectedChildId,
                        dropdownColor: AppColors.backgroundDark,
                        style: const TextStyle(color: AppColors.cream),
                        decoration: _buildInputDecoration(
                          label: 'Assign to',
                          icon: Icons.person_outline,
                        ),
                        items: childList.map((child) {
                          return DropdownMenuItem(
                            value: child.id,
                            child: Text(
                              child.name,
                              style: const TextStyle(color: AppColors.cream),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedChildId = value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a child';
                          }
                          return null;
                        },
                      );
                    },
                    loading: () => const LoadingIndicator(),
                    error: (_, __) => const Text(
                      'Error loading children',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Location (for public jobs)
                if (_jobType == JobType.public) ...[
                  TextFormField(
                    controller: _locationController,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: AppColors.cream),
                    decoration: _buildInputDecoration(
                      label: 'Location',
                      hint: '123 Main St, City',
                      icon: Icons.location_on_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 32),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: _isLoading ? null : _handleCreateJob,
                    child: _isLoading
                        ? const LoadingIndicator(size: 20)
                        : const Text(
                            'Create Job',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobTypeOption(JobType type, String label, IconData icon) {
    final isSelected = _jobType == type;
    
    return InkWell(
      onTap: () => setState(() => _jobType = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cream.withOpacity(0.2) : AppColors.cream.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.cream : AppColors.cream.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.cream,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.cream,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTypeOption(ScheduleType type, String label, IconData icon) {
    final isSelected = _scheduleType == type;
    
    return InkWell(
      onTap: () => setState(() => _scheduleType = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cream.withOpacity(0.2) : AppColors.cream.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.cream : AppColors.cream.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.cream,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.cream,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: AppColors.cream.withOpacity(0.7)),
      hintStyle: TextStyle(color: AppColors.cream.withOpacity(0.5)),
      prefixIcon: Icon(
        icon,
        color: AppColors.cream.withOpacity(0.7),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.cream.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.cream,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: AppColors.cream.withOpacity(0.05),
    );
  }
}