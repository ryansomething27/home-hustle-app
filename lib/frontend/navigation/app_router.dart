import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/verification_screen.dart';
import '../screens/parent_dashboard/parent_home_screen.dart';
import '../screens/parent_dashboard/create_job_screen.dart';
import '../screens/parent_dashboard/manage_jobs_screen.dart';
import '../screens/parent_dashboard/family_store_screen.dart';
import '../screens/parent_dashboard/bank_screen.dart' as parent_bank;
import '../screens/child_dashboard/child_home_screen.dart';
import '../screens/child_dashboard/my_jobs_screen.dart';
import '../screens/child_dashboard/resume_screen.dart';
import '../screens/child_dashboard/bank_screen.dart' as child_bank;
import '../screens/child_dashboard/family_store_screen.dart' as child_store;
import '../screens/employer_dashboard/employer_home_screen.dart';
import '../screens/employer_dashboard/post_job_screen.dart';
import '../screens/employer_dashboard/manage_applicants_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/account_settings_screen.dart';
import '../widgets/loading_indicator.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authState,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final user = authState.user;
      final isAuthRoute = Routes.isAuthRoute(state.matchedLocation);
      final isPublicRoute = Routes.isPublicRoute(state.matchedLocation);
      
      // Splash screen logic
      if (state.matchedLocation == Routes.splash) {
        if (authState.isLoading) {
          return null; // Stay on splash
        }
        if (isAuthenticated && user != null) {
          return Routes.getHomeRouteForRole(user.role);
        }
        return Routes.login;
      }
      
      // Not authenticated and trying to access protected route
      if (!isAuthenticated && !isPublicRoute) {
        return Routes.login;
      }
      
      // Authenticated but on auth route
      if (isAuthenticated && isAuthRoute && user != null) {
        return Routes.getHomeRouteForRole(user.role);
      }
      
      // Role-based access control
      if (isAuthenticated && user != null) {
        final location = state.matchedLocation;
        
        // Check parent-only routes
        if (Routes.isParentRoute(location) && user.role.toUpperCase() != 'PARENT') {
          return Routes.getHomeRouteForRole(user.role);
        }
        
        // Check child-only routes
        if (Routes.isChildRoute(location) && user.role.toUpperCase() != 'CHILD') {
          return Routes.getHomeRouteForRole(user.role);
        }
        
        // Check employer-only routes
        if (Routes.isEmployerRoute(location) && user.role.toUpperCase() != 'EMPLOYER') {
          return Routes.getHomeRouteForRole(user.role);
        }
      }
      
      return null; // No redirect needed
    },
    errorBuilder: (context, state) => _ErrorPage(error: state.error.toString()),
    routes: [
      // Splash Route
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.verification,
        builder: (context, state) => const VerificationScreen(),
      ),
      
      // Parent Routes
      GoRoute(
        path: Routes.parentHome,
        builder: (context, state) => const ParentHomeScreen(),
        routes: [
          GoRoute(
            path: 'jobs',
            builder: (context, state) => const ManageJobsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateJobScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'bank',
            builder: (context, state) => const parent_bank.BankScreen(),
          ),
          GoRoute(
            path: 'store',
            builder: (context, state) => const FamilyStoreScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      
      // Child Routes
      GoRoute(
        path: Routes.childHome,
        builder: (context, state) => const ChildHomeScreen(),
        routes: [
          GoRoute(
            path: 'jobs',
            builder: (context, state) => const MyJobsScreen(),
          ),
          GoRoute(
            path: 'bank',
            builder: (context, state) => const child_bank.BankScreen(),
          ),
          GoRoute(
            path: 'store',
            builder: (context, state) => const child_store.FamilyStoreScreen(),
          ),
          GoRoute(
            path: 'resume',
            builder: (context, state) => const ResumeScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      
      // Employer Routes
      GoRoute(
        path: Routes.employerHome,
        builder: (context, state) => const EmployerHomeScreen(),
        routes: [
          GoRoute(
            path: 'post-job',
            builder: (context, state) => const PostJobScreen(),
          ),
          GoRoute(
            path: 'applicants',
            builder: (context, state) => const ManageApplicantsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      
      // Common Settings Routes
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'account',
            builder: (context, state) => const AccountSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

// Splash Screen Widget
class SplashScreen extends ConsumerWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2332),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Title
            Text(
              'HOME\nHUSTLE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFF5F0E6),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 48),
            const LoadingIndicator(
              color: Color(0xFFF5F0E6),
            ),
          ],
        ),
      ),
    );
  }
}

// Error Page Widget
class _ErrorPage extends StatelessWidget {
  final String error;
  
  const _ErrorPage({
    Key? key,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2332),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFF5F0E6),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  color: const Color(0xFFF5F0E6),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFF5F0E6).withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.go(Routes.splash);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F0E6),
                  foregroundColor: const Color(0xFF1A2332),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Go Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Navigation Shell for Bottom Navigation
class NavigationShell extends ConsumerStatefulWidget {
  final Widget child;
  final String location;
  
  const NavigationShell({
    Key? key,
    required this.child,
    required this.location,
  }) : super(key: key);

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(NavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    
    final role = user.role.toUpperCase();
    final location = widget.location;
    
    setState(() {
      if (role == 'PARENT') {
        if (location.contains('jobs')) {
          _selectedIndex = 0;
        } else if (location.contains('bank')) {
          _selectedIndex = 1;
        } else if (location.contains('store')) {
          _selectedIndex = 2;
        } else {
          _selectedIndex = 0;
        }
      } else if (role == 'CHILD') {
        if (location.contains('jobs')) {
          _selectedIndex = 0;
        } else if (location.contains('bank')) {
          _selectedIndex = 1;
        } else if (location.contains('store')) {
          _selectedIndex = 2;
        } else {
          _selectedIndex = 0;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return widget.child;
    
    final role = user.role.toUpperCase();
    
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: role != 'EMPLOYER' ? Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2332),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildBottomNavItems(role),
            ),
          ),
        ),
      ) : null,
    );
  }

  List<Widget> _buildBottomNavItems(String role) {
    if (role == 'PARENT') {
      return [
        _buildNavItem(Icons.home, 'Home', 0, Routes.parentHome),
        _buildNavItem(Icons.work, 'Jobs', 1, Routes.parentJobs),
        _buildNavItem(Icons.account_balance, 'Bank', 2, Routes.parentBank),
      ];
    } else if (role == 'CHILD') {
      return [
        _buildNavItem(Icons.home, 'Home', 0, Routes.childHome),
        _buildNavItem(Icons.work, 'Jobs', 1, Routes.childJobs),
        _buildNavItem(Icons.account_balance, 'Bank', 2, Routes.childBank),
      ];
    }
    return [];
  }

  Widget _buildNavItem(IconData icon, String label, int index, String route) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        context.go(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFF5F0E6) : const Color(0xFFF5F0E6).withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFF5F0E6) : const Color(0xFFF5F0E6).withOpacity(0.5),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Page Transitions
CustomTransitionPage<void> _buildPageWithDefaultTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}