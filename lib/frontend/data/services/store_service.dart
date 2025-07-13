// frontend/data/services/store_service.dart

import 'package:flutter/foundation.dart';

import '../models/store.dart';
import 'api_service.dart';
import 'auth_service.dart';

class StoreService {
  factory StoreService() => _instance;
  StoreService._internal();
  static final StoreService _instance = StoreService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Get family store items
  Future<List<StoreItem>> getFamilyStoreItems({
    String? category,
    bool activeOnly = true,
    String? itemType,
  }) async {
    try {
      final response = await _apiService.get(
        '/store/family-items',
        queryParameters: {
          if (category != null) 'category': category,
          'activeOnly': activeOnly,
          if (itemType != null) 'itemType': itemType,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final items = responseData['items'] as List<dynamic>;
      return items
          .map((item) => StoreItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      debugPrint('Error getting family store items: $e');
      rethrow;
    }
  }

  // Get specific store item
  Future<StoreItem> getStoreItem(String itemId) async {
    try {
      final response = await _apiService.get('/store/items/$itemId');
      final responseData = response.data as Map<String, dynamic>;
      return StoreItem.fromMap(responseData['item'] as Map<String, dynamic>);
    } on Exception catch (e) {
      debugPrint('Error getting store item: $e');
      rethrow;
    }
  }

  // Create store item (adults only)
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
      final user = await _authService.getCurrentUser();
      if (user == null || !user.isAdult) {
        throw Exception('Only adults can create store items');
      }

      final response = await _apiService.post(
        '/store/items',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'category': category,
          'itemType': itemType,
          if (imageUrl != null) 'imageUrl': imageUrl,
          if (stock != null) 'stock': stock,
          if (ageRestriction != null) 'ageRestriction': ageRestriction,
          if (availableFrom != null) 'availableFrom': availableFrom.toIso8601String(),
          if (availableUntil != null) 'availableUntil': availableUntil.toIso8601String(),
          if (maxPurchasesPerChild != null) 'maxPurchasesPerChild': maxPurchasesPerChild,
          'requiresApproval': requiresApproval,
          if (tags != null) 'tags': tags,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return StoreItem.fromMap(responseData['item'] as Map<String, dynamic>);
    } on Exception catch (e) {
      debugPrint('Error creating store item: $e');
      rethrow;
    }
  }

  // Update store item (adults only)
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
      final user = await _authService.getCurrentUser();
      if (user == null || !user.isAdult) {
        throw Exception('Only adults can update store items');
      }

      final response = await _apiService.put(
        '/store/items/$itemId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (price != null) 'price': price,
          if (category != null) 'category': category,
          if (imageUrl != null) 'imageUrl': imageUrl,
          if (isActive != null) 'isActive': isActive,
          if (stock != null) 'stock': stock,
          if (ageRestriction != null) 'ageRestriction': ageRestriction,
          if (availableFrom != null) 'availableFrom': availableFrom.toIso8601String(),
          if (availableUntil != null) 'availableUntil': availableUntil.toIso8601String(),
          if (maxPurchasesPerChild != null) 'maxPurchasesPerChild': maxPurchasesPerChild,
          if (requiresApproval != null) 'requiresApproval': requiresApproval,
          if (tags != null) 'tags': tags,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return StoreItem.fromMap(responseData['item'] as Map<String, dynamic>);
    } on Exception catch (e) {
      debugPrint('Error updating store item: $e');
      rethrow;
    }
  }

  // Delete store item (adults only)
  Future<void> deleteStoreItem(String itemId) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || !user.isAdult) {
        throw Exception('Only adults can delete store items');
      }

