import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/helpers.dart';
import '../data/models/account.dart';

class BalanceCard extends StatelessWidget {
  final Account account;
  final bool showDollars;
  final VoidCallback? onTap;
  final bool showActions;

  const BalanceCard({
    Key? key,
    required this.account,
    required this.showDollars,
    this.onTap,
    this.showActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.cream.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cream.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getAccountIcon(),
                        color: AppTheme.cream,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getAccountTypeName(),
                          style: TextStyle(
                            color: AppTheme.cream.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (account.interestRate != null && account.interestRate! > 0)
                          Text(
                            '${account.interestRate}% APY',
                            style: TextStyle(
                              color: AppTheme.cream.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (showActions && onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.cream.withOpacity(0.5),
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              showDollars
                  ? Helpers.formatCurrency(account.balance)
                  : Helpers.formatStars(account.balance),
              style: TextStyle(
                color: AppTheme.cream,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            if (account.pendingTransactions > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${account.pendingTransactions} pending',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (account.type == AccountType.loan && account.balance > 0) ...[
              const SizedBox(height: 12),
              _buildLoanDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetails() {
    final dueDate = account.dueDate ?? DateTime.now().add(const Duration(days: 30));
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysUntilDue < 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.cream.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.3, // Mock progress
            child: Container(
              decoration: BoxDecoration(
                color: isOverdue ? Colors.red : AppTheme.cream,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isOverdue ? 'OVERDUE' : 'Due in $daysUntilDue days',
              style: TextStyle(
                color: isOverdue ? Colors.red : AppTheme.cream.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '30% APR',
              style: TextStyle(
                color: AppTheme.cream.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCardColor() {
    switch (account.type) {
      case AccountType.checking:
        return AppTheme.primaryDark.withOpacity(0.8);
      case AccountType.savings:
        return AppTheme.primaryDark.withOpacity(0.7);
      case AccountType.investment:
        return AppTheme.primaryDark.withOpacity(0.6);
      case AccountType.loan:
        return Colors.red.withOpacity(0.2);
      default:
        return AppTheme.primaryDark.withOpacity(0.8);
    }
  }

  IconData _getAccountIcon() {
    switch (account.type) {
      case AccountType.checking:
        return Icons.account_balance_wallet;
      case AccountType.savings:
        return Icons.savings;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.loan:
        return Icons.credit_card;
      default:
        return Icons.account_balance;
    }
  }

  String _getAccountTypeName() {
    switch (account.type) {
      case AccountType.checking:
        return 'CHECKING';
      case AccountType.savings:
        return 'SAVINGS';
      case AccountType.investment:
        return 'INVESTMENT';
      case AccountType.loan:
        return 'LOAN';
      default:
        return 'ACCOUNT';
    }
  }
}

// Compact version for displaying multiple cards in a row
class CompactBalanceCard extends StatelessWidget {
  final Account account;
  final bool showDollars;
  final VoidCallback? onTap;

  const CompactBalanceCard({
    Key? key,
    required this.account,
    required this.showDollars,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.cream.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getAccountIcon(),
                  color: AppTheme.cream.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _getAccountTypeName(),
                    style: TextStyle(
                      color: AppTheme.cream.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              showDollars
                  ? Helpers.formatCurrency(account.balance)
                  : Helpers.formatStars(account.balance),
              style: TextStyle(
                color: AppTheme.cream,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccountIcon() {
    switch (account.type) {
      case AccountType.checking:
        return Icons.account_balance_wallet;
      case AccountType.savings:
        return Icons.savings;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.loan:
        return Icons.credit_card;
      default:
        return Icons.account_balance;
    }
  }

  String _getAccountTypeName() {
    switch (account.type) {
      case AccountType.checking:
        return 'CHECKING';
      case AccountType.savings:
        return 'SAVINGS';
      case AccountType.investment:
        return 'INVEST';
      case AccountType.loan:
        return 'LOAN';
      default:
        return 'ACCOUNT';
    }
  }
}