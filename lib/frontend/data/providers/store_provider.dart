import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enums
enum CurrencyType { dollar, star }
enum PurchaseStatus { pending, completed, cancelled }

// Store Item model
class StoreItem {

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currencyType,
    required this.isActive,
    required this.createdAt,
    required this.familyId,
    this.imageUrl,
  });

  factory StoreItem.fromMap(Map<String, dynamic> data, String id) {
    return StoreItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      currencyType: CurrencyType.values.firstWhere(
        (e) => e.toString() == 'CurrencyType.${data['currencyType']}',
        orElse: () => CurrencyType.dollar,
      ),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      familyId: data['familyId'] ?? '',
    );
  }
  final String id;
  final String name;
  final String description;
  final double price;
  final CurrencyType currencyType;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final String familyId;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'currencyType': currencyType.toString().split('.').last,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'familyId': familyId,
    };
  }

  StoreItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    CurrencyType? currencyType,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    String? familyId,
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
      familyId: familyId ?? this.familyId,
    );
  }
}

// Store Purchase model
class StorePurchase {

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
    required this.familyId,
  });

  factory StorePurchase.fromMap(Map<String, dynamic> data, String id) {
    return StorePurchase(
      id: id,
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      childId: data['childId'] ?? '',
      childName: data['childName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      currencyType: CurrencyType.values.firstWhere(
        (e) => e.toString() == 'CurrencyType.${data['currencyType']}',
        orElse: () => CurrencyType.dollar,
      ),
      purchasedAt: (data['purchasedAt'] as Timestamp).toDate(),
      status: PurchaseStatus.values.firstWhere(
        (e) => e.toString() == 'PurchaseStatus.${data['status']}',
        orElse: () => PurchaseStatus.pending,
      ),
      familyId: data['familyId'] ?? '',
    );
  }
  final String id;
  final String itemId;
  final String itemName;
  final String childId;
  final String childName;
  final double price;
  final CurrencyType currencyType;
  final DateTime purchasedAt;
  final PurchaseStatus status;
  final String familyId;

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'childId': childId,
      'childName': childName,
      'price': price,
      'currencyType': currencyType.toString().split('.').last,
      'purchasedAt': Timestamp.fromDate(purchasedAt),
      'status': status.toString().split('.').last,
      'familyId': familyId,
    };
  }
}

// Item Details model
class ItemDetails {

  ItemDetails({
    required this.name,
    required this.description,
    required this.price,
    required this.currencyType,
    this.imageUrl,
  });
  final String name;
  final String description;
  final double price;
  final CurrencyType currencyType;
  final String? imageUrl;
}

// Store State
class StoreState {

  StoreState({
    required this.items,
    required this.purchaseHistory,
    required this.itemPurchaseCounts,
    required this.totalSpent,
  });
  final List<StoreItem> items;
  final List<StorePurchase> purchaseHistory;
  final Map<String, int> itemPurchaseCounts;
  final double totalSpent;

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

// Store Notifier
class StoreNotifier extends StateNotifier<AsyncValue<StoreState>> {

