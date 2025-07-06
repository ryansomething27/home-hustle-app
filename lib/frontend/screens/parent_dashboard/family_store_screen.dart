import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/store_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../../../frontend/data/models/store_item.dart';
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
      ref.read(storeProvider.notifier).loadPurchaseHistory();
    });
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    bool useStars = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            'Add Store Item',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Price',
                          labelStyle: TextStyle(color: AppTheme.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.accentColor),
                          ),
                          prefixText: useStars ? '⭐ ' : '\$ ',
                        ),
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text('Use Stars', style: TextStyle(color: AppTheme.textSecondary)),
                        Switch(
                          value: useStars,
                          onChanged: (value) => setState(() => useStars = value),
                          activeColor: AppTheme.accentColor,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stock Quantity',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
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
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    stockController.text.isNotEmpty) {
                  ref.read(storeProvider.notifier).addStoreItem(
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.parse(priceController.text),
                    currencyType: useStars ? CurrencyType.STARS : CurrencyType.DOLLARS,
                    stock: int.parse(stockController.text),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(StoreItem item) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());
    final stockController = TextEditingController(text: item.stock.toString());
    bool useStars = item.currencyType == CurrencyType.STARS;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(
            'Edit Store Item',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Price',
                          labelStyle: TextStyle(color: AppTheme.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.accentColor),
                          ),
                          prefixText: useStars ? '⭐ ' : '\$ ',
                        ),
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text('Use Stars', style: TextStyle(color: AppTheme.textSecondary)),
                        Switch(
                          value: useStars,
                          onChanged: (value) => setState(() => useStars = value),
                          activeColor: AppTheme.accentColor,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stock Quantity',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
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
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    stockController.text.isNotEmpty) {
                  ref.read(storeProvider.notifier).updateStoreItem(
                    itemId: item.id,
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.parse(priceController.text),
                    currencyType: useStars ? CurrencyType.STARS : CurrencyType.DOLLARS,
                    stock: int.parse(stockController.text),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              child: const Text('Update Item'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(storeProvider);

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
                    'No store items yet',
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items for your children to purchase',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
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
                  onEdit: () => _showEditItemDialog(item),
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.surfaceColor,
                        title: Text(
                          'Delete Item',
                          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
                        ),
                        content: Text(
                          'Are you sure you want to delete "${item.name}"?',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(storeProvider.notifier).deleteStoreItem(item.id);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final StoreItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StoreItemCard({
    Key? key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
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
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete,
                          size: 16,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                      color: AppTheme.textPrimary,
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
                          item.currencyType,
                        ),
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.stock > 0 
                              ? AppTheme.successColor.withOpacity(0.2)
                              : AppTheme.errorColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Stock: ${item.stock}',
                          style: AppTheme.bodySmall.copyWith(
                            color: item.stock > 0 
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
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
    );
  }
}