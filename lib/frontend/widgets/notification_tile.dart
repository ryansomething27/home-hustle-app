import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../core/utils/format_utils.dart';
import '../data/models/notification.dart';
import 'custom_button.dart';

/// A tile widget that displays notification information with swipe actions
class NotificationTile extends ConsumerWidget {
  const NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
    super.key,
    this.onActionPressed,
    this.showActions = true,
    this.isCompact = false,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;
  final Function(NotificationAction)? onActionPressed;
  final bool showActions;
  final bool isCompact;

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case 'job_assigned':
      case 'job_completed':
      case 'job_applied':
        return Icons.work_outline;
      case 'payment_received':
        return Icons.arrow_downward;
      case 'payment_sent':
        return Icons.arrow_upward;
      case 'family_invite':
        return Icons.family_restroom;
      case 'reminder':
        return Icons.alarm;
      case 'general':
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (notification.type) {
      case 'job_assigned':
      case 'job_completed':
      case 'job_applied':
        return theme.colorScheme.primary;
      case 'payment_received':
        return kSuccessColor;
      case 'payment_sent':
        return kWarningColor;
      case 'family_invite':
        return kSecondaryColor;
      case 'reminder':
        return kInfoColor;
      case 'general':
      default:
        return theme.colorScheme.secondary;
    }
  }

  Widget _buildPriorityIndicator(BuildContext context) {
    if (!notification.isHighPriority) {
      return const SizedBox.shrink();
    }

    final color = notification.isUrgent ? kErrorColor : kWarningColor;
    
    return Container(
      width: 4,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(kDefaultBorderRadius),
          bottomLeft: Radius.circular(kDefaultBorderRadius),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    final color = _getNotificationColor(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getNotificationIcon(),
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildNotificationContent(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = notification.isRead
        ? theme.textTheme.titleMedium
        : theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          );
    final bodyStyle = notification.isRead
        ? theme.textTheme.bodySmall
        : theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          );
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: titleStyle,
                  maxLines: isCompact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: kSmallPadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            notification.body,
            style: bodyStyle,
            maxLines: isCompact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (notification.senderName != null) ...[
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  notification.senderName!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
              ],
              Icon(
                Icons.access_time,
                size: 14,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                FormatUtils.formatRelativeTime(notification.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceDetails(BuildContext context) {
    if (!notification.type.contains('payment') || notification.metadata == null) {
      return const SizedBox.shrink();
    }

    final amount = notification.metadata?['amount'] as double?;
    if (amount == null) return const SizedBox.shrink();

    Theme.of(context);
    final isReceived = notification.type == 'payment_received';
    final color = isReceived ? kSuccessColor : kErrorColor;

    return Container(
      margin: const EdgeInsets.only(top: kSmallPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: kSmallPadding,
        vertical: kSmallPadding / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(kSmallBorderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isReceived ? Icons.add : Icons.remove,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            FormatUtils.formatCurrency(amount),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetails(BuildContext context) {
    if (!notification.type.contains('job') || notification.metadata == null) {
      return const SizedBox.shrink();
    }

    final jobTitle = notification.metadata?['jobTitle'] as String?;
    final jobStatus = notification.metadata?['jobStatus'] as String?;
    
    if (jobTitle == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: kSmallPadding),
      padding: const EdgeInsets.all(kSmallPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(kSmallBorderRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.work_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: kSmallPadding),
          Expanded(
            child: Text(
              jobTitle,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (jobStatus != null) ...[
            const SizedBox(width: kSmallPadding),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSmallPadding,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(kSmallBorderRadius),
              ),
              child: Text(
                FormatUtils.formatJobStatus(jobStatus),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (!notification.hasActions || !showActions || isCompact) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: kDefaultPadding),
      child: Row(
        children: notification.actions!.map((action) {
          final isPrimary = action.isPrimary;
          return Padding(
            padding: const EdgeInsets.only(right: kSmallPadding),
            child: CustomButton(
              text: action.label,
              onPressed: () => onActionPressed?.call(action),
              style: isPrimary 
                  ? CustomButtonStyle.primary 
                  : CustomButtonStyle.outline,
              size: ButtonSize.small,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required AlignmentGeometry alignment,
    required EdgeInsetsGeometry padding,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final backgroundColor = notification.isRead
        ? theme.cardColor
        : (isDark 
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.primary.withValues(alpha: 0.02));

    final content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          border: Border.all(
            color: notification.isRead 
                ? theme.dividerColor.withValues(alpha: 0.2)
                : theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            _buildPriorityIndicator(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNotificationIcon(context),
                        const SizedBox(width: kDefaultPadding),
                        _buildNotificationContent(context),
                      ],
                    ),
                    _buildFinanceDetails(context),
                    _buildJobDetails(context),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isCompact) {
      return content;
    }

    return Dismissible(
      key: Key(notification.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - mark as read/unread
          onMarkAsRead();
          return false; // Don't dismiss the tile
        } else {
          // Swipe left - delete
          return true; // Allow dismissal
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      background: _buildSwipeBackground(
        color: theme.colorScheme.primary,
        icon: notification.isRead ? Icons.mark_as_unread : Icons.done_all,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: kLargePadding),
      ),
      secondaryBackground: _buildSwipeBackground(
        color: kErrorColor,
        icon: Icons.delete_outline,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: kLargePadding),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: kSmallPadding,
        ),
        child: content,
      ),
    );
  }
}