// frontend/data/providers/bank_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../models/transaction.dart';
import '../services/bank_service.dart';

// Bank service provider
final bankServiceProvider = Provider<BankService>((ref) {
  return BankService.instance;
});

// Bank state class
class BankState {

  const BankState({
    this.accounts = const [],
    this.transactions = const [],
    this.accountTransactions = const {},
    this.accountSavingsGoals = const {},
    this.pendingMoneyRequests = const [],
    this.selectedAccount,
    this.transactionSummary,
    this.isLoading = false,
    this.error,
  });
  final List<AccountModel> accounts;
  final List<TransactionModel> transactions;
  final Map<String, List<TransactionModel>> accountTransactions;
  final Map<String, List<SavingsGoal>> accountSavingsGoals;
  final List<TransactionModel> pendingMoneyRequests;
  final AccountModel? selectedAccount;
  final TransactionSummary? transactionSummary;
  final bool isLoading;
  final String? error;

  AccountModel? get defaultAccount {
    for (final account in accounts) {
      if (account.isDefault) {
        return account;
      }
    }
    return accounts.isNotEmpty ? accounts.first : null;
  }

  double get totalBalance => accounts.fold(
        0.0,
        (sum, account) => sum + account.balance,
      );

  double get totalAvailableBalance => accounts.fold(
        0.0,
        (sum, account) => sum + account.availableBalance,
      );

