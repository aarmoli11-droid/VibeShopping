class SummaryProductInfo {
  final String productId;
  final String productName;
  final double price;
  final String storeName;
  final int quantity;

  const SummaryProductInfo({
    required this.productId,
    required this.productName,
    required this.price,
    required this.storeName,
    required this.quantity,
  });
}

class ManualListSummary {
  final int totalItems;
  final int totalQuantity;
  final double estimatedTotal;
  final double averageProductPrice;
  final SummaryProductInfo? mostExpensiveProduct;
  final SummaryProductInfo? cheapestProduct;
  final List<String> storesInvolved;
  final List<String> categoriesInvolved;
  final DateTime lastUpdated;

  const ManualListSummary({
    required this.totalItems,
    required this.totalQuantity,
    required this.estimatedTotal,
    required this.averageProductPrice,
    this.mostExpensiveProduct,
    this.cheapestProduct,
    required this.storesInvolved,
    required this.categoriesInvolved,
    required this.lastUpdated,
  });
}
