import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store.dart';
import '../services/store_service.dart';

/// State class for store management
class StoreState {
  StoreState({
    this.storeItems = const AsyncValue.loading(),
    this.purchaseHistory = const AsyncValue.loading(),
    this.pendingPurchases = const AsyncValue.loading(),
    this.itemCache = const {},
    this.purchaseCache = const {},
    this.categories = const AsyncValue.loading(),
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.selectedItemType,
    this.minPrice,
    this.maxPrice,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final AsyncValue<List<StoreItem>> storeItems;
  final AsyncValue<List<StorePurchase>> purchaseHistory;
  final AsyncValue<List<StorePurchase>> pendingPurchases;
  final Map<String, StoreItem> itemCache;
  final Map<String, List<StorePurchase>> purchaseCache;
  final AsyncValue<List<String>> categories;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;
  final String? selectedItemType;
  final double? minPrice;
  final double? maxPrice;
  final int currentPage;
  final bool hasMore;

  StoreState copyWith({
    AsyncValue<List<StoreItem>>? storeItems,
    AsyncValue<List<StorePurchase>>? purchaseHistory,
    AsyncValue<List<StorePurchase>>? pendingPurchases,
    Map<String, StoreItem>? itemCache,
    Map<String, List<StorePurchase>>? purchaseCache,
    AsyncValue<List<String>>? categories,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? selectedItemType,
    double? minPrice,
    double? maxPrice,
    int? currentPage,
    bool? hasMore,
  }) {
    return StoreState(
      storeItems: storeItems ?? this.storeItems,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      pendingPurchases: pendingPurchases ?? this.pendingPurchases,
      itemCache: itemCache ?? this.itemCache,
      purchaseCache: purchaseCache ?? this.purchaseCache,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedItemType: selectedItemType ?? this.selectedItemType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Store state notifier
class StoreNotifier extends StateNotifier<StoreState> {
  StoreNotifier(this._storeService) : super(StoreState()) {
    // Load initial data
    loadFamilyStoreItems();
    loadCategories();
  }

  final StoreService _storeService;
  static const int _pageSize = 20;

  /// Load family store items with optional filters
  Future<void> loadFamilyStoreItems({
    bool refresh = false,
    String? category,
    bool activeOnly = true,
    String? itemType,
  }) async {
    if (state.isLoading && !refresh) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      selectedCategory: category ?? state.selectedCategory,
      selectedItemType: itemType ?? state.selectedItemType,
    );

    try {
      final items = await _storeService.getFamilyStoreItems(
        category: state.selectedCategory,
        activeOnly: activeOnly,
        itemType: state.selectedItemType,
      );

      // Filter by price if set
      final filteredItems = items.where((item) {
        if (state.minPrice != null && item.price < state.minPrice!) {
          return false;
        }
        if (state.maxPrice != null && item.price > state.maxPrice!) {
          return false;
        }
        return true;
      }).toList();

      // Update cache
      final updatedCache = Map<String, StoreItem>.from(state.itemCache);
      for (final item in filteredItems) {
        updatedCache[item.id] = item;
      }

      state = state.copyWith(
        storeItems: AsyncValue.data(filteredItems),
        itemCache: updatedCache,
        isLoading: false,
        currentPage: 1,
        hasMore: false, // Family store items are loaded all at once
      );
    } on Exception catch (e, stack) {
      state = state.copyWith(
        storeItems: AsyncValue.error(e, stack),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load store categories
  Future<void> loadCategories() async {
    try {
      final categories = await _storeService.getStoreCategories();
      state = state.copyWith(
        categories: AsyncValue.data(categories),
      );
    } on Exception catch (e, stack) {
      state = state.copyWith(
        categories: AsyncValue.error(e, stack),
      );
    }
  }

  /// Get a single store item
  Future<StoreItem?> getStoreItem(String itemId) async {
    // Check cache first
    if (state.itemCache.containsKey(itemId)) {
      return state.itemCache[itemId];
    }

    try {
      final item = await _storeService.getStoreItem(itemId);
      
      // Update cache
      final updatedCache = Map<String, StoreItem>.from(state.itemCache);
      updatedCache[itemId] = item;
      
      state = state.copyWith(itemCache: updatedCache);
      return item;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Create a new store item (Admin only)
  Future<StoreItem> createStoreItem({
    required String name,
    required String description,
    required double price,
    required String category,
    required String itemType,
    String? imageUrl,
    int? stock,
    int? ageRestriction,
    DateTime? availableFrom,
    DateTime? availableUntil,
    int? maxPurchasesPerChild,
    bool requiresApproval = false,
    List<String>? tags,
  }) async {
    try {
      final item = await _storeService.createStoreItem(
        name: name,
        description: description,
        price: price,
        category: category,
        itemType: itemType,
        imageUrl: imageUrl,
        stock: stock,
        ageRestriction: ageRestriction,
        availableFrom: availableFrom,
        availableUntil: availableUntil,
        maxPurchasesPerChild: maxPurchasesPerChild,
        requiresApproval: requiresApproval,
        tags: tags,
      );

      // Update local state
      final currentItems = state.storeItems.value ?? [];
      final updatedItems = [item, ...currentItems];
      
      // Update cache
      final updatedCache = Map<String, StoreItem>.from(state.itemCache);
      updatedCache[item.id] = item;

      state = state.copyWith(
        storeItems: AsyncValue.data(updatedItems),
        itemCache: updatedCache,
      );

      return item;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Update a store item (Admin only)
  Future<StoreItem> updateStoreItem({
    required String itemId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isActive,
    int? stock,
    int? ageRestriction,
    DateTime? availableFrom,
    DateTime? availableUntil,
    int? maxPurchasesPerChild,
    bool? requiresApproval,
    List<String>? tags,
  }) async {
    try {
      final item = await _storeService.updateStoreItem(
        itemId: itemId,
        name: name,
        description: description,
        price: price,
        category: category,
        imageUrl: imageUrl,
        isActive: isActive,
        stock: stock,
        ageRestriction: ageRestriction,
        availableFrom: availableFrom,
        availableUntil: availableUntil,
        maxPurchasesPerChild: maxPurchasesPerChild,
        requiresApproval: requiresApproval,
        tags: tags,
      );

      // Update local state
      final currentItems = state.storeItems.value ?? [];
      final updatedItems = currentItems.map((i) {
        return i.id == itemId ? item : i;
      }).toList();
      
      // Update cache
      final updatedCache = Map<String, StoreItem>.from(state.itemCache);
      updatedCache[itemId] = item;

      state = state.copyWith(
        storeItems: AsyncValue.data(updatedItems),
        itemCache: updatedCache,
      );

      return item;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Delete a store item (Admin only)
  Future<void> deleteStoreItem(String itemId) async {
    try {
      await _storeService.deleteStoreItem(itemId);

      // Update local state
      final currentItems = state.storeItems.value ?? [];
      final updatedItems = currentItems.where((item) => item.id != itemId).toList();
      
      // Update cache
      final updatedCache = Map<String, StoreItem>.from(state.itemCache)
      ..remove(itemId);

      state = state.copyWith(
        storeItems: AsyncValue.data(updatedItems),
        itemCache: updatedCache,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Purchase a store item
  Future<StorePurchase> purchaseItem({
    required String itemId,
    int quantity = 1,
    String? notes,
  }) async {
    try {
      final purchase = await _storeService.purchaseItem(
        itemId: itemId,
        quantity: quantity,
        notes: notes,
      );

      // Update purchase history
      final currentHistory = state.purchaseHistory.value ?? [];
      final updatedHistory = [purchase, ...currentHistory];
      
      // Update purchase cache
      final updatedPurchaseCache = Map<String, List<StorePurchase>>.from(state.purchaseCache);
      if (!updatedPurchaseCache.containsKey(itemId)) {
        updatedPurchaseCache[itemId] = [];
      }
      updatedPurchaseCache[itemId]!.insert(0, purchase);

      // Update item stock in cache if available
      if (state.itemCache.containsKey(itemId) && state.itemCache[itemId]!.stock != null) {
        final item = state.itemCache[itemId]!;
        final updatedItem = item.copyWith(
          stock: (item.stock! - quantity).clamp(0, double.infinity).toInt(),
        );
        
        final updatedItemCache = Map<String, StoreItem>.from(state.itemCache);
        updatedItemCache[itemId] = updatedItem;
        
        // Update items list
        final currentItems = state.storeItems.value ?? [];
        final updatedItems = currentItems.map((i) {
          return i.id == itemId ? updatedItem : i;
        }).toList();
        
        state = state.copyWith(
          storeItems: AsyncValue.data(updatedItems),
          itemCache: updatedItemCache,
        );
      }

      state = state.copyWith(
        purchaseHistory: AsyncValue.data(updatedHistory),
        purchaseCache: updatedPurchaseCache,
      );

      return purchase;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Load purchase history
  Future<void> loadPurchaseHistory({
    bool refresh = false,
    String? purchaserId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (state.isLoading && !refresh) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
    );

    try {
      final purchases = await _storeService.getPurchaseHistory(
        purchaserId: purchaserId,
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: refresh ? 1 : state.currentPage,
      );

      // Update purchase cache
      final updatedPurchaseCache = Map<String, List<StorePurchase>>.from(state.purchaseCache);
      for (final purchase in purchases) {
        if (!updatedPurchaseCache.containsKey(purchase.itemId)) {
          updatedPurchaseCache[purchase.itemId] = [];
        }
        if (!updatedPurchaseCache[purchase.itemId]!.any((p) => p.id == purchase.id)) {
          updatedPurchaseCache[purchase.itemId]!.add(purchase);
        }
      }

      // Merge with existing history if not refreshing
      final List<StorePurchase> updatedHistory;
      if (refresh) {
        updatedHistory = purchases;
      } else {
        final currentHistory = state.purchaseHistory.value ?? [];
        updatedHistory = [...currentHistory, ...purchases];
      }

      state = state.copyWith(
        purchaseHistory: AsyncValue.data(updatedHistory),
        purchaseCache: updatedPurchaseCache,
        isLoading: false,
        currentPage: refresh ? 2 : state.currentPage + 1,
        hasMore: purchases.length == _pageSize,
      );
    } on Exception catch (e, stack) {
      state = state.copyWith(
        purchaseHistory: AsyncValue.error(e, stack),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load pending purchases (Admin only)
  Future<void> loadPendingPurchases() async {
    try {
      final purchases = await _storeService.getPendingPurchases();
      state = state.copyWith(
        pendingPurchases: AsyncValue.data(purchases),
      );
    } on Exception catch (e, stack) {
      state = state.copyWith(
        pendingPurchases: AsyncValue.error(e, stack),
      );
    }
  }

  /// Approve purchase (Admin only)
  Future<StorePurchase> approvePurchase({
    required String purchaseId,
    bool approve = true,
    String? reason,
  }) async {
    try {
      final purchase = await _storeService.approvePurchase(
        purchaseId: purchaseId,
        approve: approve,
        reason: reason,
      );

      // Update pending purchases
      final currentPending = state.pendingPurchases.value ?? [];
      final updatedPending = currentPending.where((p) => p.id != purchaseId).toList();
      
      // Update purchase history
      final currentHistory = state.purchaseHistory.value ?? [];
      final updatedHistory = currentHistory.map((p) {
        return p.id == purchaseId ? purchase : p;
      }).toList();

      state = state.copyWith(
        pendingPurchases: AsyncValue.data(updatedPending),
        purchaseHistory: AsyncValue.data(updatedHistory),
      );

      return purchase;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Fulfill purchase (Admin only)
  Future<StorePurchase> fulfillPurchase({
    required String purchaseId,
    String? fulfillmentNotes,
  }) async {
    try {
      final purchase = await _storeService.fulfillPurchase(
        purchaseId: purchaseId,
        fulfillmentNotes: fulfillmentNotes,
      );

      // Update purchase history
      final currentHistory = state.purchaseHistory.value ?? [];
      final updatedHistory = currentHistory.map((p) {
        return p.id == purchaseId ? purchase : p;
      }).toList();

      state = state.copyWith(
        purchaseHistory: AsyncValue.data(updatedHistory),
      );

      return purchase;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Cancel purchase
  Future<StorePurchase> cancelPurchase({
    required String purchaseId,
    String? reason,
  }) async {
    try {
      final purchase = await _storeService.cancelPurchase(
        purchaseId: purchaseId,
        reason: reason,
      );

      // Update purchase history and pending purchases
      final currentHistory = state.purchaseHistory.value ?? [];
      final updatedHistory = currentHistory.map((p) {
        return p.id == purchaseId ? purchase : p;
      }).toList();

      final currentPending = state.pendingPurchases.value ?? [];
      final updatedPending = currentPending.where((p) => p.id != purchaseId).toList();

      state = state.copyWith(
        purchaseHistory: AsyncValue.data(updatedHistory),
        pendingPurchases: AsyncValue.data(updatedPending),
      );

      return purchase;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Rate purchase (Children only)
  Future<StorePurchase> ratePurchase({
    required String purchaseId,
    required double rating,
    String? review,
  }) async {
    try {
      final purchase = await _storeService.ratePurchase(
        purchaseId: purchaseId,
        rating: rating,
        review: review,
      );

      // Update purchase history
      final currentHistory = state.purchaseHistory.value ?? [];
      final updatedHistory = currentHistory.map((p) {
        return p.id == purchaseId ? purchase : p;
      }).toList();

      state = state.copyWith(
        purchaseHistory: AsyncValue.data(updatedHistory),
      );

      return purchase;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Get child's purchase count for an item
  Future<int> getChildPurchaseCount({
    required String itemId,
    required String childId,
  }) async {
    try {
      return await _storeService.getChildPurchaseCount(
        itemId: itemId,
        childId: childId,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return 0;
    }
  }

  /// Get store statistics (Admin only)
  Future<Map<String, dynamic>> getStoreStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _storeService.getStoreStatistics(
        startDate: startDate,
        endDate: endDate,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return {};
    }
  }

  /// Get items by category
  List<StoreItem> getItemsByCategory(String category) {
    final items = state.storeItems.value ?? [];
    return items.where((item) => item.category == category).toList();
  }

  /// Get items by type
  List<StoreItem> getItemsByType(String itemType) {
    final items = state.storeItems.value ?? [];
    return items.where((item) => item.itemType == itemType).toList();
  }

  /// Get available items only
  List<StoreItem> getAvailableItems() {
    final items = state.storeItems.value ?? [];
    return items.where((item) => item.isAvailable).toList();
  }

  /// Get out of stock items
  List<StoreItem> getOutOfStockItems() {
    final items = state.storeItems.value ?? [];
    return items.where((item) => !item.hasStock).toList();
  }

  /// Search items locally
  List<StoreItem> searchItemsLocally(String query) {
    final items = state.storeItems.value ?? [];
    final lowercaseQuery = query.toLowerCase();
    
    return items.where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
          item.description.toLowerCase().contains(lowercaseQuery) ||
          (item.tags?.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ?? false);
    }).toList();
  }

  /// Filter items by age restriction
  List<StoreItem> getItemsForAge(int age) {
    final items = state.storeItems.value ?? [];
    return items.where((item) {
      return item.ageRestriction == null || age >= item.ageRestriction!;
    }).toList();
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(
      currentPage: 1,
      hasMore: true,
    );
    loadFamilyStoreItems();
  }

  /// Refresh all store data
  Future<void> refresh() async {
    await Future.wait([
      loadFamilyStoreItems(refresh: true),
      loadCategories(),
      loadPurchaseHistory(refresh: true),
      loadPendingPurchases(),
    ]);
  }
}

/// Provider for store service
final storeServiceProvider = Provider<StoreService>((ref) {
  return StoreService();
});

/// Provider for store state notifier
final storeNotifierProvider = StateNotifierProvider<StoreNotifier, StoreState>((ref) {
  final storeService = ref.watch(storeServiceProvider);
  return StoreNotifier(storeService);
});

/// Provider for store items
final storeItemsProvider = Provider<AsyncValue<List<StoreItem>>>((ref) {
  return ref.watch(storeNotifierProvider).storeItems;
});

/// Provider for purchase history
final purchaseHistoryProvider = Provider<AsyncValue<List<StorePurchase>>>((ref) {
  return ref.watch(storeNotifierProvider).purchaseHistory;
});

/// Provider for pending purchases
final pendingPurchasesProvider = Provider<AsyncValue<List<StorePurchase>>>((ref) {
  return ref.watch(storeNotifierProvider).pendingPurchases;
});

/// Provider for store categories
final storeCategoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  return ref.watch(storeNotifierProvider).categories;
});

/// Provider for filtered store items by category
final itemsByCategoryProvider = Provider.family<List<StoreItem>, String>((ref, category) {
  final notifier = ref.watch(storeNotifierProvider.notifier);
  return notifier.getItemsByCategory(category);
});

/// Provider for filtered store items by type
final itemsByTypeProvider = Provider.family<List<StoreItem>, String>((ref, itemType) {
  final notifier = ref.watch(storeNotifierProvider.notifier);
  return notifier.getItemsByType(itemType);
});

/// Provider for available items only
final availableItemsProvider = Provider<List<StoreItem>>((ref) {
  final notifier = ref.watch(storeNotifierProvider.notifier);
  return notifier.getAvailableItems();
});

/// Provider for out of stock items
final outOfStockItemsProvider = Provider<List<StoreItem>>((ref) {
  final notifier = ref.watch(storeNotifierProvider.notifier);
  return notifier.getOutOfStockItems();
});