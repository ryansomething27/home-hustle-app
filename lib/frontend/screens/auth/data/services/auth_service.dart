import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();
  
  static const String _isFirstTimeKey = 'isFirstTime';
  
  // Get current Firebase user
  fb_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;
  
  // Stream of auth state changes
  Stream<fb_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return currentFirebaseUser != null;
  }
  
  // Get current user data from secure storage
  Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(key: kUserDataKey);
      if (userJson != null) {
        return UserModel.fromJson(userJson);
      }
      return null;
    } on Exception catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  // Register new user (Adult or Child)
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String accountType, // 'adult' or 'child'
    String? parentInviteCode, // For children joining a family
  }) async {
    try {
      // Create Firebase user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Failed to create Firebase user');
      }
      
      // Get Firebase ID token
      final idToken = await credential.user!.getIdToken();
      
      // Register user in backend
      final response = await _apiService.post(
        '/auth/registerUser',
        data: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'accountType': accountType,
          'firebaseUid': credential.user!.uid,
          'parentInviteCode': parentInviteCode,
        },
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      
      // Parse user data
      final user = UserModel.fromJson(response.data['user']);
      
      // Save user data to secure storage
      await _saveUserData(user);
      
      // Send email verification
      await credential.user!.sendEmailVerification();
      
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } on Exception catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  // Login user
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Failed to sign in');
      }
      
      // Get Firebase ID token
      final idToken = await credential.user!.getIdToken();
      
      // Get user data from backend
      final response = await _apiService.post(
        '/auth/loginUser',
        data: {
          'firebaseUid': credential.user!.uid,
        },
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      
      // Parse user data
      final user = UserModel.fromJson(response.data['user']);
      
      // Save user data to secure storage
      await _saveUserData(user);
      
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } on Exception catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Clear stored user data
      await _secureStorage.delete(key: kUserDataKey);
      
      // Clear any other stored preferences if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isFirstTimeKey);
    } on Exception catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
  
  // Update user profile
  Future<UserModel> updateUserProfile({
    required Map<String, dynamic> updates,
  }) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }
      
      // Get Firebase ID token
      final idToken = await user.getIdToken();
      
      // Update user in backend
      final response = await _apiService.put(
        '/auth/updateUser',
        data: updates,
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      
      // Parse updated user data
      final updatedUser = UserModel.fromJson(response.data['user']);
      
      // Save updated user data
      await _saveUserData(updatedUser);
      
      return updatedUser;
    } on Exception catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } on Exception catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
  
  // Verify email
  Future<bool> isEmailVerified() async {
    final user = currentFirebaseUser;
    if (user == null) {
      return false;
    }
    
    // Reload user to get latest email verification status
    await user.reload();
    return user.emailVerified;
  }
  
  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }
      
      await user.sendEmailVerification();
    } on Exception catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }
  
  // Get Firebase ID token
  Future<String?> getIdToken() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        return null;
      }
      
      return await user.getIdToken();
    } on Exception catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }
  
  // Refresh user token
  Future<String?> refreshToken() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        return null;
      }
      
      return await user.getIdToken(true); // Force refresh
    } on Exception catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }
  
  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }
      
      // Get Firebase ID token
      final idToken = await user.getIdToken();
      
      // Delete user from backend first
      await _apiService.delete(
        '/auth/deleteUser',
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      
      // Delete Firebase user
      await user.delete();
      
      // Clear stored data
      await _secureStorage.delete(key: kUserDataKey);
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Please re-authenticate before deleting your account');
      }
      throw _handleFirebaseAuthError(e);
    } on Exception catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }
  
  // Re-authenticate user (for sensitive operations)
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }
      
      final credential = fb_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } on Exception catch (e) {
      throw Exception('Re-authentication failed: $e');
    }
  }
  
  // Check if this is first time user
  Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }
  
  // Set first time user flag
  Future<void> setFirstTimeUser(bool isFirstTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, isFirstTime);
  }
  
  // Private helper methods
  Future<void> _saveUserData(UserModel user) async {
    await _secureStorage.write(
      key: kUserDataKey,
      value: user.toJson(),
    );
  }
  
  String _handleFirebaseAuthError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}