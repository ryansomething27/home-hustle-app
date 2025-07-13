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

  AuthNotifier(this._authService) : super(const AuthState()) {
    _initialize();
  }
  final AuthService _authService;

  // Initialize auth state (called in constructor)
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        final isFirstTime = await _authService.isFirstTimeUser();
        state = AuthState(
          user: user,
          isFirstTimeUser: isFirstTime,
        );
      } else {
        state = const AuthState();
      }
    } on Exception catch (e) {
      state = AuthState(error: e.toString());
    }
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

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedUser = await _authService.updateUserProfile(
        updates: updates,
      );
      
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
    await _authService.resetPassword(email);
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    await _authService.resendVerificationEmail();
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      final isVerified = await _authService.isEmailVerified();
      
      if (isVerified && state.user != null) {
        // Update user's email verification status
        state = state.copyWith(
          user: state.user!.copyWith(isEmailVerified: true),
        );
      }
      
      return isVerified;
    } on Exception {
      return false;
    }
  }

  // Re-authenticate user for sensitive operations
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    await _authService.reauthenticate(
      email: email,
      password: password,
    );
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

  // Set first time user flag
  Future<void> setFirstTimeUser({required bool isFirstTime}) async {
    await _authService.setFirstTimeUser(isFirstTime);
    state = state.copyWith(isFirstTimeUser: isFirstTime);
  }

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

// Convenient providers for specific auth state properties
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isAdultProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdult;
});

final isChildProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isChild;
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isEmailVerified;
});

final isFirstTimeUserProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isFirstTimeUser;
});

final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

// Stream provider for Firebase auth state changes
final authStateChangesProvider = StreamProvider<UserModel?>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  
  await for (final firebaseUser in authService.authStateChanges) {
    if (firebaseUser != null) {
      // Fetch user data when Firebase auth state changes
      final user = await authService.getCurrentUser();
      yield user;
    } else {
      yield null;
    }
  }
});

// Usage Examples:
/*
// In a widget:
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    if (authState.isLoading) {
      return const LoadingIndicator();
    }
    
    if (authState.error != null) {
      // Show error
    }
    
    // Build login UI
  }
  
  void _handleLogin(WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).login(
        email: emailController.text,
        password: passwordController.text,
      );
      // Navigate to home
    } on Exception catch (e) {
      // Handle error
    }
  }
}

// Check if authenticated:
final isAuth = ref.watch(isAuthenticatedProvider);

// Get current user:
final user = ref.watch(currentUserProvider);

// Update first time user status:
await ref.read(authProvider.notifier).setFirstTimeUser(isFirstTime: false);

// Listen to auth state changes:
ref.listen(authStateChangesProvider, (previous, next) {
  next.when(
    data: (user) {
      if (user != null) {
        // User logged in
        router.go('/home');
      } else {
        // User logged out
        router.go('/login');
      }
    },
    loading: () {},
    error: (error, stack) {},
  );
});
*/