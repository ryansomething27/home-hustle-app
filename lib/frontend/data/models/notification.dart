import '../../core/constants.dart';

class Notification {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final NotificationPriority priority;
  final DateTime? expiresAt;

  Notification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.data,
    this.imageUrl,
    this.priority = NotificationPriority.normal,
    this.expiresAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      notificationId: json['notificationId'] as String,
      userId: json['userId'] as String,
      type: _parseNotificationType(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      priority: _parseNotificationPriority(json['priority'] as String? ?? 'normal'),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
      'data': data,
      'imageUrl': imageUrl,
      'priority': priority.toString().split('.').last,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'joboffer':
      case 'job_offer':
        return NotificationType.jobOffer;
      case 'jobapplication':
      case 'job_application':
        return NotificationType.jobApplication;
      case 'jobcompletion':
      case 'job_completion':
        return NotificationType.jobCompletion;
      case 'withdrawalrequest':
      case 'withdrawal_request':
        return NotificationType.withdrawalRequest;
      case 'withdrawalapproval':
      case 'withdrawal_approval':
        return NotificationType.withdrawalApproval;
      case 'parentapproval':
      case 'parent_approval':
        return NotificationType.parentApproval;
      case 'paymentreceived':
      case 'payment_received':
        return NotificationType.paymentReceived;
      case 'reminder':
        return NotificationType.reminder;
      case 'achievement':
        return NotificationType.achievement;
      case 'systemalert':
      case 'system_alert':
        return NotificationType.systemAlert;
      default:
        throw ArgumentError('Invalid notification type: $type');
    }
  }

  static NotificationPriority _parseNotificationPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }

  Notification copyWith({
    String? notificationId,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? data,
    String? imageUrl,
    NotificationPriority? priority,
    DateTime? expiresAt,
  }) {
    return Notification(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // Getters
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isHighPriority => priority == NotificationPriority.high || priority == NotificationPriority.urgent;
  bool get hasAction => actionUrl != null && actionUrl!.isNotEmpty;

  String get icon {
    switch (type) {
      case NotificationType.jobOffer:
        return '💼';
      case NotificationType.jobApplication:
        return '📋';
      case NotificationType.jobCompletion:
        return '✅';
      case NotificationType.withdrawalRequest:
        return '💰';
      case NotificationType.withdrawalApproval:
        return '✔️';
      case NotificationType.parentApproval:
        return '👨‍👩‍👧';
      case NotificationType.paymentReceived:
        return '💵';
      case NotificationType.reminder:
        return '🔔';
      case NotificationType.achievement:
        return '🏆';
      case NotificationType.systemAlert:
        return '⚠️';
    }
  }

  String get categoryName {
    switch (type) {
      case NotificationType.jobOffer:
      case NotificationType.jobApplication:
      case NotificationType.jobCompletion:
        return 'Jobs';
      case NotificationType.withdrawalRequest:
      case NotificationType.withdrawalApproval:
      case NotificationType.paymentReceived:
        return 'Money';
      case NotificationType.parentApproval:
        return 'Approvals';
      case NotificationType.reminder:
        return 'Reminders';
      case NotificationType.achievement:
        return 'Achievements';
      case NotificationType.systemAlert:
        return 'System';
    }
  }
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class NotificationSettings {
  final bool pushNotificationsEnabled;
  final bool inAppNotificationsEnabled;
  final Map<NotificationType, bool> typeSettings;
  final List<String> mutedHours;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationSettings({
    this.pushNotificationsEnabled = true,
    this.inAppNotificationsEnabled = true,
    Map<NotificationType, bool>? typeSettings,
    this.mutedHours = const [],
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  }) : typeSettings = typeSettings ?? _defaultTypeSettings();

  static Map<NotificationType, bool> _defaultTypeSettings() {
    return Map.fromEntries(
      NotificationType.values.map((type) => MapEntry(type, true)),
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final typeSettingsJson = json['typeSettings'] as Map<String, dynamic>?;
    final typeSettings = <NotificationType, bool>{};
    
    if (typeSettingsJson != null) {
      typeSettingsJson.forEach((key, value) {
        try {
          final type = Notification._parseNotificationType(key);
          typeSettings[type] = value as bool;
        } catch (_) {
          // Skip invalid notification types
        }
      });
    }

    return NotificationSettings(
      pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
      inAppNotificationsEnabled: json['inAppNotificationsEnabled'] as bool? ?? true,
      typeSettings: typeSettings.isEmpty ? null : typeSettings,
      mutedHours: List<String>.from(json['mutedHours'] ?? []),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final typeSettingsJson = <String, bool>{};
    typeSettings.forEach((type, enabled) {
      typeSettingsJson[type.toString().split('.').last] = enabled;
    });

    return {
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'inAppNotificationsEnabled': inAppNotificationsEnabled,
      'typeSettings': typeSettingsJson,
      'mutedHours': mutedHours,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  bool isTypeEnabled(NotificationType type) {
    return typeSettings[type] ?? true;
  }

  bool get isCurrentlyMuted {
    if (mutedHours.isEmpty) return false;
    
    final now = DateTime.now();
    final currentHour = now.hour.toString().padLeft(2, '0');
    return mutedHours.contains(currentHour);
  }

  NotificationSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? inAppNotificationsEnabled,
    Map<NotificationType, bool>? typeSettings,
    List<String>? mutedHours,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      inAppNotificationsEnabled: inAppNotificationsEnabled ?? this.inAppNotificationsEnabled,
      typeSettings: typeSettings ?? this.typeSettings,
      mutedHours: mutedHours ?? this.mutedHours,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

class NotificationGroup {
  final NotificationType type;
  final List<Notification> notifications;
  final int unreadCount;
  final DateTime latestDate;

  NotificationGroup({
    required this.type,
    required this.notifications,
    required this.unreadCount,
    required this.latestDate,
  });

  factory NotificationGroup.fromNotifications(
    NotificationType type,
    List<Notification> allNotifications,
  ) {
    final filtered = allNotifications.where((n) => n.type == type).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return NotificationGroup(
      type: type,
      notifications: filtered,
      unreadCount: filtered.where((n) => !n.isRead).length,
      latestDate: filtered.isNotEmpty ? filtered.first.createdAt : DateTime.now(),
    );
  }

  String get title => notifications.first.categoryName;
  String get icon => notifications.first.icon;
  bool get hasUnread => unreadCount > 0;
}

class PushNotificationPayload {
  final String notificationId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;

  PushNotificationPayload({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.imageUrl,
    this.actionUrl,
  });

  factory PushNotificationPayload.fromJson(Map<String, dynamic> json) {
    return PushNotificationPayload(
      notificationId: json['notificationId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: Notification._parseNotificationType(json['type'] as String),
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'data': data,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }
}