import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../frontend/data/core/constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  String? _authToken;
  String? _userId;
  String? _userRole;
  String? _userEmail;
  
  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    _userId = prefs.getString(_userIdKey);
    _userRole = prefs.getString(_userRoleKey);
    _userEmail = prefs.getString(_userEmailKey);
  }
  
  Future<void> _saveAuthData({
    required String token,
    required String userId,
    required String role,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userRoleKey, role);
    await prefs.setString(_userEmailKey, email);
    
    _authToken = token;
    _userId = userId;
    _userRole = role;
    _userEmail = email;
  }
  
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userEmailKey);
    
    _authToken = null;
    _userId = null;
    _userRole = null;
    _userEmail = null;
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };
  
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };
  
  String? get currentToken => _authToken;
  String? get currentUserId => _userId;
  String? get currentUserRole => _userRole;
  String? get currentUserEmail => _userEmail;
  
  Future<bool> get isAuthenticated async {
    if (_authToken == null) {
      await _loadAuthData();
    }
    return _authToken != null;
  }
  
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/auth/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        await _saveAuthData(
          token: data['token'],
          userId: data['userId'],
          role: data['role'],
          email: email,
        );
        
        return {
          'success': true,
          'userId': data['userId'],
          'role': data['role'],
          'message': 'Login successful',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Email not verified. Please check your inbox.',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['errorMessage'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  Future<Map<String, dynamic>> registerUser(String email, String password, String role, {String? parentId}) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/auth/register'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
          'role': role.toUpperCase(),
          if (parentId != null) 'parentId': parentId,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        return {
          'success': true,
          'userId': data['userId'],
          'role': data['role'],
          'verificationEmailSent': data['verificationEmailSent'] ?? true,
          'message': 'Registration successful. Please check your email to verify your account.',
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'An account with this email already exists',
        };
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['errorMessage'] ?? 'Invalid registration details',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['errorMessage'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  Future<Map<String, dynamic>> sendVerificationEmail() async {
    try {
      if (_authToken == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }
      
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/auth/send-verification'),
        headers: _authHeaders,
        body: json.encode({
          'userId': _userId,
        }),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Verification email sent. Please check your inbox.',
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'message': 'Too many requests. Please wait before trying again.',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['errorMessage'] ?? 'Failed to send verification email',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/auth/resend-verification'),
        headers: _headers,
        body: json.encode({
          'email': email,
        }),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Verification email sent. Please check your inbox.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'No account found with this email address',
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'message': 'Too many requests. Please wait before trying again.',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['errorMessage'] ?? 'Failed to send verification email',
        };
      }
    } catch (e) {
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
      if (_authToken == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }
      
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/auth/invite'),
        headers: _authHeaders,
        body: json.encode({
          'parentId': _userId,
          'email': email,
          'role': role.toUpperCase(),
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'inviteLink': data['inviteLink'],
          'message': 'Invitation sent successfully',
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'This email is already registered',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['errorMessage'] ?? 'Failed to send invitation',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  Future<void> signOut() async {
    await _clearAuthData();
  }
  
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      if (_authToken == null) {
        return {
          'success': false,
          'message': 'No token to refresh',
        };
      }
      
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/auth/refresh'),
        headers: _authHeaders,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        await _saveAuthData(
          token: data['token'],
          userId: _userId!,
          role: _userRole!,
          email: _userEmail!,
        );
        
        return {
          'success': true,
          'token': data['token'],
        };
      } else {
        await _clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
  
  Future<Map<String, dynamic>> checkAuthStatus() async {
    await _loadAuthData();
    
    if (_authToken != null && _userId != null && _userRole != null) {
      return {
        'isAuthenticated': true,
        'userId': _userId,
        'role': _userRole,
        'email': _userEmail,
      };
    } else {
      return {
        'isAuthenticated': false,
      };
    }
  }
}