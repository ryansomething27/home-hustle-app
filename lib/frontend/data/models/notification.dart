import 'dart:convert';

/// Model representing a notification in the Home Hustle app
class NotificationModel { // Custom action buttons

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.recipientId,
    required this.createdAt, this.senderId,
    this.senderName,
    this.readAt,
    this.isRead = false,
    this.priority = 'normal',
    this.actionType,
    this.actionData,
    this.imageUrl,
    this.category,
    this.expiresAt,
    this.metadata,
    this.isPersistent = false,
    this.deepLink,
    this.actions,
  });

  /// Create model from map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      type: map['type'] ?? 'general',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      recipientId: map['recipientId'] ?? '',
      senderId: map['senderId'],
      senderName: map['senderName'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      readAt: map['readAt'] != null 
          ? DateTime.parse(map['readAt']) 
          : null,
      isRead: map['isRead'] ?? false,
      priority: map['priority'] ?? 'normal',
      actionType: map['actionType'],
      actionData: map['actionData'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      expiresAt: map['expiresAt'] != null 
          ? DateTime.parse(map['expiresAt']) 
          : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata']) 
          : null,
      isPersistent: map['isPersistent'] ?? false,
      deepLink: map['deepLink'],
      actions: map['actions'] != null
          ? (map['actions'] as List)
              .map((action) => NotificationAction.fromMap(action))
              .toList()
          : null,
    );
  }

  /// Create model from JSON string
  factory NotificationModel.fromJson(String source) => 
      NotificationModel.fromMap(json.decode(source));
  final String id;
  final String type; // 'job_assigned', 'job_completed', 'job_applied', 'payment_received', 'payment_sent', 'family_invite', 'general', 'reminder'
  final String title;
  final String body;
  final String recipientId; // User ID who receives the notification
  final String? senderId; // User ID who triggered the notification (if applicable)
  final String? senderName; // Cached sender name for display
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final String priority; // 'low', 'normal', 'high', 'urgent'
  final String? actionType; // 'navigate', 'url', 'dismiss'
  final String? actionData; // JSON string with action parameters
  final String? imageUrl; // For rich notifications
  final String? category; // For grouping notifications
  final DateTime? expiresAt; // When the notification becomes irrelevant
  final Map<String, dynamic>? metadata; // Additional notification data
  final bool isPersistent; // Whether notification should remain after being read
  final String? deepLink; // App deep link for navigation
  final List<NotificationAction>? actions;

  /// Computed property to check if notification is expired
  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Computed property to check if notification is high priority
  bool get isHighPriority => priority == 'high' || priority == 'urgent';

  /// Computed property to check if notification is urgent
  bool get isUrgent => priority == 'urgent';

  /// Computed property to check if notification has actions
  bool get hasActions => actions != null && actions!.isNotEmpty;

  /// Computed property to get time since notification
  Duration get timeSinceCreated => DateTime.now().difference(createdAt);

  /// Get formatted notification type for display
  String get formattedType {
    switch (type) {
      case 'job_assigned':
        return 'Job Assigned';
      case 'job_completed':
        return 'Job Completed';
      case 'job_applied':
        return 'New Job Application';
      case 'payment_received':
        return 'Payment Received';
      case 'payment_sent':
        return 'Payment Sent';
      case 'family_invite':
        return 'Family Invitation';
      case 'general':
        return 'General';
      case 'reminder':
        return 'Reminder';
      default:
        return type.replaceAll('_', ' ').split(' ').map((word) => 
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }

  /// Get icon for notification type
  String get iconName {
    switch (type) {
      case 'job_assigned':
      case 'job_completed':
      case 'job_applied':
        return 'work';
      case 'payment_received':
      case 'payment_sent':
        return 'payments';
      case 'family_invite':
        return 'family_restroom';
      case 'reminder':
        return 'alarm';
      case 'general':
      default:
        return 'notifications';
    }
  }

  /// Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isRead': isRead,
      'priority': priority,
      'actionType': actionType,
      'actionData': actionData,
      'imageUrl': imageUrl,
      'category': category,
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
      'isPersistent': isPersistent,
      'deepLink': deepLink,
      'actions': actions?.map((action) => action.toMap()).toList(),
    };
  }

  /// Convert model to JSON string
  String toJson() => json.encode(toMap());

  /// Create a copy of the model with updated fields
  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? recipientId,
    String? senderId,
    String? senderName,
    DateTime? createdAt,
    DateTime? readAt,
    bool? isRead,
    String? priority,
    String? actionType,
    String? actionData,
    String? imageUrl,
    String? category,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    bool? isPersistent,
    String? deepLink,
    List<NotificationAction>? actions,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
      isPersistent: isPersistent ?? this.isPersistent,
      deepLink: deepLink ?? this.deepLink,
      actions: actions ?? this.actions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
  
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, title: $title, isRead: $isRead)';
  }
}

