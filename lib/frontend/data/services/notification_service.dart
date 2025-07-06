import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'auth_service.dart';

class NotificationService {
  final ApiService _apiService;
  final AuthService _authService;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'home_hustle_notifications';
  static const String _channelName = 'Home Hustle Notifications';
  static const String _channelDescription = 'Notifications for Home Hustle app';

  NotificationService({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  // Initialize notification services
  Future<void> initialize() async {
    // Request permission for iOS
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure FCM
    await _configureFCM();

    // Update FCM token
    await _updateFCMToken();
  }

  // Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('Notification permission status: ${settings.authorizationStatus}');
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings();

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      final androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  // Configure FCM handlers
  Future<void> _configureFCM() async {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is in background
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is opened from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageData(initialMessage.data);
    }

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessageData(message.data);
    });
  }

  // Update FCM token in backend
  Future<void> _updateFCMToken() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken == null) return;

    try {
      await _apiService.post('/notifications/update-token', {
        'fcmToken': fcmToken,
      });
    } catch (e) {
      print('Failed to update FCM token: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(
      title: message.notification?.title ?? 'Home Hustle',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  // Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleMessageData(data);
    }
  }

  // Handle message data for navigation
  void _handleMessageData(Map<String, dynamic> data) {
    final notificationType = data['type'] as String?;
    // final targetId = data['targetId'] as String?;

    // Navigate based on notification type
    // This should be implemented with your navigation system
    switch (notificationType) {
      case 'job_offer':
        // Navigate to job details
        break;
      case 'withdrawal_request':
        // Navigate to withdrawals
        break;
      case 'job_completed':
        // Navigate to job history
        break;
      case 'purchase_made':
        // Navigate to store purchases
        break;
      default:
        // Navigate to notifications screen
        break;
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    final iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Get notifications for current user
  Future<List<AppNotification>> getNotifications({
    int? limit,
    bool? unreadOnly,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (unreadOnly != null) queryParams['unreadOnly'] = unreadOnly;

    final response = await _apiService.get(
      '/notifications',
      params: queryParams,
    );

    return (response['notifications'] as List)
        .map((json) => AppNotification.fromJson(json))
        .toList();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _apiService.patch('/notifications/$notificationId/read', {});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _apiService.post('/notifications/mark-all-read', {});
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _apiService.delete('/notifications/$notificationId');
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    final userId = _authService.currentUserId;
    if (userId == null) return 0;

    try {
      final response = await _apiService.get('/notifications/unread-count');
      return response['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  // Subscribe to notification topics
  Future<void> subscribeToTopics(List<String> topics) async {
    for (final topic in topics) {
      await _firebaseMessaging.subscribeToTopic(topic);
    }
  }

  // Unsubscribe from notification topics
  Future<void> unsubscribeFromTopics(List<String> topics) async {
    for (final topic in topics) {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences({
    bool? jobOffers,
    bool? withdrawalRequests,
    bool? jobCompletions,
    bool? purchases,
    bool? reminders,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final preferences = <String, dynamic>{};
    if (jobOffers != null) preferences['jobOffers'] = jobOffers;
    if (withdrawalRequests != null) {
      preferences['withdrawalRequests'] = withdrawalRequests;
    }
    if (jobCompletions != null) preferences['jobCompletions'] = jobCompletions;
    if (purchases != null) preferences['purchases'] = purchases;
    if (reminders != null) preferences['reminders'] = reminders;

    await _apiService.patch('/notifications/preferences', preferences);
  }

  // Get notification preferences
  Future<NotificationPreferences> getNotificationPreferences() async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _apiService.get('/notifications/preferences');
    return NotificationPreferences.fromJson(response);
  }

  // Send test notification (for debugging)
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Home Hustle',
      payload: jsonEncode({'type': 'test'}),
    );
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Handle token refresh
  void handleTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((_) {
      _updateFCMToken();
    });
  }
}

// Background message handler (must be top-level function)
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

// Supporting models

class NotificationPreferences {
  final bool jobOffers;
  final bool withdrawalRequests;
  final bool jobCompletions;
  final bool purchases;
  final bool reminders;

  NotificationPreferences({
    required this.jobOffers,
    required this.withdrawalRequests,
    required this.jobCompletions,
    required this.purchases,
    required this.reminders,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      jobOffers: json['jobOffers'] ?? true,
      withdrawalRequests: json['withdrawalRequests'] ?? true,
      jobCompletions: json['jobCompletions'] ?? true,
      purchases: json['purchases'] ?? true,
      reminders: json['reminders'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobOffers': jobOffers,
      'withdrawalRequests': withdrawalRequests,
      'jobCompletions': jobCompletions,
      'purchases': purchases,
      'reminders': reminders,
    };
  }
}