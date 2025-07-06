import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/providers/job_provider.dart';
import '../../data/models/notification.dart' as app_notification;
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationProvider.notifier).loadFamilyNotifications();
      ref.read(notificationProvider.notifier).markAllAsRead();
    });
  }

  void _handlePublicJobApproval(String notificationId, String jobApplicationId, bool approved) {
    if (approved) {
      ref.read(jobProvider.notifier).approvePublicJobApplication(jobApplicationId);
    } else {
      ref.read(jobProvider.notifier).rejectPublicJobApplication(jobApplicationId);
    }
    ref.read(notificationProvider.notifier).dismissNotification(notificationId);
  }

  Widget _buildNotificationContent(app_notification.Notification notification) {
    switch (notification.type) {
      case NotificationType.PUBLIC_JOB_APPLICATION:
        return _buildPublicJobApplicationNotification(notification);
      case NotificationType.WITHDRAWAL_REQUEST:
        return _buildWithdrawalRequestNotification(notification);
      case NotificationType.JOB_COMPLETED:
        return _buildJobCompletedNotification(notification);
      case NotificationType.STORE_PURCHASE:
        return _buildStorePurchaseNotification(notification);
      default:
        return _buildDefaultNotification(notification);
    }
  }

  Widget _buildPublicJobApplicationNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final childName = data['childName'] ?? 'Your child';
    final jobTitle = data['jobTitle'] ?? 'a job';
    final employerName = data['employerName'] ?? 'an employer';
    final jobApplicationId = data['applicationId'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead 
              ? Colors.transparent 
              : AppTheme.accentColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                    color: AppTheme.warningColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.work_outline,
                    color: AppTheme.warningColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Public Job Application',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$childName wants to work for $employerName',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Job: $jobTitle',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateHelpers.formatRelativeTime(notification.createdAt),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handlePublicJobApproval(
                      notification.id,
                      jobApplicationId,
                      false,
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(color: AppTheme.errorColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handlePublicJobApproval(
                      notification.id,
                      jobApplicationId,
                      true,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalRequestNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final childName = data['childName'] ?? 'Your child';
    final amount = data['amount'] ?? 0.0;

    return NotificationTile(
      notification: notification,
      icon: Icons.account_balance_wallet_outlined,
      iconColor: AppTheme.warningColor,
      iconBackgroundColor: AppTheme.warningColor.withOpacity(0.1),
      title: 'Withdrawal Request',
      subtitle: '$childName requested ${CurrencyHelpers.formatCurrency(amount, CurrencyType.DOLLARS)}',
      onTap: () {
        Navigator.pushNamed(context, Routes.parentBank);
      },
    );
  }

  Widget _buildJobCompletedNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final childName = data['childName'] ?? 'Your child';
    final jobTitle = data['jobTitle'] ?? 'a job';

    return NotificationTile(
      notification: notification,
      icon: Icons.check_circle_outline,
      iconColor: AppTheme.successColor,
      iconBackgroundColor: AppTheme.successColor.withOpacity(0.1),
      title: 'Job Completed',
      subtitle: '$childName completed "$jobTitle"',
      onTap: () {
        Navigator.pushNamed(context, Routes.manageJobs);
      },
    );
  }

  Widget _buildStorePurchaseNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final childName = data['childName'] ?? 'Your child';
    final itemName = data['itemName'] ?? 'an item';
    final price = data['price'] ?? 0.0;
    final currencyType = data['currencyType'] == 'STARS' 
        ? CurrencyType.STARS 
        : CurrencyType.DOLLARS;

    return NotificationTile(
      notification: notification,
      icon: Icons.shopping_bag_outlined,
      iconColor: AppTheme.accentColor,
      iconBackgroundColor: AppTheme.accentColor.withOpacity(0.1),
      title: 'Store Purchase',
      subtitle: '$childName purchased "$itemName" for ${CurrencyHelpers.formatCurrency(price, currencyType)}',
      onTap: () {
        Navigator.pushNamed(context, Routes.familyStore);
      },
    );
  }

  Widget _buildDefaultNotification(app_notification.Notification notification) {
    return NotificationTile(
      notification: notification,
      icon: Icons.notifications_outlined,
      iconColor: AppTheme.textSecondary,
      iconBackgroundColor: AppTheme.textSecondary.withOpacity(0.1),
      title: notification.title,
      subtitle: notification.message,
      onTap: () {
        ref.read(notificationProvider.notifier).markAsRead(notification.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Notifications',
          style: AppTheme.headingLarge.copyWith(color: AppTheme.textPrimary),
        ),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppTheme.textPrimary),
            color: AppTheme.surfaceColor,
            onSelected: (value) {
              if (value == 'clear_all') {
                ref.read(notificationProvider.notifier).clearAllNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: AppTheme.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Clear All',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notificationState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: AppTheme.errorColor),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 80,
                    color: AppTheme.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Family activity will appear here',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          // Group notifications by date
          final groupedNotifications = <String, List<app_notification.Notification>>{};
          for (final notification in notifications) {
            final dateKey = DateHelpers.getDateGroupKey(notification.createdAt);
            groupedNotifications.putIfAbsent(dateKey, () => []).add(notification);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedNotifications.length,
            itemBuilder: (context, index) {
              final dateKey = groupedNotifications.keys.elementAt(index);
              final dateNotifications = groupedNotifications[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0) const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      dateKey,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...dateNotifications.map((notification) {
                    return _buildNotificationContent(notification);
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}