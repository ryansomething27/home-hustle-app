import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../core/utils/format_utils.dart';
import '../data/models/account.dart';
import '../data/models/transaction.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/bank_provider.dart';
import 'custom_button.dart';

/// A card widget that displays account balance information
class BalanceCard extends ConsumerWidget {
  const BalanceCard({
    super.key,
    this.account,
    this.onDeposit,
    this.onWithdraw,
    this.onTransfer,
    this.onRequestMoney,
    this.onViewAllTransactions,
    this.showActions = true,
    this.showTransactions = true,
    this.isCompact = false,
  });

  final AccountModel? account;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onTransfer;
  final VoidCallback? onRequestMoney;
  final VoidCallback? onViewAllTransactions;
  final bool showActions;
  final bool showTransactions;
  final bool isCompact;

  Color _getBalanceColor(double balance) {
    if (balance > 0) {
      return kSuccessColor;
    } else if (balance < 0) {
      return kErrorColor;
    } else {
      return Colors.grey;
    }
  }

  Widget _buildBalanceDisplay(BuildContext context, AccountModel account) {
    final theme = Theme.of(context);
    final balanceColor = _getBalanceColor(account.balance);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          account.accountName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: kSmallPadding / 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              FormatUtils.formatCurrency(account.balance),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: balanceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (account.availableBalance != account.balance) ...[
              const SizedBox(width: kSmallPadding),
              Text(
                '(${FormatUtils.formatCurrency(account.availableBalance)} available)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
        if (account.fundsOnHold > 0) ...[
          const SizedBox(height: kSmallPadding / 2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kSmallPadding,
              vertical: kSmallPadding / 2,
            ),
            decoration: BoxDecoration(
              color: kWarningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(kSmallBorderRadius),
              border: Border.all(
                color: kWarningColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_clock,
                  size: 14,
                  color: kWarningColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${FormatUtils.formatCurrency(account.fundsOnHold)} on hold',
                  style: const TextStyle(
                    color: kWarningColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSavingsGoalProgress(BuildContext context, SavingsGoal goal) {
    final theme = Theme.of(context);
    final progress = goal.progressPercentage / 100;
    
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.savings,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: kSmallPadding),
              Expanded(
                child: Text(
                  goal.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: kSmallPadding),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${FormatUtils.formatCurrency(goal.currentAmount)} of ${FormatUtils.formatCurrency(goal.targetAmount)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (goal.daysUntilTarget > 0)
                      Text(
                        '${goal.daysUntilTarget} days left',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                      )
                    else if (goal.isOverdue)
                      Text(
                        'Overdue',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kErrorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${goal.progressPercentage.toStringAsFixed(0)}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: kSmallPadding),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.isCompleted ? kSuccessColor : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel transaction) {
    final theme = Theme.of(context);
    final isIncoming = transaction.type == 'deposit' || 
                       transaction.type == 'job_payment' || 
                       transaction.type == 'allowance';
    final color = isIncoming ? kSuccessColor : kErrorColor;
    final icon = isIncoming ? Icons.arrow_downward : Icons.arrow_upward;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallPadding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(kSmallPadding),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: kDefaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  FormatUtils.formatRelativeTime(transaction.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncoming ? '+' : '-'}${FormatUtils.formatCurrency(transaction.amount)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (transaction.status == 'pending')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSmallPadding,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: kWarningColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(kSmallBorderRadius),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: kWarningColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberBalance(BuildContext context, AccountModel memberAccount) {
    final theme = Theme.of(context);
    final balanceColor = _getBalanceColor(memberAccount.balance);
    
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              FormatUtils.formatInitials(
                memberAccount.ownerName.split(' ').first,
                memberAccount.ownerName.split(' ').last,
              ),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: kDefaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberAccount.ownerName,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  memberAccount.accountName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            FormatUtils.formatCurrency(memberAccount.balance),
            style: theme.textTheme.titleMedium?.copyWith(
              color: balanceColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdultActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Add Funds',
            onPressed: onDeposit,
            size: ButtonSize.small,
            icon: Icons.add,
            fullWidth: true,
          ),
        ),
        const SizedBox(width: kSmallPadding),
        Expanded(
          child: CustomButton(
            text: 'Transfer',
            onPressed: onTransfer,
            style: CustomButtonStyle.outline,
            size: ButtonSize.small,
            icon: Icons.swap_horiz,
            fullWidth: true,
          ),
        ),
        const SizedBox(width: kSmallPadding),
        Expanded(
          child: CustomButton(
            text: 'Withdraw',
            onPressed: onWithdraw,
            style: CustomButtonStyle.outline,
            size: ButtonSize.small,
            icon: Icons.remove,
            fullWidth: true,
          ),
        ),
      ],
    );
  }

  Widget _buildChildActions(BuildContext context) {
    return CustomButton(
      text: 'Request Money',
      onPressed: onRequestMoney,
      icon: Icons.attach_money,
      fullWidth: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdult = authState.isAdult;
    final theme = Theme.of(context);
    
    // Get the account to display
    final displayAccount = account ?? ref.watch(defaultAccountProvider);
    if (displayAccount == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Text(
            'No account available',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    // Get recent transactions for this account
    final transactions = ref.watch(accountTransactionsProvider(displayAccount.id)) ?? [];
    final recentTransactions = transactions.take(3).toList();
    
    // Get savings goals for children
    final savingsGoals = !isAdult 
        ? ref.watch(accountSavingsGoalsProvider(displayAccount.id)) ?? []
        : <SavingsGoal>[];
    
    // Get family member accounts for adults
    final allAccounts = isAdult ? ref.watch(accountsProvider) : <AccountModel>[];
    final familyAccounts = allAccounts.where((acc) => 
        acc.id != displayAccount.id && 
        acc.ownerId != authState.user?.id
    ).toList();

    return Card(
      elevation: kDefaultElevation,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Account Balance
            _buildBalanceDisplay(context, displayAccount),
            
            if (!isCompact) ...[
              // Savings Goals (Children Only)
              if (!isAdult && savingsGoals.isNotEmpty) ...[
                const SizedBox(height: kLargePadding),
                Text(
                  'Savings Goals',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: kDefaultPadding),
                ...savingsGoals.take(2).map((goal) => Padding(
                  padding: const EdgeInsets.only(bottom: kDefaultPadding),
                  child: _buildSavingsGoalProgress(context, goal),
                )),
              ],
              
              // Family Member Balances (Adults Only)
              if (isAdult && familyAccounts.isNotEmpty) ...[
                const SizedBox(height: kLargePadding),
                Text(
                  'Family Members',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: kDefaultPadding),
                ...familyAccounts.map((memberAccount) => Padding(
                  padding: const EdgeInsets.only(bottom: kDefaultPadding),
                  child: _buildFamilyMemberBalance(context, memberAccount),
                )),
              ],
              
              // Recent Transactions
              if (showTransactions && recentTransactions.isNotEmpty) ...[
                const SizedBox(height: kLargePadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: onViewAllTransactions,
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const Divider(),
                ...recentTransactions.map((transaction) => 
                  _buildTransactionItem(context, transaction)
                ),
              ],
              
              // Action Buttons
              if (showActions) ...[
                const SizedBox(height: kLargePadding),
                if (isAdult)
                  _buildAdultActions(context)
                else
                  _buildChildActions(context),
              ],
            ],
          ],
        ),
      ),
    );
  }
}