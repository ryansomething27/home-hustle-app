import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/store_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/bank_provider.dart';
import '../../../../frontend/data/models/store_item.dart';
import '../../data/models/account.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/custom_button.dart';

class FamilyStoreScreen extends ConsumerStatefulWidget {
  const FamilyStoreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FamilyStoreScreen> createState() => _FamilyStoreScreenState();
}

class _FamilyStoreScreenState extends ConsumerState<FamilyStoreScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(storeProvider.notifier).loadStoreItems();
      ref.read(bankProvider.notifier).loadAccounts();
    });
  }

  void _showPurchaseConfirmation(StoreItem item) {
    final user = ref.read(authProvider).value;
    final bankState = ref.read(bankProvider);
    
    double totalBalance = 0;
    if (bankState.hasValue) {
      final accounts = bankState.value!['accounts'] as List<Account>? ?? [];
      totalBalance = accounts.fold(0, (sum, account) => sum + account.balance);
    }

    final canAfford = totalBalance >= item.price;
    final currencyDisplay = user?.familySettings?['currencyDisplay'] ?? CurrencyType.DOLLARS;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: AppTheme.accentColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyHelpers.formatCurrency(
                          item.price,
                          item.currencyType == CurrencyType.STARS ? currencyDisplay : item.currencyType,
                        ),
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (item.description.isNotEmpty) ...[
              Text(
                item.description,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: canAfford 
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: canAfford 
                      ? AppTheme.successColor.withOpacity(0.3)
                      : AppTheme.errorColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    canAfford ? Icons.account_balance_wallet : Icons.warning_amber_rounded,
                    color: canAfford ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          canAfford ? 'Available Balance' : 'Insufficient Funds',
                          style: AppTheme.bodySmall.copyWith(
                            color: canAfford ? AppTheme.successColor : AppTheme.errorColor,
                          ),
                        ),
                        Text(
                          CurrencyHelpers.formatCurrency(
                            totalBalance,
                            currencyDisplay,
                          ),
                          style: AppTheme.bodyLarge.copyWith(
                            color: canAfford ? AppTheme.successColor : AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppTheme.borderColor),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canAfford
                        ? () {
                            ref.read(storeProvider.notifier).purchaseItem(item.id);
                            Navigator.pop(context);
                            _showPurchaseSuccess(item);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: AppTheme.textSecondary.withOpacity(0.3),
                    ),
                    child: const Text('Purchase'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseSuccess(StoreItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Successfully purchased ${item.name}!',
                style: const TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(storeProvider);
    final user = ref.watch(authProvider).value;
    final currencyDisplay = user?.familySettings?['currencyDisplay'] ?? CurrencyType.DOLLARS;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Family Store',
          style: AppTheme.headingLarge.copyWith(color: AppTheme.textPrimary),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: AppTheme.accentColor),
            onPressed: () {
              Navigator.pushNamed(context, Routes.purchaseHistory);
            },
          ),
        ],
      ),
      body: storeState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: AppTheme.errorColor),
          ),
        ),
        data: (data) {
          final items = data['items'] as List<StoreItem>? ?? [];
          
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 80,
                    color: AppTheme.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Store is empty',
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for items to purchase',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _StoreItemCard(
                item: item,
                currencyDisplay: currencyDisplay,
                onPurchase: () => _showPurchaseConfirmation(item),
              );
            },
          );
        },
      ),
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final StoreItem item;
  final CurrencyType currencyDisplay;
  final VoidCallback onPurchase;

  const _StoreItemCard({
    Key? key,
    required this.item,
    required this.currencyDisplay,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = item.stock <= 0;

    return GestureDetector(
      onTap: isOutOfStock ? null : onPurchase,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 48,
                      color: isOutOfStock 
                          ? AppTheme.textSecondary.withOpacity(0.5)
                          : AppTheme.accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppTheme.bodyLarge.copyWith(
                            color: isOutOfStock 
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyHelpers.formatCurrency(
                                item.price,
                                item.currencyType == CurrencyType.STARS 
                                    ? currencyDisplay 
                                    : item.currencyType,
                              ),
                              style: AppTheme.bodyLarge.copyWith(
                                color: isOutOfStock 
                                    ? AppTheme.textSecondary
                                    : AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.stock > 0 && item.stock <= 5)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Only ${item.stock} left',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.warningColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isOutOfStock)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Out of Stock',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}