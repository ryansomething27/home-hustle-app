import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/bank_provider.dart';
import '../../data/providers/job_provider.dart';
import '../../data/providers/notification_provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../widgets/loading_indicator.dart';
import '../../navigation/routes.dart';

class ParentHomeScreen extends ConsumerStatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  ConsumerState<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends ConsumerState<ParentHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    Future.microtask(() {
      ref.read(bankProvider.notifier).loadFamilyAccounts();
      ref.read(jobProvider.notifier).loadFamilyJobs();
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  void _onBottomNavTap(int index) {
    if (index == 1) {
      // Add button - show options
      _showAddOptions();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.cream.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'What would you like to add?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.cream,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildAddOption(
              icon: Icons.work_outline,
              title: 'New Job',
              subtitle: 'Create a job for your children',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.createJob);
              },
            ),
            const SizedBox(height: 16),
            _buildAddOption(
              icon: Icons.shopping_bag_outlined,
              title: 'Store Item',
              subtitle: 'Add an item to the family store',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.familyStore);
              },
            ),
            const SizedBox(height: 16),
            _buildAddOption(
              icon: Icons.person_add_outlined,
              title: 'Invite Child',
              subtitle: 'Send an invite code to your child',
              onTap: () {
                Navigator.pop(context);
                _showInviteDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cream.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.cream,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.cream.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.cream.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog() {
    // TODO: Implement invite dialog
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final familyAccounts = ref.watch(bankProvider);
    final familyJobs = ref.watch(jobProvider);
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(user, familyAccounts, familyJobs, notifications),
            Container(), // Placeholder for add functionality
            _buildStatsTab(familyAccounts, familyJobs),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          border: Border(
            top: BorderSide(
              color: AppColors.cream.withOpacity(0.1),
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex == 2 ? 2 : 0,
          onTap: _onBottomNavTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.cream,
          unselectedItemColor: AppColors.cream.withOpacity(0.5),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 32),
              activeIcon: Icon(Icons.add_circle, size: 32),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(
    User? user,
    AsyncValue<List<Account>> familyAccounts,
    AsyncValue<List<Job>> familyJobs,
    AsyncValue<List<AppNotification>> notifications,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                            color: AppColors.cream.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user?.name ?? 'Parent',
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.notifications);
                          },
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.cream,
                            size: 28,
                          ),
                        ),
                        if (notifications.maybeWhen(
                          data: (list) => list.any((n) => !n.isRead),
                          orElse: () => false,
                        ))
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.backgroundDark,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Family Overview Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.cream.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Overview',
                        style: TextStyle(
                          color: AppColors.cream.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOverviewStat(
                            'Total Savings',
                            familyAccounts.maybeWhen(
                              data: (accounts) => Helpers.formatCurrency(
                                accounts
                                    .map((a) => a.balance)
                                    .fold(0.0, (a, b) => a + b),
                              ),
                              orElse: () => '--',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.cream.withOpacity(0.2),
                          ),
                          _buildOverviewStat(
                            'Active Jobs',
                            familyJobs.maybeWhen(
                              data: (jobs) => jobs
                                  .where((j) => j.status == JobStatus.active)
                                  .length
                                  .toString(),
                              orElse: () => '--',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.cream.withOpacity(0.2),
                          ),
                          _buildOverviewStat(
                            'Pending',
                            familyJobs.maybeWhen(
                              data: (jobs) => jobs
                                  .where((j) => j.status == JobStatus.pendingApproval)
                                  .length
                                  .toString(),
                              orElse: () => '--',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.cream,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            delegate: SliverChildListDelegate([
              _buildActionCard(
                icon: Icons.work_outline,
                label: 'Jobs',
                onTap: () => Navigator.pushNamed(context, Routes.manageJobs),
              ),
              _buildActionCard(
                icon: Icons.account_balance,
                label: 'Bank',
                onTap: () => Navigator.pushNamed(context, Routes.familyBank),
              ),
              _buildActionCard(
                icon: Icons.shopping_bag_outlined,
                label: 'Store',
                onTap: () => Navigator.pushNamed(context, Routes.familyStore),
              ),
              _buildActionCard(
                icon: Icons.people_outline,
                label: 'Children',
                onTap: () => Navigator.pushNamed(context, Routes.manageChildren),
              ),
              _buildActionCard(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => Navigator.pushNamed(context, Routes.settings),
              ),
              _buildActionCard(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () => Navigator.pushNamed(context, Routes.profile),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.cream,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.cream.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cream.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cream.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.cream,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.cream,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab(
    AsyncValue<List<Account>> familyAccounts,
    AsyncValue<List<Job>> familyJobs,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family Statistics',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.cream,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                // TODO: Add charts and detailed statistics
                Center(
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppColors.cream.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}