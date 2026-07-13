import 'product_suggestion.dart';

class ComparisonSummary {
  final String productName;
  final String masterProductId;
  final List<ProductSuggestion> prices;
  final ProductSuggestion bestPrice;
  final double minPrice;
  final double maxPrice;
  final double averagePrice;

  const ComparisonSummary({
    required this.productName,
    required this.masterProductId,
    required this.prices,
    required this.bestPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.averagePrice,
  });

  ComparisonSummary copyWith({
    String? productName,
    String? masterProductId,
    List<ProductSuggestion>? prices,
    ProductSuggestion? bestPrice,
    double? minPrice,
    double? maxPrice,
    double? averagePrice,
  }) {
    return ComparisonSummary(
      productName: productName ?? this.productName,
      masterProductId: masterProductId ?? this.masterProductId,
      prices: prices ?? this.prices,
      bestPrice: bestPrice ?? this.bestPrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      averagePrice: averagePrice ?? this.averagePrice,
    );
  }

  factory ComparisonSummary.fromJson(Map<String, dynamic> json) {
    final prices = (json['prices'] as List<dynamic>)
        .map((e) => ProductSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
    return ComparisonSummary(
      productName: json['productName'] as String,
      masterProductId: json['masterProductId'] as String,
      prices: prices,
      bestPrice:
          ProductSuggestion.fromJson(json['bestPrice'] as Map<String, dynamic>),
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      averagePrice: (json['averagePrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'masterProductId': masterProductId,
      'prices': prices.map((e) => e.toJson()).toList(),
      'bestPrice': bestPrice.toJson(),
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'averagePrice': averagePrice,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComparisonSummary &&
        other.masterProductId == masterProductId &&
        other.productName == productName;
  }

  @override
  int get hashCode => Object.hash(masterProductId, productName);

  @override
  String toString() {
    final savings = bestPrice.price - maxPrice;
    return 'ComparisonSummary($productName — ₡${bestPrice.price} ~ ₡$maxPrice, ahorro ₡${savings.abs()})';
  }
}
