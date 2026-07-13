class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit;
  final double? estimatedPrice;
  final String? storeId;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.estimatedPrice,
    this.storeId,
  });

  RecipeIngredient copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? estimatedPrice,
    String? storeId,
  }) {
    return RecipeIngredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      storeId: storeId ?? this.storeId,
    );
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
      storeId: json['storeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      if (estimatedPrice != null) 'estimatedPrice': estimatedPrice,
      if (storeId != null) 'storeId': storeId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeIngredient &&
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
    return 'RecipeIngredient($name — $quantity $unit)';
  }
}
