import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../data/models/job.dart';
import '../data/models/notification.dart';
import '../data/models/store.dart';
import '../data/providers/auth_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/job_card.dart';
import '../widgets/notification_tile.dart';
import '../widgets/store_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdult = authState.isAdult;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdult ? 'Parent Dashboard' : 'My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: isAdult 
          ? const _AdultHomeContent() 
          : const _ChildHomeContent(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work),
            label: isAdult ? 'Jobs' : 'Find Work',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Bank',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // TODO: Implement navigation
        },
      ),
    );
  }
}

class _AdultHomeContent extends StatelessWidget {
  const _AdultHomeContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock data for testing
    final mockJobs = _getMockJobs();
    final mockNotifications = _getMockNotifications();
    final mockStoreItems = _getMockStoreItems();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome back, Parent!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kLargePadding),
          
          // Balance Overview
          const BalanceCard(
            showActions: true,
            onDeposit: _showComingSoon,
            onWithdraw: _showComingSoon,
            onTransfer: _showComingSoon,
            onViewAllTransactions: _showComingSoon,
          ),
          const SizedBox(height: kLargePadding),
          
          // Recent Jobs Section
          _buildSectionHeader(
            context,
            'Recent Jobs',
            'View All',
            _showComingSoon,
          ),
          const SizedBox(height: kDefaultPadding),
          ...mockJobs.take(2).map((job) => Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding),
            child: JobCard(
              job: job,
              onTap: _showComingSoon,
              onEdit: _showComingSoon,
              onDelete: _showComingSoon,
              onViewApplications: _showComingSoon,
              onMarkCompleted: _showComingSoon,
            ),
          )),
          
          const SizedBox(height: kLargePadding),
          
          // Store Items Section
          _buildSectionHeader(
            context,
            'Store Items',
            'Manage Store',
            _showComingSoon,
          ),
          const SizedBox(height: kDefaultPadding),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mockStoreItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 200,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < mockStoreItems.length - 1 ? kDefaultPadding : 0,
                    ),
                    child: StoreItemTile(
                      item: mockStoreItems[index],
                      onTap: _showComingSoon,
                      onEdit: _showComingSoon,
                      onToggleActive: _showComingSoon,
                      isNew: index == 0,
                      isOnSale: index == 1,
                      salePrice: index == 1 ? 7.99 : null,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: kLargePadding),
          
          // Notifications Section
          _buildSectionHeader(
            context,
            'Recent Activity',
            'View All',
            _showComingSoon,
          ),
          const SizedBox(height: kDefaultPadding),
          ...mockNotifications.take(3).map((notification) => Padding(
            padding: const EdgeInsets.only(bottom: kSmallPadding),
            child: NotificationTile(
              notification: notification,
              onTap: _showComingSoon,
              onMarkAsRead: _showComingSoon,
              onDelete: _showComingSoon,
              onActionPressed: (action) => _showComingSoon(),
            ),
          )),
        ],
      ),
    );
  }
}

class _ChildHomeContent extends StatelessWidget {
  const _ChildHomeContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock data for testing
    final mockJobs = _getMockJobs();
    final mockNotifications = _getMockNotifications();
    final mockStoreItems = _getMockStoreItems();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Hi there, Champ! 🌟',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kLargePadding),
          
          // Balance Card
          const BalanceCard(
            showActions: true,
            onRequestMoney: _showComingSoon,
            onViewAllTransactions: _showComingSoon,
          ),
          const SizedBox(height: kLargePadding),
          
          // Available Jobs Section
          _buildSectionHeader(
            context,
            'Jobs You Can Do',
            'See More',
            _showComingSoon,
          ),
          const SizedBox(height: kDefaultPadding),
          ...mockJobs.where((job) => job.status == kJobStatusOpen).take(2).map((job) => Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding),
            child: JobCard(
              job: job,
              onTap: _showComingSoon,
              onApply: _showComingSoon,
              hasApplied: false,
            ),
          )),
          
          const SizedBox(height: kLargePadding),
          
          // Store Rewards Section
          _buildSectionHeader(
            context,
            '🎁 Rewards Store',
            'View All',
            _showComingSoon,
          ),
          const SizedBox(height: kDefaultPadding),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mockStoreItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 200,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < mockStoreItems.length - 1 ? kDefaultPadding : 0,
                    ),
                    child: StoreItemTile(
                      item: mockStoreItems[index],
                      onTap: _showComingSoon,
                      onBuy: _showComingSoon,
                      isNew: index == 0,
                      isOnSale: index == 1,
                      salePrice: index == 1 ? 7.99 : null,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: kLargePadding),
          
          // Notifications Section
          _buildSectionHeader(
            context,
            'Your Updates',
            'See All',
            _showComingSoon,
          ),
          const SizedBox(height: kDefaultPadding),
          ...mockNotifications.take(2).map((notification) => Padding(
            padding: const EdgeInsets.only(bottom: kSmallPadding),
            child: NotificationTile(
              notification: notification,
              onTap: _showComingSoon,
              onMarkAsRead: _showComingSoon,
              onDelete: _showComingSoon,
              isCompact: true,
            ),
          )),
        ],
      ),
    );
  }
}

