import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/account.dart';
import '../models/transaction.dart';

final bankProvider = StateNotifierProvider<BankNotifier, AsyncValue<BankState>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return BankNotifier(apiService);
});

class BankState {
  final List<Account> accounts;
  final List<Transaction> recentTransactions;
  final double totalBalance;
  final Map<String, List<Transaction>> accountTransactions;

  BankState({
    required this.accounts,
    required this.recentTransactions,
    required this.totalBalance,
    required this.accountTransactions,
  });

  BankState copyWith({
    List<Account>? accounts,
    List<Transaction>? recentTransactions,
    double? totalBalance,
    Map<String, List<Transaction>>? accountTransactions,
  }) {
    return BankState(
      accounts: accounts ?? this.accounts,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      totalBalance: totalBalance ?? this.totalBalance,
      accountTransactions: accountTransactions ?? this.accountTransactions,
    );
  }
}

class BankNotifier extends StateNotifier<AsyncValue<BankState>> {
  final ApiService _apiService;

  BankNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    try {
      state = const AsyncValue.loading();
      
      final accounts = await _apiService.getAccounts();
      final transactions = await _apiService.getRecentTransactions();
      
      double total = 0;
      for (var account in accounts) {
        total += account.balance;
      }
      
      final accountTxMap = <String, List<Transaction>>{};
      for (var account in accounts) {
        accountTxMap[account.id] = await _apiService.getAccountTransactions(account.id);
      }
      
      state = AsyncValue.data(BankState(
        accounts: accounts,
        recentTransactions: transactions,
        totalBalance: total,
        accountTransactions: accountTxMap,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> transferFunds({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
  }) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;
      
      state = const AsyncValue.loading();
      
      await _apiService.transferFunds(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
      );
      
      await loadAccounts();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> withdrawRequest({
    required String accountId,
    required double amount,
  }) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;
      
      await _apiService.withdrawRequest(
        accountId: accountId,
        amount: amount,
      );
      
      await loadAccounts();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createAccount({
    required String userId,
    required AccountType type,
    double initialBalance = 0.0,
  }) async {
    try {
      await _apiService.createAccount(
        userId: userId,
        type: type,
        initialBalance: initialBalance,
      );
      
      await loadAccounts();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> applyLoan({
    required String userId,
    required double amount,
  }) async {
    try {
      await _apiService.applyLoan(
        userId: userId,
        amount: amount,
      );
      
      await loadAccounts();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Account? getAccountById(String accountId) {
    final currentState = state.value;
    if (currentState == null) return null;
    
    try {
      return currentState.accounts.firstWhere((account) => account.id == accountId);
    } catch (_) {
      return null;
    }
  }

  List<Transaction> getTransactionsForAccount(String accountId) {
    final currentState = state.value;
    if (currentState == null) return [];
    
    return currentState.accountTransactions[accountId] ?? [];
  }

  double getTotalBalance() {
    final currentState = state.value;
    if (currentState == null) return 0.0;
    
    return currentState.totalBalance;
  }

  Future<void> refreshBalances() async {
    await loadAccounts();
  }
}