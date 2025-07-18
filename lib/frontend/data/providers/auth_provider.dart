// frontend/data/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state class
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isFirstTimeUser = true,
  });
  
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isFirstTimeUser;

  bool get isAuthenticated => user != null;
  bool get isAdult => user?.isAdult ?? false;
  bool get isChild => user?.isChild ?? false;
  bool get isEmailVerified => user?.isEmailVerified ?? false;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isFirstTimeUser,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isFirstTimeUser: isFirstTimeUser ?? this.isFirstTimeUser,
    );
  }
}

// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState(isLoading: true)) {
    _initialize();
  }
  
  final AuthService _authService;

  // Initialize auth state (called in constructor)
  Future<void> _initialize() async {
    print('🔍 AUTH INIT: Starting initialization');
    
    try {
      // Add a small delay to show splash screen
      await Future.delayed(const Duration(seconds: 1));
      
      print('🔍 AUTH INIT: Checking if logged in...');
      final isLoggedIn = await _authService.isLoggedIn();
      print('🔍 AUTH INIT: isLoggedIn = $isLoggedIn');
      
      if (isLoggedIn) {
        try {
          print('🔍 AUTH INIT: Getting current user...');
          final user = await _authService.getCurrentUser();
          print('🔍 AUTH INIT: Got user: ${user?.email}');
          
          if (user != null) {
            final isFirstTime = await _authService.isFirstTimeUser();
            state = AuthState(
              user: user,
              isFirstTimeUser: isFirstTime,
              isLoading: false,
            );
          } else {
            // Firebase user exists but no local user data
            print('🔍 AUTH INIT: No local user data, logging out');
            await _authService.logout();
            state = const AuthState(isLoading: false);
          }
        } catch (e) {
          print('🔍 AUTH INIT: Error getting user data: $e');
          // If we can't get user data, treat as not logged in
          state = const AuthState(isLoading: false);
        }
      } else {
        print('🔍 AUTH INIT: Not logged in');
        state = const AuthState(isLoading: false);
      }
      
      print('🔍 AUTH INIT: Initialization complete. State: isLoading=${state.isLoading}, isAuthenticated=${state.isAuthenticated}');
    } catch (e) {
      print('🔍 AUTH INIT ERROR: $e');
      state = AuthState(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // TEMPORARY: Mock login for testing
  Future<void> mockLogin({required bool asAdult}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Create mock user
    final mockUser = UserModel(
      id: 'mock-user-1',
      email: asAdult ? 'parent@test.com' : 'child@test.com',
      firstName: asAdult ? 'Test' : 'Kid',
      lastName: asAdult ? 'Parent' : 'User',
      accountType: asAdult ? 'adult' : 'child',
      isEmailVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    state = AuthState(
      user: mockUser,
      isFirstTimeUser: false,
      isLoading: false,
    );
  }

  // Register new user
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String accountType,
    String? parentInviteCode,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final user = await _authService.registerUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        accountType: accountType,
        parentInviteCode: parentInviteCode,
      );
      
      state = AuthState(
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Login user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final user = await _authService.loginUser(
        email: email,
        password: password,
      );
      
      final isFirstTime = await _authService.isFirstTimeUser();
      
      state = AuthState(
        user: user,
        isFirstTimeUser: isFirstTime,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await _authService.logout();
      state = const AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Other methods remain the same...
  
  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// All the other providers remain the same...