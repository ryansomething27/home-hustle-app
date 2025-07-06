import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enums
enum AccountType { checking, savings, investment }
enum TransactionType { deposit, withdrawal, transfer, interest, fee, jobPayment }
enum WithdrawalStatus { pending, approved, rejected, cancelled }

// Account model
class Account {

  Account({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
    this.savingsGoal,
  });

  factory Account.fromMap(Map<String, dynamic> data, String id) {
    return Account(
      id: id,
      userId: data['userId'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.toString() == 'AccountType.${data['type']}',
        orElse: () => AccountType.checking,
      ),
      name: data['name'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      savingsGoal: data['savingsGoal'] != null
          ? SavingsGoal.fromMap(data['savingsGoal'])
          : null,
    );
  }
  final String id;
  final String userId;
  final AccountType type;
  final String name;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SavingsGoal? savingsGoal;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'name': name,
      'balance': balance,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (savingsGoal != null) 'savingsGoal': savingsGoal!.toMap(),
    };
  }
}

// Transaction model
class Transaction {

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.status,
    required this.createdAt,
    this.fromAccountId,
    this.toAccountId,
  });

  factory Transaction.fromMap(Map<String, dynamic> data, String id) {
    return Transaction(
      id: id,
      userId: data['userId'] ?? '',
      fromAccountId: data['fromAccountId'],
      toAccountId: data['toAccountId'],
      amount: (data['amount'] ?? 0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${data['type']}',
        orElse: () => TransactionType.transfer,
      ),
      description: data['description'] ?? '',
      status: data['status'] ?? 'completed',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  final String id;
  final String userId;
  final String? fromAccountId;
  final String? toAccountId;
  final double amount;
  final TransactionType type;
  final String description;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Supporting models
class TransferResult {

  TransferResult({
    required this.transactionId,
    required this.fromBalance,
    required this.toBalance,
    required this.timestamp,
  });
  final String transactionId;
  final double fromBalance;
  final double toBalance;
  final DateTime timestamp;
}

class WithdrawalRequest {

  WithdrawalRequest({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.amount,
    required this.status, required this.requestedAt, this.reason,
    this.processedAt,
    this.processedBy,
    this.rejectionReason,
  });

  factory WithdrawalRequest.fromMap(Map<String, dynamic> data, String id) {
    return WithdrawalRequest(
      id: id,
      userId: data['userId'] ?? '',
      accountId: data['accountId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      reason: data['reason'],
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.toString() == 'WithdrawalStatus.${data['status']}',
        orElse: () => WithdrawalStatus.pending,
      ),
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      processedAt: data['processedAt'] != null
          ? (data['processedAt'] as Timestamp).toDate()
          : null,
      processedBy: data['processedBy'],
      rejectionReason: data['rejectionReason'],
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'accountId': accountId,
      'amount': amount,
      'reason': reason,
      'status': status.toString().split('.').last,
      'requestedAt': Timestamp.fromDate(requestedAt),
      if (processedAt != null) 'processedAt': Timestamp.fromDate(processedAt!),
      if (processedBy != null) 'processedBy': processedBy,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }
}

class Loan {

  Loan({
    required this.id,
    required this.userId,
    required this.principal,
    required this.balance,
    required this.interestRate,
    required this.issuedAt,
    required this.payments, this.paidOffAt,
  });

  factory Loan.fromMap(Map<String, dynamic> data, String id) {
    return Loan(
      id: id,
      userId: data['userId'] ?? '',
      principal: (data['principal'] ?? 0).toDouble(),
      balance: (data['balance'] ?? 0).toDouble(),
      interestRate: (data['interestRate'] ?? 0).toDouble(),
      issuedAt: (data['issuedAt'] as Timestamp).toDate(),
      paidOffAt: data['paidOffAt'] != null
          ? (data['paidOffAt'] as Timestamp).toDate()
          : null,
      payments: (data['payments'] as List<dynamic>? ?? [])
          .map((p) => LoanPayment.fromMap(p))
          .toList(),
    );
  }
  final String id;
  final String userId;
  final double principal;
  final double balance;
  final double interestRate;
  final DateTime issuedAt;
  final DateTime? paidOffAt;
  final List<LoanPayment> payments;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'principal': principal,
      'balance': balance,
      'interestRate': interestRate,
      'issuedAt': Timestamp.fromDate(issuedAt),
      if (paidOffAt != null) 'paidOffAt': Timestamp.fromDate(paidOffAt!),
      'payments': payments.map((p) => p.toMap()).toList(),
    };
  }
}

class LoanPayment {

  LoanPayment({
    required this.id,
    required this.amount,
    required this.paymentDate,
  });

  factory LoanPayment.fromMap(Map<String, dynamic> data) {
    return LoanPayment(
      id: data['id'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentDate: (data['paymentDate'] as Timestamp).toDate(),
    );
  }
  final String id;
  final double amount;
  final DateTime paymentDate;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
    };
  }
}