  BankState copyWith({
    List<AccountModel>? accounts,
    List<TransactionModel>? transactions,
    Map<String, List<TransactionModel>>? accountTransactions,
    Map<String, List<SavingsGoal>>? accountSavingsGoals,
    List<TransactionModel>? pendingMoneyRequests,
    AccountModel? selectedAccount,
    TransactionSummary? transactionSummary,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSelectedAccount = false,
    bool clearTransactionSummary = false,
  }) {
    return BankState(
      accounts: accounts ?? this.accounts,
      transactions: transactions ?? this.transactions,
      accountTransactions: accountTransactions ?? this.accountTransactions,
      accountSavingsGoals: accountSavingsGoals ?? this.accountSavingsGoals,
      pendingMoneyRequests: pendingMoneyRequests ?? this.pendingMoneyRequests,
      selectedAccount: clearSelectedAccount ? null : (selectedAccount ?? this.selectedAccount),
      transactionSummary: clearTransactionSummary ? null : (transactionSummary ?? this.transactionSummary),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Bank notifier
class BankNotifier extends StateNotifier<BankState> {

  BankNotifier(this._bankService) : super(const BankState());
  final BankService _bankService;

  // Create a new account
  Future<AccountModel> createAccount({
    required String accountType,
    required String accountName,
    String? parentAccountId,
    double initialBalance = 0.0,
    bool isDefault = false,
    AccountLimits? limits,
    String? iconName,
    String? color,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final account = await _bankService.createAccount(
        accountType: accountType,
        accountName: accountName,
        parentAccountId: parentAccountId,
        initialBalance: initialBalance,
        isDefault: isDefault,
        limits: limits,
        iconName: iconName,
        color: color,
      );

      // Add to accounts list
      state = state.copyWith(
        accounts: [...state.accounts, account],
        isLoading: false,
      );

      return account;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load user accounts
  Future<void> loadAccounts({
    String? accountType,
    String? status,
    bool includeShared = true,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final accounts = await _bankService.getMyAccounts(
        accountType: accountType,
        status: status,
        includeShared: includeShared,
      );

      state = state.copyWith(
        accounts: accounts,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load a specific account
  Future<void> loadAccount(String accountId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final account = await _bankService.getAccount(accountId);
      
      state = state.copyWith(
        selectedAccount: account,
        accounts: _updateAccountInList(state.accounts, account),
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update account
  Future<AccountModel> updateAccount({
    required String accountId,
    String? accountName,
    String? status,
    AccountLimits? limits,
    String? iconName,
    String? color,
    List<String>? tags,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedAccount = await _bankService.updateAccount(
        accountId: accountId,
        accountName: accountName,
        status: status,
        limits: limits,
        iconName: iconName,
        color: color,
        tags: tags,
      );

      state = state.copyWith(
        accounts: _updateAccountInList(state.accounts, updatedAccount),
        selectedAccount: state.selectedAccount?.id == accountId ? updatedAccount : state.selectedAccount,
        isLoading: false,
      );

      return updatedAccount;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Deposit funds
  Future<TransactionModel> deposit({
    required String accountId,
    required double amount,
    required String description,
    String? referenceType,
    String? referenceId,
    String? categoryId,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final transaction = await _bankService.deposit(
        accountId: accountId,
        amount: amount,
        description: description,
        referenceType: referenceType,
        referenceId: referenceId,
        categoryId: categoryId,
        notes: notes,
      );

      // Reload account to get updated balance
      await loadAccount(accountId);

      // Add transaction to list
      state = state.copyWith(
        transactions: [transaction, ...state.transactions],
        isLoading: false,
      );

      return transaction;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Withdraw funds
  Future<TransactionModel> withdraw({
    required String accountId,
    required double amount,
    required String description,
    String? referenceType,
    String? referenceId,
    String? categoryId,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final transaction = await _bankService.withdraw(
        accountId: accountId,
        amount: amount,
        description: description,
        referenceType: referenceType,
        referenceId: referenceId,
        categoryId: categoryId,
        notes: notes,
      );

      // Reload account to get updated balance
      await loadAccount(accountId);

      // Add transaction to list
      state = state.copyWith(
        transactions: [transaction, ...state.transactions],
        isLoading: false,
      );

      return transaction;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Transfer funds
  Future<TransactionModel> transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String description,
    String? categoryId,
    String? notes,
    bool isRecurring = false,
    String? recurringSchedule,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final transaction = await _bankService.transfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        description: description,
        categoryId: categoryId,
        notes: notes,
        isRecurring: isRecurring,
        recurringSchedule: recurringSchedule,
      );

      // Reload both accounts
      await loadAccount(fromAccountId);
      await loadAccount(toAccountId);

      // Add transaction to list
      state = state.copyWith(
        transactions: [transaction, ...state.transactions],
        isLoading: false,
      );

      return transaction;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load transaction history for an account
  Future<void> loadAccountTransactions({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final transactions = await _bankService.getTransactionHistory(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
        type: type,
        status: status,
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        accountTransactions: {
          ...state.accountTransactions,
          accountId: transactions,
        },
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load all user transactions
  Future<void> loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? status,
    String? accountId,
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final transactions = await _bankService.getMyTransactions(
        startDate: startDate,
        endDate: endDate,
        type: type,
        status: status,
        accountId: accountId,
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load transaction summary
  Future<void> loadTransactionSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? accountId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final summary = await _bankService.getTransactionSummary(
        startDate: startDate,
        endDate: endDate,
        accountId: accountId,
      );

      state = state.copyWith(
        transactionSummary: summary,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Create savings goal
  Future<SavingsGoal> createSavingsGoal({
    required String accountId,
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    String? description,
    String? imageUrl,
    String? category,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final goal = await _bankService.createSavingsGoal(
        accountId: accountId,
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
        description: description,
        imageUrl: imageUrl,
        category: category,
      );

      // Add to goals list
      final goals = state.accountSavingsGoals[accountId] ?? [];
      state = state.copyWith(
        accountSavingsGoals: {
          ...state.accountSavingsGoals,
          accountId: [...goals, goal],
        },
        isLoading: false,
      );

      return goal;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load savings goals for an account
  Future<void> loadSavingsGoals(String accountId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final goals = await _bankService.getSavingsGoals(accountId);

      state = state.copyWith(
        accountSavingsGoals: {
          ...state.accountSavingsGoals,
          accountId: goals,
        },
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update savings goal progress
  Future<SavingsGoal> updateSavingsGoalProgress({
    required String accountId,
    required String goalId,
    required double amount,
    bool isContribution = true,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedGoal = await _bankService.updateSavingsGoalProgress(
        accountId: accountId,
        goalId: goalId,
        amount: amount,
        isContribution: isContribution,
      );

      // Update goal in list
      final goals = state.accountSavingsGoals[accountId] ?? [];
      final updatedGoals = goals.map((goal) {
        return goal.id == goalId ? updatedGoal : goal;
      }).toList();

      state = state.copyWith(
        accountSavingsGoals: {
          ...state.accountSavingsGoals,
          accountId: updatedGoals,
        },
        isLoading: false,
      );

      return updatedGoal;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Set default account
  Future<void> setDefaultAccount(String accountId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updatedAccount = await _bankService.setDefaultAccount(accountId);

      // Update all accounts
      final updatedAccounts = state.accounts.map((account) {
        if (account.id == accountId) {
          return updatedAccount;
        } else if (account.isDefault) {
          return account.copyWith(isDefault: false);
        }
        return account;
      }).toList();

      state = state.copyWith(
        accounts: updatedAccounts,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Request money (children only)
  Future<TransactionModel> requestMoney({
    required String fromParentAccountId,
    required double amount,
    required String reason,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final transaction = await _bankService.requestMoney(
        fromParentAccountId: fromParentAccountId,
        amount: amount,
        reason: reason,
        notes: notes,
      );

      // Add to transactions
      state = state.copyWith(
        transactions: [transaction, ...state.transactions],
        isLoading: false,
      );

      return transaction;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Load pending money requests
  Future<void> loadPendingMoneyRequests() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final requests = await _bankService.getPendingMoneyRequests();

      state = state.copyWith(
        pendingMoneyRequests: requests,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Respond to money request
  Future<void> respondToMoneyRequest({
    required String transactionId,
    required bool approve,
    String? reason,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _bankService.respondToMoneyRequest(
        transactionId: transactionId,
        approve: approve,
        reason: reason,
      );

      // Reload pending requests and transactions
      await loadPendingMoneyRequests();
      await loadTransactions();

      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Clear selected account
  void clearSelectedAccount() {
    state = state.copyWith(clearSelectedAccount: true);
  }

  // Clear transaction summary
  void clearTransactionSummary() {
    state = state.copyWith(clearTransactionSummary: true);
  }

  // Helper method to update account in list
  List<AccountModel> _updateAccountInList(List<AccountModel> accounts, AccountModel updatedAccount) {
    return accounts.map((account) => 
      account.id == updatedAccount.id ? updatedAccount : account
    ).toList();
  }
}

// Main bank provider
final bankProvider = StateNotifierProvider<BankNotifier, BankState>((ref) {
  final bankService = ref.watch(bankServiceProvider);
  return BankNotifier(bankService);
});

// Convenience providers
final accountsProvider = Provider<List<AccountModel>>((ref) {
  return ref.watch(bankProvider).accounts;
});

final defaultAccountProvider = Provider<AccountModel?>((ref) {
  return ref.watch(bankProvider).defaultAccount;
});

final totalBalanceProvider = Provider<double>((ref) {
  return ref.watch(bankProvider).totalBalance;
});

final totalAvailableBalanceProvider = Provider<double>((ref) {
  return ref.watch(bankProvider).totalAvailableBalance;
});

final selectedAccountProvider = Provider<AccountModel?>((ref) {
  return ref.watch(bankProvider).selectedAccount;
});

final transactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(bankProvider).transactions;
});

final transactionSummaryProvider = Provider<TransactionSummary?>((ref) {
  return ref.watch(bankProvider).transactionSummary;
});

final pendingMoneyRequestsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(bankProvider).pendingMoneyRequests;
});

final isBankLoadingProvider = Provider<bool>((ref) {
  return ref.watch(bankProvider).isLoading;
});

final bankErrorProvider = Provider<String?>((ref) {
  return ref.watch(bankProvider).error;
});

// Account transactions by ID
final accountTransactionsProvider = Provider.family<List<TransactionModel>?, String>((ref, accountId) {
  return ref.watch(bankProvider).accountTransactions[accountId];
});

// Savings goals by account ID
final accountSavingsGoalsProvider = Provider.family<List<SavingsGoal>?, String>((ref, accountId) {
  return ref.watch(bankProvider).accountSavingsGoals[accountId];
});

// Primary account (convenience provider)
final primaryAccountProvider = Provider<AccountModel?>((ref) {
  final accounts = ref.watch(accountsProvider);
  for (final account in accounts) {
    if (account.accountType == 'primary') {
      return account;
    }
  }
  return null;
});

// Savings accounts
final savingsAccountsProvider = Provider<List<AccountModel>>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.where((account) => account.accountType == 'savings').toList();
});

// Recent transactions (last 10)
final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.take(10).toList();
});

// Usage Examples:
/*
// In a widget:
class AccountsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    
    return Column(
      children: [
        Text('Total Balance: \${totalBalance.toStringAsFixed(2)}'),
        Expanded(
          child: ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              return AccountTile(account: accounts[index]);
            },
          ),
        ),
      ],
    );
  }
}

// Create an account:
await ref.read(bankProvider.notifier).createAccount(
  accountType: 'savings',
  accountName: 'Vacation Fund',
  initialBalance: 100.0,
);

// Make a deposit:
await ref.read(bankProvider.notifier).deposit(
  accountId: accountId,
  amount: 50.0,
  description: 'Birthday money',
);

// Request money (child):
await ref.read(bankProvider.notifier).requestMoney(
  fromParentAccountId: parentAccountId,
  amount: 20.0,
  reason: 'Movie tickets',
);
*/