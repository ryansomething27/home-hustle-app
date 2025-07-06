import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://api.homehustle.com';
  static const String _tokenKey = 'auth_token';
  static const Duration _timeout = Duration(seconds: 30);
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late final Dio _dio;
  String? _authToken;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }
  
  Future<void> initialize() async {
    await _loadToken();
  }
  
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    if (_authToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_authToken';
    }
  }
  
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }
  
  // Auth methods required by auth_provider.dart
  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _saveToken(token);
  }
  
  void clearAuthToken() {
    _clearToken();
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      // Save token if returned
      if (response.data['token'] != null) {
        await _saveToken(response.data['token']);
      }
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? parentId,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          if (parentId != null) 'parentId': parentId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$userId/profile',
        data: updates,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateUserSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$userId/settings',
        data: settings,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> sendVerificationEmail(String userId) async {
    try {
      await _dio.post('/auth/send-verification', data: {
        'userId': userId,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> inviteFamilyMember({
    required String parentId,
    required String email,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/invite',
        data: {
          'parentId': parentId,
          'email': email,
          'role': role,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // Generic HTTP methods
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.delete(endpoint, queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> uploadFile(String endpoint, String filePath, {Map<String, String>? fields}) async {
    try {
      final formData = FormData();
      
      if (fields != null) {
        fields.forEach((key, value) {
          formData.fields.add(MapEntry(key, value));
        });
      }
      
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(filePath),
      ));
      
      final response = await _dio.post(endpoint, data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  ApiException _handleError(DioException e) {
    String message;
    int? statusCode;
    dynamic body;
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Request timed out. Please try again.';
        break;
      case DioExceptionType.connectionError:
        message = 'Network error. Please check your connection.';
        break;
      case DioExceptionType.badResponse:
        statusCode = e.response?.statusCode;
        body = e.response?.data;
        message = _extractErrorMessage(body, statusCode ?? 0);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      default:
        message = 'An unexpected error occurred.';
    }
    
    return ApiException(
      message: message,
      statusCode: statusCode,
      body: body,
    );
  }
  
  String _extractErrorMessage(dynamic body, int statusCode) {
    if (body == null) {
      return _getDefaultErrorMessage(statusCode);
    }
    
    if (body is Map) {
      return body['errorMessage'] ?? 
             body['message'] ?? 
             body['error'] ?? 
             _getDefaultErrorMessage(statusCode);
    }
    
    return _getDefaultErrorMessage(statusCode);
  }
  
  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 409:
        return 'Conflict';
      case 429:
        return 'Too many requests';
      case 500:
        return 'Internal server error';
      case 503:
        return 'Service unavailable';
      default:
        return 'Request failed with status code $statusCode';
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic body;
  
  ApiException({
    required this.message,
    this.statusCode,
    this.body,
  });
  
  @override
  String toString() => message;
}