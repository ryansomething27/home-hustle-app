import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Manages state for user accounts, balances, transfers, and withdrawal requests
class BankService {
  
  BankService._internal();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  /// Singleton instance
  static final BankService _instance = BankService._internal();
  static BankService get instance => _instance;
  
  /// Create a new account
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
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }
      
      final response = await _apiService.post(
        '/accounts/create',
        data: {
          'accountType': accountType,
          'accountName': accountName,
          'parentAccountId': parentAccountId,
          'initialBalance': initialBalance,
          'isDefault': isDefault,
          'limits': limits?.toMap(),
          'iconName': iconName,
          'color': color,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return AccountModel.fromMap(responseData['account']);
    } catch (e) {
      debugPrint('Error creating account: $e');
      rethrow;
    }
  }
  
  /// Get all accounts for the current user
  Future<List<AccountModel>> getMyAccounts({
    String? accountType,
    String? status,
    bool includeShared = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (accountType != null) {
        queryParams['accountType'] = accountType;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      queryParams['includeShared'] = includeShared;
      
      final response = await _apiService.get(
        '/accounts/my-accounts',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['accounts'] as List)
          .map((account) => AccountModel.fromMap(account))
          .toList();
    } catch (e) {
      debugPrint('Error getting accounts: $e');
      rethrow;
    }
  }
  
  /// Get a single account by ID
  Future<AccountModel> getAccount(String accountId) async {
    try {
      final response = await _apiService.get('/accounts/$accountId');
      
      final responseData = response.data as Map<String, dynamic>;
      return AccountModel.fromMap(responseData['account']);
    } catch (e) {
      debugPrint('Error getting account: $e');
      rethrow;
    }
  }
  
  /// Update account details
  Future<AccountModel> updateAccount({
    required String accountId,
    String? accountName,
    String? status,
    AccountLimits? limits,
    String? iconName,
    String? color,
    List<String>? tags,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (accountName != null) {
        updates['accountName'] = accountName;
      }
      if (status != null) {
        updates['status'] = status;
      }
      if (limits != null) {
        updates['limits'] = limits.toMap();
      }
      if (iconName != null) {
        updates['iconName'] = iconName;
      }
      if (color != null) {
        updates['color'] = color;
      }
      if (tags != null) {
        updates['tags'] = tags;
      }
      
      final response = await _apiService.put(
        '/accounts/$accountId',
        data: updates,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return AccountModel.fromMap(responseData['account']);
    } catch (e) {
      debugPrint('Error updating account: $e');
      rethrow;
    }
  }
  
  /// Get account balance
  Future<double> getAccountBalance(String accountId) async {
    try {
      final account = await getAccount(accountId);
      return account.balance;
    } catch (e) {
      debugPrint('Error getting account balance: $e');
      rethrow;
    }
  }
  
  /// Deposit funds to an account
  Future<TransactionModel> deposit({
    required String accountId,
    required double amount,
    required String description,
    String? referenceType,
    String? referenceId,
    String? categoryId,
    String? notes,
  }) async {
    try {
      if (amount <= 0) {
        throw Exception('Deposit amount must be greater than zero');
      }
      
      final response = await _apiService.post(
        '/accounts/$accountId/deposit',
        data: {
          'amount': amount,
          'description': description,
          'referenceType': referenceType,
          'referenceId': referenceId,
          'categoryId': categoryId,
          'notes': notes,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return TransactionModel.fromMap(responseData['transaction']);
    } catch (e) {
      debugPrint('Error depositing funds: $e');
      rethrow;
    }
  }
  
  /// Withdraw funds from an account
  Future<TransactionModel> withdraw({
    required String accountId,
    required double amount,
    required String description,
    String? referenceType,
    String? referenceId,
    String? categoryId,
    String? notes,
  }) async {
    try {
      if (amount <= 0) {
        throw Exception('Withdrawal amount must be greater than zero');
      }
      
      // Check if account can withdraw this amount
      final account = await getAccount(accountId);
      if (!account.canWithdraw(amount)) {
        throw Exception('Insufficient funds or withdrawal limit exceeded');
      }
      
      final response = await _apiService.post(
        '/accounts/$accountId/withdraw',
        data: {
          'amount': amount,
          'description': description,
          'referenceType': referenceType,
          'referenceId': referenceId,
          'categoryId': categoryId,
          'notes': notes,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return TransactionModel.fromMap(responseData['transaction']);
    } catch (e) {
      debugPrint('Error withdrawing funds: $e');
      rethrow;
    }
  }
  
  /// Transfer funds between accounts
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
    try {
      if (amount <= 0) {
        throw Exception('Transfer amount must be greater than zero');
      }
      
      if (fromAccountId == toAccountId) {
        throw Exception('Cannot transfer to the same account');
      }
      
      final response = await _apiService.post(
        '/accounts/transfer',
        data: {
          'fromAccountId': fromAccountId,
          'toAccountId': toAccountId,
          'amount': amount,
          'description': description,
          'categoryId': categoryId,
          'notes': notes,
          'isRecurring': isRecurring,
          'recurringSchedule': recurringSchedule,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return TransactionModel.fromMap(responseData['transaction']);
    } catch (e) {
      debugPrint('Error transferring funds: $e');
      rethrow;
    }
  }
  
  /// Get transaction history for an account
  Future<List<TransactionModel>> getTransactionHistory({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (type != null) {
        queryParams['type'] = type;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      
      final response = await _apiService.get(
        '/accounts/$accountId/transactions',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['transactions'] as List)
          .map((transaction) => TransactionModel.fromMap(transaction))
          .toList();
    } catch (e) {
      debugPrint('Error getting transaction history: $e');
      rethrow;
    }
  }
  
  /// Get all transactions for the current user
  Future<List<TransactionModel>> getMyTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? status,
    String? accountId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (type != null) {
        queryParams['type'] = type;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (accountId != null) {
        queryParams['accountId'] = accountId;
      }
      
      final response = await _apiService.get(
        '/accounts/my-transactions',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['transactions'] as List)
          .map((transaction) => TransactionModel.fromMap(transaction))
          .toList();
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      rethrow;
    }
  }
  
  /// Get transaction summary for reporting
  Future<TransactionSummary> getTransactionSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? accountId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
      
      if (accountId != null) {
        queryParams['accountId'] = accountId;
      }
      
      final response = await _apiService.get(
        '/accounts/transaction-summary',
        queryParameters: queryParams,
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return TransactionSummary.fromMap(responseData['summary']);
    } catch (e) {
      debugPrint('Error getting transaction summary: $e');
      rethrow;
    }
  }
  
  /// Create a savings goal
  Future<SavingsGoal> createSavingsGoal({
    required String accountId,
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    String? description,
    String? imageUrl,
    String? category,
  }) async {
    try {
      if (targetAmount <= 0) {
        throw Exception('Target amount must be greater than zero');
      }
      
      if (targetDate.isBefore(DateTime.now())) {
        throw Exception('Target date must be in the future');
      }
      
      final response = await _apiService.post(
        '/accounts/$accountId/savings-goals',
        data: {
          'name': name,
          'targetAmount': targetAmount,
          'targetDate': targetDate.toIso8601String(),
          'description': description,
          'imageUrl': imageUrl,
          'category': category,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return SavingsGoal.fromMap(responseData['savingsGoal']);
    } catch (e) {
      debugPrint('Error creating savings goal: $e');
      rethrow;
    }
  }
  
  /// Get all savings goals for an account
  Future<List<SavingsGoal>> getSavingsGoals(String accountId) async {
    try {
      final response = await _apiService.get('/accounts/$accountId/savings-goals');
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['savingsGoals'] as List)
          .map((goal) => SavingsGoal.fromMap(goal))
          .toList();
    } catch (e) {
      debugPrint('Error getting savings goals: $e');
      rethrow;
    }
  }
  
  /// Update savings goal progress
  Future<SavingsGoal> updateSavingsGoalProgress({
    required String accountId,
    required String goalId,
    required double amount,
    bool isContribution = true,
  }) async {
    try {
      final response = await _apiService.put(
        '/accounts/$accountId/savings-goals/$goalId/progress',
        data: {
          'amount': amount,
          'isContribution': isContribution,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return SavingsGoal.fromMap(responseData['savingsGoal']);
    } catch (e) {
      debugPrint('Error updating savings goal: $e');
      rethrow;
    }
  }
  
  /// Delete a savings goal
  Future<void> deleteSavingsGoal(String accountId, String goalId) async {
    try {
      await _apiService.delete('/accounts/$accountId/savings-goals/$goalId');
    } catch (e) {
      debugPrint('Error deleting savings goal: $e');
      rethrow;
    }
  }
  
  /// Set default account
  Future<AccountModel> setDefaultAccount(String accountId) async {
    try {
      final response = await _apiService.post(
        '/accounts/$accountId/set-default',
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return AccountModel.fromMap(responseData['account']);
    } catch (e) {
      debugPrint('Error setting default account: $e');
      rethrow;
    }
  }
  
  /// Get family accounts (for shared family banking)
  Future<List<AccountModel>> getFamilyAccounts() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null || currentUser.familyId == null) {
        return [];
      }
      
      final response = await _apiService.get('/accounts/family');
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['accounts'] as List)
          .map((account) => AccountModel.fromMap(account))
          .toList();
    } catch (e) {
      debugPrint('Error getting family accounts: $e');
      rethrow;
    }
  }
  
  /// Request money from parent (children only)
  Future<TransactionModel> requestMoney({
    required String fromParentAccountId,
    required double amount,
    required String reason,
    String? notes,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null || !currentUser.isChild) {
        throw Exception('Only children can request money');
      }
      
      if (amount <= 0) {
        throw Exception('Request amount must be greater than zero');
      }
      
      final response = await _apiService.post(
        '/accounts/request-money',
        data: {
          'fromParentAccountId': fromParentAccountId,
          'amount': amount,
          'reason': reason,
          'notes': notes,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return TransactionModel.fromMap(responseData['transaction']);
    } catch (e) {
      debugPrint('Error requesting money: $e');
      rethrow;
    }
  }
  
  /// Approve or reject money request (adults only)
  Future<TransactionModel> respondToMoneyRequest({
    required String transactionId,
    required bool approve,
    String? reason,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null || !currentUser.isAdult) {
        throw Exception('Only adults can respond to money requests');
      }
      
      final response = await _apiService.post(
        '/accounts/money-requests/$transactionId/respond',
        data: {
          'approve': approve,
          'reason': reason,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return TransactionModel.fromMap(responseData['transaction']);
    } catch (e) {
      debugPrint('Error responding to money request: $e');
      rethrow;
    }
  }
  
  /// Get pending money requests
  Future<List<TransactionModel>> getPendingMoneyRequests() async {
    try {
      final response = await _apiService.get('/accounts/money-requests/pending');
      
      final responseData = response.data as Map<String, dynamic>;
      return (responseData['requests'] as List)
          .map((request) => TransactionModel.fromMap(request))
          .toList();
    } catch (e) {
      debugPrint('Error getting pending money requests: $e');
      rethrow;
    }
  }
  
  /// Check account limits
  Future<bool> checkAccountLimits({
    required String accountId,
    required double amount,
    required bool isWithdrawal,
  }) async {
    try {
      final response = await _apiService.post(
        '/accounts/$accountId/check-limits',
        data: {
          'amount': amount,
          'isWithdrawal': isWithdrawal,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return responseData['withinLimits'] as bool;
    } catch (e) {
      debugPrint('Error checking account limits: $e');
      rethrow;
    }
  }
}