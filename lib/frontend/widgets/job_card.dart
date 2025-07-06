import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/helpers.dart';
import '../data/models/job.dart';
import '../data/models/user.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final UserRole userRole;
  final bool showDollars;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onComplete;
  final VoidCallback? onResign;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isCompact;

  const JobCard({
    Key? key,
    required this.job,
    required this.userRole,
    required this.showDollars,
    this.onTap,
    this.onApply,
    this.onComplete,
    this.onResign,
    this.onEdit,
    this.onDelete,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(isCompact ? 16 : 20),
        decoration: BoxDecoration(
          color: AppTheme.primaryDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (!isCompact) ...[
              const SizedBox(height: 12),
              _buildDescription(),
            ],
            const SizedBox(height: 12),
            _buildFooter(),
            if (_shouldShowActions()) ...[
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getCategoryColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(),
            color: _getCategoryColor(),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: TextStyle(
                  color: AppTheme.cream,
                  fontSize: isCompact ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildWage(),
                  if (job.type == JobType.public && job.distance != null) ...[
                    const SizedBox(width: 12),
                    _buildDistance(),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (userRole == UserRole.parent && job.type == JobType.home)
          _buildParentActions(),
      ],
    );
  }

  Widget _buildWage() {
    final wageText = showDollars
        ? Helpers.formatCurrency(job.wage)
        : Helpers.formatStars(job.wage);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cream.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$wageText/${_getFrequencyText()}',
        style: TextStyle(
          color: AppTheme.cream,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDistance() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: AppTheme.cream.withOpacity(0.6),
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          '${job.distance?.toStringAsFixed(1)} mi',
          style: TextStyle(
            color: AppTheme.cream.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    if (job.description == null || job.description!.isEmpty) return const SizedBox();
    
    return Text(
      job.description!,
      style: TextStyle(
        color: AppTheme.cream.withOpacity(0.8),
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        _buildStatus(),
        const Spacer(),
        if (job.schedule != null && job.schedule!.isNotEmpty)
          _buildSchedule(),
      ],
    );
  }

  Widget _buildStatus() {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (job.status) {
      case JobStatus.open:
        statusText = 'OPEN';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case JobStatus.pending:
        statusText = 'PENDING';
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case JobStatus.assigned:
        statusText = 'ASSIGNED';
        statusColor = Colors.blue;
        statusIcon = Icons.person;
        break;
      case JobStatus.inProgress:
        statusText = 'IN PROGRESS';
        statusColor = Colors.purple;
        statusIcon = Icons.play_circle_outline;
        break;
      case JobStatus.completed:
        statusText = 'COMPLETED';
        statusColor = AppTheme.cream.withOpacity(0.6);
        statusIcon = Icons.check_circle;
        break;
      case JobStatus.cancelled:
        statusText = 'CANCELLED';
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusText = 'UNKNOWN';
        statusColor = AppTheme.cream.withOpacity(0.4);
        statusIcon = Icons.help_outline;
    }

    return Row(
      children: [
        Icon(
          statusIcon,
          color: statusColor,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSchedule() {
    return Row(
      children: [
        Icon(
          Icons.schedule,
          color: AppTheme.cream.withOpacity(0.5),
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          job.schedule!,
          style: TextStyle(
            color: AppTheme.cream.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildParentActions() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppTheme.cream.withOpacity(0.6),
      ),
      color: AppTheme.primaryDark,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: AppTheme.cream, size: 18),
              const SizedBox(width: 8),
              Text('Edit', style: TextStyle(color: AppTheme.cream)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final List<Widget> actions = [];

    // Child actions
    if (userRole == UserRole.child) {
      if (job.status == JobStatus.open && onApply != null) {
        actions.add(_buildActionButton(
          'Apply',
          AppTheme.cream,
          AppTheme.primaryDark,
          onApply!,
        ));
      } else if (job.status == JobStatus.assigned && job.assigneeId != null) {
        if (onComplete != null) {
          actions.add(_buildActionButton(
            'Mark Complete',
            Colors.green,
            Colors.white,
            onComplete!,
          ));
        }
        if (onResign != null) {
          actions.add(_buildActionButton(
            'Resign',
            Colors.red.withOpacity(0.8),
            Colors.white,
            onResign!,
            outlined: true,
          ));
        }
      }
    }

    // Parent actions for assigned jobs
    if (userRole == UserRole.parent && job.status == JobStatus.assigned && onComplete != null) {
      actions.add(_buildActionButton(
        'Approve Completion',
        AppTheme.cream,
        AppTheme.primaryDark,
        onComplete!,
      ));
    }

    if (actions.isEmpty) return const SizedBox();

    return Row(
      children: actions.map((action) => 
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: action,
        ),
      ).toList(),
    );
  }

  Widget _buildActionButton(
    String label,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed, {
    bool outlined = false,
  }) {
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: backgroundColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: backgroundColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _shouldShowActions() {
    if (userRole == UserRole.child) {
      return (job.status == JobStatus.open && onApply != null) ||
          (job.status == JobStatus.assigned && (onComplete != null || onResign != null));
    }
    if (userRole == UserRole.parent) {
      return job.status == JobStatus.assigned && onComplete != null;
    }
    return false;
  }

  Color _getBorderColor() {
    switch (job.status) {
      case JobStatus.open:
        return Colors.green.withOpacity(0.3);
      case JobStatus.pending:
        return Colors.orange.withOpacity(0.3);
      case JobStatus.assigned:
      case JobStatus.inProgress:
        return AppTheme.cream.withOpacity(0.2);
      case JobStatus.completed:
        return AppTheme.cream.withOpacity(0.1);
      case JobStatus.cancelled:
        return Colors.red.withOpacity(0.2);
      default:
        return AppTheme.cream.withOpacity(0.1);
    }
  }

  IconData _getCategoryIcon() {
    switch (job.category) {
      case JobCategory.kitchen:
        return Icons.kitchen;
      case JobCategory.cleaning:
        return Icons.cleaning_services;
      case JobCategory.outdoor:
        return Icons.grass;
      case JobCategory.petCare:
        return Icons.pets;
      case JobCategory.organizing:
        return Icons.folder_special;
      case JobCategory.other:
      default:
        return Icons.work_outline;
    }
  }

  Color _getCategoryColor() {
    switch (job.category) {
      case JobCategory.kitchen:
        return Colors.orange;
      case JobCategory.cleaning:
        return Colors.blue;
      case JobCategory.outdoor:
        return Colors.green;
      case JobCategory.petCare:
        return Colors.pink;
      case JobCategory.organizing:
        return Colors.purple;
      case JobCategory.other:
      default:
        return AppTheme.cream;
    }
  }

  String _getFrequencyText() {
    switch (job.frequency) {
      case JobFrequency.once:
        return 'once';
      case JobFrequency.daily:
        return 'day';
      case JobFrequency.weekly:
        return 'week';
      case JobFrequency.monthly:
        return 'month';
      default:
        return 'job';
    }
  }
}