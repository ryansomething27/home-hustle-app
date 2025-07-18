import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../core/utils/format_utils.dart';
import '../data/models/job.dart';
import '../data/providers/auth_provider.dart';
import 'custom_button.dart';

/// A card widget that displays job information with actions based on user type
class JobCard extends ConsumerWidget {
  const JobCard({
    required this.job,
    super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewApplications,
    this.onMarkCompleted,
    this.onApply,
    this.onResign,
    this.application,
    this.hasApplied = false,
    this.isCompact = false,
  });

  final JobModel job;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewApplications;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onApply;
  final VoidCallback? onResign;
  final JobApplication? application;
  final bool hasApplied;
  final bool isCompact;

  Color _getStatusColor(String status) {
    switch (status) {
      case kJobStatusOpen:
        return kSuccessColor;
      case kJobStatusInProgress:
        return kWarningColor;
      case kJobStatusCompleted:
        return Colors.grey;
      case kJobStatusCancelled:
        return kErrorColor;
      case kJobStatusPendingApproval:
        return kInfoColor;
      default:
        return Colors.grey;
    }
  }

  Color _getCardBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (job.isFamilyJob) {
      return isDark 
          ? kSuccessColor.withValues(alpha: 0.1)
          : kSuccessColor.withValues(alpha: 0.05);
    } else {
      return isDark
          ? kInfoColor.withValues(alpha: 0.1)
          : kInfoColor.withValues(alpha: 0.05);
    }
  }

  Widget _buildStatusBadge(BuildContext context) {
    final statusColor = _getStatusColor(job.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSmallPadding,
        vertical: kSmallPadding / 2,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDark ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(kSmallBorderRadius),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        FormatUtils.formatJobStatus(job.status),
        style: TextStyle(
          color: isDark ? statusColor.withValues(alpha: 0.9) : statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildApplicationStatusBadge(BuildContext context) {
    if (application == null) {
      return const SizedBox.shrink();
    }
    
    final status = application!.status;
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'pending':
        statusColor = kWarningColor;
        statusText = 'Application Pending';
        break;
      case 'approved':
        statusColor = kSuccessColor;
        statusText = 'Application Approved';
        break;
      case 'rejected':
        statusColor = kErrorColor;
        statusText = 'Application Rejected';
        break;
      case 'withdrawn':
        statusColor = Colors.grey;
        statusText = 'Application Withdrawn';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown Status';
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSmallPadding,
        vertical: kSmallPadding / 2,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDark ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(kSmallBorderRadius),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: isDark ? statusColor.withValues(alpha: 0.9) : statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAdultActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (job.status == kJobStatusOpen && job.currentApplicants > 0)
          CustomButton(
            text: 'View Applications (${job.currentApplicants})',
            onPressed: onViewApplications,
            style: CustomButtonStyle.outline,
            size: ButtonSize.small,
          )
        else if (job.status == kJobStatusInProgress)
          CustomButton(
            text: 'Mark Completed',
            onPressed: onMarkCompleted,
            style: CustomButtonStyle.success,
            size: ButtonSize.small,
          ),
        Row(
          children: [
            if (job.status == kJobStatusOpen || job.status == kJobStatusInProgress)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Edit Job',
                color: Theme.of(context).colorScheme.primary,
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Delete Job',
              color: kErrorColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChildActions(BuildContext context) {
    if (application != null) {
      switch (application!.status) {
        case 'pending':
          return const CustomButton(
            text: 'Application Pending',
            onPressed: null,
            style: CustomButtonStyle.outline,
            size: ButtonSize.small,
            isDisabled: true,
          );
        case 'approved':
          if (job.status == kJobStatusInProgress) {
            return CustomButton(
              text: 'Resign from Job',
              onPressed: onResign,
              style: CustomButtonStyle.danger,
              size: ButtonSize.small,
            );
          }
          break;
        case 'rejected':
          return const Text(
            'Application Rejected',
            style: TextStyle(
              color: kErrorColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          );
      }
    } else if (job.isAvailable && !hasApplied) {
      return CustomButton(
        text: 'Apply for Job',
        onPressed: onApply,
        size: ButtonSize.small,
        icon: Icons.send,
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdult = authState.isAdult;
    final theme = Theme.of(context);
    
    return Card(
      color: _getCardBackgroundColor(context),
      elevation: kDefaultElevation,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: isCompact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: kSmallPadding / 2),
                        Text(
                          job.createdByName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: kDefaultPadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(context),
                      if (job.isUrgent) ...[
                        const SizedBox(height: kSmallPadding / 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSmallPadding,
                            vertical: kSmallPadding / 2,
                          ),
                          decoration: BoxDecoration(
                            color: kErrorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(kSmallBorderRadius),
                            border: Border.all(
                              color: kErrorColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.priority_high,
                                size: 14,
                                color: kErrorColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Urgent',
                                style: TextStyle(
                                  color: kErrorColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              if (!isCompact) ...[
                const SizedBox(height: kDefaultPadding),
                
                // Description
                Text(
                  job.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: kDefaultPadding),
                
                // Job Details Row
                Wrap(
                  spacing: kDefaultPadding,
                  runSpacing: kSmallPadding,
                  children: [
                    // Wage
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.wageType == 'fixed'
                              ? FormatUtils.formatCurrency(job.wage)
                              : '${FormatUtils.formatCurrency(job.wage)}/hr',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    
                    // Category
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.category,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    // Job Type
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          job.isFamilyJob ? Icons.home : Icons.public,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          FormatUtils.formatJobType(job.jobType),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    // Time posted
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          FormatUtils.formatRelativeTime(job.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Application Status Badge (for children)
                if (!isAdult && application != null) ...[
                  const SizedBox(height: kDefaultPadding),
                  _buildApplicationStatusBadge(context),
                ],
                
                // Actions
                const SizedBox(height: kDefaultPadding),
                if (isAdult)
                  _buildAdultActions(context)
                else
                  _buildChildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }
}