import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/bank_provider.dart';
import '../../data/providers/job_provider.dart';
import '../../data/providers/notification_provider.dart';
import '../../core/theme.dart';
import '../../core/helpers.dart';
import '../../navigation/routes.dart';
import '../../widgets/loading_indicator.dart';

class ChildHomeScreen extends ConsumerStatefulWidget {
  const ChildHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends ConsumerState<ChildHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(bankProvider.notifier).loadAccounts();
      ref.read(jobProvider.notifier).loadMyJobs();
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? AppTheme.accent, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? backgroundColor,
    Widget? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.widgetBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: AppTheme.background,
                ),
                SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.background,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 12,
                right: 12,
                child: badge,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider);
    final bankState = ref.watch(bankProvider);
    final jobsState = ref.watch(jobProvider);
    final notificationsState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: userState.when(
          data: (user) {
            if (user == null) return Center(child: Text('Not logged in'));

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            user.name,
                            style: TextStyle(
                              color: AppTheme.primaryText,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: AppTheme.accent,
                        radius: 24,
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.background,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Balance Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        bankState.when(
                          data: (accounts) {
                            final totalBalance = accounts.fold<double>(
                              0,
                              (sum, account) => sum + account.balance,
                            );
                            final currencyDisplay = user.settings?.currencyDisplay ?? 'dollars';
                            return Text(
                              Helpers.formatCurrency(totalBalance, currencyDisplay),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                          loading: () => Text(
                            '--',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          error: (_, __) => Text(
                            '\$0.00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '+12% this month',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: jobsState.when(
                          data: (jobs) {
                            final activeJobs = jobs.where((j) => 
                              j.status == 'IN_PROGRESS' && j.assignedToId == user.id
                            ).length;
                            return _buildStatCard(
                              icon: Icons.work,
                              label: 'Active Jobs',
                              value: activeJobs.toString(),
                              iconColor: Colors.blue,
                            );
                          },
                          loading: () => _buildStatCard(
                            icon: Icons.work,
                            label: 'Active Jobs',
                            value: '--',
                            iconColor: Colors.blue,
                          ),
                          error: (_, __) => _buildStatCard(
                            icon: Icons.work,
                            label: 'Active Jobs',
                            value: '0',
                            iconColor: Colors.blue,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.star,
                          label: 'Stars Earned',
                          value: '47',
                          iconColor: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Navigation Grid
                  Text(
                    'What would you like to do?',
                    style: TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildNavigationTile(
                        icon: Icons.checklist,
                        label: 'Jobs',
                        onTap: () => Navigator.pushNamed(context, Routes.childJobs),
                      ),
                      _buildNavigationTile(
                        icon: Icons.account_balance,
                        label: 'Bank',
                        onTap: () => Navigator.pushNamed(context, Routes.childBank),
                      ),
                      _buildNavigationTile(
                        icon: Icons.store,
                        label: 'Store',
                        onTap: () => Navigator.pushNamed(context, Routes.childStore),
                      ),
                      _buildNavigationTile(
                        icon: Icons.location_on,
                        label: 'Public Jobs',
                        onTap: () => Navigator.pushNamed(context, Routes.publicJobs),
                      ),
                      _buildNavigationTile(
                        icon: Icons.person,
                        label: 'Resume',
                        onTap: () => Navigator.pushNamed(context, Routes.childResume),
                      ),
                      _buildNavigationTile(
                        icon: Icons.notifications,
                        label: 'Alerts',
                        onTap: () => Navigator.pushNamed(context, Routes.notifications),
                        badge: notificationsState.when(
                          data: (notifications) {
                            final unreadCount = notifications.where((n) => !n.isRead).length;
                            if (unreadCount == 0) return null;
                            return Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          loading: () => null,
                          error: (_, __) => null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          color: AppTheme.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, Routes.notifications),
                        child: Text(
                          'See all',
                          style: TextStyle(color: AppTheme.accent),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  notificationsState.when(
                    data: (notifications) {
                      final recentNotifications = notifications.take(3).toList();
                      if (recentNotifications.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'No recent activity',
                              style: TextStyle(color: AppTheme.secondaryText),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: recentNotifications.map((notification) {
                          IconData icon;
                          Color iconColor;
                          switch (notification.type) {
                            case 'JOB_COMPLETED':
                              icon = Icons.check_circle;
                              iconColor = Colors.green;
                              break;
                            case 'PAYMENT_RECEIVED':
                              icon = Icons.attach_money;
                              iconColor = AppTheme.accent;
                              break;
                            case 'JOB_ASSIGNED':
                              icon = Icons.work;
                              iconColor = Colors.blue;
                              break;
                            default:
                              icon = Icons.info;
                              iconColor = AppTheme.secondaryText;
                          }
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(icon, color: iconColor, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.title,
                                        style: TextStyle(
                                          color: AppTheme.primaryText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        notification.message,
                                        style: TextStyle(
                                          color: AppTheme.secondaryText,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  Helpers.timeAgo(notification.timestamp),
                                  style: TextStyle(
                                    color: AppTheme.secondaryText,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => LoadingIndicator(),
                    error: (_, __) => Container(),
                  ),
                ],
              ),
            );
          },
          loading: () => Center(child: LoadingIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error loading data',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ),
      ),
    );
  }
}