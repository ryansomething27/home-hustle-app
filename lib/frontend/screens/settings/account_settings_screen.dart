import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/user.dart';
import '../../core/theme.dart';
import '../../navigation/routes.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppTheme.cream,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.cream),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildUserInfoCard(user),
            const SizedBox(height: 24),
            _buildSettingsSection(
              context,
              ref,
              'General',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: 'Update your personal information',
                  onTap: () => Navigator.pushNamed(context, Routes.profile),
                ),
                if (user?.role == UserRole.parent)
                  _buildSettingsTile(
                    context,
                    icon: Icons.family_restroom,
                    title: 'Family Settings',
                    subtitle: 'Manage family preferences',
                    onTap: () => Navigator.pushNamed(context, Routes.accountSettings),
                  ),
                _buildThemeToggle(context, ref),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(
              context,
              ref,
              'Notifications',
              [
                _buildNotificationToggle(
                  context,
                  ref,
                  'Push Notifications',
                  'pushNotifications',
                  true,
                ),
                _buildNotificationToggle(
                  context,
                  ref,
                  'Job Alerts',
                  'jobAlerts',
                  true,
                ),
                if (user?.role == UserRole.parent)
                  _buildNotificationToggle(
                    context,
                    ref,
                    'Approval Requests',
                    'approvalRequests',
                    true,
                  ),
                if (user?.role == UserRole.child)
                  _buildNotificationToggle(
                    context,
                    ref,
                    'Store Updates',
                    'storeUpdates',
                    true,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(
              context,
              ref,
              'Privacy & Security',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () => _showChangePasswordDialog(context),
                ),
                if (user?.role == UserRole.parent)
                  _buildSettingsTile(
                    context,
                    icon: Icons.security,
                    title: 'Privacy Settings',
                    subtitle: 'Control data sharing and visibility',
                    onTap: () => _showPrivacySettings(context),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(
              context,
              ref,
              'Support',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'Get help and find answers',
                  onTap: () => _showHelpCenter(context),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.policy_outlined,
                  title: 'Terms & Privacy',
                  subtitle: 'Review our policies',
                  onTap: () => _showTermsAndPrivacy(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(context, ref),
            const SizedBox(height: 16),
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cream.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.cream,
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: TextStyle(
                    color: AppTheme.cream,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: AppTheme.cream.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.cream.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleDisplayName(user?.role),
                    style: TextStyle(
                      color: AppTheme.cream,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSettingsSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<Widget> tiles,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.cream.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cream.withOpacity(0.1)),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cream.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.cream,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.cream,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.cream.withOpacity(0.6),
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.cream.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref) {
    // TODO: Implement theme provider
    final isDarkMode = true; // Default for now
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cream.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: AppTheme.cream,
          size: 20,
        ),
      ),
      title: Text(
        'Dark Mode',
        style: TextStyle(
          color: AppTheme.cream,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        isDarkMode ? 'Currently enabled' : 'Currently disabled',
        style: TextStyle(
          color: AppTheme.cream.withOpacity(0.6),
          fontSize: 13,
        ),
      ),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          // TODO: Implement theme switching
        },
        activeColor: AppTheme.cream,
        activeTrackColor: AppTheme.cream.withOpacity(0.3),
      ),
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    WidgetRef ref,
    String title,
    String key,
    bool defaultValue,
  ) {
    // TODO: Implement notification preferences provider
    final isEnabled = defaultValue;
    
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.cream,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch(
        value: isEnabled,
        onChanged: (value) {
          // TODO: Update notification preference
        },
        activeColor: AppTheme.cream,
        activeTrackColor: AppTheme.cream.withOpacity(0.3),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => _showLogoutConfirmation(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Log Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Text(
        'Version 1.0.0',
        style: TextStyle(
          color: AppTheme.cream.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
    );
  }

  String _getRoleDisplayName(UserRole? role) {
    switch (role) {
      case UserRole.parent:
        return 'Parent';
      case UserRole.child:
        return 'Child';
      case UserRole.employer:
        return 'Employer';
      default:
        return 'User';
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        title: Text(
          'Change Password',
          style: TextStyle(color: AppTheme.cream),
        ),
        content: Text(
          'Password change functionality coming soon.',
          style: TextStyle(color: AppTheme.cream.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppTheme.cream)),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    // TODO: Implement privacy settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Privacy settings coming soon')),
    );
  }

  void _showHelpCenter(BuildContext context) {
    // TODO: Implement help center
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Help center coming soon')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        title: Text(
          'About Home Hustle',
          style: TextStyle(color: AppTheme.cream),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(color: AppTheme.cream.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            Text(
              'Home Hustle builds financially smart, responsible, and entrepreneurial kids by turning household responsibilities into real-world success skills.',
              style: TextStyle(color: AppTheme.cream.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 Home Hustle',
              style: TextStyle(color: AppTheme.cream.withOpacity(0.6)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppTheme.cream)),
          ),
        ],
      ),
    );
  }

  void _showTermsAndPrivacy(BuildContext context) {
    // TODO: Navigate to terms and privacy screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terms & Privacy coming soon')),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        title: Text(
          'Log Out',
          style: TextStyle(color: AppTheme.cream),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppTheme.cream.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.cream.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.login,
                (route) => false,
              );
            },
            child: Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}