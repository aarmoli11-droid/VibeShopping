class ProductSuggestion {
  final String productId;
  final String productName;
  final String? brand;
  final String? imageUrl;
  final String storeId;
  final String storeName;
  final double price;
  final String currency;
  final String? savingsTip;

  const ProductSuggestion({
    required this.productId,
    required this.productName,
    this.brand,
    this.imageUrl,
    required this.storeId,
    required this.storeName,
    required this.price,
    required this.currency,
    this.savingsTip,
  });

  ProductSuggestion copyWith({
    String? productId,
    String? productName,
    String? brand,
    String? imageUrl,
    String? storeId,
    String? storeName,
    double? price,
    String? currency,
    String? savingsTip,
  }) {
    return ProductSuggestion(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      savingsTip: savingsTip ?? this.savingsTip,
    );
  }

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) {
    return ProductSuggestion(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String?,
      imageUrl: json['imageUrl'] as String?,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      savingsTip: json['savingsTip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      if (brand != null) 'brand': brand,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'storeId': storeId,
      'storeName': storeName,
      'price': price,
      'currency': currency,
      if (savingsTip != null) 'savingsTip': savingsTip,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductSuggestion &&
        other.productId == productId &&
        other.storeId == storeId &&
        other.price == price;
  }

  @override
  int get hashCode {
    return Object.hash(productId, storeId, price);
  }

  @override
  String toString() {
    return 'ProductSuggestion($productName — ₡$price @ $storeName)';
  }
}