      await _apiService.delete('/store/items/$itemId');
    } on Exception catch (e) {
      debugPrint('Error deleting store item: $e');
      rethrow;
    }
  }

  // Purchase store item (children only)
  Future<StorePurchase> purchaseItem({
    required String itemId,
    int quantity = 1,
    String? notes,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || !user.isChild) {
        throw Exception('Only children can purchase store items');
      }

      final response = await _apiService.post(
        '/store/purchase',
        data: {
          'itemId': itemId,
          'quantity': quantity,
          if (notes != null) 'notes': notes,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return StorePurchase.fromMap(responseData['purchase'] as Map<String, dynamic>);
    } on Exception catch (e) {
      debugPrint('Error purchasing item: $e');
      rethrow;
    }
  }

  // Get purchase history
  Future<List<StorePurchase>> getPurchaseHistory({
    String? purchaserId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/store/purchases',
        queryParameters: {
          if (purchaserId != null) 'purchaserId': purchaserId,
          if (status != null) 'status': status,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          'page': page,
          'limit': limit,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final purchases = responseData['purchases'] as List<dynamic>;
      return purchases
          .map((purchase) => StorePurchase.fromMap(purchase as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      debugPrint('Error getting purchase history: $e');
      rethrow;
    }
  }

  // Get specific purchase
  Future<StorePurchase> getPurchase(String purchaseId) async {
    try {
      final response = await _apiService.get('/store/purchases/$purchaseId');
      final responseData = response.data as Map<String, dynamic>;
      return StorePurchase.fromMap(responseData['purchase'] as Map<String, dynamic>);
    } on Exception catch (e) {
      debugPrint('Error getting purchase: $e');
      rethrow;
    }
  }

  // Approve purchase (adults only)
  Future<StorePurchase> approvePurchase({
    required String purchaseId,
    bool approve = true,
    String? reason,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || !user.isAdult) {
        throw Exception('Only adults can approve purchases');
      }

      final response = await _apiService.post(
        '/store/purchases/$purchaseId/approve',
        data: {
          'approve': approve,
          if (reason != null) 'reason': reason,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return StorePurchase.fromMap(responseData['purchase'] as Map<String, dynamic>);
    } on Exception catch (e) {
      debugPrint('Error approving purchase: $e');
      rethrow;
    }
  }

  // Fulfill purchase (adults only)
  Future<StorePurchase> fulfillPurchase({
    required String purchaseId,
    String? fulfillmentNotes,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || !user.isAdult) {
        throw Exception('Only adults can fulfill purchases');
      }

      final response = await _apiService.post(
        '/store/purchases/$purchaseId/fulfill',
        data: {
          if (fulfillmentNotes != null) 'fulfillmentNotes': fulfillmentNotes,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return StorePurchase.fromMap(responseData['purchase'] as Map<String, dynamic>);
    } on Exception catch (e) {
      debugPrint('Error fulfilling purchase: $e');
      rethrow;
    }
  }

  // Cancel purchase
  Future<StorePurchase> cancelPurchase({
    required String purchaseId,
    String? reason,
  }) async {
    try {
      final response = await _apiService.post(
        '/store/purchases/$purchaseId/cancel',
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return StorePurchase.fromMap(responseData['purchase'] as Map<String, dynamic>);
    } on Exception catch (e) {
      debugPrint('Error cancelling purchase: $e');
      rethrow;
    }
  }

  // Rate and review purchase (children only)
  Future<StorePurchase> ratePurchase({
    required String purchaseId,
    required double rating,
    String? review,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || !user.isChild) {
        throw Exception('Only children can rate purchases');
      }

      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      final response = await _apiService.post(
        '/store/purchases/$purchaseId/rate',
        data: {
          'rating': rating,
          if (review != null) 'review': review,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return StorePurchase.fromMap(responseData['purchase'] as Map<String, dynamic>);
    } on Exception catch (e) {
      debugPrint('Error rating purchase: $e');
      rethrow;
    }
  }

  // Get pending purchases for approval (adults only)
  Future<List<StorePurchase>> getPendingPurchases() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || !user.isAdult) {
        throw Exception('Only adults can view pending purchases');
      }

      final response = await _apiService.get('/store/purchases/pending');
      final responseData = response.data as Map<String, dynamic>;
      final purchases = responseData['purchases'] as List<dynamic>;
      return purchases
          .map((purchase) => StorePurchase.fromMap(purchase as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      debugPrint('Error getting pending purchases: $e');
      rethrow;
    }
  }

  // Get child's purchase count for an item
  Future<int> getChildPurchaseCount({
    required String itemId,
    required String childId,
  }) async {
    try {
      final response = await _apiService.get(
        '/store/items/$itemId/purchase-count',
        queryParameters: {
          'childId': childId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return responseData['count'] as int;
    } on Exception catch (e) {
      debugPrint('Error getting purchase count: $e');
      rethrow;
    }
  }

  // Get store categories
  Future<List<String>> getStoreCategories() async {
    try {
      final response = await _apiService.get('/store/categories');
      final responseData = response.data as Map<String, dynamic>;
      final categories = responseData['categories'] as List<dynamic>;
      return categories.cast<String>();
    } on Exception catch (e) {
      debugPrint('Error getting store categories: $e');
      rethrow;
    }
  }

  // Get store statistics (adults only)
  Future<Map<String, dynamic>> getStoreStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || !user.isAdult) {
        throw Exception('Only adults can view store statistics');
      }

      final response = await _apiService.get(
        '/store/statistics',
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      return response.data as Map<String, dynamic>;
    } on Exception catch (e) {
      debugPrint('Error getting store statistics: $e');
      rethrow;
    }
  }
}