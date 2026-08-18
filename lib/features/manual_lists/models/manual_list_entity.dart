import 'package:flutter/material.dart';

enum ManualListStatus { active, completed, archived }

enum ListSortMode { name, createdAt, updatedAt, totalPrice, itemCount }

enum ListFilterMode { all, empty, hasProducts }

class ManualListItemEntity {
  final String id;
  final String productId;
  final String? masterProductId;
  final String storeId;
  final String storeNameSnapshot;
  int quantity;
  final double unitPriceSnapshot;
  double get currentPrice => unitPriceSnapshot;
  final DateTime addedAt;

  ManualListItemEntity({
    String? id,
    required this.productId,
    this.masterProductId,
    required this.storeId,
    required this.storeNameSnapshot,
    this.quantity = 1,
    required this.unitPriceSnapshot,
    DateTime? addedAt,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        addedAt = addedAt ?? DateTime.now();

  double get subtotal => unitPriceSnapshot * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'masterProductId': masterProductId,
        'storeId': storeId,
        'storeNameSnapshot': storeNameSnapshot,
        'quantity': quantity,
        'unitPriceSnapshot': unitPriceSnapshot,
        'addedAt': addedAt.toIso8601String(),
      };

  factory ManualListItemEntity.fromJson(Map<String, dynamic> json) {
    final addedAtRaw = json['addedAt'];
    return ManualListItemEntity(
      id: json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      productId: json['productId'] as String,
      masterProductId: json['masterProductId'] as String?,
      storeId: json['storeId'] as String? ?? '',
      storeNameSnapshot: json['storeNameSnapshot'] as String? ??
          (json['storeName'] as String? ?? ''),
      quantity: json['quantity'] as int? ?? 1,
      unitPriceSnapshot: (json['unitPriceSnapshot'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      addedAt: addedAtRaw != null
          ? DateTime.parse(addedAtRaw as String)
          : DateTime.now(),
    );
  }
}

class ManualListEntity {
  final String id;
  String name;
  String? description;
  List<ManualListItemEntity> items;
  ManualListStatus status;
  final DateTime createdAt;
  DateTime updatedAt;
  int colorValue;
  int iconCodePoint;
  int totalItems;
  int totalQuantity;
  double estimatedTotal;

  ManualListEntity({
    required this.id,
    required this.name,
    this.description,
    List<ManualListItemEntity>? items,
    this.status = ManualListStatus.active,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.colorValue = VibeDefaultColors.navy,
    this.iconCodePoint = VibeDefaultIcons.cart,
    int? totalItems,
    int? totalQuantity,
    double? estimatedTotal,
  })  : items = items ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        totalItems = totalItems ?? 0,
        totalQuantity = totalQuantity ?? 0,
        estimatedTotal = estimatedTotal ?? 0.0;

  int get itemCount => totalItems;
  double get totalPrice => estimatedTotal;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'status': status.name,
        'items': items.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'colorValue': colorValue,
        'iconCodePoint': iconCodePoint,
        'totalItems': totalItems,
        'totalQuantity': totalQuantity,
        'estimatedTotal': estimatedTotal,
      };

  factory ManualListEntity.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String?;
    return ManualListEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: statusStr != null
          ? ManualListStatus.values.firstWhere(
              (s) => s.name == statusStr,
              orElse: () => ManualListStatus.active,
            )
          : ManualListStatus.active,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  ManualListItemEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      colorValue: json['colorValue'] as int? ?? VibeDefaultColors.navy,
      iconCodePoint: json['iconCodePoint'] as int? ?? VibeDefaultIcons.cart,
      totalItems: json['totalItems'] as int? ?? 0,
      totalQuantity: json['totalQuantity'] as int? ?? 0,
      estimatedTotal: (json['estimatedTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}

abstract final class VibeDefaultColors {
  static const int navy = 0xFF2C3E50;
  static const int mint = 0xFFA8D5BA;
  static const int red = 0xFFE74C3C;
  static const int blue = 0xFF3498DB;
  static const int orange = 0xFFF39C12;
  static const int purple = 0xFF9B59B6;
  static const int teal = 0xFF1ABC9C;
  static const int pink = 0xFFE91E63;
  static const int brown = 0xFF795548;
  static const int blueGrey = 0xFF607D8B;

  static const List<int> all = [
    navy,
    mint,
    red,
    blue,
    orange,
    purple,
    teal,
    pink,
    brown,
    blueGrey,
  ];
}

abstract final class VibeDefaultIcons {
  static const int cart = 0xe8cc;
  static const int bag = 0xe8d0;
  static const int favorite = 0xe87d;
  static const int star = 0xe838;
  static const int home = 0xe88a;
  static const int restaurant = 0xe56c;
  static const int eco = 0xea35;
  static const int trophy = 0xe906;
  static const int localOffer = 0xe54e;
  static const int checkroom = 0xe19e;

  static const List<int> all = [
    cart,
    bag,
    favorite,
    star,
    home,
    restaurant,
    eco,
    trophy,
    localOffer,
    checkroom,
  ];

  static IconData iconFromCodePoint(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }
}
