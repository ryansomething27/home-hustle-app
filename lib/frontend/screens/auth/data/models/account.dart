import 'dart:convert';

/// Model representing a bank account in the Home Hustle app
class AccountModel {
  final String id;
  final String ownerId; // User ID who owns the account
  final String ownerName; // Cached owner name for display
  final String accountType; // 'primary', 'savings', 'spending', 'goals'
  final String accountName;
  final double balance;
  final double availableBalance; // May differ from balance if funds are held
  final String currency; // Default 'USD'
  final String status; // 'active', 'frozen', 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastTransactionAt;
  final String? parentAccountId; // For sub-accounts
  final List<String>? linkedUserIds; // For shared family accounts
  final bool isDefault;
  final bool allowOverdraft;
  final double overdraftLimit;
  final double? interestRate; // For savings accounts
  final String? accountNumber; // Virtual account number
  final String? routingNumber; // Virtual routing number
  final AccountLimits? limits;
  final Map<String, dynamic>? metadata;
  final String? iconName; // Custom icon for the account
  final String? color; // Custom color for UI display
  final List<String>? tags; // For categorization

  AccountModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.accountType,
    required this.accountName,
    required this.balance,
    required this.availableBalance,
    this.currency = 'USD',
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.lastTransactionAt,
    this.parentAccountId,
    this.linkedUserIds,
    this.isDefault = false,
    this.allowOverdraft = false,
    this.overdraftLimit = 0.0,
    this.interestRate,
    this.accountNumber,
    this.routingNumber,
    this.limits,
    this.metadata,
    this.iconName,
    this.color,
    this.tags,
  });

  /// Computed property to check if account is active
  bool get isActive => status == 'active';

  /// Computed property to check if account is frozen
  bool get isFrozen => status == 'frozen';

  /// Computed property to check if account is closed
  bool get isClosed => status == 'closed';

  /// Computed property to check if account can accept deposits
  bool get canAcceptDeposits => isActive;

  /// Computed property to check if account can make withdrawals
  bool get canMakeWithdrawals => isActive && availableBalance > 0;

  /// Computed property to check if account is shared
  bool get isShared => linkedUserIds != null && linkedUserIds!.isNotEmpty;

  /// Computed property to check if account is a savings account
  bool get isSavingsAccount => accountType == 'savings';

  /// Computed property to check if account is a goals account
  bool get isGoalsAccount => accountType == 'goals';

  /// Computed property to get funds on hold
  double get fundsOnHold => balance - availableBalance;

  /// Check if user can withdraw a specific amount
  bool canWithdraw(double amount) {
    if (!isActive) return false;
    
    if (allowOverdraft) {
      return amount <= (availableBalance + overdraftLimit);
    }
    
    return amount <= availableBalance;
  }

  /// Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'accountType': accountType,
      'accountName': accountName,
      'balance': balance,
      'availableBalance': availableBalance,
      'currency': currency,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastTransactionAt': lastTransactionAt?.toIso8601String(),
      'parentAccountId': parentAccountId,
      'linkedUserIds': linkedUserIds,
      'isDefault': isDefault,
      'allowOverdraft': allowOverdraft,
      'overdraftLimit': overdraftLimit,
      'interestRate': interestRate,
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
      'limits': limits?.toMap(),
      'metadata': metadata,
      'iconName': iconName,
      'color': color,
      'tags': tags,
    };
  }

  /// Create model from map
  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      accountType: map['accountType'] ?? 'primary',
      accountName: map['accountName'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      availableBalance: (map['availableBalance'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      status: map['status'] ?? 'active',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
      lastTransactionAt: map['lastTransactionAt'] != null 
          ? DateTime.parse(map['lastTransactionAt']) 
          : null,
      parentAccountId: map['parentAccountId'],
      linkedUserIds: map['linkedUserIds'] != null 
          ? List<String>.from(map['linkedUserIds']) 
          : null,
      isDefault: map['isDefault'] ?? false,
      allowOverdraft: map['allowOverdraft'] ?? false,
      overdraftLimit: (map['overdraftLimit'] ?? 0).toDouble(),
      interestRate: map['interestRate']?.toDouble(),
      accountNumber: map['accountNumber'],
      routingNumber: map['routingNumber'],
      limits: map['limits'] != null 
          ? AccountLimits.fromMap(map['limits']) 
          : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata']) 
          : null,
      iconName: map['iconName'],
      color: map['color'],
      tags: map['tags'] != null 
          ? List<String>.from(map['tags']) 
          : null,
    );
  }

  /// Convert model to JSON string
  String toJson() => json.encode(toMap());

  /// Create model from JSON string
  factory AccountModel.fromJson(String source) => 
      AccountModel.fromMap(json.decode(source));

  /// Create a copy of the model with updated fields
  AccountModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? accountType,
    String? accountName,
    double? balance,
    double? availableBalance,
    String? currency,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastTransactionAt,
    String? parentAccountId,
    List<String>? linkedUserIds,
    bool? isDefault,
    bool? allowOverdraft,
    double? overdraftLimit,
    double? interestRate,
    String? accountNumber,
    String? routingNumber,
    AccountLimits? limits,
    Map<String, dynamic>? metadata,
    String? iconName,
    String? color,
    List<String>? tags,
  }) {
    return AccountModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      accountType: accountType ?? this.accountType,
      accountName: accountName ?? this.accountName,
      balance: balance ?? this.balance,
      availableBalance: availableBalance ?? this.availableBalance,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastTransactionAt: lastTransactionAt ?? this.lastTransactionAt,
      parentAccountId: parentAccountId ?? this.parentAccountId,
      linkedUserIds: linkedUserIds ?? this.linkedUserIds,
      isDefault: isDefault ?? this.isDefault,
      allowOverdraft: allowOverdraft ?? this.allowOverdraft,
      overdraftLimit: overdraftLimit ?? this.overdraftLimit,
      interestRate: interestRate ?? this.interestRate,
      accountNumber: accountNumber ?? this.accountNumber,
      routingNumber: routingNumber ?? this.routingNumber,
      limits: limits ?? this.limits,
      metadata: metadata ?? this.metadata,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AccountModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AccountModel(id: $id, accountName: $accountName, balance: $balance, status: $status)';
  }
}

