class ShoppingListItem {
  final String name;
  final double quantity;
  final String unit;
  final double? estimatedPrice;
  final String? storeId;
  final String? category;

  const ShoppingListItem({
    required this.name,
    required this.quantity,
    required this.unit,
    this.estimatedPrice,
    this.storeId,
    this.category,
  });

  ShoppingListItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? estimatedPrice,
    String? storeId,
    String? category,
  }) {
    return ShoppingListItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      storeId: storeId ?? this.storeId,
      category: category ?? this.category,
    );
  }

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
      storeId: json['storeId'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      if (estimatedPrice != null) 'estimatedPrice': estimatedPrice,
      if (storeId != null) 'storeId': storeId,
      if (category != null) 'category': category,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingListItem &&
        other.name == name &&
        other.quantity == quantity &&
        other.unit == unit;
  }

  @override
  int get hashCode {
    return Object.hash(name, quantity, unit);
  }

  @override
  String toString() {
    return 'ShoppingListItem($name x$quantity $unit)';
  }
}
