// frontend/data/models/store.dart

import 'dart:convert';

class StoreItem {

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.createdById, required this.createdByName, required this.familyId, required this.createdAt, required this.updatedAt, required this.itemType, this.imageUrl,
    this.isActive = true,
    this.stock,
    this.ageRestriction,
    this.availableFrom,
    this.availableUntil,
    this.maxPurchasesPerChild,
    this.requiresApproval = false,
    this.tags,
    this.metadata,
  });

  factory StoreItem.fromMap(Map<String, dynamic> map) {
    return StoreItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] != null ? (map['price'] as num).toDouble() : 0.0,
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] ?? true,
      stock: map['stock'] != null ? map['stock'] as int : null,
      createdById: map['createdById'] ?? '',
      createdByName: map['createdByName'] ?? '',
      familyId: map['familyId'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
      itemType: map['itemType'] ?? 'reward',
      ageRestriction: map['ageRestriction'] != null ? map['ageRestriction'] as int : null,
      availableFrom: map['availableFrom'] != null 
          ? DateTime.parse(map['availableFrom']) 
          : null,
      availableUntil: map['availableUntil'] != null 
          ? DateTime.parse(map['availableUntil']) 
          : null,
      maxPurchasesPerChild: map['maxPurchasesPerChild'] != null 
          ? map['maxPurchasesPerChild'] as int 
          : null,
      requiresApproval: map['requiresApproval'] ?? false,
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata']) 
          : null,
    );
  }

  factory StoreItem.fromJson(String source) => 
      StoreItem.fromMap(json.decode(source));
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool isActive;
  final int? stock;
  final String createdById;
  final String createdByName;
  final String familyId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String itemType; // 'reward', 'privilege', 'experience', 'physical'
  final int? ageRestriction;
  final DateTime? availableFrom;
  final DateTime? availableUntil;
  final int? maxPurchasesPerChild;
  final bool requiresApproval;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;

  // Computed properties
  bool get isAvailable {
    if (!isActive) {
      return false;
    }
    if (stock != null && stock! <= 0) {
      return false;
    }
    
    final now = DateTime.now();
    if (availableFrom != null && now.isBefore(availableFrom!)) {
      return false;
    }
    if (availableUntil != null && now.isAfter(availableUntil!)) {
      return false;
    }
    
    return true;
  }

  bool get hasStock => stock == null || stock! > 0;

  bool get isLimitedStock => stock != null;

  bool get isTimeLimited => availableFrom != null || availableUntil != null;

  bool canBePurchasedBy(String childId, int childAge, int existingPurchaseCount) {
    if (!isAvailable) {
      return false;
    }
    if (ageRestriction != null && childAge < ageRestriction!) {
      return false;
    }
    if (maxPurchasesPerChild != null && existingPurchaseCount >= maxPurchasesPerChild!) {
      return false;
    }
    return true;
  }

  StoreItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isActive,
    int? stock,
    String? createdById,
    String? createdByName,
    String? familyId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? itemType,
    int? ageRestriction,
    DateTime? availableFrom,
    DateTime? availableUntil,
    int? maxPurchasesPerChild,
    bool? requiresApproval,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      stock: stock ?? this.stock,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      familyId: familyId ?? this.familyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemType: itemType ?? this.itemType,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      availableFrom: availableFrom ?? this.availableFrom,
      availableUntil: availableUntil ?? this.availableUntil,
      maxPurchasesPerChild: maxPurchasesPerChild ?? this.maxPurchasesPerChild,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'stock': stock,
      'createdById': createdById,
      'createdByName': createdByName,
      'familyId': familyId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'itemType': itemType,
      'ageRestriction': ageRestriction,
      'availableFrom': availableFrom?.toIso8601String(),
      'availableUntil': availableUntil?.toIso8601String(),
      'maxPurchasesPerChild': maxPurchasesPerChild,
      'requiresApproval': requiresApproval,
      'tags': tags,
      'metadata': metadata,
    };
  }

  String toJson() => json.encode(toMap());
}

class StorePurchase {

  StorePurchase({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.purchaserId,
    required this.purchaserName,
    required this.price,
    required this.quantity,
    required this.status,
    required this.purchasedAt,
    required this.transactionId, required this.familyId, this.approvedAt,
    this.approvedById,
    this.approvedByName,
    this.fulfilledAt,
    this.fulfilledById,
    this.fulfilledByName,
    this.notes,
    this.fulfillmentNotes,
    this.rating,
    this.review,
    this.itemSnapshot,
    this.metadata,
  });

