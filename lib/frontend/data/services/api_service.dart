import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants.dart';

class ApiService {
  
  // Singleton pattern
  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: kApiTimeout,
        receiveTimeout: kApiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ));
    }
  }
  late final Dio _dio;
  static ApiService? _instance;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // Upload file
  Future<Response> uploadFile(
    String path, {
    required File file,
    String fileFieldName = 'file',
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fileFieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // Download file
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}

// Auth Interceptor to add Firebase token to requests
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for certain endpoints
    final skipAuthEndpoints = [
      '/auth/registerUser',
      '/auth/loginUser',
      '/health',
    ];

    final shouldSkipAuth = skipAuthEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!shouldSkipAuth) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
      } on Exception catch (e) {
        debugPrint('Error getting Firebase token: $e');
      }
    }

    handler.next(options);
  }
}

// Error Interceptor to handle common errors
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    var message = kGenericErrorMessage;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      message = 'Connection timeout. Please try again.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = kNetworkErrorMessage;
    } else if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;

      // Try to get error message from response
      if (responseData is Map && responseData.containsKey('message')) {
        message = responseData['message'];
      } else {
        switch (statusCode) {
          case 400:
            message = 'Bad request. Please check your input.';
            break;
          case 401:
            message = kAuthErrorMessage;
            break;
          case 403:
            message = kPermissionDeniedMessage;
            break;
          case 404:
            message = kNotFoundErrorMessage;
            break;
          case 422:
            message = 'Validation error. Please check your input.';
            break;
          case 429:
            message = 'Too many requests. Please try again later.';
            break;
          case 500:
            message = 'Server error. Please try again later.';
            break;
          case 503:
            message = 'Service unavailable. Please try again later.';
            break;
          default:
            message = 'Error $statusCode: ${error.response!.statusMessage}';
        }
      }
    }

    // Create a custom error with user-friendly message
    final customError = DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: message,
    );

    // Log error in debug mode
    if (kDebugMode) {
      debugPrint('API Error: $message');
      debugPrint('Error details: ${error.toString()}');
    }

    handler.next(customError);
  }
}

// Custom exception class for API errors
class ApiException implements Exception {

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });
  final String message;
  final int? statusCode;
  final dynamic data;

  @override
  String toString() => message;
}