import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/bank_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/account.dart';
import '../../data/models/transaction.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/balance_card.dart';

class BankScreen extends ConsumerStatefulWidget {
  const BankScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends ConsumerState<BankScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(bankProvider.notifier).loadAccounts();
      ref.read(bankProvider.notifier).loadTransactions();
    });
  }

  void _showTransferDialog(List<Account> accounts) {
    Account? fromAccount;
    Account? toAccount;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            'Transfer Money',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Account>(
                  value: fromAccount,
                  decoration: InputDecoration(
                    labelText: 'From Account',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                  ),
                  dropdownColor: AppTheme.surfaceColor,
                  style: TextStyle(color: AppTheme.textPrimary),
                  items: accounts.map((account) {
                    return DropdownMenuItem(
                      value: account,
                      child: Text(
                        '${_getAccountDisplayName(account.type)} - ${CurrencyHelpers.formatCurrency(account.balance, CurrencyType.DOLLARS)}',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => fromAccount = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Account>(
                  value: toAccount,
                  decoration: InputDecoration(
                    labelText: 'To Account',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                  ),
                  dropdownColor: AppTheme.surfaceColor,
                  style: TextStyle(color: AppTheme.textPrimary),
                  items: accounts
                      .where((account) => account != fromAccount)
                      .map((account) {
                    return DropdownMenuItem(
                      value: account,
                      child: Text(
                        '${_getAccountDisplayName(account.type)} - ${CurrencyHelpers.formatCurrency(account.balance, CurrencyType.DOLLARS)}',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => toAccount = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                    prefixText: '\$ ',
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (fromAccount != null &&
                    toAccount != null &&
                    amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0) {
                    ref.read(bankProvider.notifier).transferFunds(
                      fromAccountId: fromAccount!.id,
                      toAccountId: toAccount!.id,
                      amount: amount,
                    );
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalDialog(List<Account> accounts) {
    Account? selectedAccount;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            'Request Withdrawal',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your parent will need to approve this withdrawal request.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Account>(
                  value: selectedAccount,
                  decoration: InputDecoration(
                    labelText: 'From Account',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                  ),
                  dropdownColor: AppTheme.surfaceColor,
                  style: TextStyle(color: AppTheme.textPrimary),
                  items: accounts.map((account) {
                    return DropdownMenuItem(
                      value: account,
                      child: Text(
                        '${_getAccountDisplayName(account.type)} - ${CurrencyHelpers.formatCurrency(account.balance, CurrencyType.DOLLARS)}',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedAccount = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                    prefixText: '\$ ',
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedAccount != null && amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0) {
                    ref.read(bankProvider.notifier).requestWithdrawal(
                      accountId: selectedAccount!.id,
                      amount: amount,
                    );
                    Navigator.pop(context);
                    _showWithdrawalRequestSuccess();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              child: const Text('Request'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalRequestSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Withdrawal request sent to your parent!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _getAccountDisplayName(AccountType type) {
    switch (type) {
      case AccountType.CHECKING:
        return 'Spending';
      case AccountType.SAVINGS:
        return 'Savings';
      case AccountType.INVESTMENT:
        return 'Investment';
      default:
        return type.toString().split('.').last;
    }
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.CHECKING:
        return Icons.account_balance_wallet;
      case AccountType.SAVINGS:
        return Icons.savings;
      case AccountType.INVESTMENT:
        return Icons.trending_up;
      default:
        return Icons.account_balance;
    }
  }

  Color _getAccountColor(AccountType type) {
    switch (type) {
      case AccountType.CHECKING:
        return AppTheme.accentColor;
      case AccountType.SAVINGS:
        return AppTheme.successColor;
      case AccountType.INVESTMENT:
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bankState = ref.watch(bankProvider);
    final user = ref.watch(authProvider).value;
    final currencyDisplay = user?.familySettings?['currencyDisplay'] ?? CurrencyType.DOLLARS;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'My Bank',
          style: AppTheme.headingLarge.copyWith(color: AppTheme.textPrimary),
        ),
        elevation: 0,
      ),
      body: bankState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: AppTheme.errorColor),
          ),
        ),
        data: (data) {
          final accounts = data['accounts'] as List<Account>? ?? [];
          final transactions = data['transactions'] as List<Transaction>? ?? [];
          final totalBalance = accounts.fold(0.0, (sum, account) => sum + account.balance);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Balance Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accentColor,
                        AppTheme.accentColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Balance',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Icon(
                            Icons.account_balance,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyHelpers.formatCurrency(totalBalance, currencyDisplay),
                        style: AppTheme.headingLarge.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.swap_horiz,
                        label: 'Transfer',
                        color: AppTheme.successColor,
                        onPressed: accounts.length > 1
                            ? () => _showTransferDialog(accounts)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.account_balance_wallet,
                        label: 'Withdraw',
                        color: AppTheme.warningColor,
                        onPressed: accounts.isNotEmpty
                            ? () => _showWithdrawalDialog(accounts)
                            : null,
                      ),
                    ),
                  ],
                ),

                // Account Cards
                const SizedBox(height: 32),
                Text(
                  'My Accounts',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...accounts.map((account) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AccountCard(
                      account: account,
                      currencyDisplay: currencyDisplay,
                      icon: _getAccountIcon(account.type),
                      color: _getAccountColor(account.type),
                      displayName: _getAccountDisplayName(account.type),
                    ),
                  );
                }).toList(),

                // Recent Transactions
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to full transaction history
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(color: AppTheme.accentColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ...transactions.take(5).map((transaction) {
                    final isDebit = accounts.any((a) => a.id == transaction.fromAccountId);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDebit 
                                  ? AppTheme.errorColor.withOpacity(0.1)
                                  : AppTheme.successColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isDebit ? AppTheme.errorColor : AppTheme.successColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.description,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  DateHelpers.formatRelativeTime(transaction.createdAt),
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isDebit ? '-' : '+'}${CurrencyHelpers.formatCurrency(
                              transaction.amount,
                              currencyDisplay,
                            )}',
                            style: AppTheme.bodyLarge.copyWith(
                              color: isDebit ? AppTheme.errorColor : AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final CurrencyType currencyDisplay;
  final IconData icon;
  final Color color;
  final String displayName;

  const _AccountCard({
    Key? key,
    required this.account,
    required this.currencyDisplay,
    required this.icon,
    required this.color,
    required this.displayName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyHelpers.formatCurrency(account.balance, currencyDisplay),
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (account.type == AccountType.SAVINGS || account.type == AccountType.INVESTMENT)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                account.type == AccountType.SAVINGS ? '5% APR' : '10% APR',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}