/// Model representing account transaction limits
class AccountLimits {
  final double? dailyWithdrawalLimit;
  final double? dailyDepositLimit;
  final double? monthlyWithdrawalLimit;
  final double? monthlyDepositLimit;
  final double? singleTransactionLimit;
  final int? dailyTransactionCount;
  final int? monthlyTransactionCount;
  final DateTime? limitsResetAt;

  AccountLimits({
    this.dailyWithdrawalLimit,
    this.dailyDepositLimit,
    this.monthlyWithdrawalLimit,
    this.monthlyDepositLimit,
    this.singleTransactionLimit,
    this.dailyTransactionCount,
    this.monthlyTransactionCount,
    this.limitsResetAt,
  });

  /// Check if a withdrawal is within limits
  bool isWithdrawalWithinLimits(double amount, double dailyTotal, double monthlyTotal) {
    if (singleTransactionLimit != null && amount > singleTransactionLimit!) {
      return false;
    }
    
    if (dailyWithdrawalLimit != null && (dailyTotal + amount) > dailyWithdrawalLimit!) {
      return false;
    }
    
    if (monthlyWithdrawalLimit != null && (monthlyTotal + amount) > monthlyWithdrawalLimit!) {
      return false;
    }
    
    return true;
  }

  /// Check if a deposit is within limits
  bool isDepositWithinLimits(double amount, double dailyTotal, double monthlyTotal) {
    if (singleTransactionLimit != null && amount > singleTransactionLimit!) {
      return false;
    }
    
    if (dailyDepositLimit != null && (dailyTotal + amount) > dailyDepositLimit!) {
      return false;
    }
    
    if (monthlyDepositLimit != null && (monthlyTotal + amount) > monthlyDepositLimit!) {
      return false;
    }
    
    return true;
  }

