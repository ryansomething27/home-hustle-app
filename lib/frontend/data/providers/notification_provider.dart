import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notification type enum
enum NotificationType {
  jobOffer,
  jobApplication,
  jobApproval,
  jobCompleted,
  withdrawalRequest,
  withdrawalApproval,
  payment,
  reward,
  reminder,
  familyInvite,
  system
}

// Notification model
class AppNotification {

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${map['type']}',
        orElse: () => NotificationType.system,
      ),
      data: map['data'] ?? {},
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Notification state
class NotificationState {

  NotificationState({
    required this.allNotifications,
    required this.unreadNotifications,
    required this.unreadCount,
    required this.categorizedNotifications,
  });
  final List<AppNotification> allNotifications;
  final List<AppNotification> unreadNotifications;
  final int unreadCount;
  final Map<NotificationType, List<AppNotification>> categorizedNotifications;

  NotificationState copyWith({
    List<AppNotification>? allNotifications,
    List<AppNotification>? unreadNotifications,
    int? unreadCount,
    Map<NotificationType, List<AppNotification>>? categorizedNotifications,
  }) {
    return NotificationState(
      allNotifications: allNotifications ?? this.allNotifications,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      categorizedNotifications: categorizedNotifications ?? this.categorizedNotifications,
    );
  }
}

// Notification service
class NotificationService {

  NotificationService() {
    _setupFirebaseMessaging();
  }
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StreamController<AppNotification> _notificationController = StreamController<AppNotification>.broadcast();
  
  Stream<AppNotification> get onNotificationReceived => _notificationController.stream;

  Future<void> _setupFirebaseMessaging() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      // Save token to user profile in Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token});
      }
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final notification = AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
          type: _getTypeFromData(message.data),
          data: message.data,
          isRead: false,
          createdAt: DateTime.now(),
        );
        _notificationController.add(notification);
      }
    });
  }

  NotificationType _getTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    if (typeString != null) {
      try {
        return NotificationType.values.firstWhere(
          (e) => e.toString() == 'NotificationType.$typeString',
        );
      } catch (_) {}
    }
    return NotificationType.system;
  }

  Future<void> updateSubscriptions({
    required bool jobOffers,
    required bool withdrawalRequests,
    required bool approvals,
    required bool reminders,
  }) async {
    // Update FCM topic subscriptions
    if (jobOffers) {
      await _messaging.subscribeToTopic('job_offers');
    } else {
      await _messaging.unsubscribeFromTopic('job_offers');
    }

    if (withdrawalRequests) {
      await _messaging.subscribeToTopic('withdrawal_requests');
    } else {
      await _messaging.unsubscribeFromTopic('withdrawal_requests');
    }

    if (approvals) {
      await _messaging.subscribeToTopic('approvals');
    } else {
      await _messaging.unsubscribeFromTopic('approvals');
    }

    if (reminders) {
      await _messaging.subscribeToTopic('reminders');
    } else {
      await _messaging.unsubscribeFromTopic('reminders');
    }
  }

  void dispose() {
    _notificationController.close();
  }
}

// Notification notifier
class NotificationNotifier extends StateNotifier<AsyncValue<NotificationState>> {

  NotificationNotifier() : super(const AsyncValue.loading()) {
    loadNotifications();
    _setupNotificationListeners();
  }
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  void _setupNotificationListeners() {
    // Listen to notification service
    _notificationService.onNotificationReceived.listen((notification) {
      _handleNewNotification(notification);
    });

    // Listen to Firestore notifications
    final user = _auth.currentUser;
    if (user != null) {
      _notificationSubscription = _db
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) {
        _handleFirestoreUpdate(snapshot);
      });
    }
  }

  void _handleFirestoreUpdate(QuerySnapshot snapshot) {
    final notifications = snapshot.docs
        .map((doc) => AppNotification.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    final unreadNotifications = notifications.where((n) => !n.isRead).toList();
    
    final categorized = <NotificationType, List<AppNotification>>{};
    for (var type in NotificationType.values) {
      categorized[type] = notifications.where((n) => n.type == type).toList();
    }
    
    state = AsyncValue.data(NotificationState(
      allNotifications: notifications,
      unreadNotifications: unreadNotifications,
      unreadCount: unreadNotifications.length,
      categorizedNotifications: categorized,
    ));
  }

  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      
      final user = _auth.currentUser;
      if (user == null) {
        state = AsyncValue.error('User not authenticated', StackTrace.current);
        return;
      }

      final snapshot = await _db
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList();
      
      final unreadNotifications = notifications.where((n) => !n.isRead).toList();
      
      final categorized = <NotificationType, List<AppNotification>>{};
      for (var type in NotificationType.values) {
        categorized[type] = notifications.where((n) => n.type == type).toList();
      }
      
      state = AsyncValue.data(NotificationState(
        allNotifications: notifications,
        unreadNotifications: unreadNotifications,
        unreadCount: unreadNotifications.length,
        categorizedNotifications: categorized,
      ));
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.now(),
      });
      
      // State will update automatically via stream listener
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return;
      }

      final batch = _db.batch();
      
      final unreadDocs = await _db
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();
      
      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.now(),
        });
      }
      
      await batch.commit();
      
      // State will update automatically via stream listener
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).delete();
      
      // State will update automatically via stream listener
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _handleNewNotification(AppNotification notification) async {
    try {
      // Save to Firestore
      await _db.collection('notifications').add(notification.toMap());
      
      // State will update automatically via stream listener
    } on Exception catch (e) {
      print('Error saving notification: $e');
    }
  }

  List<AppNotification> getNotificationsByType(NotificationType type) {
    final currentState = state.value;
    if (currentState == null) {
      return [];
    }
    
    return currentState.categorizedNotifications[type] ?? [];
  }

  Future<void> updateNotificationSettings({
    required bool jobOffers,
    required bool withdrawalRequests,
    required bool approvals,
    required bool reminders,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Update user settings in Firestore
      await _db.collection('users').doc(user.uid).update({
        'notificationSettings': {
          'jobOffers': jobOffers,
          'withdrawalRequests': withdrawalRequests,
          'approvals': approvals,
          'reminders': reminders,
        },
      });
      
      // Update FCM subscriptions
      await _notificationService.updateSubscriptions(
        jobOffers: jobOffers,
        withdrawalRequests: withdrawalRequests,
        approvals: approvals,
        reminders: reminders,
      );
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationService.dispose();
    super.dispose();
  }
}

// Provider
final notificationProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<NotificationState>>((ref) {
  return NotificationNotifier();
});