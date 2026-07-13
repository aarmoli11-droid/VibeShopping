class PriceComparisonInfo {
  final double? currentPrice;
  final double? recommendedPrice;
  final String? bestStoreId;
  final String? bestStoreName;
  final double? estimatedSavings;

  const PriceComparisonInfo({
    this.currentPrice,
    this.recommendedPrice,
    this.bestStoreId,
    this.bestStoreName,
    this.estimatedSavings,
  });

  double? get savingsPercent {
    if (currentPrice == null || recommendedPrice == null || currentPrice == 0)
      return null;
    return ((currentPrice! - recommendedPrice!) / currentPrice!) * 100;
  }
}
