import '../../../../frontend/data/models/store_item.dart';
import 'api_service.dart';
import 'auth_service.dart';

class StoreService {
  final ApiService _apiService;
  final AuthService _authService;

  StoreService({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  // Add item to family store (parent only)
  Future<StoreItem> addItem({
    required String name,
    required String description,
    required double price,
    required CurrencyType currencyType,
    String? imageUrl,
    String? category,
    int? quantity,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    final requestBody = {
      'parentId': currentUser.id,
      'itemDetails': {
        'name': name,
        'description': description,
        'price': price,
        'currencyType': currencyType.name,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (category != null) 'category': category,
        if (quantity != null) 'quantity': quantity,
      },
    };

    final response = await _apiService.post(
      '/store/add-item',
      body: requestBody,
      token: token,
    );

    return StoreItem.fromJson(response);
  }

  // Get all store items for family
  Future<List<StoreItem>> getStoreItems() async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/store/items',
      token: token,
    );

    return (response['items'] as List)
        .map((json) => StoreItem.fromJson(json))
        .toList();
  }

  // Get store item by ID
  Future<StoreItem> getItemById(String itemId) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/store/items/$itemId',
      token: token,
    );

    return StoreItem.fromJson(response);
  }

  // Purchase item from store (child)
  Future<StorePurchase> purchaseItem({
    required String itemId,
    int quantity = 1,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    final requestBody = {
      'childId': currentUser.id,
      'itemId': itemId,
      'quantity': quantity,
    };

    final response = await _apiService.post(
      '/store/purchase',
      body: requestBody,
      token: token,
    );

    return StorePurchase.fromJson(response);
  }

  // Update store item (parent only)
  Future<StoreItem> updateItem({
    required String itemId,
    String? name,
    String? description,
    double? price,
    CurrencyType? currencyType,
    String? imageUrl,
    String? category,
    int? quantity,
    bool? isActive,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (price != null) updates['price'] = price;
    if (currencyType != null) updates['currencyType'] = currencyType.name;
    if (imageUrl != null) updates['imageUrl'] = imageUrl;
    if (category != null) updates['category'] = category;
    if (quantity != null) updates['quantity'] = quantity;
    if (isActive != null) updates['isActive'] = isActive;

    final response = await _apiService.patch(
      '/store/items/$itemId',
      body: updates,
      token: token,
    );

    return StoreItem.fromJson(response);
  }

  // Delete store item (parent only)
  Future<void> deleteItem(String itemId) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    await _apiService.delete(
      '/store/items/$itemId',
      token: token,
    );
  }

  // Get purchase history for child
  Future<List<StorePurchase>> getPurchaseHistory({
    String? childId,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('User not found');

    final queryParams = childId != null ? '?childId=$childId' : '';

    final response = await _apiService.get(
      '/store/purchases$queryParams',
      token: token,
    );

    return (response['purchases'] as List)
        .map((json) => StorePurchase.fromJson(json))
        .toList();
  }

  // Get store categories
  Future<List<String>> getCategories() async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/store/categories',
      token: token,
    );

    return List<String>.from(response['categories']);
  }

  // Search store items
  Future<List<StoreItem>> searchItems({
    String? query,
    String? category,
    CurrencyType? currencyType,
    double? maxPrice,
    bool? activeOnly = true,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (query != null) queryParams['q'] = query;
    if (category != null) queryParams['category'] = category;
    if (currencyType != null) queryParams['currencyType'] = currencyType.name;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (activeOnly != null) queryParams['activeOnly'] = activeOnly.toString();

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _apiService.get(
      '/store/search${queryString.isNotEmpty ? '?$queryString' : ''}',
      token: token,
    );

    return (response['items'] as List)
        .map((json) => StoreItem.fromJson(json))
        .toList();
  }

  // Check if child can afford item
  Future<bool> canAffordItem({
    required String itemId,
    required String childId,
  }) async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/store/can-afford?itemId=$itemId&childId=$childId',
      token: token,
    );

    return response['canAfford'] as bool;
  }

  // Get store statistics (parent)
  Future<StoreStatistics> getStoreStatistics() async {
    final token = await _authService.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get(
      '/store/statistics',
      token: token,
    );

    return StoreStatistics.fromJson(response);
  }
}

// Supporting models for store-specific data

class StoreItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final CurrencyType currencyType;
  final String? imageUrl;
  final String? category;
  final int quantity;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currencyType,
    this.imageUrl,
    this.category,
    required this.quantity,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] ?? json['itemId'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      currencyType: CurrencyType.values.firstWhere(
        (e) => e.name == json['currencyType'],
        orElse: () => CurrencyType.cash,
      ),
      imageUrl: json['imageUrl'],
      category: json['category'],
      quantity: json['quantity'] ?? -1,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class StorePurchase {
  final String id;
  final String itemId;
  final String childId;
  final String itemName;
  final double price;
  final CurrencyType currencyType;
  final int quantity;
  final double totalAmount;
  final PurchaseStatus status;
  final DateTime purchasedAt;

  StorePurchase({
    required this.id,
    required this.itemId,
    required this.childId,
    required this.itemName,
    required this.price,
    required this.currencyType,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.purchasedAt,
  });

  factory StorePurchase.fromJson(Map<String, dynamic> json) {
    return StorePurchase(
      id: json['id'] ?? json['transactionId'],
      itemId: json['itemId'],
      childId: json['childId'],
      itemName: json['itemName'],
      price: (json['price'] as num).toDouble(),
      currencyType: CurrencyType.values.firstWhere(
        (e) => e.name == json['currencyType'],
        orElse: () => CurrencyType.cash,
      ),
      quantity: json['quantity'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: PurchaseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PurchaseStatus.completed,
      ),
      purchasedAt: DateTime.parse(json['purchasedAt']),
    );
  }
}

class StoreStatistics {
  final int totalItems;
  final int activeItems;
  final int totalPurchases;
  final double totalRevenue;
  final Map<String, int> purchasesByCategory;
  final List<TopSellingItem> topSellingItems;

  StoreStatistics({
    required this.totalItems,
    required this.activeItems,
    required this.totalPurchases,
    required this.totalRevenue,
    required this.purchasesByCategory,
    required this.topSellingItems,
  });

  factory StoreStatistics.fromJson(Map<String, dynamic> json) {
    return StoreStatistics(
      totalItems: json['totalItems'],
      activeItems: json['activeItems'],
      totalPurchases: json['totalPurchases'],
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      purchasesByCategory: Map<String, int>.from(json['purchasesByCategory']),
      topSellingItems: (json['topSellingItems'] as List)
          .map((item) => TopSellingItem.fromJson(item))
          .toList(),
    );
  }
}

class TopSellingItem {
  final String itemId;
  final String itemName;
  final int purchaseCount;
  final double totalRevenue;

  TopSellingItem({
    required this.itemId,
    required this.itemName,
    required this.purchaseCount,
    required this.totalRevenue,
  });

  factory TopSellingItem.fromJson(Map<String, dynamic> json) {
    return TopSellingItem(
      itemId: json['itemId'],
      itemName: json['itemName'],
      purchaseCount: json['purchaseCount'],
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );
  }
}

enum CurrencyType { cash, stars }

enum PurchaseStatus { pending, completed, cancelled, refunded }