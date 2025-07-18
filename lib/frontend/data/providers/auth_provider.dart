// frontend/data/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
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
    debugPrint('🔍 AUTH INIT: Starting initialization');
    
    try {
      // Add a small delay to show splash screen
      await Future.delayed(const Duration(seconds: 1));
      
      debugPrint('🔍 AUTH INIT: Checking if logged in...');
      final isLoggedIn = await _authService.isLoggedIn();
      debugPrint('🔍 AUTH INIT: isLoggedIn = $isLoggedIn');
      
      if (isLoggedIn) {
        try {
          debugPrint('🔍 AUTH INIT: Getting current user...');
          final user = await _authService.getCurrentUser();
          debugPrint('🔍 AUTH INIT: Got user: ${user?.email}');
          
          if (user != null) {
            final isFirstTime = await _authService.isFirstTimeUser();
            state = AuthState(
              user: user,
              isFirstTimeUser: isFirstTime,
            );
          } else {
            // Firebase user exists but no local user data
            debugPrint('🔍 AUTH INIT: No local user data, logging out');
            await _authService.logout();
            state = const AuthState();
          }
        } on Exception catch (e) {
          debugPrint('🔍 AUTH INIT: Error getting user data: $e');
          // If we can't get user data, treat as not logged in
          state = const AuthState();
        }
      } else {
        debugPrint('🔍 AUTH INIT: Not logged in');
        state = const AuthState();
      }
      
      debugPrint('🔍 AUTH INIT: Initialization complete. State: isLoading=${state.isLoading}, isAuthenticated=${state.isAuthenticated}');
    } on Exception catch (e) {
      debugPrint('🔍 AUTH INIT ERROR: $e');
      state = AuthState(
        error: e.toString(),
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
      );
    } on Exception catch (e) {
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
      );
    } on Exception catch (e) {
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
      state = const AuthState();
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Refresh user data from backend
  Future<void> refreshUserData() async {
    final currentUser = state.user;
    if (currentUser == null) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true);
      
      // Re-fetch user data from backend
      final user = await _authService.getCurrentUser();
      
      if (user != null) {
        state = state.copyWith(
          user: user,
          isLoading: false,
        );
      } else {
        // If we can't get user data, something is wrong
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to refresh user data',
        );
      }
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.resendVerificationEmail();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedUser = await _authService.updateUserProfile(updates: updates);
      
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await _authService.deleteAccount();
      state = const AuthState();
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Set first time user flag
  Future<void> setFirstTimeUser({required bool isFirstTime}) async {
    await _authService.setFirstTimeUser(isFirstTime: isFirstTime);
    state = state.copyWith(isFirstTimeUser: isFirstTime);
  }
}

// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Convenient provider to get current user
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

// Provider to check if user is adult
final isAdultUserProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdult;
});

// Provider to check if user is child
final isChildUserProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isChild;
});

// Provider to check if email is verified
final isEmailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isEmailVerified;
});

// Provider to check if loading
final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

// Provider to get auth error
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

// Provider to check if first time user
final isFirstTimeUserProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isFirstTimeUser;
});