import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<NotificationState>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final notificationService = ref.read(notificationServiceProvider);
  return NotificationNotifier(apiService, notificationService);
});

class NotificationState {
  final List<AppNotification> allNotifications;
  final List<AppNotification> unreadNotifications;
  final int unreadCount;
  final Map<NotificationType, List<AppNotification>> categorizedNotifications;

  NotificationState({
    required this.allNotifications,
    required this.unreadNotifications,
    required this.unreadCount,
    required this.categorizedNotifications,
  });

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

class NotificationNotifier extends StateNotifier<AsyncValue<NotificationState>> {
  final ApiService _apiService;
  final NotificationService _notificationService;

  NotificationNotifier(this._apiService, this._notificationService) : super(const AsyncValue.loading()) {
    loadNotifications();
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    _notificationService.onNotificationReceived.listen((notification) {
      _handleNewNotification(notification);
    });
  }

  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      
      final notifications = await _apiService.getNotifications();
      
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
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;
      
      await _apiService.markNotificationAsRead(notificationId);
      
      final updatedNotifications = currentState.allNotifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      
      final unreadNotifications = updatedNotifications.where((n) => !n.isRead).toList();
      
      final categorized = <NotificationType, List<AppNotification>>{};
      for (var type in NotificationType.values) {
        categorized[type] = updatedNotifications.where((n) => n.type == type).toList();
      }
      
      state = AsyncValue.data(NotificationState(
        allNotifications: updatedNotifications,
        unreadNotifications: unreadNotifications,
        unreadCount: unreadNotifications.length,
        categorizedNotifications: categorized,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final currentState = state.value;
      if (currentState == null) return;
      
      await _apiService.markAllNotificationsAsRead();
      
      final updatedNotifications = currentState.allNotifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();
      
      final categorized = <NotificationType, List<AppNotification>>{};
      for (var type in NotificationType.values) {
        categorized[type] = updatedNotifications.where((n) => n.type == type).toList();
      }
      
      state = AsyncValue.data(NotificationState(
        allNotifications: updatedNotifications,
        unreadNotifications: [],
        unreadCount: 0,
        categorizedNotifications: categorized,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;
      
      await _apiService.deleteNotification(notificationId);
      
      final updatedNotifications = currentState.allNotifications
          .where((n) => n.id != notificationId)
          .toList();
      
      final unreadNotifications = updatedNotifications.where((n) => !n.isRead).toList();
      
      final categorized = <NotificationType, List<AppNotification>>{};
      for (var type in NotificationType.values) {
        categorized[type] = updatedNotifications.where((n) => n.type == type).toList();
      }
      
      state = AsyncValue.data(NotificationState(
        allNotifications: updatedNotifications,
        unreadNotifications: unreadNotifications,
        unreadCount: unreadNotifications.length,
        categorizedNotifications: categorized,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _handleNewNotification(AppNotification notification) {
    final currentState = state.value;
    if (currentState == null) return;
    
    final updatedNotifications = [notification, ...currentState.allNotifications];
    final unreadNotifications = updatedNotifications.where((n) => !n.isRead).toList();
    
    final categorized = <NotificationType, List<AppNotification>>{};
    for (var type in NotificationType.values) {
      categorized[type] = updatedNotifications.where((n) => n.type == type).toList();
    }
    
    state = AsyncValue.data(NotificationState(
      allNotifications: updatedNotifications,
      unreadNotifications: unreadNotifications,
      unreadCount: unreadNotifications.length,
      categorizedNotifications: categorized,
    ));
  }

  List<AppNotification> getNotificationsByType(NotificationType type) {
    final currentState = state.value;
    if (currentState == null) return [];
    
    return currentState.categorizedNotifications[type] ?? [];
  }

  Future<void> updateNotificationSettings({
    required bool jobOffers,
    required bool withdrawalRequests,
    required bool approvals,
    required bool reminders,
  }) async {
    try {
      await _apiService.updateNotificationSettings(
        jobOffers: jobOffers,
        withdrawalRequests: withdrawalRequests,
        approvals: approvals,
        reminders: reminders,
      );
      
      await _notificationService.updateSubscriptions(
        jobOffers: jobOffers,
        withdrawalRequests: withdrawalRequests,
        approvals: approvals,
        reminders: reminders,
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }
}