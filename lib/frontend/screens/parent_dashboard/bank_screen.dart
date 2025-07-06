import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/bank_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/account.dart';
import '../../data/models/transaction.dart';
import '../../data/models/user.dart';
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

class _BankScreenState extends ConsumerState<BankScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<User> _children = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    Future.microtask(() async {
      await ref.read(bankProvider.notifier).loadFamilyAccounts();
      await ref.read(bankProvider.notifier).loadPendingWithdrawals();
      await ref.read(bankProvider.notifier).loadFamilyTransactions();
      _loadChildren();
    });
  }

  void _loadChildren() async {
    final authState = ref.read(authProvider);
    if (authState.value?.role == UserRole.PARENT) {
      final children = await ref.read(authProvider.notifier).getFamilyChildren();
      setState(() {
        _children = children;
        _tabController = TabController(length: children.length, vsync: this);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTransferDialog(String childId, List<Account> accounts) {
    Account? fromAccount;
    Account? toAccount;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            'Transfer Funds',
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
                        '${account.type.name} - ${CurrencyHelpers.formatCurrency(account.balance, CurrencyType.DOLLARS)}',
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
                        '${account.type.name} - ${CurrencyHelpers.formatCurrency(account.balance, CurrencyType.DOLLARS)}',
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
                    ref.read(bankProvider.notifier).transferFundsForChild(
                      childId: childId,
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

  @override
  Widget build(BuildContext context) {
    final bankState = ref.watch(bankProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Family Bank',
          style: AppTheme.headingLarge.copyWith(color: AppTheme.textPrimary),
        ),
        elevation: 0,
        bottom: _children.isNotEmpty
            ? TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.accentColor,
                labelColor: AppTheme.textPrimary,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: _children.map((child) => Tab(text: child.name)).toList(),
              )
            : null,
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
          if (_children.isEmpty) {
            return Center(
              child: Text(
                'No children in family',
                style: AppTheme.headingMedium.copyWith(color: AppTheme.textSecondary),
              ),
            );
          }

          final familyAccounts = data['familyAccounts'] as Map<String, List<Account>>? ?? {};
          final pendingWithdrawals = data['pendingWithdrawals'] as List<dynamic>? ?? [];
          final transactions = data['transactions'] as List<Transaction>? ?? [];

          return TabBarView(
            controller: _tabController,
            children: _children.map((child) {
              final childAccounts = familyAccounts[child.id] ?? [];
              final childWithdrawals = pendingWithdrawals
                  .where((w) => w['userId'] == child.id)
                  .toList();
              final childTransactions = transactions
                  .where((t) => childAccounts.any((a) => a.id == t.fromAccountId || a.id == t.toAccountId))
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pending Withdrawals
                    if (childWithdrawals.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.warningColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, 
                                     color: AppTheme.warningColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Pending Withdrawals',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.warningColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...childWithdrawals.map((withdrawal) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          CurrencyHelpers.formatCurrency(
                                            withdrawal['amount'],
                                            CurrencyType.DOLLARS,
                                          ),
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateHelpers.formatDate(withdrawal['createdAt']),
                                          style: AppTheme.bodySmall.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.check_circle, 
                                                    color: AppTheme.successColor),
                                          onPressed: () {
                                            ref.read(bankProvider.notifier)
                                                .approveWithdrawal(withdrawal['id']);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.cancel, 
                                                    color: AppTheme.errorColor),
                                          onPressed: () {
                                            ref.read(bankProvider.notifier)
                                                .rejectWithdrawal(withdrawal['id']);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Account Balances
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Accounts',
                          style: AppTheme.headingMedium.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showTransferDialog(child.id, childAccounts),
                          icon: Icon(Icons.swap_horiz, color: AppTheme.accentColor),
                          label: Text('Transfer', 
                                      style: TextStyle(color: AppTheme.accentColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...childAccounts.map((account) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BalanceCard(
                          account: account,
                          currencyDisplay: CurrencyType.DOLLARS,
                          onTap: () {
                            // Show account details
                          },
                        ),
                      );
                    }).toList(),

                    // Transaction History
                    const SizedBox(height: 24),
                    Text(
                      'Recent Transactions',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (childTransactions.isEmpty)
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
                      ...childTransactions.take(10).map((transaction) {
                        final isDebit = childAccounts.any((a) => a.id == transaction.fromAccountId);
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
                                      DateHelpers.formatDate(transaction.createdAt),
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
                                  CurrencyType.DOLLARS,
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
            }).toList(),
          );
        },
      ),
    );
  }
}