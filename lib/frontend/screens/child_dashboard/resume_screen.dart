import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/job_provider.dart';
import '../../data/providers/bank_provider.dart';
import '../../data/models/job.dart';
import '../../core/theme.dart';
import '../../core/helpers.dart';
import '../../widgets/loading_indicator.dart';

class ResumeScreen extends ConsumerStatefulWidget {
  const ResumeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends ConsumerState<ResumeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(jobProvider.notifier).loadMyJobs();
      ref.read(bankProvider.notifier).loadAccounts();
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppTheme.accent),
            SizedBox(width: 4),
          ],
          Text(
            skill,
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    DateTime? earnedDate,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 12,
                  ),
                ),
                if (earnedDate != null)
                  Text(
                    'Earned ${Helpers.formatDate(earnedDate)}',
                    style: TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider);
    final jobsState = ref.watch(jobProvider);
    final bankState = ref.watch(bankProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'My Resume',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: AppTheme.accent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Resume sharing coming soon!')),
              );
            },
          ),
        ],
      ),
      body: userState.when(
        data: (user) {
          if (user == null) return Center(child: Text('Not logged in'));

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Young Entrepreneur',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Member since ${Helpers.formatDate(user.createdAt)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Statistics Grid
                jobsState.when(
                  data: (jobs) {
                    final completedJobs = jobs.where((j) => 
                      j.status == 'COMPLETED' && j.assignedToId == user.id
                    ).toList();
                    
                    final totalEarnings = completedJobs.fold<double>(
                      0, (sum, job) => sum + job.wage
                    );
                    
                    final totalHours = completedJobs.length * 2; // Assuming 2 hours per job average
                    
                    final currentJobs = jobs.where((j) => 
                      j.status == 'IN_PROGRESS' && j.assignedToId == user.id
                    ).length;

                    return GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          icon: Icons.check_circle,
                          value: completedJobs.length.toString(),
                          label: 'Jobs Completed',
                          iconColor: Colors.green,
                        ),
                        _buildStatCard(
                          icon: Icons.attach_money,
                          value: '\$${totalEarnings.toStringAsFixed(0)}',
                          label: 'Total Earnings',
                          iconColor: AppTheme.accent,
                        ),
                        _buildStatCard(
                          icon: Icons.access_time,
                          value: totalHours.toString(),
                          label: 'Hours Worked',
                          iconColor: Colors.blue,
                        ),
                        _buildStatCard(
                          icon: Icons.star,
                          value: '4.8',
                          label: 'Average Rating',
                          iconColor: Colors.amber,
                        ),
                      ],
                    );
                  },
                  loading: () => LoadingIndicator(),
                  error: (_, __) => SizedBox(),
                ),
                SizedBox(height: 24),

                // Skills Section
                Text(
                  'Skills & Expertise',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSkillChip('Kitchen Cleaning', icon: Icons.kitchen),
                    _buildSkillChip('Pet Care', icon: Icons.pets),
                    _buildSkillChip('Lawn Care', icon: Icons.grass),
                    _buildSkillChip('Organization', icon: Icons.folder),
                    _buildSkillChip('Time Management', icon: Icons.schedule),
                    _buildSkillChip('Responsibility', icon: Icons.verified),
                  ],
                ),
                SizedBox(height: 24),

                // Work History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Work History',
                      style: TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/child/jobs');
                      },
                      child: Text(
                        'See all',
                        style: TextStyle(color: AppTheme.accent),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                jobsState.when(
                  data: (jobs) {
                    final completedJobs = jobs
                        .where((j) => j.status == 'COMPLETED' && j.assignedToId == user.id)
                        .toList()
                      ..sort((a, b) => (b.completedAt ?? DateTime.now())
                          .compareTo(a.completedAt ?? DateTime.now()));

                    if (completedJobs.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Complete jobs to build your work history',
                            style: TextStyle(color: AppTheme.secondaryText),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: completedJobs.take(5).map((job) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.widgetBackground,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.work,
                                  color: AppTheme.background,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title,
                                      style: TextStyle(
                                        color: AppTheme.primaryText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Completed ${Helpers.formatDate(job.completedAt!)}',
                                      style: TextStyle(
                                        color: AppTheme.secondaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                Helpers.formatCurrency(job.wage, job.currencyType),
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => LoadingIndicator(),
                  error: (_, __) => SizedBox(),
                ),
                SizedBox(height: 24),

                // Achievements & Badges
                Text(
                  'Achievements & Badges',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Column(
                  children: [
                    _buildBadgeCard(
                      title: 'First Job Completed',
                      description: 'Successfully completed your first job',
                      icon: Icons.flag,
                      color: Colors.green,
                      earnedDate: DateTime.now().subtract(Duration(days: 30)),
                    ),
                    SizedBox(height: 8),
                    _buildBadgeCard(
                      title: 'Super Saver',
                      description: 'Saved over \$50 in your savings account',
                      icon: Icons.savings,
                      color: Colors.blue,
                      earnedDate: DateTime.now().subtract(Duration(days: 15)),
                    ),
                    SizedBox(height: 8),
                    _buildBadgeCard(
                      title: 'Reliable Worker',
                      description: 'Completed 5 jobs on time',
                      icon: Icons.timer,
                      color: Colors.orange,
                      earnedDate: DateTime.now().subtract(Duration(days: 7)),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Certificates
                Text(
                  'Certificates',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.school, color: Colors.amber, size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Literacy Basic',
                              style: TextStyle(
                                color: AppTheme.primaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Understanding money, savings, and budgeting',
                              style: TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading resume',
            style: TextStyle(color: AppTheme.errorColor),
          ),
        ),
      ),
    );
  }
}