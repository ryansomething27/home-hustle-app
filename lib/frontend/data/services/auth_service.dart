import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  
  factory AuthService() => _instance;
  
  AuthService._internal();
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  
  static final AuthService _instance = AuthService._internal();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  String? _userId;
  String? _userRole;
  String? _userEmail;
  
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _userId ?? _auth.currentUser?.uid;
  String? get currentUserRole => _userRole;
  String? get currentUserEmail => _userEmail ?? _auth.currentUser?.email;
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_userIdKey);
    _userRole = prefs.getString(_userRoleKey);
    _userEmail = prefs.getString(_userEmailKey);
    
    // If we have a Firebase user but no cached data, load from Firestore
    if (_auth.currentUser != null && (_userRole == null || _userId == null)) {
      await _loadUserFromFirestore(_auth.currentUser!.uid);
    }
  }
  
  Future<void> _saveUserData({
    required String userId,
    required String role,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userRoleKey, role);
    await prefs.setString(_userEmailKey, email);
    
    _userId = userId;
    _userRole = role;
    _userEmail = email;
  }
  
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userEmailKey);
    
    _userId = null;
    _userRole = null;
    _userEmail = null;
  }
  
  Future<void> _loadUserFromFirestore(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        await _saveUserData(
          userId: userId,
          role: data['role'] ?? 'child',
          email: data['email'] ?? _auth.currentUser?.email ?? '',
        );
      }
    } on Exception catch (_) {
      // Handle error silently
    }
  }
  
  Future<bool> get isAuthenticated async {
    if (_auth.currentUser == null) {
      return false;
    }
    if (_userRole == null) {
      await _loadUserData();
    }
    return _auth.currentUser != null;
  }
  
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return {
          'success': false,
          'message': 'Login failed',
        };
      }
      
      // Check if email is verified
      if (!credential.user!.emailVerified) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Email not verified. Please check your inbox.',
        };
      }
      
      // Load user data from Firestore
      await _loadUserFromFirestore(credential.user!.uid);
      
      return {
        'success': true,
        'userId': credential.user!.uid,
        'role': _userRole,
        'message': 'Login successful',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Invalid password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later';
          break;
      }
      return {
        'success': false,
        'message': message,
      };
    } on Exception catch (_) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  Future<Map<String, dynamic>> registerUser(
    String email,
    String password,
    String role, {
    String? parentId,
    String? name,
  }) async {
    try {
      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return {
          'success': false,
          'message': 'Registration failed',
        };
      }
      
      // Create user document in Firestore
      final userDoc = {
        'email': email,
        'role': role.toLowerCase(),
        'name': name ?? email.split('@')[0],
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
        'stars': 0,
      };
      
      // Add parent ID if this is a child account
      if (parentId != null && role.toLowerCase() == 'child') {
        userDoc['parentId'] = parentId;
        
        // Get parent's family ID
        final parentDoc = await _db.collection('users').doc(parentId).get();
        if (parentDoc.exists) {
          userDoc['familyId'] = parentDoc.data()?['familyId'] ?? parentId;
        }
      } else if (role.toLowerCase() == 'parent') {
        // Create family ID for parent
        userDoc['familyId'] = credential.user!.uid;
      }
      
      await _db.collection('users').doc(credential.user!.uid).set(userDoc);
      
      // Send verification email
      await credential.user!.sendEmailVerification();
      
      // Save user data locally
      await _saveUserData(
        userId: credential.user!.uid,
        role: role.toLowerCase(),
        email: email,
      );
      
      return {
        'success': true,
        'userId': credential.user!.uid,
        'role': role.toLowerCase(),
        'verificationEmailSent': true,
        'message': 'Registration successful. Please check your email to verify your account.',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
      }
      return {
        'success': false,
        'message': message,
      };
    } on Exception catch (_) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  Future<Map<String, dynamic>> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }
      
      if (user.emailVerified) {
        return {
          'success': false,
          'message': 'Email already verified',
        };
      }
      
      await user.sendEmailVerification();
      
      return {
        'success': true,
        'message': 'Verification email sent. Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        return {
          'success': false,
          'message': 'Too many requests. Please wait before trying again.',
        };
      }
      return {
        'success': false,
        'message': 'Failed to send verification email',
      };
    } on Exception catch (_) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      // Firebase doesn't support resending verification to arbitrary email
      // User must be logged in to resend verification
      if (_auth.currentUser == null || _auth.currentUser!.email != email) {
        return {
          'success': false,
          'message': 'Please login to resend verification email',
        };
      }
      
      return await sendVerificationEmail();
    } on Exception catch (_) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  Future<Map<String, dynamic>> inviteFamily({
    required String email,
    required String role,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || _userRole != 'parent') {
        return {
          'success': false,
          'message': 'Not authorized to send invitations',
        };
      }
      
      // Check if email already exists
      final existingUsers = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (existingUsers.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'This email is already registered',
        };
      }
      
      // Create invitation in Firestore
      final invitation = await _db.collection('invitations').add({
        'parentId': user.uid,
        'parentEmail': user.email,
        'invitedEmail': email,
        'role': role.toLowerCase(),
        'familyId': _userId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      
      // In a production app, you'd send an email here
      // For now, return the invitation ID as a "link"
      final inviteLink = 'homehustle://invite/${invitation.id}';
      
      return {
        'success': true,
        'inviteLink': inviteLink,
        'message': 'Invitation created successfully',
      };
    } on Exception catch (_) {
      return {
        'success': false,
        'message': 'Failed to create invitation',
      };
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
    await _clearUserData();
  }
  
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user session to refresh',
        };
      }
      
      // Firebase handles token refresh automatically
      // Just reload user data
      await user.reload();
      await _loadUserFromFirestore(user.uid);
      
      return {
        'success': true,
        'userId': user.uid,
      };
    } on Exception catch (_) {
      return {
        'success': false,
        'message': 'Failed to refresh session',
      };
    }
  }
  
  Future<Map<String, dynamic>> checkAuthStatus() async {
    await _loadUserData();
    
    final user = _auth.currentUser;
    if (user != null && _userRole != null) {
      return {
        'isAuthenticated': true,
        'userId': user.uid,
        'role': _userRole,
        'email': user.email,
        'emailVerified': user.emailVerified,
      };
    } else {
      return {
        'isAuthenticated': false,
      };
    }
  }
  
  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Method to update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      
      // Update Firestore
      final updates = <String, dynamic>{};
      if (displayName != null) {
        updates['name'] = displayName;
      }
      if (photoURL != null) {
        updates['photoURL'] = photoURL;
      }
      
      if (updates.isNotEmpty) {
        await _db.collection('users').doc(user.uid).update(updates);
      }
    }
  }
}