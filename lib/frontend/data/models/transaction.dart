import '../../core/constants.dart';

class Transaction {
  final String transactionId;
  final String userId;
  final TransactionType type;
  final double amount;
  final String? sourceAccountId;
  final String? targetAccountId;
  final DateTime createdAt;
  final TransactionStatus status;
  final String description;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.transactionId,
    required this.userId,
    required this.type,
    required this.amount,
    this.sourceAccountId,
    this.targetAccountId,
    required this.createdAt,
    required this.status,
    required this.description,
    this.relatedEntityId,
    this.relatedEntityType,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'] as String,
      userId: json['userId'] as String,
      type: _parseTransactionType(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      sourceAccountId: json['sourceAccountId'] as String?,
      targetAccountId: json['targetAccountId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: _parseTransactionStatus(json['status'] as String),
      description: json['description'] as String,
      relatedEntityId: json['relatedEntityId'] as String?,
      relatedEntityType: json['relatedEntityType'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'sourceAccountId': sourceAccountId,
      'targetAccountId': targetAccountId,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'description': description,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
      'metadata': metadata,
    };
  }

  static TransactionType _parseTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'transfer':
        return TransactionType.transfer;
      case 'jobpayment':
      case 'job_payment':
        return TransactionType.jobPayment;
      case 'storepurchase':
      case 'store_purchase':
        return TransactionType.storePurchase;
      case 'interest':
        return TransactionType.interest;
      case 'loan':
        return TransactionType.loan;
      case 'loanrepayment':
      case 'loan_repayment':
        return TransactionType.loanRepayment;
      case 'fine':
        return TransactionType.fine;
      default:
        throw ArgumentError('Invalid transaction type: $type');
    }
  }

  static TransactionStatus _parseTransactionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        throw ArgumentError('Invalid transaction status: $status');
    }
  }

  Transaction copyWith({
    String? transactionId,
    String? userId,
    TransactionType? type,
    double? amount,
    String? sourceAccountId,
    String? targetAccountId,
    DateTime? createdAt,
    TransactionStatus? status,
    String? description,
    String? relatedEntityId,
    String? relatedEntityType,
    Map<String, dynamic>? metadata,
  }) {
    return Transaction(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      targetAccountId: targetAccountId ?? this.targetAccountId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      description: description ?? this.description,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      metadata: metadata ?? this.metadata,
    );
  }

  // Getters
  bool get isDebit => type == TransactionType.withdrawal ||
      type == TransactionType.storePurchase ||
      type == TransactionType.fine ||
      type == TransactionType.loanRepayment ||
      (type == TransactionType.transfer && sourceAccountId != null);

  bool get isCredit => type == TransactionType.deposit ||
      type == TransactionType.jobPayment ||
      type == TransactionType.interest ||
      type == TransactionType.loan ||
      (type == TransactionType.transfer && targetAccountId != null);

  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;

  String get displayType {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.jobPayment:
        return 'Job Payment';
      case TransactionType.storePurchase:
        return 'Store Purchase';
      case TransactionType.interest:
        return 'Interest';
      case TransactionType.loan:
        return 'Loan';
      case TransactionType.loanRepayment:
        return 'Loan Repayment';
      case TransactionType.fine:
        return 'Fine';
    }
  }

  String get icon {
    switch (type) {
      case TransactionType.deposit:
        return '💰';
      case TransactionType.withdrawal:
        return '💸';
      case TransactionType.transfer:
        return '🔄';
      case TransactionType.jobPayment:
        return '💼';
      case TransactionType.storePurchase:
        return '🛍️';
      case TransactionType.interest:
        return '📈';
      case TransactionType.loan:
        return '🏦';
      case TransactionType.loanRepayment:
        return '💳';
      case TransactionType.fine:
        return '⚠️';
    }
  }
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class TransactionSummary {
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome;
  final double totalExpenses;
  final double netAmount;
  final Map<TransactionType, double> incomeByType;
  final Map<TransactionType, double> expensesByType;
  final int transactionCount;

  TransactionSummary({
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netAmount,
    required this.incomeByType,
    required this.expensesByType,
    required this.transactionCount,
  });

  factory TransactionSummary.fromTransactions(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    double income = 0;
    double expenses = 0;
    final incomeByType = <TransactionType, double>{};
    final expensesByType = <TransactionType, double>{};

    final filteredTransactions = transactions.where((t) =>
        t.createdAt.isAfter(startDate) &&
        t.createdAt.isBefore(endDate) &&
        t.isCompleted);

    for (final transaction in filteredTransactions) {
      if (transaction.isCredit) {
        income += transaction.amount;
        incomeByType[transaction.type] =
            (incomeByType[transaction.type] ?? 0) + transaction.amount;
      } else if (transaction.isDebit) {
        expenses += transaction.amount;
        expensesByType[transaction.type] =
            (expensesByType[transaction.type] ?? 0) + transaction.amount;
      }
    }

    return TransactionSummary(
      startDate: startDate,
      endDate: endDate,
      totalIncome: income,
      totalExpenses: expenses,
      netAmount: income - expenses,
      incomeByType: incomeByType,
      expensesByType: expensesByType,
      transactionCount: filteredTransactions.length,
    );
  }

  double get savingsRate => totalIncome > 0 ? (netAmount / totalIncome) : 0;
  bool get isPositive => netAmount >= 0;
}

class TransactionFilter {
  final List<TransactionType>? types;
  final TransactionStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? accountId;
  final String? searchQuery;

  TransactionFilter({
    this.types,
    this.status,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.accountId,
    this.searchQuery,
  });

  bool matches(Transaction transaction) {
    if (types != null && !types!.contains(transaction.type)) {
      return false;
    }

    if (status != null && transaction.status != status) {
      return false;
    }

    if (startDate != null && transaction.createdAt.isBefore(startDate!)) {
      return false;
    }

    if (endDate != null && transaction.createdAt.isAfter(endDate!)) {
      return false;
    }

    if (minAmount != null && transaction.amount < minAmount!) {
      return false;
    }

    if (maxAmount != null && transaction.amount > maxAmount!) {
      return false;
    }

    if (accountId != null &&
        transaction.sourceAccountId != accountId &&
        transaction.targetAccountId != accountId) {
      return false;
    }

    if (searchQuery != null &&
        searchQuery!.isNotEmpty &&
        !transaction.description.toLowerCase().contains(searchQuery!.toLowerCase())) {
      return false;
    }

    return true;
  }

  TransactionFilter copyWith({
    List<TransactionType>? types,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? accountId,
    String? searchQuery,
  }) {
    return TransactionFilter(
      types: types ?? this.types,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      accountId: accountId ?? this.accountId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PendingTransaction {
  final String pendingId;
  final Transaction transaction;
  final DateTime scheduledFor;
  final bool requiresApproval;
  final String? approvalBy;

  PendingTransaction({
    required this.pendingId,
    required this.transaction,
    required this.scheduledFor,
    required this.requiresApproval,
    this.approvalBy,
  });

  factory PendingTransaction.fromJson(Map<String, dynamic> json) {
    return PendingTransaction(
      pendingId: json['pendingId'] as String,
      transaction: Transaction.fromJson(json['transaction'] as Map<String, dynamic>),
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
      requiresApproval: json['requiresApproval'] as bool,
      approvalBy: json['approvalBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pendingId': pendingId,
      'transaction': transaction.toJson(),
      'scheduledFor': scheduledFor.toIso8601String(),
      'requiresApproval': requiresApproval,
      'approvalBy': approvalBy,
    };
  }
}