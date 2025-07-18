import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'frontend/core/theme.dart';
import 'router.dart';

// Global instances
late SharedPreferences sharedPreferences;
late FlutterSecureStorage secureStorage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize storage
  sharedPreferences = await SharedPreferences.getInstance();
  secureStorage = const FlutterSecureStorage();
  
  runApp(
    const ProviderScope(
      child: HomeHustleApp(),
    ),
  );
}

class HomeHustleApp extends ConsumerWidget {
  const HomeHustleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Home Hustle',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}