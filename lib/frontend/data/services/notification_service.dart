import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart'; // For Color and debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/notification.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Handles push notifications via Firebase Cloud Messaging and local notifications
class NotificationService {
  NotificationService._internal() {
    _firebaseMessaging = FirebaseMessaging.instance;
    _localNotifications = FlutterLocalNotificationsPlugin();
  }
  
  // Notification constants (to be added to constants.dart)
  static const String defaultNotificationChannel = 'high_importance_channel';
  static const String defaultNotificationIcon = 'ic_notification';
  static const Color defaultNotificationColor = kPrimaryColor;
  
  // Storage keys
  static const String _fcmTokenKey = 'fcmToken';
  static const String _notificationPermissionKey = 'notificationPermission';
  
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  late final FirebaseMessaging _firebaseMessaging;
  late final FlutterLocalNotificationsPlugin _localNotifications;
  
  /// Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  
  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Request notification permissions
      await _requestPermissions();
      
      // Configure FCM
      await _configureFCM();
      
      // Get and save FCM token
      final token = await getToken();
      if (token != null) {
        await _saveTokenToBackend(token);
      }
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_saveTokenToBackend);
      
      debugPrint('NotificationService initialized successfully');
    } on Exception catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      rethrow;
    }
  }
  
  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(defaultNotificationIcon);
    
    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // Initialize the plugin
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }
  }
  
  /// Create Android notification channel
  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      defaultNotificationChannel,
      'Home Hustle Notifications',
      description: 'Important notifications from Home Hustle',
      importance: Importance.high,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    try {
      // Request FCM permissions - all default values
      final fcmSettings = await _firebaseMessaging.requestPermission();
      
      // Check if granted
      final fcmGranted = fcmSettings.authorizationStatus == AuthorizationStatus.authorized;
      
      // For Android 13+, also request notification permission
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        final androidGranted = status.isGranted;
        
        // Save permission status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_notificationPermissionKey, fcmGranted && androidGranted);
        
        return fcmGranted && androidGranted;
      }
      
      // Save permission status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationPermissionKey, fcmGranted);
      
      return fcmGranted;
    } on Exception catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }
  
  /// Configure FCM message handling
  Future<void> _configureFCM() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
    
    // Check if app was opened from a notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }
    
    // Set foreground notification presentation options for iOS
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  
  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.messageId}');
    
    // Show local notification
    await showLocalNotification(
      title: message.notification?.title ?? 'Home Hustle',
      body: message.notification?.body ?? 'You have a new notification',
      payload: message.data,
    );
    
    // Save to notification history
    await _saveNotificationToHistory(message);
  }
  
  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped with payload: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!) as Map<String, dynamic>;
        _handleNotificationNavigation(data);
      } on FormatException catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }
  
  /// Handle notification open from FCM
  void _handleNotificationOpen(RemoteMessage message) {
    debugPrint('Notification opened: ${message.messageId}');
    _handleNotificationNavigation(message.data);
  }
  
  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // This will be implemented based on your navigation setup
    // For now, just log the action
    final action = data['action'] as String?;
    final targetId = data['targetId'] as String?;
    
    debugPrint('Navigate to: $action with targetId: $targetId');
    
    // TODO(Ryan): Implement navigation based on action type
    // Examples:
    // - action: 'job_assigned' → Navigate to job details
    // - action: 'payment_received' → Navigate to transaction details
    // - action: 'new_application' → Navigate to applications
  }
  
  /// Get FCM token
  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      
      if (token != null) {
        // Save token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_fcmTokenKey, token);
      }
      
      return token;
    } on Exception catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
  
  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      
      // Remove from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmTokenKey);
      
      // Remove from backend
      await _removeTokenFromBackend();
    } on Exception catch (e) {
      debugPrint('Error deleting FCM token: $e');
      rethrow;
    }
  }
  
  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } on Exception catch (e) {
      debugPrint('Error subscribing to topic: $e');
      rethrow;
    }
  }
  
  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } on Exception catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
      rethrow;
    }
  }
  
  /// Send notification via API
  Future<void> sendNotification({
    required String title,
    required String body,
    required String recipientId,
    String? type,
    String? actionType,
    Map<String, dynamic>? actionData,
    String? imageUrl,
    String priority = 'normal',
  }) async {
    try {
      await _apiService.post(
        '/notifications/send',
        data: {
          'title': title,
          'body': body,
          'recipientId': recipientId,
          'type': type,
          'actionType': actionType,
          'actionData': actionData,
          'imageUrl': imageUrl,
          'priority': priority,
        },
      );
    } on Exception catch (e) {
      debugPrint('Error sending notification: $e');
      rethrow;
    }
  }
  
  /// Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    String? imageUrl,
    bool playSound = true,
    bool vibrate = true,
  }) async {
    try {
      // Android notification details
      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        defaultNotificationChannel,
        'Home Hustle Notifications',
        channelDescription: 'Important notifications from Home Hustle',
        importance: Importance.high,
        priority: Priority.high,
        playSound: playSound,
        enableVibration: vibrate,
        color: defaultNotificationColor,
        icon: defaultNotificationIcon,
        styleInformation: imageUrl != null
            ? const BigPictureStyleInformation(
                DrawableResourceAndroidBitmap(defaultNotificationIcon),
                largeIcon: DrawableResourceAndroidBitmap(defaultNotificationIcon),
              )
            : null,
      );
      
      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      // Combined notification details
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Show the notification
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000), // Unique ID
        title,
        body,
        details,
        payload: payload != null ? json.encode(payload) : null,
      );
    } on Exception catch (e) {
      debugPrint('Error showing local notification: $e');
      rethrow;
    }
  }
  
  /// Fetch notification history
  Future<List<NotificationModel>> fetchNotificationHistory({
    int page = 1,
    int limit = 20,
    String? type,
    bool unreadOnly = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (type != null) {
        queryParams['type'] = type;
      }
      if (unreadOnly) {
        queryParams['unreadOnly'] = true;
      }
      
      final response = await _apiService.get(
        '/notifications/history',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['notifications'] as List)
          .map((notification) => NotificationModel.fromMap(notification))
          .toList();
    } on Exception catch (e) {
      debugPrint('Error fetching notification history: $e');
      rethrow;
    }
  }
  
  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put('/notifications/$notificationId/read');
    } on Exception catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiService.put('/notifications/read-all');
    } on Exception catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }
  
  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiService.delete('/notifications/$notificationId');
    } on Exception catch (e) {
      debugPrint('Error deleting notification: $e');
      rethrow;
    }
  }
  
  /// Get notification preferences
  Future<NotificationPreferences> getNotificationPreferences() async {
    try {
      final response = await _apiService.get('/notifications/preferences');
      
      final responseData = response.data as Map<String, dynamic>;
      return NotificationPreferences.fromMap(responseData['preferences']);
    } on Exception catch (e) {
      debugPrint('Error getting notification preferences: $e');
      // Return default preferences on error
      return NotificationPreferences();
    }
  }
  
  /// Update notification preferences
  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final response = await _apiService.put(
        '/notifications/preferences',
        data: preferences.toMap(),
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return NotificationPreferences.fromMap(responseData['preferences']);
    } on Exception catch (e) {
      debugPrint('Error updating notification preferences: $e');
      rethrow;
    }
  }
  
  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/notifications/unread-count');
      
      final responseData = response.data as Map<String, dynamic>;
      return responseData['count'] as int;
    } on Exception catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }
  
  /// Schedule local notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        defaultNotificationChannel,
        'Home Hustle Notifications',
        channelDescription: 'Important notifications from Home Hustle',
        importance: Importance.high,
        priority: Priority.high,
        color: defaultNotificationColor,
        icon: defaultNotificationIcon,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // For now, we'll use a simple delay-based scheduling
      // In production, you'd want to use timezone-aware scheduling
      final delay = scheduledDate.difference(DateTime.now());
      
      if (delay.isNegative) {
        throw Exception('Scheduled date must be in the future');
      }
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: payload != null ? json.encode(payload) : null,
      );
    } on Exception catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }
  
  /// Cancel scheduled notification
  Future<void> cancelScheduledNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } on Exception catch (e) {
      debugPrint('Error cancelling scheduled notification: $e');
      rethrow;
    }
  }
  
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } on Exception catch (e) {
      debugPrint('Error cancelling all notifications: $e');
      rethrow;
    }
  }
  
  /// Private helper methods
  
  /// Save FCM token to backend
  Future<void> _saveTokenToBackend(String token) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        return;
      }
      
      await _apiService.post(
        '/notifications/register-token',
        data: {
          'token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );
      
      debugPrint('FCM token saved to backend');
    } on Exception catch (e) {
      debugPrint('Error saving FCM token to backend: $e');
    }
  }
  
  /// Remove FCM token from backend
  Future<void> _removeTokenFromBackend() async {
    try {
      await _apiService.delete('/notifications/remove-token');
      debugPrint('FCM token removed from backend');
    } on Exception catch (e) {
      debugPrint('Error removing FCM token from backend: $e');
    }
  }
  
  /// Save notification to history
  Future<void> _saveNotificationToHistory(RemoteMessage message) async {
    try {
      await _apiService.post(
        '/notifications/save',
        data: {
          'title': message.notification?.title,
          'body': message.notification?.body,
          'data': message.data,
          'messageId': message.messageId,
          'sentTime': message.sentTime?.toIso8601String(),
        },
      );
    } on Exception catch (e) {
      debugPrint('Error saving notification to history: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  
  // Initialize notification service if needed
  await NotificationService.instance.showLocalNotification(
    title: message.notification?.title ?? 'Home Hustle',
    body: message.notification?.body ?? 'You have a new notification',
    payload: message.data,
  );
}