import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

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

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService = ApiService();

  AuthNotifier() : super(AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiService.initialize();
      // Check if user is already logged in
      // This would be implemented based on your token validation logic
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
    if (currentUser == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updates = <String, dynamic>{
        'name': name,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      };
      
      await _apiService.updateProfile(
        userId: currentUser.id,
        updates: updates,
      );
      
      // Update local user
      final updatedUser = currentUser.copyWith(name: name);
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    final currentUser = state.user;
    if (currentUser == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiService.updateUserSettings(
        userId: currentUser.id,
        settings: settings,
      );
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> sendVerificationEmail() async {
    final currentUser = state.user;
    if (currentUser == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiService.sendVerificationEmail(currentUser.id);
      state = state.copyWith(isLoading: false);
    } catch (e) {
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
    if (currentUser == null || currentUser.role != UserRole.parent) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _apiService.inviteFamilyMember(
        parentId: currentUser.id,
        email: email,
        role: role,
      );
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    final currentUser = state.user;
    if (currentUser == null) return;
    
    try {
      final response = await _apiService.getUser(currentUser.id);
      final user = User.fromJson(response);
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}