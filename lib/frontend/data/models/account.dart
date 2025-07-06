import '../../core/constants.dart';

class Account {
  final String accountId;
  final String userId;
  final AccountType type;
  final double balance;
  final DateTime createdAt;
  final DateTime? lastInterestApplied;
  final bool isActive;
  final double? overdraftLimit;
  final Map<String, dynamic>? metadata;

  Account({
    required this.accountId,
    required this.userId,
    required this.type,
    required this.balance,
    required this.createdAt,
    this.lastInterestApplied,
    this.isActive = true,
    this.overdraftLimit,
    this.metadata,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'] as String,
      userId: json['userId'] as String,
      type: _parseAccountType(json['type'] as String),
      balance: (json['balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastInterestApplied: json['lastInterestApplied'] != null
          ? DateTime.parse(json['lastInterestApplied'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      overdraftLimit: (json['overdraftLimit'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'userId': userId,
      'type': type.toString().split('.').last,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
      'lastInterestApplied': lastInterestApplied?.toIso8601String(),
      'isActive': isActive,
      'overdraftLimit': overdraftLimit,
      'metadata': metadata,
    };
  }

  static AccountType _parseAccountType(String type) {
    switch (type.toLowerCase()) {
      case 'checking':
        return AccountType.checking;
      case 'savings':
        return AccountType.savings;
      case 'investment':
        return AccountType.investment;
      default:
        throw ArgumentError('Invalid account type: $type');
    }
  }

  Account copyWith({
    String? accountId,
    String? userId,
    AccountType? type,
    double? balance,
    DateTime? createdAt,
    DateTime? lastInterestApplied,
    bool? isActive,
    double? overdraftLimit,
    Map<String, dynamic>? metadata,
  }) {
    return Account(
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      lastInterestApplied: lastInterestApplied ?? this.lastInterestApplied,
      isActive: isActive ?? this.isActive,
      overdraftLimit: overdraftLimit ?? this.overdraftLimit,
      metadata: metadata ?? this.metadata,
    );
  }

  // Getters
  bool get isChecking => type == AccountType.checking;
  bool get isSavings => type == AccountType.savings;
  bool get isInvestment => type == AccountType.investment;

  double get interestRate {
    switch (type) {
      case AccountType.savings:
        return FinancialConstants.savingsInterestRate;
      case AccountType.investment:
        return FinancialConstants.investmentInterestRate;
      default:
        return 0.0;
    }
  }

  bool get canGoNegative => type == AccountType.checking && overdraftLimit != null;
  double get availableBalance => canGoNegative ? balance + (overdraftLimit ?? 0) : balance;
  bool get isOverdrawn => balance < 0;

  String get displayName {
    switch (type) {
      case AccountType.checking:
        return 'Checking Account';
      case AccountType.savings:
        return 'Savings Account';
      case AccountType.investment:
        return 'Investment Account';
    }
  }

  String get icon {
    switch (type) {
      case AccountType.checking:
        return '💳';
      case AccountType.savings:
        return '🏦';
      case AccountType.investment:
        return '📈';
    }
  }
}

class Loan {
  final String loanId;
  final String userId;
  final double principal;
  final double currentBalance;
  final double interestRate;
  final DateTime issuedAt;
  final DateTime? dueDate;
  final LoanStatus status;
  final List<LoanPayment> payments;
  final String? linkedAccountId;
  final Map<String, dynamic>? metadata;

  Loan({
    required this.loanId,
    required this.userId,
    required this.principal,
    required this.currentBalance,
    required this.interestRate,
    required this.issuedAt,
    this.dueDate,
    required this.status,
    this.payments = const [],
    this.linkedAccountId,
    this.metadata,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      loanId: json['loanId'] as String,
      userId: json['userId'] as String,
      principal: (json['principal'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      status: _parseLoanStatus(json['status'] as String),
      payments: (json['payments'] as List<dynamic>?)
              ?.map((p) => LoanPayment.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      linkedAccountId: json['linkedAccountId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loanId': loanId,
      'userId': userId,
      'principal': principal,
      'currentBalance': currentBalance,
      'interestRate': interestRate,
      'issuedAt': issuedAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'payments': payments.map((p) => p.toJson()).toList(),
      'linkedAccountId': linkedAccountId,
      'metadata': metadata,
    };
  }

  static LoanStatus _parseLoanStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return LoanStatus.active;
      case 'paid':
        return LoanStatus.paid;
      case 'defaulted':
        return LoanStatus.defaulted;
      default:
        throw ArgumentError('Invalid loan status: $status');
    }
  }

  double get totalPaid => payments.fold(0, (sum, payment) => sum + payment.amount);
  double get remainingBalance => currentBalance;
  double get totalWithInterest => principal + (principal * interestRate);
  bool get isPaidOff => status == LoanStatus.paid;
  bool get isActive => status == LoanStatus.active;
}

enum LoanStatus {
  active,
  paid,
  defaulted,
}

class LoanPayment {
  final String paymentId;
  final String loanId;
  final double amount;
  final DateTime paidAt;
  final String? note;

  LoanPayment({
    required this.paymentId,
    required this.loanId,
    required this.amount,
    required this.paidAt,
    this.note,
  });

  factory LoanPayment.fromJson(Map<String, dynamic> json) {
    return LoanPayment(
      paymentId: json['paymentId'] as String,
      loanId: json['loanId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidAt: DateTime.parse(json['paidAt'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'loanId': loanId,
      'amount': amount,
      'paidAt': paidAt.toIso8601String(),
      'note': note,
    };
  }
}

class AccountSummary {
  final Map<AccountType, Account> accounts;
  final double totalBalance;
  final double totalSavings;
  final double totalInvestments;
  final List<Loan> activeLoans;
  final double totalLoanBalance;

  AccountSummary({
    required this.accounts,
    required this.totalBalance,
    required this.totalSavings,
    required this.totalInvestments,
    required this.activeLoans,
    required this.totalLoanBalance,
  });

  factory AccountSummary.fromAccounts(List<Account> accountList, List<Loan> loans) {
    final accountMap = <AccountType, Account>{};
    double total = 0;
    double savings = 0;
    double investments = 0;

    for (final account in accountList) {
      accountMap[account.type] = account;
      total += account.balance;
      
      if (account.isSavings) {
        savings += account.balance;
      } else if (account.isInvestment) {
        investments += account.balance;
      }
    }

    final activeLoans = loans.where((loan) => loan.isActive).toList();
    final totalLoans = activeLoans.fold<double>(
      0,
      (sum, loan) => sum + loan.currentBalance,
    );

    return AccountSummary(
      accounts: accountMap,
      totalBalance: total,
      totalSavings: savings,
      totalInvestments: investments,
      activeLoans: activeLoans,
      totalLoanBalance: totalLoans,
    );
  }

  double get netWorth => totalBalance - totalLoanBalance;
  bool get hasActiveLoans => activeLoans.isNotEmpty;
  Account? get checkingAccount => accounts[AccountType.checking];
  Account? get savingsAccount => accounts[AccountType.savings];
  Account? get investmentAccount => accounts[AccountType.investment];
}

class WithdrawalRequest {
  final String requestId;
  final String userId;
  final String accountId;
  final double amount;
  final WithdrawalStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String? notes;

  WithdrawalRequest({
    required this.requestId,
    required this.userId,
    required this.accountId,
    required this.amount,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.processedBy,
    this.notes,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      requestId: json['requestId'] as String,
      userId: json['userId'] as String,
      accountId: json['accountId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: _parseWithdrawalStatus(json['status'] as String),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      processedBy: json['processedBy'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'userId': userId,
      'accountId': accountId,
      'amount': amount,
      'status': status.toString().split('.').last,
      'requestedAt': requestedAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'processedBy': processedBy,
      'notes': notes,
    };
  }

  static WithdrawalStatus _parseWithdrawalStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return WithdrawalStatus.pending;
      case 'approved':
        return WithdrawalStatus.approved;
      case 'rejected':
        return WithdrawalStatus.rejected;
      case 'cancelled':
        return WithdrawalStatus.cancelled;
      default:
        throw ArgumentError('Invalid withdrawal status: $status');
    }
  }

  bool get isPending => status == WithdrawalStatus.pending;
  bool get isApproved => status == WithdrawalStatus.approved;
  bool get isProcessed => processedAt != null;
}

enum WithdrawalStatus {
  pending,
  approved,
  rejected,
  cancelled,
}