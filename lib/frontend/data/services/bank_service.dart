import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'auth_service.dart';

class BankService {
  final ApiService _apiService;
  final AuthService _authService;

  BankService({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  // Create a new account for child
  Future<Account> createAccount({
    required String userId,
    required AccountType type,
    double initialBalance = 0.0,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final requestBody = {
      'userId': userId,
      'type': type.name,
      'initialBalance': initialBalance,
    };

    final response = await _apiService.post(
      '/accounts/create',
      body: requestBody,
      token: token,
    );

    return Account.fromJson(response);
  }

  // Get all accounts for a user
  Future<List<Account>> getAccounts({String? userId}) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    final targetUserId = userId ?? currentUser.id;

    final response = await _apiService.get(
      '/accounts?userId=$targetUserId',
      token: token,
    );

    return (response['accounts'] as List)
        .map((json) => Account.fromJson(json))
        .toList();
  }

  // Get account by ID
  Future<Account> getAccountById(String accountId) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/accounts/$accountId',
      token: token,
    );

    return Account.fromJson(response);
  }

  // Transfer funds between accounts
  Future<TransferResult> transferFunds({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? description,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final requestBody = {
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      if (description != null) 'description': description,
    };

    final response = await _apiService.post(
      '/accounts/transfer',
      body: requestBody,
      token: token,
    );

    return TransferResult.fromJson(response);
  }

  // Request withdrawal (child)
  Future<WithdrawalRequest> requestWithdrawal({
    required String accountId,
    required double amount,
    String? reason,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final requestBody = {
      'accountId': accountId,
      'amount': amount,
      if (reason != null) 'reason': reason,
    };

    final response = await _apiService.post(
      '/accounts/withdraw',
      body: requestBody,
      token: token,
    );

    return WithdrawalRequest.fromJson(response);
  }

  // Approve withdrawal request (parent)
  Future<void> approveWithdrawal({
    required String requestId,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    await _apiService.post(
      '/accounts/withdraw/approve',
      body: {
        'requestId': requestId,
      },
      token: token,
    );
  }

  // Reject withdrawal request (parent)
  Future<void> rejectWithdrawal({
    required String requestId,
    String? reason,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    await _apiService.post(
      '/accounts/withdraw/reject',
      body: {
        'requestId': requestId,
        if (reason != null) 'reason': reason,
      },
      token: token,
    );
  }

  // Get withdrawal requests
  Future<List<WithdrawalRequest>> getWithdrawalRequests({
    String? userId,
    WithdrawalStatus? status,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId;
    if (status != null) queryParams['status'] = status.name;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _apiService.get(
      '/accounts/withdrawals${queryString.isNotEmpty ? '?$queryString' : ''}',
      token: token,
    );

    return (response['requests'] as List)
        .map((json) => WithdrawalRequest.fromJson(json))
        .toList();
  }

  // Get transaction history
  Future<List<Transaction>> getTransactions({
    String? accountId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    int? limit,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (accountId != null) queryParams['accountId'] = accountId;
    if (userId != null) queryParams['userId'] = userId;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    if (type != null) queryParams['type'] = type.name;
    if (limit != null) queryParams['limit'] = limit.toString();

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _apiService.get(
      '/accounts/transactions${queryString.isNotEmpty ? '?$queryString' : ''}',
      token: token,
    );

    return (response['transactions'] as List)
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  // Get loan details
  Future<Loan?> getCurrentLoan({String? userId}) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    final targetUserId = userId ?? currentUser.id;

    final response = await _apiService.get(
      '/accounts/loan?userId=$targetUserId',
      token: token,
    );

    if (response['loan'] == null) return null;
    return Loan.fromJson(response['loan']);
  }

  // Request loan (when overdraft)
  Future<Loan> requestLoan({
    required double amount,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    final requestBody = {
      'userId': currentUser.id,
      'amount': amount,
    };

    final response = await _apiService.post(
      '/accounts/loan',
      body: requestBody,
      token: token,
    );

    return Loan.fromJson(response);
  }

  // Make loan payment
  Future<void> makeLoanPayment({
    required String loanId,
    required double amount,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    await _apiService.post(
      '/accounts/loan/payment',
      body: {
        'loanId': loanId,
        'amount': amount,
      },
      token: token,
    );
  }

  // Get account summary for all family members (parent)
  Future<FamilyBankSummary> getFamilyBankSummary() async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/accounts/family-summary',
      token: token,
    );

    return FamilyBankSummary.fromJson(response);
  }

  // Set savings goal
  Future<SavingsGoal> setSavingsGoal({
    required String accountId,
    required String goalName,
    required double targetAmount,
    DateTime? targetDate,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final requestBody = {
      'accountId': accountId,
      'goalName': goalName,
      'targetAmount': targetAmount,
      if (targetDate != null) 'targetDate': targetDate.toIso8601String(),
    };

    final response = await _apiService.post(
      '/accounts/savings-goal',
      body: requestBody,
      token: token,
    );

    return SavingsGoal.fromJson(response);
  }

  // Get account balance
  Future<double> getBalance(String accountId) async {
    final account = await getAccountById(accountId);
    return account.balance;
  }

  // Get total balance across all accounts
  Future<double> getTotalBalance({String? userId}) async {
    final accounts = await getAccounts(userId: userId);
    return accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  // Apply interest (scheduled job, but can be triggered manually for testing)
  Future<void> applyInterest() async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    await _apiService.post(
      '/accounts/apply-interest',
      body: {},
      token: token,
    );
  }
}

// Supporting models for bank-specific data

class TransferResult {
  final String transactionId;
  final double fromBalance;
  final double toBalance;
  final DateTime timestamp;

  TransferResult({
    required this.transactionId,
    required this.fromBalance,
    required this.toBalance,
    required this.timestamp,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      transactionId: json['transactionId'],
      fromBalance: (json['fromBalance'] as num).toDouble(),
      toBalance: (json['toBalance'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class WithdrawalRequest {
  final String id;
  final String userId;
  final String accountId;
  final double amount;
  final String? reason;
  final WithdrawalStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String? rejectionReason;

  WithdrawalRequest({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.amount,
    this.reason,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.processedBy,
    this.rejectionReason,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'] ?? json['requestId'],
      userId: json['userId'],
      accountId: json['accountId'],
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'],
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WithdrawalStatus.pending,
      ),
      requestedAt: DateTime.parse(json['requestedAt']),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      processedBy: json['processedBy'],
      rejectionReason: json['rejectionReason'],
    );
  }
}

class Loan {
  final String id;
  final String userId;
  final double principal;
  final double balance;
  final double interestRate;
  final DateTime issuedAt;
  final DateTime? paidOffAt;
  final List<LoanPayment> payments;

  Loan({
    required this.id,
    required this.userId,
    required this.principal,
    required this.balance,
    required this.interestRate,
    required this.issuedAt,
    this.paidOffAt,
    required this.payments,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] ?? json['loanId'],
      userId: json['userId'],
      principal: (json['principal'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      issuedAt: DateTime.parse(json['issuedAt']),
      paidOffAt: json['paidOffAt'] != null
          ? DateTime.parse(json['paidOffAt'])
          : null,
      payments: (json['payments'] as List? ?? [])
          .map((p) => LoanPayment.fromJson(p))
          .toList(),
    );
  }
}

class LoanPayment {
  final String id;
  final double amount;
  final DateTime paymentDate;

  LoanPayment({
    required this.id,
    required this.amount,
    required this.paymentDate,
  });

  factory LoanPayment.fromJson(Map<String, dynamic> json) {
    return LoanPayment(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
    );
  }
}

class FamilyBankSummary {
  final double totalFamilyBalance;
  final List<ChildBankSummary> childrenSummaries;
  final int pendingWithdrawals;
  final double totalLoansOutstanding;

  FamilyBankSummary({
    required this.totalFamilyBalance,
    required this.childrenSummaries,
    required this.pendingWithdrawals,
    required this.totalLoansOutstanding,
  });

  factory FamilyBankSummary.fromJson(Map<String, dynamic> json) {
    return FamilyBankSummary(
      totalFamilyBalance: (json['totalFamilyBalance'] as num).toDouble(),
      childrenSummaries: (json['childrenSummaries'] as List)
          .map((s) => ChildBankSummary.fromJson(s))
          .toList(),
      pendingWithdrawals: json['pendingWithdrawals'],
      totalLoansOutstanding: (json['totalLoansOutstanding'] as num).toDouble(),
    );
  }
}

class ChildBankSummary {
  final String childId;
  final String childName;
  final double totalBalance;
  final Map<AccountType, double> accountBalances;
  final bool hasLoan;
  final double? loanBalance;

  ChildBankSummary({
    required this.childId,
    required this.childName,
    required this.totalBalance,
    required this.accountBalances,
    required this.hasLoan,
    this.loanBalance,
  });

  factory ChildBankSummary.fromJson(Map<String, dynamic> json) {
    final balances = <AccountType, double>{};
    (json['accountBalances'] as Map<String, dynamic>).forEach((key, value) {
      final accountType = AccountType.values.firstWhere(
        (e) => e.name == key,
        orElse: () => AccountType.checking,
      );
      balances[accountType] = (value as num).toDouble();
    });

    return ChildBankSummary(
      childId: json['childId'],
      childName: json['childName'],
      totalBalance: (json['totalBalance'] as num).toDouble(),
      accountBalances: balances,
      hasLoan: json['hasLoan'],
      loanBalance: json['loanBalance'] != null
          ? (json['loanBalance'] as num).toDouble()
          : null,
    );
  }
}

class SavingsGoal {
  final String id;
  final String accountId;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final DateTime createdAt;
  final bool isAchieved;

  SavingsGoal({
    required this.id,
    required this.accountId,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    required this.createdAt,
    required this.isAchieved,
  });

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'],
      accountId: json['accountId'],
      goalName: json['goalName'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      isAchieved: json['isAchieved'] ?? false,
    );
  }

  double get progressPercentage => (currentAmount / targetAmount * 100).clamp(0, 100);
}

enum WithdrawalStatus { pending, approved, rejected, cancelled }