  StoreNotifier() : super(const AsyncValue.loading()) {
    loadStore();
  }
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loadStore() async {
    try {
      state = const AsyncValue.loading();
      
      final user = _auth.currentUser;
      if (user == null) {
        state = AsyncValue.error('User not authenticated', StackTrace.current);
        return;
      }

      // Get user's family ID
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final familyId = userDoc.data()?['familyId'] ?? '';

      // Load store items for the family
      final itemsSnapshot = await _db
          .collection('storeItems')
          .where('familyId', isEqualTo: familyId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final items = itemsSnapshot.docs
          .map((doc) => StoreItem.fromMap(doc.data(), doc.id))
          .toList();

      // Load purchase history
      final purchasesSnapshot = await _db
          .collection('storePurchases')
          .where('familyId', isEqualTo: familyId)
          .orderBy('purchasedAt', descending: true)
          .get();
      
      final purchases = purchasesSnapshot.docs
          .map((doc) => StorePurchase.fromMap(doc.data(), doc.id))
          .toList();
      
      // Calculate purchase counts and total spent
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
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addItem({
    required String parentId,
    required ItemDetails itemDetails,
  }) async {
    try {
      // Get family ID
      final userDoc = await _db.collection('users').doc(parentId).get();
      final familyId = userDoc.data()?['familyId'] ?? '';

      final item = StoreItem(
        id: '',
        name: itemDetails.name,
        description: itemDetails.description,
        price: itemDetails.price,
        currencyType: itemDetails.currencyType,
        imageUrl: itemDetails.imageUrl,
        isActive: true,
        createdAt: DateTime.now(),
        familyId: familyId,
      );

      await _db.collection('storeItems').add(item.toMap());
      
      await loadStore();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateItem({
    required String itemId,
    required ItemDetails itemDetails,
  }) async {
    try {
      await _db.collection('storeItems').doc(itemId).update({
        'name': itemDetails.name,
        'description': itemDetails.description,
        'price': itemDetails.price,
        'currencyType': itemDetails.currencyType.toString().split('.').last,
        'imageUrl': itemDetails.imageUrl,
        'updatedAt': Timestamp.now(),
      });
      
      await loadStore();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _db.collection('storeItems').doc(itemId).delete();
      
      await loadStore();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleItemActive(String itemId) async {
    try {
      final currentState = state.value;
      if (currentState == null) {
        return;
      }
      
      final item = currentState.items.firstWhere((i) => i.id == itemId);
      
      await _db.collection('storeItems').doc(itemId).update({
        'isActive': !item.isActive,
        'updatedAt': Timestamp.now(),
      });
      
      await loadStore();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> purchaseItem({
    required String childId,
    required String itemId,
  }) async {
    try {
      final currentState = state.value;
      if (currentState == null) {
        return;
      }

      final item = currentState.items.firstWhere((i) => i.id == itemId);
      
      // Get child's info
      final childDoc = await _db.collection('users').doc(childId).get();
      final childName = childDoc.data()?['name'] ?? '';
      final familyId = childDoc.data()?['familyId'] ?? '';

      // Check if child has enough balance/stars
      if (item.currencyType == CurrencyType.dollar) {
        // Check dollar balance in accounts
        final accountsSnapshot = await _db
            .collection('accounts')
            .where('userId', isEqualTo: childId)
            .get();
        
        double totalBalance = 0;
        for (var doc in accountsSnapshot.docs) {
          totalBalance += (doc.data()['balance'] ?? 0).toDouble();
        }
        
        if (totalBalance < item.price) {
          throw Exception('Insufficient funds');
        }
      } else {
        // Check star balance
        final starsBalance = childDoc.data()?['stars'] ?? 0;
        if (starsBalance < item.price) {
          throw Exception('Insufficient stars');
        }
      }

      // Create purchase record
      final purchase = StorePurchase(
        id: '',
        itemId: itemId,
        itemName: item.name,
        childId: childId,
        childName: childName,
        price: item.price,
        currencyType: item.currencyType,
        purchasedAt: DateTime.now(),
        status: PurchaseStatus.pending,
        familyId: familyId,
      );

      final purchaseRef = await _db.collection('storePurchases').add(purchase.toMap());

      // Deduct from child's balance/stars
      if (item.currencyType == CurrencyType.dollar) {
        // Deduct from primary account (checking)
        final accountsSnapshot = await _db
            .collection('accounts')
            .where('userId', isEqualTo: childId)
            .where('type', isEqualTo: 'checking')
            .limit(1)
            .get();
        
        if (accountsSnapshot.docs.isNotEmpty) {
          final accountDoc = accountsSnapshot.docs.first;
          final currentBalance = (accountDoc.data()['balance'] ?? 0).toDouble();
          
          await accountDoc.reference.update({
            'balance': currentBalance - item.price,
            'updatedAt': Timestamp.now(),
          });
        }
      } else {
        // Deduct stars
        final currentStars = childDoc.data()?['stars'] ?? 0;
        await _db.collection('users').doc(childId).update({
          'stars': currentStars - item.price.toInt(),
        });
      }

      // Mark purchase as completed
      await _db.collection('storePurchases').doc(purchaseRef.id).update({
        'status': 'completed',
      });

      // Create notification for parent
      await _db.collection('notifications').add({
        'userId': childDoc.data()?['parentId'] ?? '',
        'title': 'Store Purchase',
        'body': '$childName purchased ${item.name} for ${item.price} ${item.currencyType == CurrencyType.dollar ? 'dollars' : 'stars'}',
        'type': 'storePurchase',
        'data': {
          'purchaseId': purchaseRef.id,
          'itemId': itemId,
          'childId': childId,
        },
        'isRead': false,
        'createdAt': Timestamp.now(),
      });
      
      await loadStore();
    } on Exception catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  StoreItem? getItemById(String itemId) {
    final currentState = state.value;
    if (currentState == null) {
      return null;
    }
    
    try {
      return currentState.items.firstWhere((item) => item.id == itemId);
    } on StateError {
      return null;
    }
  }

  List<StoreItem> getActiveItems() {
    final currentState = state.value;
    if (currentState == null) {
      return [];
    }
    
    return currentState.items.where((item) => item.isActive).toList();
  }

  List<StorePurchase> getPurchasesForChild(String childId) {
    final currentState = state.value;
    if (currentState == null) {
      return [];
    }
    
    return currentState.purchaseHistory
        .where((purchase) => purchase.childId == childId)
        .toList();
  }

  int getPurchaseCountForItem(String itemId) {
    final currentState = state.value;
    if (currentState == null) {
      return 0;
    }
    
    return currentState.itemPurchaseCounts[itemId] ?? 0;
  }

  Future<void> refreshStore() async {
    await loadStore();
  }
}

// Provider
final storeProvider = StateNotifierProvider<StoreNotifier, AsyncValue<StoreState>>((ref) {
  return StoreNotifier();
});