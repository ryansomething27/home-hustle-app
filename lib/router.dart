import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'frontend/screens/home_screen.dart';
import 'frontend/screens/splash_screen.dart';
// Import other screens as you create them
// import 'frontend/screens/login_screen.dart';
// import 'frontend/screens/job_details_screen.dart';
// import 'frontend/screens/store_screen.dart';

// In router.dart, REPLACE the entire routerProvider with this:
final routerProvider = Provider<GoRouter>((ref) {
  // TEMPORARY: Skip auth for testing
  
  return GoRouter(
    initialLocation: '/home',  // Go straight to home
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // No redirects - let everything through
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      // ... rest of your routes
    ],
    // ... error builder
  );
});

// Navigation extension methods
extension NavigationExtension on BuildContext {
  void navigateToHome() => go('/home');
  void navigateToLogin() => go('/login');
  void navigateToJob(String jobId) => go('/job/$jobId');
  void navigateToStoreItem(String itemId) => go('/store/item/$itemId');
  void navigateToNotifications() => go('/notifications');
  void navigateToProfile() => go('/profile');
  void navigateToSettings() => go('/settings');
}