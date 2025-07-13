import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

/// State class for notifications
class NotificationState {
  NotificationState({
    this.notifications = const AsyncValue.loading(),
    this.unreadCount = const AsyncValue.data(0),
    this.preferences = const AsyncValue.loading(),
    this.notificationCache = const {},
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final AsyncValue<List<NotificationModel>> notifications;
  final AsyncValue<int> unreadCount;
  final AsyncValue<NotificationPreferences> preferences;
  final Map<String, NotificationModel> notificationCache;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  NotificationState copyWith({
    AsyncValue<List<NotificationModel>>? notifications,
    AsyncValue<int>? unreadCount,
    AsyncValue<NotificationPreferences>? preferences,
    Map<String, NotificationModel>? notificationCache,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      preferences: preferences ?? this.preferences,
      notificationCache: notificationCache ?? this.notificationCache,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Notification state notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this._notificationService) : super(NotificationState()) {
    // Initialize notification service and load initial data
    _initialize();
  }

  final NotificationService _notificationService;
  static const int _pageSize = 20;

  /// Initialize notification service and load initial data
  Future<void> _initialize() async {
    try {
      await _notificationService.initialize();
      await Future.wait([
        loadNotifications(),
        loadUnreadCount(),
        loadPreferences(),
      ]);
    } on Exception catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  /// Load notifications with pagination
  Future<void> loadNotifications({
    bool refresh = false,
    String? type,
    bool unreadOnly = false,
  }) async {
    if (state.isLoading && !refresh) {
      return;
    }

    final page = refresh ? 1 : state.currentPage;

    state = state.copyWith(
      isLoading: true,
    );

    try {
      final notifications = await _notificationService.fetchNotificationHistory(
        page: page,
        type: type,
        unreadOnly: unreadOnly,
      );

      // Update cache
      final updatedCache = Map<String, NotificationModel>.from(state.notificationCache);
      for (final notification in notifications) {
        updatedCache[notification.id] = notification;
      }

      // Merge with existing notifications if not refreshing
      final List<NotificationModel> updatedNotifications;
      if (refresh) {
        updatedNotifications = notifications;
      } else {
        final currentNotifications = state.notifications.value ?? [];
        updatedNotifications = [...currentNotifications, ...notifications];
      }

      state = state.copyWith(
        notifications: AsyncValue.data(updatedNotifications),
        notificationCache: updatedCache,
        isLoading: false,
        currentPage: refresh ? 2 : page + 1,
        hasMore: notifications.length == _pageSize,
      );
    } on Exception catch (e, stack) {
      state = state.copyWith(
        notifications: AsyncValue.error(e, stack),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore({
    String? type,
    bool unreadOnly = false,
  }) async {
    if (!state.hasMore || state.isLoading) {
      return;
    }

    await loadNotifications(
      type: type,
      unreadOnly: unreadOnly,
    );
  }

  /// Load unread notification count
  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      state = state.copyWith(
        unreadCount: AsyncValue.data(count),
      );
    } on Exception catch (e, stack) {
      state = state.copyWith(
        unreadCount: AsyncValue.error(e, stack),
      );
    }
  }

  /// Load notification preferences
  Future<void> loadPreferences() async {
    try {
      final preferences = await _notificationService.getNotificationPreferences();
      state = state.copyWith(
        preferences: AsyncValue.data(preferences),
      );
    } on Exception catch (e, stack) {
      state = state.copyWith(
        preferences: AsyncValue.error(e, stack),
      );
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      final notifications = state.notifications.value ?? [];
      final updatedNotifications = notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
        return notification;
      }).toList();

      // Update cache
      final updatedCache = Map<String, NotificationModel>.from(state.notificationCache);
      if (updatedCache.containsKey(notificationId)) {
        updatedCache[notificationId] = updatedCache[notificationId]!.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }

      state = state.copyWith(
        notifications: AsyncValue.data(updatedNotifications),
        notificationCache: updatedCache,
      );

      // Update unread count
      await loadUnreadCount();
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      // Update local state
      final notifications = state.notifications.value ?? [];
      final updatedNotifications = notifications.map((notification) {
        return notification.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }).toList();

      // Update cache
      final updatedCache = <String, NotificationModel>{};
      state.notificationCache.forEach((key, notification) {
        updatedCache[key] = notification.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      });

      state = state.copyWith(
        notifications: AsyncValue.data(updatedNotifications),
        notificationCache: updatedCache,
        unreadCount: const AsyncValue.data(0),
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Update local state
      final notifications = state.notifications.value ?? [];
      final updatedNotifications = notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      // Update cache
      final updatedCache = Map<String, NotificationModel>.from(state.notificationCache)
      ..remove(notificationId);

      state = state.copyWith(
        notifications: AsyncValue.data(updatedNotifications),
        notificationCache: updatedCache,
      );

      // Update unread count if the deleted notification was unread
      final deletedNotification = notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => notifications.first,
      );
      
      if (!deletedNotification.isRead) {
        await loadUnreadCount();
      }
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update notification preferences
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    state = state.copyWith(
      preferences: const AsyncValue.loading(),
    );

    try {
      final updatedPreferences = await _notificationService.updateNotificationPreferences(preferences);
      state = state.copyWith(
        preferences: AsyncValue.data(updatedPreferences),
      );
    } on Exception catch (e, stack) {
      state = state.copyWith(
        preferences: AsyncValue.error(e, stack),
      );
    }
  }

  /// Send a notification
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
      await _notificationService.sendNotification(
        title: title,
        body: body,
        recipientId: recipientId,
        type: type,
        actionType: actionType,
        actionData: actionData,
        imageUrl: imageUrl,
        priority: priority,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _notificationService.scheduleNotification(
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: payload,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Handle notification tap/action
  Future<void> handleNotificationAction(
    String notificationId,
    String action,
    String? data,
  ) async {
    try {
      // Mark as read if not already
      final notification = state.notificationCache[notificationId];
      if (notification != null && !notification.isRead) {
        await markAsRead(notificationId);
      }

      // Handle the action based on type
      switch (action) {
        case 'navigate':
          // Navigation will be handled by the UI layer
          break;
        case 'url':
          // URL opening will be handled by the UI layer
          break;
        case 'dismiss':
          // Just mark as read, already done above
          break;
        case 'custom':
          // Custom actions handled by UI layer
          break;
      }
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    final notifications = state.notifications.value ?? [];
    return notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    final notifications = state.notifications.value ?? [];
    return notifications.where((n) => !n.isRead).toList();
  }

  /// Get high priority notifications
  List<NotificationModel> getHighPriorityNotifications() {
    final notifications = state.notifications.value ?? [];
    return notifications.where((n) => n.isHighPriority).toList();
  }

  /// Clear all notifications from local state
  void clearNotifications() {
    state = state.copyWith(
      notifications: const AsyncValue.data([]),
      notificationCache: const {},
      currentPage: 1,
      hasMore: true,
    );
  }

  /// Refresh all notification data
  Future<void> refresh() async {
    await Future.wait([
      loadNotifications(refresh: true),
      loadUnreadCount(),
      loadPreferences(),
    ]);
  }
}

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

/// Provider for notification state notifier
final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationNotifier(notificationService);
});

/// Provider for notifications list
final notificationsProvider = Provider<AsyncValue<List<NotificationModel>>>((ref) {
  return ref.watch(notificationNotifierProvider).notifications;
});

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(notificationNotifierProvider).unreadCount;
});

/// Provider for notification preferences
final notificationPreferencesProvider = Provider<AsyncValue<NotificationPreferences>>((ref) {
  return ref.watch(notificationNotifierProvider).preferences;
});

/// Provider for filtered notifications by type
final notificationsByTypeProvider = Provider.family<List<NotificationModel>, String>((ref, type) {
  final notifier = ref.watch(notificationNotifierProvider.notifier);
  return notifier.getNotificationsByType(type);
});

/// Provider for unread notifications only
final unreadNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notifier = ref.watch(notificationNotifierProvider.notifier);
  return notifier.getUnreadNotifications();
});

/// Provider for high priority notifications
final highPriorityNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notifier = ref.watch(notificationNotifierProvider.notifier);
  return notifier.getHighPriorityNotifications();
});