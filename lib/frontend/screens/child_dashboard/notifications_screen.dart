import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/notification_provider.dart';
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
      ref.read(notificationProvider.notifier).loadPersonalNotifications();
      ref.read(notificationProvider.notifier).markAllAsRead();
    });
  }

  Widget _buildNotificationContent(app_notification.Notification notification) {
    switch (notification.type) {
      case NotificationType.JOB_ASSIGNED:
        return _buildJobAssignedNotification(notification);
      case NotificationType.JOB_APPLICATION_APPROVED:
        return _buildJobApplicationApprovedNotification(notification);
      case NotificationType.JOB_APPLICATION_REJECTED:
        return _buildJobApplicationRejectedNotification(notification);
      case NotificationType.WITHDRAWAL_APPROVED:
        return _buildWithdrawalApprovedNotification(notification);
      case NotificationType.WITHDRAWAL_REJECTED:
        return _buildWithdrawalRejectedNotification(notification);
      case NotificationType.STORE_PURCHASE_CONFIRMED:
        return _buildStorePurchaseConfirmedNotification(notification);
      case NotificationType.PAYMENT_RECEIVED:
        return _buildPaymentReceivedNotification(notification);
      case NotificationType.ACHIEVEMENT_EARNED:
        return _buildAchievementEarnedNotification(notification);
      default:
        return _buildDefaultNotification(notification);
    }
  }

  Widget _buildJobAssignedNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final jobTitle = data['jobTitle'] ?? 'a job';
    final wage = data['wage'] ?? 0.0;

    return NotificationTile(
      notification: notification,
      icon: Icons.assignment_ind,
      iconColor: AppTheme.accentColor,
      iconBackgroundColor: AppTheme.accentColor.withOpacity(0.1),
      title: 'New Job Assigned',
      subtitle: 'You\'ve been assigned "$jobTitle" - Earn ${CurrencyHelpers.formatCurrency(wage, CurrencyType.DOLLARS)}',
      onTap: () {
        Navigator.pushNamed(context, Routes.myJobs);
      },
    );
  }

  Widget _buildJobApplicationApprovedNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final jobTitle = data['jobTitle'] ?? 'a job';
    final employerName = data['employerName'] ?? 'the employer';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead 
              ? Colors.transparent 
              : AppTheme.successColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ref.read(notificationProvider.notifier).markAsRead(notification.id);
          Navigator.pushNamed(context, Routes.myJobs);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration,
                  color: AppTheme.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Application Approved! 🎉',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your parents approved your application for "$jobTitle" with $employerName',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
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
      ),
    );
  }

  Widget _buildJobApplicationRejectedNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final jobTitle = data['jobTitle'] ?? 'a job';

    return NotificationTile(
      notification: notification,
      icon: Icons.work_off,
      iconColor: AppTheme.errorColor,
      iconBackgroundColor: AppTheme.errorColor.withOpacity(0.1),
      title: 'Job Application Not Approved',
      subtitle: 'Your application for "$jobTitle" was not approved by your parents',
      onTap: () {
        ref.read(notificationProvider.notifier).markAsRead(notification.id);
      },
    );
  }

  Widget _buildWithdrawalApprovedNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final amount = data['amount'] ?? 0.0;

    return NotificationTile(
      notification: notification,
      icon: Icons.account_balance_wallet,
      iconColor: AppTheme.successColor,
      iconBackgroundColor: AppTheme.successColor.withOpacity(0.1),
      title: 'Withdrawal Approved',
      subtitle: 'Your withdrawal request for ${CurrencyHelpers.formatCurrency(amount, CurrencyType.DOLLARS)} has been approved!',
      onTap: () {
        Navigator.pushNamed(context, Routes.childBank);
      },
    );
  }

  Widget _buildWithdrawalRejectedNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final amount = data['amount'] ?? 0.0;

    return NotificationTile(
      notification: notification,
      icon: Icons.money_off,
      iconColor: AppTheme.errorColor,
      iconBackgroundColor: AppTheme.errorColor.withOpacity(0.1),
      title: 'Withdrawal Not Approved',
      subtitle: 'Your withdrawal request for ${CurrencyHelpers.formatCurrency(amount, CurrencyType.DOLLARS)} was not approved',
      onTap: () {
        ref.read(notificationProvider.notifier).markAsRead(notification.id);
      },
    );
  }

  Widget _buildStorePurchaseConfirmedNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final itemName = data['itemName'] ?? 'an item';
    final price = data['price'] ?? 0.0;
    final currencyType = data['currencyType'] == 'STARS' 
        ? CurrencyType.STARS 
        : CurrencyType.DOLLARS;

    return NotificationTile(
      notification: notification,
      icon: Icons.shopping_bag,
      iconColor: AppTheme.accentColor,
      iconBackgroundColor: AppTheme.accentColor.withOpacity(0.1),
      title: 'Purchase Successful',
      subtitle: 'You purchased "$itemName" for ${CurrencyHelpers.formatCurrency(price, currencyType)}',
      onTap: () {
        ref.read(notificationProvider.notifier).markAsRead(notification.id);
      },
    );
  }

  Widget _buildPaymentReceivedNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final amount = data['amount'] ?? 0.0;
    final jobTitle = data['jobTitle'] ?? 'a job';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead 
              ? Colors.transparent 
              : AppTheme.successColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ref.read(notificationProvider.notifier).markAsRead(notification.id);
          Navigator.pushNamed(context, Routes.childBank);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.attach_money,
                  color: AppTheme.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Received! 💰',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You earned ${CurrencyHelpers.formatCurrency(amount, CurrencyType.DOLLARS)} for completing "$jobTitle"',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
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
      ),
    );
  }

  Widget _buildAchievementEarnedNotification(app_notification.Notification notification) {
    final data = notification.data ?? {};
    final achievementName = data['achievementName'] ?? 'an achievement';
    final achievementDescription = data['achievementDescription'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentColor.withOpacity(0.1),
            AppTheme.warningColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () {
          ref.read(notificationProvider.notifier).markAsRead(notification.id);
          Navigator.pushNamed(context, Routes.achievements);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
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
                      'New Achievement! 🏆',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievementName,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (achievementDescription.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        achievementDescription,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                    'Your updates will appear here',
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