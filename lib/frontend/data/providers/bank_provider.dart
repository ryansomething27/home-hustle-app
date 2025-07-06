import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });

  factory Account.fromMap(Map<String, dynamic> data, String id) {
    return Account(
      id: id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'checking',
      name: data['name'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  final String id;
  final String userId;
  final String type;
  final String name;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'name': name,
      'balance': balance,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
      type: data['type'] ?? 'transfer',
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
  final String type;
  final String description;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'type': type,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Loan model
class Loan {

  Loan({
    required this.id,
    required this.userId,
    required this.amount,
    required this.interestRate,
    required this.termMonths,
    required this.purpose,
    required this.status,
    required this.createdAt,
  });

  factory Loan.fromMap(Map<String, dynamic> data, String id) {
    return Loan(
      id: id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      interestRate: (data['interestRate'] ?? 0).toDouble(),
      termMonths: data['termMonths'] ?? 0,
      purpose: data['purpose'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  final String id;
  final String userId;
  final double amount;
  final double interestRate;
  final int termMonths;
  final String purpose;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'purpose': purpose,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Enum for account types
enum AccountType { checking, savings, investment }

// Bank state model
class BankState {

  const BankState({
    this.accounts = const [],
    this.recentTransactions = const [],
    this.loans = const [],
    this.isLoading = false,
    this.error,
  });
  final List<Account> accounts;
  final List<Transaction> recentTransactions;
  final List<Loan> loans;
  final bool isLoading;
  final String? error;

  BankState copyWith({
    List<Account>? accounts,
    List<Transaction>? recentTransactions,
    List<Loan>? loans,
    bool? isLoading,
    String? error,
  }) {
    return BankState(
      accounts: accounts ?? this.accounts,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      loans: loans ?? this.loans,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Bank state notifier
class BankNotifier extends StateNotifier<BankState> {

  BankNotifier() : super(const BankState()) {
    loadBankData();
  }
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loadBankData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false, 
          error: 'User not authenticated'
        );
        return;
      }

      // Load accounts
      final accountsSnapshot = await _db
          .collection('accounts')
          .where('userId', isEqualTo: user.uid)
          .get();
      
      final accounts = accountsSnapshot.docs
          .map((doc) => Account.fromMap(doc.data(), doc.id))
          .toList();

      // Load recent transactions
      final transactionsSnapshot = await _db
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      
      final transactions = transactionsSnapshot.docs
          .map((doc) => Transaction.fromMap(doc.data(), doc.id))
          .toList();

      // Load loans
      final loansSnapshot = await _db
          .collection('loans')
          .where('userId', isEqualTo: user.uid)
          .get();
      
      final loans = loansSnapshot.docs
          .map((doc) => Loan.fromMap(doc.data(), doc.id))
          .toList();

      state = state.copyWith(
        accounts: accounts,
        recentTransactions: transactions,
        loans: loans,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createAccount(AccountType type, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final newAccount = Account(
        id: '',
        userId: user.uid,
        type: type.toString().split('.').last,
        name: name,
        balance: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _db.collection('accounts').add(newAccount.toMap());
      final createdAccount = Account(
        id: docRef.id,
        userId: newAccount.userId,
        type: newAccount.type,
        name: newAccount.name,
        balance: newAccount.balance,
        createdAt: newAccount.createdAt,
        updatedAt: newAccount.updatedAt,
      );

      state = state.copyWith(
        accounts: [...state.accounts, createdAccount],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> transferFunds({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get accounts
      final fromAccount = state.accounts.firstWhere((a) => a.id == fromAccountId);
      final toAccount = state.accounts.firstWhere((a) => a.id == toAccountId);

      if (fromAccount.balance < amount) {
        throw Exception('Insufficient funds');
      }

      // Create transaction
      final transaction = Transaction(
        id: '',
        userId: user.uid,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        type: 'transfer',
        description: description ?? 'Transfer',
        status: 'completed',
        createdAt: DateTime.now(),
      );

      // Update balances and create transaction in a batch
      final batch = _db.batch();
      
      // Add transaction
      final transactionRef = _db.collection('transactions').doc();
      batch.set(transactionRef, transaction.toMap());
      
      // Update from account balance
      batch.update(_db.collection('accounts').doc(fromAccountId), {
        'balance': fromAccount.balance - amount,
        'updatedAt': Timestamp.now(),
      });
      
      // Update to account balance
      batch.update(_db.collection('accounts').doc(toAccountId), {
        'balance': toAccount.balance + amount,
        'updatedAt': Timestamp.now(),
      });
      
      await batch.commit();

      // Reload data to get updated balances
      await loadBankData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> withdrawRequest({
    required String accountId,
    required double amount,
    String? reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final account = state.accounts.firstWhere((a) => a.id == accountId);
      
      if (account.balance < amount) {
        throw Exception('Insufficient funds');
      }

      // Create withdrawal transaction (needs parent approval)
      final transaction = Transaction(
        id: '',
        userId: user.uid,
        fromAccountId: accountId,
        toAccountId: null,
        amount: amount,
        type: 'withdrawal',
        description: reason ?? 'Withdrawal request',
        status: 'pending', // Needs parent approval
        createdAt: DateTime.now(),
      );

      await _db.collection('transactions').add(transaction.toMap());
      
      // Reload data
      await loadBankData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> applyLoan({
    required double amount,
    required String purpose,
    required int termMonths,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create loan application (needs parent approval)
      final loan = Loan(
        id: '',
        userId: user.uid,
        amount: amount,
        interestRate: 5.0, // Family-friendly interest rate
        termMonths: termMonths,
        purpose: purpose,
        status: 'pending', // Needs parent approval
        createdAt: DateTime.now(),
      );

      await _db.collection('loans').add(loan.toMap());
      
      // Reload data
      await loadBankData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  double getTotalBalance() {
    return state.accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  Account? getAccountById(String id) {
    try {
      return state.accounts.firstWhere((account) => account.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Transaction> getAccountTransactions(String accountId) {
    return state.recentTransactions
        .where((transaction) => 
            transaction.fromAccountId == accountId || 
            transaction.toAccountId == accountId)
        .toList();
  }
}

// Providers
final bankProvider = StateNotifierProvider<BankNotifier, BankState>((ref) {
  return BankNotifier();
});

// Convenience providers
final totalBalanceProvider = Provider<double>((ref) {
  final bankState = ref.watch(bankProvider);
  return bankState.accounts.fold(0.0, (sum, account) => sum + account.balance);
});

final accountProvider = Provider.family<Account?, String>((ref, accountId) {
  final bankState = ref.watch(bankProvider);
  try {
    return bankState.accounts.firstWhere((account) => account.id == accountId);
  } catch (_) {
    return null;
  }
});

final accountTransactionsProvider = Provider.family<List<Transaction>, String>((ref, accountId) {
  final bankState = ref.watch(bankProvider);
  return bankState.recentTransactions
      .where((transaction) => 
          transaction.fromAccountId == accountId || 
          transaction.toAccountId == accountId)
      .toList();
});