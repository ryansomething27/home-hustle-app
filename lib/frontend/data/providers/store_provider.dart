import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final storeProvider = StateNotifierProvider<StoreNotifier, AsyncValue<StoreState>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return StoreNotifier(apiService);
});

class StoreState {
  final List<StoreItem> items;
  final List<StorePurchase> purchaseHistory;
  final Map<String, int> itemPurchaseCounts;
  final double totalSpent;

  StoreState({
    required this.items,
    required this.purchaseHistory,
    required this.itemPurchaseCounts,
    required this.totalSpent,
  });

  StoreState copyWith({
    List<StoreItem>? items,
    List<StorePurchase>? purchaseHistory,
    Map<String, int>? itemPurchaseCounts,
    double? totalSpent,
  }) {
    return StoreState(
      items: items ?? this.items,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      itemPurchaseCounts: itemPurchaseCounts ?? this.itemPurchaseCounts,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}

class StoreItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final CurrencyType currencyType;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currencyType,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  StoreItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    CurrencyType? currencyType,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currencyType: currencyType ?? this.currencyType,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StorePurchase {
  final String id;
  final String itemId;
  final String itemName;
  final String childId;
  final String childName;
  final double price;
  final CurrencyType currencyType;
  final DateTime purchasedAt;
  final PurchaseStatus status;

  StorePurchase({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.childId,
    required this.childName,
    required this.price,
    required this.currencyType,
    required this.purchasedAt,
    required this.status,
  });
}

enum CurrencyType {
  dollar,
  star,
}

enum PurchaseStatus {
  pending,
  completed,
  cancelled,
}

class ItemDetails {
  final String name;
  final String description;
  final double price;
  final CurrencyType currencyType;
  final String? imageUrl;

  ItemDetails({
    required this.name,
    required this.description,
    required this.price,
    required this.currencyType,
    this.imageUrl,
  });
}

class StoreNotifier extends StateNotifier<AsyncValue<StoreState>> {
  final ApiService _apiService;

  StoreNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadStore();
  }

  Future<void> loadStore() async {
    try {
      state = const AsyncValue.loading();
      
      final items = await _apiService.getStoreItems();
      final purchases = await _apiService.getPurchaseHistory();
      
      final purchaseCounts = <String, int>{};
      double totalSpent = 0;
      
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.completed) {
          purchaseCounts[purchase.itemId] = (purchaseCounts[purchase.itemId] ?? 0) + 1;
          totalSpent += purchase.price;
        }
      }
      
      state = AsyncValue.data(StoreState(
        items: items,
        purchaseHistory: purchases,
        itemPurchaseCounts: purchaseCounts,
        totalSpent: totalSpent,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addItem({
    required String parentId,
    required ItemDetails itemDetails,
  }) async {
    try {
      await _apiService.addStoreItem(
        parentId: parentId,
        itemDetails: itemDetails,
      );
      
      await loadStore();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateItem({
    required String itemId,
    required ItemDetails itemDetails,
  }) async {
    try {
      await _apiService.updateStoreItem(
        itemId: itemId,
        itemDetails: itemDetails,
      );
      
      await loadStore();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _apiService.deleteStoreItem(itemId);
      
      await loadStore();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleItemActive(String itemId) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;
      
      final item = currentState.items.firstWhere((i) => i.id == itemId);
      
      await _apiService.toggleStoreItemActive(
        itemId: itemId,
        isActive: !item.isActive,
      );
      
      await loadStore();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> purchaseItem({
    required String childId,
    required String itemId,
  }) async {
    try {
      await _apiService.purchaseStoreItem(
        childId: childId,
        itemId: itemId,
      );
      
      await loadStore();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  StoreItem? getItemById(String itemId) {
    final currentState = state.value;
    if (currentState == null) return null;
    
    try {
      return currentState.items.firstWhere((item) => item.id == itemId);
    } catch (_) {
      return null;
    }
  }

  List<StoreItem> getActiveItems() {
    final currentState = state.value;
    if (currentState == null) return [];
    
    return currentState.items.where((item) => item.isActive).toList();
  }

  List<StorePurchase> getPurchasesForChild(String childId) {
    final currentState = state.value;
    if (currentState == null) return [];
    
    return currentState.purchaseHistory
        .where((purchase) => purchase.childId == childId)
        .toList();
  }

  int getPurchaseCountForItem(String itemId) {
    final currentState = state.value;
    if (currentState == null) return 0;
    
    return currentState.itemPurchaseCounts[itemId] ?? 0;
  }

  Future<void> refreshStore() async {
    await loadStore();
  }
}