/// Model representing a notification action button
class NotificationAction {

  NotificationAction({
    required this.id,
    required this.label,
    required this.action,
    this.data,
    this.icon,
    this.isPrimary = false,
  });

  /// Create model from map
  factory NotificationAction.fromMap(Map<String, dynamic> map) {
    return NotificationAction(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      action: map['action'] ?? 'dismiss',
      data: map['data'],
      icon: map['icon'],
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  /// Create model from JSON string
  factory NotificationAction.fromJson(String source) => 
      NotificationAction.fromMap(json.decode(source));
  final String id;
  final String label;
  final String action; // 'navigate', 'url', 'dismiss', 'custom'
  final String? data; // Action-specific data (route, URL, etc.)
  final String? icon;
  final bool isPrimary;

  /// Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'action': action,
      'data': data,
      'icon': icon,
      'isPrimary': isPrimary,
    };
  }

  /// Convert model to JSON string
  String toJson() => json.encode(toMap());
}

/// Model representing notification preferences
class NotificationPreferences {

  NotificationPreferences({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.jobNotifications = true,
    this.paymentNotifications = true,
    this.familyNotifications = true,
    this.reminderNotifications = true,
    this.marketingNotifications = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
    this.weekendQuietHours = false,
    this.mutedCategories = const [],
  });

  /// Create model from map
  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      pushEnabled: map['pushEnabled'] ?? true,
      emailEnabled: map['emailEnabled'] ?? true,
      jobNotifications: map['jobNotifications'] ?? true,
      paymentNotifications: map['paymentNotifications'] ?? true,
      familyNotifications: map['familyNotifications'] ?? true,
      reminderNotifications: map['reminderNotifications'] ?? true,
      marketingNotifications: map['marketingNotifications'] ?? false,
      quietHoursStart: map['quietHoursStart'] ?? '22:00',
      quietHoursEnd: map['quietHoursEnd'] ?? '07:00',
      weekendQuietHours: map['weekendQuietHours'] ?? false,
      mutedCategories: List<String>.from(map['mutedCategories'] ?? []),
    );
  }
  final bool pushEnabled;
  final bool emailEnabled;
  final bool jobNotifications;
  final bool paymentNotifications;
  final bool familyNotifications;
  final bool reminderNotifications;
  final bool marketingNotifications;
  final String quietHoursStart; // "22:00" format
  final String quietHoursEnd; // "07:00" format
  final bool weekendQuietHours;
  final List<String> mutedCategories;

  /// Check if notifications should be delivered now
  bool shouldDeliverNow() {
    if (!pushEnabled) {
      return false;
    }
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Check weekend quiet hours
    if (weekendQuietHours && (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday)) {
      return false;
    }
    
    // Check quiet hours
    if (quietHoursStart.compareTo(quietHoursEnd) < 0) {
      // Normal case: quiet hours don't cross midnight
      return currentTime.compareTo(quietHoursStart) < 0 || currentTime.compareTo(quietHoursEnd) > 0;
    } else {
      // Quiet hours cross midnight
      return currentTime.compareTo(quietHoursStart) < 0 && currentTime.compareTo(quietHoursEnd) > 0;
    }
  }

  /// Check if a specific notification type is enabled
  bool isTypeEnabled(String notificationType) {
    switch (notificationType) {
      case 'job_assigned':
      case 'job_completed':
      case 'job_applied':
        return jobNotifications;
      case 'payment_received':
      case 'payment_sent':
        return paymentNotifications;
      case 'family_invite':
        return familyNotifications;
      case 'reminder':
        return reminderNotifications;
      default:
        return true;
    }
  }

  /// Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'jobNotifications': jobNotifications,
      'paymentNotifications': paymentNotifications,
      'familyNotifications': familyNotifications,
      'reminderNotifications': reminderNotifications,
      'marketingNotifications': marketingNotifications,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'weekendQuietHours': weekendQuietHours,
      'mutedCategories': mutedCategories,
    };
  }

  /// Create a copy with updated fields
  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? jobNotifications,
    bool? paymentNotifications,
    bool? familyNotifications,
    bool? reminderNotifications,
    bool? marketingNotifications,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? weekendQuietHours,
    List<String>? mutedCategories,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      jobNotifications: jobNotifications ?? this.jobNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      familyNotifications: familyNotifications ?? this.familyNotifications,
      reminderNotifications: reminderNotifications ?? this.reminderNotifications,
      marketingNotifications: marketingNotifications ?? this.marketingNotifications,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      weekendQuietHours: weekendQuietHours ?? this.weekendQuietHours,
      mutedCategories: mutedCategories ?? this.mutedCategories,
    );
  }
}