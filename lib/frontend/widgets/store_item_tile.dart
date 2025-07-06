import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/helpers.dart';
import '../../../frontend/data/models/store_item.dart';
import '../data/models/user.dart';

class StoreItemTile extends StatelessWidget {
  final StoreItem item;
  final UserRole userRole;
  final bool showDollars;
  final VoidCallback? onTap;
  final VoidCallback? onPurchase;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isCompact;

  const StoreItemTile({
    Key? key,
    required this.item,
    required this.userRole,
    required this.showDollars,
    this.onTap,
    this.onPurchase,
    this.onEdit,
    this.onDelete,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: isCompact ? 4 : 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.stock > 0
                ? AppTheme.cream.withOpacity(0.2)
                : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: isCompact ? _buildCompactLayout() : _buildFullLayout(),
      ),
    );
  }

  Widget _buildFullLayout() {
    return Column(
      children: [
        if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
          _buildImage(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDescription(),
              ],
              const SizedBox(height: 12),
              _buildFooter(),
              if (_shouldShowActions()) ...[
                const SizedBox(height: 16),
                _buildActions(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            _buildCompactImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: AppTheme.cream,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildPriceTag(),
                    const SizedBox(width: 8),
                    _buildStockIndicator(),
                  ],
                ),
              ],
            ),
          ),
          if (userRole == UserRole.child && item.stock > 0 && onPurchase != null)
            _buildCompactPurchaseButton(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: AppTheme.cream.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: item.imageUrl != null
            ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildCompactImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.cream.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: item.imageUrl != null
            ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.cream.withOpacity(0.1),
      child: Icon(
        Icons.image,
        color: AppTheme.cream.withOpacity(0.3),
        size: 40,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  color: AppTheme.cream,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              _buildPriceTag(),
            ],
          ),
        ),
        if (userRole == UserRole.parent)
          _buildParentActions(),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      item.description!,
      style: TextStyle(
        color: AppTheme.cream.withOpacity(0.8),
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        _buildStockIndicator(),
        const Spacer(),
        if (item.category != null)
          _buildCategory(),
      ],
    );
  }

  Widget _buildPriceTag() {
    final priceText = showDollars
        ? Helpers.formatCurrency(item.price)
        : Helpers.formatStars(item.price);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priceText,
        style: TextStyle(
          color: AppTheme.primaryDark,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStockIndicator() {
    final isOutOfStock = item.stock == 0;
    final isLowStock = item.stock > 0 && item.stock <= 3;
    
    Color stockColor;
    String stockText;
    IconData stockIcon;
    
    if (isOutOfStock) {
      stockColor = Colors.red;
      stockText = 'Out of Stock';
      stockIcon = Icons.cancel;
    } else if (isLowStock) {
      stockColor = Colors.orange;
      stockText = '${item.stock} left';
      stockIcon = Icons.warning;
    } else if (item.stock < 99) {
      stockColor = Colors.green;
      stockText = '${item.stock} available';
      stockIcon = Icons.check_circle;
    } else {
      stockColor = Colors.green;
      stockText = 'In Stock';
      stockIcon = Icons.check_circle;
    }
    
    return Row(
      children: [
        Icon(
          stockIcon,
          color: stockColor,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          stockText,
          style: TextStyle(
            color: stockColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategory() {
    if (item.category == null) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cream.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        item.category!,
        style: TextStyle(
          color: AppTheme.cream.withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildParentActions() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppTheme.cream.withOpacity(0.6),
      ),
      color: AppTheme.primaryDark,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: AppTheme.cream, size: 18),
              const SizedBox(width: 8),
              Text('Edit', style: TextStyle(color: AppTheme.cream)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (userRole == UserRole.child && item.stock > 0 && onPurchase != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPurchase,
          icon: const Icon(Icons.shopping_cart, size: 18),
          label: const Text('Purchase'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.cream,
            foregroundColor: AppTheme.primaryDark,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }
    
    if (userRole == UserRole.child && item.stock == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel,
              color: Colors.red,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Out of Stock',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox();
  }

  Widget _buildCompactPurchaseButton() {
    return IconButton(
      onPressed: onPurchase,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cream,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.shopping_cart,
          color: AppTheme.primaryDark,
          size: 18,
        ),
      ),
    );
  }

  bool _shouldShowActions() {
    return userRole == UserRole.child && onPurchase != null;
  }
}

// Grid item version for store displays
class GridStoreItemTile extends StatelessWidget {
  final StoreItem item;
  final UserRole userRole;
  final bool showDollars;
  final VoidCallback? onTap;
  final VoidCallback? onPurchase;

  const GridStoreItemTile({
    Key? key,
    required this.item,
    required this.userRole,
    required this.showDollars,
    this.onTap,
    this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.stock > 0
                ? AppTheme.cream.withOpacity(0.2)
                : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: AppTheme.cream,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        showDollars
                            ? Helpers.formatCurrency(item.price)
                            : Helpers.formatStars(item.price),
                        style: TextStyle(
                          color: AppTheme.cream,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.stock == 0)
                        Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 16,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: AppTheme.cream.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: item.imageUrl != null
            ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.image,
                    color: AppTheme.cream.withOpacity(0.3),
                    size: 40,
                  ),
                ),
              )
            : Center(
                child: Icon(
                  Icons.image,
                  color: AppTheme.cream.withOpacity(0.3),
                  size: 40,
                ),
              ),
      ),
    );
  }
}