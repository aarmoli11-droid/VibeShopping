import 'store_price.dart';

class ComparisonResult {
  final String masterProductId;
  final String productName;
  final List<StorePrice> stores;

  const ComparisonResult({
    required this.masterProductId,
    required this.productName,
    required this.stores,
  });

  StorePrice? get bestPrice {
    if (stores.length < 2) return null;
    return stores.reduce((a, b) => a.price < b.price ? a : b);
  }

  double savingsFor(String storeId) {
    final store = stores.where((s) => s.storeId == storeId).firstOrNull;
    final best = bestPrice;
    if (store == null || best == null) return 0;
    final diff = store.price - best.price;
    return diff > 0 ? diff : 0;
  }

  double savingsPercentFor(String storeId) {
    final store = stores.where((s) => s.storeId == storeId).firstOrNull;
    final best = bestPrice;
    if (store == null || best == null || store.price == 0) return 0;
    return ((store.price - best.price) / store.price) * 100;
  }

  List<String> get requiredStores =>
      stores.map((s) => s.storeId).toSet().toList();
}

class ComparisonPreview {
  final String bestStoreName;
  final String? bestStoreLogoUrl;
  final double bestPrice;
  final double savings;
  final int storeCount;

  const ComparisonPreview({
    required this.bestStoreName,
    this.bestStoreLogoUrl,
    required this.bestPrice,
    required this.savings,
    required this.storeCount,
  });
}
