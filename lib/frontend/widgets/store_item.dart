import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../core/utils/format_utils.dart';
import '../data/models/store.dart';
import '../data/models/user.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/bank_provider.dart';
import 'custom_button.dart';

/// A tile widget that displays store item information in a grid layout
class StoreItemTile extends ConsumerWidget {
  const StoreItemTile({
    required this.item,
    required this.onTap,
    super.key,
    this.onBuy,
    this.onEdit,
    this.onToggleActive,
    this.onUpdateStock,
    this.onAddToFavorites,
    this.isNew = false,
    this.isOnSale = false,
    this.salePrice,
    this.childPurchaseCount = 0,
  });

  final StoreItem item;
  final VoidCallback onTap;
  final VoidCallback? onBuy;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;
  final VoidCallback? onUpdateStock;
  final VoidCallback? onAddToFavorites;
  final bool isNew;
  final bool isOnSale;
  final double? salePrice;
  final int childPurchaseCount;

  IconData _getCategoryIcon(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'reward':
        return Icons.star;
      case 'privilege':
        return Icons.vpn_key;
      case 'experience':
        return Icons.rocket_launch;
      case 'physical':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'reward':
        return kWarningColor;
      case 'privilege':
        return kInfoColor;
      case 'experience':
        return kSecondaryColor;
      case 'physical':
        return kPrimaryColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBadges(BuildContext context) {
    final badges = <Widget>[];
    
    if (isNew) {
      badges.add(_buildBadge(
        context,
        'NEW',
        kSecondaryColor,
        Icons.new_releases,
      ));
    }
    
    if (isOnSale && salePrice != null) {
      final discount = ((item.price - salePrice!) / item.price * 100).round();
      badges.add(_buildBadge(
        context,
        '-$discount%',
        kErrorColor,
        Icons.local_offer,
      ));
    }
    
    if (item.isLimitedStock && item.stock != null && item.stock! <= 5) {
      badges.add(_buildBadge(
        context,
        'LIMITED',
        kWarningColor,
        Icons.timer,
      ));
    }
    
    // ignore: always_put_control_body_on_new_line
    if (badges.isEmpty) return const SizedBox.shrink();
    
    return Positioned(
      top: kSmallPadding,
      left: kSmallPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: badges.map((badge) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: badge,
        )).toList(),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSmallPadding,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(kSmallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final theme = Theme.of(context);
    
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(kDefaultBorderRadius),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(kDefaultBorderRadius),
                ),
                child: Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
                ),
              )
            else
              _buildPlaceholder(context),
            
            // Overlay for unavailable items
            if (!item.isAvailable)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(kDefaultBorderRadius),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'UNAVAILABLE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            
            _buildBadges(context),
            
            // Category indicator
            Positioned(
              bottom: kSmallPadding,
              right: kSmallPadding,
              child: Container(
                padding: const EdgeInsets.all(kSmallPadding),
                decoration: BoxDecoration(
                  color: _getCategoryColor(item.itemType),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(item.itemType),
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(
        _getCategoryIcon(item.itemType),
        size: 48,
        color: theme.colorScheme.primary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isAdult = authState.isAdult;
    final user = authState.user;
    
    // Get child's balance if applicable
    final defaultAccount = !isAdult ? ref.watch(defaultAccountProvider) : null;
    final canAfford = defaultAccount != null && 
                      defaultAccount.availableBalance >= (salePrice ?? item.price);

    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name
          Text(
            item.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Description
          Text(
            item.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: kSmallPadding),
          
          // Price and stock row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOnSale && salePrice != null) ...[
                    Text(
                      FormatUtils.formatCurrency(item.price),
                      style: theme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      FormatUtils.formatCurrency(salePrice!),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: kErrorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else
                    Text(
                      FormatUtils.formatCurrency(item.price),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              
              // Stock indicator
              if (item.isLimitedStock && item.stock != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSmallPadding,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: item.stock! <= 5 
                        ? kWarningColor.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kSmallBorderRadius),
                    border: Border.all(
                      color: item.stock! <= 5 
                          ? kWarningColor.withValues(alpha: 0.3)
                          : theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${item.stock} left',
                    style: TextStyle(
                      color: item.stock! <= 5 ? kWarningColor : theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          // Additional info for children
          if (!isAdult) ...[
            const SizedBox(height: kSmallPadding),
            
            // Balance check
            if (defaultAccount != null)
              Row(
                children: [
                  Icon(
                    canAfford ? Icons.check_circle : Icons.error_outline,
                    size: 16,
                    color: canAfford ? kSuccessColor : kErrorColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    canAfford ? 'You can buy this!' : 'Not enough funds',
                    style: TextStyle(
                      color: canAfford ? kSuccessColor : kErrorColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            
            // Age restriction
            if (item.ageRestriction != null && user != null) ...[
              const SizedBox(height: 4),
              if (user.age != null && user.age! < item.ageRestriction!)
                Row(
                  children: [
                    const Icon(
                      Icons.block,
                      size: 16,
                      color: kErrorColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Age ${item.ageRestriction}+ required',
                      style: const TextStyle(
                        color: kErrorColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
            
            // Purchase limit
            if (item.maxPurchasesPerChild != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Purchased: $childPurchaseCount/${item.maxPurchasesPerChild}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            
            // Requires approval
            if (item.requiresApproval) ...[
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(
                    Icons.approval,
                    size: 16,
                    color: kWarningColor,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Requires approval',
                    style: TextStyle(
                      color: kWarningColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
          
          // Actions
          const SizedBox(height: kDefaultPadding),
          if (isAdult)
            _buildAdultActions(context)
          else
            _buildChildActions(context, canAfford, user),
        ],
      ),
    );
  }

  Widget _buildAdultActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Edit',
            onPressed: item.isAvailable ? onEdit : null,
            style: CustomButtonStyle.outline,
            size: ButtonSize.small,
            icon: Icons.edit,
            fullWidth: true,
          ),
        ),
        const SizedBox(width: kSmallPadding),
        IconButton(
          icon: Icon(
            item.isActive ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          onPressed: onToggleActive,
          tooltip: item.isActive ? 'Deactivate' : 'Activate',
          color: item.isActive ? Colors.grey : kSuccessColor,
        ),
      ],
    );
  }

  Widget _buildChildActions(BuildContext context, bool canAfford, UserModel? user) {
    final canPurchase = item.isAvailable && 
                       canAfford && 
                       (user?.age == null || item.ageRestriction == null || user!.age! >= item.ageRestriction!) &&
                       (item.maxPurchasesPerChild == null || childPurchaseCount < item.maxPurchasesPerChild!);
    
    return CustomButton(
      text: 'Buy Now',
      onPressed: canPurchase ? onBuy : null,
      size: ButtonSize.small,
      icon: Icons.shopping_cart,
      fullWidth: true,
      isDisabled: !canPurchase,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAvailable = item.isAvailable;
    
    return Card(
      elevation: isAvailable ? kDefaultElevation : 1,
      color: isAvailable ? null : theme.cardColor.withValues(alpha: 0.7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(context),
            Expanded(
              child: _buildContent(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}