// Helper widget for section headers
Widget _buildSectionHeader(
  BuildContext context,
  String title,
  String actionText,
  VoidCallback onTap,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      TextButton(
        onPressed: onTap,
        child: Text(actionText),
      ),
    ],
  );
}

// Placeholder function for coming soon features
void _showComingSoon() {
  debugPrint('Feature coming soon!');
}

// Mock data generators
List<JobModel> _getMockJobs() {
  return [
    JobModel(
      id: '1',
      title: 'Clean the Living Room',
      description: 'Vacuum the carpet, dust the furniture, and organize the coffee table.',
      wage: 15.0,
      wageType: 'fixed',
      jobType: 'family',
      category: 'Cleaning',
      status: 'open',
      createdById: 'parent1',
      createdByName: 'Mom',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isUrgent: true,
      currentApplicants: 2,
    ),
    JobModel(
      id: '2',
      title: 'Walk the Dog',
      description: 'Take Max for a 30-minute walk around the neighborhood.',
      wage: 5.0,
      wageType: 'fixed',
      jobType: 'family',
      category: 'Pet Care',
      status: 'in_progress',
      createdById: 'parent2',
      createdByName: 'Dad',
      assignedToId: 'child1',
      assignedToName: 'Alex',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    JobModel(
      id: '3',
      title: 'Help with Grocery Shopping',
      description: 'Assist with carrying groceries and putting them away.',
      wage: 10.0,
      wageType: 'fixed',
      jobType: 'family',
      category: 'Errands',
      status: 'open',
      createdById: 'parent1',
      createdByName: 'Mom',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      estimatedDuration: 60,
    ),
  ];
}

List<NotificationModel> _getMockNotifications() {
  return [
    NotificationModel(
      id: '1',
      type: 'job_applied',
      title: 'New Job Application',
      body: 'Sarah applied for "Clean the Living Room"',
      recipientId: 'parent1',
      senderId: 'child2',
      senderName: 'Sarah',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      priority: 'high',
      actions: [
        NotificationAction(
          id: 'approve',
          label: 'Approve',
          action: 'custom',
          isPrimary: true,
        ),
        NotificationAction(
          id: 'reject',
          label: 'Reject',
          action: 'custom',
        ),
      ],
    ),
    NotificationModel(
      id: '2',
      type: 'payment_received',
      title: 'Payment Received!',
      body: 'You earned \$5.00 for completing "Walk the Dog"',
      recipientId: 'child1',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
      metadata: {'amount': 5.0},
    ),
    NotificationModel(
      id: '3',
      type: 'reminder',
      title: 'Job Reminder',
      body: 'Don\'t forget to complete "Help with Grocery Shopping" by 5 PM',
      recipientId: 'child1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      priority: 'normal',
    ),
  ];
}

List<StoreItem> _getMockStoreItems() {
  return [
    StoreItem(
      id: '1',
      name: 'Extra Screen Time',
      description: '30 minutes of additional screen time for games or videos',
      price: 10.0,
      category: 'Privileges',
      itemType: 'privilege',
      createdById: 'parent1',
      createdByName: 'Mom',
      familyId: 'family1',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      stock: 5,
    ),
    StoreItem(
      id: '2',
      name: 'Pizza Night',
      description: 'Choose the pizza toppings for family pizza night',
      price: 15.0,
      category: 'Experiences',
      itemType: 'experience',
      createdById: 'parent1',
      createdByName: 'Mom',
      familyId: 'family1',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      requiresApproval: true,
    ),
    StoreItem(
      id: '3',
      name: 'Toy Store Gift Card',
      description: '\$10 gift card to your favorite toy store',
      price: 50.0,
      category: 'Rewards',
      itemType: 'reward',
      createdById: 'parent1',
      createdByName: 'Mom',
      familyId: 'family1',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      stock: 3,
      ageRestriction: 8,
    ),
    StoreItem(
      id: '4',
      name: 'Movie Night Choice',
      description: 'Pick the movie for family movie night',
      price: 20.0,
      category: 'Experiences',
      itemType: 'experience',
      createdById: 'parent2',
      createdByName: 'Dad',
      familyId: 'family1',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];
}