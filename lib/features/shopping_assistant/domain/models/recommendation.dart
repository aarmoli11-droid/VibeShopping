import 'product_suggestion.dart';

class Recommendation {
  final String productId;
  final String productName;
  final ProductSuggestion recommendedStore;
  final List<ProductSuggestion> alternatives;
  final String reason;
  final String? comparisonSummary;

  const Recommendation({
    required this.productId,
    required this.productName,
    required this.recommendedStore,
    required this.alternatives,
    required this.reason,
    this.comparisonSummary,
  });

  Recommendation copyWith({
    String? productId,
    String? productName,
    ProductSuggestion? recommendedStore,
    List<ProductSuggestion>? alternatives,
    String? reason,
    String? comparisonSummary,
  }) {
    return Recommendation(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      recommendedStore: recommendedStore ?? this.recommendedStore,
      alternatives: alternatives ?? this.alternatives,
      reason: reason ?? this.reason,
      comparisonSummary: comparisonSummary ?? this.comparisonSummary,
    );
  }

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      recommendedStore: ProductSuggestion.fromJson(
          json['recommendedStore'] as Map<String, dynamic>),
      alternatives: (json['alternatives'] as List<dynamic>)
          .map((e) => ProductSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      reason: json['reason'] as String,
      comparisonSummary: json['comparisonSummary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'recommendedStore': recommendedStore.toJson(),
      'alternatives': alternatives.map((e) => e.toJson()).toList(),
      'reason': reason,
      if (comparisonSummary != null) 'comparisonSummary': comparisonSummary,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recommendation &&
        other.productId == productId &&
        other.productName == productName;
  }

  @override
  int get hashCode {
    return Object.hash(productId, productName);
  }

  @override
  String toString() {
    return 'Recommendation($productName → ${recommendedStore.storeName})';
  }
}