  factory StorePurchase.fromMap(Map<String, dynamic> map) {
    return StorePurchase(
      id: map['id'] ?? '',
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      purchaserId: map['purchaserId'] ?? '',
      purchaserName: map['purchaserName'] ?? '',
      price: map['price'] != null ? (map['price'] as num).toDouble() : 0.0,
      quantity: map['quantity'] ?? 1,
      status: map['status'] ?? 'pending',
      purchasedAt: map['purchasedAt'] != null 
          ? DateTime.parse(map['purchasedAt']) 
          : DateTime.now(),
      approvedAt: map['approvedAt'] != null 
          ? DateTime.parse(map['approvedAt']) 
          : null,
      approvedById: map['approvedById'],
      approvedByName: map['approvedByName'],
      fulfilledAt: map['fulfilledAt'] != null 
          ? DateTime.parse(map['fulfilledAt']) 
          : null,
      fulfilledById: map['fulfilledById'],
      fulfilledByName: map['fulfilledByName'],
      transactionId: map['transactionId'] ?? '',
      notes: map['notes'],
      fulfillmentNotes: map['fulfillmentNotes'],
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      review: map['review'],
      familyId: map['familyId'] ?? '',
      itemSnapshot: map['itemSnapshot'] != null 
          ? Map<String, dynamic>.from(map['itemSnapshot']) 
          : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata']) 
          : null,
    );
  }

  factory StorePurchase.fromJson(String source) => 
      StorePurchase.fromMap(json.decode(source));
  final String id;
  final String itemId;
  final String itemName;
  final String purchaserId;
  final String purchaserName;
  final double price;
  final int quantity;
  final String status; // 'pending', 'approved', 'fulfilled', 'cancelled'
  final DateTime purchasedAt;
  final DateTime? approvedAt;
  final String? approvedById;
  final String? approvedByName;
  final DateTime? fulfilledAt;
  final String? fulfilledById;
  final String? fulfilledByName;
  final String transactionId;
  final String? notes;
  final String? fulfillmentNotes;
  final double? rating;
  final String? review;
  final String familyId;
  final Map<String, dynamic>? itemSnapshot; // Store item details at time of purchase
  final Map<String, dynamic>? metadata;

  // Computed properties
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isFulfilled => status == 'fulfilled';
  bool get isCancelled => status == 'cancelled';
  
  bool get canBeApproved => isPending;
  bool get canBeFulfilled => isApproved;
  bool get canBeCancelled => isPending || isApproved;
  bool get canBeReviewed => isFulfilled && rating == null;

  double get totalPrice => price * quantity;

  Duration? get timeToPurchase => approvedAt?.difference(purchasedAt);
  Duration? get timeToFulfillment => 
      fulfilledAt != null && approvedAt != null 
          ? fulfilledAt!.difference(approvedAt!) 
          : null;

  StorePurchase copyWith({
    String? id,
    String? itemId,
    String? itemName,
    String? purchaserId,
    String? purchaserName,
    double? price,
    int? quantity,
    String? status,
    DateTime? purchasedAt,
    DateTime? approvedAt,
    String? approvedById,
    String? approvedByName,
    DateTime? fulfilledAt,
    String? fulfilledById,
    String? fulfilledByName,
    String? transactionId,
    String? notes,
    String? fulfillmentNotes,
    double? rating,
    String? review,
    String? familyId,
    Map<String, dynamic>? itemSnapshot,
    Map<String, dynamic>? metadata,
  }) {
    return StorePurchase(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      purchaserId: purchaserId ?? this.purchaserId,
      purchaserName: purchaserName ?? this.purchaserName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedById: approvedById ?? this.approvedById,
      approvedByName: approvedByName ?? this.approvedByName,
      fulfilledAt: fulfilledAt ?? this.fulfilledAt,
      fulfilledById: fulfilledById ?? this.fulfilledById,
      fulfilledByName: fulfilledByName ?? this.fulfilledByName,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      fulfillmentNotes: fulfillmentNotes ?? this.fulfillmentNotes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      familyId: familyId ?? this.familyId,
      itemSnapshot: itemSnapshot ?? this.itemSnapshot,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'purchaserId': purchaserId,
      'purchaserName': purchaserName,
      'price': price,
      'quantity': quantity,
      'status': status,
      'purchasedAt': purchasedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedById': approvedById,
      'approvedByName': approvedByName,
      'fulfilledAt': fulfilledAt?.toIso8601String(),
      'fulfilledById': fulfilledById,
      'fulfilledByName': fulfilledByName,
      'transactionId': transactionId,
      'notes': notes,
      'fulfillmentNotes': fulfillmentNotes,
      'rating': rating,
      'review': review,
      'familyId': familyId,
      'itemSnapshot': itemSnapshot,
      'metadata': metadata,
    };
  }

  String toJson() => json.encode(toMap());
}