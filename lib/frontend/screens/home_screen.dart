import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../data/models/job.dart';
import '../data/models/store.dart';  // ADD THIS LINE
import '../data/providers/auth_provider.dart';
import '../widgets/job_card.dart';

// Navigation index provider to track current tab
final navigationIndexProvider = StateProvider<int>((ref) => 0);

// Simple balance provider
final balanceProvider = StateProvider<double>((ref) => 125.50);

// Applied jobs provider - just tracks job IDs
final appliedJobsProvider = StateProvider<List<String>>((ref) => []);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // TEMPORARY: If not authenticated, show login options
    if (!authState.isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Home Hustle',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Text('Please login to continue'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).mockLogin(asAdult: true);
                },
                child: const Text('Login as Parent'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).mockLogin(asAdult: false);
                },
                child: const Text('Login as Child'),
              ),
            ],
          ),
        ),
      );
    }
    
    final isAdult = authState.isAdult;
    final currentIndex = ref.watch(navigationIndexProvider);
    final balance = ref.watch(balanceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(currentIndex, isAdult)),
        actions: [
          // Show balance in app bar
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '\$${balance.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          // HOME TAB
          _buildHomeTab(context, isAdult, ref),
          
          // JOBS TAB
          _buildJobsTab(context, isAdult, ref),
          
          // STORE TAB
          _buildStoreTab(context, ref),
          
          // BANK TAB
          _buildBankTab(context, isAdult, ref),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.work_outline),
            selectedIcon: const Icon(Icons.work),
            label: isAdult ? 'Jobs' : 'Find Work',
          ),
          const NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Store',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Bank',
          ),
        ],
      ),
    );
  }
  
  String _getTitle(int index, bool isAdult) {
    switch (index) {
      case 0:
        return isAdult ? 'Parent Dashboard' : 'My Dashboard';
      case 1:
        return isAdult ? 'Jobs Management' : 'Find Work';
      case 2:
        return 'Family Store';
      case 3:
        return 'Bank';
      default:
        return 'Home Hustle';
    }
  }

  Widget _buildHomeTab(BuildContext context, bool isAdult, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final appliedJobs = ref.watch(appliedJobsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAdult ? 'Welcome back, Parent!' : 'Hi there, Champ! 🌟',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Balance Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (isAdult) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.work, color: Colors.blue),
                title: const Text('Active Jobs'),
                trailing: Text(
                  '${_getMockJobs().where((j) => j.status == 'open').length}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Jobs Applied'),
                trailing: Text(
                  '${appliedJobs.length}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobsTab(BuildContext context, bool isAdult, WidgetRef ref) {
    final mockJobs = _getMockJobs();
    final appliedJobs = ref.watch(appliedJobsProvider);
    final balance = ref.watch(balanceProvider);
    
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockJobs.length,
        itemBuilder: (context, index) {
          final job = mockJobs[index];
          final hasApplied = appliedJobs.contains(job.id);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Column(
                children: [
                  JobCard(
                    job: job,
                    hasApplied: hasApplied,
                    onTap: () {
                      // Show job details dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(job.title),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job.description),
                              const SizedBox(height: 16),
                              Text('Pay: \$${job.wage}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Posted by: ${job.createdByName}'),
                              Text('Category: ${job.category}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            if (!isAdult && !hasApplied)
                              ElevatedButton(
                                onPressed: () {
                                  // Apply for job
                                  ref.read(appliedJobsProvider.notifier).update(
                                    (state) => [...state, job.id],
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Applied for "${job.title}"!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: const Text('Apply'),
                              ),
                            if (isAdult && job.status == 'in_progress')
                              ElevatedButton(
                                onPressed: () {
                                  // Complete job and pay
                                  ref.read(balanceProvider.notifier).update(
                                    (state) => state - job.wage,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Paid \$${job.wage} for "${job.title}"'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                child: const Text('Mark Complete & Pay'),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (hasApplied)
                    Container(
                      color: Colors.green.withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Applied', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreTab(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final mockStoreItems = _getMockStoreItems();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: mockStoreItems.length,
        itemBuilder: (context, index) {
          final item = mockStoreItems[index];
          final canAfford = balance >= item.price;
          
          return Card(
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(item.name),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.description),
                        const SizedBox(height: 16),
                        Text(
                          'Price: \$${item.price}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (!canAfford)
                          const Text(
                            'Not enough balance!',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: canAfford ? () {
                          // Buy item
                          ref.read(balanceProvider.notifier).update(
                            (state) => state - item.price,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Purchased "${item.name}"!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } : null,
                        child: const Text('Buy'),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          _getItemIcon(item.itemType),
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    const Spacer(),
                    Text(
                      '\$${item.price}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBankTab(BuildContext context, bool isAdult, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big Balance Display
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Current Balance', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Transfer
          if (isAdult)
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Give Allowance'),
                    content: const Text('Transfer \$10 to child?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(balanceProvider.notifier).update(
                            (state) => state - 10,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sent \$10 allowance!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Allowance (\$10)'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getItemIcon(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'reward':
        return Icons.star;
      case 'privilege':
        return Icons.vpn_key;
      case 'experience':
        return Icons.rocket_launch;
      default:
        return Icons.shopping_bag;
    }
  }
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
    ),
  ];
}

List<StoreItem> _getMockStoreItems() {
  return [
    StoreItem(
      id: '1',
      name: 'Extra Screen Time',
      description: '30 minutes of additional screen time',
      price: 10.0,
      category: 'Privileges',
      itemType: 'privilege',
      createdById: 'parent1',
      createdByName: 'Mom',
      familyId: 'family1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}