  /// Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'dailyWithdrawalLimit': dailyWithdrawalLimit,
      'dailyDepositLimit': dailyDepositLimit,
      'monthlyWithdrawalLimit': monthlyWithdrawalLimit,
      'monthlyDepositLimit': monthlyDepositLimit,
      'singleTransactionLimit': singleTransactionLimit,
      'dailyTransactionCount': dailyTransactionCount,
      'monthlyTransactionCount': monthlyTransactionCount,
      'limitsResetAt': limitsResetAt?.toIso8601String(),
    };
  }

  /// Create model from map
  factory AccountLimits.fromMap(Map<String, dynamic> map) {
    return AccountLimits(
      dailyWithdrawalLimit: map['dailyWithdrawalLimit']?.toDouble(),
      dailyDepositLimit: map['dailyDepositLimit']?.toDouble(),
      monthlyWithdrawalLimit: map['monthlyWithdrawalLimit']?.toDouble(),
      monthlyDepositLimit: map['monthlyDepositLimit']?.toDouble(),
      singleTransactionLimit: map['singleTransactionLimit']?.toDouble(),
      dailyTransactionCount: map['dailyTransactionCount']?.toInt(),
      monthlyTransactionCount: map['monthlyTransactionCount']?.toInt(),
      limitsResetAt: map['limitsResetAt'] != null 
          ? DateTime.parse(map['limitsResetAt']) 
          : null,
    );
  }

  /// Create a copy with updated fields
  AccountLimits copyWith({
    double? dailyWithdrawalLimit,
    double? dailyDepositLimit,
    double? monthlyWithdrawalLimit,
    double? monthlyDepositLimit,
    double? singleTransactionLimit,
    int? dailyTransactionCount,
    int? monthlyTransactionCount,
    DateTime? limitsResetAt,
  }) {
    return AccountLimits(
      dailyWithdrawalLimit: dailyWithdrawalLimit ?? this.dailyWithdrawalLimit,
      dailyDepositLimit: dailyDepositLimit ?? this.dailyDepositLimit,
      monthlyWithdrawalLimit: monthlyWithdrawalLimit ?? this.monthlyWithdrawalLimit,
      monthlyDepositLimit: monthlyDepositLimit ?? this.monthlyDepositLimit,
      singleTransactionLimit: singleTransactionLimit ?? this.singleTransactionLimit,
      dailyTransactionCount: dailyTransactionCount ?? this.dailyTransactionCount,
      monthlyTransactionCount: monthlyTransactionCount ?? this.monthlyTransactionCount,
      limitsResetAt: limitsResetAt ?? this.limitsResetAt,
    );
  }
}

/// Model representing a savings goal
class SavingsGoal {
  final String id;
  final String accountId; // Associated goals account
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final String? category;
  final bool isCompleted;
  final DateTime? completedAt;
  final String createdById;
  final List<String>? contributorIds;

  SavingsGoal({
    required this.id,
    required this.accountId,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.category,
    this.isCompleted = false,
    this.completedAt,
    required this.createdById,
    this.contributorIds,
  });

  /// Computed property for progress percentage
  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  /// Computed property for remaining amount
  double get remainingAmount => (targetAmount - currentAmount).clamp(0, double.infinity);

  /// Computed property for days until target
  int get daysUntilTarget => targetDate.difference(DateTime.now()).inDays;

  /// Computed property to check if goal is overdue
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(targetDate);

  /// Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'category': category,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdById': createdById,
      'contributorIds': contributorIds,
    };
  }

  /// Create model from map
  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] ?? '',
      accountId: map['accountId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      targetDate: map['targetDate'] != null 
          ? DateTime.parse(map['targetDate']) 
          : DateTime.now().add(const Duration(days: 30)),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
      imageUrl: map['imageUrl'],
      category: map['category'],
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
      createdById: map['createdById'] ?? '',
      contributorIds: map['contributorIds'] != null 
          ? List<String>.from(map['contributorIds']) 
          : null,
    );
  }
}