class SavingsGoal {

  SavingsGoal({
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt, required this.isAchieved, this.targetDate,
  });

  factory SavingsGoal.fromMap(Map<String, dynamic> data) {
    return SavingsGoal(
      goalName: data['goalName'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      targetDate: data['targetDate'] != null
          ? (data['targetDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAchieved: data['isAchieved'] ?? false,
    );
  }
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final DateTime createdAt;
  final bool isAchieved;

  Map<String, dynamic> toMap() {
    return {
      'goalName': goalName,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      if (targetDate != null) 'targetDate': Timestamp.fromDate(targetDate!),
      'createdAt': Timestamp.fromDate(createdAt),
      'isAchieved': isAchieved,
    };
  }

  double get progressPercentage => (currentAmount / targetAmount * 100).clamp(0, 100);
}

class FamilyBankSummary {

  FamilyBankSummary({
    required this.totalFamilyBalance,
    required this.childrenSummaries,
    required this.pendingWithdrawals,
    required this.totalLoansOutstanding,
  });
  final double totalFamilyBalance;
  final List<ChildBankSummary> childrenSummaries;
  final int pendingWithdrawals;
  final double totalLoansOutstanding;
}

class ChildBankSummary {

  ChildBankSummary({
    required this.childId,
    required this.childName,
    required this.totalBalance,
    required this.accountBalances,
    required this.hasLoan,
    this.loanBalance,
  });
  final String childId;
  final String childName;
  final double totalBalance;
  final Map<AccountType, double> accountBalances;
  final bool hasLoan;
  final double? loanBalance;
}

// Bank Service
class BankService {

  BankService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new account for child
  Future<Account> createAccount({
    required String userId,
    required AccountType type,
    double initialBalance = 0.0,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    final account = Account(
      id: '',
      userId: userId,
      type: type,
      name: '${type.toString().split('.').last.capitalize()} Account',
      balance: initialBalance,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final docRef = await _db.collection('accounts').add(account.toMap());
    
    return Account(
      id: docRef.id,
      userId: account.userId,
      type: account.type,
      name: account.name,
      balance: account.balance,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
  }

  // Get all accounts for a user
  Future<List<Account>> getAccounts({String? userId}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    final targetUserId = userId ?? user.uid;

    final snapshot = await _db
        .collection('accounts')
        .where('userId', isEqualTo: targetUserId)
        .get();

    return snapshot.docs
        .map((doc) => Account.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get account by ID
  Future<Account> getAccountById(String accountId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    final doc = await _db.collection('accounts').doc(accountId).get();
    if (!doc.exists) {
      throw Exception('Account not found');
    }

    return Account.fromMap(doc.data()!, doc.id);
  }

  // Transfer funds between accounts
  Future<TransferResult> transferFunds({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    // Get accounts
    final fromDoc = await _db.collection('accounts').doc(fromAccountId).get();
    final toDoc = await _db.collection('accounts').doc(toAccountId).get();

    if (!fromDoc.exists || !toDoc.exists) {
      throw Exception('Account not found');
    }

    final fromAccount = Account.fromMap(fromDoc.data()!, fromDoc.id);
    final toAccount = Account.fromMap(toDoc.data()!, toDoc.id);

    if (fromAccount.balance < amount) {
      throw Exception('Insufficient funds');
    }

    // Create transaction record
    final transaction = Transaction(
      id: '',
      userId: user.uid,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      type: TransactionType.transfer,
      description: description ?? 'Transfer',
      status: 'completed',
      createdAt: DateTime.now(),
    );

    // Perform transfer in a batch
    final batch = _db.batch();
    
    // Add transaction
    final transactionRef = _db.collection('transactions').doc();
    batch.set(transactionRef, transaction.toMap());
    
    // Update from account
    batch.update(fromDoc.reference, {
      'balance': fromAccount.balance - amount,
      'updatedAt': Timestamp.now(),
    });
    
    // Update to account
    batch.update(toDoc.reference, {
      'balance': toAccount.balance + amount,
      'updatedAt': Timestamp.now(),
    });

    await batch.commit();

    return TransferResult(
      transactionId: transactionRef.id,
      fromBalance: fromAccount.balance - amount,
      toBalance: toAccount.balance + amount,
      timestamp: DateTime.now(),
    );
  }

  // Request withdrawal (child)
  Future<WithdrawalRequest> requestWithdrawal({
    required String accountId,
    required double amount,
    String? reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    // Check account balance
    final account = await getAccountById(accountId);
    if (account.balance < amount) {
      throw Exception('Insufficient funds');
    }

    final request = WithdrawalRequest(
      id: '',
      userId: user.uid,
      accountId: accountId,
      amount: amount,
      reason: reason,
      status: WithdrawalStatus.pending,
      requestedAt: DateTime.now(),
    );

    final docRef = await _db.collection('withdrawalRequests').add(request.toMap());

    // Notify parent
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final parentId = userDoc.data()?['parentId'];
    
    if (parentId != null) {
      await _db.collection('notifications').add({
        'userId': parentId,
        'title': 'Withdrawal Request',
        'body': '${userDoc.data()?['name'] ?? 'Your child'} requested \$$amount withdrawal',
        'type': 'withdrawalRequest',
        'data': {'requestId': docRef.id},
        'isRead': false,
        'createdAt': Timestamp.now(),
      });
    }

    return WithdrawalRequest(
      id: docRef.id,
      userId: request.userId,
      accountId: request.accountId,
      amount: request.amount,
      reason: request.reason,
      status: request.status,
      requestedAt: request.requestedAt,
    );
  }

  // Approve withdrawal request (parent)
  Future<void> approveWithdrawal({
    required String requestId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    final requestDoc = await _db.collection('withdrawalRequests').doc(requestId).get();
    if (!requestDoc.exists) {
      throw Exception('Request not found');
    }

    final request = WithdrawalRequest.fromMap(requestDoc.data()!, requestDoc.id);
    
    // Get account and check balance
    final account = await getAccountById(request.accountId);
    if (account.balance < request.amount) {
      throw Exception('Insufficient funds');
    }

    // Update request and account in a batch
    final batch = _db.batch();
    
    // Update request
    batch.update(requestDoc.reference, {
      'status': 'approved',
      'processedAt': Timestamp.now(),
      'processedBy': user.uid,
    });
    
    // Update account balance
    batch.update(_db.collection('accounts').doc(request.accountId), {
      'balance': account.balance - request.amount,
      'updatedAt': Timestamp.now(),
    });
    
    // Create transaction record
    final transactionRef = _db.collection('transactions').doc();
    batch.set(transactionRef, {
      'userId': request.userId,
      'fromAccountId': request.accountId,
      'amount': request.amount,
      'type': 'withdrawal',
      'description': 'Withdrawal: ${request.reason ?? 'Cash withdrawal'}',
      'status': 'completed',
      'createdAt': Timestamp.now(),
    });

    await batch.commit();
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
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    Query query = _db.collection('transactions');
    
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    } else if (accountId != null) {
      query = query.where('fromAccountId', isEqualTo: accountId);
    }
    
    if (type != null) {
      query = query.where('type', isEqualTo: type.toString().split('.').last);
    }
    
    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    query = query.orderBy('createdAt', descending: true);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Get total balance across all accounts
  Future<double> getTotalBalance({String? userId}) async {
    final accounts = await getAccounts(userId: userId);
    double total = 0.0;
    for (final account in accounts) {
      total += account.balance;
    }
    return total;
  }

  // Set savings goal
  Future<void> setSavingsGoal({
    required String accountId,
    required String goalName,
    required double targetAmount,
    DateTime? targetDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    final goal = SavingsGoal(
      goalName: goalName,
      targetAmount: targetAmount,
      currentAmount: 0,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      isAchieved: false,
    );

    await _db.collection('accounts').doc(accountId).update({
      'savingsGoal': goal.toMap(),
      'updatedAt': Timestamp.now(),
    });
  }
}

// Extension helper
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}