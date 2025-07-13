import 'dart:convert';

/// Model representing a financial transaction in the Home Hustle app
class TransactionModel {

  TransactionModel({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.fromAccountId, required this.fromAccountName, required this.fromUserId, required this.fromUserName, required this.toAccountId, required this.toAccountName, required this.toUserId, required this.toUserName, required this.description, required this.createdAt, this.currency = 'USD',
    this.completedAt,
    this.referenceType,
    this.referenceId,
    this.categoryId,
    this.categoryName,
    this.notes,
    this.failureReason,
    this.metadata,
    this.receiptUrl,
    this.isRecurring = false,
    this.recurringSchedule,
    this.nextRecurringDate,
  });

  /// Create model from map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? 'pending',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      fromAccountId: map['fromAccountId'] ?? '',
      fromAccountName: map['fromAccountName'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      fromUserName: map['fromUserName'] ?? '',
      toAccountId: map['toAccountId'] ?? '',
      toAccountName: map['toAccountName'] ?? '',
      toUserId: map['toUserId'] ?? '',
      toUserName: map['toUserName'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
      referenceType: map['referenceType'],
      referenceId: map['referenceId'],
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      notes: map['notes'],
      failureReason: map['failureReason'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata']) 
          : null,
      receiptUrl: map['receiptUrl'],
      isRecurring: map['isRecurring'] ?? false,
      recurringSchedule: map['recurringSchedule'],
      nextRecurringDate: map['nextRecurringDate'] != null 
          ? DateTime.parse(map['nextRecurringDate']) 
          : null,
    );
  }

  /// Create model from JSON string
  factory TransactionModel.fromJson(String source) => 
      TransactionModel.fromMap(json.decode(source));
  final String id;
  final String type; // 'job_payment', 'store_purchase', 'store_credit', 'transfer', 'adjustment', 'withdrawal'
  final String status; // 'pending', 'completed', 'failed', 'cancelled'
  final double amount;
  final String currency; // Default 'USD'
  final String fromAccountId;
  final String fromAccountName; // Cached for display
  final String fromUserId;
  final String fromUserName; // Cached for display
  final String toAccountId;
  final String toAccountName; // Cached for display
  final String toUserId;
  final String toUserName; // Cached for display
  final String description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? referenceType; // 'job', 'store_item', 'transfer', etc.
  final String? referenceId; // ID of related job, store item, etc.
  final String? categoryId; // For categorizing transactions
  final String? categoryName; // Cached category name
  final String? notes;
  final String? failureReason;
  final Map<String, dynamic>? metadata; // Additional transaction data
  final String? receiptUrl; // For store purchases
  final bool isRecurring;
  final String? recurringSchedule; // 'weekly', 'monthly', etc.
  final DateTime? nextRecurringDate;

  /// Computed property to check if transaction is pending
  bool get isPending => status == 'pending';

  /// Computed property to check if transaction is completed
  bool get isCompleted => status == 'completed';

  /// Computed property to check if transaction is failed
  bool get isFailed => status == 'failed';

  /// Computed property to check if transaction is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Computed property to check if this is a debit (money out)
  bool get isDebit => type == 'store_purchase' || type == 'withdrawal' || 
      (type == 'transfer' && fromUserId == toUserId);

  /// Computed property to check if this is a credit (money in)
  bool get isCredit => type == 'job_payment' || type == 'store_credit' || 
      (type == 'transfer' && fromUserId != toUserId);

  /// Computed property to get transaction direction for a specific user
  String getDirectionForUser(String userId) {
    if (fromUserId == userId) {
      return 'outgoing';
    } else if (toUserId == userId) {
      return 'incoming';
    }
    return 'unknown';
  }

  /// Computed property to format the amount with sign for display
  String getFormattedAmountForUser(String userId) {
    final direction = getDirectionForUser(userId);
    if (direction == 'outgoing') {
      return '-\$${amount.toStringAsFixed(2)}';
    } else if (direction == 'incoming') {
      return '+\$${amount.toStringAsFixed(2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'amount': amount,
      'currency': currency,
      'fromAccountId': fromAccountId,
      'fromAccountName': fromAccountName,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toAccountId': toAccountId,
      'toAccountName': toAccountName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'referenceType': referenceType,
      'referenceId': referenceId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'notes': notes,
      'failureReason': failureReason,
      'metadata': metadata,
      'receiptUrl': receiptUrl,
      'isRecurring': isRecurring,
      'recurringSchedule': recurringSchedule,
      'nextRecurringDate': nextRecurringDate?.toIso8601String(),
    };
  }

  /// Convert model to JSON string
  String toJson() => json.encode(toMap());

  /// Create a copy of the model with updated fields
  TransactionModel copyWith({
    String? id,
    String? type,
    String? status,
    double? amount,
    String? currency,
    String? fromAccountId,
    String? fromAccountName,
    String? fromUserId,
    String? fromUserName,
    String? toAccountId,
    String? toAccountName,
    String? toUserId,
    String? toUserName,
    String? description,
    DateTime? createdAt,
    DateTime? completedAt,
    String? referenceType,
    String? referenceId,
    String? categoryId,
    String? categoryName,
    String? notes,
    String? failureReason,
    Map<String, dynamic>? metadata,
    String? receiptUrl,
    bool? isRecurring,
    String? recurringSchedule,
    DateTime? nextRecurringDate,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      fromAccountName: fromAccountName ?? this.fromAccountName,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toAccountId: toAccountId ?? this.toAccountId,
      toAccountName: toAccountName ?? this.toAccountName,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      notes: notes ?? this.notes,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringSchedule: recurringSchedule ?? this.recurringSchedule,
      nextRecurringDate: nextRecurringDate ?? this.nextRecurringDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
  
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $type, amount: $amount, status: $status)';
  }
}

/// Model representing a transaction summary for reporting
class TransactionSummary {

  TransactionSummary({
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netAmount,
    required this.transactionCount,
    required this.incomeByCategory,
    required this.expensesByCategory,
    required this.transactionCountByType,
  });

  /// Create model from map
  factory TransactionSummary.fromMap(Map<String, dynamic> map) {
    return TransactionSummary(
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      totalIncome: (map['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (map['totalExpenses'] ?? 0).toDouble(),
      netAmount: (map['netAmount'] ?? 0).toDouble(),
      transactionCount: map['transactionCount'] ?? 0,
      incomeByCategory: Map<String, double>.from(
        map['incomeByCategory'] ?? {},
      ),
      expensesByCategory: Map<String, double>.from(
        map['expensesByCategory'] ?? {},
      ),
      transactionCountByType: Map<String, int>.from(
        map['transactionCountByType'] ?? {},
      ),
    );
  }

  /// Create model from JSON string
  factory TransactionSummary.fromJson(String source) => 
      TransactionSummary.fromMap(json.decode(source));
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome;
  final double totalExpenses;
  final double netAmount;
  final int transactionCount;
  final Map<String, double> incomeByCategory;
  final Map<String, double> expensesByCategory;
  final Map<String, int> transactionCountByType;

  /// Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netAmount': netAmount,
      'transactionCount': transactionCount,
      'incomeByCategory': incomeByCategory,
      'expensesByCategory': expensesByCategory,
      'transactionCountByType': transactionCountByType,
    };
  }

  /// Convert model to JSON string
  String toJson() => json.encode(toMap());
}