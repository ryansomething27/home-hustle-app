import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/helpers.dart';
import '../data/models/notification.dart' as app;
import '../data/models/user.dart';

class NotificationTile extends StatelessWidget {
  final app.Notification notification;
  final UserRole userRole;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.userRole,
    this.onTap,
    this.onDismiss,
    this.onApprove,
    this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: onDismiss != null ? DismissDirection.endToStart : DismissDirection.none,
      background: _buildDismissBackground(),
      onDismissed: (_) => onDismiss?.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? AppTheme.primaryDark.withOpacity(0.3)
              : AppTheme.primaryDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? AppTheme.cream.withOpacity(0.1)
                : AppTheme.cream.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildContent(),
                  if (_shouldShowActions()) ...[
                    const SizedBox(height: 12),
                    _buildActions(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.delete,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: TextStyle(
                  color: AppTheme.cream,
                  fontSize: 16,
                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Helpers.formatRelativeTime(notification.timestamp),
                style: TextStyle(
                  color: AppTheme.cream.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (!notification.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getTypeColor(),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      notification.message,
      style: TextStyle(
        color: AppTheme.cream.withOpacity(0.8),
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        if (onApprove != null)
          _buildActionButton(
            'Approve',
            Colors.green,
            Icons.check,
            onApprove!,
          ),
        if (onApprove != null && onReject != null)
          const SizedBox(width: 8),
        if (onReject != null)
          _buildActionButton(
            'Reject',
            Colors.red,
            Icons.close,
            onReject!,
            outlined: true,
          ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onPressed, {
    bool outlined = false,
  }) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  bool _shouldShowActions() {
    // Show actions for approval notifications when user is a parent
    return userRole == UserRole.parent && 
           (notification.type == app.NotificationType.jobApproval ||
            notification.type == app.NotificationType.withdrawalRequest ||
            notification.type == app.NotificationType.publicJobApplication) &&
           (onApprove != null || onReject != null);
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case app.NotificationType.jobOffer:
        return Icons.work_outline;
      case app.NotificationType.jobApproval:
      case app.NotificationType.publicJobApplication:
        return Icons.approval;
      case app.NotificationType.jobComplete:
        return Icons.check_circle_outline;
      case app.NotificationType.payment:
        return Icons.attach_money;
      case app.NotificationType.withdrawalRequest:
        return Icons.account_balance;
      case app.NotificationType.storeUpdate:
        return Icons.store;
      case app.NotificationType.achievement:
        return Icons.emoji_events;
      case app.NotificationType.reminder:
        return Icons.alarm;
      case app.NotificationType.general:
      default:
        return Icons.notifications_none;
    }
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case app.NotificationType.jobOffer:
        return Colors.blue;
      case app.NotificationType.jobApproval:
      case app.NotificationType.publicJobApplication:
        return Colors.orange;
      case app.NotificationType.jobComplete:
        return Colors.green;
      case app.NotificationType.payment:
        return Colors.green;
      case app.NotificationType.withdrawalRequest:
        return Colors.purple;
      case app.NotificationType.storeUpdate:
        return Colors.pink;
      case app.NotificationType.achievement:
        return Colors.amber;
      case app.NotificationType.reminder:
        return Colors.red;
      case app.NotificationType.general:
      default:
        return AppTheme.cream;
    }
  }
}

// Compact version for notification badge/preview
class CompactNotificationTile extends StatelessWidget {
  final app.Notification notification;
  final VoidCallback? onTap;

  const CompactNotificationTile({
    Key? key,
    required this.notification,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.cream.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getTypeIcon(),
              color: _getTypeColor(),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: AppTheme.cream,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: AppTheme.cream.withOpacity(0.6),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getTypeColor(),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case app.NotificationType.jobOffer:
        return Icons.work_outline;
      case app.NotificationType.jobApproval:
      case app.NotificationType.publicJobApplication:
        return Icons.approval;
      case app.NotificationType.jobComplete:
        return Icons.check_circle_outline;
      case app.NotificationType.payment:
        return Icons.attach_money;
      case app.NotificationType.withdrawalRequest:
        return Icons.account_balance;
      case app.NotificationType.storeUpdate:
        return Icons.store;
      case app.NotificationType.achievement:
        return Icons.emoji_events;
      case app.NotificationType.reminder:
        return Icons.alarm;
      case app.NotificationType.general:
      default:
        return Icons.notifications_none;
    }
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case app.NotificationType.jobOffer:
        return Colors.blue;
      case app.NotificationType.jobApproval:
      case app.NotificationType.publicJobApplication:
        return Colors.orange;
      case app.NotificationType.jobComplete:
        return Colors.green;
      case app.NotificationType.payment:
        return Colors.green;
      case app.NotificationType.withdrawalRequest:
        return Colors.purple;
      case app.NotificationType.storeUpdate:
        return Colors.pink;
      case app.NotificationType.achievement:
        return Colors.amber;
      case app.NotificationType.reminder:
        return Colors.red;
      case app.NotificationType.general:
      default:
        return AppTheme.cream;
    }
  }
}