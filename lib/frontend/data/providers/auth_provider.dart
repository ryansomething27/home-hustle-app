import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';

// Define UserRole enum
enum UserRole { parent, child, employer }

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Auth State
class AuthState {

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });
  final User? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {

  AuthNotifier() : super(AuthState()) {
    _initialize();
  }
  final ApiService _apiService = ApiService();

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiService.initialize();
      // Check if user is already logged in
      // This would be implemented based on your token validation logic
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.login(email, password);
      
      // Parse user from response
      final userData = response['user'] ?? {};
      final token = response['token'];
      
      if (token != null) {
        _apiService.setAuthToken(token);
      }
      
      final user = User.fromJson(userData);
      state = state.copyWith(user: user, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? parentId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiService.register(
        email: email,
        password: password,
        name: name,
        role: role,
        parentId: parentId,
      );
      
      // After registration, you might want to auto-login or verify email
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      _apiService.clearAuthToken();
      state = AuthState(); // Reset to initial state
    } on Exception catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updateProfile({
    required String name,
    String? profileImageUrl,
  }) async {
    final currentUser = state.user;
    if (currentUser == null) {
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updates = <String, dynamic>{
        'name': name,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      };
      
      await _apiService.updateProfile(
        userId: currentUser.userId,
        updates: updates,
      );
      
      // Update local user
      final updatedUser = currentUser.copyWith(name: name);
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    final currentUser = state.user;
    if (currentUser == null) {
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiService.updateUserSettings(
        userId: currentUser.userId,
        settings: settings,
      );
      
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> sendVerificationEmail() async {
    final currentUser = state.user;
    if (currentUser == null) {
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiService.sendVerificationEmail(currentUser.userId);
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> inviteFamilyMember({
    required String email,
    required String role,
  }) async {
    final currentUser = state.user;
    if (currentUser == null || currentUser.role != 'parent') {
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiService.inviteFamilyMember(
        parentId: currentUser.userId,
        email: email,
        role: role,
      );
      
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    final currentUser = state.user;
    if (currentUser == null) {
      return;
    }
    
    try {
      final response = await _apiService.getUser(currentUser.userId);
      final user = User.fromJson(response);
      state = state.copyWith(user: user);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}