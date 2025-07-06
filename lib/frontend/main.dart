import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'navigation/app_router.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF1A2332),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const HomeHustleApp(),
    ),
  );
}

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// NotificationService provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError();
});

class HomeHustleApp extends ConsumerWidget {
  const HomeHustleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Home Hustle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Always use dark theme to match design
      routerConfig: router,
      builder: (context, child) {
        // Apply global text scale factor
        final mediaQuery = MediaQuery.of(context);
        final scale = mediaQuery.textScaleFactor.clamp(0.8, 1.2);
        
        return MediaQuery(
          data: mediaQuery.copyWith(textScaleFactor: scale),
          child: child!,
        );
      },
    );
  }
}

// Global error widget
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  
  const ErrorBoundary({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
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
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    color: Color(0xFFF5F0E6),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  details.exception.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFF5F0E6).withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // In a real app, you might want to restart or navigate home
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
                    'Try Again',
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
    };
    
    return child;
  }
}

// App lifecycle observer
class AppLifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef ref;
  
  AppLifecycleObserver(this.ref);
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        // App is in background
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        break;
    }
  }
  
  void _onAppResumed() {
    // Refresh data when app comes to foreground
    // You can trigger providers to refresh here
  }
  
  void _onAppPaused() {
    // Save any pending data when app goes to background
  }
}

// Initialize app services
class AppInitializer {
  static Future<void> initialize() async {
    try {
      // Add any additional initialization here
      // For example: analytics, crash reporting, etc.
    } catch (e) {
      debugPrint('Error during app initialization: $e');
    }
  }
}